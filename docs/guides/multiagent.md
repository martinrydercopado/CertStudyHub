# Multi-Agent Architecture in Agentforce
## Study Guide

---

## Section 1: The Agentic Mindset and Mental Model

**Exam Weight: Foundational — tested throughout all sections**

### Objective 1.1: Understand the shift from monolithic bot architecture to distributed agentic systems

#### Topics

---

**Topic: What distinguishes a distributed agentic system from a legacy decision-tree bot**

A legacy monolithic bot operates on a rigid, linear series of pre-scripted if-then statements. Every possible path must be explicitly authored, and any deviation from the scripted flow results in failure. A distributed agentic system replaces this with a reasoning model that classifies intent probabilistically from conversational context, manages dynamic state across turns and agent boundaries, and enforces safety at the architecture level rather than through authored guardrails. The agent is inherently multi-purpose — it orchestrates intent dynamically rather than following a lookup table.

---

**Topic: The three foundational assumptions of the Agentforce agentic mindset**

Salesforce best practices define three assumptions that underpin every agentic design decision:

1. **Intent classification is probabilistic, not programmatic.** The reasoning model selects the correct domain based on conversational context. There is no deterministic lookup table mapping input to outcome.
2. **State is dynamic, not pre-scripted.** Variables evolve across turns, across subagents, and across agent boundaries throughout the session.
3. **Safety is enforced at the architecture level.** Security gates, authorization checks, and trust boundaries are implemented as runtime-enforced deterministic constructs — not as natural language instructions that rely on the model to comply.

---

**Topic: The finite state machine model — how a subagent works at runtime**

Each subagent in Agentforce functions as an independent finite state machine. System intelligence emerges from the interaction of three elements working together:

- **Variables:** The agent's working memory. Values persist across turns and across subagent transitions.
- **Instructions:** The rules that govern reasoning within a single turn. Instructions are re-evaluated after every action execution, not just at the start of the turn.
- **Topics (Subagents):** Bounded domains of expertise. Each subagent owns a specific set of behaviors and has defined scope for what it handles.

The practical consequence of this model is that you can predict and reason about agent behavior by examining state transitions across these three elements rather than trying to follow a single linear execution path.

---

### Objective 1.2: Understand the variable system taxonomy and its implications for multi-agent design

#### Topics

---

**Topic: The four variable types and their mutability rules**

Salesforce documentation defines four distinct variable types, each with different scope, mutability, and failure characteristics:

| Type | Mutability | How Populated | Failure Risk |
|---|---|---|---|
| **Linked** | Read-only | External context injected at session start | Cannot be set by the agent; silent failure if treated as mutable |
| **Mutable** | Read-write | Set by the agent during the session | Must be initialized with a default value or guards fail silently |
| **Slot-fill** | Write-once per turn | LLM extracts value from natural speech via `...` token | Value only available within the current turn's slot-fill context |
| **System** | Read-only | Predefined runtime context (e.g., user input) | Cannot be overridden |

Understanding the distinction between these types is a prerequisite for multi-agent design because cross-subagent state passing depends on correct variable type selection.

---

**Topic: Why uninitialized mutable variables are a production risk**

Best practices require that every mutable variable be initialized with an explicit default value in the `variables:` block. An uninitialized mutable variable returns a null-like default at runtime. This causes `available when` guards that evaluate that variable to silently fail — the condition evaluates incorrectly, and actions that should be hidden are exposed, or actions that should be available are hidden. This class of failure produces no compile-time error, making it particularly dangerous in production.

Correct pattern:
```
variables:
    is_verified: mutable boolean = False
    order_id:    mutable string  = ""
```

Incorrect and dangerous pattern:
```
variables:
    is_verified: mutable boolean   # no default — dangerous
```

---

### Objective 1.3: Understand the core execution order guarantee

#### Topics

---

**Topic: The deterministic-before-LLM execution contract**

The single most architecturally significant principle in Agentforce agent design is the execution order guarantee: deterministic logic executes before the LLM reasoning layer engages. Always. This is a runtime contract, not a convention or suggestion.

The practical consequence is that any security gate, trust check, or guard against irreversible action must be written in deterministic syntax (`->`), not as natural language instructions (`|`). Writing a guard in natural language asks the LLM to comply. Writing it in deterministic syntax enforces compliance at the runtime level, regardless of what the user says.

---

## Section 2: Agent Script Syntax and the Deterministic-Reasoning Divide

**Exam Weight: High — syntax errors and misuse are a primary source of production failures**

### Objective 2.1: Distinguish between the two instruction operators and their processing contexts

#### Topics

---

**Topic: The `->` (logic) operator vs. the `|` (reasoning) operator**

Agent Script uses two operators in the `reasoning.instructions` block that are processed by entirely different systems:

| Operator | Name | What It Does | Who Processes It |
|---|---|---|---|
| `->` | Logic / Procedural | Executes if/else branches, `run` actions, `set` assignments, `transition` calls | The Agent Script runtime — deterministically |
| `\|` | Reasoning / Declarative | Assembles text that forms the prompt sent to the LLM | The LLM model |

The LLM never sees raw `->` instructions. By the time the LLM receives its prompt, all conditionals have already been resolved and all variable values have already been injected by the runtime. The LLM sees only the final assembled prompt text from the `|` lines that matched the current state.

---

**Topic: How variable values are injected into LLM-facing prompt text**

Within `|` pipe text (LLM-facing instructions), variable values are referenced using the `{!@variables.X}` syntax. This syntax signals the runtime to inject the current value of the variable before passing the text to the LLM. Using `@variables.X` directly in pipe text without the `{!...}` wrapper is a syntax error that causes silent failure — the variable name is passed as a literal string rather than its value.

Correct:
```
| Your order {!@variables.order_id} has been updated.
```

Incorrect (silent failure):
```
| Your order @variables.order_id has been updated.
```

---

**Topic: The `instructions: ->` block structure and conditional branching**

When `reasoning.instructions:` is followed by `->`, the entire block is treated as deterministic logic that the runtime processes before constructing the LLM prompt. Conditional branches using `if` determine which `|` text lines are included in the assembled prompt. Only the lines from matching branches reach the LLM — branches that do not match are discarded entirely before the prompt is assembled.

