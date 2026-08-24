#Determining the Right Level of Determinism for Agentforce

*Updated August 24, 2026*
*This guide was generated using AI with grounding in official Salesforce documentation. Review for accuracy before using.*

---

## Table of Contents

1. [The Core Tension: Fluidity vs. Control](#1-the-core-tension-fluidity-vs-control)
2. [How the Reasoning Engine Actually Works (ReAct)](#2-how-the-reasoning-engine-actually-works-react)
3. [The Determinism Spectrum: Six Official Levels](#3-the-determinism-spectrum-six-official-levels)
4. [Where Topics, Instructions, Flows, and Agent Script Sit on the Spectrum](#4-where-topics-instructions-flows-and-agent-script-sit-on-the-spectrum)
5. [Techniques to Increase Determinism vs. Increase Flexibility](#5-techniques-to-increase-determinism-vs-increase-flexibility)
6. [Diagnosing Unreliable Behavior: Is It Determinism or a Data Problem?](#6-diagnosing-unreliable-behavior-is-it-determinism-or-a-data-problem)
7. [Global vs. Per-Subagent Instructions: A Known Product Gap](#7-global-vs-per-subagent-instructions-a-known-product-gap)
8. [Customer Conversation Framework: Setting Expectations on Predictability](#8-customer-conversation-framework-setting-expectations-on-predictability)
9. [Case Study: Dialing In an Unreliable Agent](#9-case-study-dialing-in-an-unreliable-agent)
10. [The Architect's Cheat Sheet](#10-the-architects-cheat-sheet)

---

## 1. The Core Tension: Fluidity vs. Control

### Why This Matters

The promise of Agentforce is that agents can understand intent, adapt to novel phrasing, and reason across steps — without needing every possible conversation to be scripted in advance. That is genuinely powerful. But enterprise businesses also need processes to be repeatable, auditable, and compliant.

These two goals pull in opposite directions. A fully autonomous agent is maximally flexible but unpredictable. A fully scripted agent is predictable but brittle. The right architecture is not one or the other. It is a deliberate, context-driven balance.

> **The Salesforce framing:** "The key to successful agent creation is to strike the right balance between creative fluidity and enterprise control." — *Agentforce Guide to Achieving Reliable Agent Behavior*

### The Chatbot vs. Agent Analogy

It helps to contrast agents with their chatbot predecessors. A chatbot is like a **novice cook following a recipe** — any deviation from the script produces a failure. An agent is like a **seasoned chef** — given an understanding of your preferences and available ingredients, it improvises a result. The chef is more capable, but you still need to tell them what they are not allowed to serve.

Your job as a Success Architect is to write the right kitchen rules: specific enough to prevent dangerous improvisation, loose enough to let the chef do what they do best.

---

## 2. How the Reasoning Engine Actually Works (ReAct)

Before you can tune reliability, you need to understand what is actually being tuned.

### The ReAct Paradigm

Agentforce's Atlas Reasoning Engine is built on **ReAct** (Reasoning + Acting), a paradigm introduced in 2022. It mimics human problem-solving by cycling through four steps:

| Step | What Happens |
|---|---|
| **Reason** | The engine interprets user intent and identifies the most appropriate subagent and action(s). |
| **Act** | The engine launches the selected action(s). |
| **Observe** | The engine evaluates the action result against the user's intent. If the intent is fulfilled, it produces a final response. If not, it loops. |
| **Repeat** | The cycle continues until the request is complete, no suitable actions remain, or a maximum call limit is reached. |

The LLM is involved at every Reason and Observe step. Depending on the action type, it may also be involved during Act. This is important: **the LLM is not just generating responses — it is also making routing and sequencing decisions** throughout.

### The Hybrid Execution Model (GA February 2026)

The current Agentforce architecture separates two execution paths:

- **Path A: Deterministic.** When instructions are expressed as code (via Agent Script's `->` logic syntax), the Atlas Reasoning Engine executes them without involving the LLM. No prompt assembly. No probabilistic reasoning. Fully auditable.
- **Path B: LLM Reasoning.** When instructions contain natural language prompts (the `|` pipe syntax), the engine assembles a prompt and invokes the LLM.

The boundary between these two paths is **explicit in the script** — not inferred at runtime. This is the central design decision you help clients make.

### The Three-Stage Execution Pipeline

```
Authoring (Agent Script in Builder)
        ↓
Compilation (Agent Graph — machine-optimized execution plan)
        ↓
Runtime (Atlas Reasoning Engine — traverses graph, enforces logic, calls LLM only where needed)
```

You work only in the Authoring layer. The Compilation and Runtime layers enforce the boundaries you define.

---

## 3. The Determinism Spectrum: Six Official Levels

Salesforce defines six official levels of agentic control. They are **cumulative** — each level builds on the previous one. Think of them not as modes to switch between, but as layers you progressively add.

> Reference: [salesforce.com/agentforce/levels-of-determinism](https://www.salesforce.com/agentforce/levels-of-determinism/)

---

### Level 1: Instruction-Free Subagents with Prompt Actions

**What it is:** The agent autonomously selects subagents and actions using only its understanding of the conversation. No explicit instructions are written.

**Why you would use it:** Rapid prototyping, internal FAQ agents, low-stakes general Q&A. The agent has the largest degree of freedom at this level.

**The business tradeoff:** Speed to build is high. Predictability is low. The agent is entirely reliant on the LLM's interpretation of subagent names and action descriptions.

**SA note:** This is a great starting point, not a destination for production. The key design work here is writing semantically distinct subagent names and action descriptions, because those are the signals the LLM uses to route.

---

### Level 2: Agent Instructions

**What it is:** Explicit written instructions guide the agent's behavior — rules, guardrails, sequences, escalation conditions, and response style expectations.

**Why you would use it:** You need the agent to follow specific business policies consistently without encoding every scenario. Instructions can specify things like "always verify identity before discussing account details" or "do not respond if no applicable policy is found."

**The business tradeoff:** Instructions increase consistency but are probabilistic. The LLM reads them as guidance, not as code. A well-written instruction greatly improves reliability; a poorly written one can confuse the engine or produce contradictions.

**SA note — the overscripting trap:** One of the most common mistakes at this level is micromanagement. Writing instructions like "If the user asks X, respond with Y. If they ask Z, respond with W" creates an exhaustive, fragile script that breaks on any unanticipated phrasing. Better practice: write behavioral instructions that define *how the agent should reason*, not what it should say word for word. Use RAG (Level 3) for policy content rather than embedding it in instructions.

**SA note — instruction placement:** Instructions are added to the *subagent* level (not the agent level). They become part of the observation prompt the engine uses when deciding its next action. Today, there is no native global instruction layer — see [Section 7](#7-global-vs-per-subagent-instructions-a-known-product-gap) for implications.

---

### Level 3: Data Grounding (RAG)

**What it is:** The agent's responses are anchored to verified external data sources — CRM records, knowledge bases, document repositories — using Retrieval Augmented Generation (RAG).

**Why you would use it:** Without grounding, agents answer from model training data, which may be outdated, generic, or wrong for your specific business context. Grounded responses are based on facts the business controls.

**The business tradeoff:** Grounding dramatically improves accuracy and trustworthiness, but it introduces a retrieval quality dependency. If the knowledge base has gaps or poor indexing, the agent's answers will reflect that. Grounding is not a silver bullet — it is a quality ceiling.

**SA note:** Encourage clients to think of their knowledge base as a product, not a one-time setup. Stale or poorly structured knowledge articles are one of the most common root causes of "the agent gave a wrong answer" issues. This is a **data problem**, not a determinism problem — an important diagnostic distinction covered in [Section 6](#6-diagnosing-unreliable-behavior-is-it-determinism-or-a-data-problem).

**RAG design pitfalls to flag:**
- Do not script RAG to always call specific articles for specific questions. Let RAG's semantic matching work.
- Do not chain multiple actions sequentially via instructions to cover multiple data sources — the engine may consider the request fulfilled early and skip subsequent actions. Use a single prompt template that combines retrieval sources, or use Agent Script (Level 6) to enforce the sequence.

---

### Level 4: Variables

**What it is:** Variables allow the agent to store and carry state across turns and across subagents — user identity, retrieved data, workflow progress, predictive model outputs.

**Why you would use it:** Without variables, the agent has only its context window for memory. On long conversations, earlier context can be lost, causing the agent to lose track of where it is in a process, forget a retrieved data point, or re-ask for information the user already provided.

**The business tradeoff:** Variables enable personalization and multi-step workflows, but they add design complexity. Poorly managed variable state can cause agents to get "stuck" or behave differently on a second call to the same subagent.

**SA note:** Variables can also drive **conditional action filtering**. An action can be made `available when` a variable holds a certain value — this is a deterministic gate at the platform level, not an LLM suggestion. This is one of the most underutilized reliability levers at this level.

**Key variable design principles:**
- Initialize all variables to sensible defaults. The gate is closed by default; the workflow must earn the right to proceed.
- Never rely on the LLM to set a gate variable. Use a deterministic `run` and `set` block.
- Store RAG output in variables when conversations may become long, so the data remains available regardless of context window pressure.

---

### Level 5: Deterministic Actions (Apex, Flows, APIs)

**What it is:** Instead of relying on the agent's reasoning to orchestrate multi-step logic, the logic is encoded in deterministic Salesforce assets — Flows, Apex classes, or API callouts — and the agent invokes them as a single action.

**Why you would use it:** When a business process has a known, fixed sequence of steps (create record, send email, update status, notify manager), you do not want the LLM deciding the order. Encode it in a Flow and let the agent call it. The Flow is deterministic by nature.

**The business tradeoff:** Higher reliability for known sequences. Less flexibility if the sequence needs to vary based on conversational context. Also, Flows with prompt nodes can include non-deterministic elements (LLM calls inside the Flow), so understand what is inside the box before assuming the action is fully deterministic.

**SA note — when a Flow is the right answer:** A good indication that a Flow action is preferred is when the subagent would otherwise need instructions like "First do this, then do this, and finally do this." Enforcing sequences of more than three steps through instructions alone becomes difficult to maintain and unreliable in practice. Move that logic into a Flow.

**SA note — Flows conditioned on fixed rules:** Salesforce's own guidance is explicit here: a Flow whose step sequence is determined by **fixed rules** (not by user input) can serve as a fully deterministic Agentforce action. Marketing journey flows, record-update sequences, and integration callouts are good examples.

---

### Level 6: Deterministic Control with Agent Script

**What it is:** Agent Script is a domain-specific language (DSL) that lets you hard-code the reasoning process itself, not just what tools are available. You define immutable paths: mandatory authentication gates, if/else conditional branching, forced subagent transitions, and explicit variable binding between steps.

**Why you would use it:** When "mostly right" is not good enough. This level provides a mathematical guarantee that certain steps will always run in a certain order, regardless of user input or LLM interpretation.

**The business tradeoff:** Maximum reliability for critical paths. Higher build effort. Risk of overengineering if applied to flows that don't need it. An agent that is fully scripted at Level 6 throughout is effectively a sophisticated chatbot — not an agent.

**The key distinction:** In Levels 1-5, you say "Agent, here is a tool. Use it if appropriate." In Level 6, you say "Agent, run this. Now. Every time. No exceptions."

**Two authoring paths:**
- **Builder Path (no-code):** Write the logic in structured natural language in the document-style canvas. The platform compiles it into Agent Script automatically. Accessible to admins and business analysts.
- **Code-First Path:** Write Agent Script directly in Script view for maximum precision. Supports a hybrid mode where some instructions stay in natural language and others are directly coded.

**Level 6 patterns to know:**

| Pattern | What it enforces | Example |
|---|---|---|
| `before_reasoning` block | Actions that run unconditionally *before* the LLM sees anything | Fetch customer record, run authentication check |
| `after_reasoning` block | Logic that runs *after* the LLM responds, regardless of outcome | Log CSAT, reset variables, enforce sequence transition |
| `if/else` conditionals | Deterministic branching without LLM involvement | If credit score < 600, show debt counseling only |
| Forced `transition to` | Lock the user into a specific subagent | Emergency triage must stay in triage subagent |
| `available when` gates | Physically remove an action from the LLM's tool list | Payment action invisible until validation passes |
| Explicit `set` bindings | Prevent the LLM misinterpreting action output | `set @variables.balance = @outputs.account_balance` |

---

## 4. Where Topics, Instructions, Flows, and Agent Script Sit on the Spectrum

This table is designed to help you quickly map client building blocks to their place on the spectrum — and the conversations each one should trigger.

| Building Block | Level(s) | Determinism Type | Key Design Conversation |
|---|---|---|---|
| Subagent name and classification description | 1 | Probabilistic | Are descriptions semantically distinct? No overlap? |
| Action description / instruction | 1-2 | Probabilistic | Does the engine reliably pick the right action? |
| Subagent instructions (rules, guardrails) | 2 | Probabilistic | Are you scripting behavior or scripting conversation? |
| Knowledge base / RAG action | 3 | Probabilistic (retrieval quality) | Is the knowledge base current and well-structured? |
| Context variables | 4 | Probabilistic (LLM sets) vs. Deterministic (code sets) | Who sets this variable — code or the LLM? |
| `available when` filters on actions | 4 | Deterministic (platform-enforced gate) | Does the gate variable have a deterministic writer? |
| Flows (fixed-rule sequences) | 5 | Deterministic | Does the flow depend on user input or fixed rules? |
| Apex / API actions | 5 | Deterministic (unless calling prompts inside) | Are there probabilistic elements inside the action? |
| Agent Script `->` logic instructions | 6 | Fully deterministic | Is this the right level of control for this workflow step? |
| Agent Script `\|` prompt instructions | 1-6 | Probabilistic (LLM handles) | Is LLM reasoning genuinely needed here? |
| Agent Script `before_reasoning` / `after_reasoning` | 6 | Fully deterministic | Does this logic need to run on every parse? |

---

## 5. Techniques to Increase Determinism vs. Increase Flexibility

### Increasing Determinism (When the Agent Is Too Unpredictable)

Use these when the client's "why did the agent do that?" question points to inconsistency, wrong sequencing, or skipped steps.

1. **Sharpen action and subagent descriptions.** Semantic clarity is the cheapest form of determinism. If two actions could plausibly apply to the same user utterance, the engine will sometimes choose the wrong one. Make them unambiguous.
2. **Add targeted instructions.** Add one instruction at a time and test between each addition. More is not always better — verbose instructions can confuse the engine or create contradictions.
3. **Move sequence logic into a Flow.** If the subagent needs to do A, then B, then C — and this is always the right order — encode it in an autolaunched Flow and call it as a single action.
4. **Use `available when` gates.** Instead of instructing the agent not to call an action yet, remove it from view entirely using a variable-based gate.
5. **Promote to Agent Script Level 6 for critical paths.** Use `before_reasoning` to guarantee prerequisite actions always run. Use `if/else` to replace instruction-based branching. Use forced `transition to` to prevent subagent drift.
6. **Lower LLM temperature on prompt actions.** Where prompt templates generate variable responses, reducing temperature increases repeatability. This is configurable on individual prompt actions.
7. **Instruct the agent not to alter prompt action output** (for regulated content). The instruction "Do not change the promptResponse output, regardless of channel" forces the agent to pass the templated response verbatim.

### Increasing Flexibility (When the Agent Is Too Rigid)

Use these when the agent feels robotic, fails on valid but unexpected phrasing, or requires constant maintenance as business rules evolve.

1. **Move policy rules from instructions into knowledge articles.** Use RAG to retrieve the policy at the right moment, rather than embedding every rule in instructions. This also makes rules easier to update without redeployment.
2. **Reduce instruction length.** Long instructions increase the probability that the engine ignores or misapplies parts of them. Write fewer, more behavioral instructions.
3. **Consolidate subagents.** Overly granular subagents increase routing complexity and misroute risk. A single subagent with RAG can often handle a broader question space more reliably than many narrow subagents.
4. **Remove unnecessary `available when` filters.** Over-constraining action availability can cause the agent to get stuck when expected variable states do not arrive.
5. **Use Level 5 actions as traffic controllers, not as monolithic scripts.** For large-scale agents handling hundreds of use cases, let the reasoning engine route to isolated deterministic actions per use case, rather than scripting a single giant Level 6 flow.

### The Right Balance in Practice

> "The real art of agent architecture and design lies in right-sizing the determinism by applying exactly enough control to ensure safety, without sacrificing the conversational flexibility that makes AI valuable in the first place." — *Agentforce Guide to Achieving Reliable Agent Behavior*

A practical starting rule: **start at Levels 1-3 and monitor production logs.** Where you observe sequencing failures, skipped steps, or hallucinated parameters, selectively harden that specific path with Level 4-6 controls. Do not preemptively script everything.

---

## 6. Diagnosing Unreliable Behavior: Is It Determinism or a Data Problem?

This is one of the most critical diagnostic conversations a Success Architect can facilitate. The symptoms of a determinism problem and a data/grounding problem can look identical from the end user's perspective. The fixes are completely different.

### Diagnostic Framework

Use this layered approach to isolate the root cause:

**Step 1 — Confirm the right subagent is being selected.**
Open Agent Builder and run the failing conversation. Check the reasoning trace. Did the correct subagent get selected? If not, the problem is in subagent classification descriptions. This is a determinism/design problem, not a data problem.

**Step 2 — Confirm the right action is being called.**
Within the subagent, is the correct action being invoked? If the agent is selecting the wrong action, the issue is in action descriptions or instructions. Still a determinism problem.

**Step 3 — Confirm the action is returning correct data.**
If the right action is being called, is it returning the expected result? Check the action output in the reasoning trace. If the output is wrong or empty, this is a **data or integration problem** — not an agent configuration problem. Check the data source, the retriever, or the API response.

**Step 4 — Confirm the response is properly grounded.**
The engine performs a grounding check before the final response: the answer must be based on action outputs, must follow subagent instructions, and must stay within scope. If this check is failing, the issue may be a conflict between action outputs and instructions — a determinism problem.

### The Most Common Misdiagnosis

**Symptom:** "The agent gave a wrong answer about our product."
**Misdiagnosis:** "The agent needs better instructions."
**Actual cause (often):** The knowledge article the agent retrieved was outdated or incorrectly structured. The agent gave the best answer it could based on what it retrieved. Fix the knowledge base, not the agent configuration.

**Symptom:** "The agent skipped a step in the process."
**Misdiagnosis:** "The knowledge base doesn't cover that scenario."
**Actual cause (often):** The instruction was probabilistic and the engine determined the request was fulfilled before reaching that step. Fix: encode the mandatory step in a Flow (Level 5) or use Agent Script `before_reasoning` (Level 6) to guarantee execution.

### Quick Diagnostic Checklist

| Observation | Likely Root Cause | Where to Look |
|---|---|---|
| Agent routes to wrong subagent | Overlapping classification descriptions | Subagent description text |
| Agent skips a step in a process | Instruction-based sequence, engine exited early | Move to Flow or Agent Script |
| Agent provides outdated information | Stale knowledge base content | Knowledge articles / data source |
| Agent response varies on identical input | No deterministic path enforced | Promote to Agent Script Level 6 |
| Agent asks for info the user already gave | Variable not persisting state | Variable design, context window limits |
| Agent calls same action repeatedly | `available when` gate stays open after action runs | Gate variable not being reset |
| Agent ignores an instruction | Instruction is too long, ambiguous, or conflicts with another | Simplify and isolate instructions |

---

## 7. Global vs. Per-Subagent Instructions: A Known Product Gap

### The Current State

Today, Agentforce instructions live at the **subagent level**. Each subagent has its own instruction block, and those instructions are included in that subagent's observation prompt. There is no native mechanism to write a single global instruction that applies across all subagents.

This is explicitly acknowledged in Salesforce's own guidance: "Sometimes, instructions apply globally to the agent and are not related to an individual subagent. Functionality to maintain global instructions is currently on the product roadmap."

### Why This Matters to Your Clients

In practice, this means that guardrails like "always respond in English," "never discuss competitor products," or "always include a compliance disclaimer" must be duplicated across every subagent in which they should apply. If a new subagent is added later, someone must remember to add those instructions to it as well.

This is a maintenance risk. Over time, as agents grow, it becomes easy for a new subagent to inadvertently ship without the expected guardrails.

### Current Workarounds

1. **Agent-level system instructions.** The agent-level `system: instructions:` block does apply globally and can carry persona, tone, and high-level behavioral rules. Use this block for anything that should always be true across all subagents. Note: per-subagent `system: instructions:` blocks **override** the agent-level ones, so take care when mixing both.
2. **Agent Script `start_agent` initialization.** Use the `start_agent` block to set variables or run actions that establish global state (authenticated user context, session flags, etc.) that all subsequent subagents can read.
3. **Governance discipline.** Establish a documented checklist of global guardrail instructions that must be copied into every new subagent at build time. Flag this as a process control during delivery.
4. **Centralized subagent for shared behaviors.** For behaviors like compliance disclaimers or human escalation logic, create a dedicated subagent that handles it, and transition to it consistently. Centralizing the logic avoids duplication.

### What to Tell Customers

Set the expectation clearly: global instructions are on the roadmap, not yet available. Agree on a governance process now rather than assuming it will be handled automatically. Agents with more than 5-6 subagents are at meaningful risk of inconsistent guardrail coverage without an active process.

---

## 8. Customer Conversation Framework: Setting Expectations on Predictability

One of the most important value-add conversations a Success Architect can have is setting honest, calibrated expectations before go-live. AI agents are not deterministic by default. Clients who expect chatbot-level scripted precision from a Level 1-3 agent will be disappointed. Clients who understand the spectrum will be equipped to make the right design choices.

### The Five Expectation-Setting Conversations

**1. "How often must the agent get this exactly right?"**
This is the first and most important question. Not all agent interactions carry the same risk. A wrong answer about store hours is annoying. A wrong action on a financial transfer is a compliance incident. Map risk level to required determinism level before building.

| Risk Level | Acceptable Variability | Recommended Level |
|---|---|---|
| Low (informational, FAQ) | High | Levels 1-3 |
| Medium (service requests, data updates) | Low | Levels 3-5 |
| High (financial, regulated, irreversible actions) | Near-zero | Level 5-6 (Agent Script) |

**2. "What does 'reliable' mean for this use case?"**
Clients often conflate different types of reliability:
- *Routing reliability:* Did the agent engage the right subagent?
- *Factual reliability:* Did it provide the right information?
- *Process reliability:* Did it execute the right steps in the right order?
- *Compliance reliability:* Did it stay within required guardrails?

Each requires different controls. A single answer of "make it more reliable" is not actionable.

**3. "What happens when the agent is wrong?"**
Help clients think through fallback design:
- Is there a human escalation path?
- Are irreversible actions (record updates, case closures, payments) confirmed before execution?
- Is there a review loop for high-stakes outcomes?

Agents with no fallback and no human-in-the-loop for high-risk actions should be approached with significant caution, regardless of the determinism level.

**4. "What will you monitor in production?"**
Reliability is not a build-time guarantee — it is a runtime discipline. Encourage clients to define:
- What session traces will they review?
- What does a failure look like, and how quickly will they know?
- Who owns the agent quality post-launch?

**5. "Are you optimizing for autonomy or for auditability?"**
These goals sometimes conflict. A fully autonomous Level 1-3 agent provides maximum flexibility but limited audit trails. A Level 6 Agent Script agent provides full execution auditability but requires more upfront design. For regulated industries, **guided determinism via Agent Script is the recommended pattern** for compliance requirements.

### The "Humans in Control" Model

Agentforce is designed around a "humans in control" philosophy:
- Humans define intent and guardrails.
- Agents execute within those boundaries.
- Humans verify outcomes before release (or before high-stakes actions execute).

This is not a limitation of the platform. It is the correct model for enterprise AI. Position it to clients as a feature, not a gap.

---

## 9. Case Study: Dialing In an Unreliable Agent

### The Scenario

A financial services client built a Service Agent for their retail banking call center. The agent handles balance inquiries, transaction history, and fund transfers. After two weeks in production, the client reports three issues:

1. The agent sometimes skips the identity verification step and goes straight to account information.
2. The agent occasionally produces different responses to the same "what is my balance?" question.
3. The agent once processed a fund transfer without prompting for confirmation.

### Step 1: Diagnose Each Issue

**Issue 1 — Skipped identity verification**
Using the Agent Builder reasoning trace, the architect confirms the agent went directly to the "Account Inquiry" subagent without passing through "Identity Verification." The identity verification step was written as an instruction: "Always verify the user's identity before providing account information."

Root cause: This is a **determinism problem** at Level 2. The instruction is probabilistic — the LLM read it as guidance but assessed that sufficient context existed to proceed. The fix is not to rewrite the instruction.

**Issue 2 — Variable balance responses**
The architect checks the "Balance Inquiry" action output in the trace. The action is returning the correct balance every time. But the prompt template that formats the response is being modified by the LLM's observation prompt — combining it with other context from the conversation, leading to slightly different phrasing.

Root cause: A **determinism problem** at Level 2. The instruction "Do not change the promptResponse output" was not in place.

**Issue 3 — Transfer without confirmation**
The `execute_transfer` action has no `available when` guard. It appeared in the LLM's tool list at all times. The LLM interpreted a user's clear intent ("yes, transfer it") as sufficient authorization to proceed.

Root cause: A **determinism problem** at Level 4-5. No gate was enforcing the confirmation step.

### Step 2: Apply the Fixes

**Fix for Issue 1 — Enforce identity verification with Agent Script:**
Move the identity verification check into a `before_reasoning` block in the `start_agent` or as a forced transition before the account subagent. The `before_reasoning` block executes as code — not as a prompt. The LLM cannot skip it.

```
# In the account_inquiry subagent
before_reasoning:
    if @variables.identity_verified == False:
        transition to @subagent.identity_verification
```

Result: The identity subagent always runs before account access. Mathematically guaranteed.

**Fix for Issue 2 — Lock prompt response output:**
Add a subagent instruction to the balance inquiry subagent:

```
"Do not change the promptResponse output, regardless of the channel."
```

For even stricter control, use Agent Script to run the balance action deterministically and inject its output directly into the prompt template, bypassing LLM reformulation.

**Fix for Issue 3 — Gate the transfer action:**
Add an `available when` condition so the transfer action is hidden from the LLM until an explicit confirmation variable is set by a deterministic confirmation step:

```
actions:
    execute_transfer: @actions.execute_transfer
        available when @variables.transfer_confirmed == True
        with from_account=@variables.source_account
        with to_account=@variables.destination_account
        with amount=@variables.transfer_amount
```

The `transfer_confirmed` variable is set only after the user's explicit "yes, proceed" response is captured by a deterministic confirmation subagent — not by the LLM interpreting implied consent.

### Step 3: Adopt the Hybrid Architecture

After the fixes, the agent architecture looks like this:

```
[Level 6] start_agent: Force identity verification → set identity_verified variable
     ↓
[Level 4-5] account_inquiry subagent: RAG + instructions for flexible Q&A
     ↓
[Level 5-6] transfer subagent: Collect, validate, gate, confirm → execute deterministically
     ↓
[Level 6] after_reasoning: Force CSAT collection, compliance closing language
```

This is the **deterministic sandwich** pattern: Level 6 controls the critical beginning (authentication) and end (compliance), while Levels 3-5 handle the flexible middle (answering questions). Each zone uses exactly the right level of control.

### Lessons for the SA

- Do not redesign the entire agent. Identify the specific failure modes and apply targeted controls.
- The most reliable indicator that Level 6 is needed: the same conversation produces different execution paths on repeated runs.
- Always ask: "Is this a wrong instruction, or is the instruction correct but the mechanism is wrong?" Rewriting instructions when the mechanism needs to change is the most common pattern of wasted effort.

---

## 10. The Architect's Cheat Sheet

### Zone A: Guided Autonomy (Levels 1-5) — "Trust, but Verify"

**Use when:**
- The correct path varies based on user preferences (shopping, planning, general support)
- The agent handles a broad scope of use cases and scale makes scripting impractical
- Speed to market is a priority and risk tolerance is medium
- Business processes are still evolving and flexibility is needed

**Avoid when:**
- Steps must execute in a guaranteed sequence
- Actions are irreversible (financial, compliance, medical)
- The business requires a full audit trail of execution paths
- "Mostly right" is not an acceptable outcome

### Zone B: Scripted Precision (Level 6 Agent Script) — "Whatever You Do, Do Exactly This"

**Use when:**
- Authentication must be verified before sensitive actions
- Disclosures must be delivered verbatim (regulated industries)
- Step B requires the exact output of Step A
- Subagent drift in high-stakes contexts is not acceptable

**Avoid when:**
- The conversation path is inherently variable (the user should lead)
- The use case is low-risk and high-volume (scripting overhead is not justified)
- The scope is so large that a monolithic script creates a maintenance burden
- You are replacing simple deterministic automation that never needed an agent

### Summary Comparison Table

| Feature | Levels 1-5 (Guided Autonomy) | Level 6 (Agent Script) |
|---|---|---|
| **Primary driver** | Probabilistic LLM reasoning | Deterministic compiled graph |
| **Logic source** | Natural language prompts | if/else, state management, transitions |
| **Action execution** | LLM selects tools as appropriate | Forced execution — code decides |
| **Context memory** | Implicit via LLM context window | Explicit via mutable variables throughout script |
| **Audit trail** | Reasoning logs (requires interpretation) | Full execution path (deterministic and traceable) |
| **Build effort** | Low (primarily prompting) | Medium-High (scripting and logic design) |
| **Risk tolerance** | Medium | Low (zero-trust for critical paths) |
| **Best for** | FAQ, general service, discovery, dynamic Q&A | Auth, payments, compliance, diagnostics, sequential workflows |

### The Final Recommendation

Start with Levels 1-5 for speed and discovery. Monitor your production logs. Where you observe the agent struggling with consistency, failing to follow a required sequence, or making decisions that should not be left to the LLM, **selectively harden that specific workflow with Level 6.** Do not apply Level 6 everywhere. Do not avoid it where it is genuinely needed.

The most mature agent architectures are not fully autonomous, and they are not fully scripted. They are **hybrid** — built by architects who understood exactly where the LLM boundary should fall, and made that decision deliberately.

---
*For the official six-level framework: [salesforce.com/agentforce/levels-of-determinism](https://www.salesforce.com/agentforce/levels-of-determinism/)*
