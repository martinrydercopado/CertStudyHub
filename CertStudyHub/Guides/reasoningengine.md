# Inside the Atlas Reasoning Engine: The Complete Agentforce Guide

*Updated August 26, 2026*
*This guide was generated using AI with grounding in official Salesforce documentation and internal FDE technical deep dive sessions. Review for accuracy before using.*

---

## Table of Contents
1. [The Mental Model](#1-the-mental-model)
   - 1.1 [What the Atlas Reasoning Engine Is](#11-what-the-atlas-reasoning-engine-is)
   - 1.2 [Why Hybrid Reasoning Exists: The Previous Model's Limits](#12-why-hybrid-reasoning-exists-the-previous-models-limits)
   - 1.3 [The Fundamental Split](#13-the-fundamental-split)
   - 1.4 [Agentforce Builder: Where You Author](#14-agentforce-builder-where-you-author)
   - 1.5 [The Atlas Engine and the Agent Graph](#15-the-atlas-engine-and-the-agent-graph)
   - 1.6 [The Agent Harness: The Configurable Layer](#16-the-agent-harness-the-configurable-layer)
2. [The Two-Phase Execution Engine](#2-the-two-phase-execution-engine)
   - 2.1 [Phase 1: Deterministic Resolution](#21-phase-1-deterministic-resolution)
   - 2.2 [Phase 2: LLM Reasoning](#22-phase-2-llm-reasoning)
   - 2.3 [When the LLM Is Actually Triggered](#23-when-the-llm-is-actually-triggered)
   - 2.4 [Why This Split Is the Primary Diagnostic Tool](#24-why-this-split-is-the-primary-diagnostic-tool)
   - 2.5 [Global Runtime Configuration: config.runtime](#25-global-runtime-configuration-configruntime)
   - 2.6 [The Three-Stage Per-Turn Pipeline](#26-the-three-stage-per-turn-pipeline)
3. [The Complete Turn Anatomy](#3-the-complete-turn-anatomy)
   - 3.1 [The Re-Resolution Loop: The Inner Heartbeat](#31-the-re-resolution-loop-the-inner-heartbeat)
   - 3.2 [LLM Recovery After Failed Actions](#32-llm-recovery-after-failed-actions)
   - 3.3 [What the LLM Does NOT See](#33-what-the-llm-does-not-see)
   - 3.4 [The Extended Internal State Machine Hooks](#34-the-extended-internal-state-machine-hooks)
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
   - 6.2 [The Four Action Chaining Patterns and Parallel Tool Calling](#62-the-four-action-chaining-patterns-and-parallel-tool-calling)
   - 6.3 [available when: Hard Filter, Not Soft Hint](#63-available-when-hard-filter-not-soft-hint)
   - 6.4 [The Four Transition Mechanisms](#64-the-four-transition-mechanisms)
   - 6.5 [Handoff vs. Delegation](#65-handoff-vs-delegation)
   - 6.6 [The Zero-Hallucination Routing Pattern](#66-the-zero-hallucination-routing-pattern)
   - 6.7 [Inline Skills (Pilot)](#67-inline-skills-pilot)
   - 6.8 [Subgraphs and Supervision Calls](#68-subgraphs-and-supervision-calls)
7. [The start_agent Subagent and Turn Restart Behavior](#7-the-start_agent-subagent-and-turn-restart-behavior)
   - 7.5 [Goal-Based Agents: Beyond the Turn Model (Pilot)](#75-goal-based-agents-beyond-the-turn-model-pilot)
8. [The Module Graph Runtime and Session Architecture](#8-the-module-graph-runtime-and-session-architecture)
   - 8.1 [MGR Overview](#81-mgr-overview)
   - 8.2 [The Unified Spec Transformation](#82-the-unified-spec-transformation)
   - 8.3 [System Injection Behavior](#83-system-injection-behavior)
   - 8.4 [Sticky Flowcharts and reset_to_initial_node](#84-sticky-flowcharts-and-reset_to_initial_node)
   - 8.5 [Bring Your Own Node (BYON)](#85-bring-your-own-node-byon)
   - 8.6 [Session Architecture: Redis and State Hydration](#86-session-architecture-redis-and-state-hydration)
   - 8.7 [The Agents API and the A2A Roadmap](#87-the-agents-api-and-the-a2a-roadmap)
9. [The EinsteinHyperClassifier](#9-the-einsteinhyperclassifier)
   - 9.1 [What HyperClassifier Is](#91-what-hyperclassifier-is)
   - 9.2 [How It Works: Single-Token Prediction](#92-how-it-works-single-token-prediction)
   - 9.3 [HyperClassifier Limitations](#93-hyperclassifier-limitations)
   - 9.4 [The HyperClassifier and before_reasoning Paradox](#94-the-hyperclassifier-and-before_reasoning-paradox)
10. [The Posture Spectrum](#10-the-posture-spectrum)
    - 10.1 [Agentic, Mixed, and Scripted](#101-agentic-mixed-and-scripted)
    - 10.2 [The Five Justifications for Determinism](#102-the-five-justifications-for-determinism)
    - 10.3 [The Three Control Primitives](#103-the-three-control-primitives)
    - 10.4 [The Minimal Instructions Principle](#104-the-minimal-instructions-principle)
11. [The Einstein Trust Layer](#11-the-einstein-trust-layer)
    - 11.1 [What It Is and When It Operates](#111-what-it-is-and-when-it-operates)
    - 11.2 [The Zero-Retention Policy](#112-the-zero-retention-policy)
    - 11.3 [Data Permissions and Content Screening](#113-data-permissions-and-content-screening)
12. [Reasoning Constraints](#12-reasoning-constraints)
    - 12.1 [The Bounded Loop Iteration Limit](#121-the-bounded-loop-iteration-limit)
    - 12.2 [Flex Credits and Token Consumption](#122-flex-credits-and-token-consumption)
13. [Debugging, Triage, and Diagnostics](#13-debugging-triage-and-diagnostics)
    - 13.1 [Telemetry Stack](#131-telemetry-stack)
    - 13.2 [Draft vs. Published Discrepancies](#132-draft-vs-published-discrepancies)
    - 13.3 [Automated Triage Scripting](#133-automated-triage-scripting)
    - 13.4 [Reading Session Traces](#134-reading-session-traces)
14. [Reasoning Anti-Patterns](#14-reasoning-anti-patterns)
15. [Terminology Reference](#15-terminology-reference)

---

## 1. The Mental Model

### Why This Matters Before Anything Else

Before Agentforce, building an AI assistant on Salesforce meant writing a prompt, sending it to a model, and hoping the response was correct and safe. That approach has hard limits. The model can be asked to do things it should not do. It can invent information it does not have. It has no reliable mechanism for enforcing business rules, and there is no audit trail when it goes wrong.

Agentforce represents a fundamentally different design philosophy. The move from simple prompting to **hybrid reasoning** is the central idea of this entire guide. Understanding it is not background context — it is the prerequisite for everything else.

---

### 1.1 What the Atlas Reasoning Engine Is

The **Atlas Reasoning Engine** is the runtime planner at the heart of Agentforce. It receives a user message, interprets the Agent Script configuration file, and produces a response. When you publish an agent via the Salesforce CLI, the Atlas engine formally compiles your authored Agent Script into the **GenAiPlannerBundle** metadata artifact.

Internally, the service that implements this planner is tracked in Splunk under the name **Agent Service Agentic Reasoner** — colloquially referred to as **Daisy** (and its expanded successor, **Daisy++**). Daisy addressed the original need for deterministic behavior inside the agent graph. Daisy++ emerged from the rapid evolution of LLM capabilities, which created an intense need for an expandable, configurable intermediary layer between the Atlas planner and the model itself. That layer is called the **agent harness** (see Section 1.6).

Atlas is not a single large language model. It is a **hybrid execution environment** that combines three distinct layers:

- **A deterministic resolver** — a compiler-like pass that evaluates your authored logic before any LLM is ever involved.
- **An LLM reasoning loop** — where an underlying foundation model makes probabilistic decisions, but only within the constraints the resolver has already enforced.
- **The Einstein Trust Layer** — a runtime security boundary that wraps every LLM call, enforcing data privacy, permission checks, and content safety.

> **Scenario: A Status Lookup**
>
> A user types "What is the status of my order?" Every turn begins at `start_agent`. `before_reasoning` fires and checks if `@variables.session_token` is empty — it is not, so no redirect. HyperClassifier (if active) routes to the Order Management subagent. The reasoning loop begins. Phase 1 resolves instructions and filters available actions. Phase 2 (the LLM) decides to call `get_order_status`. The action runs, populates `@variables.order_status`, and re-resolution fires from the top. The LLM now sees the success branch and produces: "Your order is out for delivery and will arrive today." `after_reasoning` fires and logs the completed lookup. Turn ends.

---

### 1.2 Why Hybrid Reasoning Exists: The Previous Model's Limits

**State did not survive the conversation.** Relying on single-turn processing meant the agent had no persistent memory of earlier steps. If the conversation deviated even slightly, the agent could drop previously captured context and force the user to restart.

**Completed steps were not remembered.** Without state management, agents had no record of which mandatory steps a user had already completed, producing unpredictable looping.

**Every interaction paid the full LLM cost.** Even a simple conversational scenario required a minimum of three LLM cycles — subagent selection, action selection, and response generation. Multi-step tasks extended to five or more cycles.

**Execution paths could not be guaranteed.** Because every decision depended on the LLM's real-time reasoning, minor variations in input, system prompt, or model version produced different action selections on identical requests.

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

**Architectural note on `groundedness`:** prior to 262.12, groundedness validation was an implicit platform behavior with no author-controlled switch. The explicit flag means that architects designing agents for cost-sensitive deployments can now make a deliberate tradeoff: disable groundedness validation to eliminate the extra LLM call, accepting the reduced protection against hallucinated grounding.

---

### 1.5 The Atlas Engine and the Agent Graph

The Agent Graph is the compiled execution plan the Atlas engine traverses during every turn. Each node in the graph corresponds to a subagent. Edges represent transitions. The graph is compiled from your Agent Script into the GenAiPlannerBundle. When Atlas receives a user message, it does not re-parse raw YAML — it executes the compiled graph.

---

### 1.6 The Agent Harness: The Configurable Layer

*(Introduced as a named concept in Daisy++)*

The **agent harness** is the intermediary layer that sits between the Atlas reasoning engine (the planner) and the model endpoint itself. Understanding what the harness is — and what it is not — is essential for architects designing complex or non-standard agent use cases.

**What the harness is:**
- Everything that structurally wraps around the raw LLM API call.
- The layer responsible for engineering the correct **context window**: system prompts, user messages, assistant text logs, tool messages, and tool schemas.
- The configurable surface for tools, context engineering, and short-term memory elements.
- Completely decoupled from surface presentation layers (UI rendering) and from the underlying hardware tier (CPU/runtime allocation).

**What the harness is not:**
- The model itself.
- The surface that renders output to users.
- A static, fixed configuration — it is designed to be configurable per business case.

**Why this matters architecturally:** all proprietary harnesses — whether from Anthropic, OpenAI, or Salesforce — are ultimately competing on **context engineering methodology**, not fundamentally different computational primitives. Salesforce's goal with Daisy++ is to build a platform that is a superset of all possible harnesses, so that any external loop configuration can be emulated and any enterprise harness requirement can be met through configuration rather than platform-level code changes.

**The three target use cases the harness abstraction enables:**

1. **Proprietary logic integration:** enterprise customers with complex isolated cloud code or legacy workflows can plug directly into the core reasoning engine via the Module Graph Runtime (MGR) without rewriting that logic as standard Agentforce actions.
2. **Non-conversational background agents:** agents that operate with zero human interaction — triggered by events such as email arrival — and execute long-running multi-step background tasks rather than chat-style exchanges. This pattern was accelerated by the Bluebirds acquisition.
3. **Advanced platform capabilities:** adding custom skills, specialized memory pieces, runtime orchestration hooks, and Bring Your Own Node (BYON) configurations that do not fit the standard action model.

> **The practical implication for architects:** the harness concept explains why `before_reasoning`, `after_reasoning`, action filtering, and the config.runtime block all exist as separate configurable surfaces. Each is a distinct layer of the harness. When you design a complex agent, you are not just writing prompts — you are engineering an entire context window construction pipeline.

---

## 2. The Two-Phase Execution Engine

### 2.1 Phase 1: Deterministic Resolution

Phase 1 is a compiler-like pass that runs before any LLM call. It processes the `reasoning.instructions` block top-to-bottom, evaluating every conditional, firing every `run` statement it encounters, capturing outputs into variables via `set`, injecting variable values into pipe text via `{!@variables.X}`, and filtering the tool schema to only include actions whose `available when` conditions evaluate to `True`.

The output of Phase 1 is not the raw Agent Script. It is a resolved prompt string and a filtered list of tool schemas — the only things the LLM ever sees.

**What fires in Phase 1:**
- `if` / `else if` / `else` block evaluation
- `run @actions.X` invocations (deterministic action calls)
- `set @variables.X = @outputs.Y` captures
- `{!@variables.X}` token injection into pipe text
- `available when` condition evaluation
- `before_reasoning` block execution

**What does not fire in Phase 1:**
- LLM calls
- Action invocations listed in `reasoning.actions` (those are offered to the LLM as tool schemas, not executed)

---

### 2.2 Phase 2: LLM Reasoning

Phase 2 is where the foundation model executes. It receives the resolved prompt from Phase 1 and the filtered tool schema. It makes one of three decisions:

1. **Call a tool** — select one of the available actions and provide slot-fill values for its parameters.
2. **Produce a terminal response** — generate a natural language reply to send to the user.
3. **Ask a clarifying question** — request additional information before acting.

If the LLM calls a tool, the action executes, and the re-resolution loop fires: Phase 1 rebuilds the instruction block from scratch using the updated variable state, and Phase 2 executes again with the new context.

---

### 2.3 When the LLM Is Actually Triggered

The LLM is triggered only when a node in the agent graph has `reasoning.instructions` with prompt content. Not every node does. Deterministic-only nodes that execute only `run` blocks, set variables, and transition without producing any output do not consume an LLM iteration.

**The specific conditions that trigger an LLM call:**

1. A subagent node has `reasoning.instructions` with pipe content (`|` mode).
2. Actions are listed in `reasoning.actions` and the engine must decide which to call.
3. A response must be generated for the user.
4. A groundedness validation check fires (when enabled — see `config.runtime`).

---

### 2.4 Why This Split Is the Primary Diagnostic Tool

When a bug occurs in an Agentforce agent, the first diagnostic question is: did the failure happen in Phase 1 or Phase 2?

- **Phase 1 failure:** a condition evaluated incorrectly, a variable was empty when it should not be, a `run` block did not fire, an action was filtered out by an `available when` condition that should not have fired. These are **logic bugs** — deterministic and reproducible.
- **Phase 2 failure:** the LLM chose the wrong action, extracted the wrong slot value, produced an incorrect response, or ignored an instruction. These are **probabilistic bugs** — they may not reproduce reliably. The fix is usually a prompt change, not a code change.

Treating a Phase 2 bug as a Phase 1 bug (and vice versa) leads to the wrong fix and wasted debugging time. Check session traces to identify which phase produced the incorrect output.

---

### 2.5 Global Runtime Configuration: config.runtime

The `config.runtime` block (introduced in 262.12) is a top-level configuration block that exposes boolean flags governing streaming, thought chunks, citation attachment, groundedness validation, and node reset behavior.

```yaml
config:
    runtime:
        streaming: true
        thought_chunks: false
        citation: true
        groundedness: true
        reset_to_initial_node: true
```

**Key flags:**

| Flag | Default | Effect |
|---|---|---|
| `streaming` | true | Streams tokens to the client before state write-back completes |
| `groundedness` | true (service agents) | Validates LLM output against grounded sources; on by default for service agents, opt-in for employee agents |
| `citation` | true | Attaches knowledge article citations in Post-Orchestration |
| `reset_to_initial_node` | true | Returns conversation to the root router after each turn; set to `false` for sticky flowcharts (see Section 8.4) |
| `thought_chunks` | false | Surfaces intermediate reasoning steps |

> **Important:** an empty `config.runtime` block is a hard compile error. Set at least one flag or omit the block entirely.

> **Groundedness defaults by surface:** groundedness checks are enabled by default for **service agents**. For **employee agents**, they must be explicitly enabled via the `groundedness: true` flag. This distinction matters for cost and latency budgeting across different deployment surfaces.

---

### 2.6 The Three-Stage Per-Turn Pipeline

Every individual user message triggers a sequential three-stage execution pipeline that wraps the two-phase engine described above. Understanding this outer pipeline is important for diagnosing failures that occur before or after the graph executes.

**Stage 1: Pre-Orchestration**

Runs uniformly on every incoming request before handing off to the agent graph. This stage handles:
- Universal validation.
- **Short-circuit checks** — on voice surfaces, simple chitchat utterances may be processed and responded to here without entering the graph at all, minimizing latency.
- **Prompt injection detection** — evaluated via the security hyper-classifier that screens the user's input for adversarial injection patterns before any graph execution occurs.

> **Design implication:** prompt injection defense is not only an Einstein Trust Layer concern — it fires at the Pre-Orchestration stage, before the graph is even entered. An injected prompt that passes Pre-Orchestration will then encounter the ETL's input toxicity screening if enabled. Defense is layered.

**Stage 2: Graph Execution**

The core modular state machine engine. Context variables and specific nodes process the reasoning steps, cycling through the full internal state machine sequence (see Section 3.4). This stage contains the two-phase engine described in Sections 2.1 and 2.2.

**Stage 3: Post-Orchestration**

Runs rules on every outbound response generated by the graph. This stage handles:
- **Citation attachment** — knowledge article citations are appended here, not during graph execution.
- **Data normalization** — response payloads are normalized before delivery.
- **Surface-specific formatting** — the engine formats output for the target surface. Employee surfaces receive rich UI card rendering; service surfaces default to text-only output.
- **Groundedness and anti-hallucination checks** — guardrail models evaluate whether the response is grounded in the provided context.

**Streaming and write-back sequencing:** the harness is built to stream all text tokens to the client first, before any other Post-Orchestration work, to minimize latency for real-time voice applications. State is persisted back to Redis only after the turn completes execution. This means a user on a voice surface may receive a response before the session write-back has finished.

---

## 3. The Complete Turn Anatomy

### What a Turn Actually Contains

A turn is one complete cycle: one user message in, one agent response out. Inside that cycle, a structured sequence of events occurs.

**The complete turn sequence:**

1. User message received. Pre-Orchestration fires (Section 2.6 Stage 1).
2. Execution begins at `start_agent`.
3. `before_reasoning` on `start_agent` fires (if present).
4. HyperClassifier or standard LLM classifies the user message and selects a subagent.
5. `before_reasoning` on the selected subagent fires (if present and model allows).
6. Phase 1 resolution begins: conditions evaluated, `run` blocks execute, variables captured, tokens injected, tool schema filtered.
7. Phase 2 (LLM) receives resolved prompt and filtered tool schema via recency-biased focus prompts, makes a decision.
8. If the LLM calls a tool: the Pre-Tool Hook validates parameters; if confirmation is required, execution pauses and state is serialized (see Section 3.4). Otherwise the action executes, the Post-Tool Hook fires, outputs are available, and Phase 1 re-resolution fires from the top (the re-resolution loop).
9. If the LLM produces a terminal response: the response is passed through the Einstein Trust Layer (toxicity scoring), then delivered to the user.
10. `after_reasoning` fires (if present, model allows, and no mid-reasoning handoff occurred).
11. Post-Orchestration fires: citations attached, formatting applied, groundedness validated, response streamed.
12. State persisted to Redis. Turn ends.

---

### 3.1 The Re-Resolution Loop: The Inner Heartbeat

The re-resolution loop is the single most misunderstood mechanic in Agentforce.

**What re-resolution means:** after every tool call, the entire `reasoning.instructions` block is rebuilt from scratch using the updated variable state. This is not "continue from where you left off." It is a full re-evaluation of the entire instruction block, top to bottom, every single time a tool call completes.

**Why the platform works this way:** variable state has changed. The instruction text appropriate before the action ran may no longer be appropriate after. By rebuilding the entire block, the engine ensures the LLM always sees instructions that reflect the current state of the world.

**The critical authoring consequence:** post-action conditional checks must be placed at the **top** of `instructions: ->` blocks. A check placed at the bottom will not be reached during the re-resolution pass that fires immediately after the action completes — the LLM has already made a decision based on what came earlier.

---

### 3.2 LLM Recovery After Failed Actions

When an action fails — network error, timeout, record not found — the failure result is returned to the LLM as a tool response. The LLM then decides how to recover. It may retry, try an alternative action, ask the user for clarification, or produce an error response.

**The authoring implication:** do not assume the LLM will always recover correctly from a failed action. If your workflow has a mandatory action that must succeed, capture the failure in a variable during the Post-Tool stage and gate subsequent logic on that variable's value. Let Phase 1 logic, not LLM judgment, determine the recovery path.

---

### 3.3 What the LLM Does NOT See

The LLM receives only the resolved output of Phase 1 — never the raw Agent Script. Specifically, the LLM does not see:

- Raw `if`, `else if`, or `else` keywords or the conditions they contain
- `run` statements or any indication one fired
- `set` statements
- `available when` conditions
- `before_reasoning` or `after_reasoning` block content
- Subagent names or the concept of subagents as a structural entity
- `@variables.X` syntax — it only sees the resolved value after `{!@variables.X}` injection
- Any action invocations that fired deterministically during Phase 1
- Graph nodes that were traversed deterministically
- `@system_variables.X` syntax — system variables are resolved before the prompt is assembled

**The practical authoring rule:** read your `reasoning.instructions` pipe text as if you were the LLM receiving it. Does it make sense as a standalone English instruction? If it references Agent Script constructs, it needs to be rewritten.

---

### 3.4 The Extended Internal State Machine Hooks

Within each active agent node step, the engine cycles through a seven-stage internal state machine. The two-phase model (Sections 2.1 and 2.2) describes Phase 1 and Phase 2. This section covers the additional hooks that surround tool execution.

**The seven-stage sequence:**

1. **Before Reasoning Iteration** — Evaluates deterministic `if`/`else` conditions and modifies mutable state variables exactly once per turn, before the LLM is invoked. This corresponds to `before_reasoning` block execution in Agent Script.

2. **Tool Planner (the LLM call)** — System prompts and **recency-biased focus prompts** are parsed alongside the filtered tool schemas to make the core LLM Gateway call. The recency-biased framing emphasizes recent conversational context to improve tool selection accuracy.

3. **Pre-Tool Hook** — Executes validation steps and allows input data to be inspected or modified immediately before the selected tool launches. This is the stage where parameter binding is confirmed and input guardrails can be applied.

4. **Execution Pause Check** — If the selected tool requires user confirmation or manual input collection (via `require_confirmation` or equivalent configuration), the engine **pauses graph execution** at this point. It serializes the complete current state snapshot and returns the response payload to the client interface. When the user submits their confirmation or input, the stateless engine re-hydrates the exact saved state and resumes execution from this point without re-running prior steps.

   > **Design implication:** the Execution Pause Check is how multi-step confirmation flows work without losing state across turns. The stateless architecture is preserved because the serialized state snapshot contains everything needed to resume. Authors relying on `@variables` state across a confirmation step should verify that all needed variables are populated before the pause point.

5. **Post-Tool Hook** — Ingests the raw output returned by the action, logs it to the telemetry stream, and allows developers to inspect or transform the output before it is handed to Phase 1 re-resolution.

6. **Hand-Off and Transition Evaluation** — Evaluates all transition expressions against the updated state to determine whether the conversation should shift to a different subagent node. This fires after every tool execution, not only at the end of a full reasoning loop.

7. **After Reasoning Iteration** — Fires once the loop detects that no additional tool executions are pending and a terminal response has been produced. This corresponds to `after_reasoning` block execution in Agent Script.

> **Relationship to Agent Script surfaces:** stages 1 and 7 map directly to `before_reasoning` and `after_reasoning` blocks. Stages 3 and 5 (Pre-Tool and Post-Tool hooks) are platform-managed and not directly authored in Agent Script, but their behavior affects how `@outputs` are available and what the LLM sees after an action completes. Stage 4 (Execution Pause) is triggered by tool-level configuration, not by Agent Script syntax.

---

## 4. The Instruction Surfaces

### Why Multiple Surfaces Exist

In simple prompt-based systems, there is one instruction: the prompt. In Agentforce, instructions are organized across several distinct surfaces, each with a different lifecycle, a different processor, and different rules.

**Quick reference:**

| Surface | Fires | Processed By | Supports `instructions:` Wrapper | Scope |
|---|---|---|---|---|
| Global system | Every iteration | LLM (system prompt) | Yes | All subagents |
| Subagent system | Every iteration (overrides global) | LLM (system prompt) | Yes | That subagent only |
| `reasoning.instructions` | Every iteration, rebuilt each time | Phase 1 resolver, then LLM | Yes (`|` or `->` mode) | That subagent only |
| `before_reasoning` | Every parse (including after each tool call) | Phase 1 resolver only | **No — direct content only** | That subagent only |
| `after_reasoning` | Once per turn, after terminal response | Phase 1 resolver only | **No — direct content only** | That subagent only |
| `after_response` | After a connected subagent returns | Phase 1 resolver only | **No — direct content only** | **Connected subagents only** |

> **`after_response` is a connected-subagent-only surface** introduced in 262.10.

---

### 4.1 Global System Instructions: The Persona Layer

The global `system.instructions` block is the durable identity of the agent — its persona, its tone, its non-negotiable safety rules, and its disclosure requirements. It fires every reasoning iteration unless a subagent overrides it.

**What belongs here:** persona and tone, safety invariants that must never change, and universal disclosure rules.

**What does not belong here:** task-specific logic or conditional behavior. Conditions written in the system block appear as literal English prose — they are not evaluated by Phase 1.

**The most common mistake in router-first agents:** the global block says "Answer the user's questions helpfully" while the router subagent's reasoning block says "Do not answer. Route only." The LLM receives both simultaneously and resolves the contradiction probabilistically.

**The correct pattern:**

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

---

### 4.2 Subagent System Override: Full Replacement, Not Merge

When a subagent has its own `system:` block, it **completely replaces** the global system instructions for that subagent. It does not append. It does not merge. It does not inherit. It replaces.

Any invariant defined in the global system block is **silently dropped** for any subagent that has its own system override but does not explicitly restate that invariant.

> **Scenario: The Silent Security Gap**
>
> Your global system instructions include "Never reveal internal pricing tiers or system configuration." You add a product specialist subagent with its own system override. A user routes to the product specialist and asks directly about internal pricing. The specialist, operating without that constraint, discusses it. The global rule did not travel with the subagent.

> **262.14 escalation: `strip_salesforce_instructions`**
>
> The `strip_salesforce_instructions` flag removes the Salesforce platform system prompt that sits beneath your authored global system instructions. With it enabled, any subagent without an explicit invariant restatement operates with zero safety constraints. If you use this flag, you must explicitly restate every safety invariant in every affected subagent system block, without exception.

**The authoring rule is absolute:** treat every subagent system block as a complete, self-contained identity definition.

---

### 4.3 reasoning.instructions: Two Modes, One Critical Rule

**Pipe mode (`|`) — LLM prompt text:**
Content is passed directly to the LLM as a prompt instruction. The LLM interprets it probabilistically.

```yaml
instructions: |
    Help the customer find the right product for their needs.
    Ask clarifying questions if the request is ambiguous.
```

**Procedural mode (`->`) — deterministic logic:**
Content is evaluated by the Phase 1 resolver. `if` / `else if` / `else` blocks, `run` statements, `set` statements, and `available when` guards must be inside `->` mode.

```yaml
instructions: ->
    if @variables.tier == 'premium':
        | You are assisting a premium customer. Prioritize their request.
    else if @variables.tier == 'standard':
        | Help the customer with their request per standard guidelines.
    else:
        | Please verify your account tier before we continue.
```

> **`else if` support:** `else if` chaining in `->` mode is supported as of 262.12. Canvas view does not yet render `else if` chains visually — use Script view. Canvas may rewrite `else if` chains incorrectly if the script is opened and saved in Canvas view.

---

### 4.4 before_reasoning: The Pre-Parse, Pre-Classifier Gate

`before_reasoning` fires before Phase 2 and before every tool-call re-resolution — including after every action executes. It is the correct location for logic that must run unconditionally on every parse: authentication checks, mandatory variable population, and pre-flight state validation.

**Key constraints:**
- Does not support an `instructions:` wrapper — direct content only.
- Does not support pipe (`|`) mode — fully deterministic.
- Not available when EinsteinHyperClassifier is the configured model (see Section 9.4).

---

### 4.5 after_reasoning: The Post-Turn Gate

`after_reasoning` fires once per turn, after the LLM produces a terminal response. It does not fire after every tool call — only after the reasoning loop concludes with a user-facing response.

**Two critical bypass cases — logic in after_reasoning will NOT execute when:**

**Case 1:** a subagent transitions mid-reasoning via `@utils.transition to`. No terminal response means no `after_reasoning` trigger.

**Case 2:** an action has `is_displayable: True` set. The platform exits the reasoning loop immediately, and `after_reasoning` never executes.

**Recommended mitigation for both cases:** move logic that must execute reliably into the `before_reasoning` block of the subsequent subagent.

**Syntax constraint:** `after_reasoning` does not support an `instructions:` wrapper.

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

`after_response` fires after a connected (external or BYON) agent returns control to the orchestrator. A connected subagent runs its reasoning loop remotely — the orchestrator never ran a local reasoning loop — so there is no `after_reasoning` to trigger. `after_response` fills that gap.

**Accepted statements:** `run`, `set`, `if`, and `transition`. Pipe (`|`) instructions are explicitly disallowed.

---

## 5. Variables and State in the Reasoning Loop

### 5.1 Mutable vs. Linked Variables

Agentforce variables are either mutable (writable via `set` statements in Agent Script) or linked (read from external data sources at resolution time). Mutable variables are the primary state management mechanism. Linked variables provide read access to record fields without requiring an explicit action call.

---

### 5.2 The Four Scope Zones

Agentforce defines four distinct variable scopes, each holding a different kind of value and valid in a different context.

**`@variables.X` — Session-persistent state**
Valid anywhere in Agent Script logic and injectable into pipe text via `{!@variables.X}`. Persists for the life of the session unless explicitly overwritten.

**`@outputs.X` — Action return values**
Valid **only** in `set` and `if` statements immediately after the action's `run` block. The scope expires when those statements complete.

**`@inputs.X` — Action input values**
Valid **only** in `with` clauses during action invocation. Scope expires when the `with` clause finishes.

**`@system_variables.X` — Read-only platform context**
Predefined, read-only variables populated by the platform at the start of every inbound turn.

| Variable | Populated | Description |
|---|---|---|
| `@system_variables.current_modality` | Turn start (262.12) | The channel modality, e.g. `"voice"` or `"text"`. |
| `@system_variables.current_connection` | Turn start (262.12) | The connection identifier for the current inbound session. |
| `@system_variables.last_reply.interrupted` | Turn start (262.14, voice) | Boolean — whether the agent's last reply was interrupted by the user. |
| `@system_variables.last_reply.interrupted_heard_text` | Turn start (262.14, voice) | The portion of the agent's last reply the user heard before interrupting. |

---

### 5.3 The Silent Failure Zone

`@inputs` and `@outputs` scope violations are the most dangerous bugs in Agent Script development — dangerous precisely because they produce no error and no obvious symptom. The action executes successfully. The variable simply does not get set.

**How to catch this in traces:** a `FunctionStep` that completes with no difference in the `postVars` section (the before/after variable state comparison) is the diagnostic indicator of a scope violation.

**Prevention:** capture every needed output value immediately in `set` statements directly under the `run` block.

---

### 5.4 Variable Persistence Across Subagents

`@variables` persist across subagent transitions. A value set in Subagent A is fully available when Subagent B takes control. This is the primary mechanism for passing state through a multi-subagent workflow without external storage.

> **Scenario: Verify Once, Carry Forward**
>
> An authentication gate verifies the customer and sets `@variables.is_verified = True` and `@variables.customer_id`. When the router transitions to order management, those variables are already there. The order management subagent's `before_reasoning` block checks `@variables.is_verified` — it is `True` — and makes order-specific actions available. The customer never re-verifies.

---

### 5.5 The setVariables Slot-Fill Utility

`@utils.setVariables` is the LLM-driven slot-filling utility that tells the agent to define a variable based on a natural language description.

```yaml
reasoning:
    actions:
        set_first_name_variable: @utils.setVariables
            with first_name =...
            description: "Get the user's first name"
```

**When to use `setVariables`:** appropriate when the goal is to collect a specific value through natural conversation before any downstream action runs. It does not consume action credits.

---

### 5.5.1 ask for: Structured Variable Capture (Pilot)

*(Introduced as `collect` in 262.12; renamed `ask for` in 262.14.)*

`ask for` is a structured variable capture statement that gathers one variable at a time from the user in a controlled, resumable way.

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

**Features:** if-branching, auto-resume when the user provides extra information, and cancel/change-of-intent handling. The `instructions: guidance` block accepts paraphrasable natural language.

> **Pilot caveat:** syntax may still change before general availability. Validate against the current Agent Script compiler before relying on this feature in production.

---

### 5.6 The Three Input Binding Patterns

| Pattern | Syntax | When Resolved | Security Risk |
|---|---|---|---|
| LLM slot-fill | `with param =...` | Phase 2 | High — LLM extracts from user input |
| Variable binding | `with param = @variables.X` | Phase 1 | None — value from verified session state |
| Literal value | `with param = 'fixed'` | Phase 1 (compile-time) | None — constant |

> **262.10 default slot-fill behavior:** if an action input is marked `is_required: true` and has neither a `default` value nor a `with` clause, the compiler now automatically marks it `slot_filled_by: LLM`. **Audit your action definitions for required inputs without explicit binding.**

---

## 6. Actions and the Reasoning Loop

### Actions as the Bridge to the Real World

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

**LLM-driven invocation (`reasoning.actions` block):** the LLM decides whether and when to call the action. The action appears in the LLM's tool schema.

**Deterministic invocation (`run @actions.X`):** the action fires unconditionally when the code path is reached during Phase 1. The LLM is not involved in the decision.

The same action definition can be used both ways. The invocation mode is determined by context, not by the action definition itself.

---

### 6.2 The Four Action Chaining Patterns and Parallel Tool Calling

**Pattern 1: Sequential `run` blocks (fully deterministic)**

Actions execute in a fixed, top-to-bottom order during Phase 1. No LLM iteration consumed.

```yaml
instructions: ->
    run @actions_account
        with account_id = @variables.account_id
        set @variables.account_data = @outputs.account
    run @actions.calculate_risk
        with account = @variables.account_data
        set @variables.risk_score = @outputs.score
    run @actions.generate_offer
        with risk = @variables.risk_score
        set @variables.offer = @outputs.offer_text
```

**Pattern 2: LLM-sequenced actions**
Actions listed in `reasoning.actions` are offered to the LLM as tool schemas. The LLM decides the order. Use when sequencing requires conversational judgment.

**Pattern 3: Conditional chaining**
Use Phase 1 `if` logic to gate which `run` blocks fire based on earlier action results.

**Pattern 4: Parallel tool execution**
The LLM can plan multiple tools simultaneously when the `parallel_tool_execution` parameter is enabled. Sequential execution is the default to maintain data atomicity across Salesforce workflows.

**State isolation for parallel tools:** when the LLM selects multiple tools to run concurrently, MGR **clones the active state container into independent instances** for each tool so they cannot pollute one another mid-run. At the conclusion of the parallel tool step, states are rejoined using **Last-Write-Wins (LWW)** resolution logic: the last tool to complete writes its state changes, overwriting any conflicting changes from concurrently executing tools.

> **Authoring implication for parallel calls:** if two parallel tools both write to the same `@variables.X`, only one write survives — whichever finishes last. Design parallel tool workflows so each tool writes to distinct variables. Custom merge strategies are under active development and are not yet available.

**The action loop problem:** the platform does not automatically suppress an action after it has been called once. If `available when` remains True after the action runs and the reasoning instructions are ambiguous, the LLM will call the same action on every parse. Close the gate deterministically after execution.

---

### 6.3 available when: Hard Filter, Not Soft Hint

`available when` is a Phase 1 gate that controls whether an action appears in the LLM's tool schema. If the condition evaluates to `False`, the action is invisible to the LLM — not just deprioritized.

**Lint hardening (262.10):** the compiler now flags `available when` conditions that resolve to non-boolean literals at compile time.

---

### 6.4 The Four Transition Mechanisms

*(Renamed from "The Three Transition Mechanisms" — `escalate` added as of 262.14, `connected_subagent` as transition target added as of 262.10)*

| Mechanism | Valid Context | LLM Involved | Direction | Notes |
|---|---|---|---|---|
| Bare `transition to @subagent.X` | `before_reasoning`, `after_reasoning`, `reasoning.instructions ->` | No | One-way | Standard local and connected subagents |
| `@utils.transition to @subagent.X` | `reasoning.actions` only | Yes | One-way | Standard local and connected subagents |
| `@subagent.X` as action reference | `reasoning.actions` only | Yes | Returns to caller | Standard local subagents only |
| `escalate` statement | Top-level or `reasoning.instructions` | No | One-way, single-fire | Cannot loop — correct choice for escalation paths |

**The `escalate` statement (262.14):** deterministic and single-fire. Unlike a `transition to` inside a looping `before_reasoning` block, `escalate` cannot re-fire on subsequent parses. This makes it the correct choice for escalation paths that must not loop.

```yaml
instructions: ->
    if @variables.sentiment_score < 0.2:
        escalate
```

---

### 6.5 Handoff vs. Delegation

**Handoff (`@utils.transition to`):** control transfers completely to the called subagent. The caller does not resume. Use when the destination should completely own the user experience from that point forward.

**Delegation (`@subagent.X` as action reference):** the parent orchestrates, the child runs its full reasoning loop and produces a result, and control returns to the parent. Use when the parent needs to coordinate across multiple children or incorporate results into a unified response.

**`delegate_escalation` on connected subagents (262.12):** when `True`, any escalation triggered within the connected subagent uses the connected subagent's own outbound escalation flow. When `False`, escalation delegates back to the orchestrator's escalation flow.

---

### 6.6 The Zero-Hallucination Routing Pattern

Combining `filter_from_agent: True` and `is_used_by_planner: True` on a classification action's output forces the LLM to actually call the classification action to obtain the routing value — it has no cached or hallucinated value to use.

---

### 6.7 Inline Skills (Pilot)

*(New in 262.14)*

Skills are defined in a top-level `skill_definitions` block and attached per-node via `reasoning.skills`, directly mirroring the `reasoning.actions` pattern. Skills encapsulate reusable reasoning instructions; actions invoke external systems. A subagent can use both in the same turn.

```yaml
skill_definitions:
    summarize_case:
        instructions: |
            Summarize the key facts of the customer's case in three bullet points.

    de_escalation_phrasing:
        target: skill://shared-de-escalation-v2
```

---

### 6.8 Subgraphs and Supervision Calls

*(Distinct from Transitions and Delegation — see also Section 6.5)*

A **subgraph** (also called a supervision call) allows a developer to instantiate and run an entire auxiliary graph execution structure natively, as if it were a simple tool call. This is different from both transitions and delegation.

**The structural distinction:**

| Mechanism | What happens to the user context | Control return |
|---|---|---|
| Transition | User is fully dropped into a new node space | Does not return to caller |
| Delegation (`@subagent.X`) | Parent calls child, child runs locally, returns result | Returns to parent |
| Subgraph / Supervision | Parent consults a child specialist graph running its own isolated execution | Returns isolated response payload to parent |

The key difference between delegation and a subgraph is isolation. In delegation, the child subagent runs within the parent's graph context. In a subgraph call, the child graph executes as a fully separate graph structure with its own state, and the parent receives a clean, isolated response payload — which it then interprets and delivers to the user in its own voice.

> **Use case:** a customer-facing service agent needs a complex eligibility determination that involves proprietary logic housed in a separate internal specialist graph. Rather than transitioning the user to that graph (which would break conversational continuity), the service agent invokes the specialist graph as a subgraph, receives the eligibility decision as a payload, and communicates the outcome to the user directly.

**Conversation history in subgraphs:** currently, conversational history passes globally into subgraph executions. A feature rollout is in progress to allow isolated supervisor graphs to execute with completely clean history arrays — useful for scenarios where the specialist graph should not have access to the full prior conversation.

**Relationship to BYON:** Bring Your Own Node configurations (Section 8.5) can be invoked within subgraph patterns, allowing custom Docker-based logic to participate in the supervision call flow.

---

## 7. The start_agent Subagent and Turn Restart Behavior

`start_agent` is the mandatory entry point for every turn. Every turn begins at `start_agent` regardless of which subagent handled the previous turn. The `before_reasoning` block on `start_agent` is the correct location for mandatory initialization logic that must run before topic classification — session variable population, authentication state checks, and required context loading.

**Turn restart behavior:** when a transition returns to a subagent that has already been visited, execution begins at the **beginning** of that subagent — not where it last left off. There is no resume-from-checkpoint for standard subagent transitions.

---

### 7.5 Goal-Based Agents: Beyond the Turn Model (Pilot)

*(Pilot in 262.14)*

Goal-Based Agents (GBA) operate outside the standard turn-based model. Instead of waiting for user utterances and responding turn-by-turn, a GBA agent pursues a declared goal through a structured workflow, potentially over an extended period, with no human in the loop for individual steps.

GBA is gated behind `config.agent_type: "GoalBasedAgent"` and introduces distinct constructs:

```yaml
config:
    agent_type: "GoalBasedAgent"

workflows:
    daily_account_review:
        trigger:
            cron: "0 8 * * 1-5"
        orchestrator:
            # Orchestration logic here
```

| Block / Construct | Purpose |
|---|---|
| `workflows:` | Declares one or more named workflows. |
| `trigger:` | Defines what activates a workflow. `cron:` enables scheduled execution. |
| `orchestrator:` | Contains orchestration logic for the workflow. |
| `# @dialect: agentforce-plugin` | Pragma marking a file as an Agentforce plugin. |
| `@plugins.<name>.*` | References a plugin's exported capabilities. |

**Hard gating:** `workflows`, `trigger`, and `orchestrator` blocks produce a hard compile error if they appear in a standard agent script.

---

## 8. The Module Graph Runtime and Session Architecture

### Overview

The Module Graph Runtime (MGR) is the Python-based library that implements the Daisy++ unified planner. It is the concrete execution engine that carries out the agent harness configuration described in Section 1.6. Understanding MGR is important for engineers debugging platform-level issues, building BYON extensions, or working with the Unified Spec format.

---

### 8.1 MGR Overview

**Library characteristics:**
- Installable via standard Python `pip install`.
- Highly unopinionated and flexible — ships without built-in hardcoded system prompts.
- Built entirely on **Pydantic objects**, meaning complex execution graphs can be authored in standard JSON or YAML specifications without modifying library source code.
- Lightweight footprint; can be run as a standalone library outside the full Salesforce infrastructure for local testing purposes.

**Configuration-driven design:** the MGR's graph authoring model is declarative. An engineer defines nodes, edges, tool schemas, and state transitions in configuration files. The library executes the graph according to the specification. This is the mechanism that allows Agent Script to be translated into an executable plan without requiring custom code for each agent.

---

### 8.2 The Unified Spec Transformation

The Unified Spec is the runtime-internal representation of an agent's configuration. Understanding its evolution explains some platform behaviors and debugging approaches.

**The transformation chain:**

1. **`planner_config`** — the original, massive metadata file bundle used by the legacy Java planner. Dense, Salesforce-specific, difficult to extend.
2. **`agent.json`** — introduced by Daisy. A cleaner abstraction of the same configuration data, separating the agent specification from platform internals.
3. **Unified Spec** — introduced by Daisy++. The `agent.json` is ingested and translated over-the-wire into the Unified Spec, which strips away Salesforce-specific vocabulary and terminology. This translation happens dynamically at runtime, not at compile time.

**Why the Unified Spec strips Salesforce terminology:** the Unified Spec is designed to be platform-agnostic, paving the way for potential future open-sourcing of the MGR library. An agent graph described in the Unified Spec could, in principle, be executed by any MGR-compatible runtime — not just Salesforce's implementation.

**Practical implication for debugging:** when examining low-level runtime traces, you may see references to Unified Spec fields that do not map 1:1 to Agent Script constructs. The translation layer between `agent.json` and Unified Spec is where some field-naming discrepancies originate.

---

### 8.3 System Injection Behavior

During the translation from `agent.json` to the Unified Spec, the engine automatically injects hidden tools into the runtime graph. These are not authored by developers — they are inserted by the platform.

**The two injected tools:**

- **`user_select_record_tool`** — handles record disambiguation when the LLM must present multiple record options to the user for selection. Controls the UI component that renders record selection cards.
- **`show_tool_results`** — controls how tool output is surfaced and rendered in the UI.

These are legacy holdovers designed to match the behavior of the original Java engine and to render standard UI components on supported surfaces.

> **The 90% field bug statistic:** approximately 90% of field bugs where a UI card fails to render or input values are silently dropped trace back to prompting failures — specifically, the LLM choosing not to call one of these injected system tools when it should. The LLM skips them because it does not have sufficient instruction to recognize when they are required, or because a conflicting instruction discourages tool calls.

**The authoring implication:** if your agent is experiencing missing cards or dropped input values in production, check whether your `reasoning.instructions` prompt contains language that might cause the LLM to skip tool calls. Phrases like "respond directly" or "answer without looking anything up" can inadvertently suppress the LLM's selection of injected system tools. These tools do not appear in your authored script — you cannot see them — which makes this category of bug particularly hard to identify without knowing about the injection behavior.

---

### 8.4 Sticky Flowcharts and reset_to_initial_node

The `reset_to_initial_node` flag in `config.runtime` controls whether the conversation returns to the root intent classifier router node after each turn.

**Default behavior (`reset_to_initial_node: true`):** after every turn, the conversation resets to the front-door router node. The intent classifier re-evaluates the user's next message from the root. This is the standard topology: every turn starts fresh at the router, which directs to the appropriate specialist.

**Sticky flowchart behavior (`reset_to_initial_node: false`):** the conversation remains locked inside the currently active node across subsequent turns. The router is bypassed. The subagent that handled the previous turn continues to handle subsequent turns until an explicit handoff condition triggers a transition.

**When to use sticky flowcharts:**

- Multi-turn data collection sequences where the same specialist subagent must maintain context across several user messages.
- Confirmation flows where the agent must hold the user inside a specific decision branch until the user confirms or cancels.
- Complex workflows with branching logic that should not be disrupted by the router re-classifying a mid-workflow utterance as a different intent.

**When NOT to use sticky flowcharts:**

- General-purpose agents where users need to freely switch topics.
- Any scenario where the user's next utterance could legitimately trigger a different specialist.

> **Anti-pattern:** using sticky flowcharts as a shortcut to avoid designing proper transition logic. If the flowchart remains sticky indefinitely and no transition condition ever fires, the user is permanently locked in the current node — producing an agent that appears unresponsive or broken for any topic outside the current specialist's scope.

---

### 8.5 Bring Your Own Node (BYON)

BYON is the mechanism for introducing custom programming frameworks — Python libraries, multi-LLM consensus patterns, proprietary computation engines — into the MGR execution flow without rewriting that logic as standard Agentforce actions.

**Deployment pattern:**
1. Custom logic is bundled as a **standard Docker container**.
2. The container is deployed via Salesforce's **Internal Computing Services (ICS)** on a managed **Kubernetes** cluster.
3. The container exposes endpoints that the MGR runtime can call.

**Runtime execution:** as the master graph executes and enters a BYON node, request payloads are proxied directly to the container. The local logic block executes, returns raw JSON results to the reasoning layer, and Daisy++ manages downstream tool integrations and state updates from that point forward.

**What BYON is suited for:**
- Heavy Python library dependencies (ML models, scientific computing) that cannot run in a standard Salesforce execution environment.
- Multi-LLM consensus architectures where multiple models vote on a response.
- Proprietary algorithms or legacy code that cannot be refactored into Apex or Flow.

**What BYON is not:**
- A replacement for standard actions when a Flow or Apex action can fulfill the requirement.
- A low-latency solution — Docker container invocation adds round-trip overhead.

**Relationship to `after_response`:** when a BYON node completes and returns control to the orchestrator, the `after_response` surface (Section 4.5.1) fires, allowing the orchestrator to inspect the return payload and route accordingly.

---

### 8.6 Session Architecture: Redis and State Hydration

The Daisy++ reasoning tier is **entirely stateless and multi-tenant**. No data is permanently preserved in local application service memory. This is a fundamental architectural constraint that shapes all state management design decisions.

**How state works across turns:**

On every incoming conversation turn, the system must hydrate the agent's current state from an external cache layer powered by **Redis**. The full session state — `@variables`, turn history, graph position, any serialized pause-state from an Execution Pause Check — is loaded from Redis at the start of each turn and written back to Redis at the end.

**Redis session TTL:** Redis maintains an explicit session Time-To-Live of **7 days**. A session that goes inactive for more than 7 days is expired. The user's `@variables` state is lost. Any subsequent interaction begins as a new session.

**Long-running sessions:** true persistent sessions that extend beyond the 7-day TTL — for use cases like week-long onboarding workflows or ongoing background monitoring agents — are on the product roadmap but are not yet available at time of publication.

**Design implications:**

- Never design a critical workflow that assumes session state will survive more than 7 days without a turn.
- For workflows that require durable state beyond the TTL, write critical state to a Salesforce record (via a Flow or Apex action) rather than relying solely on `@variables`.
- The stateless architecture is why the Execution Pause Check (Section 3.4) can safely serialize and pause mid-execution — the entire state is designed to be serialized to Redis and reconstituted.

**Streaming and write-back ordering:** tokens stream to the client before the Redis write-back occurs. In a voice scenario, the user may hear the agent's response while the state write is still in flight. Design for the possibility that a connection drop immediately after a response could result in state not being persisted.

---

### 8.7 The Agents API and the A2A Roadmap

**Current architecture:** multiple client layers connect to the stack through an Agents API proxy. A legacy Java planner stack intercepts and proxies the core `start_session`, `continue_session`, and `end_session` calls to the underlying Python/FastAPI-based reasoner service (Daisy++). This adds middleware hops for every turn.

**Agents API v2:** a planned simplification that will expose **Agent-to-Agent (A2A)** communications natively with fewer middleware hops. A2A enables agents to call other agents as first-class orchestration primitives, without the current proxy overhead.

**What A2A changes for architects:** with A2A natively exposed, multi-agent orchestration patterns that currently require BYON or connected subagent workarounds will have a cleaner, lower-latency path. Agents designed using the delegation pattern (Section 6.5) will be well-positioned to adopt A2A without significant rearchitecting.

---

## 9. The EinsteinHyperClassifier

### 9.1 What HyperClassifier Is

EinsteinHyperClassifier is a specialized classification model optimized for topic routing speed. It replaces the standard LLM at the routing decision point, dramatically reducing latency for subagent selection. Instead of running a full LLM reasoning pass to classify intent, HyperClassifier produces a routing decision via single-token prediction.

---

### 9.2 How It Works: Single-Token Prediction

HyperClassifier produces its routing decision as a single token — a direct selection of the target subagent. This bypasses the full prompt assembly and reasoning loop that a standard LLM routing decision requires. The classification is purely semantic: HyperClassifier matches the user's utterance against the descriptions and example utterances of available subagents.

---

### 9.3 HyperClassifier Limitations

HyperClassifier's specialization comes with hard constraints:

- **Cannot use `before_reasoning`** — the block is not executed.
- **Cannot use `after_reasoning`** — the block is not executed.
- **Can only use `@utils.transition` as a tool** — no other tools or actions are available in the `reasoning.actions` block.

These constraints apply at the subagent level. A subagent configured to use EinsteinHyperClassifier operates under all three restrictions simultaneously.

---

### 9.4 The HyperClassifier and before_reasoning Paradox

**The advisory recommends:** for logic that must execute unconditionally before topic selection, use `before_reasoning` on `agent_router`.

**The constraint states:** when EinsteinHyperClassifier is the model for a subagent, `before_reasoning` cannot be used on that subagent.

**The resolution:** if your agent requires mandatory pre-classification logic, you **cannot use EinsteinHyperClassifier as the model for `agent_router`**.

**Why the state-based routing workaround fails:** HyperClassifier selects the topic first based on semantic relevance. If a user asks a business question, HyperClassifier routes to the relevant business topic — and a `RunningUserValidated == False` condition on the User Verification topic is evaluated afterward, too late to intercept.

**HyperClassifier diagnostic improvements (262.10):** when `before_reasoning` or `after_reasoning` blocks are present on a HyperClassifier-configured subagent, the compiler now identifies the incompatibility and points to the appropriate alternative.

**The correct design decision matrix:**

| Need | Correct model for agent_router |
|---|---|
| Maximum classification speed, no mandatory pre-classification logic | EinsteinHyperClassifier |
| Mandatory pre-classification logic (auth, session init, required vars) | Standard LLM |
| Both mandatory logic AND fast classification | Standard LLM on agent_router; HyperClassifier on specialist subagents only |

---

## 10. The Posture Spectrum

### 10.1 Agentic, Mixed, and Scripted

Every Agentforce agent sits somewhere on a spectrum between fully agentic (pure LLM reasoning, maximum flexibility, minimum determinism) and fully scripted (pure deterministic logic, maximum reliability, zero LLM judgment). Most production agents are mixed — deterministic for the steps that require reliability and compliance, agentic for the steps that require conversational intelligence.

---

### 10.2 The Five Justifications for Determinism

Use deterministic control whenever one or more of the following applies:

1. **Safety invariant** — the step must always produce the same result regardless of input.
2. **Compliance requirement** — an auditor needs a record that a specific step always fired.
3. **Security gate** — a verified identity or permission check that must not be LLM-interpretable.
4. **Cost constraint** — the step does not require judgment and consuming an LLM iteration is wasteful.
5. **Reproducibility requirement** — the step must produce identical results on identical inputs.

---

### 10.3 The Three Control Primitives

The three primitives for implementing deterministic control in Agent Script are:

1. **`run @actions.X` in Phase 1** — unconditional action execution.
2. **`if` / `else if` / `else` in `->` mode** — conditional logic evaluated before any LLM involvement.
3. **`available when` guards** — hard schema filtering that prevents the LLM from even seeing an action.

---

### 10.4 The Minimal Instructions Principle

The LLM performs better with fewer, clearer instructions than with more, noisier ones. Every instruction you add to a prompt is a potential source of contradiction with another instruction. The minimal instructions principle: give the LLM exactly what it needs to make the decision you are asking it to make — nothing more.

---

## 11. The Einstein Trust Layer

### 11.1 What It Is and When It Operates

The Einstein Trust Layer (ETL) is a runtime security boundary that wraps every LLM call. It operates at two points: before the LLM receives a prompt (input screening and grounding enforcement) and after the LLM produces a response (output toxicity scoring and data masking review).

---

### 11.2 The Zero-Retention Policy

The ETL enforces a zero-data retention policy with external partner model providers such as OpenAI and Azure OpenAI. This policy has three commitments from the provider:

1. **No training use** — data is not used for model training.
2. **No retention** — data is not retained after a response is sent back to Salesforce.
3. **No human review** — no human at the provider sees data sent to their LLM.

**Important scope qualification:** this policy applies specifically to external partner model providers. Models built or fine-tuned by Salesforce and hosted within Salesforce's trust boundary operate under different terms.

---

### 11.3 Data Permissions and Content Screening

**Secure Data Retrieval:** when prompts are grounded with CRM data, the ETL enforces that grounding respects the executing user's permissions. Field-level security and role-based access controls are enforced at grounding time.

**Data Masking:** the ETL includes data masking that detects sensitive data in prompts before they are sent to the LLM, replacing it with placeholder text.

> **Critical production note:** data masking for LLMs is **disabled for agents**. Authors building Agentforce agents must not rely on ETL data masking as a PII protection mechanism in agent conversations.

**Prompt Defense:** the ETL applies system policies to decrease the likelihood of unintended or harmful outputs, defending against jailbreaking and prompt injection attacks.

**Toxicity Scoring:**

- **Toxicity Detection in Responses** — enabled by default, non-configurable. Every LLM response is graded on a scale from `0` to `1` across categories such as hate speech, violence, and harassment, plus a boolean `isToxicityDetected` flag.
- **Toxicity Detection in Prompts** — opt-in. Must be manually enabled in Setup. Prevents users from submitting toxic or adversarial inputs.

The `GenAiGatewayRequest__dlm` stream in Data Cloud tracks these via `enableOutputSafetyScoring__c` (defaults to `true`) and `enableInputSafetyScoring__c` (defaults to `false`).

---

## 12. Reasoning Constraints

### Why Constraints Exist

Every runtime system has hard limits. In Agentforce, those limits prevent runaway loops, protect platform stability, and keep billing predictable.

---

### 12.1 The Bounded Loop Iteration Limit

The Atlas Reasoning Engine enforces a bounded iteration ceiling on LLM-driven reasoning loops. When that ceiling is reached, the engine breaks out of the loop and returns control to the subagent router.

> **On the specific number:** the exact platform ceiling is not publicly documented by Salesforce. Design subagents with the understanding that chains of sequential LLM-driven action calls must be kept short.

**What counts as an iteration:** each Phase 1 + Phase 2 cycle is one iteration. Deterministic `run` blocks within Phase 1 do not consume iterations.

**The three failure patterns this limit produces:**

1. **Incomplete task execution** — the workflow did not finish before the ceiling was reached. The user receives no useful response.
2. **Unexpected router return** — the agent returns to the router mid-workflow, confusing the user.
3. **Silent state corruption** — variables were partially updated before the limit was hit, leaving state in an inconsistent condition for the next turn.

**The fix:** move deterministic sequential steps to `run` blocks in Phase 1. Reserve `reasoning.actions` for steps that genuinely require LLM judgment.

---

### 12.2 Flex Credits and Token Consumption

Each LLM call consumes Flex Credits based on token volume. Deterministic `run` block executions do not consume Flex Credits. This is the cost-efficiency argument for the hybrid model: every step moved to deterministic execution is a step that does not consume credits.

---

## 13. Debugging, Triage, and Diagnostics

### 13.1 Telemetry Stack

System exceptions and execution events are tracked across three overlapping telemetry systems:

- **Monitoring Cloud (Internal DataDog):** captures trace IDs for individual execution events. Use these to identify the exact point in the pipeline where a failure occurred.
- **Splunk (under the "Agentic Reasoner" flag):** captures service-level logs under the official service identifier name `Agent Service Agentic Reasoner`. Splunk is the primary log destination for pipeline-level errors.
- **Salesforce Trace Diagnostics (STDM):** the standard Salesforce trace mechanism, which captures agent execution events within the Salesforce platform boundary. Useful for org-level debugging and audit.

For most field debugging scenarios, starting in STDM and escalating to Splunk or DataDog for platform-level issues is the recommended workflow.

---

### 13.2 Draft vs. Published Discrepancies

Uncommitted (draft) agents execute differently from their published counterparts in one critical way:

- **Draft mode:** runs fully non-streamed requests. The complete response is assembled before any tokens are sent to the client.
- **Published mode:** uses native event-stream loops. Tokens stream to the client as they are generated.

This architectural difference means that behaviors sensitive to streaming timing — including some surface rendering decisions and state write-back ordering — may behave differently in draft mode than in production. Additionally, local actions may encounter validation issues across these boundaries if they rely on streaming-specific behavior.

> **Best practice:** always validate agent behavior in a published sandbox environment before releasing to production. Draft-mode testing is useful for fast iteration but is not a reliable proxy for production streaming behavior.

---

### 13.3 Automated Triage Scripting

The engineering team has released an automated command-line script utility inside the chatbots monorepo workspace. This tool automates the first-pass triage of agent execution failures.

**How to use it:**
1. Obtain a valid Session ID for the failing session from STDM or Monitoring Cloud.
2. Provide the Session ID to the script via a terminal linked to Monitoring Cloud and Code Search CLI utilities.
3. The script evaluates execution logic to flag compilation errors or prompting flaws.

**Accuracy:** approximately 80% of compilation errors and prompting flaws are identified correctly. The remaining 20% require manual trace inspection.

**Where to find it:** the script toolkit is located inside the chatbots monorepo workspace. Refer to the FDE resource hub for the current link and usage instructions.

---

### 13.4 Reading Session Traces

Session traces are the primary debugging artifact for understanding what happened inside a specific turn.

**Key trace elements:**

- **`FunctionStep`** — records the execution of an action. Includes a `preVars` and `postVars` section showing variable state before and after the action ran.
- **`postVars` with no change** — the diagnostic indicator of an `@outputs` scope violation (Section 5.3). The action ran; nothing was captured.
- **`LLMStep`** — records each Phase 2 LLM call, including the resolved prompt the LLM received and the tool call or response it produced.
- **Multiple `LLMStep` entries with no clean response** — indicates the reasoning loop was terminated by the bounded iteration ceiling (Section 12.1).
- **Missing injected tool calls in `LLMStep` tool selections** — indicates the LLM skipped `user_select_record_tool` or `show_tool_results`, which explains missing UI cards (Section 8.3).

---

## 14. Reasoning Anti-Patterns

### Anti-Pattern 1: Pipe-Mode Conditionals

Using `|` mode to write conditional instructions as English prose rather than using `->` mode with actual `if` / `else if` / `else` evaluation.

*Signal:* intermittent behavior where the agent sometimes follows an instruction and sometimes ignores it.

*Fix:* convert `|` mode conditionals to `->` mode `if` / `else if` / `else` blocks.

---

### Anti-Pattern 2: Invariants Lost Through Subagent System Override

Adding a subagent-level `system:` block for specialization without restating safety invariants from the global system block.

*Signal:* a subagent with its own system block that does not contain the same confidentiality, disclosure, and safety rules as the global block.

*Fix:* treat every subagent system block as a complete, standalone identity definition. Doubly critical when `strip_salesforce_instructions` is active.

---

### Anti-Pattern 3: Scope Violation Chains

Referencing `@outputs.X` or `@inputs.X` outside their valid scope windows.

*Signal:* a `FunctionStep` with no change in `postVars`, followed by downstream behavior that ignores the action result.

*Fix:* capture all needed outputs immediately in `set` statements directly under the `run` block.

---

### Anti-Pattern 4: Sensitive Parameters via Slot-Fill

Using the `...` ellipsis on action parameters that represent verified identities or sensitive record IDs.

*Signal:* `with customer_id =...` or `with account_id =...` where that ID should come from authenticated session state; or any `is_required` input with no `with` clause in an action that handles sensitive data.

*Fix:* pin sensitive parameters to `@variables` populated during verified authentication.

---

### Anti-Pattern 5: LLM Action Chains Longer Than a Few Sequential Steps

Designing a subagent that requires a long sequence of LLM-driven action calls.

*Signal:* session traces showing the reasoning loop terminated with multiple `LLMStep` entries and no clean user response.

*Fix:* move deterministic sequential steps to `run` blocks in Phase 1.

---

### Anti-Pattern 6: Global System Instructions That Contradict Subagent Posture

A global instruction that directs the LLM to behave one way while a routing or scripted subagent requires different behavior.

*Signal:* a router subagent that occasionally answers questions directly instead of routing.

*Fix:* write the global system instruction in a posture-neutral way. Move task-specific direction into `reasoning.instructions`.

---

### Anti-Pattern 7: State-Based Routing to Enforce Mandatory Pre-Classification Logic

Relying on a state-based routing condition on a semantically unrelated topic to intercept all turns before a business topic runs, when HyperClassifier is active.

*Signal:* intermittent failures where mandatory verification logic is skipped.

*Fix:* use `before_reasoning` on `agent_router`. If HyperClassifier is required, use a standard LLM on `agent_router` and confine HyperClassifier to specialist subagents.

---

### Anti-Pattern 8: Transitions in before_reasoning Without Guards

An unconditional `transition to` in `before_reasoning` fires on every parse — including after every tool call — creating an infinite routing loop.

*Signal:* an agent that routes correctly on the first turn but enters an unresponsive loop on subsequent turns.

*Fix:* always wrap `transition to` in `before_reasoning` inside an `if` condition. For fixed escalation targets that must not loop, use the `escalate` statement instead.

---

### Anti-Pattern 9: Ignoring Injected System Tools in Prompt Design

Writing `reasoning.instructions` prompts that inadvertently suppress the LLM's selection of injected system tools (`user_select_record_tool`, `show_tool_results`), resulting in missing UI cards or dropped input values.

*Signal:* UI cards that do not render; input collection that silently drops values. Affects approximately 90% of missing-card field bugs.

*Fix:* avoid prompting language that discourages tool calls in general (e.g., "respond directly without tools"). Review session trace `LLMStep` entries to confirm whether injected tools are being selected when expected.

---

### Anti-Pattern 10: Assuming Sticky Flowcharts Are a Substitute for Transition Logic

Setting `reset_to_initial_node: false` to avoid designing proper subagent transition conditions, resulting in users being permanently locked in a single subagent context.

*Signal:* users reporting that the agent ignores topic changes or seems unable to handle requests outside a narrow scope.

*Fix:* design explicit transition conditions that fire when the user's intent shifts. Sticky flowcharts should have a defined exit condition — not be an open-ended lock.

---

### Anti-Pattern 11: Writing Parallel Tools That Share Output Variables

Designing parallel tool calls where multiple tools write to the same `@variables.X`, relying on merge behavior that is actually Last-Write-Wins.

*Signal:* non-deterministic state after parallel tool execution; one tool's result sometimes overwrites another's unexpectedly.

*Fix:* ensure each parallel tool writes to distinct, non-overlapping variables. Treat LWW as a data loss risk, not a merge strategy.

---

## 15. Terminology Reference

**`agentforce://` URI scheme**
Deprecated as of 262.8. Replaced by `agent://`.

**Agent harness**
The configurable intermediary layer between the Atlas reasoning engine and the LLM model endpoint. Encompasses all tools, context engineering mechanisms, and short-term memory elements that surround the LLM API call. Introduced as a named concept in Daisy++. See Section 1.6.

**Agent Service Agentic Reasoner**
The official service identifier name for the Daisy/Daisy++ unified planner, used for Splunk telemetry tracking.

**`ask for` statement**
A pilot variable capture statement (introduced as `collect` in 262.12, renamed `ask for` in 262.14) that gathers one variable at a time from the user inside `reasoning.instructions`. See Section 5.5.1.

**`after_response`**
A connected-subagent-only instruction surface (262.10) that fires after a connected agent returns. See Section 4.5.1.

**Bring Your Own Node (BYON)**
A mechanism for introducing custom Docker-containerized logic into the MGR execution flow, deployed via ICS on Kubernetes. See Section 8.5.

**`config.runtime` block**
A top-level configuration block (262.12) exposing boolean flags for streaming, thought_chunks, citation, groundedness, and reset_to_initial_node. An empty block is a hard compile error. See Section 2.5.

**Daisy / Daisy++**
Internal names for the Agentforce unified planner service. Daisy addressed deterministic agent behavior needs. Daisy++ expanded the architecture to support a configurable agent harness, MGR-based graph authoring, and advanced extensibility.

**`disable_graph_runtime`**
Deprecated flag, now a hard compile error as of 262.12.

**`escalate` statement**
A deterministic, single-fire transition statement (262.14) that hands off to a fixed escalation target exactly once. Cannot loop. See Section 6.4.

**Execution Pause Check**
Stage 4 of the internal state machine. Pauses graph execution when a tool requires user confirmation, serializes full session state to Redis, and re-hydrates when the user responds. See Section 3.4.

**`goal-based agent` / `GoalBasedAgent`**
An agent type (pilot in 262.14) gated behind `config.agent_type: "GoalBasedAgent"` that operates outside the standard turn-based model. See Section 7.5.

**Inline Skills**
A pilot feature (262.14) introducing `skill_definitions` and `reasoning.skills` blocks. Skills encapsulate reusable reasoning instructions. See Section 6.7.

**Last-Write-Wins (LWW)**
The state merge strategy used when parallel tool executions complete. The last tool to finish writes its state changes, overwriting conflicting changes from concurrently executing tools. Custom merge strategies are in development. See Section 6.2.

**Module Graph Runtime (MGR)**
The pip-installable, Pydantic-based Python library that implements the Daisy++ unified planner. Executes agent graphs defined in JSON or YAML without hardcoded system prompts. See Section 8.1.

**`reasoning.instructions`**
The primary instruction surface for subagent reasoning. Rebuilt on every parse, including after every tool call. Supports literal mode (`|`) and procedural mode (`->`).

**Redis**
The external cache layer that holds all session state between turns. Session TTL is 7 days. The stateless MGR runtime hydrates from Redis on every turn and writes back after every turn. See Section 8.6.

**Subgraph / Supervision Call**
A pattern for calling an auxiliary graph execution structure as an isolated tool call. Distinct from transitions (which drop user context into a new node) and delegation (which calls a local child subagent). See Section 6.8.

**Unified Spec**
The runtime-internal, platform-agnostic representation of an agent's configuration, produced by translating `agent.json` at runtime. Strips Salesforce-specific terminology to support future open-sourcing. See Section 8.2.

**`user_select_record_tool` / `show_tool_results`**
Hidden tools automatically injected into the Unified Spec during translation. Control record selection UI components and tool result rendering. Responsible for approximately 90% of missing-card and dropped-input field bugs when the LLM skips them. See Section 8.3.

**Zero-hallucination routing pattern**
A pattern combining `filter_from_agent: True` and `is_used_by_planner: True` on a classification action's output. Forces the LLM to call the action to obtain the routing value. See Section 6.6.