```
reasoning:
    instructions: ->
        if @variables.is_verified == True:
            | Your account balance is {!@variables.account_balance}.

        if @variables.is_verified == False:
            | I need to verify your identity before sharing account details.
```

---

### Objective 2.2: Master the instruction surface lifecycle — five distinct surfaces with distinct behaviors

#### Topics

---

**Topic: The five instruction surfaces and when each fires**

Salesforce documentation defines five distinct instruction surfaces, each with a specific runtime moment and scope behavior:

| Surface | Fires When | Who Can Use It | Scope Behavior |
|---|---|---|---|
| `system.instructions` (global) | Before every LLM call, across all subagents | LLM-facing | Durable persona, safety rules, global scope definitions |
| `system.instructions` (subagent-level) | Only within the owning subagent | LLM-facing | Completely **replaces** the global block — does not merge with it |
| `before_reasoning` | Once per turn, before any LLM processing | Runtime only — pure `->` logic | Pre-condition checks, mandatory data loads, auth gates |
| `reasoning.instructions` | Rebuilt from scratch after every action call in the reasoning loop | Both `->` and `\|` | Current turn's objective, state injection, action guidance |
| `after_reasoning` | Once, after the reasoning loop produces a user-facing response | Runtime only — pure `->` logic | State cleanup, post-response transitions |

Understanding when each surface fires is critical for placing logic in the correct location. Logic placed on the wrong surface either does not fire at the expected time or fires in the wrong context.

---

**Topic: The `before_reasoning` block — mandatory data loads and auth gates**

The `before_reasoning` block executes outside the LLM reasoning loop. The LLM has no awareness of it. It fires once per turn before any LLM processing begins, making it the correct location for:

- Mandatory data pre-loads that must be available before the LLM reasons
- Authorization gate checks that must run before any domain logic executes
- Routing decisions based on current variable state

Because `before_reasoning` is pure `->` logic, it cannot contain `|` pipe text. It also cannot use `@utils.transition` — only the bare `transition to @subagent.X` syntax is valid here.

---

**Topic: The `after_reasoning` block and the mid-turn transition trap**

The `after_reasoning` block fires once after the reasoning loop produces a response. It is a common location for state cleanup and post-response routing. However, a critical failure mode exists: if the LLM calls a `@utils.transition` action mid-reasoning (before the loop completes), the `after_reasoning` block is completely aborted for that turn. Any logic placed exclusively in `after_reasoning` will silently fail in sessions where this occurs.

Best practice: critical state cleanup and logging should be placed as deterministic `run` statements inside `reasoning.instructions`, not exclusively in `after_reasoning`. Only use `after_reasoning` for logic that is acceptable to lose if a mid-turn transition occurs.

Additionally, transitions within `after_reasoning` must use bare `transition to @subagent.X` syntax. Using `@utils.transition to` in an `after_reasoning` block causes a compile error.

---

**Topic: `reasoning.instructions` re-resolution after every action**

A key runtime behavior: `reasoning.instructions` is rebuilt from scratch after every action execution within the reasoning loop. This means post-action checks that are placed at the **top** of the `reasoning.instructions` block will fire immediately when action outputs update variable values. Checks placed at the bottom of the block may not be evaluated against the freshest state in time.

Best practice: always place post-action conditional checks at the top of the `reasoning.instructions` block so they fire immediately on re-resolution when the relevant variable changes.

---

### Objective 2.3: Correctly apply action invocation patterns

#### Topics

---

**Topic: Deterministic action invocation vs. LLM-driven action invocation**

Two action invocation patterns exist and are not interchangeable:

| Pattern | Syntax | Who Decides to Execute | When to Use |
|---|---|---|---|
| **Deterministic** | `run @actions.X` inside a `->` block | The runtime — unconditionally when the `->` line is reached | Must-execute logic: mandatory data loads, authorization gates |
| **LLM-Driven** | Listed in the `reasoning: actions:` block | The LLM selects from its available tool list contextually | Conversational, optional tool selection based on user intent |

An action must be explicitly wired to one of these two patterns. Referencing an action name in `|` pipe text without listing it in the `actions:` block (for LLM-driven) or calling it with `run` (for deterministic) results in silent failure — the action is never invoked.

---

**Topic: The `available when` guard — hiding actions from the LLM**

The `available when` condition on an action definition is a first-class security primitive, not a soft hint. When the condition is not met, the action is completely absent from the LLM's tool list — not disabled or grayed out. The LLM cannot reference or call it because it does not exist in the LLM's available context for that turn.

This distinction is architecturally important: it means an attacker cannot prompt-inject their way into calling a hidden action. The guard is enforced at the platform level, not by asking the LLM to comply with an instruction.

---

**Topic: The `@utils.transition` syntax rules — where it is valid and where it is not**

`@utils.transition to @subagent.X` is an LLM-facing tool. It is valid only in the `reasoning: actions:` block — places where the LLM selects it. It must never appear in `before_reasoning`, `after_reasoning`, or inside `->` logic blocks. In those contexts, the correct deterministic syntax is `transition to @subagent.X` (bare syntax, no `@utils.` prefix).

| Syntax | Valid Locations | Executed By |
|---|---|---|
| `transition to @subagent.X` | `before_reasoning`, `after_reasoning`, `->` blocks | The Agent Script runtime |
| `@utils.transition to @subagent.X` | `reasoning: actions:` block only | The LLM selects it as a tool |

Using `@utils.transition` in `after_reasoning` is a compile error that blocks deployment.

---

### Objective 2.4: Understand variable scope lifecycle rules

#### Topics

---

**Topic: The three scope contexts — `@inputs`, `@outputs`, and `@variables`**

Three reference contexts exist for action data, and each is only valid in a specific scope:

| Reference | Valid Scope | Common Mistake |
|---|---|---|
| `@inputs.X` | Only during the `with` clause of a specific action invocation | Using it in a `set` statement after the action completes — returns null |
| `@outputs.X` | Only in `set` or `if` statements immediately after the producing action | Referencing it two blocks later — returns null |
| `@variables.X` | Anywhere after the variable has been set by a previous action | Referencing it before the producing action has run — returns the default value |

The most common mistake is attempting to capture `@inputs.X` in a `set` statement, which silently returns null because `@inputs` is out of scope outside the `with` clause.

