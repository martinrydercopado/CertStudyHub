# Multi-Agent Architecture in Agentforce
### Strategic Patterns, Interoperability Protocols, and Architectural Boundaries

---

## Table of Contents

1. [The Mental Model](#1-the-mental-model)
2. [Syntax and Structure: The Deterministic-Reasoning Divide](#2-syntax-and-structure-the-deterministic-reasoning-divide)
3. [Subagent Boundaries: Deterministic Triggers for Logic Segmentation](#3-subagent-boundaries-deterministic-triggers-for-logic-segmentation)
4. [Agent Boundaries: Orchestration Thresholds and System Autonomy](#4-agent-boundaries-orchestration-thresholds-and-system-autonomy)
5. [Multi-Agent Design Patterns: A Comparative Technical Study](#5-multi-agent-design-patterns-a-comparative-technical-study)
6. [The Three Deployment Patterns: SOMA, MOMA, and 3P](#6-the-three-deployment-patterns-soma-moma-and-3p)
7. [Routing Architecture and Priority](#7-routing-architecture-and-priority)
8. [Model Selection and the `model_config` Override](#8-model-selection-and-the-model_config-override)
9. [State, Memory, and Context Sharing](#9-state-memory-and-context-sharing)
10. [Interoperability Protocols: MCP and A2A](#10-interoperability-protocols-mcp-and-a2a)
11. [Common Failure Modes](#11-common-failure-modes)
12. [Trust, Security, and Identity](#12-trust-security-and-identity)
13. [Governance, Observability, and Quality Assurance](#13-governance-observability-and-quality-assurance)
14. [Production Heuristics and Design Principles](#14-production-heuristics-and-design-principles)
- [Appendix A: Key Term Glossary](#appendix-a-key-term-glossary)
- [Appendix B: Protocol and Model Reference](#appendix-b-protocol-and-model-reference)

---

## 1. The Mental Model

### 1.1 From Decision Trees to Distributed Reasoning

The enterprise landscape is undergoing a fundamental strategic shift from legacy monolithic bot architectures — rigid, linear decision trees — toward a distributed "Agentic" mindset. Architects must now view Agentforce not as a collection of static scripts, but as a **distributed reasoning system** capable of dynamic task handling.

This paradigm shift requires abandoning hard-coded paths in favor of an architecture where a single agent is inherently multi-purpose, operating as a sophisticated orchestration of intent rather than a brittle series of if-then statements. The Agentforce Mindset assumes three things:

- **Intent classification is probabilistic,** not programmatic. The LLM selects the right domain based on conversational context, not a lookup table.
- **State is dynamic,** not pre-scripted. Variables evolve across turns, across subagents, and across agent boundaries.
- **Safety is enforced at the architecture level,** not by trusting the LLM to comply with natural language instructions.

### 1.2 The Finite State Machine Model

Each **subagent functions as an independent finite state machine**. The system's intelligence emerges from the interaction between three elements.

| Element | Role |
|---|---|
| **Variables** | The agent's working memory. State that persists across turns and subagents. |
| **Instructions** | The rules that govern reasoning within a turn. Re-evaluated after every action. |
| **Topics (Subagents)** | The bounded domains of expertise. Each subagent owns a specific set of behaviors. |

### 1.3 Variable System Taxonomy

Understanding the four variable types is a prerequisite for any multi-agent design work. They have fundamentally different scopes, mutability rules, and failure modes.

| Type | Mutability | How Populated | Example |
|---|---|---|---|
| **Linked** | Read-only | External context at session start | `customer_name` linked from contact record |
| **Mutable** | Read-write | Set by the agent during the session | `@variables.order_id`, `@variables.verified` |
| **Slot-fill** | Write-once per turn | LLM extracts value from conversation via `...` token | Collecting an order number from natural speech |
| **System** | Read-only | Predefined runtime context | `@system_variables.user_input` |

> **Best practice:** Always initialize mutable variables with explicit default values in the `variables:` block. An uninitialized variable returns a null-like default that can cause `available when` guards to fail silently.

```agentscript
variables:
    is_verified: mutable boolean = False
    order_id:    mutable string  = ""
    # NOT: is_verified: mutable boolean  <-- uninitialized, dangerous
```

### 1.4 The Core Architectural Axiom

The single most important principle in Agent Script is the **execution order guarantee:**

> **Deterministic logic (`->`) executes before the LLM reasoning layer engages. Always.**

This is not a convention. It is a runtime contract. Actions run, variables are set, and conditionals branch exactly as written before the LLM processes any text.

The practical implication: **authorization gates, trust checks, and irreversible action guards must be written as `->` logic, not as `|` natural language instructions.** Writing a guard in natural language is asking the LLM to comply. Writing it in `->` is enforcing compliance at the runtime level.

---

## 2. Syntax and Structure: The Deterministic-Reasoning Divide

### 2.1 The Two Instruction Operators

| Operator | Name | What It Does | Who Processes It |
|---|---|---|---|
| `->` | Logic / Procedural | Executes if/else, run, set, transition | The Agent Script runtime |
| `\|` | Reasoning / Declarative | Assembles prompt text for the LLM | The LLM |

The LLM never sees raw `->` instructions. It receives only the assembled prompt text from `|` lines, with all conditionals already resolved and all variable values already injected.

```agentscript
reasoning:
    instructions: ->
        if @variables.is_verified == True:
            | Your account balance is {!@variables.account_balance}.
              How else can I help you today?

        if @variables.is_verified == False:
            | I need to verify your identity before sharing account details.
              Could you provide your registered email address?
```

### 2.2 `after_reasoning` Transition Syntax

> **Critical Rule:** When placing a transition inside an `after_reasoning` block, you **must** use the deterministic bare syntax `transition to @subagent.X`. You must **never** use `@utils.transition to` here. Using `@utils.transition` in `after_reasoning` causes a compilation error.

| Syntax | Valid In | Executed By |
|---|---|---|
| `transition to @subagent.X` | `before_reasoning`, `after_reasoning`, `->` blocks | The Agent Script runtime |
| `@utils.transition to @subagent.X` | `reasoning: actions:` block only | The LLM selects it as a tool |

> **Lifecycle trap:** If a subagent transitions to a new subagent mid-reasoning, the original subagent's `after_reasoning` block is **completely aborted**. The new subagent's `before_reasoning` does not fire retroactively for that same turn. Never rely on `after_reasoning` for state that is critical to system correctness.

### 2.3 Instruction Surfaces and Their Scope

Five distinct instruction surfaces exist. Each has a specific runtime moment and overwrite behavior.

| Surface | Runs When | Scope Behavior |
|---|---|---|
| `system.instructions` (global) | Every LLM call, all subagents | Durable persona, safety, scope |
| `system.instructions` (subagent-level) | Only in the owning subagent | **Replaces** the global block entirely; does not merge |
| `before_reasoning` | Once per turn, before all LLM calls | Pure `->` deterministic logic only |
| `reasoning.instructions` | Rebuilt after every tool call in the loop | Current objective, state injection, action guidance |
| `after_reasoning` | Once, after reasoning loop produces a response | State cleanup, post-response transitions |

### 2.4 The `before_reasoning` and `after_reasoning` Lifecycle

These blocks execute **outside the LLM reasoning loop**. The LLM has no awareness of them.

```agentscript
subagent account_inquiry:
    before_reasoning:
        # Fires EVERY turn, BEFORE the LLM sees anything
        if @variables.is_verified == False:
            transition to @subagent.identity_verification
        run @actions.get_account_summary
            with customer_id = @variables.customer_id
            set @variables.account_balance = @outputs.balance
            set @variables.account_status  = @outputs.status
```

### 2.5 Action Invocation Patterns

Two invocation patterns exist and they are not interchangeable.

| Pattern | Syntax | Who Decides | Use Case |
|---|---|---|---|
| **Deterministic** | `run @actions.X` inside `->` block | The runtime — unconditional | Must-execute logic: data loading, auth gates |
| **LLM-Driven** | Listed in `reasoning: actions:` block | The LLM selects from available tools | Conversational, contextual tool selection |

```agentscript
reasoning:
    instructions: ->
        # DETERMINISTIC: Always runs before LLM reasons
        run @actions.load_customer_profile
            with id = @variables.customer_id
            set @variables.tier = @outputs.tier

        | Customer tier is {!@variables.tier}. How can I help you today?

    actions:
        # LLM-DRIVEN: LLM decides whether and when to call this
        upgrade_tier: @actions.upgrade_customer_tier
            description: "Upgrades the customer to the next service tier"
            available when @variables.tier == "Standard"
            with customer_id = @variables.customer_id
```

> **Bug Pattern Alert:** Referencing `@actions.X` in `|` prose without also listing the action in the `actions:` block (for LLM-driven mode) or calling it with `run` (for deterministic mode) results in **silent failure**.

### 2.6 Post-Action Re-Resolution and Check Placement

`reasoning.instructions` is **rebuilt from scratch after every action executes**. Post-action checks placed at the **top** of the block fire immediately when variables update.

```agentscript
reasoning:
    instructions: ->
        # CORRECT: Post-action check at TOP — fires on re-resolution
        if @variables.order_cancelled == True:
            | Your order has been cancelled. Reference: {!@variables.cancellation_ref}.
            transition to @subagent.confirmation_agent

        | I can help you cancel your order. Please provide your order number.

    actions:
        cancel_order: @actions.cancel_order_action
            description: "Cancels the specified order"
            available when @variables.order_id != ""
            with order_id = @variables.order_id
            set @variables.order_cancelled  = @outputs.success
            set @variables.cancellation_ref = @outputs.reference_number
```

---

> **Scenario Pause — Lifecycle Trap**
>
> A developer builds a checkout agent. The `payment_subagent` is supposed to log every transaction in `after_reasoning` before transitioning to `confirmation_subagent`. In production, 12% of sessions show no transaction log.
>
> **Root cause:** The LLM occasionally calls a `@utils.transition` action mid-reasoning. This aborts `after_reasoning`. The log action never fires for those sessions.
>
> **Fix:** Move the logging `run` statement into `reasoning.instructions` as a deterministic step before the transition. Confirm any `after_reasoning` transitions use bare `transition to @subagent.X` syntax.

---

## 3. Subagent Boundaries: Deterministic Triggers for Logic Segmentation

### 3.1 The Default Posture: Start Minimal

> **Start with a single-domain agentic agent. Add complexity only when justified by a concrete, named requirement.**

Every subagent boundary adds routing overhead, context-passing complexity, and a new class of failure modes.

### 3.2 The Three Triggers for Subagent Segmentation

**Trigger 1: Instruction Overload**

Excessive instruction length degrades reasoning fidelity. Instruction length alone is not the trigger; *quality degradation* is.

*Diagnostic signal:* The agent consistently misses rule conditions or conflates domain-specific details.

**Trigger 2: Functional Divergence**

Different processing logic, data sources, or security guardrails mixed in one subagent cause the LLM to incur context-switching overhead.

*Diagnostic signal:* The agent handles two domains requiring different permissions, data sources, or trust levels.

**Trigger 3: Modularity and Regression Control**

Isolating distinct responsibilities enables independent update cycles.

*Diagnostic signal:* Different teams own different functional areas, or the same area changes frequently enough that co-location creates regression risk.

### 3.3 Case Study: Customer Service Agent Segmentation

```
start_agent (router)
    |
    ├── user_verification
    |       Trigger 2: different security guardrails, different data
    |       - Collects email address
    |       - Verifies identity against company records
    |       - Sets @variables.is_verified = True/False
    |
    ├── order_status
    |       Trigger 3: separate team, independent change cadence
    |       - Collects order number (slot-fill via ...)
    |       - Retrieves order details
    |       - Handles follow-up: expedite, cancel, reship
    |
    └── case_management
            Trigger 1: distinct instruction set — mixing with order_status
                        would overload context with case taxonomy rules
            - Creates support cases for verified users
            - Handles verification failures, order escalations
            - Routes to human queue via @utils.escalate
```

**Flow of control:** Every utterance returns to `start_agent`. No subagent routes directly to another.

### 3.4 The `available when` Guard as a Security Primitive

When an `available when` condition is not met, the action is **completely hidden from the LLM's tool list** — not disabled, not grayed out. The LLM cannot be prompted into calling it.

```agentscript
subagent order_status:
    reasoning:
        instructions: ->
            | I can help you with your order.
        actions:
            cancel_order: @actions.cancel_order
                description: "Cancels the specified order"
                available when @variables.order_id  != ""
                    and @variables.is_verified == True

            get_order_status: @actions.get_order_status
                description: "Retrieves the current status of an order"
                available when @variables.order_id != ""
```

---

> **Scenario Pause — Trigger Evaluation**
>
> An architect designs an HR agent with three capabilities: leave balance inquiry, payroll inquiry, and disciplinary record inquiry.
>
> - Trigger 2: Disciplinary records require elevated permissions and stricter audit logging.
> - Trigger 3: Leave and payroll share the same HR systems team. Disciplinary records are owned by Employee Relations with a different SDLC.
>
> **Decision:** Two subagents. `hr_inquiry` handles leave and payroll. `disciplinary_inquiry` is separate.

---

## 4. Agent Boundaries: Orchestration Thresholds and System Autonomy

### 4.1 When a Subagent Boundary Becomes an Agent Boundary

**Boundary 1: Lifecycle and SDLC Independence**

A shared `.agent` file represents **shared fate**. If different development teams require independent release cadences, deployment pipelines, and rollback capabilities, those functions must reside in **separate agents**.

**Boundary 2: Independent Invocation**

If a domain must be directly callable from external systems — other agents, external APIs, orchestrators — it requires its own agent identity with its own A2A endpoint and Agent Card.

**Boundary 3: Regulatory Isolation**

When different domains require different data sovereignty, tenant isolation, or compliance boundaries, they must reside in separate agents (potentially in separate orgs via MOMA).

### 4.2 State Management Across Agent Boundaries

| Mechanism | Transfer Type | Caller Context | When to Use |
|---|---|---|---|
| `@utils.transition` to a connected agent | One-way handoff | Caller context is discarded after transfer | Terminal transfers: the subagent owns the session from this point |
| `@subagent.<name>` (within same agent) | Round-trip delegation | Control returns to caller after subagent completes | Non-terminal delegations: caller needs to act on the result |

---

## 5. Multi-Agent Design Patterns: A Comparative Technical Study

### Pattern 1: Monolithic Subagent

| Dimension | Assessment |
|---|---|
| **Reasoning fidelity** | Low. Context dilution across mixed domains. |
| **State management** | Simple. No cross-subagent variable passing. |
| **SDLC** | High risk. Any change touches all capabilities. |
| **Use when** | Prototype only. Never in production for complex logic. |

### Pattern 2: Single Agent with Intent Classifier (SOMA Light)

| Dimension | Assessment |
|---|---|
| **Reasoning fidelity** | High. Scoped, focused instructions per subagent. |
| **State management** | Medium. Variables shared within the same agent lifecycle. |
| **SDLC** | Medium risk. Entire agent redeployed for any single subagent update. |
| **Use when** | One team owns all domains; infrequent updates; shared org boundary appropriate. |

### Pattern 3: Orchestrator to Separate Agents (SOMA/MOMA)

| Dimension | Assessment |
|---|---|
| **Reasoning fidelity** | Maximum. Full contextual isolation per agent. |
| **State management** | Complex. Cross-agent state passing requires explicit variable mapping; MOMA caps at 10 messages. |
| **SDLC** | Maximum independence. Each agent has its own deployment lifecycle. |
| **Use when** | Different teams own each domain; regulatory isolation required; independent API exposure needed. |

### Pattern 4: Hybrid Orchestration

| Dimension | Assessment |
|---|---|
| **Reasoning fidelity** | High for grouped domains; maximum for isolated specialists. |
| **Use when** | Some domains share genuine data affinity; others require strict isolation. |

### Pattern Selection Decision Tree

```
Does any domain need independent API exposure or A2A invocability?
    YES -> Pattern 3 or 4 (separate agents required)
    NO  -> Continue

Do different teams own different domains with independent release cadences?
    YES -> Pattern 3 or 4
    NO  -> Continue

Do any domains require different permission boundaries?
    YES -> Pattern 3 or 4
    NO  -> Continue

Would a single subagent exceed high-fidelity reasoning capacity?
    YES -> Pattern 2 (single agent, multiple subagents)
    NO  -> Pattern 1 (single subagent, simplest viable architecture)
```

---

> **Scenario Pause — Pattern Selection Under Pressure**
>
> A fintech company wants a unified "Wealth Management Assistant." Credit analysis: Risk team, quarterly releases, strict audit. Portfolio rebalancing: Advisory team, daily updates. Client communication history: CRM, shared with 4 other agents, rarely changes.
>
> **Result:** Hybrid Pattern 3/4. Credit and Portfolio as separate agents (independent SDLC). Client history as a reusable subagent within a shared "Client Context Agent."

---

## 6. The Three Deployment Patterns: SOMA, MOMA, and 3P

### 6.1 SOMA — Single-Org Multi-Agent

**GA technical limits:**

- Up to 7-8 subagents wide (soft limit; flagged in observability dashboard at 7)
- 2 delegation levels deep (A to B; no tertiary)
- Session duration: 24-48 hours maximum
- Bidirectional variable sync (GA)
- Last 20 messages of conversation history passed on delegation

**SOMA latency profile (P95):**

| Hop | Component | Overhead |
|---|---|---|
| Hop 1 | Orchestrator routing (EinsteinHyperClassifier) | +3-5s |
| Hop 2 | Agent-to-agent API call | +2-4s |
| Hop 3 | Subagent topic selection (LLM) | +3-5s |
| Hop 4 | Response synthesis — Supervised Mode only | +2-3s |
| **P95 Total (Supervised)** | | **~12-20s** |
| **P95 Total (Handoff Mode)** | Hop 4 removed | **~8-14s** |

### 6.2 MOMA — Multi-Org Multi-Agent

**Before you choose MOMA: evaluate Data Cloud Zero-Copy Federation first.**

MOMA carries significant technical constraints: a 10-message context cap, JWT-based identity propagation complexity, pass-by-value memory (no shared state), and a hard one-level delegation limit.

> **Can the external org's data be federated into the primary org using Data Cloud Zero-Copy?**
>
> If yes, you can maintain a SOMA pattern. The data boundary concern is solved at the data layer — not the orchestration layer.

**When MOMA is still correct despite Data Cloud availability:**

- The secondary org requires write-backs that must execute within its own tenant boundary.
- Regulatory requirements mandate that the agent logic itself executes within the secondary org's tenancy.
- The secondary org is owned by a separate business entity where tenant-level isolation is non-negotiable.
- The secondary org team requires independent agent deployment governance, not just independent data access.

**Decision rule:** If data access alone is the constraint, solve it at the data layer with Data Cloud. If agent execution boundaries or governance isolation are the constraint, MOMA is correct.

**MOMA hard architectural constraints:**

| Constraint | Rule | Reason |
|---|---|---|
| Delegation depth | Strictly one level (Primary to Secondary; no tertiary) | Prevents failure cascade and undefined context ownership |
| Context cap | Last 10 messages passed (hard limit) | Cross-org payload management |
| Memory model | Pass-by-value, not shared memory | No externally shared persistent state between orgs |
| Trust boundary | All orgs must share the same DC1 boundary | Data sovereignty compliance |
| Org membership | One org can belong to ONE trust boundary | Prevents cross-boundary leakage |
| Agent shareability | Agents are NOT auto-shared; admin must explicitly mark as shareable | Security-by-default posture |

**Identity propagation in MOMA:**

- **Primary path:** Email-based identity resolver maps the logged-in user across orgs without re-authentication.
- **Fallback:** If email resolution fails, the system defaults to Guest User — a significant permission downgrade that must be explicitly planned for.
- **Step-up authentication:** If a secondary org requires additional auth, the login prompt fires in the **primary org's interface**, not the secondary org's.

### 6.3 3P — Third-Party Agent Interoperability

| Direction | Auth Mechanism | Status |
|---|---|---|
| **Outbound** (AF to 3P) | Named Credentials + OAuth; Guest User only | Pilot |
| **Inbound** (3P to AF) | AEA: Web-Server Flow; ASA: Client Credentials Flow | Pilot |

**Hard limits:** A2A payload must conform to A2A protocol schema; no parallel tasks per request; plain text responses only (rich modalities post-Pilot); 15-second round-trip limit.

---

> **Scenario Pause — SOMA vs. MOMA vs. Data Cloud**
>
> A financial services firm has credit, legal, and valuation teams. Credit uses a separate Salesforce org for regulatory isolation of bureau data.
>
> First question: Can the credit org's data be federated via Data Cloud Zero-Copy?
> - If **yes, and the credit agent only needs read access:** federate and keep SOMA. No JWT complexity, no 10-message cap, full bidirectional variable sync.
> - If **no — because the credit agent must write back to bureau systems:** MOMA is correct.

---

## 7. Routing Architecture and Priority

### 7.1 The Routing Stack

```
User Message
    |
    v
[1] Einstein Trust Layer
    Prompt_Injection check
    Inappropriate_Content check
    Reverse_Engineering check
    BLOCK here = custom agents never execute
    |
    v
[2] EinsteinHyperClassifier (when used as router model)
    Salesforce-owned, optimized for routing (not a generic LLM)
    Significantly faster and more accurate for classification
    ONLY supports @utils.transition
    PROHIBITS before_reasoning and after_reasoning blocks
    |
    v
[3] Subagent Topic Selection (standard LLM)
    Full before_reasoning / after_reasoning support here
    |
    v
[4] Subagent Action Selection
```

### 7.2 CRITICAL: The EinsteinHyperClassifier Constraint and Model Override

**EinsteinHyperClassifier advantages:**
- Significantly faster subagent classification compared to other LLMs.
- Increased classification accuracy, particularly for specialized classification constraints and negative instructions.

**EinsteinHyperClassifier hard limitations (platform-enforced, not configurable):**
- **Cannot** use `before_reasoning` or `after_reasoning`.
- **Can only** use the tool `@utils.transition` — no other tool types.

If you attempt to deploy an agent definition that includes `before_reasoning` logic at the router level while the HyperClassifier is the assigned model, **the deployment will fail**.

**Correct HyperClassifier-compatible router:**

```agentscript
# CORRECT -- HyperClassifier-compatible router
start_agent agent_router:
    description: "Route user requests to the appropriate specialist"
    model_config:
        model: "model://EinsteinHyperClassifier"
    reasoning:
        instructions: |
            You are a router only. Do NOT answer questions directly.
            Always use a transition action to route immediately.
        actions:
            go_to_identity: @utils.transition to @subagent.identity_verification
                description: "Verifies user identity before sensitive operations"
                available when @variables.verified == False

            go_to_orders: @utils.transition to @subagent.order_management
                description: "Handles order inquiries, modifications, and cancellations"
                available when @variables.verified == True

            go_to_billing: @utils.transition to @subagent.billing_support
                description: "Processes payment questions, refunds, and invoice disputes"
                available when @variables.verified == True
```

**What you cannot do with HyperClassifier:**

```agentscript
# WRONG -- deployment will fail if HyperClassifier is the router model
start_agent agent_router:
    before_reasoning:                    # PROHIBITED with HyperClassifier
        if @variables.verified == False:
            transition to @subagent.identity_verification
    reasoning:
        instructions: ->
            | How can I help you today?
        actions:
            go_to_orders: @utils.transition to @subagent.order_management
                description: "Order inquiries"
```

**How to use deterministic `before_reasoning` logic at the router level:**

```agentscript
# Router with model override -- enables before_reasoning and after_reasoning
start_agent agent_router:
    description: "Welcome the user and determine the appropriate subagent"
    model_config:
        model: "model://sfdc_ai__DefaultGPT41"    # Standard LLM replaces HyperClassifier
    before_reasoning:
        if @variables.verified == False:
            transition to @subagent.identity_verification
    reasoning:
        instructions: ->
            | How can I help you today?
        actions:
            go_to_orders: @utils.transition to @subagent.order_management
                description: "Order inquiries"
```

**The trade-off is real.** Overriding to a standard LLM gains lifecycle hook support but adds latency and reduces routing precision.

| Requirement | Model Choice |
|---|---|
| Maximum routing speed and classification accuracy | EinsteinHyperClassifier — no lifecycle hooks |
| Deterministic `before_reasoning` gate at router level | Standard LLM via `model_config:` — accepts latency trade-off |
| Both speed and lifecycle hooks | Auth gate subagent pattern — keep HyperClassifier as router; push preconditions into the first-destination subagent |

### 7.3 Routing Determinism Within Subagents

Within subagents, the model is always a standard LLM (unless you override it), so `before_reasoning`, `after_reasoning`, and all lifecycle hooks are fully supported.

```agentscript
subagent order_management:
    before_reasoning:
        if @variables.order_id == "":
            run @actions.get_recent_orders
                with customer_id = @variables.customer_id
                set @variables.recent_orders = @outputs.orders
    reasoning:
        instructions: ->
            if @variables.order_id != "":
                | I found your order. Here are the details.
            else:
                | Which order can I help you with?
        actions:
            cancel_order: @actions.cancel_order
                description: "Cancel a specific order"
                available when @variables.order_id  != ""
                    and @variables.is_verified == True
```

### 7.4 Handoff Mode vs. Supervised Mode

| Mode | Who Responds to User | Latency | Multi-intent Support |
|---|---|---|---|
| **Supervised** | Superagent synthesizes subagent output | Higher (+2-3s synthesis hop) | Yes — Superagent coordinates multiple subagents |
| **Handoff** | Subagent streams directly to user | Lower (synthesis hop removed) | No — single-intent only |

> **Session termination discrepancy:** In Preview, subagent session termination appears clean. In live channels (LEX, Slack, MIAW), session termination behavior may differ. Always validate in the **target deployment channel**.

### 7.5 Description Hygiene and the `go_to_` Convention

Routing accuracy depends on sharp, mutually exclusive descriptions. The EinsteinHyperClassifier treats descriptions as classification boundaries. Overlapping descriptions produce non-deterministic routing.

```agentscript
# BAD -- overlapping descriptions cause inconsistent routing
subagent billing_support:
    description: "Handles customer payment and account questions"
subagent account_management:
    description: "Handles customer account and payment issues"

# GOOD -- mutually exclusive, precise descriptions
subagent billing_support:
    description: "Processes payments, refunds, and invoice disputes"
subagent account_management:
    description: "Manages profile updates, password resets, and access permissions"
```

Use the `go_to_` prefix on all transition actions. This groups transitions visually, signals routing intent to the HyperClassifier, and makes the action list scannable in complex agents.

---

> **Scenario Pause — Routing Architecture Decision**
>
> A fraud detection team requires every conversation to be checked against a real-time fraud score before any subagent executes. The architect wants to implement this as `before_reasoning` logic in the router.
>
> **Problem:** The router uses the EinsteinHyperClassifier. `before_reasoning` is prohibited. A `model_config:` override would add latency and reduce routing accuracy.
>
> **Better solution:** Keep the HyperClassifier router. Add a dedicated `fraud_gate` subagent as the **first routing destination**. `fraud_gate` uses `before_reasoning` to run the fraud check deterministically, sets `@variables.fraud_score`, then routes to the appropriate domain subagent or terminates the session.

---

## 8. Model Selection and the `model_config` Override

### 8.1 The Default Model Inheritance Chain

By default, Agentforce uses the **org-level model selected in Setup** for all agents and all subagents. The `model_config:` block overrides this default at any level of the hierarchy.

**Precedence (most specific wins):**

```
Org-level model (Setup default)
    overridden by
Agent-level model_config (applies to all subagents in this agent)
    overridden by
Subagent-level model_config (applies only to this subagent)
```

**Concrete example from the official docs:**

- `MyTestAgent` sets Claude Haiku 4.5 at the agent level.
- `HandleReservation` subagent overrides to Gemini 3.1 Pro at the subagent level.
- Result: `HandleReservation` uses Gemini 3.1 Pro; all other subagents in `MyTestAgent` use Claude Haiku 4.5; all other agents in the org use the Salesforce default.

### 8.2 Syntax and Placement

**Agent-level (between `system:` and subagents):**

```agentscript
system:
    instructions: "You are an AI service assistant."
    messages:
        welcome: "Hi, I'm an AI service assistant. How can I help?"
        error: "Sorry, it looks like something has gone wrong."

model_config:
    model: "model://sfdc_ai__DefaultBedrockAnthropicClaude45Haiku"
```

**Subagent-level:**

```agentscript
subagent ReservationManagement:
    description: "Handles requests to create new reservations for customers."
    model_config:
        model: "model://sfdc_ai__DefaultBedrockAnthropicClaude45Haiku"
    reasoning:
        instructions: ->
            | When would you like your reservation?
```

**Router-level (inside `start_agent`):**

```agentscript
start_agent agent_router:
    description: "Welcome the user and determine the appropriate subagent"
    model_config:
        model: "model://sfdc_ai__DefaultGPT41"
    reasoning:
        instructions: |
            Route the user to the correct subagent.
        actions:
            go_to_reservations: @utils.transition to @subagent.ReservationManagement
                description: "Handles reservation requests"
```

### 8.3 Officially Supported and Recommended Models

> **Note on model API names:** The identifiers below are Salesforce-internal `sfdc_ai__` API names. They are distinct from the public release names used by Anthropic, Google, and OpenAI. These exact strings must be used in `model://` URIs — substituting public model names will cause compilation errors.

| Model (Salesforce Name) | API Name (use in `model://`) | Best For |
|---|---|---|
| **GPT 4.1** | `sfdc_ai__DefaultGPT41` | Router override, general-purpose reasoning |
| **Claude Haiku 4.5** | `sfdc_ai__DefaultBedrockAnthropicClaude45Haiku` | Slot-fill, lightweight subagents, latency-sensitive tasks |
| **Gemini 3.5 Flash** | `sfdc_ai__DefaultVertexAIGemini35Flash` | Fast conversational handling |

> **Important:** Other supported models may not be suitable for every agent or tool. Thoroughly test your agent with your chosen model before deploying.

### 8.4 The Model Assignment Strategy

| Subagent Type | Characteristics | Recommended Model |
|---|---|---|
| **Router / Classifier** | Routing only; no conversational reasoning | EinsteinHyperClassifier (default in Service templates) |
| **Slot-fill Collector** | Extracts one value; no complex reasoning | Claude Haiku 4.5 (fast, low latency) |
| **Lightweight Conversational** | Standard transactional dialogue | Agent-level default; no subagent override needed |
| **Complex Reasoning** | Multi-step analysis, ambiguous input, regulatory compliance | Heavyweight model; subagent-level override |
| **Escalation / Handoff** | Brief summary and route to human | Claude Haiku 4.5 |

### 8.5 Practical Example: Model-Stratified Agent Architecture

```agentscript
system:
    instructions: "You are a customer service assistant."
    messages:
        welcome: "Hi, how can I help you today?"
        error:   "Something went wrong. Please try again."

# Agent-level default: GPT 4.1 for most subagents
model_config:
    model: "model://sfdc_ai__DefaultGPT41"

start_agent agent_router:
    description: "Route user requests to the correct specialist"
    model_config:
        model: "model://EinsteinHyperClassifier"
    reasoning:
        instructions: |
            Route immediately. Do not answer questions directly.
        actions:
            go_to_collect:     @utils.transition to @subagent.collect_order_id
                description: "Collect the customer's order number"
            go_to_compliance:  @utils.transition to @subagent.compliance_analysis
                description: "Perform regulatory compliance analysis on a request"
            go_to_confirm:     @utils.transition to @subagent.order_confirmed
                description: "Confirm an order has been placed"

subagent collect_order_id:
    description: "Collects the customer's order number"
    model_config:
        model: "model://sfdc_ai__DefaultBedrockAnthropicClaude45Haiku"
    reasoning:
        instructions: ->
            | What is your order number?
        actions:
            set_order_id: @utils.setVariables
                with order_id = ...

# Complex reasoning: inherits GPT 4.1 from agent-level default
subagent compliance_analysis:
    description: "Performs regulatory compliance analysis"
    reasoning:
        instructions: ->
            run @actions.load_regulatory_context
                with jurisdiction = @variables.customer_region
                set @variables.regulatory_rules = @outputs.rules
            | Analyze the customer's request against: {!@variables.regulatory_rules}
              Provide a compliant recommendation only.

subagent order_confirmed:
    description: "Confirms order placement to the customer"
    model_config:
        model: "model://sfdc_ai__DefaultBedrockAnthropicClaude45Haiku"
    reasoning:
        instructions: ->
            | Your order {!@variables.order_id} has been confirmed.
              Is there anything else I can help you with?
```

### 8.6 Latency Budgeting With `model_config`

```
SOMA Latency Budget -- Model Stratification Impact (indicative P95):

EinsteinHyperClassifier (router)           ~1-2s  (vs. ~3-5s with standard LLM)
collect_order_id (Haiku)                   ~1-2s  (vs. ~3-5s with standard LLM)
compliance_analysis (GPT 4.1, inherited)   ~3-5s  (task justifies cost)
order_confirmed (Haiku)                    ~1-2s  (vs. ~3-5s with standard LLM)

P95 Total (Handoff Mode, stratified):      ~7-12s
P95 Total (Supervised, stratified):        ~10-15s

vs. uniform standard model at every hop:
P95 Total (Supervised):                    ~12-20s
```

### 8.7 Testing Model Selections

Test model selections using **different models in different versions of your agent:**

- Version A: Claude Haiku 4.5 at agent level (lightweight baseline)
- Version B: GPT 4.1 at agent level (higher capability baseline)

Compare session traces across versions to identify where model choice materially affects output quality or latency. Promote the version that best balances both for your production traffic profile.

---

## 9. State, Memory, and Context Sharing

### 9.1 Variable Types and Cross-Boundary Sync

| Scope | SOMA (GA) | MOMA | 3P |
|---|---|---|---|
| Mutable variable sync | Bidirectional | Pass-by-value at delegation time | Session ID + last 10 messages only |
| Context history passed | Last 20 messages | Last 10 messages (hard cap) | Last 10 messages |
| Shared persistent memory | No — variables only | No | No |

**Bidirectional sync in SOMA (GA):** Changes a subagent makes during its turn are reflected in the Superagent's state when control returns — even in Handoff Mode.

**Variable mapping validation:** If a mapped variable is renamed or deleted, the platform **blocks the save operation**. Silent breakage in variable mappings is catastrophic at runtime, so the platform surfaces it at design time.

### 9.2 Variable Scope Lifecycle Rules

| Reference | Valid Scope | Common Mistake |
|---|---|---|
| `@inputs.X` | Only during `with` clause of action invocation | Using in a `set` statement after the action completes — always null |
| `@outputs.X` | Only in `set`/`if` immediately after the producing action | Referencing two blocks later — null |
| `@variables.X` | Anywhere after the variable is set | Referencing before the producing action runs — returns default |

```agentscript
# WRONG -- @inputs out of scope in set
run @actions.get_station_status
    with station_name = @variables.input_station
    set @variables.result = @inputs.station_name   # SILENT FAILURE

# CORRECT
run @actions.get_station_status
    with station_name = @variables.input_station
    set @variables.result = @outputs.station_name
```

---

## 10. Interoperability Protocols: MCP and A2A

### 10.1 MCP — "The USB-C for AI"

The Model Context Protocol is a **standardized interface for AI agents to discover and invoke capabilities** across the broader AI tooling ecosystem.

| Role | Description |
|---|---|
| **MCP Client** | The agent or system consuming tools, prompts, and resources |
| **MCP Server** | The host exposing tools, prompts, and resources to clients |

**MCP Asset Categories:**

| Asset Type | Definition |
|---|---|
| **Tools** | Executable functions; allowlisted tools become available to the agent's LLM |
| **Prompts** | Pre-defined templates for LLM interaction |
| **Resources** | Static or dynamic data sources (databases, APIs, knowledge bases) |

#### MCP CLI Workflow

> **Preview Status:** `sf agent mcp` commands are in developer preview. Known bugs affect `--label` and `--server-url` persistence. Verify output carefully after every `create`.

**Step 1: Register**

```bash
sf agent mcp create \
    --name "my_internal_tools_server" \
    --server-url "https://mcp.internal.company.com/sse" \
    --auth-type oauth \
    --json
# Immediately verify -- --server-url may not persist in some environments
```

**Step 2: Fetch advertised assets (from live server)**

```bash
sf agent mcp fetch \
    --mcp-server-name "my_internal_tools_server" \
    --json
# Read-only -- does not grant access to anything
```

**Step 3: Allowlist assets (full replacement — not additive)**

```bash
sf agent mcp asset replace \
    --mcp-server-name "my_internal_tools_server" \
    --json
# Always include ALL desired assets -- partial payload silently removes the rest
```

**Step 4: Verify saved catalog**

```bash
sf agent mcp list --json

# View assets saved in the Salesforce catalog
sf agent mcp asset list --mcp-server-id <SERVER_ID> --json
```

**Mental model for fetch vs. asset list:**

| Command | What It Reads | When to Use |
|---|---|---|
| `sf agent mcp fetch` | The **live external MCP server** | Discovering what is available before allowlisting |
| `sf agent mcp asset list` | The **Salesforce catalog** — what is currently allowlisted | Verifying what your agents can actually access |

#### Known MCP Preview Issues

| Issue | Impact | Workaround |
|---|---|---|
| `--label` flag does not persist | Server registered without a display label | Add the label manually via UI after CLI registration |
| `--server-url` flag does not persist in some environments | Server endpoint missing after creation | Verify returned JSON immediately; re-register if URL is absent |
| `asset replace` is not additive | Previous allowlist wiped on each call | Always fetch current list first; include all desired assets in the payload |

#### Security Guidance for MCP

- Treat `sf agent mcp asset replace` with the same scrutiny as a permission set assignment.
- Store MCP server OAuth secrets in Named Credentials, not environment variables.
- Review `fetch` output as a security artifact before running `asset replace`.
- Use `sf agent mcp asset list --mcp-server-id <ID>` regularly to audit active agent access.

### 10.2 A2A — Agent-to-Agent Protocol

A2A is an open interoperability standard enabling Agentforce agents to communicate with agents from any vendor that implements the protocol.

**Step 1: Discovery — Agent Cards**

Each A2A-capable agent publishes an Agent Card: a JSON document advertising its capabilities, authentication requirements, and A2A endpoint.

**Step 2: Task Delegation — Messages and Parts**

Tasks are requested via HTTP/JSON-RPC 2.0. Each request is structured as a Message containing Parts — typed parameters carrying the task's input.

**Step 3: Execution and Response — Artifacts**

The receiving agent processes the task and returns Artifacts: structured outputs representing the result of the work.

**Step 4: Updates — Streaming via SSE**

Real-time status and progress stream back via Server-Sent Events (SSE) or Push Notifications. Critical for long-running tasks.

```
[Orchestrator receives]
event: task_update
data: {"status": "in_progress", "progress": 0.6, "message": "Bureau pull in progress"}

event: task_complete
data: {"status": "completed", "artifact": {"credit_score": 742, "risk_tier": "A"}}
```

#### MCP vs. A2A: Knowing Which Protocol to Use

| Dimension | MCP | A2A |
|---|---|---|
| **What it connects** | Agent to Tool/Resource/Prompt | Agent to Agent |
| **State management** | Stateless tool calls | Stateful task sessions with SSE updates |
| **Autonomy of receiver** | Function execution only | Agent reasons, plans, and executes independently |
| **When to use** | Agent needs a specific capability | Agent needs another agent to handle a full domain |

The practical test: if the remote system is a **function** (takes inputs, returns outputs, no independent reasoning), use MCP. If the remote system is an **agent** (interprets intent, plans execution, manages its own state), use A2A.

#### MuleSoft Agent Fabric: The 3P Broker Registry

For third-party integrations, MuleSoft Agent Fabric acts as the broker registry — the discovery and routing layer for external agents (AWS Q, Bedrock, Azure AI Foundry, etc.) without custom point-to-point integrations.

---

## 11. Common Failure Modes

### 11.1 Platform and Compiler Failures

| Failure | Cause | Fix |
|---|---|---|
| **Empty reasoning block** | Subagent has no instructions | Every subagent requires non-empty reasoning instructions. Commit blocker. |
| **Schema validation error** | `system.instructions` names a capability with no corresponding subagent | Every named capability must map to an actual subagent. |
| **Unresolvable action source** | Managed package namespace not installed in target org | Run `sf agent discover` against the deployment org before committing. |
| **`@utils.transition` rule violation** | Properties like `label:`, `require_user_confirmation:`, or `inputs:` on a utility action | Only `description:` and `available` are valid on utility actions. |
| **`developer_name` mismatch** | Config name does not match `aiAuthoringBundles/` directory name | Exact case-sensitive match required. |
| **`before_reasoning` in HyperClassifier router** | `before_reasoning` deployed at `start_agent` level while HyperClassifier is the assigned model | Remove the lifecycle hook or add `model_config: model: "model://sfdc_ai__DefaultGPT41"` to override. |
| **`@utils.transition` in `after_reasoning`** | Using LLM tool syntax in a directive block | Replace with bare `transition to @subagent.X` syntax. |
| **MCP `asset replace` wipes allowlist** | Replacement payload omits previously allowlisted assets | Always run `sf agent mcp asset list` before replacing; include all desired assets. |
| **MCP server URL not persisted** | Known preview bug with the `--server-url` flag | Verify returned JSON immediately; re-register if URL is absent. |

### 11.2 Runtime and State Failures

**Aborted Lifecycle (`after_reasoning`):**
Mid-turn transitions abort `after_reasoning`. State cleanup placed there will silently fail. Move critical cleanup to deterministic `run` statements inside `reasoning.instructions` before the transition.

**Mesh Orchestration Loops:**
Non-hierarchical agent graphs where Agent A calls Agent B and Agent B calls Agent A create circular delegation loops. Audit every agent for guaranteed terminal paths.

**Overlapping Subagent Descriptions:**
Non-deterministic routing from the EinsteinHyperClassifier. Fix: write mutually exclusive descriptions.

**Action Loop (Repeated Execution):**
An action with no `available when` gate and no post-action stop condition will be called repeatedly on every reasoning re-resolution. Gate every write action.

**A2A Timeout Failures:**
Cross-system A2A responses must arrive within 15 seconds. Long-running 3P tasks without SSE streaming configured will fail silently. Always implement SSE update handling for A2A delegations with unpredictable latency.

---

## 12. Trust, Security, and Identity

### 12.1 The Einstein Trust Layer

Three built-in system subagents run as platform-level guardrails **before** any custom logic:

| Built-in Subagent | Purpose |
|---|---|
| `Prompt_Injection` | Detects attempts to override agent instructions through user input |
| `Inappropriate_Content` | Screens for content policy violations |
| `Reverse_Engineering` | Detects attempts to expose internal agent logic |

**Safety review severity levels:**

- **BLOCK:** Stops the deployment pipeline. Must be resolved before production.
- **WARN:** Flags for human review. Does not stop deployment.
- **INFO:** Best-practice recommendations.

### 12.2 Identity Propagation

| Scope | Identity Model | Failure Mode |
|---|---|---|
| SOMA | Uniform session user across all agents in same org | None — single identity context |
| MOMA | Email-based resolver maps user across orgs; no re-authentication | Fallback to Guest User if email resolution fails |
| 3P | Session ID + JWT; user identity not automatically propagated | 3P agent executes in its own auth context |

> **No agent may act outside its trust boundary or elevate privileges beyond those of the initiating user.** This is an architectural guarantee, not a configurable rule.

---

## 13. Governance, Observability, and Quality Assurance

### 13.1 The Seven-Stage Agent Lifecycle

| Stage | Capability | Key Action |
|---|---|---|
| **Discover** | AF Studio / Asset Library | Browse and evaluate available agents |
| **Register** | AF Registry + `sf agent mcp create` | Integrate 3P agents (A2A) and MCP servers |
| **Build and Orchestrate** | Agentforce Builder | Connect agents, configure routing, map variables |
| **Govern** | AF Gateway | Define and enforce organizational policies |
| **Observe and Test** | Test Center + STDM | Monitor performance, validate functionality, trace failures |
| **Publish** | Agent Exchange | Distribute agents to internal or external marketplaces |
| **Use** | All Channels | Deliver unified end-user experience |

### 13.2 Observability Architecture

The goal is a **single pane of glass** — a unified trace of the entire multi-agent interaction, not just the Superagent's perspective.

- Every subagent trace is persisted as an independent session trace in STDM.
- Discrete handoff entries are recorded in the Primary Agent's trace at every delegation.
- Bidirectional trace lookup: Primary Agent Step to Subagent ID (forward); Subagent Session to Primary Agent ID via `PreviousSessionId` (backward).

```bash
# Read resolved LLM inputs per turn
jq -r '.planTrace.steps[] | select(.type == "LLM_STEP") | .input' \
  .sfdx/agents/MyAgent/sessions/*/traces/*.json

# Check variable state before and after each action
jq -r '.planTrace.steps[] | select(.type == "ACTION_STEP") | \
  {name:.name, pre:.preVars, post:.postVars}' \
  .sfdx/agents/MyAgent/sessions/*/traces/*.json
```

### 13.3 Automated Testing with Custom Evaluations (LLM-as-Judge)

For multi-agent architectures, manual CLI tracing is necessary but not sufficient. **Custom Evaluations using the LLM-as-Judge pattern** are the production-grade solution.

Custom Evals configure a secondary LLM to automatically review conversation logs and score them against defined quality criteria — without a human reading every trace.

#### Semantic Conflict Detection

The most critical Custom Eval use case for multi-agent architectures. It automatically scans conversation logs for two specific failure patterns:

**Pattern 1: Contradiction Across Agent Boundaries**

In a SOMA or MOMA deployment, different agents may reach logically contradictory conclusions within the same session. Example:

- Agent A (Promotions Agent) grants a 20% loyalty discount.
- Agent B (Billing Agent) — operating later in the same session — processes the invoice without the discount.

The user receives contradictory information. Neither agent made a technical error. Both made correct decisions within their own context. The conflict is **semantic** — it only becomes visible when the two agents' assertions are read together.

**Pattern 2: Endless Reasoning Loops**

Semantic loop detection identifies sessions where agents are cycling — where the conversation shows the same intent being processed repeatedly without forward progress. Diagnostic signals the judge LLM looks for:

- The same slot-fill question asked more than twice without a new value being captured.
- The same action attempted multiple times with the same inputs without a different outcome.
- A user expressing the same intent in progressively more direct language without receiving a resolution.

#### Configuring Custom Evals for SOMA

```
Testing Center > Evaluations > New Evaluation

Evaluation Type: LLM-as-Judge (Custom)
Judge Model:     sfdc_ai__DefaultGPT41
Scope:           Session-level (full conversation log across all subagents)

Criteria examples:
  - "Did the agent resolve the user's stated intent within 4 turns?"
  - "Did any agent make a factual assertion that contradicts an assertion
     made by another agent in the same session?"
  - "Did the agent ask for the same piece of information more than twice?"
  - "Was the user offered a discount or exception? If yes, was it honored
     consistently throughout the rest of the session?"

Trigger: Post-session, on all production sessions (sample rate configurable)
Alert:   STDM record flagged; routed to QA queue for human review
```

> For MOMA deployments specifically — where agents operate across org boundaries with capped context (10 messages) — the risk of semantic conflicts is higher because agents have less context to reason against. **Custom Evals are not optional in MOMA production deployments; they are a foundational quality gate.**

### 13.4 Streaming Controls

**Default behavior:** Token streaming is **enabled by default** in Agentforce. The agent begins streaming response tokens to the client as soon as the LLM starts generating them.

**Disabling streaming:**

```agentscript
system:
    instructions: "You are an AI service assistant."
    messages:
        welcome: "Hi, how can I help you today?"
        error:   "Something went wrong."
    additional_parameter__disable_streaming: True
```

**When to disable streaming:**

| Scenario | Rationale |
|---|---|
| **Structured output rendering** | Some UI components cannot render correctly if markdown or JSON is streamed incrementally. |
| **Compliance-gated response review** | Some workflows require a compliance check on the full response before it is displayed. |
| **Latency-insensitive batch workflows** | Background processing agents where perceived latency is irrelevant. |

> **Bottom line:** Only disable streaming when a specific, named rendering or compliance requirement demands it. Never disable it for general simplicity or as a debugging convenience in production.

### 13.5 Retry Policy

| Failure Type | Retry? | Rationale |
|---|---|---|
| Transient model/platform failure | Yes (2 retries) | Service may recover |
| Integration failure | Yes (2 retries) | External service may recover |
| No topic matched | No | Same input produces same routing failure |
| Auth/permission failure | No | Retrying won't grant access |
| Input too long | No | Same input will fail the size limit again |
| Transfer limit reached | No | Retrying hits the same limit |

### 13.6 "No Results" vs. "Failure" Disambiguation

Users must never receive a generic error message when the agent simply could not find a matching record. Two fundamentally different outcomes require two fundamentally different user messages.

| Outcome | What Happened | Required Message |
|---|---|---|
| **System Failure** | Timeout, platform error, action threw an exception | Acknowledge the system problem. Give the user a concrete recovery path. Never claim "no results" when the system actually failed to run. |
| **No Results** | The action executed successfully but returned an empty result set | Acknowledge that the search completed successfully. Confirm the parameters searched. Offer next steps. Never say "something went wrong" when nothing went wrong. |

**Implementation pattern — explicit disambiguation:**

```agentscript
reasoning:
    instructions: ->
        if @variables.action_status == "error":
            | I'm sorry, I encountered a technical issue retrieving that information.
              Please try again in a moment, or contact our support team at
              support@company.com if the problem continues.

        if @variables.action_status == "success"
                and @variables.result_count == 0:
            | I searched our records but couldn't find an order matching
              "{!@variables.order_id}". Please double-check the order number
              and try again, or I can help you search by a different method.

        if @variables.action_status == "success"
                and @variables.result_count > 0:
            | I found your order. Here are the details: {!@variables.order_summary}.
```

This three-way branch — error, success-no-results, success-with-results — should be present in every subagent that calls an external data source.

---

## 14. Production Heuristics and Design Principles

### 14.1 The Agentic Maturity Roadmap

```
Level 1: Agent Script Mastery
    Deterministic logic (->) for trust gates and irreversible actions
    LLM reasoning (|) for conversational handling
    apex://, flow://, prompt:// action targets
    Variable scope discipline

Level 2: Subagent Segmentation
    Apply three triggers: overload, divergence, modularity
    Mutually exclusive descriptions
    available when as security primitive
    Understand HyperClassifier constraints at start_agent level

Level 3: Model Stratification
    Set agent-level model_config as a sensible baseline
    Override at subagent level only where reasoning complexity justifies it
    Use sfdc_ai__ API names; test selections in separate agent versions

Level 4: SOMA Orchestration
    Superagent as single entry point
    Bidirectional variable sync
    Handoff vs. Supervised mode selection
    Evaluate Data Cloud Zero-Copy before MOMA
    Streaming enabled by default; disable only with explicit justification

Level 5: MOMA and 3P
    Cross-org trust boundaries and identity propagation
    A2A protocol for agent delegation
    MCP for tool ecosystem integration
    MuleSoft Agent Fabric for 3P broker registry

Level 6: Full Ecosystem Integration
    Multi-protocol architectures (MCP + A2A + SOMA/MOMA)
    Custom Evals (LLM-as-Judge) for semantic conflict detection
    No Results vs. Failure disambiguation in every data-sourcing subagent
    Observability at scale (STDM)
    Independent SDLC per agent domain
    Governance and compliance automation
```

### 14.2 Pre-Deployment Checklist

**Syntax and Compiler:**

- [ ] Every subagent has non-empty `reasoning.instructions`
- [ ] No `@utils.transition` carries properties beyond `description:` and `available when`
- [ ] All `apex://` and `flow://` targets resolve in the deployment org
- [ ] Boolean literals are `True`/`False` (capitalized)
- [ ] `{!@variables.X}` syntax used in all `|` pipe text
- [ ] `developer_name` matches `aiAuthoringBundles/` directory name exactly

**HyperClassifier and Model:**

- [ ] No `before_reasoning` or `after_reasoning` at `start_agent` level unless `model_config:` overrides the HyperClassifier
- [ ] Router uses only `@utils.transition` actions while HyperClassifier is assigned
- [ ] `model_config:` overrides use valid `sfdc_ai__` API names
- [ ] Model selections tested in a separate agent version before promoting to production
- [ ] Agent-level `model_config` set as baseline; subagent overrides applied only where justified

**Streaming:**

- [ ] `additional_parameter__disable_streaming` is `False` or absent unless a specific rendering or compliance requirement mandates batch mode
- [ ] If streaming is disabled, perceived latency impact documented and accepted by stakeholders

**State and Routing:**

- [ ] All mutable variables have explicit default values
- [ ] All post-action checks are at the TOP of `reasoning.instructions`
- [ ] Subagent descriptions are semantically mutually exclusive
- [ ] No circular transitions in the agent graph (A to B to A)
- [ ] Every reasoning branch has a terminal path (user response or `@utils.escalate`)
- [ ] `after_reasoning` transitions use bare `transition to @subagent.X` — never `@utils.transition to`
- [ ] Critical state cleanup is NOT exclusively in `after_reasoning`

**UX and Disambiguation:**

- [ ] Every subagent that calls an external data source has explicit three-way branching: error, success-no-results, success-with-results
- [ ] Error messages include a concrete user recovery path (retry, contact support, alternative channel)
- [ ] "No results" messages confirm what was searched and offer next steps
- [ ] No subagent conflates a system failure with an empty result set

**Data Boundary:**

- [ ] Data Cloud Zero-Copy Federation evaluated before choosing MOMA
- [ ] MOMA chosen only when agent execution boundary (not just data access) requires org separation

**Testing and Quality:**

- [ ] Custom Evals (LLM-as-Judge) configured in Testing Center for production sessions
- [ ] Semantic Conflict Detection eval active for any SOMA/MOMA deployment with multiple data-sourcing agents
- [ ] Disambiguation accuracy included as a Custom Eval criterion
- [ ] Endless reasoning loop detection included as a Custom Eval criterion

**MCP and A2A:**

- [ ] MCP server registration verified via `sf agent mcp list` after `create`
- [ ] Asset allowlist verified via `sf agent mcp asset list --mcp-server-id <ID>`
- [ ] `asset replace` payload includes all desired assets (non-additive operation)
- [ ] OAuth secrets stored in Named Credentials, not environment variables
- [ ] A2A delegations with unpredictable latency have SSE update handling configured
- [ ] 3P agent round-trip latency tested against the 15-second hard limit

**Security and Identity:**

- [ ] Authorization gates use `->` deterministic logic, not `|` natural language instructions
- [ ] `available when` guards on all sensitive actions
- [ ] MOMA identity fallback (Guest User) is explicitly planned for

---

## Appendix A: Key Term Glossary

| Term | Definition |
|---|---|
| **Superagent** | The customer-facing orchestrator agent. Users interact only with this agent. |
| **Subagent** | A specialist domain agent operating behind the scenes with scoped skills, data access, and actions. |
| **SOMA** | Single-Org Multi-Agent. All agents in one Salesforce org. |
| **MOMA** | Multi-Org Multi-Agent. Primary Agent in one org delegates to Secondary Agents in separate trusted orgs. |
| **A2A** | Agent-to-Agent protocol. Open interoperability standard for cross-system agent communication. |
| **MCP** | Model Context Protocol. Standardized interface for agents to discover and invoke tools, prompts, and resources. |
| **MCP Client** | The agent or system consuming MCP-advertised capabilities. |
| **MCP Server** | The host exposing tools, prompts, and resources to MCP clients. |
| **Agent Card** | JSON document advertising an agent's capabilities, authentication, and A2A endpoint. |
| **Artifact (A2A)** | Structured output returned by a receiving agent after completing a delegated task. |
| **SSE** | Server-Sent Events. Streaming mechanism for real-time A2A task status updates. |
| **MuleSoft Agent Fabric** | Broker registry for 3P agent discovery, routing, and policy enforcement. |
| **EinsteinHyperClassifier** | Salesforce-owned routing model. Only supports `@utils.transition`. Prohibits `before_reasoning`/`after_reasoning`. Faster and more accurate for classification than general LLMs. |
| **`model_config:`** | Block that overrides the default model at org, agent, or subagent level. Uses Salesforce-internal `sfdc_ai__` API names in `"model://..."` URI format. Subagent-level wins over agent-level; agent-level wins over org-level. |
| **`additional_parameter__disable_streaming`** | Boolean flag in the `system:` block that controls whether token streaming is active. Default is streaming-on. |
| **Custom Evals (LLM-as-Judge)** | Automated QA mechanism using a secondary LLM to score conversation logs against defined quality criteria. Configured in the Testing Center. |
| **Semantic Conflict Detection** | Custom Eval pattern that scans full session logs for contradictory assertions made by different agents in the same conversation. |
| **Data Cloud Zero-Copy** | Federation mechanism allowing cross-org data access without data movement. Evaluate before MOMA. |
| **Allowlist** | The set of MCP assets (tools, prompts, resources) explicitly permitted for agent use. Managed via `sf agent mcp asset replace`. |
| **AEA** | Agentforce Employee Agent. Internal, logged-in user context. |
| **ASA** | Agentforce Service Agent. Customer-facing, deployed via messaging channels. |
| **GDoT** | Global Directory of Tenants. Stores org trust boundary mappings for MOMA. |
| **DC1** | Salesforce data center trust boundary governing which orgs can share agents in MOMA. |
| **STDM** | Session Trace Data Model. Data Cloud schema for persisting and querying agent session traces. |
| **Trust Layer** | Platform-level safety guardrails (prompt injection, inappropriate content, reverse engineering) that run before any custom agent logic. |
| **Handoff Mode** | Subagent streams response directly to user; Superagent reclaims control after the turn. |
| **Supervised Mode** | Superagent mediates all responses; subagent output feeds Superagent's synthesis step. |
| **`available when`** | Guard condition that hides an action entirely from the LLM's tool list. First-class security primitive. |
| **Slot-fill** | Using `...` token to signal the reasoning engine to extract a value from conversation via `@utils.setVariables`. |

---

## Appendix B: Protocol and Model Reference

**Protocol Comparison:**

| Dimension | MCP | A2A | Direct Subagent (`@subagent`) |
|---|---|---|---|
| **Cross-org** | Yes | Yes | No |
| **Cross-vendor** | Yes | Yes | No |
| **State management** | Stateless tool calls | Stateful task sessions | Shared variable scope |
| **Autonomy of target** | Function execution only | Agent reasons independently | Shared lifecycle |
| **Discovery** | `sf agent mcp fetch` | Agent Card (JSON) | Static subagent name |
| **Auth model** | Named Credentials + OAuth | JWT, OAuth, Client Credentials | Inherited from Superagent |
| **Streaming** | No | SSE / Push Notifications | Not applicable |
| **Best for** | Tools, APIs, knowledge sources | Full domain delegation | Internal task segmentation |

**Model Assignment Reference:**

> All model names below are Salesforce-internal identifiers. They do not correspond 1:1 to public vendor release names.

| Subagent Type | Recommended Model (Salesforce Name) | `sfdc_ai__` API Name |
|---|---|---|
| Router (HyperClassifier default) | EinsteinHyperClassifier | `EinsteinHyperClassifier` |
| Router (standard LLM override) | GPT 4.1 | `sfdc_ai__DefaultGPT41` |
| Slot-fill / Confirmation | Claude Haiku 4.5 | `sfdc_ai__DefaultBedrockAnthropicClaude45Haiku` |
| Fast conversational handling | Gemini 3.5 Flash | `sfdc_ai__DefaultVertexAIGemini35Flash` |
| Complex reasoning (agent baseline) | GPT 4.1 | `sfdc_ai__DefaultGPT41` |

**`model_config` Precedence:**

```
Org-level (Setup)
    overridden by
Agent-level model_config
    overridden by
Subagent-level model_config  <-- most specific; always wins
```

**Streaming Reference:**

| Flag | Default | Effect |
|---|---|---|
| `additional_parameter__disable_streaming: False` (or absent) | Default | Token streaming active; lowest perceived latency |
| `additional_parameter__disable_streaming: True` | Must be set explicitly | Batch mode; complete response assembled before display |
