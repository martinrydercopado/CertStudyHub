# Inside Daisy: The Complete Agentforce Reasoning Engine Guide

**How Agentforce Thinks — Turn-by-Turn Mechanics, Determinism, and LLM Probabilism**

---

## Table of Contents

1. [The Mental Model](#1-the-mental-model)
   - [1.1 What "Daisy" Is](#11-what-daisy-is)
   - [1.2 The Fundamental Split](#12-the-fundamental-split)
   - [1.3 The Atlas Engine and the Agent Graph](#13-the-atlas-engine-and-the-agent-graph)
2. [The Two-Phase Execution Engine](#2-the-two-phase-execution-engine)
   - [2.1 Phase 1: Deterministic Resolution](#21-phase-1-deterministic-resolution)
   - [2.2 Phase 2: LLM Reasoning](#22-phase-2-llm-reasoning)
   - [2.3 Why This Split Is the Primary Diagnostic Tool](#23-why-this-split-is-the-primary-diagnostic-tool)
3. [The Complete Turn Anatomy](#3-the-complete-turn-anatomy)
   - [3.1 The Re-Resolution Loop: The Inner Heartbeat](#31-the-re-resolution-loop-the-inner-heartbeat)
   - [3.2 The Backward Arrow: FSM Retry Mechanics](#32-the-backward-arrow-fsm-retry-mechanics)
   - [3.3 What the LLM Actually Does NOT See](#33-what-the-llm-actually-does-not-see)
4. [The Five Instruction Surfaces](#4-the-five-instruction-surfaces)
   - [4.1 Global System Instructions: The Persona Layer](#41-global-system-instructions-the-persona-layer)
   - [4.2 Subagent System Override: Full Replacement, Not Merge](#42-subagent-system-override-full-replacement-not-merge)
   - [4.3 reasoning.instructions: Two Modes, One Critical Rule](#43-reasoninginstructions-two-modes-one-critical-rule)
   - [4.4 before_reasoning: The Pre-Turn Gate](#44-before_reasoning-the-pre-turn-gate)
   - [4.5 after_reasoning: The Post-Turn Gate](#45-after_reasoning-the-post-turn-gate)
5. [Variables and State in the Reasoning Loop](#5-variables-and-state-in-the-reasoning-loop)
   - [5.1 Mutable vs. Linked Variables](#51-mutable-vs-linked-variables)
   - [5.2 The Three Scope Zones](#52-the-three-scope-zones)
   - [5.3 The Silent Failure Zone](#53-the-silent-failure-zone)
   - [5.4 Variable Persistence Across Subagents](#54-variable-persistence-across-subagents)
   - [5.5 The setVariables Turn-End Trap](#55-the-setvariables-turn-end-trap)
   - [5.6 The Three Input Binding Patterns](#56-the-three-input-binding-patterns)
6. [Actions and the Reasoning Loop](#6-actions-and-the-reasoning-loop)
   - [6.1 Deterministic vs. LLM-Driven Invocation](#61-deterministic-vs-llm-driven-invocation)
   - [6.2 available when: Hard Filter, Not Soft Hint](#62-available-when-hard-filter-not-soft-hint)
   - [6.3 The Three Transition Mechanisms](#63-the-three-transition-mechanisms)
   - [6.4 Handoff vs. Delegation](#64-handoff-vs-delegation)
   - [6.5 The Zero-Hallucination Routing Pattern](#65-the-zero-hallucination-routing-pattern)
7. [The Posture Spectrum](#7-the-posture-spectrum)
   - [7.1 Agentic, Mixed, and Scripted](#71-agentic-mixed-and-scripted)
   - [7.2 The Five Justifications for Determinism](#72-the-five-justifications-for-determinism)
   - [7.3 The Three Control Primitives](#73-the-three-control-primitives)
   - [7.4 The Minimal Instructions Principle](#74-the-minimal-instructions-principle)
8. [The Einstein Trust Layer](#8-the-einstein-trust-layer)
   - [8.1 What It Is and When It Operates](#81-what-it-is-and-when-it-operates)
   - [8.2 The Zero-Retention Policy](#82-the-zero-retention-policy)
   - [8.3 Data Permissions and Content Screening](#83-data-permissions-and-content-screening)
9. [Reasoning Constraints](#9-reasoning-constraints)
   - [9.1 The 3–4 Loop Iteration Limit](#91-the-34-loop-iteration-limit)
   - [9.2 The 10,000-Token Heuristic](#92-the-10000-token-heuristic)
10. [Reasoning Anti-Patterns](#10-reasoning-anti-patterns)
11. [Terminology Reference](#11-terminology-reference)

---

## 1. The Mental Model

### Why This Matters Before Anything Else

Before Agentforce, building an AI assistant on Salesforce meant writing a prompt, sending it to a model, and hoping the response was correct and safe. That approach has hard limits. The model can be asked to do things it should not do. It can invent information it does not have. It has no reliable mechanism for enforcing business rules, and there is no audit trail when it goes wrong.

Agentforce represents a fundamentally different design philosophy. The move from simple prompting to hybrid reasoning is the central idea of this entire guide. Understanding it is not background context — it is the prerequisite for everything else.

---

### 1.1 What "Daisy" Is

"Daisy" is the informal name for the Agentforce runtime planner — the engine that receives a user message, interprets the AgentScript configuration file, and produces a response. When you publish an agent via the Salesforce CLI, Daisy formally compiles into the **GenAiPlannerBundle** metadata artifact.

It is not a single large language model. It is a **hybrid execution environment** that combines three distinct layers:

- **A deterministic resolver** — a compiler-like pass that evaluates your authored logic before any LLM is ever involved
- **An LLM reasoning loop** — where an underlying foundation model makes probabilistic decisions, but only within the constraints the resolver has already enforced
- **The Einstein Trust Layer** — a runtime security boundary that wraps every LLM call, enforcing data privacy, permission checks, and content safety

Think of it this way. A pure LLM approach is like asking a very smart person to run your company with no rulebook, no access controls, and no audit trail. The Daisy hybrid approach gives that person a strict operating manual, controlled access to tools, and a security checkpoint on everything they send or receive. Every reasoning behavior, every bug, and every optimization in Agentforce traces back to the interaction between these three layers.

Learning to think in this three-layer model is the single most important skill in Agentforce development.

---

### 1.2 The Fundamental Split

The most important concept in all of Agentforce is the clean division of responsibility between the deterministic layer and the LLM layer. Once you internalize this split, debugging becomes dramatically faster and authoring decisions become much clearer.

**The deterministic layer handles everything that must always be controlled:**

| Deterministic Layer (authored control) | LLM Layer (probabilistic judgment) |
|---|---|
| if / else evaluation | Which action to call |
| Variable injection | How to fill slot parameters |
| run @actions.X execution | What to say to the user |
| available when filtering | Whether to respond or call a tool |
| transition to routing | How to phrase and sequence the response |
| set variable capture | Which of multiple valid paths to take |

Here is the critical insight: **the LLM never sees raw AgentScript syntax.** It never sees `if` blocks, `run` statements, `@variables.X` references, or `available when` guards. It only ever sees the output of the deterministic pass — a clean, resolved prompt string plus a filtered set of tool schemas.

Deterministic logic controls **what the agent knows**. The LLM controls **whether and how to act** on that knowledge.

> **Scenario: Why This Split Matters in Practice**
>
> You are building a customer service agent for a bank. A customer asks to transfer $10,000 to an external account. In a pure LLM world, the model decides whether to execute this based on the prompt you wrote — a prompt the user might be able to argue or trick their way around. In Agentforce, the transfer action simply does not appear in the LLM's tool list until `@variables.is_verified == True`. The model cannot override this. It cannot be convinced otherwise. The deterministic layer made unauthorized invocation structurally impossible before the LLM was ever consulted.

---

### 1.3 The Atlas Engine and the Agent Graph

A natural assumption when first reading AgentScript is that the file is interpreted live, line-by-line, each time a user sends a message. This assumption leads to incorrect mental models about timing, ordering, and what "running" an action actually means.

The Atlas engine employs a **compilation phase** when you publish an agent. The `.agent` file compiles into an **Agent Graph** — a compiled representation of your agent's behavior that the runtime executes. This graph encodes two mathematical structures, each optimized for its domain.

**Directed Acyclic Graph (DAG):** Tool invocations, sequential dependencies, and deterministic actions are mapped as a DAG. This structure mathematically prevents infinite loops within automated workflows and guarantees that prerequisites are met before downstream actions can occur. The "acyclic" property means no node can point back to itself or any ancestor — infinite loops are impossible in the deterministic path by design.

**Finite State Machine (FSM):** Transitions between subagents and internal states are managed via an FSM. Unlike the DAG, the FSM records "backward arrows" — edges representing what happens when the LLM tries an action, receives an error, and must reason into an alternative approach. This retry mechanic prevents catastrophic workflow degradation when actions fail.

Why two structures? The DAG guarantees determinism and order in the parts of your agent you fully control. The FSM allows flexibility and recovery in the parts where the LLM is reasoning. Together they give Agentforce predictability where you need it, and adaptability where you need that instead.

---

## 2. The Two-Phase Execution Engine

### Why Two Phases?

Early AI systems were either fully scripted (rule engines, decision trees) or fully probabilistic (raw LLM prompting). Scripted systems are predictable but brittle — they cannot handle natural language variation. Probabilistic systems are flexible but unsafe — they cannot reliably enforce business rules.

The two-phase engine is the architectural answer to this tension. Phase 1 handles everything that must be predictable. Phase 2 handles everything that benefits from intelligent, adaptive judgment. The boundary between them is precise, not fuzzy.

---

### 2.1 Phase 1: Deterministic Resolution

Every reasoning iteration — every single cycle of the engine — begins with Phase 1 before the LLM is ever involved. This phase is entirely deterministic: given the same input state, it always produces the same output. There is no probability here, no model involved, no variability.

Phase 1 reads `reasoning.instructions: ->` from top to bottom and performs these six operations in sequence:

**1. Condition Evaluation**
Evaluates `if / else if / else` conditions against current variable values. Only the matching branch's content proceeds. Non-matching branches are discarded entirely — they do not exist as far as the LLM is concerned.

**2. Synchronous Action Execution**
Executes `run @actions.X` calls synchronously. The Apex class or Flow runs immediately, and its outputs are available for the next steps within the same Phase 1 pass.

**3. Variable Capture**
Executes `set @variables.X` statements, updating variable state immediately. These updated values are available to all subsequent steps in the same Phase 1 pass.

**4. Token Injection**
Replaces `{!@variables.X}` tokens with their current values in the pipe text. This is how the LLM ends up with concrete values — a customer's name, an order status, a tier level — injected directly into its instruction text.

**5. Tool Schema Filtering**
Evaluates `available when` guards on every action in the `reasoning.actions` block. Actions that fail their guard are completely removed from the tool schema. The LLM has zero awareness they exist.

**6. Immediate Transition**
Fires `transition to` immediately if one is reached. The current prompt is discarded, and execution starts fresh in the target subagent. The LLM is never called for this iteration.

**The output of Phase 1 is two things:** a resolved prompt string (only the pipe lines matching current state) and a filtered tool schema (only the actions where `available when` evaluated to True). Everything Phase 2 receives has already been through this filter.

---

### 2.2 Phase 2: LLM Reasoning

Phase 2 is where probability enters. After Phase 1 produces its resolved output, that output passes through the Einstein Trust Layer and is handed to the underlying foundation model.

**The LLM receives exactly four things:**

1. **One system prompt** — either the global `system.instructions` or the subagent-level system override. Never both merged. Never blended. Only one is active.
2. **Full conversation history** — every prior turn in this session.
3. **Resolved reasoning.instructions** — only the pipe text matching current variable state. No conditionals. No `run` blocks. No `set` statements. Just plain, resolved English.
4. **Tool schemas** — JSON function schemas for only the actions that passed their `available when` guard during Phase 1.

**The LLM makes one of three decisions:**

- **Call an action** — selects one tool, fills its slot parameters by extracting values from conversation, and submits the call
- **Produce a terminal response** — writes a text reply to the user and ends the current reasoning loop
- **Delegate to a subagent** — calls a subagent as a tool (if available), which runs its own reasoning loop and returns a result

> **Scenario: A Refund Request**
>
> A customer types "I need a refund for order 12345." Phase 1 has already evaluated that `@variables.is_verified == True` and included the `issue_refund` action in the tool schema. It has also injected the customer's account tier into the prompt text. The LLM now sees a resolved instruction like "Help the customer with their refund request. The customer is a Gold tier member." and a tool schema containing the `issue_refund` action. The LLM decides to call `issue_refund`, extracts "12345" from the conversation as the order ID, and submits the call. The customer's verification status was enforced in Phase 1 before the LLM ever had a chance to reason about it.

---

### 2.3 Why This Split Is the Primary Diagnostic Tool

One of the most practical benefits of the two-phase architecture is how cleanly it maps to debugging. When an agent misbehaves, most developers open a trace and start reading without a clear hypothesis. The Phase 1/Phase 2 split gives you a structured first question that immediately narrows the search.

**Ask: Did the correct instructions and tool list reach the LLM?**

If **no** — wrong branch was active, a required action was missing from the tool schema, or an injected variable had the wrong value — you have a **Phase 1 problem**. The cause is in your authored logic: a wrong variable value, a wrong condition expression, or `|` mode used instead of `->` mode. Fix it by inspecting variable state and condition logic.

If **yes** — the right instructions and tools reached the LLM, but it still acted incorrectly — you have a **Phase 2 problem**. The cause is in how the LLM interpreted what it received: a vague action description, ambiguous instructions, a missing stop condition, or conflicting directives. Fix it by improving descriptions and instructions.

This binary framing eliminates a large class of guesswork before you ever read a full trace file.

---

## 3. The Complete Turn Anatomy

### What a Turn Actually Contains

A turn is one complete cycle: one user message in, one agent response out. Inside that cycle, a structured sequence of events occurs across three phases — a pre-turn gate, a reasoning loop, and a post-turn gate. Understanding this sequence precisely is the foundation for predicting how your agent will behave and diagnosing problems when it does not.

**The complete turn sequence:**

```
User message arrives
    ↓
before_reasoning fires (deterministic only, once per turn)
    → If a transition fires here: jump to new subagent, LLM never called
    ↓
Reasoning loop begins
    → Phase 1: deterministic resolution
    → Einstein Trust Layer
    → Phase 2: LLM reasoning
        → If LLM calls an action: execute, capture outputs, re-resolve from top, loop
        → If LLM produces response: exit loop, deliver to user
    → Loop repeats until terminal response or 3–4 iteration cap
    ↓
after_reasoning fires (deterministic only, once per turn)
    ↓
Turn ends. Agent waits for next message.
```

> **Scenario: A Status Lookup**
>
> A user types "What is the status of my order?" `before_reasoning` fires and checks if `@variables.session_token` is empty — it is not, so no redirect. The reasoning loop begins. Phase 1 resolves instructions and filters available actions. Phase 2 (the LLM) decides to call `get_order_status`, extracting the user's intent. The action runs, populates `@variables.order_status`, and Phase 1 re-resolution fires immediately from the top. The re-resolution detects `@variables.order_status != ''` at the top of the block. The LLM produces: "Your order is out for delivery and will arrive today." `after_reasoning` fires and logs the completed lookup. Turn ends.

---

### 3.1 The Re-Resolution Loop: The Inner Heartbeat

The re-resolution loop is the single most misunderstood mechanic in Agentforce, and getting it wrong produces some of the most confusing bugs on the platform.

**What re-resolution means:** after every tool call, the entire `reasoning.instructions` block is rebuilt from scratch using the updated variable state. This is not "continue from where you left off." It is a full re-evaluation of the entire instruction block, top to bottom, every single time a tool call completes.

**Why the platform works this way:** variable state has changed. The instruction text that was appropriate before the action ran may no longer be appropriate after. By rebuilding the entire block, the engine ensures the LLM always sees instructions that reflect the current state of the world — not a stale snapshot from the beginning of the iteration.

**The critical authoring consequence:** post-action conditional checks **must be placed at the TOP of `instructions: ->` blocks.**

Here is what goes wrong when they are at the bottom:

```
instructions: ->
    | Please provide your order number and I will look it up.
    run @actions.get_order_status
        with order_id = ...
        set @variables.status = @outputs.status
    | ← re-resolution fires here, reads from TOP again
    if @variables.status != '':   ← ← ← THIS IS TOO LATE
        | Your order status is {!@variables.status}.
```

After the action runs, re-resolution fires and reads from the top. The LLM sees "Please provide your order number" again and either repeats the ask or produces a confused response. The result check at the bottom never gets a clean shot at controlling behavior.

**The correct pattern:**

```
instructions: ->
    if @variables.status != '':   ← ← ← CHECK FIRST, ALWAYS
        | Your order status is {!@variables.status}.
    | Please provide your order number and I will look it up.
    run @actions.get_order_status
        with order_id = ...
        set @variables.status = @outputs.status
```

On first entry, `@variables.status` is empty, so the condition is False, it is skipped, and the LLM correctly sees the initial instruction. After the action completes and re-resolution fires, the status is now set, the condition is True, and the LLM sees the success instruction instead. This is one of those rules that, once you understand the reason behind it, becomes completely intuitive.

---

### 3.2 The Backward Arrow: FSM Retry Mechanics

In a purely sequential execution model, a failed action crashes the workflow. The Atlas FSM takes a more resilient approach through a mechanism called the **backward arrow**.

When the LLM attempts a tool call and receives an error payload instead of a successful result, the FSM records this as a backward arrow — a retry edge in the Agent Graph. Rather than terminating the turn, the FSM records the failure and the LLM reasons into an alternative approach. It might try a different action, ask the user for corrected input, or produce an apologetic response explaining it could not complete the task.

In trace visualization tools, backward arrows appear as literal reverse edges in the chain-of-thought graph — you can see exactly where the LLM pivoted and which path it took instead.

**The important design implication:** retry loops still consume reasoning iterations. Each retry is one more tick toward the 3–4 iteration hard cap. A misconfigured action that consistently returns an error will cause the LLM to retry until it hits the cap, producing a confusing "unexpected error" response to the user. Monitoring for backward arrows in production traces is an essential practice for catching misconfigured actions before they affect users at scale.

---

### 3.3 What the LLM Actually Does NOT See

Understanding what the LLM cannot see is just as important as understanding what it can. Developers who try to "explain" AgentScript constructs to the LLM in their instructions are writing dead code — the model cannot access those constructs.

**The LLM never sees:**

- Raw `if` or `else` keywords or the conditions they contain
- `run` statements or any indication one fired
- `set` statements
- `available when` conditions — failing actions simply do not appear in the tool schema, with no indication they ever existed
- `before_reasoning` or `after_reasoning` block content
- Subagent names or the concept of subagents as a structural entity
- `@variables.X` syntax — it only sees the resolved value after `{!@variables.X}` injection
- Any action invocations that fired deterministically during Phase 1

**The practical authoring rule:** never write a reasoning instruction that tells the model to "check `@variables.X`" or "look at which subagent is active." The model cannot do these things. Instructions must state the concrete operational task in plain English, based on what Phase 1 has already resolved and injected.

A good test: read your `reasoning.instructions` pipe text as if you were the LLM receiving it. Does it make sense as a standalone English instruction? Does it give you enough context to act? Or does it reference AgentScript constructs? If it references constructs, it needs to be rewritten.

---

## 4. The Five Instruction Surfaces

### Why Multiple Surfaces Exist

In simple prompt-based systems, there is one instruction: the prompt. In Agentforce, instructions are organized across five distinct surfaces, each with a different lifecycle, a different processor, and different rules. This is not complexity for its own sake. Each surface solves a specific problem: some instructions should apply universally, some should vary by subagent context, some should be rebuilt on every action call, and some should fire only once per turn with no LLM involvement at all.

Conflating these surfaces — using the wrong one for the wrong job — is one of the most common sources of both bugs and compile errors.

**Quick reference:**

| Surface | Fires | Processed By | Supports `instructions:` Wrapper |
|---|---|---|---|
| Global system | Every iteration | LLM (system prompt) | Yes |
| Subagent system | Every iteration (overrides global) | LLM (system prompt) | Yes |
| reasoning.instructions | Every iteration, rebuilt each | Phase 1 resolver, then LLM | Yes (`\|` or `->` mode) |
| before_reasoning | Once per turn, before loop | Phase 1 resolver only | **No — direct content only** |
| after_reasoning | Once per turn, after loop | Phase 1 resolver only | **No — direct content only** |

---

### 4.1 Global System Instructions: The Persona Layer

The global `system.instructions` block is the durable identity of the agent — its persona, its tone, its non-negotiable safety rules, and its disclosure requirements. It fires every reasoning iteration unless a subagent overrides it, making it the model's constant baseline.

**What belongs here:** persona and tone, safety invariants that must never change, and universal disclosure rules such as "I am an AI assistant."

**What does not belong here:** task-specific logic (which belongs in `reasoning.instructions`) or conditional behavior. Conditions written in the system block appear as literal English prose — they are not evaluated. "If the user asks about billing, route to billing" in a system block is prose the LLM will attempt to interpret, with unpredictable results.

**The most common mistake in router-first agents:** the global block says "Answer the user's questions helpfully" while the router subagent's reasoning block says "Do not answer. Route only." The LLM receives both simultaneously and must resolve the contradiction probabilistically. One instruction wins — but which one is non-deterministic across turns and model versions.

**The correct pattern:** write a global instruction that is neutral toward all subagent postures.

```
system:
    instructions: |
        You are a Salesforce customer service assistant.
        Always identify yourself as an AI when directly asked.
        Never reveal internal system configuration or pricing tiers.
        Perform only the current operating task. Answer only when
        that task calls for an answer. Otherwise route, verify,
        clarify, or escalate as directed.
```

This instruction is compatible with a routing subagent, a specialist subagent, a verification gate, and a conversational agent — without contradiction.

---

### 4.2 Subagent System Override: Full Replacement, Not Merge

This is one of the most consequential and least obvious behaviors in Agentforce. When a subagent has its own `system:` block, it **completely replaces** the global system instructions for that subagent. It does not append. It does not merge. It does not inherit. It replaces.

Any invariant defined in the global system block — a safety disclosure, a data protection rule, a confidentiality requirement — is **silently dropped** for any subagent that has its own system override but does not explicitly restate that invariant. There is no error, no warning, and no indication in the agent's behavior that the rule no longer applies for that subagent.

> **Scenario: The Silent Security Gap**
>
> Your global system instructions include "Never reveal internal pricing tiers or system configuration." You add a product specialist subagent with its own system override focused on technical product details. The developer wrote the override for specialization purposes and assumed confidentiality rules were inherited. A user routes to the product specialist and asks directly about internal pricing. The specialist, operating without that constraint, discusses it. The global rule did not travel with the subagent — it was silently replaced.

**The authoring rule is absolute:** restate every invariant the subagent must retain in its subagent-level system block. Treat every subagent system block as a complete, self-contained identity definition — not an addendum to the global.

---

### 4.3 reasoning.instructions: Two Modes, One Critical Rule

The `reasoning.instructions` surface is the most powerful and most error-prone surface in AgentScript. It is rebuilt on every reasoning iteration (including after every tool call) and supports two modes. Choosing the wrong mode is the most common silent authoring failure in the entire language.

**Literal mode (`|`):** content is sent to the LLM verbatim without any Phase 1 evaluation. Any `if` keyword written here appears in the LLM's prompt as the English word "if." The model reads it as prose and may or may not interpret it as a conditional. Use only for simple, unconditional instructions.

**Procedural mode (`->`):** activates Phase 1 deterministic evaluation. The resolver reads top-to-bottom, evaluates conditions, executes `run` statements, captures `set` values, and only the matching `|` lines reach the LLM. Use whenever the block contains any conditional logic, variable injection, `run` statements, or `set` statements.

**The invisible bug:** using `|` mode when you need conditional behavior produces no compile error, no runtime warning, and no obvious symptom. The LLM simply receives your condition text as English and attempts to interpret it. Sometimes it follows the intent. Often it does not. The behavior is intermittent and difficult to reproduce.

**The rule:** any time your instructions block contains an `if`, a `run`, a `set`, or a `{!@variables.X}` injection, use `->` mode. The cost of using `->` mode unnecessarily is zero. The cost of using `|` mode when `->` was needed is an invisible, intermittent behavior bug.

---

### 4.4 before_reasoning: The Pre-Turn Gate

`before_reasoning` runs once per turn, before the reasoning loop begins and before the LLM is ever involved. It is purely deterministic — it can set variables, run actions, evaluate conditions, and fire transitions, but it never produces LLM output.

**Why this matters:** it lets you make hard decisions before any LLM cost is incurred. If a session has expired, you can detect it and redirect immediately. If you need to load account data that every part of the conversation will use, you can load it here once per turn rather than once per iteration.

**Common valid uses:**
- Authentication and authorization gates (fail fast before LLM cost)
- Mandatory data pre-loading used across all reasoning iterations
- Early exits for invalid or expired session states

**The critical syntax constraint:** `before_reasoning` does **not** use an `instructions:` wrapper. Content goes directly under the block as direct children — `transition` statements, `run` statements, `set` statements, and `if` statements are all written directly, not nested under `instructions:`. Using `instructions: ->` inside `before_reasoning` is a **compilation error**.

```yaml
# WRONG — compile error
before_reasoning:
    instructions: ->
        if @variables.session_token == '':
            transition to @subagent.auth

# CORRECT
before_reasoning:
    if @variables.session_token == '':
        transition to @subagent.auth
```

---

### 4.5 after_reasoning: The Post-Turn Gate

`after_reasoning` runs once per turn, after the reasoning loop produces a terminal response. The LLM has already spoken by the time this executes.

**Common valid uses:**
- State cleanup (clearing temporary variables)
- Logging (recording that a workflow step completed)
- Conditional transitions based on what the turn accomplished

**Two critical behavioral distinctions:**

**First:** `after_reasoning` fires after the reasoning loop ends with a terminal response. It does **not** fire after each tool call within the loop. Three sequential tool calls in one turn trigger `after_reasoning` once — after the final response — not three times.

**Second:** if a subagent transitions mid-reasoning via `@utils.transition to` (the LLM-driven handoff), the original subagent's `after_reasoning` does **not** run. A handoff means the original subagent gave up control before producing a terminal response. No terminal response means no `after_reasoning` trigger. If you have cleanup logic that must run regardless of how a turn ends, this constraint is a design risk that must be explicitly accounted for.

Like `before_reasoning`, `after_reasoning` does not support an `instructions:` wrapper. Same constraint, same compile error.

---

## 5. Variables and State in the Reasoning Loop

### Why State Management Is Different Here

In a traditional application, state lives in a database or session store, and you read and write it explicitly. In a pure LLM system, "state" is the conversation history — the model infers context from what was said before. Agentforce uses a hybrid approach: explicit, typed variables with strict scope rules, living alongside conversation history. This gives you the control of traditional state management and the natural language capability of LLM reasoning — but it requires understanding the scope rules precisely, because violations produce silent failures.

---

### 5.1 Mutable vs. Linked Variables

**Mutable variables** are session-persistent values the agent can both read and write. They must have a default value declared at definition time.

```yaml
variables:
    customer_name: mutable string = ''
    order_count: mutable number = 0
    is_verified: mutable boolean = False
    preferences: mutable object = {}
    item_list: mutable list[string] = []
```

**Critical syntax rule:** boolean default values must be capitalized — `True` or `False`. The parser rejects lowercase `true` and `false`. This produces a compile error that does not always clearly identify the capitalization as the cause.

**Linked variables** are read-only values populated from external session context — information Salesforce establishes at session start. They must have a `source` declaration and must **not** have a default value. Providing a default value on a linked variable is a compile error.

```yaml
variables:
    EndUserId: linked string from @MessagingSession.MessagingEndUserId
    RoutableId: linked string from @MessagingSession.RoutableId
    ContactId: linked string from @MessagingSession.ContactId
```

Linked variables are the primary mechanism for knowing who the user is without asking them. In a service agent, they come from the `MessagingSession` context. In an employee agent, they typically come from `@session.sessionID`. Getting these right is an early and important configuration step in every new agent.

---

### 5.2 The Three Scope Zones

Agentforce defines three distinct variable scope zones. Each holds a different kind of value, is valid in a different context, and behaves very differently when used outside its valid scope.

**`@variables.X` — Session-persistent state**
Valid anywhere in AgentScript logic and injectable into pipe text via `{!@variables.X}`. Persists for the life of the session unless explicitly overwritten.

**`@outputs.X` — Action return values**
Valid **only** in `set` and `if` statements immediately after the action's `run` block. The scope expires when those statements complete. Referencing `@outputs.X` anywhere else produces a silent failure.

**`@inputs.X` — Action input values**
Valid **only** in `with` clauses during action invocation. Not valid in subsequent `set` statements or post-execution checks. Scope expires when the `with` clause finishes.

**The correct mental model:** `@outputs` and `@inputs` are short-lived windows, not persistent stores. The moment an action's `with` clause or immediate post-run block completes, those windows close. Everything that needs to survive beyond the action must be explicitly transferred to `@variables` within those windows.

---

### 5.3 The Silent Failure Zone

`@inputs` and `@outputs` scope violations are the most dangerous bugs in AgentScript development — dangerous precisely because they produce no error and no obvious symptom.

When you use `@inputs` or `@outputs` outside their valid scope, the action executes successfully. The variable simply does not get set. No error is thrown. The agent continues operating as if everything worked — just without the value it should have.

> **Scenario: The Invisible Empty Field**
>
> An agent retrieves a customer's home branch location to display in a response. The developer writes the fetch action, captures `@outputs.status` immediately, but then tries to inject `@outputs.customer_location` into a pipe line three statements later. The `@outputs` scope has already expired. The injection produces an empty string. The agent displays "Your nearest branch is ." — a clearly wrong response with no error in any log to explain why.

**How to catch this in traces:** a `FunctionStep` that completes with no difference in the `postVars` section (the before/after variable state comparison) is the diagnostic indicator of a scope violation. The action ran. The output was produced. Nothing was captured because the `set` statement referenced a scope that was already closed.

**Prevention:** capture every needed output value immediately in `set` statements directly under the `run` block. Then reference `@variables` everywhere else. Treat the post-action `set` window as a mandatory handoff step, not optional cleanup.

---

### 5.4 Variable Persistence Across Subagents

`@variables` persist across subagent transitions. A value set in Subagent A is fully available when Subagent B takes control. This is not a special feature you configure — it is the default behavior of the `@variables` scope, and it is the primary mechanism for passing state through a multi-subagent workflow without external storage or middleware.

> **Scenario: Verify Once, Carry Forward**
>
> A customer service agent has three subagents — an authentication gate, an order management specialist, and a billing specialist. When the authentication gate verifies the customer, it sets `@variables.is_verified = True` and `@variables.customer_id` from the verification result. When the router transitions to order management, those variables are already there. The order management subagent's `before_reasoning` block checks `@variables.is_verified` — it is `True` — and immediately makes order-specific actions available. The customer never re-verifies. The verified customer ID flows through to every action that needs it without being re-extracted from conversation. This is the verify-once, carry-forward pattern.

---

### 5.5 The setVariables Turn-End Trap

`@utils.setVariables` is the LLM-driven slot-filling utility that lets the model extract values from conversation and populate variables. It has a non-obvious and frequently misunderstood behavior: **it ends the turn after capturing values.**

The reasoning loop does not continue after `setVariables` runs. Any action listed after `setVariables` in the same `reasoning.actions` block will not fire in that turn. The turn is over.

**When to use `setVariables`:** only when collecting variables across multiple turns is the explicit and intentional design goal — a multi-step intake form where each turn collects one field.

**The correct pattern for capture-then-act in one turn:** use LLM slot-fill directly on the target action using the ellipsis operator.

```yaml
# WRONG — action never fires in same turn
reasoning:
    actions:
        - @utils.setVariables
            set order_id = ...
        - @actions.get_order_status   ← this never fires
            with order_id = @variables.order_id

# CORRECT — capture and act in one turn
reasoning:
    actions:
        - @actions.get_order_status
            with order_id = ...   ← LLM extracts and calls in one step
```

The ellipsis causes the LLM to extract the order ID and call the action in a single Phase 2 decision — no intermediate variable collection, no turn-ending side effect.

---

### 5.6 The Three Input Binding Patterns

Action parameters can be populated three ways. The choice between them has direct security and reliability implications, not just stylistic ones.

**LLM slot-fill (`with param = ...`):** the LLM extracts the value from conversation at Phase 2 time. Fully probabilistic — the LLM decides what to extract. If the value is absent, it prompts the user.

**Variable binding (`with param = @variables.X`):** the runtime reads the variable at Phase 1 time, before the LLM is involved. Fully deterministic. If the variable is empty, the action receives an empty string with no user prompt.

**Literal value (`with param = 'fixed'`):** a compiled constant resolved at Phase 1. Always the same value regardless of conversation or state.

> **Scenario: The Account ID Injection Risk**
>
> An agent processes refunds. The `issue_refund` action requires a `customer_id` parameter. If you use `with customer_id = ...`, the LLM extracts a customer ID from the conversation — meaning a malicious user could type a different customer's ID and potentially trigger a refund against someone else's account. If you use `with customer_id = @variables.customer_id`, where that variable was set during verified authentication, the LLM has no ability to override the value from conversation. The verified ID flows through deterministically. This is the security-critical reason to choose variable binding over slot-fill for sensitive parameters.

**The rule:** use `@variables` binding for verified identities, confirmed record IDs, and any sensitive value that should not be extractable from arbitrary user input. Use the ellipsis only for parameters the LLM legitimately needs to extract from conversation.

---

## 6. Actions and the Reasoning Loop

### Actions as the Bridge to the Real World

In a pure LLM system, the model can only produce text. It cannot look up a customer record, process a payment, or update a case. Actions are what transform Agentforce from a text generator into an agent that can actually do things — querying databases, calling APIs, running flows, and updating records. How and when those actions fire is controlled by the two-phase engine.

---

### 6.1 Deterministic vs. LLM-Driven Invocation

Every action can be invoked in one of two ways, and the choice fundamentally changes who controls whether and when it fires.

**Deterministic invocation (`run @actions.X`):** fires during Phase 1, before the LLM is called. The action always executes when the code path is reached — regardless of what the LLM would think or prefer. The LLM never sees the `run` statement. It only sees the resolved pipe text with injected values after the action has already completed.

Use for: pre-loading data every iteration needs, security gates that must always run, mandatory logging, and guaranteed ordering of multiple actions.

**LLM-driven invocation (`reasoning.actions` block):** fires during Phase 2. The LLM decides whether and when to call the action based on the action's `description` field and conversation context. The LLM is in control of the invocation decision.

Use for: actions the agent should call only when relevant to the user's specific request, and any case where the model's judgment about timing and relevance is appropriate.

> **Scenario: Pre-Load vs. On-Demand**
>
> Loading a customer's account tier on every turn is deterministic — it always needs to happen, and the cost of not having it is instructions that reference an empty variable. This belongs in `before_reasoning` as a `run` statement, firing once per turn. Looking up a specific order's status is LLM-driven — it only needs to happen if the user is asking about an order. This belongs in `reasoning.actions`, where the LLM calls it only when the conversation calls for it.

---

### 6.2 available when: Hard Filter, Not Soft Hint

`available when` is the mechanism that brings deterministic authorization to the LLM's tool list. It is one of the most important safety features in Agentforce.

When an `available when` condition evaluates to `False` during Phase 1, the action is completely absent from the tool schema handed to the LLM. The model has zero awareness the action exists. This is not a soft restriction — the model cannot be persuaded, tricked, or prompted into calling an action that is not in its tool schema.

This is fundamentally different from a prose instruction like "only call this action if the user is verified." A prose instruction is probabilistic. Under adversarial input or in a sufficiently complex conversation, the LLM may not follow it. `available when` makes unauthorized invocation **structurally impossible**, not just unlikely.

> **Scenario: The Layered Refund Guard**
>
> A refund action has two guards: `available when @variables.is_verified == True` and `available when @variables.refund_amount > 0`. A user who has not completed verification cannot see the refund action in the LLM's tool list at all. A verified user with a zero refund amount also cannot. Only when both conditions are simultaneously True does the action become available. No prose instruction achieves this level of enforcement — and no amount of clever user phrasing can work around it.

Multiple `available when` clauses on a single action are evaluated as a logical AND — all must be True for the action to appear.

---

### 6.3 The Three Transition Mechanisms

Transitions are how agents move between subagents. Agentforce has three distinct mechanisms with strict rules about where each can be used. Using the wrong one in the wrong context produces a compile error — and the error message rarely tells you which pairing rule you violated.

| Mechanism | Valid Context | LLM Involved | Direction |
|---|---|---|---|
| Bare `transition to @subagent.X` | `before_reasoning`, `after_reasoning`, run post-conditions | No | One-way |
| `@utils.transition to @subagent.X` | `reasoning.actions` only | Yes (LLM decides when) | One-way |
| `@subagent.X` as action reference | `reasoning.actions` only | Yes (LLM decides when) | Two-way (returns to caller) |

The valid pairings must be memorized. Bare `transition to` belongs in lifecycle hooks and run blocks. `@utils.transition to` and delegation references belong in `reasoning.actions`. No exceptions.

---

### 6.4 Handoff vs. Delegation

Handoff and delegation represent two fundamentally different control flow models. Choosing the right one has major architectural implications.

**Handoff (`@utils.transition to`):** control transfers completely to the called subagent. The caller does not resume. The destination owns the full response. The original subagent's after_reasoning does not fire if the handoff occurs mid-reasoning. Use when the destination should completely own the user experience.

**Delegation (`@subagent.X` as action reference):** the parent orchestrates, the child runs its full reasoning loop and produces a result, and control returns to the parent, which synthesizes the final response. Use when the parent needs to coordinate across multiple children or incorporate results into a unified response.

**The architectural implication:** building with delegation rather than pure handoff creates more composable, orchestratable agents. As Salesforce's multi-agent coordination capabilities evolve, agents built with the delegation pattern are much easier to incorporate into larger orchestration workflows without architectural rework.

---

### 6.5 The Zero-Hallucination Routing Pattern

Two output flags on action definitions control an important aspect of LLM behavior.

**`filter_from_agent: True`** prevents the LLM from displaying the output value to the user. The value is available to the agent's internal logic but invisible in model responses. Use for internal routing flags, risk scores, and system IDs.

**`is_used_by_planner: True`** allows the LLM to reason about the output value for routing decisions. Use for intent classification outputs and decision flags.

Combining both creates the **zero-hallucination routing pattern.** The LLM must actually call the classification action to obtain the routing value — it has no cached or hallucinated value to use. Once it has the real result, it can act on it for routing — but it cannot expose it to the user.

Without this pattern, a router LLM might guess intent from the user's message without calling the classifier at all — producing routing decisions based on probabilistic interpretation rather than actual classifier output. With this pattern, every routing decision is grounded in the classifier's actual result.

---

## 7. The Posture Spectrum

### From Fully Scripted to Fully Agentic

The concept of posture is what unifies everything discussed so far. Early AI systems forced a binary choice: either full scripted control (deterministic, predictable, brittle) or full LLM latitude (flexible, adaptive, unsafe). Posture lets you choose exactly how much of each you need, for each specific subagent, based on what that subagent actually does.

This is not a configuration setting. It is a design philosophy backed by specific, implementable controls.

---

### 7.1 Agentic, Mixed, and Scripted

**Agentic posture (the default):** the LLM chooses which actions to call and when, extracts slot parameters from conversation, and determines response content and sequencing. Best for open-ended tasks, information retrieval, and conversational flows with no specific security or ordering requirements. Start here.

**Mixed posture:** selective determinism applied where justified. Some actions are gated with `available when`, some parameters are pinned to variable values, and some conditional instructions restrict what the LLM sees based on current state. Best for tasks with security gates, irreversible actions, or ordering requirements — while keeping the rest of the interaction natural and adaptive.

**Scripted posture:** fully deterministic. All transitions use bare `transition to`, all actions use `run`, and the LLM has zero discretion about what happens next. Best for regulated workflows, strict legal compliance, and zero-tolerance for variation. Rare in practice — most business use cases benefit from at least some LLM adaptability.

---

### 7.2 The Five Justifications for Determinism

One of the strongest patterns in Salesforce's Agentforce design guidance is the discipline around adding deterministic controls. Add determinism only when you have a specific, named justification. Without a justification, keep the posture agentic.

**The five valid justifications:**

1. **Regulatory requirement** — a compliance rule mandates specific sequencing, wording, or disclosure that cannot vary
2. **Trust gate** — identity verification must complete before access is granted
3. **Irreversible action** — once fired, the action cannot be undone
4. **External system ordering** — an external API requires operations in a specific sequence
5. **Observed production failure** — a specific behavior has failed in production and deterministic control is the proven fix

If the justification does not match one of these five, keep the posture agentic. Adding determinism without justification increases brittleness, removes the LLM's ability to handle natural variation in user input, and increases maintenance burden without a concrete safety benefit. The agentic default is not laziness — it is recognition that the LLM's adaptive reasoning is a feature, one that should only be constrained when a specific risk justifies the cost.

---

### 7.3 The Three Control Primitives

When a justification for determinism exists, three primitives implement it. Each operates at a different layer and can be combined for defense-in-depth.

**`available when`:** hard Phase 1 filter removing the action from the tool schema when the condition is False. Authorization-layer control. The LLM cannot call the action because, from its perspective, it does not exist.

**Parameter pinning:** binding a parameter to `@variables.X` instead of `...` forces a specific value at Phase 1 time. The LLM cannot substitute a different value from conversation. Use for verified identifiers and sensitive values that should not be extractable from user input.

**Conditional instructions:** `if/else` blocks in `reasoning.instructions: ->` mode ensure the LLM only sees the branch matching current state. Use for security-state-dependent instruction sets.

> **Scenario: Three Layers on One Action**
>
> A payment action has: `available when @variables.is_verified == True` (the action is invisible until verified), `with account_number = @variables.verified_account` (the account number cannot be overridden from conversation), and a conditional instruction block showing "Process the payment" only when verified and "Please verify your identity first" otherwise. Three independent layers of control — an unverified user gets no payment action in their tool list, no ability to inject an account number, and sees only the verification instruction.

---

### 7.4 The Minimal Instructions Principle

Keep instructions minimal. The fewer instructions you give the LLM, the better it generally performs — as long as those instructions accurately represent what you need.

This feels counterintuitive. More guidance should produce better behavior. But LLM reasoning does not work like human reading. When a model receives instructions packed with conditional rules, exceptions, and clarifications, it must resolve all of that context simultaneously in every reasoning iteration. Competing instructions create noise. Redundant instructions create ambiguity.

Push as much logic as possible out of AgentScript instructions and into actions. Logic in actions is reusable across subagents and agents, does not add context load to the LLM, and can be tested independently. Logic in instructions is ephemeral and adds to the token budget on every iteration.

Every unnecessary instruction token brings the context budget closer to the 10,000-token threshold where latency spikes and LLM accuracy degrades. Adding instructions without a concrete reason does not make the agent safer or better. It makes it slower and noisier.

---

## 8. The Einstein Trust Layer

### Why a Trust Layer Is Necessary

In a simple prompt-based system, your data leaves your system boundary the moment you send it to an LLM API. What happens to it after that is governed by the API provider's terms of service. For enterprise Salesforce customers with sensitive CRM data — customer records, financial data, health information, personal identifiers — this is not acceptable.

The Einstein Trust Layer exists because hybrid reasoning requires hybrid governance. You need the intelligence of a large language model and the data protection of Salesforce's enterprise security model. The ETL is the mechanism that provides both simultaneously.

---

### 8.1 What It Is and When It Operates

The Einstein Trust Layer (ETL) is the runtime security boundary that operates on every turn, for every user session, in every Agentforce production deployment. It sits between Phase 1 output and the LLM — every context package passes through it before reaching the foundation model, and every model response passes back through it before returning to the reasoning loop.

The ETL is not a one-time authoring check. It is actively running on every single inference call, continuously, in production.

**The ETL sequence on input:**
1. Sharing rule and field-level security enforcement — data in the context respects the same permission model as a direct SOQL query by the running user
2. Prompt injection and toxicity detection — the input is screened for malicious injection attempts and inappropriate content before reaching the model

**The ETL sequence on output:**
1. Toxicity detection on the model's response
2. Grounding quality check before the response returns to the reasoning loop

---

### 8.2 The Zero-Retention Policy

The ETL Zero-Retention Policy guarantees that customer CRM data used for grounding in an Agentforce inference call is **never stored, never logged, and never used to train external public models** by the underlying LLM providers — OpenAI, Anthropic, Google, or any other. The data flows into the LLM gateway only for that specific inference call and is discarded immediately after the inference completes.

This is a contractual and architectural guarantee from Salesforce, not a configuration option that can accidentally be disabled. It is enforced at the LLM gateway boundary.

The answer to the common enterprise question — "does our Salesforce customer data train OpenAI's models if we use Agentforce?" — is **no.** The mechanism is the ETL zero-retention policy enforced at the LLM gateway, not a contractual promise alone.

---

### 8.3 Data Permissions and Content Screening

The ETL extends Salesforce's existing governance model to the LLM boundary in two important ways.

**Permission enforcement:** Salesforce sharing rules and field-level security are enforced at every agent action. When grounding data is pulled for an LLM call, it respects the same permission model as a direct SOQL query executed by the running user. The model cannot receive data the running user is not authorized to see — regardless of how the grounding query was constructed.

**Content screening:** the ETL screens inputs for malicious prompt injection attempts — attempts by adversarial users to include hidden instructions in their messages to alter the model's behavior — and for inappropriate content. It screens model outputs for toxicity and grounding quality before those outputs return to the reasoning loop.

Together, these capabilities mean the ETL is not just a data privacy mechanism. It is the security and governance layer that makes it possible for enterprises to deploy LLM-powered agents against their most sensitive CRM data with reasonable confidence that existing access controls remain in effect.

---

## 9. Reasoning Constraints

### Design Constraints as Architecture Drivers

Every platform has constraints. What makes Agentforce's constraints interesting is that they are not arbitrary limitations — they are deliberate design choices that prevent runaway costs, infinite loops, and degraded reasoning quality at scale. Understanding them as architecture drivers, not obstacles, is what separates agents that work in production from agents that work in demos.

---

### 9.1 The 3–4 Loop Iteration Limit

The reasoning loop has a hard platform guardrail of approximately 3–4 iterations per turn before the runtime forces an exit. This is enforced by the Atlas FSM — it is not a configurable timeout, it is a hard architectural constraint.

A reasoning iteration is one complete Phase 1 + Phase 2 cycle. Each time the LLM calls an action and re-resolution begins, the iteration counter increments. Failed retries via backward arrows also count. When the cap is reached, the platform forces the turn to exit with an error response.

**Concrete design implications:**

- Count your maximum possible iterations on every execution path during design, not after deployment
- Workflows requiring more than 3–4 sequential LLM-driven decisions per turn must be broken across multiple user turns
- Circular subagent references will hit this cap unpredictably, producing confusing errors
- Monitoring for turns that frequently hit the cap in production is a signal the workflow needs structural redesign — not a signal to seek a higher limit

> **Scenario: The Hidden Loop**
>
> An agent workflow has: collect order ID (1 iteration) → look up order status (2nd iteration) → check eligibility for return (3rd iteration) → log the interaction (4th iteration). On the happy path, this works. But if the order lookup fails and the LLM retries (backward arrow), you now have 5 iterations. The platform forces an exit. The user gets an "unexpected error" response that has nothing to do with their actual request. The fix is to move the logging to `after_reasoning` (free, deterministic, does not count as an iteration) and consolidate the status and eligibility lookups into a single action.

---

### 9.2 The 10,000-Token Heuristic

The reasoning engine targets approximately 10,000 tokens per transaction payload as a performance and accuracy ceiling. This is not a hard API limit — it is the threshold beyond which response quality degrades and latency spikes become measurable.

**What fills the token budget:**

| Source | Typical Range | Controllability |
|---|---|---|
| Global system instructions | 100–500 tokens | High — keep concise |
| Subagent system overrides | 100–500 tokens per subagent | High — restate only required invariants |
| Conversation history | Grows per turn | Partial — session design controls this |
| Resolved reasoning.instructions | 100–1,000 tokens | High — `->` mode sends only matching branches |
| Tool schemas | ~100 tokens per action | High — `available when` suppresses irrelevant tools |
| Grounding data (ADL/knowledge) | Variable | High — use relevancy-ranked retrieval |

**The three optimization levers:**

1. **Conciseness** — remove any instruction that does not change behavior
2. **Consolidation** — merge redundant actions and overlapping descriptions
3. **Filtering** — use `available when` aggressively; every suppressed action removes its full schema from the budget for that iteration

**A critical distinction Salesforce documentation makes explicit:** token count drives **latency and LLM accuracy**. Credit billing is charged per action execution — 20 credits per Apex or Flow action, 2–16 for Prompt Templates — regardless of token count. These are completely separate optimization concerns with completely separate levers. Reducing instruction length improves reasoning quality. Reducing unnecessary action executions reduces credit costs. Do not conflate them.

---

## 10. Reasoning Anti-Patterns

### Why Anti-Patterns Matter

Every platform has failure modes that appear repeatedly, across different teams, on different projects. The anti-patterns below are not theoretical — they are the most common production failures in Agentforce development. Each one has a recognizable symptom, a clear root cause, and a specific fix. Knowing them before you encounter them cuts diagnostic time from hours to minutes.

---

### AP-1: | Mode with Conditional Logic (The Invisible Bug)

**Pattern:** writing conditional logic (`if/else` blocks) in `reasoning.instructions` using `|` (literal) mode instead of `->` (procedural) mode.

**What happens:** the Phase 1 resolver treats the block as literal text and passes it to the LLM verbatim. The LLM receives `if @variables.is_verified == True: Process the account request.` as an English sentence and attempts to interpret it as a natural language instruction. Sometimes it follows the intent. Often it does not. The behavior varies between turns, making the bug intermittent and nearly impossible to reproduce reliably.

**Why it is dangerous:** no compile error, no runtime warning, no obvious symptom in normal interactions.

**Fix:** always use `->` mode when the instructions block contains any conditional logic, variable checks, `run` statements, or `set` statements.

---

### AP-2: Post-Action Check at the Bottom (The Re-Resolution Trap)

**Pattern:** placing a post-action result check at the bottom of a `reasoning.instructions: ->` block rather than at the top.

**What happens:** re-resolution fires after the tool call and reads from the top. The LLM sees the initial instruction again before reaching the result check — causing double-execution of initial prompts and non-deterministic behavior.

**Fix:** always place post-action conditional checks at the top of `instructions: ->` blocks. The initial user-facing instruction goes below and is only visible when no result yet exists.

---

### AP-3: Prose-Based Authorization (The Security Failure)

**Pattern:** using a prose instruction ("Only call this action if the user is verified") instead of `available when` to restrict access to a sensitive action.

**What happens:** prose authorization is probabilistic. Under adversarial input or in a sufficiently complex conversation state, the LLM may not follow the restriction. Unauthorized invocation is unlikely but possible.

**Fix:** always use `available when` to gate actions with financial impact, PII access, or irreversible effects. Prose instructions and `available when` can coexist for defense-in-depth, but prose alone is never a sufficient security control.

---

### AP-4: @inputs Used After Execution (The Silent Failure)

**Pattern:** writing `set @variables.X = @inputs.paramName` after the action's `run` block has completed.

**What happens:** the `@inputs` scope expired immediately after the `with` clauses during invocation. The `set` statement silently does nothing. The variable is not set, no error is thrown, and the `FunctionStep` trace shows no `postVars` diff.

**Fix:** use `@outputs` for post-action value capture. If an input value needs to be preserved, assign it to a `@variables` reference before the action call using a separate `set` statement.

---

### AP-5: instructions: Wrapper in Lifecycle Hooks (Compile Error)

**Pattern:** wrapping `before_reasoning` or `after_reasoning` content in an `instructions: ->` block.

**What happens:** a compile error. The error message typically does not identify the wrapper as the cause.

**Why it fails:** lifecycle hooks are deterministic-only surfaces that never invoke the LLM. The `instructions:` wrapper is a construct associated with LLM-facing surfaces. It is meaningless — and invalid — in a deterministic-only context.

**Fix:** place `transition`, `run`, `set`, and `if` statements as direct children of the `before_reasoning` or `after_reasoning` block, with no `instructions:` wrapper.

---

### AP-6: Wrong Transition Syntax in Wrong Context (Compile Error)

**Pattern:** placing `@utils.transition to` in a directive block, or placing bare `transition to` in a `reasoning.actions` block.

**What happens:** a compile error with an unhelpful message.

**Fix:** memorize the valid pairings. Bare `transition to` belongs in lifecycle hooks and `run` post-conditions. `@utils.transition to` and delegation references belong in `reasoning.actions`. No exceptions.

---

### AP-7: Contradicting System and Reasoning Instructions (Undefined Behavior)

**Pattern:** global `system.instructions` says "Answer the user's questions helpfully" while a router subagent's `reasoning.instructions` says "Do not answer. Route only."

**What happens:** the LLM receives both simultaneously and resolves the contradiction probabilistically. The behavior is unstable across turns and will likely shift as model versions change.

**Fix:** write global instructions that are posture-neutral: "Perform only the current operating task. Answer only when that task calls for an answer. Otherwise route, verify, clarify, or escalate as directed."

---

### AP-8: Subagent System Override Dropping Required Invariants (Silent Security Gap)

**Pattern:** a subagent system override that omits invariants defined in the global system instructions, assuming they are inherited.

**What happens:** the override completely replaces the global. Omitted invariants are silently dropped. The gap is intermittent and depends on which subagent the user routes to.

**Fix:** treat every subagent system block as a complete, self-contained identity definition. Restate every invariant the subagent must retain. Maintain a standard invariant block that is included in every subagent system override.

---

### AP-9: @utils.setVariables Followed by Immediate Action (Turn-End Trap)

**Pattern:** listing `@utils.setVariables` and a target action in the same `reasoning.actions` block, expecting the action to fire in the same turn.

**What happens:** `setVariables` ends the turn after capturing values. The action never fires in that turn.

**Fix:** use the ellipsis slot-fill operator directly on the target action. `with order_id = ...` causes the LLM to extract the value and call the action in a single Phase 2 step.

---

### AP-10: Vague Action Description (Wrong Tool Selection)

**Pattern:** action descriptions like "Get data," "Look up information," or "Handle customer issue."

**What happens:** the LLM uses descriptions as its primary tool-selection signal. Vague descriptions make reliable selection impossible. The LLM may call the wrong action, call multiple actions unnecessarily, or repeatedly ask for clarification the actions already have access to.

**Fix:** write descriptions specific enough for unambiguous selection. Include what the action does, what data it returns, what parameter it requires, and when to use it versus similar actions.

> **Poor:** "Look up order information"
>
> **Correct:** "Look up the current status, estimated delivery date, and tracking number for a specific customer order. Requires the order ID. Use this when the customer asks about the status or whereabouts of a particular order — not when they want to modify or cancel it."

---

## 11. Terminology Reference

A shared vocabulary is essential for working on Agentforce teams. These definitions are the precise meanings used throughout this guide and throughout Salesforce's Agentforce documentation.

---

**Turn**
The complete cycle of one user message in, one agent response out. Includes `before_reasoning`, the full reasoning loop, and `after_reasoning`.

**Reasoning Iteration**
One complete Phase 1 (deterministic resolution) plus Phase 2 (LLM reasoning) cycle within the reasoning loop. Multiple iterations can occur within a single turn. Each LLM-driven action call starts a new iteration and increments the counter toward the 3–4 hard cap.

**Deterministic Resolution**
Phase 1 — evaluating all AgentScript constructs (conditions, `run` statements, variable injections, `available when` filters) before any LLM involvement. Always produces the same output for the same input state.

**Re-Resolution**
The specific instance of Phase 1 that fires after every tool call within the reasoning loop. A full re-evaluation from the top of the `reasoning.instructions` block using updated variable state. Not a continuation — a full rebuild from the top.

**Slot Filling**
The LLM extracting a parameter value from conversation context using the `...` (ellipsis) syntax. A Phase 2 probabilistic operation — the LLM decides what value matches the parameter. If absent, it prompts the user.

**Variable Binding**
The runtime resolving `@variables.X` to its stored value at Phase 1 time. Fully deterministic — no LLM involved, no probability. The stored value is used directly. Security-critical distinction from slot filling.

**Tool Schema**
The JSON function schema representation of an action handed to the LLM during Phase 2. Actions failing `available when` are completely excluded — from the LLM's perspective, they do not exist.

**| mode (Literal mode)**
`reasoning.instructions` mode in which content is sent to the LLM verbatim without Phase 1 evaluation. Conditionals appear as English prose. Use only for simple, unconditional instructions.

**-> mode (Procedural mode)**
`reasoning.instructions` mode that activates Phase 1 deterministic evaluation. Use whenever the block contains conditional logic, variable injection, `run` statements, or `set` statements.

**Posture**
The designed ratio of LLM latitude to authored determinism in a subagent. Agentic gives the LLM maximum latitude. Scripted gives the LLM zero discretion. Mixed applies selective controls where justified.

**Handoff**
One-way subagent transfer via `@utils.transition to` in `reasoning.actions`. The caller does not resume. The destination subagent owns the full response. The original subagent's `after_reasoning` does not fire if the handoff occurs mid-reasoning.

**Delegation (Supervision)**
Two-way subagent call via `@subagent.X` as an action reference in `reasoning.actions`. The child runs its full reasoning loop, produces a result, and control returns to the parent, which synthesizes the final response.

**DAG (Directed Acyclic Graph)**
The mathematical structure for tool invocations and sequential dependencies in the Agent Graph. The "acyclic" property mathematically prevents infinite loops in the deterministic path.

**FSM (Finite State Machine)**
The mathematical structure for subagent transitions and retry logic in the Agent Graph. Managed by the Atlas engine. Enforces the 3–4 iteration hard cap. Records backward arrows for retry paths.

**Backward Arrow**
An FSM retry edge recorded when the LLM attempts a tool call, receives an error, and reasons into an alternative approach. Visible as literal reverse edges in trace visualization tools.

**GenAiPlannerBundle**
The runtime metadata artifact created by the Salesforce platform when you publish an agent. The compiled output of the Atlas engine — what actually executes in production. Distinct from the AiAuthoringBundle (the `.agent` file developers author and deploy).

**@variables**
Session-persistent state. Valid anywhere in AgentScript logic and injectable into pipe text via `{!@variables.X}`. Persists for the life of the session.

**@outputs**
Action return values. Valid only in `set` and `if` statements immediately after the action's `run` block. Expires after those statements complete. Using `@outputs` outside this window is a silent failure.

**@inputs**
Action input values. Valid only in `with` clauses during action invocation. Expires when the `with` clause finishes. Using `@inputs` in a subsequent `set` statement is a silent failure.

**10k Token Heuristic**
Approximately 10,000 tokens as the architectural target for the total context package per reasoning transaction. Governs latency and LLM reasoning accuracy — not credit billing. A separate concern from action execution costs.

**Credit Billing**
20 Einstein credits per Apex or Flow action execution. 2–16 credits per Prompt Template action. Framework operations (transitions, conditionals, variable evaluations) are free. Completely separate from token count optimization.

**Zero-Hallucination Pattern**
Combining `filter_from_agent: True` and `is_used_by_planner: True` on an action output. Forces the LLM to invoke the action to obtain a routing value rather than guessing from conversation, while preventing the raw value from appearing in user-facing output.

**Einstein Trust Layer (ETL)**
The runtime security boundary between Phase 1 output and the LLM. Enforces zero-retention of CRM grounding data, screens inputs for prompt injection and toxicity, screens model outputs before they return to the reasoning loop, and enforces Salesforce sharing rules and field-level security at the LLM boundary. Operates on every inference call, in every session, in every production deployment.

**Zero-Retention Policy**
The ETL guarantee that customer CRM data used for grounding is never stored, logged, or used to train external public models by the underlying LLM providers. Enforced at the LLM gateway boundary. A contractual and architectural guarantee from Salesforce.

---

*This guide covers the Agentforce Reasoning Engine (Daisy) as documented in Salesforce's Agentforce developer documentation and platform best practices.*