---

## Section 3: Subagent Boundaries and Segmentation

**Exam Weight: High — architectural decision-making is a core competency**

### Objective 3.1: Apply the minimalist default posture for subagent design

#### Topics

---

**Topic: Start minimal — the default single-domain agentic posture**

Best practices establish a clear default: start with a single-domain agentic agent. Add subagent complexity only when justified by a concrete, named requirement. Every subagent boundary introduces routing overhead, variable passing complexity, and a new class of failure modes. Complexity added without a concrete justification creates cost without benefit.

The correct design sequence is: single subagent first, then evaluate whether a specific trigger mandates segmentation. Not: assume segmentation is better and simplify later.

---

**Topic: The three justified triggers for subagent segmentation**

When a single subagent is no longer appropriate, best practices recognize exactly three triggers that justify introducing a subagent boundary:

**Trigger 1 — Instruction Overload:** When instruction length has degraded reasoning fidelity to the point where the agent consistently misses rule conditions or conflates domain-specific details. The trigger is observed quality degradation, not instruction length alone.

**Trigger 2 — Functional Divergence:** When two domains in the same subagent require different security guardrails, data sources, or permission levels. The LLM incurs context-switching overhead when asked to reason across domains with fundamentally different constraints in a single subagent.

**Trigger 3 — Modularity and Regression Control:** When different teams own different functional areas, or when a given area changes frequently enough that co-location with other domains creates regression risk. Independent update cycles require isolated subagent boundaries.

---

**Topic: Applying segmentation triggers to a real scenario — customer service agent example**

Consider a customer service agent with three capabilities: identity verification, order status, and case management. Applying the three triggers:

- `user_verification` is segmented by Trigger 2: it requires different security guardrails and a different data source than the order domain.
- `order_status` is segmented by Trigger 3: a separate team owns it with an independent change cadence.
- `case_management` is segmented by Trigger 1: its distinct instruction set (case taxonomy rules, escalation logic) would overload the context if mixed with order management.

A key structural principle: every utterance returns to `start_agent`. Subagents do not route directly to each other — control always flows back through the router.

---

### Objective 3.2: Determine when a subagent boundary becomes an agent boundary

#### Topics

---

**Topic: Three thresholds that require a full agent boundary, not just a subagent boundary**

A shared `.agent` file means shared deployment fate. When the following conditions arise, a separate agent is required:

**Boundary 1 — SDLC Independence:** When different development teams require independent release cadences, deployment pipelines, and rollback capabilities. A subagent in a shared `.agent` file is redeployed whenever any part of the agent is redeployed.

**Boundary 2 — Independent External Invocability:** When a domain must be directly callable from external systems — other agents, external APIs, or orchestrators — it requires its own agent identity, its own A2A endpoint, and its own Agent Card.

**Boundary 3 — Regulatory Isolation:** When different domains require different data sovereignty, tenant isolation, or compliance boundaries. These domains must reside in separate agents, and potentially in separate Salesforce orgs using MOMA.

---

**Topic: State transfer mechanics across agent boundaries — handoff vs. round-trip**

When state must cross an agent boundary, two transfer mechanisms exist with different behaviors:

| Mechanism | Transfer Type | What Happens to Caller | When to Use |
|---|---|---|---|
| `@utils.transition` to a connected agent | One-way handoff | Caller context is discarded after the transfer | Terminal transfers where the receiving agent owns the session from that point forward |
| `@subagent.<name>` (within same agent) | Round-trip delegation | Control returns to caller after the subagent completes | Non-terminal delegations where the calling subagent needs to act on the result |

Using a terminal handoff when a round-trip is needed results in lost context and broken state continuity.

---

## Section 4: Multi-Agent Design Patterns

**Exam Weight: High — pattern selection is a common scenario-based question type**

### Objective 4.1: Compare and select from the four multi-agent design patterns

#### Topics

---

**Topic: Pattern 1 — Monolithic Subagent**

All capabilities are handled in a single subagent with no routing between specialized domains.

| Dimension | Assessment |
|---|---|
| Reasoning fidelity | Low — context dilution across mixed domains |
| State management | Simple — no cross-subagent variable passing required |
| SDLC risk | High — any change touches all capabilities simultaneously |
| Appropriate use | Prototypes only. Never in production for complex or mixed-domain logic. |

---

**Topic: Pattern 2 — Single Agent with Intent Classifier (SOMA Light)**

A single Salesforce org hosts one agent with multiple specialized subagents. A router (typically using the EinsteinHyperClassifier) classifies intent and transitions to the appropriate subagent.

| Dimension | Assessment |
|---|---|
| Reasoning fidelity | High — scoped, focused instructions per subagent |
| State management | Medium — variables are shared within the same agent lifecycle |
| SDLC risk | Medium — the entire agent is redeployed when any single subagent changes |
| Appropriate use | One team owns all domains; infrequent updates; a shared org boundary is appropriate |

---

**Topic: Pattern 3 — Orchestrator to Separate Agents (SOMA/MOMA)**

Multiple separate agents with independent identities. An orchestrator agent delegates to specialist agents via agent-to-agent calls. Agents may reside in the same org (SOMA) or separate orgs (MOMA).

| Dimension | Assessment |
|---|---|
| Reasoning fidelity | Maximum — full contextual isolation per agent |
| State management | Complex — explicit variable mapping required across agent boundaries; MOMA caps at 10 messages of context |
| SDLC independence | Maximum — each agent has its own deployment lifecycle |
| Appropriate use | Different teams own each domain; regulatory isolation is required; independent external API exposure is needed |

---

**Topic: Pattern 4 — Hybrid Orchestration**

A combination of Patterns 2 and 3. Some domains are grouped together in the same agent (sharing genuine data affinity), while others are isolated as separate agents (requiring strict independence).

| Dimension | Assessment |
|---|---|
| Reasoning fidelity | High for grouped domains; maximum for isolated specialists |
| Appropriate use | When some domains share genuine data affinity and others require strict isolation or different SDLC governance |

---

**Topic: The pattern selection decision tree**

When selecting a pattern, best practices recommend applying this decision sequence:

