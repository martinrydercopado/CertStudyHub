# Inside the Atlas Reasoning Engine: The Complete Agentforce Guide

**How Agentforce Thinks — Turn-by-Turn Mechanics, Determinism, and LLM Probabilism**

*Audience: Success Architects | Version 4 | August 2026*

---

## Table of Contents
1. [The Mental Model](#1-the-mental-model)
   - 1.1 [What the Atlas Reasoning Engine Is](#11-what-the-atlas-reasoning-engine-is)
   - 1.2 [Why Hybrid Reasoning Exists: The Previous Model's Limits](#12-why-hybrid-reasoning-exists-the-previous-models-limits)
   - 1.3 [The Fundamental Split](#13-the-fundamental-split)
   - 1.4 [Agentforce Builder: Where You Author](#14-agentforce-builder-where-you-author)
   - 1.5 [The Atlas Engine and the Agent Graph](#15-the-atlas-engine-and-the-agent-graph)
2. [The Two-Phase Execution Engine](#2-the-two-phase-execution-engine)
   - 2.1 [Phase 1: Deterministic Resolution](#21-phase-1-deterministic-resolution)
   - 2.2 [Phase 2: LLM Reasoning](#22-phase-2-llm-reasoning)
   - 2.3 [When the LLM Is Actually Triggered](#23-when-the-llm-is-actually-triggered)
   - 2.4 [Why This Split Is the Primary Diagnostic Tool](#24-why-this-split-is-the-primary-diagnostic-tool)
   - 2.5 [Global Runtime Configuration: config.runtime](#25-global-runtime-configuration-configruntime)
3. [The Complete Turn Anatomy](#3-the-complete-turn-anatomy)
   - 3.1 [The Re-Resolution Loop: The Inner Heartbeat](#31-the-re-resolution-loop-the-inner-heartbeat)
   - 3.2 [LLM Recovery After Failed Actions](#32-llm-recovery-after-failed-actions)
   - 3.3 [What the LLM Does NOT See](#33-what-the-llm-does-not-see)
4. [The Instruction Surfaces](#4-the-instruction-surfaces)
   - 4.1 [Global System Instructions: The Persona Layer](#41-global-system-instructions-the-persona-layer)
   - 4.2 [Subagent System Override: Full Replacement, Not Merge](#42-subagent-system-override-full-replacement-not-merge)
   - 4.3 [reasoning.instructions: Two Modes, One Critical Rule](#43-reasoninginstructions-two-modes-one-critical-rule)
   - 4.4 [before_reasoning: The Pre-Parse, Pre-Classifier Gate](#44-before_reasoning-the-pre-parse-pre-classifier-gate)
   - 4.5 [after_reasoning: The Post-Turn Gate](#45-after_reasoning-the-post-turn-gate)
   - 4.5.1 [after_response: The Connected Subagent Return Surface](#451-after_response-the-connected-subagent-return-surface)
5. [Variables and State in the Reasoning Loop](#5-variables-and-state-in-the-reasoning-loop)
   - 5.1 [Mutable vs. Linked Variables](#51-mutable-vs-linked-variables)
   - 5.2 [The Four Scope Zones](#52-the-four-scope-zones)
   - 5.3 [The Silent Failure Zone](#53-the-silent-failure-zone)
   - 5.4 [Variable Persistence Across Subagents](#54-variable-persistence-across-subagents)
   - 5.5 [The setVariables Slot-Fill Utility](#55-the-setvariables-slot-fill-utility)
   - 5.5.1 [ask for: Structured Variable Capture (Pilot)](#551-ask-for-structured-variable-capture-pilot)
   - 5.6 [The Three Input Binding Patterns](#56-the-three-input-binding-patterns)
6. [Actions and the Reasoning Loop](#6-actions-and-the-reasoning-loop)
   - 6.1 [Deterministic vs. LLM-Driven Invocation](#61-deterministic-vs-llm-driven-invocation)
   - 6.2 [The Four Action Chaining Patterns](#62-the-four-action-chaining-patterns)
   - 6.3 [available when: Hard Filter, Not Soft Hint](#63-available-when-hard-filter-not-soft-hint)
   - 6.4 [The Four Transition Mechanisms](#64-the-four-transition-mechanisms)
   - 6.5 [Handoff vs. Delegation](#65-handoff-vs-delegation)
   - 6.6 [The Zero-Hallucination Routing Pattern](#66-the-zero-hallucination-routing-pattern)
   - 6.7 [Inline Skills (Pilot)](#67-inline-skills-pilot)
7. [The start_agent Subagent and Turn Restart Behavior](#7-the-start_agent-subagent-and-turn-restart-behavior)
   - 7.5 [Goal-Based Agents: Beyond the Turn Model (Pilot)](#75-goal-based-agents-beyond-the-turn-model-pilot)
8. [The EinsteinHyperClassifier](#8-the-einsteinhyperclassifier)
   - 8.1 [What HyperClassifier Is](#81-what-hyperclassifier-is)
   - 8.2 [How It Works: Single-Token Prediction](#82-how-it-works-single-token-prediction)
   - 8.3 [HyperClassifier Limitations](#83-hyperclassifier-limitations)
   - 8.4 [The HyperClassifier and before_reasoning Paradox](#84-the-hyperclassifier-and-before_reasoning-paradox)
9. [The Posture Spectrum](#9-the-posture-spectrum)
   - 9.1 [Agentic, Mixed, and Scripted](#91-agentic-mixed-and-scripted)
   - 9.2 [The Five Justifications for Determinism](#92-the-five-justifications-for-determinism)
   - 9.3 [The Three Control Primitives](#93-the-three-control-primitives)
   - 9.4 [The Minimal Instructions Principle](#94-the-minimal-instructions-principle)
10. [The Einstein Trust Layer](#10-the-einstein-trust-layer)
    - 10.1 [What It Is and When It Operates](#101-what-it-is-and-when-it-operates)
    - 10.2 [The Zero-Retention Policy](#102-the-zero-retention-policy)
    - 10.3 [Data Permissions and Content Screening](#103-data-permissions-and-content-screening)
11. [Reasoning Constraints](#11-reasoning-constraints)
    - 11.1 [The Bounded Loop Iteration Limit](#111-the-bounded-loop-iteration-limit)
    - 11.2 [Flex Credits and Token Consumption](#112-flex-credits-and-token-consumption)
12. [Reasoning Anti-Patterns](#12-reasoning-anti-patterns)
13. [Terminology Reference](#13-terminology-reference)

---

## 1. The Mental Model

### Why This Matters Before Anything Else

Before Agentforce, building an AI assistant on Salesforce meant writing a prompt, sending it to a model, and hoping the response was correct and safe. That approach has hard limits. The model can be asked to do things it should not do. It can invent information it does not have. It has no reliable mechanism for enforcing business rules, and there is no audit trail when it goes wrong.

Agentforce represents a fundamentally different design philosophy. The move from simple prompting to **hybrid reasoning** is the central idea of this entire guide. Understanding it is not background context — it is the prerequisite for everything else.

---

### 1.1 What the Atlas Reasoning Engine Is

The **Atlas Reasoning Engine** is the runtime planner at the heart of Agentforce. It receives a user message, interprets the Agent Script configuration file, and produces a response. When you publish an agent via the Salesforce CLI, the Atlas engine formally compiles your authored Agent Script into the **GenAiPlannerBundle** metadata artifact.

Atlas is not a single large language model. It is a **hybrid execution environment** that combines three distinct layers:

- **A deterministic resolver** — a compiler-like pass that evaluates your authored logic before any LLM is ever involved.
- **An LLM reasoning loop** — where an underlying foundation model makes probabilistic decisions, but only within the constraints the resolver has already enforced.
- **The Einstein Trust Layer** — a runtime security boundary that wraps every LLM call, enforcing data privacy, permission checks, and content safety.

> **Scenario: A Status Lookup**
>
> A user types "What is the status of my order?" Every turn begins at `start_agent`. `before_reasoning` fires and checks if `@variables.session_token` is empty — it is not, so no redirect. HyperClassifier (if active) routes to the Order Management subagent. The reasoning loop begins. Phase 1 resolves instructions and filters available actions. Phase 2 (the LLM) decides to call `get_order_status`. The action runs, populates `@variables.order_status`, and re-resolution fires from the top. The LLM now sees the success branch and produces: "Your order is out for delivery and will arrive today." `after_reasoning` fires and logs the completed lookup. Turn ends.

---

### 1.2 Why Hybrid Reasoning Exists: The Previous Model's Limits

**State did not survive the conversation.** Relying on single-turn processing meant the agent had no persistent memory of earlier steps. If the conversation deviated even slightly, the agent could drop previously captured context and force the user to restart. For multi-step transactional workflows, this created a reliability ceiling: the more steps in the process, the higher the probability of context loss before completion.

**Completed steps were not remembered.** Without state management, agents had no record of which mandatory steps a user had already completed. This produced unpredictable looping, where an agent would return to a step the user had already finished.

**Every interaction paid the full LLM cost.** Even a simple conversational scenario required a minimum of three LLM cycles — subagent selection, action selection, and response generation. Multi-step tasks extended to five or more cycles. There was no way to short-circuit the reasoning loop for steps that did not require judgment.

**Execution paths could not be guaranteed.** Because every decision depended on the LLM's real-time reasoning, minor variations in input, system prompt, or model version produced different action selections on identical requests. A workflow that passed in staging could behave differently in production.

The hybrid model addresses all four. Deterministic logic handles the steps that do not need the LLM. Variables persist state across turns. The Agent Graph defines an explicit execution plan that the Atlas engine follows reliably. And the audit trail reflects actual code execution, not probabilistic reasoning.

> **The cost implication:** the shift from a minimum of three LLM cycles to targeted, justified LLM calls is also a direct cost reduction mechanism. Every step moved to deterministic `run` execution is a step that does not consume an LLM iteration. This is the architectural reason a bounded iteration limit exists as a design constraint rather than just a platform guardrail.

---

### 1.3 The Fundamental Split

The most important concept in all of Agentforce is the clean division of responsibility between the deterministic layer and the LLM layer. Once you internalize this split, debugging becomes dramatically faster and authoring decisions become much clearer.

**The governing design rule:** if you can express a decision as code, write it as logic. Reserve LLM reasoning for what genuinely requires judgment, natural language understanding, or contextual interpretation.

| Deterministic Layer (authored control) | LLM Layer (probabilistic judgment) |
|---|---|
| `if` / `else if` / `else` evaluation | Which action to call |
| Variable injection | How to fill slot parameters |
| `run @actions.X` execution | What to say to the user |
| `available when` filtering | Whether to respond or call a tool |
| `transition to` routing | How to phrase and sequence the response |
| `set` variable capture | Which of multiple valid paths to take |

Here is the critical insight: **the LLM never sees raw Agent Script syntax.** It never sees `if` blocks, `run` statements, `@variables.X` references, or `available when` guards. It only ever sees the output of the deterministic pass — a clean, resolved prompt string plus a filtered set of tool schemas.

Deterministic logic controls **what the agent knows**. The LLM controls **whether and how to act** on that knowledge.

---

### 1.4 Agentforce Builder: Where You Author

Agentforce Builder is the recommended authoring environment for new agents, hosted within Agentforce Studio. It provides two editing surfaces that produce the same underlying artifact:

- **Canvas view** — a no-code drag-and-drop interface for configuring subagents, actions, and instructions visually.
- **Script view** — direct Agent Script editing. This is required for features that Canvas does not yet support, including `else if` conditional chains (see Section 4.3) and several pilot constructs introduced in 262.12 and 262.14.

When you publish from either view, the compiler produces the **GenAiPlannerBundle** metadata artifact.

---

### 1.5 The Atlas Engine and the Agent Graph

The **Agent Graph** is the serialized execution plan compiled from your `.agent` source file at publish time. It is optimized for machine execution by the Atlas Reasoning Engine state machine executor. It is not human-readable and is not directly accessible to authors.

When diagnosing agent behavior, you work with session traces — not the Agent Graph directly. The trace reflects the actual execution path the engine followed, which is the reliable source of truth for what the deterministic resolver did versus what the LLM decided.

---

## 2. The Two-Phase Execution Engine

### Why Two Phases?

Early AI systems were either fully scripted (rule engines, decision trees) or fully probabilistic (raw LLM prompting). Scripted systems are predictable but brittle — they cannot handle natural language variation. Probabilistic systems are flexible but unsafe — they cannot reliably enforce business rules.

The two-phase engine is the architectural answer to this tension. Phase 1 handles everything that must be predictable. Phase 2 handles everything that benefits from intelligent, adaptive judgment. The boundary between them is precise, not fuzzy.

---

### 2.1 Phase 1: Deterministic Resolution

Every reasoning iteration begins with Phase 1 before the LLM is ever involved. This phase is entirely deterministic: given the same input state, it always produces the same output.

Phase 1 reads `reasoning.instructions: ->` from top to bottom and performs these six operations in sequence:

**1. Condition Evaluation**
Evaluates `if / else if / else` conditions against current variable values. Only the matching branch's content proceeds. Non-matching branches are discarded entirely — they do not exist as far as the LLM is concerned.

**2. Synchronous Action Execution**
Executes `run @actions.X` calls synchronously. The Apex class or Flow runs immediately, and its outputs are available for subsequent steps within the same Phase 1 pass.

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

1. The system prompt (global or subagent-level, depending on whether a subagent override is active).
2. The resolved `reasoning.instructions` prompt string produced by Phase 1.
3. The filtered tool schema — only the actions whose `available when` conditions evaluated to True.
4. The conversation history for the current session.

The LLM uses these four inputs to make one decision: call a tool, produce a terminal response, or delegate to a subagent reference in the tool schema.

---

### 2.3 When the LLM Is Actually Triggered

The LLM is invoked more often than most authors realize. Beyond the main reasoning loop, the platform triggers additional LLM calls in several specific circumstances:

**1. Subagent classification**
On every turn, the platform invokes a classification call to select the appropriate subagent. If EinsteinHyperClassifier is active, this is a single-token prediction. If a standard model is active, it is a full LLM call.

**2. Slot-fill extraction**
When an action parameter uses the `...` ellipsis operator and the value is not yet available, the LLM is invoked to extract the value from conversation.

**3. `@utils.setVariables`**
Each invocation of the slot-fill utility triggers an LLM call to identify and assign the requested variable value.

**4. Groundedness validation**
When a response is grounded in retrieved data (via RAG or data retrieval actions), the platform may trigger an additional LLM call to confirm the output is genuinely grounded in the retrieved content rather than hallucinated. This adds a validation cycle that does not appear in the main reasoning loop but does consume an LLM call.

**5. Action simulation**
In the Agentforce Builder Preview and Simulate environment, actions are not executed live. The platform triggers an LLM call to emulate the action's response. **Your Preview environment does not execute real actions.** Simulation results reflect what the LLM believes the action would return, which may differ from what the action actually returns in production. Always test against a real environment before promotion.

**6. Structured output generation**
When a response must conform to a defined output schema (for example, a JSON structure for downstream consumption), the platform triggers a specialized LLM call to produce output that matches the schema constraints rather than free-form text.

**7. Localization generation**
For formatting and transient messaging in non-English locales where no pre-authored default exists, the platform triggers an LLM call to generate appropriately localized content.

**8. Progress indicator generation**
During multi-step operations, the platform may trigger an LLM call to generate transient messaging that keeps the user informed while the agent is working.

> **The cost modeling implication:** points 1-3 are the calls you think about when designing a turn. Points 4-8 are additional calls the platform may trigger independently of your authored logic. Groundedness validation (point 4) and action simulation (point 5) are easy to miss when estimating LLM call volume. A grounded response that also requires structured output could trigger three distinct LLM calls for what looks like a single agent response.

---

### 2.4 Why This Split Is the Primary Diagnostic Tool

The Phase 1/Phase 2 split gives you a structured first question that immediately narrows any debugging search.

**Ask: Did the correct instructions and tool list reach the LLM?**

**If no** — wrong branch was active, a required action was missing from the tool schema, or an injected variable had the wrong value — you have a **Phase 1 problem**. The cause is in your authored logic: a wrong variable value, a wrong condition expression, or `|` mode used instead of `->` mode. Fix it by inspecting variable state and condition logic.

**If yes** — the right instructions and tools reached the LLM, but it still acted incorrectly — you have a **Phase 2 problem**. The cause is in how the LLM interpreted what it received: a vague action description, ambiguous instructions, a missing stop condition, or conflicting directives. Fix it by improving descriptions and instructions.

This binary framing eliminates a large class of guesswork before you ever read a full trace file.

---

### 2.5 Global Runtime Configuration: config.runtime

*(New in 262.12)*

The `config.runtime` block is a top-level configuration section that exposes boolean flags controlling global engine behaviors. These flags compile into `global_configuration.runtime` at publish time and affect the entire agent, not individual subagents.

```yaml
config:
    agent_type: "StandardAgent"
    runtime:
        streaming: true
        thought_chunks: false
        citation: true
        groundedness: true
        reset_to_initial_node: false
```

**The five flags:**

| Flag | Effect |
|---|---|
| `streaming` | Enables token-by-token streaming of agent responses to the client. |
| `thought_chunks` | Emits intermediate reasoning steps to the client during processing. |
| `citation` | Attaches source citations to grounded responses. |
| `groundedness` | Activates groundedness validation (see Section 2.3, point 4). As of 262.12, architects have an explicit switch for this behavior rather than relying on implicit platform defaults. |
| `reset_to_initial_node` | When `True`, the engine resets to `start_agent` after each turn rather than preserving any subagent position. Directly relevant to the stateless turn model described in Section 7. |

> **Hard compile error:** an empty `runtime:` block — present but with no flags set — is a compile error as of 262.12. Either set at least one flag or omit the block entirely. An omitted block uses platform defaults for all flags.

**Architectural note on `groundedness`:** prior to 262.12, groundedness validation was an implicit platform behavior with no author-controlled switch. The explicit flag means that architects designing agents for cost-sensitive deployments can now make a deliberate tradeoff: disable groundedness validation to eliminate the extra LLM call described in Section 2.3 point 4, accepting the reduced protection against hallucinated grounding. This is a consequential decision that should be made intentionally.

---

## 3. The Complete Turn Anatomy

### What a Turn Actually Contains

A turn is one complete cycle: one user message in, one agent response out. Inside that cycle, a structured sequence of events occurs. Understanding this sequence precisely is the foundation for predicting how your agent will behave and diagnosing problems when it does not.

**The complete turn sequence:**

1. User message received.
2. Execution begins at `start_agent`.
3. `before_reasoning` on `start_agent` fires (if present).
4. HyperClassifier or standard LLM classifies the user message and selects a subagent.
5. `before_reasoning` on the selected subagent fires (if present and model allows).
6. Phase 1 resolution begins: conditions evaluated, `run` blocks execute, variables captured, tokens injected, tool schema filtered.
7. Phase 2 (LLM) receives resolved prompt and filtered tool schema, makes a decision.
8. If the LLM calls a tool: the action executes, outputs are available, Phase 1 re-resolution fires from the top (the re-resolution loop).
9. If the LLM produces a terminal response: the response is passed through the Einstein Trust Layer (toxicity scoring), then delivered to the user.
10. `after_reasoning` fires (if present, model allows, and no mid-reasoning handoff occurred).
11. Turn ends.

---

### 3.1 The Re-Resolution Loop: The Inner Heartbeat

The re-resolution loop is the single most misunderstood mechanic in Agentforce, and getting it wrong produces some of the most confusing bugs on the platform.

**What re-resolution means:** after every tool call, the entire `reasoning.instructions` block is rebuilt from scratch using the updated variable state. This is not "continue from where you left off." It is a full re-evaluation of the entire instruction block, top to bottom, every single time a tool call completes.

**Why the platform works this way:** variable state has changed. The instruction text appropriate before the action ran may no longer be appropriate after. By rebuilding the entire block, the engine ensures the LLM always sees instructions that reflect the current state of the world, not a stale snapshot.

**The critical authoring consequence:** post-action conditional checks must be placed at the **top** of `instructions: ->` blocks.

Here is what goes wrong when they are at the bottom:

```yaml
instructions: ->
    | Please provide your order number and I will look it up.
    run @actions.get_order_status
        with order_id =...
        set @variables.status = @outputs.status
    if @variables.status != '':   # <- THIS IS TOO LATE
        | Your order status is {!@variables.status}.
```

After the action runs, re-resolution fires and reads from the top. The LLM sees "Please provide your order number" again and either repeats the ask or produces a confused response.

**The correct pattern:**

```yaml
instructions: ->
    if @variables.status != '':   # <- CHECK FIRST, ALWAYS
        | Your order status is {!@variables.status}.
    | Please provide your order number and I will look it up.
    run @actions.get_order_status
        with order_id =...
        set @variables.status = @outputs.status
```

On first entry, `@variables.status` is empty, so the condition is False, it is skipped, and the LLM correctly sees the initial instruction. After the action completes and re-resolution fires, the status is now set, the condition is True, and the LLM sees the success instruction instead.

---

### 3.2 LLM Recovery After Failed Actions

When the LLM attempts a tool call and receives an error payload instead of a successful result, the LLM reasons into an alternative approach rather than terminating the turn outright. It might try a different action, ask the user for corrected input, or produce an apologetic response explaining it could not complete the task. This recovery happens within the existing reasoning loop.

**The important design implication:** each recovery attempt consumes a reasoning iteration. Each failed call is one more step toward the platform's bounded iteration ceiling. A misconfigured action that consistently returns an error will cause the LLM to attempt recovery until it hits the limit, producing a confusing response to the user.

In session traces, identify failed action recoveries by looking for `FunctionStep` entries with error payloads followed by a new `LLMStep` — the LLM re-entering reasoning after seeing the failure.

---

### 3.3 What the LLM Does NOT See

Understanding what the LLM cannot see is just as important as understanding what it can. Developers who try to "explain" Agent Script constructs to the LLM in their instructions are writing dead code — the model cannot access those constructs.

**The LLM never sees:**

- Raw `if`, `else if`, or `else` keywords or the conditions they contain
- `run` statements or any indication one fired
- `set` statements
- `available when` conditions — failing actions simply do not appear in the tool schema, with no indication they ever existed
- `before_reasoning` or `after_reasoning` block content
- Subagent names or the concept of subagents as a structural entity
- `@variables.X` syntax — it only sees the resolved value after `{!@variables.X}` injection
- Any action invocations that fired deterministically during Phase 1
- Graph nodes that were traversed deterministically — the LLM is only invoked at nodes with prompt instructions
- `@system_variables.X` syntax — system variables are resolved before the prompt is assembled; the LLM sees only the injected value

**The practical authoring rule:** read your `reasoning.instructions` pipe text as if you were the LLM receiving it. Does it make sense as a standalone English instruction? Does it give you enough context to act? Or does it reference Agent Script constructs? If it references constructs, it needs to be rewritten.

---

## 4. The Instruction Surfaces

### Why Multiple Surfaces Exist

In simple prompt-based systems, there is one instruction: the prompt. In Agentforce, instructions are organized across several distinct surfaces, each with a different lifecycle, a different processor, and different rules. Each surface solves a specific problem: some instructions should apply universally, some should vary by subagent context, some should be rebuilt on every action call, and some should fire with no LLM involvement at all.

Conflating these surfaces — using the wrong one for the wrong job — is one of the most common sources of both bugs and compile errors.

**Quick reference:**

| Surface | Fires | Processed By | Supports `instructions:` Wrapper | Scope |
|---|---|---|---|---|
| Global system | Every iteration | LLM (system prompt) | Yes | All subagents |
| Subagent system | Every iteration (overrides global) | LLM (system prompt) | Yes | That subagent only |
| `reasoning.instructions` | Every iteration, rebuilt each time | Phase 1 resolver, then LLM | Yes (`|` or `->` mode) | That subagent only |
| `before_reasoning` | Every parse (including after each tool call) | Phase 1 resolver only | **No — direct content only** | That subagent only |
| `after_reasoning` | Once per turn, after terminal response | Phase 1 resolver only | **No — direct content only** | That subagent only |
| `after_response` | After a connected subagent returns | Phase 1 resolver only | **No — direct content only** | **Connected subagents only** |

> **`after_response` is a connected-subagent-only surface** introduced in 262.10. It is not available on standard local subagents. See Section 4.5.1 for full details.

---

### 4.1 Global System Instructions: The Persona Layer

The global `system.instructions` block is the durable identity of the agent — its persona, its tone, its non-negotiable safety rules, and its disclosure requirements. It fires every reasoning iteration unless a subagent overrides it, making it the model's constant baseline.

**What belongs here:** persona and tone, safety invariants that must never change, and universal disclosure rules such as "I am an AI assistant."

**What does not belong here:** task-specific logic (which belongs in `reasoning.instructions`) or conditional behavior. Conditions written in the system block appear as literal English prose — they are not evaluated. "If the user asks about billing, route to billing" in a system block is prose the LLM will attempt to interpret, with unpredictable results.

**The most common mistake in router-first agents:** the global block says "Answer the user's questions helpfully" while the router subagent's reasoning block says "Do not answer. Route only." The LLM receives both simultaneously and must resolve the contradiction probabilistically. One instruction wins — but which one is non-deterministic across turns and model versions.

**The correct pattern:** write a global instruction that is neutral toward all subagent postures.

```yaml
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

> **262.14 escalation of this gap: `strip_salesforce_instructions`**
>
> The `strip_salesforce_instructions` flag (262.14) can be set top-level or per-subagent. When set, it removes the Salesforce platform system prompt that sits beneath your own global system instructions. Prior to 262.14, the guide's model assumed a Salesforce baseline persona was always present underneath your authored instructions — a layer that includes implicit safety guidance. With `strip_salesforce_instructions` enabled, that baseline is gone. The Silent Security Gap scenario becomes strictly more severe: there is now no authored invariant and no platform baseline. Any subagent operating with `strip_salesforce_instructions` and no explicit invariant restatement is operating with zero safety constraints. **If you use this flag, you must explicitly restate every safety invariant you rely on, in every affected subagent system block, without exception.**

**The authoring rule is absolute:** restate every invariant the subagent must retain in its subagent-level system block. Treat every subagent system block as a complete, self-contained identity definition — not an addendum to the global. This is even more critical when `strip_salesforce_instructions` is active.

---

### 4.3 reasoning.instructions: Two Modes, One Critical Rule

The `reasoning.instructions` surface is the most powerful and most error-prone surface in Agent Script. It is rebuilt on every reasoning iteration (including after every tool call) and supports two modes. Choosing the wrong mode is the most common silent authoring failure in the entire language.

**Pipe mode (`|`) — LLM prompt text:**
Content is passed directly to the LLM as a prompt instruction. The LLM interprets it probabilistically. Use this for natural language direction that genuinely requires LLM judgment.

```yaml
instructions: |
    Help the customer find the right product for their needs.
    Ask clarifying questions if the request is ambiguous.
```

**Procedural mode (`->`) — deterministic logic:**
Content is evaluated by the Phase 1 resolver. `if` / `else if` / `else` blocks, `run` statements, `set` statements, and `available when` guards must be inside `->` mode. Use this whenever you need guaranteed execution or conditional branching.

```yaml
instructions: ->
    if @variables.tier == 'premium':
        | You are assisting a premium customer. Prioritize their request.
    else if @variables.tier == 'standard':
        | Help the customer with their request per standard guidelines.
    else:
        | Please verify your account tier before we continue.
```

> **`else if` support:** `else if` chaining in `->` mode is supported as of 262.12. Note that Canvas view does not yet render `else if` chains visually — use Script view when authoring multi-branch conditionals. Canvas may rewrite `else if` chains incorrectly if the script is opened and saved in Canvas view.

**The one critical rule:** you cannot mix modes in a single `instructions:` block. Choose `|` or `->`. If your block needs any `if`, `run`, or `set` statement, the entire block must use `->`.

---

### 4.4 before_reasoning: The Pre-Parse, Pre-Classifier Gate

`before_reasoning` is the earliest execution point in every turn and every parse. It fires before the HyperClassifier makes any routing decision, before any LLM is involved, and before any reasoning begins.

**Common valid uses:**
- Authentication and authorization gates (fail fast before any LLM cost or routing decision)
- Mandatory data pre-loading that every subagent will need (EndUserId, EndUserName, session context)
- Early exits for invalid or expired session states

**The critical syntax constraint:** `before_reasoning` does **not** use an `instructions:` wrapper. Content goes directly under the block. Using `instructions: ->` inside `before_reasoning` is a **compile error**.

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

**Three practical consequences of the per-parse firing behavior:**

1. **Initialization actions re-execute** on every parse in multi-action turns. Guard once-per-session logic explicitly.
2. **Counter variables** incremented here reflect parse count, not turn count.
3. **Actions with side effects** (external API calls, record writes) must be guarded against re-execution.

**The guard pattern for once-per-session logic:**

```yaml
before_reasoning:
    if @variables.sessionInitialized == False:
        run @actions.InitializeSession
        set @variables.sessionInitialized = True
```

> **Critical anti-pattern — infinite loops:** never place a `transition to` instruction in `before_reasoning` without a condition guard. An unconditional `transition to` here fires on every parse and creates an infinite routing loop. This is one of the most severe authoring errors on the platform and produces no compile-time warning.

---

### 4.5 after_reasoning: The Post-Turn Gate

`after_reasoning` runs after the reasoning loop produces a terminal response. The LLM has already spoken by the time this executes.

**Common valid uses:**
- State cleanup (clearing temporary variables)
- Logging (recording that a workflow step completed)
- Conditional transitions based on what the turn accomplished

**Transition syntax in after_reasoning:** transitions inside `after_reasoning` must use the bare `transition to` syntax — not `@utils.transition to`. The `@utils.` prefix form is valid only inside `reasoning.actions` blocks.

```yaml
# WRONG — @utils. prefix is not valid here
after_reasoning:
    if @variables.case_type != '':
        @utils.transition to @subagent.case_creation

# CORRECT
after_reasoning:
    if @variables.case_type != '':
        transition to @subagent.case_creation
```

**The pipe command is platform-prohibited in after_reasoning.** You cannot place a `|` prompt instruction inside `after_reasoning`. This is a platform-enforced constraint. `after_reasoning` is fully deterministic because the language itself prevents prompt instructions from appearing there.

**Two critical bypass cases — logic placed in after_reasoning will NOT execute when:**

**Case 1:** a subagent transitions mid-reasoning via `@utils.transition to` (an LLM-driven handoff). The original subagent gave up control before producing a terminal response. No terminal response means no `after_reasoning` trigger.

**Case 2:** an action in the flow has `is_displayable: True` set. When `is_displayable: True` is configured on an action, the platform exits the reasoning loop immediately as soon as the LLM decides to surface that output. That exit is immediate — `after_reasoning` never executes in this path.

**The recommended mitigation for both bypass cases:** move logic that must execute reliably into the `before_reasoning` block of the subsequent subagent rather than relying on `after_reasoning` of the current one.

Like `before_reasoning`, `after_reasoning` does not support an `instructions:` wrapper. Same constraint, same compile error.

```yaml
# WRONG — compile error
after_reasoning:
    instructions: ->
        if @variables.commit_failed == True:
            transition to @subagent.operation_recovery

# CORRECT
after_reasoning:
    if @variables.commit_failed == True:
        transition to @subagent.operation_recovery
```

---

### 4.5.1 after_response: The Connected Subagent Return Surface

*(New in 262.10 — connected subagents only)*

`after_response` is a sixth instruction surface available exclusively on `connected_subagent` nodes. It fires after a connected (external or BYON) agent returns control to the orchestrator — filling the gap where `after_reasoning` cannot fire because connected subagents have no local reasoning loop.

**Why this surface exists:** when a standard local subagent completes its turn, `after_reasoning` fires in the normal way. But a connected subagent runs its reasoning loop remotely. The orchestrator receives a response payload — it never ran a local reasoning loop — so there is no `after_reasoning` to trigger. `after_response` is the hook that fires in that position instead.

**Accepted statements:** `run`, `set`, `if`, and `transition`. The pipe (`|`) instruction is explicitly disallowed. This is the same prohibition as `after_reasoning`, and for the same reason: there is no reasoning loop active at this point, so there is no LLM to receive a prompt instruction.

```yaml
connected_subagent:
    target: agent://my-external-agent
    after_response:
        if @variables.handoff_result == 'escalate':
            transition to @subagent.human_handoff
        set @variables.external_complete = True
```

**Design consideration:** use `after_response` for state updates, routing decisions, and cleanup logic that must happen after a connected agent returns. Treat it the same way you treat `after_reasoning` in terms of what can and cannot appear there — and apply the same bypass awareness: if the connected subagent itself transitions mid-execution, `after_response` may not fire.

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

**Type deprecation note (262.10):** the `id` primitive type is deprecated in favor of `string`. If your variable definitions use `mutable id`, migrate them to `mutable string`. The `id` type will produce a deprecation warning and may be removed in a future release.

**Linked variables** are read-only values populated from external session context — information Salesforce establishes at session start. They must have a `source` declaration and must **not** have a default value. Providing a default value on a linked variable is a compile error.

```yaml
variables:
    EndUserId: linked string from @MessagingSession.MessagingEndUserId
    RoutableId: linked string from @MessagingSession.RoutableId
    ContactId: linked string from @MessagingSession.ContactId
```

Linked variables are the primary mechanism for knowing who the user is without asking them. In a service agent, they come from the `MessagingSession` context. In an employee agent, they typically come from `@session.sessionID`. Getting these right is an early and important configuration step in every new agent.

---

### 5.2 The Four Scope Zones

*(Updated in 262.12 and 262.14)*

Agentforce defines four distinct variable Each holds a different kind of value, is valid in a different context, and behaves very differently when used outside its valid scope.

**`@variables.X` — Session-persistent state**
Valid anywhere in Agent Script logic and injectable into pipe text via `{!@variables.X}`. Persists for the life of the session unless explicitly overwritten.

**`@outputs.X` — Action return values**
Valid **only** in `set` and `if` statements immediately after the action's `run` block. The scope expires when those statements complete. Referencing `@outputs.X` anywhere else produces a silent failure.

**`@inputs.X` — Action input values**
Valid **only** in `with` clauses during action invocation. Not valid in subsequent `set` statements or post-execution checks. Scope expires when the `with` clause finishes.

**`@system_variables.X` — Read-only platform context**
A set of predefined, read-only variables populated by the platform at the start of every inbound turn. They are resolved before the prompt is assembled — the LLM sees the injected value, not the syntax. Current system variables include:

| Variable | Populated | Description |
|---|---|---|
| `@system_variables.current_modality` | Turn start (262.12) | The channel modality, e.g. `"voice"` or `"text"`. |
| `@system_variables.current_connection` | Turn start (262.12) | The connection identifier for the current inbound session. |
| `@system_variables.last_reply.interrupted` | Turn start (262.14, voice) | Boolean — whether the agent's last reply was interrupted by the user. |
| `@system_variables.last_reply.interrupted_heard_text` | Turn start (262.14, voice) | The portion of the agent's last reply the user heard before interrupting. |

Use `@system_variables.current_modality` to write subagents that behave differently on voice versus text channels — for example, suppressing markdown formatting or adjusting response length for voice.

**The correct mental model for `@outputs` and `@inputs`:** these are short-lived windows, not persistent stores. The moment an action's `with` clause or immediate post-run block completes, those windows close. Everything that needs to survive beyond the action must be explicitly transferred to `@variables` within those windows.

---

### 5.3 The Silent Failure Zone

`@inputs` and `@outputs` scope violations are the most dangerous bugs in Agent Script development — dangerous precisely because they produce no error and no obvious symptom.

When you use `@inputs` or `@outputs` outside their valid scope, the action executes successfully. The variable simply does not get set. No error is thrown. The agent continues operating as if everything worked — just without the value it should have.

> **Scenario: The Invisible Empty Field**
>
> An agent retrieves a customer's home branch location to display in a response. The developer writes the fetch action, captures `@outputs.status` immediately, but then tries to inject `@outputs.customer_location` into a pipe line three statements later. The `@outputs` scope has already expired. The injection produces an empty string. The agent displays "Your nearest branch is." — a clearly wrong response with no error in any log to explain why.

**How to catch this in traces:** a `FunctionStep` that completes with no difference in the `postVars` section (the before/after variable state comparison) is the diagnostic indicator of a scope violation. The action ran. The output was produced. Nothing was captured because the `set` statement referenced a scope that was already closed.

**Prevention:** capture every needed output value immediately in `set` statements directly under the `run` block. Then reference `@variables` everywhere else. Treat the post-action `set` window as a mandatory handoff step, not optional cleanup.

---

### 5.4 Variable Persistence Across Subagents

`@variables` persist across subagent transitions. A value set in Subagent A is fully available when Subagent B takes control. This is not a special feature you configure — it is the default behavior of the `@variables` scope, and it is the primary mechanism for passing state through a multi-subagent workflow without external storage or middleware.

> **Scenario: Verify Once, Carry Forward**
>
> A customer service agent has three subagents — an authentication gate, an order management specialist, and a billing specialist. When the authentication gate verifies the customer, it sets `@variables.is_verified = True` and `@variables.customer_id` from the verification result. When the router transitions to order management, those variables are already there. The order management subagent's `before_reasoning` block checks `@variables.is_verified` — it is `True` — and immediately makes order-specific actions available. The customer never re-verifies. The verified customer ID flows through to every action that needs it without being re-extracted from conversation.

---

### 5.5 The setVariables Slot-Fill Utility

`@utils.setVariables` is the LLM-driven slot-filling utility that tells the agent to define a variable based on a natural language description. The `...` token instructs the LLM to set the value of the variable from the conversation. The `description:` field instructs the LLM on how to interpret what to capture.

```yaml
reasoning:
    actions:
        set_first_name_variable: @utils.setVariables
            with first_name =...
            description: "Get the user's first name"
```

**When to use `setVariables`:** it is appropriate when the design goal is to collect a specific value through natural conversation before any downstream action runs. It is a free framework utility — it does not consume action credits.

**The important design consideration:** `@utils.setVariables` asks the LLM to focus on capturing the variable. If you need to capture a value **and** immediately act on it in the same turn, use LLM slot-fill directly on the target action using the ellipsis operator instead. This lets the LLM extract the value and invoke the action in a single Phase 2 decision.

```yaml
# Capture-then-act in one turn: use direct slot-fill on the action
reasoning:
    actions:
        - @actions.get_order_status
            with order_id =...   # LLM extracts and calls in one step
```

---

### 5.5.1 ask for: Structured Variable Capture (Pilot)

*(Introduced as `collect` in 262.12; renamed `ask for` in 262.14. Syntax is explicitly flagged as pilot and may still change before GA. No official documentation page exists at time of publication.)*

`ask for` is a structured variable capture statement that sits inside `reasoning.instructions` and gathers one variable at a time from the user in a controlled, resumable way. It is the natural successor to `@utils.setVariables` for scenarios where you need deterministic, turn-by-turn variable collection with branching, resume logic, and escape handling.

```yaml
instructions: ->
    ask for @variables.preferred_contact_method
        instructions: guidance
            | How would you like to be contacted? Options are email, phone, or chat.
    if @variables.preferred_contact_method == 'phone':
        ask for @variables.phone_number
            instructions: guidance
                | Please provide your phone number including area code.
```

**How it works:**

- The engine collects one variable at a time. After the user responds, the variable is set and the next statement in the block evaluates.
- **If-branching** is fully supported inside `ask for` sequences, allowing the collection flow to branch based on already-collected values.
- **Auto-resume:** if the user provides additional information mid-collection without being explicitly asked, the engine incorporates it rather than discarding it.
- **Cancel / change-of-intent handling:** if the user expresses intent to cancel or change direction, the engine handles the escape without looping.
- The variable's own `description` field flows to the LLM as per-field context — a cleaner mechanism than writing the entire extraction instruction inline.
- The `instructions: guidance` block accepts paraphrasable natural language. The LLM may rephrase this to fit conversational context, unlike a `|` prompt that is injected verbatim.

**Relationship to `setVariables`:** `ask for` is more structured than `setVariables`. Use `setVariables` for opportunistic, single-variable capture during a broader conversational flow. Use `ask for` when the variable collection sequence itself is the main purpose of the subagent turn.

**The `collect-experimental` lint:** in 262.12, the `collect` form emitted an info-level `collect-experimental` lint once per script. As of 262.14, the statement is renamed `ask for` and the lint is no longer emitted under that name. If you have existing scripts using `collect`, migrate them to `ask for` syntax before GA.

> **Pilot caveat:** syntax for `ask for` may still change before general availability. Validate against the current Agent Script compiler before relying on this feature in production workflows.

---

### 5.6 The Three Input Binding Patterns

Action parameters can be populated three ways. The choice between them has direct security and reliability implications.

**LLM slot-fill (`with param =...`):** the LLM extracts the value from conversation at Phase 2 time. Fully probabilistic — the LLM decides what to extract. If the value is absent, it prompts the user.

**Variable binding (`with param = @variables.X`):** the runtime reads the variable at Phase 1 time, before the LLM is involved. Fully deterministic. If the variable is empty, the action receives an empty string with no user prompt.

**Literal value (`with param = 'fixed'`):** a compiled constant resolved at Phase 1. Always the same value regardless of conversation or state.

> **Scenario: The Account ID Injection Risk**
>
> An agent processes refunds. The `issue_refund` action requires a `customer_id` parameter. If you use `with customer_id =...`, the LLM extracts a customer ID from the conversation — meaning a malicious user could type a different customer's ID and potentially trigger a refund against someone else's account. If you use `with customer_id = @variables.customer_id`, where that variable was set during verified authentication, the LLM has no ability to override the value from conversation. The verified ID flows through deterministically. This is the security-critical reason to choose variable binding over slot-fill for sensitive parameters.

> **262.10 default slot-fill behavior — check your action definitions:** as of 262.10, if an action input is marked `is_required: true` and has neither a `default` value nor a `with` clause, the compiler automatically marks it `slot_filled_by: LLM`. Previously, this gap was silent — the input was simply undefined. Now it silently becomes ellipsis-style LLM slot-fill. This is precisely the injection-risk pattern described above. **Audit your action definitions for required inputs without explicit binding.** Any `is_required` input that should be bound to a verified session variable but has no `with` clause will now default to LLM slot-fill as of 262.10 — and the behavior change is silent at runtime.

**The rule:** use `@variables` binding for verified identities, confirmed record IDs, and any sensitive value that should not be extractable from arbitrary user input. Use the ellipsis only for parameters the LLM legitimately needs to extract from conversation. Never leave a required sensitive parameter unbound.

---

## 6. Actions and the Reasoning Loop

### Actions as the Bridge to the Real World

In a pure LLM system, the model can only produce text. It cannot look up a customer record, process a payment, or update a case. Actions are what transform Agentforce from a text generator into an agent that can actually do things — querying databases, calling APIs, running flows, and updating records. How and when those actions fire is controlled by the two-phase engine.

Agentforce supports the following custom action types:

| Action Type | When to Use | Skills Required |
|---|---|---|
| Flow | Low-code rules-based automation and record retrieval | Low-code |
| Apex | Pro-code rules-based automation and complex custom logic | Pro-code |
| Prompt Template | LLM-based tasks like summarization or content generation | Low-code |
| External Service | Data from REST APIs with OpenAPI specs | Low-code |
| MuleSoft API | Legacy systems and complex enterprise integrations | Pro-code |
| Predictive Model | Predictive AI within an agent | Low-code |

Always check whether a standard action can fulfill the need before creating a custom one.

---

### 6.1 Deterministic vs. LLM-Driven Invocation

Every action in Agent Script can be invoked in two fundamentally different ways, and the choice has major implications for behavior, cost, and safety.

**LLM-driven invocation (`reasoning.actions` block):** the LLM decides whether and when to call the action, based on the description, the conversation, and the resolved instructions. The action appears in the LLM's tool schema. The LLM selects it when it judges the action appropriate.

**Deterministic invocation (`run @actions.X`):** the action fires unconditionally when the code path is reached during Phase 1 resolution. The LLM is not involved in the decision. This is how you enforce that an action always fires — for pre-loading data, enforcing audit trails, or implementing mandatory compliance steps.

The same action definition can be used both ways in different parts of the agent. The invocation mode is determined by context, not by the action definition itself.

---

### 6.2 The Four Action Chaining Patterns

When a workflow requires actions to run in a guaranteed sequence, four distinct patterns are available. Choosing between them depends on whether LLM judgment should be involved in the sequencing decision.

**Pattern 1: Sequential `run` blocks (fully deterministic)**
Actions execute in a fixed, top-to-bottom order during Phase 1. The LLM is not involved at any step. Each action's output is captured and passed as input to the next. Use when the sequence is unconditional and always the same. This is the most cost-efficient pattern — none of these steps consume an LLM iteration.

```yaml
instructions: ->
    run @actions.fetch_account
        with account_id = @variables.account_id
        set @variables.account_data = @outputs.account
    run @actions.calculate_risk
        with account = @variables.account_data
        set @variables.risk_score = @outputs.score
    run @actions.generate_offer
        with risk = @variables.risk_score
        set @variables.offer = @outputs.offer_text
```

**Pattern 2: Chained reasoning actions (LLM-selected sequencing)**
Actions are defined in `reasoning.actions` and the LLM selects them in sequence across multiple reasoning iterations. Each action's output is stored in a variable and referenced as input to the next action's description or `with` clause. Use when the LLM needs judgment about whether or how to proceed between steps. Each step in this pattern consumes one reasoning iteration.

**Pattern 3: Transitions (subagent-to-subagent chaining)**
A subagent completes its task, then transitions execution to a specialist subagent that handles the next stage. The handoff is one-way. Session variables carry state between subagents. Use when each stage of a workflow belongs in a distinct, independently testable subagent.

**Pattern 4: Conditionals (branch-based sequencing)**
The next action in a chain is selected based on the result of the previous action. An `if` block evaluates the captured output and either triggers a follow-up action or routes to a different path.

```yaml
instructions: ->
    run @actions.validate_order
        with order_id = @variables.order_id
        set @variables.validation_result = @outputs.result
    if @variables.validation_result == 'approved':
        run @actions.process_payment
            with order_id = @variables.order_id
            set @variables.payment_status = @outputs.status
    if @variables.validation_result == 'rejected':
        | Inform the user their order could not be validated
          and ask them to review the details.
```

**The critical distinction across all four patterns:** sequential `run` blocks (Pattern 1) and conditionals (Pattern 4) execute entirely within Phase 1 — no LLM calls, no iteration consumption. Chained reasoning actions (Pattern 2) consume one reasoning iteration per action call. This distinction directly affects how quickly a workflow approaches the platform's bounded iteration limit.

---

### 6.3 available when: Hard Filter, Not Soft Hint

`available when` is an authorization-layer control, not a suggestion to the LLM. When an `available when` condition evaluates to False during Phase 1, the action is completely removed from the tool schema. The LLM receives no tool entry, no description, and no indication the action exists.

This is categorically different from telling the LLM in an instruction "only call this action if the user is verified." An instruction is a probabilistic suggestion. `available when` is a compile-time enforced removal.

```yaml
actions:
    issue_refund: @actions.process_refund
        description: "Issues a refund for the specified order"
        available when @variables.is_verified == True
```

When `is_verified` is False, `issue_refund` is invisible to the LLM. No amount of prompting, social engineering, or natural language instruction from the user can make the LLM call an action that does not appear in its tool list.

**Lint hardening (262.10):** the compiler now flags `available when` conditions that resolve to non-boolean literals at compile time. If your condition evaluates to a string or number rather than a boolean, you will receive a lint warning. Treat this as a correctness signal — a non-boolean `available when` condition has undefined filtering behavior and should be rewritten to evaluate cleanly to `True` or `False`.

**The action loop problem:** the platform does not automatically suppress an action after it has been called once. If `available when` remains True after the action runs and the reasoning instructions are ambiguous, the LLM will call the same action on every parse. Close the gate deterministically after execution — either by setting the gate variable to a closed state in post-execution logic, or by using a separate `has_run` boolean.

---

### 6.4 The Four Transition Mechanisms

*(Renamed from "The Three Transition Mechanisms" — `escalate` added as of 262.14, `connected_subagent` as transition target added as of 262.10)*

Transitions are how agents move between subagents. Agentforce has four distinct mechanisms with strict rules about where each can be used. Using the wrong one in the wrong context produces a compile error.

| Mechanism | Valid Context | LLM Involved | Direction | Notes |
|---|---|---|---|---|
| Bare `transition to @subagent.X` | `before_reasoning`, `after_reasoning`, `reasoning.instructions ->` | No | One-way | Standard local subagents and connected subagents |
| `@utils.transition to @subagent.X` | `reasoning.actions` only | Yes (LLM decides when) | One-way | Standard local subagents and connected subagents |
| `@subagent.X` as action reference | `reasoning.actions` only | Yes (LLM decides when) | Returns to caller | Standard local subagents only |
| `escalate` statement | Top-level or `reasoning.instructions` | No | One-way, single-fire | See below |

**Connected subagents as transition targets (262.10):** `transition to @connected_subagent.X` now compiles cleanly through the normal supervision path. The interim compile warning from 262.8 is fully resolved. Both bare and `@utils.` forms support connected subagent targets.

**The `escalate` statement (262.14):** `escalate` is a deterministic, single-fire statement that hands off to a fixed escalation target — typically a human agent or external queue. It fires exactly once and does not return control to the calling subagent.

```yaml
instructions: ->
    if @variables.sentiment_score < 0.2:
        escalate
```

The single-fire guarantee is architecturally significant. Unlike a `transition to` inside a looping `before_reasoning` block, `escalate` cannot re-fire on subsequent parses. This makes it the correct choice for escalation paths that must not loop — exactly the scenario that Anti-Pattern 9 warns about when unconditional transitions appear in `before_reasoning`. If your escalation logic previously used an unguarded `transition to` in `before_reasoning`, migrating it to `escalate` eliminates the loop risk by design.

**Other transition rules:** all non-escalate transitions are one-way by default. There is no return of control to the calling subagent unless you explicitly create a return transition in the destination subagent. When transitioning back to a subagent, flow starts at the **beginning** of that subagent — not where it last left off.

**Note on conditional transitions:** a conditional `transition to` at the top of a `reasoning.instructions ->` block executes before any prompt begins. This makes it more reliable for enforcing mandatory prerequisite flows than `available when` filtering — the transition fires before the LLM has seen any context at all.

---

### 6.5 Handoff vs. Delegation

Handoff and delegation represent two fundamentally different control flow models. Choosing the right one has major architectural implications.

**Handoff (`@utils.transition to`):** control transfers completely to the called subagent. The caller does not resume. The destination owns the full response. The original subagent's `after_reasoning` does not fire if the handoff occurs mid-reasoning. Use when the destination should completely own the user experience from that point forward.

**Delegation (`@subagent.X` as action reference):** the parent orchestrates, the child runs its full reasoning loop and produces a result, and control returns to the parent, which synthesizes the final response. Use when the parent needs to coordinate across multiple children or incorporate results into a unified response.

**`delegate_escalation` on connected subagents (262.12):** connected subagents expose a `delegate_escalation` boolean (default `True`). When `True`, any escalation triggered within the connected subagent uses the connected subagent's own outbound escalation flow. When `False`, escalation delegates back to the orchestrator's escalation flow instead. This matters when the connected agent is a third-party or cross-org agent with its own escalation configuration that you do not want to override — or conversely, when you want the orchestrator to own all escalation paths uniformly.

```yaml
connected_subagent:
    target: agent://partner-service-agent
    delegate_escalation: False   # orchestrator owns all escalation
```

**The architectural implication:** building with delegation rather than pure handoff creates more composable, orchestratable agents. As multi-agent coordination capabilities evolve, agents built with the delegation pattern are much easier to incorporate into larger orchestration workflows without architectural rework.

---

### 6.6 The Zero-Hallucination Routing Pattern

Two output flags on action definitions control an important aspect of LLM behavior.

**`filter_from_agent: True`** prevents the LLM from displaying the output value to the user. The value is available to the agent's internal logic but invisible in model responses. Use for internal routing flags, risk scores, and system IDs.

**`is_used_by_planner: True`** allows the LLM to reason about the output value for routing decisions. Use for intent classification outputs and decision flags.

Combining both creates the **zero-hallucination routing pattern.** The LLM must actually call the classification action to obtain the routing value — it has no cached or hallucinated value to use. Once it has the real result, it can act on it for routing — but it cannot expose it to the user.

---

### 6.7 Inline Skills (Pilot)

*(New in 262.14 — skill_definitions block previewed as runtime WIP in 262.12)*

Inline Skills introduce a new instruction-authoring primitive that mirrors how `reasoning.actions` maps actions to tools. Where actions invoke external Flows, Apex, or APIs, skills encapsulate reusable reasoning instructions that can be attached to subagents and invoked by the LLM as named capabilities.

**Structure:**

Skills are defined in a top-level `skill_definitions` block and attached per-node via `reasoning.skills` — directly mirroring the `reasoning.actions` pattern.

```yaml
skill_definitions:
    summarize_case:
        instructions: |
            Summarize the key facts of the customer's case in three bullet points.
            Focus on: what the customer requested, what was attempted, and current status.

    de_escalation_phrasing:
        target: skill://shared-de-escalation-v2
```

```yaml
# In a subagent
reasoning:
    skills:
        - @skill_definitions.summarize_case
        - @skill_definitions.de_escalation_phrasing
    actions:
        - @actions.get_case_details
```

**Two skill definition styles:**

- **Inline body:** the `instructions:` block is defined directly in `skill_definitions`. The skill's reasoning instructions are embedded in the agent script itself. Use for agent-specific, frequently iterated skill logic.
- **`skill://` target:** the skill points at a named shared skill resource. Use for reusable skills shared across multiple agents or maintained separately.

**How the LLM uses skills:** the LLM selects skills from `reasoning.skills` using the same mechanism it uses to select actions from `reasoning.actions` — based on the skill's name and description. Meaningful, specific skill names improve selection accuracy. This is the same naming discipline that applies to actions.

**Relationship to actions:** skills and actions are complementary, not alternatives. Actions invoke external systems. Skills encapsulate reasoning patterns. A subagent can use both in the same turn.

> **Pilot caveat:** Inline Skills are pilot in 262.14. The `skill_definitions` block and `reasoning.skills` syntax may change before GA. Do not use in production-critical agents without validating against the current compiler. The 262.12 `skills:` block preview was a precursor and is superseded by the 262.14 syntax.

---

## 7. The start_agent Subagent and Turn Restart Behavior

Every Agentforce turn begins at `start_agent`, without exception. On every customer utterance, the engine begins execution at this block. Subagents do not resume between turns — each turn restarts at `start_agent` and routing classification runs again.

This has several practical consequences:

- **State must live in variables, not in subagent position.** Because execution always restarts at `start_agent`, the only way to carry information across turns is via `@variables`. Any context stored in LLM conversation history is available to the LLM but is not part of the deterministic resolution path.
- **`before_reasoning` on `start_agent` fires on every turn.** This makes it the correct place for session-level initialization that must happen before any topic is selected.
- **Subagent continuity is a design choice, not a platform default.** If you want a user to continue where they left off in a multi-turn workflow, that continuity must be encoded in variables and reflected in the routing logic of `start_agent`.

**BYON nodes as `start_agent` (262.8):** custom subagent nodes (Bring Your Own Node / connected subagents) can now serve as the initial and sole `start_agent` node. This means a BYON-hosted agent can be the entry point for the entire turn without requiring a standard local `start_agent` wrapper. The turn restart model still applies: every turn begins at whatever node is designated `start_agent`, whether that node is local or BYON.

**`agent://` scheme (262.8):** connected subagent targets now use the `agent://` URI scheme. The previous `agentforce://` scheme is deprecated. Update any existing `connected_subagent` target declarations accordingly.

```yaml
# DEPRECATED
connected_subagent:
    target: agentforce://my-external-agent

# CORRECT
connected_subagent:
    target: agent://my-external-agent
```

> **Business implication:** this architecture makes Agentforce agents stateless at the platform level and stateful only through what you explicitly persist. This is a feature, not a limitation. It makes agents predictable, testable, and auditable in ways that session-memory-based systems are not. See Section 7.5 for Goal-Based Agents, which introduce a different execution model operating outside this turn-based pattern.

---

### 7.5 Goal-Based Agents: Beyond the Turn Model (Pilot)

*(New in 262.14 — pilot)*

> **Scope note:** everything in Sections 1 through 7.4 describes the standard Agentforce turn-based model, where every interaction begins with a user utterance and ends with an agent response. Goal-Based Agents (GBA) / AgentIQ are a distinct execution model that does not share those foundations. GBA agents are not activated by user utterances — they are activated by triggers (including cron schedules) and pursue goals autonomously across multiple orchestrated steps. Read this section as an extension to the turn model, not a replacement.

**What Goal-Based Agents are:**

A Goal-Based Agent is an autonomous agent type gated behind `config.agent_type: "GoalBasedAgent"`. Instead of waiting for user utterances and responding turn-by-turn, a GBA agent pursues a declared goal through a structured workflow, potentially over an extended period, with no human in the loop for individual steps.

GBA is the first Agentforce execution model that is genuinely **scheduled and autonomous** — not reactive. A GBA agent can wake up on a cron schedule, execute a multi-step orchestrated workflow, and complete without any user-initiated interaction.

**Key blocks and constructs:**

```yaml
config:
    agent_type: "GoalBasedAgent"

workflows:
    daily_account_review:
        trigger:
            cron: "0 8 * * 1-5"   # 8am Monday-Friday
        orchestrator:
            # Orchestration logic here

# @dialect: agentforce-plugin
plugins:
    account_data: @plugins.account_data.*
```

| Block / Construct | Purpose |
|---|---|
| `workflows:` | Declares one or more named workflows the agent can execute. |
| `trigger:` | Defines what activates a workflow. `cron:` enables scheduled execution. |
| `orchestrator:` | Contains the orchestration logic for the workflow — sequencing subagents and skills to pursue the goal. |
| `# @dialect: agentforce-plugin` | Pragma marking a file as an Agentforce plugin. |
| `@plugins.<name>.*` | References a plugin's exported capabilities within GBA orchestration. |

**Hard gating:** the `workflows`, `trigger`, and `orchestrator` blocks are valid only when `config.agent_type: "GoalBasedAgent"` is set. As of 262.14, these blocks produce a hard compile error if they appear in a standard agent script. This is a deliberate isolation — GBA constructs cannot accidentally leak into standard agents.

**Design implications for architects:**

- The `start_agent` / turn restart model does not apply to GBA workflows. A GBA workflow is initiated by its trigger, not by a user utterance.
- The `config.runtime.reset_to_initial_node` flag (Section 2.5) is not meaningful for GBA workflows in the same way it is for standard agents — GBA workflows do not have an "initial node" in the turn model sense.
- `@variables` scope within a GBA workflow spans the workflow execution, not a user session. This is a different persistence model from standard agents.
- Because GBA agents operate autonomously, the "humans in control" model shifts: humans define the goal, trigger conditions, and guardrails in the workflow definition. The agent executes within those boundaries without per-step human approval.

> **Pilot caveat:** GBA / AgentIQ is pilot in 262.14. Block names, trigger syntax, and plugin referencing patterns may change before GA. Do not deploy GBA agents in production without validating against current compiler and runtime documentation. Treat GBA design work done today as exploratory architecture.

---

## 8. The EinsteinHyperClassifier

### 8.1 What HyperClassifier Is

EinsteinHyperClassifier is a specialized model purpose-built for subagent classification. Rather than using a general-purpose LLM to route user requests to subagents, HyperClassifier recasts that routing decision as a single-token prediction problem — producing classification results dramatically faster than a standard LLM.

HyperClassifier is an optional model configuration for the `agent_router` subagent. When enabled, it replaces the standard LLM call for subagent selection. It does not replace LLM reasoning within the selected subagent.

---

### 8.2 How It Works: Single-Token Prediction

**The core innovation:** standard LLMs classify by generating free-form text — they produce the class label as a sequence of output tokens, one at a time. This means a longer topic name produces a longer response time. For real-time applications like Agentforce Voice, this latency is unacceptable and unpredictable.

HyperClassifier instead recasts classification as predicting a **single special token** that represents the selected class, regardless of how long the class name is. This produces **constant-time O(1) inference**: the model outputs its classification decision in a fixed number of steps, regardless of how many subagents exist or how long their names are.

**The documented results:**

- **30x faster** subagent classification compared to general-purpose LLMs
- **1 second reduction** in Time to First Token (TTFT) for agent responses
- **Zero reasoning overhead**: the model is fine-tuned exclusively for classification and does not generate explanatory text
- **Increased classification accuracy**, particularly for specialized classification constraints and negative instructions (qualitative improvement confirmed in official Agent Script model documentation; specific benchmark figures are not publicly documented by Salesforce)

> **Note:** earlier versions of this guide cited a "KV caching / Cached Augmented Generation" second innovation, a specific 1-2% accuracy improvement figure, and a 1,000+ token prompt handling threshold. Those claims could not be verified against official Salesforce engineering documentation and have been removed. The single-token prediction architecture is the confirmed core speedup mechanism.

---

### 8.3 HyperClassifier Limitations

HyperClassifier's specialization comes with hard constraints. These are not configuration options — they are architectural limitations of the model.

**When EinsteinHyperClassifier is the active model on a subagent:**

- **Cannot use `before_reasoning`** — the block is not executed. *(Confirmed: Salesforce Agent Script developer documentation)*
- **Cannot use `after_reasoning`** — the block is not executed. *(Confirmed: Salesforce Agent Script developer documentation)*
- **Can only use `@utils.transition` as a tool** — no other tools or actions are available in the `reasoning.actions` block. *(Confirmed: Salesforce Agent Script model documentation — `ascript-model.md`)*

These constraints apply at the subagent level. A subagent configured to use EinsteinHyperClassifier operates under all three restrictions simultaneously.

---

### 8.4 The HyperClassifier and before_reasoning Paradox

This is an architectural tension that every Agentforce designer needs to understand explicitly.

**The advisory recommends:** for logic that must execute unconditionally on every turn before topic selection, use `before_reasoning` on `agent_router`. This ensures mandatory initialization (populating `EndUserId`, `EndUserName`, session context) runs before HyperClassifier makes its routing decision.

**The constraint states:** when EinsteinHyperClassifier is configured as the model for a subagent, `before_reasoning` cannot be used on that subagent.

**The resolution:** if your agent requires mandatory pre-classification logic (authentication checks, session variable population, required context loading), you **cannot use EinsteinHyperClassifier as the model for `agent_router`**. The `before_reasoning` hook and the HyperClassifier model are mutually exclusive on the same subagent.

**Why the state-based routing workaround fails:** a common intuitive design pattern is to use a state-based routing condition on a "User Verification" topic (`RunningUserValidated == False`) to enforce mandatory logic before business topics are reached. This pattern does not work reliably when HyperClassifier is enabled, because HyperClassifier routing and state-based routing conditions operate in **separate execution phases**. HyperClassifier selects the topic first, based on semantic relevance. If a user asks a business question, HyperClassifier routes to the relevant business topic — and the `RunningUserValidated == False` condition on the User Verification topic is evaluated afterward, too late to intercept the routing decision.

**HyperClassifier diagnostic improvements (262.10):** when `before_reasoning` or `after_reasoning` blocks are present on a HyperClassifier-configured subagent, the compiler now correctly identifies the incompatibility and points to the appropriate alternative in its error message. If you have previously encountered opaque errors in this scenario, the 262.10 diagnostics provide a clearer path to resolution.

**The correct design decision matrix:**

| Need | Correct model for agent_router |
|---|---|
| Maximum classification speed, no mandatory pre-classification logic | EinsteinHyperClassifier |
| Mandatory pre-classification logic (auth, session init, required vars) | Standard LLM (GPT 4.1, Claude Haiku 4.5, Gemini 3.5 Flash) |
| Both mandatory logic AND fast classification | Standard LLM on agent_router; use HyperClassifier on specialist subagents only |

The performance benefit of HyperClassifier is real and significant. The architectural constraint is equally real. Make this tradeoff explicitly, not by accident.

---

## 9. The Posture Spectrum

### From Fully Scripted to Fully Agentic

Posture is what unifies everything discussed so far. Early AI systems forced a binary choice: either full scripted control (deterministic, predictable, brittle) or full LLM latitude (flexible, adaptive, unsafe). Posture lets you choose exactly how much of each you need, for each specific subagent, based on what that subagent actually does.

This is not a configuration setting. It is a design philosophy backed by specific, implementable controls.

---

### 9.1 Agentic, Mixed, and Scripted

**Agentic posture (the default):** the LLM chooses which actions to call and when, extracts slot parameters from conversation, and determines response content and sequencing. Best for open-ended tasks, information retrieval, and conversational flows with no specific security or ordering requirements. Start here.

**Mixed posture:** selective determinism applied where justified. Some actions are gated with `available when`, some parameters are pinned to variable values, and some conditional instructions restrict what the LLM sees based on current state. Best for tasks with security gates, irreversible actions, or ordering requirements — while keeping the rest of the interaction natural and adaptive.

**Scripted posture:** fully deterministic. All transitions use bare `transition to`, all actions use `run`, and the LLM has zero discretion about what happens next. Best for regulated workflows, strict legal compliance, and zero-tolerance for variation. Rare in practice — most business use cases benefit from at least some LLM adaptability.

---

### 9.2 The Five Justifications for Determinism

One of the strongest patterns in Salesforce's Agentforce design guidance is the discipline around adding deterministic controls. Add determinism only when you have a specific, named justification. Without a justification, keep the posture agentic.

**The five valid justifications:**

1. **Regulatory requirement** — a compliance rule mandates specific sequencing, wording, or disclosure that cannot vary.
2. **Trust gate** — identity verification must complete before access is granted.
3. **Irreversible action** — once fired, the action cannot be undone.
4. **External system ordering** — an external API requires operations in a specific sequence.
5. **Observed production failure** — a specific behavior has failed in production and deterministic control is the proven fix.

If the justification does not match one of these five, keep the posture agentic. Adding determinism without justification increases brittleness, removes the LLM's ability to handle natural variation in user input, and increases maintenance burden without a concrete safety benefit.

---

### 9.3 The Three Control Primitives

When a justification for determinism exists, three primitives implement it. Each operates at a different layer and can be combined for defense-in-depth.

**`available when`:** hard Phase 1 filter removing the action from the tool schema when the condition is False. Authorization-layer control. The LLM cannot call the action because, from the LLM's perspective, it does not exist.

**Parameter pinning (`with param = @variables.X`):** replaces probabilistic slot-fill with deterministic variable binding. The LLM cannot override the parameter value with content from conversation. Use for verified identities and sensitive record IDs.

**Conditional instructions:** `if` / `else if` / `else` blocks in `instructions: ->` that change what text reaches the LLM based on current state. The LLM only sees the branch that matched — it has no awareness of branches that did not match.

---

### 9.4 The Minimal Instructions Principle

The most powerful authoring insight in all of Agentforce is also the most counterintuitive: **less instruction text produces better agent behavior.**

The instinct when building an agent is to write more instructions — to anticipate every edge case, address every possible user input, and add guidance for every situation the LLM might encounter. This instinct is wrong. More instructions introduce:

- **Conflicting directives** — two instructions that both apply to the same situation but specify different behaviors.
- **Stale coverage** — instructions written for a version of the agent that no longer exists.
- **Attention dilution** — the LLM trying to satisfy too many constraints simultaneously and satisfying none of them cleanly.
- **Maintenance burden** — every instruction must be updated when the agent changes.

**The correct approach:**
- Write one instruction per concrete behavioral requirement.
- Remove any instruction that cannot be traced to a specific, observed need.
- Let the LLM use its general capability for everything not explicitly constrained.
- Add instructions only when a specific behavior has failed without them.

The principle extends to subagents. Do not add a subagent because you might need it. Add it only when a distinct behavioral domain genuinely requires separate state management, a different system prompt, or a different action set. Every unnecessary subagent adds routing overhead, increases the chance of misrouting, and complicates the conversation flow for no benefit.

---

## 10. The Einstein Trust Layer

### Security Is Not Optional Infrastructure

The Einstein Trust Layer (ETL) is not a feature you enable on specific agents. It is a mandatory architectural component — a set of agreements, security technology, and data and privacy controls built into the Salesforce platform — that wraps every LLM interaction across all Agentforce deployments. Every prompt that leaves your org and every response that returns goes through this layer.

Understanding what the ETL does — and does not — do is essential for setting correct security expectations in production.

---

### 10.1 What It Is and When It Operates

The ETL operates on every LLM call. Its processing happens in two directions:

**Prompt journey (outbound):** secure data retrieval and grounding, data masking (where applicable — see Section 10.3), and prompt defense via system policies.

**Response journey (inbound):** toxicity scoring of the LLM response and audit logging of prompts, responses, and trust signals Data 360.

The ETL is the boundary between your Salesforce org and external model providers. It is designed to ensure that what leaves your org is appropriately protected and what returns is appropriately screened and logged.

> **Important:** ETL capabilities apply only to generative AI and Agentforce features. Standard Salesforce platform operations are not affected.

---

### 10.2 The Zero-Retention Policy

The ETL enforces a zero-data retention policy with external partner model providers such as OpenAI and Azure OpenAI. This policy has three specific commitments from the external provider:

1. **No training use** — data sent to the LLM is not used for model training or product improvements.
2. **No retention** — data is not retained by the third-party LLM after a response is sent back to Salesforce.
3. **No human review** — no human being at the third-party provider looks at data sent to their LLM.

**Important scope qualification:** this policy applies specifically to **external partner model providers**. Models built or fine-tuned by Salesforce and hosted within Salesforce's own trust boundary operate under different terms. Models you build and host on your own infrastructure are governed by your own policies. The zero-retention commitment is a contractual obligation with external providers, not a universal claim about all possible model configurations.

---

### 10.3 Data Permissions and Content Screening

**Secure Data Retrieval and Grounding**

When prompts are grounded with CRM data, the ETL enforces that grounding respects the executing user's permissions. Data retrieval preserves all standard Salesforce role-based controls, user permissions, and field-level security. A user cannot receive grounded context from records they do not have access to — the grounding is dynamic and permission-aware at runtime.

**Data Masking**

The ETL includes data masking that detects sensitive data in prompts before they are sent to the LLM, replacing it with placeholder text. Detection uses two methods: pattern-based (regex and ML models for names, companies, and other unstructured PII) and field-based (Shield Platform Encryption and data classification metadata).

> **Critical production note:** data masking for LLMs is **disabled for agents**. This applies specifically to Agentforce agent interactions. For embedded generative AI features such as Einstein Service Replies and Einstein Work Summaries, data masking is available and configurable. Authors building Agentforce agents must not rely on ETL data masking as a PII protection mechanism in agent conversations.

**Prompt Defense**

The ETL applies system policies to prompts to decrease the likelihood of the LLM generating unintended or harmful outputs. These policies help defend against jailbreaking and prompt injection attacks. System policies can vary across different generative AI features and use cases.

**Toxicity Scoring**

The ETL applies toxicity scoring across two distinct scopes, with different default behavior for each:

**Toxicity Detection in Responses — enabled by default, non-configurable:**
Output toxicity scoring is a core safety mechanism of the Einstein Trust Layer. It is automatically active in all Agentforce environments. In Salesforce Setup under the Einstein Trust Layer "Safety and Security" tab, Toxicity Detection in Responses is enabled by default and **cannot be disabled**. Each LLM response is graded on a scale from `0` (harmless) to `1` (toxic) across categories such as hate speech, violence, and harassment, plus a boolean `isToxicityDetected` confidence flag.

**Toxicity Detection in Prompts — opt-in enhancement:**
Input toxicity scoring is not active by default. Administrators must navigate to the Safety and Security tab in Setup and manually enable this setting. Enabling it prevents users from submitting toxic or adversarial inputs designed to bait or jailbreak the agent.

This architectural distinction is confirmed in the underlying data model. The `GenAiGatewayRequest__dlm` stream in Data Cloud tracks these behaviors via two separate fields:

- `enableOutputSafetyScoring__c` — defaults to `true` for all agent feature requests.
- `enableInputSafetyScoring__c` — defaults to `false` unless Toxicity Detection in Prompts is explicitly toggled in Setup.

Toxicity scores and the `isToxicityDetected` flag are logged and stored in Data 360 as part of the audit trail. Pre-built reports and dashboards are available for analysis.

**Audit Trail**

Prompts, responses, and trust signals — including toxicity scores — are logged and stored in Data 360. Feedback can be used for improving prompt templates.

---

## 11. Reasoning Constraints

### Why Constraints Exist

Every runtime system has hard limits. In Agentforce, those limits exist to prevent runaway loops, protect platform stability, and keep billing predictable. Understanding these constraints before you hit them in production is what separates smooth deployments from emergency incidents.

---

### 11.1 The Bounded Loop Iteration Limit

The Atlas Reasoning Engine enforces a bounded iteration ceiling on LLM-driven reasoning loops. When that ceiling is reached, the engine breaks out of the loop and returns control to the subagent router. This is a platform-enforced guardrail, not a configurable parameter.

> **On the specific number:** production session traces consistently show reasoning exhaustion occurring within a small number of LLM-driven iterations. The exact platform ceiling is not publicly documented by Salesforce in any official specification. This guide does not assert a specific numeric cap. Design your subagents with the understanding that chains of sequential LLM-driven action calls must be kept short.

**What counts as an iteration:** each Phase 1 + Phase 2 cycle is one iteration. Every time the LLM calls an action and re-resolution fires, that is one iteration consumed. Deterministic `run` blocks within Phase 1 do not consume iterations — only LLM-driven action calls in `reasoning.actions` do.

**Historical context:** in the previous Agentforce model, even a simple conversational scenario required a minimum of three LLM cycles. The hybrid model exists precisely to let simple and deterministic steps bypass the LLM entirely, making the iteration ceiling a limit on LLM-driven work rather than an unavoidable baseline.

**Why this matters for design:** a subagent that requires a long chain of sequential LLM-driven tool calls to complete its task risks hitting this limit before finishing. The recovery behavior — returning to the router — produces a confusing experience for the user and leaves the task incomplete.

**The three failure patterns this limit produces:**

1. **Action chains that are too long** — a subagent designed to call multiple actions sequentially via `reasoning.actions` may not complete. Redesign to move deterministic steps to `run` blocks in Phase 1 (Pattern 1 from Section 6.2), which do not consume LLM iterations.
2. **Recovery loops** — a consistently failing action causes the LLM to retry repeatedly. Each retry is an iteration. Successive failures can exhaust the ceiling before the LLM produces a useful response.
3. **Slot-fill loops** — a required parameter that the LLM cannot extract from conversation causes repeated re-prompting. Each re-prompt is an iteration.

**The diagnostic signal:** a session trace that shows multiple `LLMStep` entries followed by an unexpected transition back to the router is the pattern for hitting this limit.

---

### 11.2 Flex Credits and Token Consumption

Agentforce uses the **Flex Credits** model for action-based billing. Credits are consumed when actions execute — not when the agent responds. The platform separately enforces these hard runtime size limits:

- Maximum agent response: 1MB
- Plan trace: 1M characters
- Transformed plan trace: 32k tokens

The 32k transformed plan trace limit is the relevant architectural ceiling for reasoning context. Key billing facts:

- Flex Credits are priced at $0.10 per action (approximately $500 per 100,000 credits as of the last published rate).
- Enterprise Edition customers receive a free credits allocation.
- Utilities such as `@utils.escalate`, `@utils.setVariables`, and `@utils.end_session` are generally not billed as actions.
- LLM calls (prompts) are billed separately in 2,000-token chunks under the Prompts usage type.

> **For current per-action credit rates and any billing thresholds, always refer to the Salesforce Agentforce pricing documentation.** Rates are subject to change and this guide does not guarantee the accuracy of specific pricing figures.

---

## 12. Reasoning Anti-Patterns

The following patterns consistently produce agents that are harder to debug, less reliable in production, and more expensive to maintain. They appear frequently in initial implementations. Recognizing them early saves significant remediation effort.

---

**Anti-Pattern 1: The Unnecessary Router**

Building a router-first architecture when the agent handles a single coherent domain. Routing adds an LLM turn, increases latency, and introduces a potential misrouting failure mode. A single well-structured subagent is always preferable to a router plus one specialist.

*Signal:* a router subagent whose only destination is one other subagent.

*Fix:* collapse the router and specialist into a single subagent with `available when` guards controlling action availability.

---

**Anti-Pattern 2: Instructions as LLM Conditions**

Writing conditional logic in `|` mode pipe text rather than using `->` mode procedural blocks. The LLM interprets conditions probabilistically — sometimes correctly, often not, and never reliably.

```yaml
# WRONG
instructions: |
    If the user is verified, help them with their account.
    If the user is not verified, ask them to verify.

# CORRECT
instructions: ->
    if @variables.is_verified == True:
        | Help the user with their account.
    else:
        | Please verify your identity before we continue.
```

*Signal:* intermittent behavior that is difficult to reproduce, where the agent sometimes follows an instruction and sometimes ignores it.

*Fix:* convert `|` mode conditionals to `->` mode `if` / `else if` / `else` blocks.

---

**Anti-Pattern 3: Scope Violation Chains**

Referencing `@outputs.X` or `@inputs.X` outside their valid scope windows, and then building further logic on top of the empty-string result. The action runs, the capture silently fails, and the downstream logic operates on an empty value.

*Signal:* a `FunctionStep` with no change in `postVars`, followed by downstream behavior that ignores the action result.

*Fix:* capture all needed outputs immediately in `set` statements directly under the `run` block.

---

**Anti-Pattern 4: Sensitive Parameters via Slot-Fill**

Using the `...` ellipsis on action parameters that represent verified identities or sensitive record IDs. This allows the LLM to extract these values from user-provided conversation text, creating an injection vector.

**262.10 escalation:** as of 262.10, this pattern is no longer only a risk if you consciously write `with sensitive_id =...`. If an `is_required` action input has no `with` clause and no default, the compiler now automatically marks it `slot_filled_by: LLM`. A previously-silent gap in parameter binding is now silently converted to LLM slot-fill. **Audit all action definitions for `is_required` inputs that lack an explicit `with` clause.** The injection risk is now the default behavior for unbound required inputs — it does not require a deliberate authoring mistake to occur.

*Signal:* any `with customer_id =...` or `with account_id =...` pattern where that ID should come from authenticated session state; or any `is_required` input with no `with` clause in an action that handles sensitive data.

*Fix:* pin sensitive parameters to `@variables` that were populated during verified authentication. Always provide an explicit `with` clause for every `is_required` input.

---

**Anti-Pattern 5: Subagent System Override Without Invariant Restatement**

Adding a subagent-level `system:` block for specialization without restating safety invariants from the global system block. The global block is silently replaced — invariants that should apply everywhere are dropped for that subagent.

*Signal:* a subagent with its own system block that does not contain the same confidentiality, disclosure, and safety rules as the global block.

*Fix:* treat every subagent system block as a complete, standalone identity definition. Restate all invariants explicitly. If `strip_salesforce_instructions` is in use, this fix is doubly critical — there is no platform baseline to fall back on.

---

**Anti-Pattern 6: LLM Action Chains Longer Than a Few Sequential Steps**

Designing a subagent that requires a long sequence of LLM-driven action calls in `reasoning.actions` to complete its workflow. This risks hitting the platform's bounded iteration ceiling before the workflow finishes.

*Signal:* session traces showing the reasoning loop terminated with multiple `LLMStep` entries and no clean user response, followed by an unexpected return to the router.

*Fix:* move deterministic sequential steps to `run` blocks in Phase 1 (Section 6.2, Pattern 1), which do not consume LLM iterations. Reserve `reasoning.actions` for steps that genuinely require LLM judgment.

---

**Anti-Pattern 7: Global System Instructions That Contradict Subagent Posture**

A global instruction that directs the LLM to behave one way (e.g., "always answer helpfully") while a routing or scripted subagent requires different behavior (e.g., "only route, never answer"). The LLM receives both simultaneously as one system prompt and resolves the contradiction probabilistically.

*Signal:* a router subagent that occasionally answers questions directly instead of routing them.

*Fix:* write the global system instruction in a posture-neutral way that is compatible with all subagent behaviors. Move task-specific behavioral direction into `reasoning.instructions` where it is scoped to the subagent.

---

**Anti-Pattern 8: Using State-Based Routing to Enforce Mandatory Pre-Classification Logic**

Relying on a state-based routing condition on a semantically unrelated topic (e.g., "User Verification" with `RunningUserValidated == False`) to intercept all turns before a business topic runs. When HyperClassifier is enabled, this pattern fails silently: HyperClassifier routes to the most semantically relevant business topic first, and the state-based condition is evaluated afterward — too late to intercept.

*Signal:* intermittent failures where mandatory verification or initialization logic is skipped when HyperClassifier routes to a business topic before state conditions are evaluated.

*Fix:* use `before_reasoning` on `agent_router` for mandatory pre-classification logic. If HyperClassifier is required for its performance benefits, use a standard LLM on `agent_router` to preserve `before_reasoning` compatibility, and confine HyperClassifier to specialist subagents.

---

**Anti-Pattern 9: Transitions in before_reasoning Without Guards**

Placing a `transition to` instruction in `before_reasoning` without a condition guard. Because `before_reasoning` fires on every parse — including after every tool call — an unconditional transition here fires repeatedly and creates an infinite routing loop.

*Signal:* an agent that appears to route correctly on the first turn but enters an unresponsive loop on subsequent turns or multi-action flows.

*Fix:* always wrap any `transition to` in `before_reasoning` inside an `if` condition that evaluates to True only when the transition is actually needed. Alternatively, if the intent is to hand off to a fixed escalation target and never return, use the `escalate` statement (Section 6.4) instead. The `escalate` statement is single-fire by design and cannot loop — it is architecturally immune to the re-parse trigger that makes unguarded `transition to` dangerous in `before_reasoning`.

---

**Anti-Pattern 10: Treating Preview / Simulate as a Production Test Environment**

Relying on Agentforce Builder's Preview and Simulate environment as a substitute for production testing. In the preview environment, actions are not executed live — the platform uses LLM simulation to emulate action responses. Simulation results reflect what the LLM believes the action would return, which may differ significantly from what the action actually returns with real data in production.

*Signal:* an agent that behaves correctly in Preview but produces wrong or incomplete results in a real sandbox org, particularly in actions that depend on actual Salesforce records or external API responses.

*Fix:* use the Agentforce Testing Center in a Sandbox org for pre-deployment validation. The Testing Center supports test cases created via CSV, AI-generation, knowledge base, or conversation import, evaluated with LLM-as-judge metrics. It is automatically enabled for all Agentforce customers in Sandbox orgs at no additional cost. Limits include 500 test cases per job; recommended batch sizes are 20-30 cases.

---

## 13. Terminology Reference

**`@inputs.X`**
The scope zone for action input values. Valid only in `with` clauses during action invocation. Scope expires when the `with` clause finishes. Do not reference outside this scope.

**`@outputs.X`**
The scope zone for action return values. Valid only in `set` and `if` statements immediately following the action's `run` block. Scope expires after those statements complete.

**`@system_variables.X`**
Read-only platform context variables populated at the start of every inbound turn. Resolved before the prompt is assembled — the LLM sees the injected value, not the raw syntax. Includes `current_modality`, `current_connection` (both 262.12), and `last_reply.interrupted` / `last_reply.interrupted_heard_text` (262.14, voice channels). See Section 5.2.

**`@variables.X`**
Session-persistent state. Valid anywhere in Agent Script logic and across subagent transitions. Injectable into pipe text via `{!@variables.X}`. Persists for the life of the session unless explicitly overwritten.

**`agent://` URI scheme**
The current URI scheme for connected subagent targets, replacing the deprecated `agentforce://` scheme (deprecated in 262.8). Update all `connected_subagent` target declarations accordingly.

**Agent Graph**
The serialized execution plan compiled from the `.agent` source file when you publish an agent. Optimized for machine execution by the Atlas Reasoning Engine state machine executor. Not human-readable. Not directly accessible to authors.

**Agent Script**
The declarative DSL (domain-specific language) used to define Agentforce agent behavior. Combines deterministic logic instructions (`->`) with LLM reasoning prompts (`|`). Compiled into the GenAiPlannerBundle on publish.

**Agentforce Builder**
The recommended authoring environment for new agents, hosted within Agentforce Studio. Provides Canvas view (no-code) and Script view (direct Agent Script editing). Both views produce the same underlying artifact. Some features — including `else if` chains and pilot constructs — require Script view.

**`agentforce://` URI scheme**
Deprecated as of 262.8. Replaced by `agent://`. See `agent://` entry.

**`ask for` statement**
A pilot variable capture statement (introduced as `collect` in 262.12, renamed `ask for` in 262.14) that gathers one variable at a time from the user inside `reasoning.instructions`. Supports if-branching, auto-resume, and cancel/change-of-intent handling. The variable's `description` field flows to the LLM as per-field context. Syntax may still change before GA. See Section 5.5.1.

**`after_response`**
A connected-subagent-only instruction surface (262.10) that fires after a connected agent returns. Accepts `run`, `set`, `if`, and `transition` statements. Pipe instructions are disallowed. See Section 4.5.1.

**`config.runtime` block**
A top-level configuration block (262.12) exposing boolean flags for streaming, thought_chunks, citation, groundedness, and reset_to_initial_node. Compiles to `global_configuration.runtime`. An empty block is a hard compile error — set at least one flag or omit the block. See Section 2.5.

**`disable_graph_runtime`**
Deprecated flag, now a hard compile error as of 262.12. Remove from any agent scripts that reference it. Previously deprecated; the transition to hard error was confirmed in 262.12.

**`escalate` statement**
A deterministic, single-fire transition statement (262.14) usable at the top level or inside `reasoning.instructions`. Hands off to a fixed escalation target exactly once. Unlike `transition to`, it cannot loop — making it the correct choice for escalation paths in contexts where re-parse risk exists. See Section 6.4.

**`goal-based agent` / `GoalBasedAgent`**
An agent type (pilot in 262.14) gated behind `config.agent_type: "GoalBasedAgent"` that operates outside the standard turn-based model. GBA agents use `workflows`, `trigger` (including cron), and `orchestrator` blocks to pursue goals autonomously. These blocks produce a hard compile error in standard agents. See Section 7.5.

**Inline Skills**
A pilot feature (262.14) introducing `skill_definitions` (top-level) and `reasoning.skills` (per-node) blocks that mirror the `reasoning.actions` pattern. Skills encapsulate reusable reasoning instructions rather than external action invocations. Can be defined inline or via `skill://` target references. See Section 6.7.

**`reasoning.instructions`**
The primary instruction surface for subagent reasoning. Rebuilt on every parse, including after every tool call. Supports literal mode (`|`) and procedural mode (`->`). Use `->` mode whenever the block contains conditionals, `run` statements, `set` statements, or variable injections.

**Re-resolution**
The process of rebuilding the `reasoning.instructions` block from scratch after each tool call, using updated variable state. Ensures the LLM always sees instructions reflecting current state. Requires post-action condition checks to be placed at the top of `->` blocks.

**ReAct (Reasoning and Acting)**
The reasoning approach used by the Atlas Reasoning Engine. Loops through reason, act, and observe cycles until a user goal is fulfilled. Replaced the previous Chain-of-Thought (CoT) approach. Enables adaptive, human-like conversational experiences while remaining grounded in deterministic business logic.

**Script view**
The direct Agent Script editing surface within Agentforce Builder. Produces the same underlying artifact as Canvas view. Required for features not yet supported in Canvas, including `else if` chains (262.12) and several pilot constructs introduced in 262.14.

**`setVariables`**
A `@utils` slot-fill utility that instructs the LLM to capture a variable value from conversation using a natural language description. A free framework utility that does not consume action credits. For structured, multi-variable sequential capture, prefer `ask for` (Section 5.5.1).

**`start_agent`**
The entry subagent for every Agentforce turn, without exception. On every customer utterance, the agent begins execution at this block. Subagents do not resume between turns — each turn restarts at `start_agent` and routing classification runs again. As of 262.8, BYON / connected subagent nodes can serve as `start_agent`.

**`strip_salesforce_instructions`**
A 262.14 flag (top-level or per-subagent) that removes the Salesforce platform system prompt from beneath your authored instructions. Eliminates the implicit safety baseline that was previously always present. Must be used with explicit invariant restatement in every affected subagent system block. See Section 4.2.

**Transition (bare)**
The `transition to @subagent.X` form valid in `before_reasoning`, `after_reasoning`, and `reasoning.instructions ->` blocks. Fully deterministic, no LLM involvement. One-way. Supports both local and connected subagent targets as of 262.10.

**Transition (`@utils.transition`)**
The `@utils.transition to @subagent.X` form valid only inside `reasoning.actions`. LLM-driven — the LLM decides when to invoke the transition. One-way. Supports both local and connected subagent targets as of 262.10.

**Unified Planner**
A descriptive characterization used in this guide and some architectural discussions to refer to the Atlas Reasoning Engine — the same hybrid execution environment that plans and orchestrates Agentforce agent turns. *Note: this term does not appear verbatim in official Salesforce platform documentation. It is used here as a descriptive label consistent with the engine's function, not as confirmed Salesforce nomenclature. Readers should use "Atlas Reasoning Engine" when citing official sources.*

**Zero-hallucination routing pattern**
A pattern combining `filter_from_agent: True` and `is_used_by_planner: True` on a classification action's output. The LLM must call the action to obtain the routing value — it has no cached or hallucinated value to use — and can then act on the real result for routing without exposing it to the user.

---
