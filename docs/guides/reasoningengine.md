# Inside Daisy: The Agentforce Reasoning Engine
### How Agentforce Thinks — Turn-by-Turn Mechanics, Determinism, and LLM Probabilism

---

> **How to use this document.** Read Sections 1-4 sequentially to build the core mental model. Sections 5-8 expand the model into specific mechanics. Section 9 covers the constraints the engine operates within. Section 10 covers reasoning-specific failure modes.

---

## Table of Contents

1. [The Mental Model: What the Reasoning Engine Is](#1-the-mental-model)
2. [The Two-Phase Execution Engine](#2-the-two-phase-execution-engine)
3. [The Complete Turn Anatomy](#3-the-complete-turn-anatomy)
4. [The Five Instruction Surfaces](#4-the-five-instruction-surfaces)
5. [Variables and State in the Reasoning Loop](#5-variables-and-state-in-the-reasoning-loop)
6. [Actions and the Reasoning Loop](#6-actions-and-the-reasoning-loop)
7. [The Posture Spectrum: Determinism vs. LLM Latitude](#7-the-posture-spectrum)
8. [The Einstein Trust Layer](#8-the-einstein-trust-layer)
9. [Reasoning Constraints](#9-reasoning-constraints)
10. [Reasoning Anti-Patterns](#10-reasoning-anti-patterns)
11. [Terminology Reference](#11-terminology-reference)

---

## 1. The Mental Model

### 1.1 What "Daisy" Is

"Daisy" is the informal name for the Agentforce runtime planner — the engine that receives a user message, interprets the AgentScript file, and produces a response. Formally it compiles into the `GenAiPlannerBundle` metadata artifact when you publish an agent. It is not a single LLM. It is a **hybrid execution environment** that combines:

- A **deterministic resolver** (a compiler-like pass that evaluates your authored logic before any LLM is involved)
- An **LLM reasoning loop** (where an underlying model makes probabilistic decisions within the constraints the resolver has already enforced)
- A **trust layer** (a runtime security boundary that wraps every LLM call)

This three-layer architecture is the foundational idea of this document. Every reasoning behavior, every bug, and every optimization traces back to the interaction between these three layers.

### 1.2 The Fundamental Split

```
DETERMINISTIC LAYER                    LLM LAYER
(authored control)                     (probabilistic judgment)

- if / else evaluation                 - Which action to call
- variable injection                   - How to fill slot parameters
- run @actions.X execution             - What to say to the user
- available when filtering             - Whether to respond or call a tool
- transition to routing                - How to phrase and sequence the response
- set variable capture
```

The critical insight: **the LLM never sees raw AgentScript syntax.** It never sees `if` blocks, `run` statements, `@variables.X` references, or `available when` guards. It only ever sees the output of the deterministic pass — a clean, resolved prompt string plus a set of tool schemas.

**Deterministic logic controls WHAT the agent knows. The LLM controls WHETHER and HOW to act on that knowledge.**

### 1.3 The Atlas Engine and the Agent Graph

A common misconception is that Agent Script is interpreted live, line-by-line, during runtime. In reality, the Atlas engine employs a compilation phase upon publish. The `.agent` file compiles into an Agent Graph that the runtime executes. This graph encodes two underlying mathematical structures:

- **Directed Acyclic Graph (DAG):** Tool invocations, sequential dependencies, and deterministic actions are mapped as a DAG. This prevents infinite loops within automated workflows and guarantees that prerequisites are met before downstream actions occur.
- **Finite State Machine (FSM):** Transitions between subagents and internal states are managed via an FSM. The engine records "backward arrows" indicating when the LLM must retry an action due to a failure, preventing catastrophic workflow degradation.

Understanding the DAG/FSM duality explains why the runtime behaves with predictability in the deterministic path and flexibility in the LLM path. The two mathematical models are each optimized for their respective domains.

---

## 2. The Two-Phase Execution Engine

Every reasoning iteration — every single time the agent needs to decide something — passes through both phases. This happens multiple times per user turn.

### 2.1 Phase 1: Deterministic Resolution

The runtime reads `reasoning.instructions: ->` from top to bottom. Nothing probabilistic happens here. The runtime:

1. **Evaluates `if`/`else if`/`else` conditions** against the current values of all variables. Only the matching branch's content proceeds. Non-matching branches are discarded entirely.
2. **Executes `run @actions.X` calls** synchronously. The action runs and its outputs are immediately available.
3. **Executes `set @variables.X` statements**, updating variable state immediately.
4. **Injects `{!@variables.X}` tokens** by replacing them with the current variable values in the pipe text.
5. **Evaluates `available when` guards** on each action in the `reasoning.actions` block. Actions that fail their guard are completely removed from the tool schema. The LLM will have no awareness they exist.
6. **Fires `transition to`** immediately if one is reached, discarding the current prompt and starting fresh in the target subagent. The LLM is never called for this iteration.

The output of Phase 1 is:
- A **resolved prompt string** (only the `|` pipe lines that matched the current state)
- A **filtered tool schema** (only the actions where `available when` evaluated to True)

### 2.2 Phase 2: LLM Reasoning

The resolved prompt string plus the filtered tool schemas pass through the Einstein Trust Layer (Section 8), then are handed to the underlying model. The LLM receives exactly:

1. **One system prompt**: Either the global `system.instructions` OR the subagent-level system override — never both merged, never blended
2. **Full conversation history**: All prior turns in this session
3. **The resolved `reasoning.instructions`**: Only the pipe text matching the current variable state. No conditionals. No `run` blocks. No `set` statements.
4. **Tool schemas**: JSON function schemas for only the actions that passed their `available when` guard

The LLM then makes one of three decisions:
- **Call an action**: Selects one tool, fills its slot parameters using `...` extraction from conversation, and submits the call
- **Produce a terminal response**: Writes a text reply to the user and ends the current reasoning loop
- **Delegate**: Calls a subagent as a tool (if one is available as a delegation reference), which runs its own reasoning loop and returns

### 2.3 Why This Split Is the Primary Diagnostic Tool

When you see unexpected agent behavior, this split gives you a precise first question: **did it fail in Phase 1 or Phase 2?**

- If the wrong instructions reached the LLM, it is a Phase 1 problem (wrong variable value, wrong condition, `|` mode instead of `->` mode).
- If the right instructions reached the LLM but it acted incorrectly, it is a Phase 2 problem (poor action description, ambiguous instructions, missing stop condition, conflicting directives).

This binary framing eliminates a large class of guesswork before you ever open a trace file.

---

## 3. The Complete Turn Anatomy

This is the full execution sequence for a single user message from arrival to response.

```
════════════════════════════════════════════════════════════
USER MESSAGE ARRIVES
════════════════════════════════════════════════════════════
                          │
                          ▼
            ┌─────────────────────────┐
            │   before_reasoning      │  (once per turn, deterministic only)
            │                         │
            │  - set @variables.X     │
            │  - run @actions.X       │
            │  - if / else evaluation │
            │  - transition to fires  │◄── If transition: jump to new subagent,
            │    if condition met     │    LLM never called for this turn
            └────────────┬────────────┘
                         │ (no transition)
                         ▼
╔══════════════════════════════════════════════════════════╗
║              REASONING LOOP BEGINS                       ║
║  (repeats until terminal response OR 3-4 iteration cap) ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  ┌─────────────────────────────────────────────────┐     ║
║  │ PHASE 1: Deterministic Resolution               │     ║
║  │                                                 │     ║
║  │  1. Evaluate if/else top-to-bottom              │     ║
║  │  2. Execute run @actions.X synchronously        │     ║
║  │  3. Execute set @variables.X                    │     ║
║  │  4. Inject {!@variables.X} into pipe text       │     ║
║  │  5. Filter available when → build tool schema   │     ║
║  │  6. If transition to reached: exit loop now     │     ║
║  │                                                 │     ║
║  │  OUTPUT: resolved prompt string + tool schemas  │     ║
║  └───────────────────┬─────────────────────────────┘     ║
║                      │                                   ║
║                      ▼                                   ║
║  ┌─────────────────────────────────────────────────┐     ║
║  │ EINSTEIN TRUST LAYER                            │     ║
║  │  - Zero-retention boundary enforced             │     ║
║  │  - Toxicity / injection detection               │     ║
║  │  - Sharing rules / FLS enforced                 │     ║
║  └───────────────────┬─────────────────────────────┘     ║
║                      │                                   ║
║                      ▼                                   ║
║  ┌─────────────────────────────────────────────────┐     ║
║  │ PHASE 2: LLM Reasoning                          │     ║
║  │                                                 │     ║
║  │  LLM receives:                                  │     ║
║  │    - system prompt (global OR subagent override)│     ║
║  │    - conversation history                       │     ║
║  │    - resolved instructions (pipe text only)     │     ║
║  │    - tool schemas (available when = True only)  │     ║
║  │                                                 │     ║
║  │  LLM decides:                                   │     ║
║  │    A) Call an action → go to Action Execution   │     ║
║  │    B) Produce terminal response → exit loop     │     ║
║  └───────────┬──────────────────┬──────────────────┘     ║
║              │(A)               │(B)                     ║
║              ▼                  ▼                        ║
║  ┌───────────────────┐    ┌──────────────────────────┐   ║
║  │ Action Execution  │    │  Terminal Response Sent   │   ║
║  │                   │    │  to User                  │   ║
║  │ - Apex/Flow runs  │    └──────────────┬────────────┘   ║
║  │ - @outputs filled │                   │               ║
║  │ - set stmts run   │                   ▼               ║
║  │ - @outputs scope  │    ╔══════════════════════════╗   ║
║  │   expires after   │    ║   EXIT REASONING LOOP    ║   ║
║  │   set completes   │    ╚══════════════════════════╝   ║
║  │ - loop counter+1  │                                   ║
║  └────────┬──────────┘                                   ║
║           │                                              ║
║           └──► BACK TO PHASE 1 RE-RESOLUTION ◄──────────╝
║                (with updated variable state)
╚══════════════════════════════════════════════════════════╝
                          │
                          ▼
            ┌─────────────────────────┐
            │   after_reasoning       │  (once per turn, after loop exits)
            │                         │
            │  - set @variables.X     │
            │  - run @actions.X       │
            │  - if / else evaluation │
            │  - transition to fires  │
            │    if condition met     │
            └─────────────────────────┘
                          │
                          ▼
════════════════════════════════════════════════════════════
TURN END — AWAITING NEXT USER MESSAGE
════════════════════════════════════════════════════════════
```

### 3.1 The Re-Resolution Loop: The Inner Heartbeat

The single most misunderstood mechanic in Agentforce is this: **after every tool call, the entire `reasoning.instructions` block is rebuilt from scratch** using the updated variable state.

This is not "continue from where you left off." It is a full re-evaluation of the entire instruction block, top to bottom, every time.

**Why this matters so much:** Post-action conditional checks MUST be placed at the TOP of `instructions: ->` blocks. When the loop re-evaluates after a tool call, it reads from the top. If your success check is at the bottom, the LLM sees all the "please ask the user for their order number" instructions again before ever reaching it — causing double-execution, confusion, and non-deterministic behavior.

```agentscript
# CORRECT: Post-action check at TOP fires immediately on re-resolution
reasoning:
    instructions: ->
        if @variables.order_status != "":
            | Your order status is {!@variables.order_status}.
            transition to @subagent.confirmation

        | Please provide your order number and I will look it up.

# WRONG: Post-action check at BOTTOM — LLM sees stale instructions again
reasoning:
    instructions: ->
        | Please provide your order number and I will look it up.
        if @variables.order_status != "":   # Never fires cleanly
            transition to @subagent.confirmation
```

### 3.2 The Backward Arrow: FSM Retry Mechanics

The Atlas FSM records "backward arrows" — what happens when the LLM attempts a tool call and receives an error payload. Rather than crashing, the FSM records the failure and the LLM reasons into an alternative approach. This is the mechanism behind the visual retry edges visible in trace tools: they show exactly where the LLM pivoted and which alternative path it took.

### 3.3 What the LLM Actually Does NOT See

The LLM **never** sees:
- Raw `if` or `else` keywords or their conditions
- `run` statements
- `set` statements
- `available when` conditions (failing actions simply disappear from the tool schema)
- `before_reasoning` or `after_reasoning` block content
- Subagent names or the concept of subagents as a structural entity
- `@variables.X` syntax — only the resolved value after `{!@variables.X}` injection
- Actions that fired deterministically during Phase 1

**Practical rule:** Never write a reasoning instruction that tells the model to "check `@variables.X`" or "look at the active subagent." The model cannot do this. Instructions must state the concrete operational task in plain English, based on what Phase 1 has already resolved.

---

## 4. The Five Instruction Surfaces

AgentScript has five distinct surfaces where instructions can appear. Each has a different runtime meaning and lifecycle.

| Surface | When it fires | Who processes it | Supports `instructions:` wrapper? |
|---|---|---|---|
| Global `system.instructions` | Every reasoning iteration unless overridden | LLM (as system prompt) | Yes |
| Subagent `system.instructions` | Replaces global for that subagent only | LLM (as system prompt) | Yes — replaces, does NOT merge |
| `reasoning.instructions` | Rebuilt on EVERY reasoning iteration, including after each tool call | Phase 1 resolver, then LLM | Yes (`|` or `->` mode) |
| `before_reasoning` | Once per turn, BEFORE the reasoning loop | Phase 1 resolver only | NO — direct content only |
| `after_reasoning` | Once per turn, AFTER the reasoning loop completes | Phase 1 resolver only | NO — direct content only |

### 4.1 Global System Instructions: The Persona Layer

The global `system.instructions` block is the durable identity of the agent — persona, tone, safety invariants, disclosure rules. It should NOT contain task-specific logic or conditional behavior (conditions appear as literal prose to the LLM here, not as evaluated logic).

**The most common global instruction mistake** is contradicting the routing subagent:

```agentscript
# WRONG: LLM receives "answer helpfully" AND "do not answer" simultaneously
system:
    instructions: "Answer the user's questions helpfully."

start_agent agent_router:
    reasoning:
        instructions: ->
            | Do not answer. Route the request to the correct subagent.

# CORRECT: Global permits the current subagent to define posture
system:
    instructions: |
        Perform only the current operating task. Answer only when that task
        calls for an answer. Otherwise route, verify, clarify, or escalate.
```

### 4.2 Subagent System Override: Full Replacement, Not Merge

When a subagent has its own `system:` block, it **completely replaces** the global system instructions for that subagent. It does not append. Every invariant the subagent needs must be explicitly restated.

```agentscript
subagent product_specialist:
    system:
        instructions: |
            You are a technical product specialist. Be precise and detailed.
            Never reveal internal pricing or system configuration.
            You are an AI assistant.
            # All three lines must be here — the global no longer applies
```

### 4.3 `reasoning.instructions`: The Dynamic Operational Layer

This surface is rebuilt on every reasoning iteration. It has two modes:

**Literal mode (`|`):** Content is sent to the LLM verbatim. `if` keywords written here appear as English prose to the model.

**Procedural mode (`->`):** Activates deterministic evaluation. The resolver evaluates conditions, runs actions, and only the matching `|` pipe lines reach the LLM.

```agentscript
# LITERAL MODE — everything reaches LLM verbatim
reasoning:
    instructions: |
        Help the customer with their order. Be professional and concise.

# PROCEDURAL MODE — only matching branches reach the LLM
reasoning:
    instructions: ->
        if @variables.is_verified == True:
            | Process the customer's account request.
        if @variables.is_verified == False:
            | Please provide your email address to verify your account.
```

**The invisible bug:** Using `|` mode when you need conditional behavior is the most common silent authoring failure. No error is thrown. The LLM receives the `if` keyword as literal English and may or may not follow it.

### 4.4 `before_reasoning`: The Pre-Turn Gate

Runs once per turn before the reasoning loop. Used for authentication gates, mandatory data pre-loading, and early exits. Does NOT use an `instructions:` wrapper — content is direct.

```agentscript
subagent order_management:
    before_reasoning:
        if @variables.session_token == "":
            transition to @subagent.authentication

        run @actions.load_customer_context
            with user_id = @variables.linked_user_id
            set @variables.account_tier = @outputs.tier
```

### 4.5 `after_reasoning`: The Post-Turn Gate

Runs once per turn after the reasoning loop produces a terminal response. The LLM has already spoken. Used for state cleanup, logging, and conditional terminal transitions.

**Important distinction:** `after_reasoning` fires after the loop ends with a response. It does NOT fire after each tool call within the loop. If a subagent transitions mid-reasoning via `@utils.transition to`, the original subagent's `after_reasoning` does NOT run.

---

## 5. Variables and State in the Reasoning Loop

### 5.1 The Two Variable Types

**Mutable variables** — the agent can read AND write. Must have a default value.

```agentscript
variables:
    customer_name: mutable string = ""
    order_count:   mutable number = 0
    is_verified:   mutable boolean = False
```

**Linked variables** — read-only, populated from session context. Must have a `source`. Must NOT have a default value.

```agentscript
variables:
    EndUserId: linked string
        source: @MessagingSession.MessagingEndUserId
```

**Boolean capitalization:** Always `True` or `False` (capitalized). The parser rejects lowercase. This is an extremely common compile error.

### 5.2 The Three Scope Zones

| Scope | What it holds | Valid contexts |
|---|---|---|
| `@variables.X` | Session-persistent state | Anywhere in AgentScript logic and `{!@variables.X}` in pipe text |
| `@outputs.X` | Action return values | Only in `set` and `if` statements IMMEDIATELY after the action's `run` block. Expires after those statements complete. |
| `@inputs.X` | Action input values | Only in `with` clauses DURING action invocation. NOT valid in `set` or post-execution checks. |

### 5.3 The Silent Failure Zone

`@inputs` and `@outputs` scope violations produce no error. The action executes successfully. The variable simply does not get set. Nothing in the surface behavior tells you this happened.

```agentscript
# WRONG — @inputs scope has expired after the action runs — SILENT FAILURE
run @actions.get_status
    with station_name = ...
    set @variables.station = @inputs.station_name   # FAILS SILENTLY

# WRONG — @outputs used after the immediate post-action window — SILENT FAILURE
run @actions.fetch_order
    with id = @variables.order_id
    set @variables.status = @outputs.status

| Placed at {!@outputs.customer_location}  # @outputs is GONE here

# CORRECT — capture everything immediately after the action
run @actions.fetch_order
    with id = @variables.order_id
    set @variables.status = @outputs.status
    set @variables.location = @outputs.customer_location

| Status: {!@variables.status} from {!@variables.location}
```

**Diagnostic pattern:** A `FunctionStep` in the trace that completes with no `postVars` diff indicates a scope violation.

### 5.4 Variable Persistence Across Subagent Transitions

Variables persist across subagent transitions. A variable set in Subagent A is fully available in Subagent B. This is the primary mechanism for passing state through a multi-subagent flow — and the reason a gate subagent can verify identity once and have that verification respected by every downstream subagent.

### 5.5 The `@utils.setVariables` Turn-End Side Effect

`@utils.setVariables` ends the turn after capturing values. Instructions do not re-evaluate in the same turn after it runs. The correct pattern for "capture then immediately act" is LLM slot-fill directly on the action:

```agentscript
# WRONG — setVariables ends the turn; the lookup never fires same turn
reasoning:
    actions:
        collect: @utils.setVariables
            with order_id = ...
        lookup: @actions.fetch_order    # Never fires in same turn
            with id = @variables.order_id

# CORRECT — LLM extracts and calls the action in one turn
reasoning:
    actions:
        lookup: @actions.fetch_order
            with id = ...
            set @variables.order_status = @outputs.status
```

### 5.6 The Three Input Binding Patterns

| Pattern | Syntax | Who fills it | When |
|---|---|---|---|
| LLM slot-fill | `with param = ...` | LLM extracts from conversation | Phase 2 (probabilistic) |
| Variable binding | `with param = @variables.X` | Runtime reads variable value | Phase 1 (deterministic) |
| Literal value | `with param = "fixed"` | Compiled constant | Phase 1 (deterministic) |

The ellipsis (`...`) operator is a Phase 2 probabilistic instruction to the LLM. If the value is absent from the conversation, the LLM asks the user for it. If a variable binding references an empty variable, the action receives an empty string silently — no prompt to the user.

---

## 6. Actions and the Reasoning Loop

### 6.1 The Two Invocation Modes

Every action can be invoked deterministically (Phase 1) or by the LLM (Phase 2). The choice fundamentally changes who controls whether and when the action fires.

**Deterministic invocation (`run @actions.X`):**
- Fires during Phase 1 before the LLM is ever called
- Always executes when the code path is reached, regardless of LLM judgment
- The LLM never sees the `run` statement

```agentscript
reasoning:
    instructions: ->
        run @actions.load_customer_profile
            with user_id = @variables.linked_user_id
            set @variables.account_tier = @outputs.tier

        | Account tier: {!@variables.account_tier}
```

**LLM-driven invocation (`reasoning.actions` block):**
- LLM decides whether and when to call the action, based on the `description`
- The LLM uses the action description to determine relevance
- Fires during Phase 2

```agentscript
reasoning:
    instructions: ->
        | Help the customer look up their order status.
    actions:
        lookup: @actions.get_order_status
            description: "Look up the current status, estimated delivery date, and
                          tracking number for a customer order by order ID"
            with order_id = ...
            set @variables.order_status = @outputs.status
```

### 6.2 `available when`: Hard Removal from the Reasoning Context

`available when` is not a soft hint. When a condition evaluates to `False` during Phase 1, the action is completely absent from the tool schema handed to the LLM. The model has zero awareness the action exists. This is fundamentally different from a prose instruction like "only call this if the user is verified" — that instruction is probabilistic and the LLM may not follow it. `available when` makes unauthorized invocation impossible, not just unlikely.

```agentscript
reasoning:
    actions:
        process_refund: @actions.issue_refund
            description: "Issue a refund to the customer"
            available when @variables.is_verified == True
            available when @variables.refund_amount > 0
            with order_id = @variables.order_id
```

### 6.3 The Three Transition Mechanisms

| Mechanism | Where valid | LLM involved? | Direction |
|---|---|---|---|
| Bare `transition to @subagent.X` | `before_reasoning`, `after_reasoning`, inside `run` post-condition | No — deterministic | One-way, no return |
| `@utils.transition to @subagent.X` | `reasoning.actions` only | Yes — LLM decides when | One-way, no return |
| `@subagent.X` (delegation) | `reasoning.actions` only | Yes — LLM decides when | Two-way — control returns to caller |

Using the wrong syntax in the wrong context causes a compilation error with no helpful message.

**Delegation (two-way):** When the LLM calls a delegated subagent as a tool, that subagent runs its own full reasoning loop, produces a result, and control returns to the calling subagent. The caller synthesizes the final response. This is supervision — the parent remains in control.

### 6.4 The Zero-Hallucination Action Pattern

Two output flags control what the LLM can see and say about an action's outputs:

| Flag | Effect |
|---|---|
| `filter_from_agent: True` | LLM cannot display this value to the user |
| `is_used_by_planner: True` | LLM can reason about this value for routing |

Combining both forces the LLM to actually call the action to get a routing value — it cannot hallucinate it — and can use the value for routing but cannot expose it to the user.

```agentscript
outputs:
    intent_classification: string
        filter_from_agent: True
        is_used_by_planner: True
```

---

## 7. The Posture Spectrum

Posture defines the spectrum between agentic (LLM has latitude) and deterministic (authored control governs). This is the core architectural decision for each subagent.

### 7.1 The Three Posture Types

**Agentic (default):** LLM chooses which actions to call, when, and how to fill parameters. LLM determines response content. Best for open-ended tasks with no security or ordering requirements.

**Mixed:** Some actions gated with `available when`. Some parameters pinned to variable values instead of `...`. Some conditional instructions restrict LLM behavior to matched branches. Best for tasks with security gates or irreversible actions.

**Scripted:** All transitions via bare `transition to`. All actions via `run`. LLM has zero discretion about what happens next. Best for regulated workflows with zero-tolerance for variation.

### 7.2 The Five Justifications for Adding Determinism

Add deterministic controls only when justified by one of these five causes. Adding controls for "just in case" reasons increases brittleness without improving safety.

1. **Regulatory requirement**: A compliance rule mandates specific sequencing or disclosure
2. **Trust gate**: Identity verification must complete before access is granted
3. **Irreversible action**: Once fired, the action cannot be undone
4. **External system ordering**: An external system requires operations in a specific sequence
5. **Observed production failure**: A specific behavior has failed and deterministic control is the fix

### 7.3 The Three Control Primitives

| Primitive | What it does |
|---|---|
| `available when` | Hard-removes action from tool schema when condition is False |
| Parameter pinning | `with param = @variables.X` instead of `...` — removes LLM slot-fill decision |
| Conditional instructions | `if/else` in `reasoning.instructions: ->` — LLM only sees the matching branch |

### 7.4 The Minimal Instructions Principle

**Keep instructions minimal.** Optimal LLM performance comes from concise, focused instructions. Push as much as possible into actions — logic in actions is reusable and does not add context to the LLM. Shorter instructions produce better reasoning because the model has fewer conflicting signals to interpret. Every instruction that does not change behavior should be removed.

---

## 8. The Einstein Trust Layer

The Einstein Trust Layer (ETL) is the **runtime** security boundary that operates milliseconds before every LLM call, on every turn, for every session. It sits between Phase 1 output and the LLM. It is separate from the authoring-time safety review — these are two distinct mechanisms.

```
Phase 1 Output (resolved prompt + tool schemas)
          │
          ▼
[ETL: Sharing rule enforcement / FLS checks]
          │
          ▼
[ETL: Input toxicity and injection screening]
          │
          ▼
[ETL: Zero-retention boundary established for this call]
          │
          ▼
LLM Gateway → Foundation Model
          │
          ▼
[ETL: Output toxicity and grounding checks]
          │
          ▼
Response returned to reasoning loop
```

### 8.1 Zero-Retention Policy

Customer CRM data used for grounding is never stored, logged, or used to train external public models by the underlying LLM providers (OpenAI, Anthropic, Google, etc.). The data flows into the LLM gateway only for that specific inference call and is discarded immediately. This is a contractual and architectural guarantee, not a configuration option.

### 8.2 Prompt Guardrails and Toxicity Detection

The ETL screens input context for malicious prompt injections and inappropriate content before the assembled context reaches the foundation model. It also screens outputs before they are returned to the reasoning loop. Toxic or injection-carrying content is intercepted at this layer.

### 8.3 Data Boundary Enforcement

Salesforce sharing rules and field-level security are enforced at every agent action. Grounding data pulled for an LLM call respects the same permission model as a direct SOQL query by the running user. The ETL extends this governance to the LLM boundary — the model cannot be given data the running user is not authorized to see.

---

## 9. Reasoning Constraints

### 9.1 The 3-4 Loop Iteration Limit

The reasoning loop has a hard guardrail of approximately 3-4 iterations before the runtime forces an exit. This protects against infinite loops and is enforced by the Atlas FSM.

What this means for reasoning design:
- The engine cannot chain more than 3-4 LLM-driven action calls in a single user turn
- Workflows requiring more sequential decisions must be spread across multiple turns
- Circular subagent references will hit this limit unpredictably
- Counting the maximum possible loop iterations on every execution path is a required design step

### 9.2 The 10,000 Token Heuristic

The Agentforce reasoning engine operates with an effective architectural target of approximately **10,000 tokens per transaction payload.** This is not a hard API limit — it is a performance and accuracy heuristic. Every token in the context window adds reasoning latency and creates interpretive load for the model. Beyond roughly 10k tokens, response quality degrades and latency spikes become measurable.

**What fills the token budget:**

| Source | Typical size | Controllable? |
|---|---|---|
| Global system instructions | 100-500 tokens | Yes — keep concise |
| Subagent system override | 100-500 tokens | Yes — restate only required invariants |
| Conversation history | Grows per turn | Partially |
| Resolved reasoning instructions | 100-1,000 tokens | Yes — `->` mode sends only matching branches |
| Tool schemas (available actions) | ~100 tokens per action | Yes — `available when` suppresses irrelevant tools |

**The three optimization levers:**
1. **Conciseness:** Remove any instruction that does not change behavior
2. **Consolidation:** Merge redundant actions
3. **Filtering:** Use `available when` aggressively — every suppressed action reduces the budget

**Important:** Token count drives latency and LLM accuracy. It does NOT affect credit billing. These are separate concerns.

---

## 10. Reasoning Anti-Patterns

These are the failure modes that trace directly back to how the reasoning engine works.

### AP-1: `|` Mode with Conditional Logic (The Invisible Bug)
```agentscript
# WRONG — sends literal "if @variables.is_verified == True:" to LLM as prose
reasoning:
    instructions: |
        if @variables.is_verified == True:
            Show account details.

# CORRECT
reasoning:
    instructions: ->
        if @variables.is_verified == True:
            | Show account details.
```

### AP-2: Post-Action Check at Bottom (Re-Resolution Trap)
```agentscript
# WRONG — LLM sees "ask for order number" again after lookup completes
reasoning:
    instructions: ->
        | What is your order number?
        if @variables.order_status != "":
            transition to @subagent.show_status

# CORRECT — check at TOP, fires first on every re-resolution
reasoning:
    instructions: ->
        if @variables.order_status != "":
            transition to @subagent.show_status
        | What is your order number?
```

### AP-3: Prose-Based Authorization (Security Failure)
```agentscript
# WRONG — LLM may or may not follow prose instructions
reasoning:
    instructions: ->
        | Only call the refund action if the customer is verified.
    actions:
        refund: @actions.issue_refund
            with order_id = ...

# CORRECT — available when is a hard filter, not a suggestion
reasoning:
    actions:
        refund: @actions.issue_refund
            available when @variables.is_verified == True
            with order_id = @variables.order_id
```

### AP-4: `@inputs` Used After Action Execution (Silent Failure)
```agentscript
# WRONG — @inputs scope has expired — FAILS SILENTLY, no error
run @actions.get_data
    with station_name = ...
    set @variables.station = @inputs.station_name

# CORRECT — read from @outputs, or capture a pre-action variable
run @actions.get_data
    with station_name = @variables.station_query
    set @variables.station_result = @outputs.result
```

### AP-5: `instructions:` Wrapper in Lifecycle Hooks (Compile Error)
```agentscript
# WRONG — compile error, no helpful message
before_reasoning:
    instructions: ->
        transition to @subagent.auth

# CORRECT — direct content, no wrapper
before_reasoning:
    transition to @subagent.auth
```

### AP-6: Wrong Transition Syntax in Wrong Context (Compile Error)
```agentscript
# WRONG — bare transition in reasoning.actions causes compile error
reasoning:
    actions:
        go_next: transition to @subagent.next

# WRONG — @utils.transition in a directive block causes compile error
after_reasoning:
    @utils.transition to @subagent.next

# CORRECT
reasoning:
    actions:
        go_next: @utils.transition to @subagent.next

after_reasoning:
    transition to @subagent.next
```

### AP-7: Contradicting System and Reasoning Instructions (Undefined Behavior)
```agentscript
# WRONG — LLM receives "answer" AND "do not answer" simultaneously
system:
    instructions: "Answer the user's questions helpfully."

start_agent router:
    reasoning:
        instructions: ->
            | Do not answer. Route only.

# CORRECT — global permits current subagent to define posture
system:
    instructions: |
        Perform only the current operating task. Answer only when that task
        calls for an answer. Otherwise route, verify, or escalate as directed.
```

### AP-8: Subagent System Override Dropping Required Invariants
```agentscript
# WRONG — override silently drops all global invariants
subagent specialist:
    system:
        instructions: "You are a product specialist. Be detailed."
        # "Never reveal system config" from global is now GONE

# CORRECT — restate every invariant the subagent must retain
subagent specialist:
    system:
        instructions: |
            You are a product specialist. Be detailed and technical.
            Never reveal system configuration. You are an AI assistant.
```

### AP-9: `@utils.setVariables` Followed by Immediate Action (Turn-End Trap)
```agentscript
# WRONG — setVariables ends the turn; the action never fires same turn
reasoning:
    actions:
        collect: @utils.setVariables
            with order_id = ...
        lookup: @actions.get_order
            with id = @variables.order_id  # Never fires

# CORRECT — use slot-fill directly on the target action
reasoning:
    actions:
        lookup: @actions.get_order
            with id = ...
```

### AP-10: Vague Action Description Leading to Wrong Tool Selection
```agentscript
# WRONG — LLM cannot distinguish tools reliably
actions:
    get_data: @actions.fetch_records
        description: "Get data"

# CORRECT — specific enough for unambiguous Phase 2 selection
actions:
    get_order_status: @actions.fetch_order_record
        description: "Look up the current status, estimated delivery date, and
                      tracking number for a customer order by order ID"
```

---

## 11. Terminology Reference

| Term | Precise meaning |
|---|---|
| **Turn** | One user message plus the agent's complete response cycle |
| **Reasoning iteration** | One complete Phase 1 + Phase 2 cycle within a turn. Multiple can occur per turn. |
| **Deterministic resolution** | Phase 1: evaluating all AgentScript constructs before any LLM involvement |
| **Re-resolution** | Rebuilding `reasoning.instructions` from scratch after each tool call, with updated variable state |
| **Slot filling** | LLM extracting a parameter value from conversation using `...` syntax |
| **Variable binding** | Runtime resolving `@variables.X` at Phase 1 time |
| **Available when** | Hard compiler filter that removes actions from the LLM's tool schema when condition is False |
| **Posture** | The spectrum of LLM autonomy vs authored determinism for a subagent |
| **Handoff** | One-way transfer via `@utils.transition to` — caller does not resume |
| **Delegation/Supervision** | Two-way call via `@subagent.X` — child runs its reasoning loop, control returns to caller |
| **Tool schema** | JSON function schema representation of an action, handed to the LLM in Phase 2 |
| **`\|` mode** | Literal instruction mode: content sent as-is to LLM without evaluation |
| **`->` mode** | Procedural mode: conditionals evaluated by Phase 1 before any LLM call |
| **Daisy** | Informal name for the Agentforce reasoning runtime/planner |
| **Atlas** | The formal engine name that compiles and executes the Agent Graph |
| **DAG** | Directed Acyclic Graph: mathematical structure for tool invocations and sequential dependencies |
| **FSM** | Finite State Machine: manages subagent transitions and retry logic |
| **Backward arrow** | FSM term for a retry edge — where the LLM attempted a tool call, failed, and pivoted |
| **GenAiPlannerBundle** | Runtime metadata artifact created during agent publish |
| **AiAuthoringBundle** | Authoring-domain metadata artifact (`.agent` file + bundle-meta.xml) |
| **`@inputs`** | Action input values — valid ONLY in `with` clauses during invocation |
| **`@outputs`** | Action return values — valid ONLY in `set`/`if` immediately after invocation |
| **`@variables`** | Session-persistent state — valid anywhere in AgentScript logic |
| **`before_reasoning`** | Deterministic pre-turn hook — fires once before the reasoning loop, no `instructions:` wrapper |
| **`after_reasoning`** | Deterministic post-turn hook — fires once after the reasoning loop ends with a response |
| **Loop iteration limit** | Hard platform guardrail of ~3-4 reasoning iterations per turn before forced exit |
| **10k Token Heuristic** | Architectural target of ~10,000 tokens per payload — governs latency and LLM accuracy, not credit billing |
| **Zero-Hallucination Pattern** | `filter_from_agent: True` + `is_used_by_planner: True` — forces LLM to invoke action rather than guess a value |
| **Einstein Trust Layer (ETL)** | Runtime boundary between Phase 1 and the LLM: zero-retention, toxicity detection, FLS enforcement |
| **Zero-Retention Policy** | ETL guarantee that CRM grounding data is never stored by or used to train external LLM providers |

---

*Compiled from: Agent Script Core Language Reference, Instruction Resolution Reference, Actions Reference, Posture and Determinism Reference, Architecture Patterns Reference, Production Gotchas Reference, Agent Script Deep Dive Webinars (Parts 1, 2, and 3), and "Inside Daisy: The Turn-by-Turn Mechanics of Agentforce Reasoning" (user document).*