1. Does any domain need independent external API exposure or A2A invocability? **Yes → Pattern 3 or 4.**
2. Do different teams own different domains with independent release cadences? **Yes → Pattern 3 or 4.**
3. Do any domains require different permission boundaries? **Yes → Pattern 3 or 4.**
4. Would a single subagent exceed high-fidelity reasoning capacity? **Yes → Pattern 2.**
5. None of the above: **Pattern 1 — single subagent, simplest viable architecture.**

---

## Section 5: Deployment Patterns — SOMA, MOMA, and 3P

**Exam Weight: High — technical constraints and decision criteria are frequently tested**

### Objective 5.1: Apply SOMA architecture and understand its technical limits

#### Topics

---

**Topic: SOMA technical limits and latency profile**

Single-Org Multi-Agent (SOMA) operates within one Salesforce org. Key platform constraints:

- Up to 7-8 subagents wide (a soft limit; the observability dashboard flags at 7)
- Maximum 2 delegation levels deep (Agent A to Agent B; no tertiary Agent C)
- Session duration: 24-48 hours maximum
- Bidirectional variable sync between Superagent and subagents is supported at GA
- Last 20 messages of conversation history are passed on each delegation

SOMA latency profile (P95 estimates):

| Mode | Typical P95 Total Latency |
|---|---|
| Supervised Mode (Superagent synthesizes response) | ~12-20 seconds |
| Handoff Mode (subagent streams directly to user) | ~8-14 seconds |

The synthesis hop in Supervised Mode adds approximately 2-3 seconds compared to Handoff Mode.

---

**Topic: Handoff Mode vs. Supervised Mode — tradeoffs**

| Dimension | Supervised Mode | Handoff Mode |
|---|---|---|
| Who responds to the user | Superagent synthesizes the subagent's output | Subagent streams directly to the user |
| Latency | Higher (synthesis hop adds ~2-3s) | Lower (synthesis hop removed) |
| Multi-intent support | Yes — Superagent can coordinate across multiple subagents | No — single-intent only per turn |
| Best for | Complex sessions requiring Superagent-level coherence | High-volume, latency-sensitive, single-intent interactions |

---

### Objective 5.2: Apply MOMA architecture and know when it is and is not the right choice

#### Topics

---

**Topic: The MOMA-first question — always evaluate Data Cloud Zero-Copy Federation before choosing MOMA**

Multi-Org Multi-Agent (MOMA) is not the default choice for cross-org scenarios. Best practices require evaluating Data Cloud Zero-Copy Federation first. If the external org's data can be federated into the primary org using Data Cloud Zero-Copy, the data boundary concern is solved at the data layer — and a SOMA pattern with full bidirectional variable sync, no 10-message cap, and no JWT complexity can be maintained.

MOMA is the correct choice only when the concern is not just data access but agent execution isolation:

- The secondary org requires write-backs that must execute within its own tenant boundary
- Regulatory requirements mandate that agent logic itself executes within the secondary org's tenancy
- The secondary org is owned by a separate business entity where tenant-level isolation is non-negotiable
- The secondary org team requires independent agent deployment governance, not just independent data access

---

**Topic: MOMA hard architectural constraints**

MOMA carries constraints that do not exist in SOMA and cannot be configured away:

| Constraint | Rule | Reason |
|---|---|---|
| Delegation depth | Strictly one level — Primary to Secondary; no tertiary | Prevents failure cascade and undefined context ownership |
| Context cap | Last 10 messages passed (hard limit, not configurable) | Cross-org payload management |
| Memory model | Pass-by-value, not shared memory | No persistent shared state exists between orgs |
| Trust boundary | All orgs must share the same DC1 boundary | Data sovereignty compliance |
| Org membership | One org can belong to exactly ONE trust boundary | Prevents cross-boundary leakage |
| Agent shareability | Agents are NOT auto-shared across orgs | Security-by-default; admin must explicitly mark as shareable |

---

**Topic: MOMA identity propagation and the Guest User fallback risk**

In MOMA, identity is propagated across orgs via an email-based identity resolver. The logged-in user is mapped to the corresponding user in the secondary org without requiring re-authentication. However, if email resolution fails, the system silently defaults to Guest User — a significant permission downgrade that must be explicitly planned for in agent design.

If a secondary org requires step-up authentication, the login prompt fires in the primary org's interface, not the secondary org's. Architects must account for this when designing user flows that cross org boundaries.

---

### Objective 5.3: Understand third-party (3P) agent interoperability

#### Topics

---

**Topic: 3P interoperability directions, auth mechanisms, and hard limits**

Third-party agent interoperability allows Agentforce to communicate with agents from other vendors via the A2A protocol.

| Direction | Auth Mechanism | Current Status |
|---|---|---|
| Outbound (Agentforce to third-party) | Named Credentials + OAuth; Guest User context only | Pilot |
| Inbound (third-party to Agentforce) | AEA: Web-Server Flow; ASA: Client Credentials Flow | Pilot |

Hard platform limits for 3P interactions:
- A2A payload must conform to the A2A protocol schema
- No parallel tasks per request
- Plain text responses only (rich modalities planned post-Pilot)
- 15-second hard round-trip limit — any delegation with unpredictable latency must implement SSE streaming to avoid timeout failures

---

## Section 6: Routing Architecture and the EinsteinHyperClassifier

**Exam Weight: High — HyperClassifier constraints are a common source of deployment failures**

### Objective 6.1: Understand the routing stack and trust layer

#### Topics

---

**Topic: The four-layer routing stack — execution order**

Every user message passes through four processing layers in sequence:

1. **Einstein Trust Layer** — Three built-in platform guardrails run before any custom logic: `Prompt_Injection`, `Inappropriate_Content`, and `Reverse_Engineering`. A BLOCK at this layer means custom agent logic never executes.
2. **EinsteinHyperClassifier** (when assigned as the router model) — Salesforce-owned routing model optimized for intent classification. Significantly faster and more accurate than general LLMs for this specific task. Routes to subagents via `@utils.transition` only.
3. **Subagent Topic Selection** (standard LLM) — Full `before_reasoning` and `after_reasoning` lifecycle support exists at this level.
4. **Subagent Action Selection** — LLM selects from the available tool list based on the assembled prompt and current context.

---

**Topic: EinsteinHyperClassifier capabilities and hard limitations**

The EinsteinHyperClassifier is the default router model in Service Agent templates. Its advantages are speed and classification accuracy — particularly for specialized classification constraints and negative routing instructions. Its limitations are platform-enforced and cannot be configured away:

- **Cannot** use `before_reasoning` or `after_reasoning` blocks at the `start_agent` level
- **Can only** use `@utils.transition` as a tool — no other action types are supported
- Attempting to deploy a `start_agent` with `before_reasoning` logic while the HyperClassifier is assigned will cause a deployment failure

---

**Topic: The model override trade-off — gaining lifecycle hooks at the cost of routing speed**

When deterministic `before_reasoning` logic is needed at the router level, the solution is to override the HyperClassifier with a standard LLM via `model_config:`. This is done by adding a `model_config:` block inside `start_agent` specifying a standard model such as `sfdc_ai__DefaultGPT41`.

The trade-off is real and explicit:

| Requirement | Recommended Router Model |
|---|---|
| Maximum routing speed and classification accuracy | EinsteinHyperClassifier — no lifecycle hooks available |
| Deterministic `before_reasoning` gate at router level | Standard LLM via `model_config:` — latency and accuracy trade-off accepted |
| Both speed and lifecycle hooks | Use an auth gate subagent pattern: keep HyperClassifier as router; push preconditions into the first-destination subagent's `before_reasoning` |

---

**Topic: Subagent description hygiene — mutually exclusive descriptions prevent non-deterministic routing**

The EinsteinHyperClassifier treats subagent and transition action descriptions as classification boundaries. Overlapping or ambiguous descriptions produce non-deterministic routing — the same user utterance may route to different subagents across sessions. Best practices require that every subagent description be semantically mutually exclusive.

Bad (overlapping descriptions cause routing failures):
```
subagent billing_support: "Handles customer payment and account questions"
subagent account_management: "Handles customer account and payment issues"
```

Good (mutually exclusive):
```
subagent billing_support: "Processes payments, refunds, and invoice disputes"
subagent account_management: "Manages profile updates, password resets, and access permissions"
```

Additionally, using the `go_to_` prefix convention on all transition actions groups transitions visually, signals routing intent to the HyperClassifier, and makes the action list scannable in complex agents.

---

## Section 7: Model Selection and the `model_config` Override

**Exam Weight: Medium — model selection strategy and API name accuracy are testable**

### Objective 7.1: Apply model inheritance and override rules

#### Topics

---

**Topic: The model configuration precedence chain**

The model used for any subagent is determined by a precedence hierarchy — most specific wins:

```
Org-level model (configured in Salesforce Setup)
    overridden by
Agent-level model_config (applies to all subagents in the agent)
    overridden by
Subagent-level model_config (applies only to this specific subagent)
```

A `model_config:` block can be placed at three levels: inside `start_agent`, between the `system:` block and the subagent definitions (agent-level), or inside a specific `subagent` definition. Agent-level configuration is the recommended baseline; subagent-level overrides should be applied only where the reasoning complexity of a specific subagent genuinely justifies a different model.

---

**Topic: Salesforce-internal model API names — use `sfdc_ai__` identifiers in `model://` URIs**

Model names used in `model_config:` blocks must use Salesforce-internal `sfdc_ai__` API identifiers, not the public vendor release names used by Anthropic, Google, or OpenAI. Substituting public model names causes compile errors.

| Model (Common Name) | Salesforce API Name (use in `model://`) | Best For |
|---|---|---|
| EinsteinHyperClassifier | `EinsteinHyperClassifier` | Router classification only |
| GPT 4.1 | `sfdc_ai__DefaultGPT41` | Router override, general-purpose reasoning |
| Claude Haiku 4.5 | `sfdc_ai__DefaultBedrockAnthropicClaude45Haiku` | Slot-fill, lightweight subagents, latency-sensitive tasks |
| Gemini 3.5 Flash | `sfdc_ai__DefaultVertexAIGemini35Flash` | Fast conversational handling |

---

**Topic: Model assignment strategy by subagent type**

Best practices map model selection to subagent responsibility:

| Subagent Type | Recommended Model |
|---|---|
| Router / Classifier | EinsteinHyperClassifier (default in Service templates) |
| Slot-fill Collector | Claude Haiku 4.5 (fast, low latency) |
| Lightweight Conversational | Agent-level default; no subagent override needed |
| Complex Reasoning (multi-step analysis, regulatory compliance) | Heavyweight model via subagent-level `model_config:` override |
| Escalation / Handoff | Claude Haiku 4.5 (brief summary only; speed matters) |

Stratifying models by subagent type reduces P95 latency materially. Using a uniform heavyweight model at every hop adds significant overhead compared to reserving expensive models only for subagents that genuinely require complex reasoning.

---

**Topic: Testing model selections before promoting to production**

Best practice is to test model selections in separate agent versions before promoting to production:

- Version A: Claude Haiku 4.5 at agent level (lightweight baseline)
- Version B: GPT 4.1 at agent level (higher capability baseline)

Session traces across versions are compared to identify where model choice materially affects output quality or latency. The version that best balances quality and latency for the production traffic profile is promoted.

---

## Section 8: State, Memory, and Context Sharing Across Boundaries

**Exam Weight: Medium-High — cross-boundary state management is a critical production concern**

### Objective 8.1: Understand variable sync rules across SOMA, MOMA, and 3P boundaries

#### Topics

---

**Topic: State sharing capabilities by deployment pattern**

Variable and context sharing behavior differs significantly across deployment patterns:

| Scope | SOMA | MOMA | 3P |
|---|---|---|---|
| Mutable variable sync | Bidirectional (changes in subagent reflect in Superagent when control returns) | Pass-by-value at delegation time only | Session ID + last 10 messages only |
| Conversation history passed | Last 20 messages | Last 10 messages (hard cap) | Last 10 messages |
| Shared persistent memory | Not supported — variables only | Not supported | Not supported |

In SOMA, bidirectional sync means changes a subagent makes during its turn are reflected in the Superagent's state when control returns — even in Handoff Mode. This is a significant advantage over MOMA's pass-by-value model.

---

**Topic: Variable mapping validation — the platform blocks broken mappings at design time**

When a mutable variable that is mapped across subagents is renamed or deleted, the platform blocks the save operation at design time. This prevents silent runtime breakage in variable mappings. It is a design-time safety gate, not a runtime recovery mechanism — which means the correct practice is to maintain consistent variable names throughout the agent lifecycle and treat renames as a formal change operation.

---

## Section 9: Interoperability Protocols — MCP and A2A

**Exam Weight: Medium — protocol selection and command syntax are testable**

### Objective 9.1: Understand the Model Context Protocol (MCP)

#### Topics

---

**Topic: MCP — what it is and the three asset categories**

The Model Context Protocol is a standardized interface for AI agents to discover and invoke capabilities across the broader AI tooling ecosystem. It defines a client-server model:

- **MCP Client:** The agent or system consuming tools, prompts, and resources.
- **MCP Server:** The host exposing tools, prompts, and resources to clients.

Three asset categories can be advertised by an MCP server:

| Asset Type | Definition |
|---|---|
| Tools | Executable functions; allowlisted tools become available to the agent's LLM as callable actions |
| Prompts | Pre-defined templates for LLM interaction |
| Resources | Static or dynamic data sources (databases, APIs, knowledge bases) |

---

**Topic: The MCP CLI workflow — four steps with critical caveats**

Registering and configuring an MCP server follows four steps:

**Step 1 — Register:** `sf agent mcp create` registers the server. Due to a known preview bug, `--server-url` may not persist after registration. Always verify the returned JSON immediately and re-register if the URL is absent.

**Step 2 — Fetch:** `sf agent mcp fetch` reads the live external MCP server to discover what assets it advertises. This is a read-only operation — it does not grant access to anything.

**Step 3 — Allowlist:** `sf agent mcp asset replace` writes the allowlist. This operation is a full replacement, not an additive update. Assets omitted from the payload are silently removed from the allowlist. Always fetch the current allowlist first and include all desired assets in the replacement payload.

**Step 4 — Verify:** `sf agent mcp asset list --mcp-server-id <ID>` reads the Salesforce catalog — what is currently allowlisted and accessible to agents. This is different from `mcp fetch`, which reads the live server.

---

**Topic: MCP security practices**

Treating MCP asset allowlisting with the same scrutiny as permission set assignment is a stated best practice. Specific security guidance includes:

- Store MCP server OAuth secrets in Named Credentials — never in environment variables
- Review `fetch` output as a security artifact before running `asset replace`
- Audit active agent access regularly using `sf agent mcp asset list --mcp-server-id <ID>`

---

### Objective 9.2: Understand the Agent-to-Agent (A2A) Protocol

#### Topics

---

**Topic: A2A — the four-step interaction lifecycle**

The Agent-to-Agent protocol is an open interoperability standard enabling Agentforce agents to communicate with agents from any vendor that implements the protocol. The interaction lifecycle has four steps:

**Step 1 — Discovery:** Each A2A-capable agent publishes an Agent Card — a JSON document advertising its capabilities, authentication requirements, and A2A endpoint.

**Step 2 — Task Delegation:** Tasks are requested via HTTP/JSON-RPC 2.0. Each request is structured as a Message containing Parts — typed parameters carrying the task's input.

**Step 3 — Execution and Response:** The receiving agent processes the task and returns Artifacts — structured outputs representing the result of the work.

**Step 4 — Streaming Updates:** Real-time status and progress stream back via Server-Sent Events (SSE) or Push Notifications. SSE configuration is required for any A2A delegation with unpredictable latency to prevent silent timeout failures at the 15-second hard limit.

---

**Topic: MCP vs. A2A — choosing the right protocol**

The practical decision rule: if the remote system is a **function** (takes inputs, returns outputs, no independent reasoning), use MCP. If the remote system is an **agent** (interprets intent, plans its own execution, manages its own state), use A2A.

| Dimension | MCP | A2A |
|---|---|---|
| What it connects | Agent to Tool / Resource / Prompt | Agent to Agent |
| State management | Stateless tool calls | Stateful task sessions with SSE updates |
| Autonomy of receiver | Function execution only | Agent reasons, plans, and executes independently |
| Discovery mechanism | `sf agent mcp fetch` | Agent Card (JSON) |
| Auth model | Named Credentials + OAuth | JWT, OAuth, Client Credentials |
| Best for | Tools, APIs, knowledge sources | Full domain delegation to an independently reasoning agent |

---

**Topic: MuleSoft Agent Fabric — the 3P broker registry**

For third-party integrations, MuleSoft Agent Fabric acts as the broker registry — the discovery and routing layer for external agents (AWS Q, Bedrock, Azure AI Foundry, etc.) without requiring custom point-to-point integrations. It provides a centralized registry for discovering, routing to, and enforcing policy on external agents.

---

## Section 10: Trust, Security, and Identity

**Exam Weight: High — security architecture questions are a consistent focus**

### Objective 10.1: Understand platform-level trust guardrails

#### Topics

---

**Topic: The three built-in platform guardrails in the Einstein Trust Layer**

Three built-in subagents run at the platform level before any custom agent logic executes. They cannot be disabled or bypassed:

| Built-in Subagent | Purpose |
|---|---|
| `Prompt_Injection` | Detects attempts to override agent instructions through user input |
| `Inappropriate_Content` | Screens for content policy violations |
| `Reverse_Engineering` | Detects attempts to expose internal agent logic |

A BLOCK-level finding from any of these three subagents prevents the custom agent from executing for that session. Safety review findings are also classified at three severity levels: BLOCK (stops the deployment pipeline and must be resolved before production), WARN (flags for human review but does not stop deployment), and INFO (best-practice recommendations).

---

**Topic: Deterministic enforcement of authorization gates — why natural language guards are insufficient**

Authorization gates, trust checks, and guards against irreversible actions must be implemented as deterministic `->` logic — not as `|` natural language instructions. Writing a security guard in natural language is asking the LLM to comply with it voluntarily. Writing it in deterministic `->` syntax enforces compliance at the runtime level, where the LLM has no ability to override it regardless of what the user says or what the conversation context implies.

This is the practical application of the core architectural axiom: safety enforced at the architecture level, not by trusting the LLM.

---

### Objective 10.2: Understand identity propagation across deployment patterns

#### Topics

---

**Topic: Identity model by deployment pattern**

| Pattern | Identity Model | Primary Failure Mode |
|---|---|---|
| SOMA | Uniform session user across all agents in the same org | None — single identity context |
| MOMA | Email-based resolver maps user across orgs; no re-authentication required | Fallback to Guest User if email resolution fails — explicit planning required |
| 3P | Session ID + JWT; user identity is not automatically propagated | Third-party agent executes in its own auth context |

---

**Topic: The architectural identity guarantee**

No agent may act outside its trust boundary or elevate privileges beyond those of the initiating user. This is an architectural guarantee enforced by the platform — it is not a configurable rule and cannot be overridden by agent instructions.

---

## Section 11: Governance, Observability, and Quality Assurance

**Exam Weight: Medium — QA patterns and failure disambiguation are increasingly tested**

### Objective 11.1: Understand the seven-stage agent lifecycle

#### Topics

---

**Topic: The seven stages of the Agentforce agent lifecycle**

Salesforce documentation defines a seven-stage lifecycle for agent governance:

| Stage | Primary Tool / Capability | Key Action |
|---|---|---|
| Discover | Agentforce Studio / Asset Library | Browse and evaluate available agents |
| Register | Agentforce Registry + `sf agent mcp create` | Integrate 3P agents and MCP servers |
| Build and Orchestrate | Agentforce Builder | Connect agents, configure routing, map variables |
| Govern | Agentforce Gateway | Define and enforce organizational policies |
| Observe and Test | Testing Center + STDM | Monitor performance, validate functionality, trace failures |
| Publish | Agent Exchange | Distribute agents to internal or external marketplaces |
| Use | All Channels | Deliver unified end-user experience |

---

### Objective 11.2: Apply observability practices — tracing and session diagnostics

#### Topics

---

**Topic: The Session Trace Data Model (STDM) and bidirectional trace lookup**

Every subagent trace is persisted as an independent session trace in STDM. Discrete handoff entries are recorded in the Primary Agent's trace at every delegation. Bidirectional trace lookup is supported:

- Forward: Primary Agent step to Subagent session ID
- Backward: Subagent session to Primary Agent ID via `PreviousSessionId`

This bidirectional capability is essential for diagnosing failures in multi-agent sessions where the root cause may be in a subagent trace, not the primary agent trace.

---

**Topic: Diagnosing failures using session traces — the three key step types**

Session traces stored locally (`.sfdx/agents/`) contain three step types that map to different diagnostic scenarios:

- **LLMStep:** Read the resolved LLM input to see exactly what prompt the model received. Useful for diagnosing incorrect routing, wrong variable injection, or missing context.
- **FunctionStep / ACTION_STEP:** Check `preVars` and `postVars` on action steps to see variable state before and after action execution. Useful for diagnosing action failures, incorrect outputs, or missing variable updates.
- **ReasoningStep:** Trace the reasoning loop to see which tools the LLM selected and in what order. Useful for diagnosing unexpected action calls or missed transitions.

---

### Objective 11.3: Configure and apply Custom Evaluations (LLM-as-Judge) for multi-agent QA

#### Topics

---

**Topic: Custom Evaluations — automated quality assessment using a secondary LLM**

For multi-agent architectures, manual CLI tracing is necessary but not sufficient for production quality assurance. Custom Evaluations use a secondary LLM (configured in the Testing Center) to automatically review conversation logs and score sessions against defined quality criteria without human review of every trace.

Custom Evals are configured with:
- A judge model (typically a capable reasoning model)
- A scope (session-level, covering the full conversation log across all subagents)
- Specific criteria expressed as natural language questions the judge LLM answers about each session

Custom Evals can be configured to trigger post-session on all production sessions (with a configurable sample rate) and route flagged sessions to a QA queue.

---

**Topic: Semantic Conflict Detection — the most critical Custom Eval use case for multi-agent systems**

In SOMA and MOMA deployments, different agents may reach logically contradictory conclusions within the same session. Neither agent makes a technical error — both make correct decisions within their own context. The conflict only becomes visible when the two agents' assertions are read together in the session log.

Example: Agent A (Promotions) grants a 20% loyalty discount. Agent B (Billing) processes the invoice later in the same session without applying the discount. The user receives contradictory information.

Semantic Conflict Detection is a Custom Eval pattern that scans full session logs for this class of failure. For MOMA deployments specifically — where the 10-message context cap increases the risk that agents lack full session context — Custom Evals including semantic conflict detection are not optional; they are a foundational quality gate.

---

**Topic: Endless reasoning loop detection — the second critical Custom Eval pattern**

A session is in an endless reasoning loop when agents cycle without making forward progress. A judge LLM scanning for the following diagnostic signals can identify these sessions automatically:

- The same slot-fill question is asked more than twice without a new value being captured
- The same action is attempted multiple times with the same inputs without a different outcome
- The user expresses the same intent in progressively more direct language without receiving resolution

Endless loop detection should be configured as a Custom Eval criterion in any production multi-agent deployment.

---

### Objective 11.4: Implement the "No Results vs. Failure" disambiguation pattern

#### Topics

---

**Topic: Why conflating system failure with empty results is a UX and trust failure**

Two fundamentally different runtime outcomes require two fundamentally different user messages. Returning a generic error message when the agent simply found no matching records is incorrect — and so is returning a "no results found" message when the system actually failed to execute.

Best practices require that every subagent that calls an external data source implement explicit three-way branching:

| Outcome | What Happened | Required User Message |
|---|---|---|
| System Failure | Timeout, platform error, or action threw an exception | Acknowledge the system problem explicitly. Provide a concrete recovery path (retry, contact support, alternative channel). Never claim "no results" when the system failed. |
| Success — No Results | Action executed successfully but returned an empty result set | Acknowledge that the search completed successfully. Confirm the parameters searched. Offer next steps. Never say "something went wrong" when nothing did. |
| Success — Results Found | Action executed and returned data | Present the data and offer relevant follow-up actions. |

This three-way branch is a required pattern, not optional, in any subagent that sources data from an external system.

---

## Section 12: Common Failure Modes and the Pre-Deployment Checklist

**Exam Weight: Medium — pattern recognition for failure scenarios is testable**

### Objective 12.1: Identify and remediate common platform and compiler failures

#### Topics

---

**Topic: Compiler failures — causes and fixes**

| Failure | Cause | Fix |
|---|---|---|
| Empty reasoning block | A subagent has no instructions | Every subagent requires non-empty `reasoning.instructions`. This is a commit blocker. |
| Schema validation error | `system.instructions` names a capability with no corresponding subagent | Every named capability must map to an actual subagent definition. |
| Unresolvable action source | Managed package namespace not installed in the target org | Run `sf agent discover` against the deployment org before committing. |
| `@utils.transition` rule violation | Properties like `label:`, `require_user_confirmation:`, or `inputs:` placed on a utility action | Only `description:` and `available when` are valid on utility actions. |
| `developer_name` mismatch | Config name does not match the `aiAuthoringBundles/` directory name | Exact case-sensitive match is required. |
| `before_reasoning` in HyperClassifier router | `before_reasoning` deployed at `start_agent` level while HyperClassifier is the assigned model | Remove the lifecycle hook or override with `model_config: model: "model://sfdc_ai__DefaultGPT41"`. |
| `@utils.transition` in `after_reasoning` | Using LLM tool syntax in a directive block | Replace with bare `transition to @subagent.X` syntax. |

---

### Objective 12.2: Identify and remediate common runtime and state failures

#### Topics

---

**Topic: Aborted lifecycle — the `after_reasoning` silent failure**

When the LLM calls a `@utils.transition` action mid-reasoning, `after_reasoning` is aborted for that turn. State cleanup, logging, or transitions placed exclusively in `after_reasoning` will silently fail in those sessions. The fix is to move critical cleanup into deterministic `run` statements inside `reasoning.instructions` before the transition, so it executes regardless of whether `after_reasoning` fires Mesh orchestration loops — circular delegation**

In non-hierarchical agent graphs where Agent A delegates to Agent B and Agent B can delegate back to Agent A, circular delegation loops can form. These loops have no terminal state and will consume session resources until platform limits terminate the session. Every agent graph must be audited to confirm that all delegation paths have guaranteed terminal paths — either a user response or an `@utils.escalate`.

---

**Topic: Action loop — repeated execution without a terminal condition**

An action listed in the `reasoning: actions:` block with no `available when` guard and no post-action stop condition will be called repeatedly on every reasoning re-resolution. The LLM continues to see it as an available tool and continues to call it because the instructions do not signal that the work is done. Every write action must have an `available when` guard that removes it from the tool list after its intended execution.

---

### Objective 12.3: Apply the production agentic maturity roadmap

#### Topics

---

**Topic: The six levels of agentic maturity — building from core skills to full ecosystem integration**

Best practices define an incremental maturity model for building production-grade multi-agent systems:

| Level | Focus | Key Skills |
|---|---|---|
| Level 1 | Agent Script Mastery | Deterministic `->` vs. reasoning `\|`; action targets; variable scope discipline |
| Level 2 | Subagent Segmentation | Three triggers; mutually exclusive descriptions; `available when` as security primitive; HyperClassifier constraints |
| Level 3 | Model Stratification | Agent-level `model_config` as baseline; subagent overrides where justified; `sfdc_ai__` API names; version testing |
| Level 4 | SOMA Orchestration | Superagent as single entry point; bidirectional variable sync; Handoff vs. Supervised mode; Data Cloud Zero-Copy evaluation |
| Level 5 | MOMA and 3P | Cross-org trust boundaries; A2A protocol; MCP tool ecosystem; MuleSoft Agent Fabric |
| Level 6 | Full Ecosystem Integration | Multi-protocol architectures; Custom Evals (LLM-as-Judge); disambiguation patterns at scale; STDM observability; independent SDLC per domain |

---

## Appendix: Key Terms Reference

| Term | Definition |
|---|---|
| **Superagent** | The customer-facing orchestrator agent. Users interact only with this agent. |
| **Subagent** | A specialist domain agent operating behind the scenes with scoped instructions, data access, and actions. |
| **SOMA** | Single-Org Multi-Agent. All agents in one Salesforce org. |
| **MOMA** | Multi-Org Multi-Agent. Primary Agent in one org delegates to Secondary Agents in separate trusted orgs. |
| **A2A** | Agent-to-Agent protocol. Open interoperability standard for cross-system agent communication. |
| **MCP** | Model Context Protocol. Standardized interface for agents to discover and invoke tools, prompts, and resources. |
| **Agent Card** | JSON document advertising an agent's capabilities, authentication requirements, and A2A endpoint. |
| **EinsteinHyperClassifier** | Salesforce-owned routing model optimized for intent classification. Only supports `@utils.transition`. Prohibits `before_reasoning`/`after_reasoning`. |
| **`model_config:`** | Block that overrides the default model at org, agent, or subagent level. Uses `sfdc_ai__` API names in `model://` URI format. |
| **`available when`** | Guard condition that hides an action entirely from the LLM's tool list when the condition is not met. A first-class security primitive. |
| **Slot-fill** | Using the `...` token to signal the runtime to extract a value from user conversation via `@utils.setVariables`. |
| **Custom Evals (LLM-as-Judge)** | Automated QA mechanism using a secondary LLM to score conversation logs against defined quality criteria. Configured in the Testing Center. |
| **Semantic Conflict Detection** | Custom Eval pattern that scans full session logs for contradictory assertions made by different agents in the same session. |
| **Data Cloud Zero-Copy** | Federation mechanism allowing cross-org data access without data movement. Must be evaluated before choosing MOMA. |
| **Handoff Mode** | Subagent streams response directly to user; Superagent reclaims control after the turn ends. Lower latency, single-intent only. |
| **Supervised Mode** | Superagent mediates and synthesizes all responses. Higher latency, multi-intent capable. |
| **STDM** | Session Trace Data Model. Data Cloud schema for persisting and querying agent session traces. |
| **Trust Layer** | Platform-level safety guardrails (Prompt_Injection, Inappropriate_Content, Reverse_Engineering) that execute before any custom agent logic. |
| **MuleSoft Agent Fabric** | Broker registry for third-party agent discovery, routing, and policy enforcement. |
| **DC1** | Salesforce data center trust boundary governing which orgs can share agents in MOMA. |
| **AEA** | Agentforce Employee Agent. Internal, logged-in user context. |
| **ASA** | Agentforce Service Agent. Customer-facing, deployed via messaging channels. |
