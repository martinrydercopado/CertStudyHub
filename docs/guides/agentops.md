# AgentOps: A Success Architect's Guide to Agentforce

*Updated August 30, 2026*
*This guide was generated using AI with grounding in official Salesforce documentation and DevOps research. Review for accuracy before using.*

---

## Table of Contents

1. [What Is AgentOps?](#1-what-is-agentops)
   - [The Business View](#the-business-view)
   - [The Compilation Model](#the-compilation-model)
   - [How This Differs From Classic Einstein Bots](#how-this-differs-from-classic-einstein-bots)
2. [Why Version Control Is Non-Negotiable for Agents](#2-why-version-control-is-non-negotiable-for-agents)
   - [What Changes When the System Is Probabilistic](#what-changes-when-the-system-is-probabilistic)
   - [What Must Be Under Version Control](#what-must-be-under-version-control)
   - [If Your Team Is Not Using Version Control Yet](#if-your-team-is-not-using-version-control-yet)
3. [The New Agentforce Architecture](#3-the-new-agentforce-architecture)
   - [Agent Script](#agent-script)
   - [The Atlas Reasoning Engine](#the-atlas-reasoning-engine)
   - [The Einstein Trust Layer](#the-einstein-trust-layer)
4. [Agent Script: The Language of Agents](#4-agent-script-the-language-of-agents)
   - [Technical Overview](#technical-overview)
   - [The EinsteinHyperClassifier](#the-einsteinHyperClassifier)
5. [Generative AI-Assisted Development: Opportunities and Guardrails](#5-generative-ai-assisted-development-opportunities-and-guardrails)
   - [The Specific Risk With Agents](#the-specific-risk-with-agents)
   - [The Four-Part Recommended Stance](#the-four-part-recommended-stance)
   - [Common Failure Patterns in AI-Generated Agent Code](#common-failure-patterns-in-ai-generated-agent-code)
6. [Agent Script Blocks: The Building Blocks of an Agent](#6-agent-script-blocks-the-building-blocks-of-an-agent)
7. [The Execution Lifecycle: before_reasoning, reasoning, and after_reasoning](#7-the-execution-lifecycle-before_reasoning-reasoning-and-after_reasoning)
   - [The Parse: The Primary Unit of Execution](#the-parse-the-primary-unit-of-execution)
   - [The Three Blocks](#the-three-blocks)
8. [Actions, Tools, and Variables](#8-actions-tools-and-variables)
9. [The LLM Boundary: Where Judgment Ends and Code Begins](#9-the-llm-boundary-where-judgment-ends-and-code-begins)
   - [The Six Levels of Agentic Control](#the-six-levels-of-agentic-control)
   - [The Golden Rule](#the-golden-rule)
10. [Multi-Agent Orchestration: SOMA, MOMA, and 3P](#10-multi-agent-orchestration-soma-moma-and-3p)
    - [The Three Patterns](#the-three-patterns)
    - [SOMA Architecture Deep Dive](#soma-architecture-deep-dive)
    - [MOMA and 3P Trust Boundaries](#moma-and-3p-trust-boundaries)
11. [Change Management: From Monolith to SOMA](#11-change-management-from-monolith-to-soma)
    - [Why Monoliths Fail at Scale](#why-monoliths-fail-at-scale)
    - [SOMA as an Organizational Design Decision](#soma-as-an-organizational-design-decision)
    - [The Migration Path](#the-migration-path)
12. [Team Structure and Collaboration for Agent Delivery](#12-team-structure-and-collaboration-for-agent-delivery)
    - [Why Team Structure Shapes Agent Architecture](#why-team-structure-shapes-agent-architecture)
    - [Role Clarity for Agent Delivery](#role-clarity-for-agent-delivery)
    - [Admins Are Part of Agent Delivery](#admins-are-part-of-agent-delivery)
    - [If Your Team Is Small or Siloed](#if-your-team-is-small-or-siloed)
13. [Regulated Industry Delivery Framework](#13-regulated-industry-delivery-framework)
    - [Finding the Right Internal Stakeholder](#finding-the-right-internal-stakeholder)
    - [Finding the Value Stream Bottleneck](#finding-the-value-stream-bottleneck)
    - [Change Approval in Practice — Working With and Around CABs](#change-approval-in-practice--working-with-and-around-cabs)
    - [The Minimum Viable Floor](#the-minimum-viable-floor)
14. [Security and the Einstein Trust Layer](#14-security-and-the-einstein-trust-layer)
15. [RAG, Data 360, and the Data Space Permission Gap](#15-rag-data-360-and-the-data-space-permission-gap)
    - [How RAG Works in Agentforce](#how-rag-works-in-agentforce)
    - [The Jargon Problem](#the-jargon-problem)
    - [Retriever Architecture](#retriever-architecture)
    - [Environment Guidance: Sandbox vs. Scratch Org](#environment-guidance-sandbox-vs-scratch-org)
    - [The Data Space Permission Gap](#the-data-space-permission-gap)
16. [Testing Your Agent](#16-testing-your-agent)
    - [Why Testing Is Not Optional](#why-testing-is-not-optional)
    - [The Three-Leg Pipeline](#the-three-leg-pipeline)
    - [The Testing Pyramid](#the-testing-pyramid)
    - [The Agentforce Testing Center](#the-agentforce-testing-center)
    - [How Tests Are Evaluated](#how-tests-are-evaluated)
    - [What Teams Must Test and Usually Don't](#what-teams-must-test-and-usually-dont)
17. [Deployment and Metadata](#17-deployment-and-metadata)
    - [The Five-Phase Release Lifecycle](#the-five-phase-release-lifecycle)
    - [API v68: The New Simplified Metadata Model](#api-v68-winter-27-the-new-simplified-metadata-model)
    - [API v67 and Earlier: The Two Metadata Domains](#api-v67-and-earlier-the-two-metadata-domains)
    - [Branching Strategy for Agent Delivery](#branching-strategy-for-agent-delivery)
    - [Environment Pipeline Architecture](#environment-pipeline-architecture)
    - [Separating Deployments from Releases](#separating-deployments-from-releases)
    - [Static Analysis and Pre-Commit Quality Gates](#static-analysis-and-pre-commit-quality-gates)
    - [Continuous Delivery Rituals](#continuous-delivery-rituals)
18. [Pricing: Flex Credits and Conversations](#18-pricing-flex-credits-and-conversations)
19. [Monitoring and Analytics](#19-monitoring-and-analytics)
20. [Architect Patterns and Troubleshooting Reference](#20-architect-patterns-and-troubleshooting-reference)

---

## 1. What Is AgentOps?

### The Business View

Every organization has more jobs to be done than it has people to complete them. Agentforce is Salesforce's platform for building and deploying autonomous AI agents that engage customers, support employees, and execute business processes at scale — 24 hours a day, across every channel.

AgentOps is the discipline of designing, building, operating, and continuously improving those agents. It spans the full delivery lifecycle: authoring agent logic, deploying across environments, monitoring production behavior, and iterating based on real usage data.

This guide is written for Success Architects who already know how to design and build agents. Its focus is the operational discipline that turns a working agent into a reliable, maintainable, production-grade system — version control, CI/CD pipelines, environment strategy, testing at scale, and release governance.

### The Compilation Model

Agent Script compiles to an Agent Graph on deploy. This has a practical implication: syntax errors and reference errors surface at deploy time (or earlier, with `sf agent validate`), not at runtime. A successfully compiled and deployed agent has a structurally valid graph. Runtime failures are then behavioral — wrong routing, wrong variable state, wrong action output — rather than structural.

> **Key implication for CI/CD:** Running `sf agent validate` before every deploy catches compilation errors before they consume a release window. This is the earliest and cheapest failure mode to catch. Section 17 covers the full pipeline.

### How This Differs From Classic Einstein Bots

Classic Einstein Bots used a slot-filling and intent classification model with a click-based dialog editor. Agentforce replaces this with the Agent Graph and Atlas Reasoning Engine. The differences that matter architecturally:

- Classic Bots had no compiled intermediate representation. Changes took effect immediately on save.
- Agentforce has a five-phase lifecycle (Generate > Deploy > Publish > Activate > Test) with distinct authoring and runtime metadata domains. See Section 17.
- Classic Bots could not express deterministic logic inline with natural language prompts. Agentforce makes this boundary explicit with the `->` / `|` distinction.

---

## 2. Why Version Control Is Non-Negotiable for Agents

### What Changes When the System Is Probabilistic

You already know from Section 1 that agents are probabilistic. When a Flow breaks, it throws an error. When an agent breaks, it answers — confidently, plausibly, and incorrectly. This fundamental difference is why version control is not just a good practice for agent delivery. It is the foundation that every other practice in this guide rests on.

Here is the scenario that plays out on every team that skips it. A production agent starts giving wrong answers in week three. The support team escalates. The SA asks: "What changed, and when?" Nobody knows. A developer updated a prompt template. An admin modified the backing Flow. Someone published a new agent version after a permission fix. All three happened in the same week. Without version control, answering that question means interviewing everyone and reconstructing history from memory. With version control, it means running `git log` and reading a three-line diff.

The 2019 Pardot incident makes this concrete. Salesforce deployed a database script that inadvertently granted Modify All Data permissions to users in orgs with Pardot installed. Salesforce locked 60% of US orgs for 15 hours while addressing it. When access was restored, teams with version control and a delivery pipeline were able to redeploy correct permissions within two hours. Teams without it struggled for days. No team could have prevented the outage. The difference was entirely in recovery speed — and recovery speed is determined entirely by whether the team can answer "what is the correct state, and how do we get back to it?" in minutes rather than days.

This principle applies directly to agents. An agent that regresses in production is a two-hour problem for a team with version control and a tested rollback procedure. It is a multi-day crisis for a team without it.

### What Must Be Under Version Control

Agents are not a single file. A change to any of these components can change agent behavior without touching the agent definition itself:

- **Agent Script (`.agent` files)** — the source of truth for the agent's logic and prompting behavior
- **AiAgentDefinition and AiAgentDefinitionVersion metadata** — the deployed representation of the agent (v68) or AiAuthoringBundle + Bot + BotVersion + GenAiPlannerBundle (v67)
- **Apex `@InvocableMethod` wrapper classes** — the code behind every agent action
- **Flows** invoked as agent actions
- **Prompt Templates** — changes here alter LLM behavior without changing any agent metadata
- **Custom Metadata records** used for feature flags or configuration
- **Permission sets** assigned to the Einstein Agent User

If a component is not in version control, a change to it is invisible. An admin who updates a Flow directly in a sandbox, or a developer who tweaks a Prompt Template in Setup, has just created a gap between what the repository says the agent does and what the agent actually does in that environment.

The rule is simple: if it affects agent behavior, it lives in the repository.

### If Your Team Is Not Using Version Control Yet

Many teams will be somewhere between "we have a repository that nobody uses" and "we have never set up git at all." Both situations are improvable right now without a multi-quarter transformation.

**If you have no version control at all:** Start with the agent metadata only. Track the AiAgentDefinition folder and Agent Script files from day one, even if the rest of the org is still managed through change sets. This creates a meaningful audit trail for the riskiest part of your delivery without requiring a full process overhaul.

**If you have a repository that is not the real source of truth:** Establish one non-negotiable rule: the Agent Script file is the exception to whatever informal process exists. Nobody publishes an agent change that has not been committed and reviewed. One island of discipline can expand.

**If your team uses Salesforce CLI but not git:** `sf project retrieve start --track-source` pulls changes from the sandbox into a local project. Commit after every significant change. It is not a perfect CI/CD workflow, but it is vastly better than no history at all.

**The trade-off to name explicitly:** Accepting no version control means accepting that you cannot reliably diagnose agent regressions, cannot roll back a bad agent change without redeploying from memory, and cannot produce an audit trail for regulated clients or change boards. Those are not theoretical risks. They are the first three problems that will hit a production agent team within six months of go-live.

---

## 3. The New Agentforce Architecture

### Agent Script

Agent Script is the compiled, declarative DSL that defines agent behavior. It is the human-readable source of truth — the artifact that developers author, commit, review, and promote through the delivery pipeline. Everything downstream of it (the Agent Graph, the runtime metadata) is compiled output.

### The Atlas Reasoning Engine

The runtime engine that executes the Agent Graph. The Atlas Reasoning Engine traverses the graph node by node, enforcing the boundary between deterministic and probabilistic execution. It is responsible for subagent classification, action invocation, LLM call orchestration, and session state management. The ReAct (reason-act-observe) loop that governs multi-step agent behavior is implemented by the Atlas Reasoning Engine.

### The Einstein Trust Layer

A security perimeter that sits between the Atlas Reasoning Engine and any external LLM. Every LLM call passes through the Trust Layer, which applies data masking, toxicity detection, prompt injection defense, and zero-data-retention enforcement. The Trust Layer is not optional and cannot be bypassed. See Section 14 for a full reference.

---

## 4. Agent Script: The Language of Agents

### Technical Overview

Agent Script is a compiled, declarative, property-based DSL. Its two most important characteristics:

- **It is whitespace-sensitive.** Indentation determines structure, similar to Python.
- **It uses `@` for resource access.** Variables, actions, utilities, and subagents are all referenced with `@variables.x`, `@actions.x`, `@utils.x`, and `@subagents.x`.

The syntax uses two characters to distinguish types of instructions:

| Symbol | Meaning | LLM Involved? |
|---|---|---|
| `->` | Logic instruction block (deterministic) | No |
| `\|` | Prompt instruction (natural language to LLM) | Yes |

This boundary is explicit and deliberate. When you write `->`, you are writing code. When you write `|`, you are writing a prompt. Understanding where to place that boundary is the core design decision in every Agentforce implementation.

### A Simple Example

```
subagent Order_Management:
    description: "Handles order lookup and status updates."

    reasoning:
        instructions: ->
            if @variables.order_summary == "":
                run @actions.lookup_current_order
                    with member_email=@variables.member_email
                    set @variables.order_summary=@outputs.order_summary

            | Refer to the user by name {!@variables.member_name}.
              Show their current order summary: {!@variables.order_summary}.
              If they want past order info, ask for Order ID and
              use {!@actions.lookup_order}.
```

### The EinsteinHyperClassifier

For subagent classification, Salesforce provides the **EinsteinHyperClassifier** — a Salesforce-owned model that is significantly faster and more accurate than a general LLM for this specific task.

**Advantages:**
- Significantly faster subagent classification
- Increased accuracy, particularly for specialized constraints and negative instructions

**Limitations — read these before designing your router:**
- **Cannot use `before_reasoning` or `after_reasoning` blocks at all.** This is a hard platform constraint. If your `agent_router` uses the EinsteinHyperClassifier and you place any logic in `before_reasoning` or `after_reasoning`, the agent will throw a platform error at runtime.
- **Can only use the `@utils.transition` tool.** No other tools or actions are available to it.

> **Architect implication:** The `before_reasoning` guard patterns described throughout this guide cannot be applied to an `agent_router` subagent that uses the EinsteinHyperClassifier. Any initialization logic that must run before routing must live in a dedicated initialization subagent, or be handled by a standard (non-EinsteinHyperClassifier) router.

---

## 5. Generative AI-Assisted Development: Opportunities and Guardrails

### The Specific Risk With Agents

Developers are increasingly using generative AI tools to write Agent Script, scaffold Apex actions, and produce Flow XML. Used correctly, this increases productivity significantly. Used carelessly, it produces code that ships to production and that nobody on the team fully understands.

Agent Script and Agentforce metadata are not well-represented in most LLMs' training data. The language is young, the syntax is strict, and the platform constraints — complex data types, PSL ordering, deployment sequencing, EinsteinHyperClassifier limitations — are exactly the kind of details that generative AI models get confidently wrong.

A developer who has never built an agent manually has no frame of reference to evaluate what the AI produced, catch what it got wrong, or debug what fails in production. The AI output will look plausible. It may even validate. A vibe-coded agent that nobody on the team fully understands is not a faster agent. It is a time bomb.

### The Four-Part Recommended Stance

**1. Build something manually before you use AI to build it.**
Before using generative AI to scaffold an agent or an Apex action, the developer should have built at least one of each by hand — not to be complete, but to understand the platform well enough to know when the AI output is wrong.

**2. Use AI to accelerate, not to replace understanding.**
AI-generated Agent Script, Apex stubs, and Flow XML should be reviewed with the same rigor as any other code contribution. The PR review gate is the right place to catch what the AI got wrong — which means the reviewer must understand the platform well enough to spot it.

**3. AI-generated code requires the same tests as human-written code — arguably more.**
If the developer does not fully understand what was generated, the test suite is the only safety net between that code and production. This is one of the strongest arguments for a robust testing gate: if AI-assisted authoring is happening on your team, testing is not optional by definition.

**4. Document what was generated and how it was reviewed.**
For regulated clients with audit requirements, AI-assisted authorship is a disclosure item. PRs should note when AI tooling was used and what human review was applied.

### Common Failure Patterns in AI-Generated Agent Code

| AI-generated mistake | Platform behavior | Correct approach |
|---|---|---|
| Using `before_reasoning` on an EinsteinHyperClassifier router | Hard platform error at runtime | Remove `before_reasoning` entirely from EinsteinHyperClassifier subagents |
| Using bare `number` type in action I/O definitions | Fails at publish (not at deploy) | Use `lightning__numberType` for Flow targets, `lightning__integerType` for Apex |
| Assigning a permission set before the required PSL | Silent, incomplete access | Always assign PSL first, permission set second |
| Writing `@variables.X` in prompt instructions instead of `{{!@variables.X}}` | Variable renders as literal text | Use `{{!@variables.X}}` for variable interpolation in prompts |
| Chaining `connected_subagent` blocks (sub-agent calling sub-agent) | Unsupported platform pattern | Flatten the chain or introduce a proper supervisor layer |
| Mixing old and new metadata types in a v68 deployment | Validation fails | Use `AiAgentDefinition` + `AiAgentDefinitionVersion` exclusively for v68 deployments |
| Deploying `AiAgentDefinitionVersion` before its parent `AiAgentDefinition` exists | Deployment fails outright | Always include the full `AiAgentDefinition` on first deploy to any target org |

> **The bottom line:** Generative AI is a productivity multiplier for experienced developers who understand what they are reviewing. For teams new to the platform, manual-first is the rule.

---

## 6. Agent Script Blocks: The Building Blocks of an Agent

Every Agent Script file is composed of named blocks. Each block contains properties that describe data or procedures.

### config Block

Defines agent identity. Required fields include `developer_name` (unique API name, max 80 characters, no spaces, no consecutive underscores) and `description`.

```
config:
    developer_name: "Service_Agent_v2"
    agent_label: "Service Agent"
    description: "Handles customer service inquiries."
    agent_type: AgentforceServiceAgent
    enable_enhanced_event_logs: True
```

Set `enable_enhanced_event_logs: True` in non-production environments. This enables conversation logging for debugging and monitoring.

### access Block

Defines the agent's default user. The agent runs in the context of this user, and the user's permissions grant or deny access to Salesforce data. The agent user should have only the permissions required for the agent's tasks.

```
access:
    default_agent_user: "service-agent@yourcompany.com"
```

### system Block

Contains global instructions and required messages. Both `welcome` and `error` messages are required.

```
system:
    instructions: |
        You are a helpful customer service agent. Be concise and professional.

    messages:
        welcome: |
            Hi {!@variables.userPreferredName}! How can I help you today?
        error: "Something went wrong. Please try again."
```

### variables Block

Defines global session variables available to all subagents. Three variable types exist:
- **Custom (mutable):** Writeable during the session. The primary orchestration tool.
- **Linked:** Tied to a source record, read-only.
- **System:** Platform-defined, read-only (e.g., `@variables.user_input`).

```
variables:
    verified: mutable boolean = False
        description: "Whether the user has completed identity verification"
    member_email: mutable string = ""
        description: "Customer's verified email address"
```

### language Block

```
language:
    default_locale: "en_US"
    all_additional_locales: False
```

### connection Block

Configures messaging channel behavior, including escalation routing to Omni-Channel.

```
connection messaging:
    escalation_message: "Connecting you to an agent now."
    outbound_route_type: "OmniChannelFlow"
    outbound_route_name: "support_escalation_flow"
    adaptive_response_allowed: True
```

### start_agent Block

Every agent has exactly one `start_agent` block. Every user utterance begins execution here. This block handles subagent classification, filtering, and routing.

### subagent Block

A subagent handles a specific category of user intent. It contains a `description` (used by the routing engine), an optional `system.instructions` override, a `reasoning` block, and an `actions` block.

```
subagent Identity_Verification:
    description: "Verifies user identity by email."

    actions:
        send_code:
            description: "Send a verification code to the user's email."
            inputs:
                email: string
                    is_required: True
            outputs:
                code_sent: boolean
            target: "flow://Send_Verification_Code"

    reasoning:
        instructions: ->
            if @variables.member_email != "":
                run @actions.send_code
                    with email=@variables.member_email
                    set @variables.code_sent=@outputs.code_sent

            | Ask the user for the verification code they received.
              Use {!@actions.verify_code_tool} to confirm it.
```

### connected_subagent Block

Used in SOMA multi-agent architectures. Defines a reference to another Agentforce agent in your org.

```
connected_subagent Billing_Agent:
    label: "Billing Agent"
    target: "agentforce://X00Dfi200000dpFZ_Billing_Agent"
    loading_text: "Checking your billing information..."
    description: "Handles billing inquiries, payment history, and invoice questions."
    inputs:
        customer_id: string = @variables.customer_id
        verified: boolean = @variables.verified
```

---

## 7. The Execution Lifecycle: before_reasoning, reasoning, and after_reasoning

### The Parse: The Primary Unit of Execution

The primary unit of execution is the **parse**: a single complete cycle through a subagent's three lifecycle blocks. The Atlas Reasoning Engine initiates a new parse in three situations:

1. On first entry into the subagent
2. After every tool call, when an action completes and returns a result
3. On every new user turn within the same subagent

One user turn can trigger multiple parses if multiple tool calls occur. Initialization logic placed without a guard condition in `before_reasoning` will run more than once per user turn in multi-action flows.

### The Three Blocks

| Block | When it runs | LLM involved? | EinsteinHyperClassifier supported? |
|---|---|---|---|
| `before_reasoning` | Start of every parse, before the LLM sees anything | Never | No — platform error if used |
| `reasoning` | Contains both deterministic logic and prompt instructions | Mixed | Partial (`@utils.transition` only) |
| `after_reasoning` | After reasoning completes | Never | No — platform error if used |

### before_reasoning

`before_reasoning` runs unconditionally at the start of every parse.

**Use it for:**
- Session initialization: fetching context records, setting session variables
- Authentication and entitlement checks
- Context hydration: pre-loading data so the LLM receives populated variables

**Do not use it for:**
- Logic that should run only once per session (without a guard condition)
- Logic that depends on the current user input
- Transitions — a `transition to` directive fires unconditionally on every parse and creates infinite routing loops

Guard once-per-session initialization explicitly:

```
before_reasoning:
    if @variables.sessionInitialized == False:
        run @actions.InitializeSession
        set @variables.sessionInitialized = True
```

> **Scenario:** A developer places `run @actions.FetchAccountRecord` in `before_reasoning` without a guard. A user turn triggering three tool calls causes three API calls to the same endpoint. Adding `if @variables.account_loaded == False:` and setting the flag after the first successful call drops API calls from 3 to 1 per turn.

### reasoning

The `reasoning` block contains both deterministic logic (`->`) and prompt instructions (`|`). The engine processes the block top-to-bottom: deterministic sections run as code; prompt sections trigger LLM calls.

**Use it for:** Conditional action selection, prompt assembly, tool declaration, subagent transitions.

### after_reasoning

`after_reasoning` runs after the LLM has completed its reasoning loop.

**Critical caveat:** `after_reasoning` does not run if the reasoning block exits via a `transition to`. If your reasoning block transitions to another subagent, `after_reasoning` is skipped entirely for that parse.

**Use it for:** Variable cleanup, audit logging, conditional transitions that depend on variables set during reasoning.

**Constraints:** Cannot use pipe (`|`) prompt instructions or EinsteinHyperClassifier. Transitions in `after_reasoning` prevent the original subagent from continuing execution.

---

## 8. Actions, Tools, and Variables

### Actions

Actions are the executable units of work available to a subagent. Each action wraps a Salesforce Flow, Apex class, or prompt template with strongly typed inputs and outputs.

**Two invocation patterns:**

**Deterministic** — fires unconditionally when the logic instruction is reached:

```
-> run @actions.lookup_account
       with account_id=@variables.account_id
       set @variables.account_name=@outputs.account_name
```

**Subjective** — offered to the LLM as a callable tool; the LLM decides whether to invoke it:

```
reasoning:
    actions:
        lookup: @actions.lookup_account
            description: "Look up account details by ID."
```

### Tools

Tools are the LLM-callable form of actions. Tool selection is driven by the tool's name and description — write these to be specific and unambiguous.

`available when` clauses act as hard gates. A tool with a false `available when` condition is invisible to the LLM for that parse. This is the recommended pattern for capability gating (e.g., hide refund tools unless the user is verified).

### Variables

Variables are the memory of an agent session. They persist across turns and across subagents.

| Type | Mutable? | Source |
|---|---|---|
| Custom | Yes | Defined in `variables` block, set during session |
| Linked | No | Tied to a Salesforce record field |
| System | No | Platform-provided (e.g., `@variables.user_input`) |

**Best practices:**
- Initialize custom variables with sensible defaults to avoid null-reference errors
- Use descriptive names — the LLM uses the variable description to understand what it holds
- Store action outputs in variables before referencing them in prompt instructions
- Use `@utils.setVariables` for LLM-driven variable setting; use deterministic `set` for code-driven assignment

---

## 9. The LLM Boundary: Where Judgment Ends and Code Begins

### The Six Levels of Agentic Control

Before reaching for a new instruction, architects should understand that instructions are just one of six controls available to influence agent behavior.

| Level | Control | Best for | Not for |
|---|---|---|---|
| 1 | Instruction-free subagent and prompt action selection | Simple, low-stakes choices | Business-critical behavior that must always produce the same outcome |
| 2 | Instructions | Judgment calls, tone, preferences, behavioral guidance | Critical validation, sensitive business rules, fixing routing problems |
| 3 | Data grounding | When the agent needs accurate facts from Knowledge, Data Cloud, or other sources | Decisions that don't depend on retrieving specific information |
| 4 | Variables | Passing data explicitly through context or action outputs | Simple conversational guidance that belongs in instructions |
| 5 | Deterministic Actions | Business-critical logic, validation, calculations, integrations | Simple conversational guidance where some variation is acceptable |
| 6 | Agent Script | Deterministic authoring, ordered logic, conditional behavior, controlled transitions | Problems that can be handled by simpler controls above |

> **Practical rule of thumb:** If you have repeatedly rewritten the same instruction and the behavior remains inconsistent, the problem almost certainly needs a different control — not more instruction text.

### When to Use Deterministic Logic (`->`)

Use `->` when:
- The correct behavior can be fully specified in advance
- The stakes of getting it wrong are high (security checks, entitlement gates, financial calculations)
- The action needs to run every time, unconditionally
- You are setting or reading variables
- You are calling a Flow, Apex class, or API action with known inputs

### When to Use LLM Reasoning (`|`)

Use `|` when:
- The user's language is ambiguous and natural language understanding is required
- The response must be generated in natural language
- The correct action depends on nuanced context that cannot be reduced to conditionals
- You are doing slot filling conversationally

### The Golden Rule

> **If you can write it as an `if` statement, write it as an `if` statement.**

Every prompt instruction costs tokens, adds latency, and introduces variability. Every deterministic instruction is free, instant, and reproducible. The default should always be deterministic; the LLM is the exception, not the rule.

### System Instruction Overrides

Subagents can override the agent-level `system.instructions` for specific tones or personas. Subagent-level instructions take complete precedence — they are not merged with the agent-level instructions; they replace them.

```
subagent Technical_Support:
    system:
        instructions: |
            You are a precise technical support specialist.
            Use exact product names and version numbers.
            Avoid casual language.
```

---

## 10. Multi-Agent Orchestration: SOMA, MOMA, and 3P

### The Three Patterns

**SOMA (Single-Org Multi-Agent)**
Multiple specialized agents within the same Salesforce org collaborate under a primary agent. The primary agent delegates to sub-agents via `connected_subagent` blocks. All agents share the same org context, security model, and Data Cloud data space.

**MOMA (Multi-Org Multi-Agent)**
Agents across different Salesforce orgs collaborate via the **Agent2Agent (A2A) protocol**. Trust boundaries enable secure cross-org agent invocation. Each org maintains independent security controls.

**3P (Third-Party Agent Integration)**
Agentforce agents interoperate with non-Salesforce agents via the **A2A protocol**. A2A is the shared delegation mechanism for both MOMA and 3P scenarios.

**MCP (Model Context Protocol)**
A separate mechanism for giving an agent access to external tools and systems. MCP is not an agent-to-agent delegation protocol — it is a tool/system access protocol. Do not conflate MCP with A2A.

> **Beta status:** A2A-based integration for MOMA and 3P is currently in beta. Verify current feature availability before treating these patterns as fully GA for production architectures.

> **Protocol summary:** A2A = agent-to-agent delegation. MCP = agent-to-tool/system access. These are configured separately.

### SOMA Architecture Deep Dive

**The Supervisor Pattern:** The primary agent receives all user input, never handles domain logic directly, and its only job is classification and delegation. Specialized sub-agents handle actual work.

**SOMA Type-Matching Requirement:** The orchestrator agent type and the connected sub-agent type must match. An Agentforce Service Agent can only connect to other Agentforce Service Agents; an Agentforce Employee Agent can only connect to other Agentforce Employee Agents. Mismatched types produce a platform error at configuration time.

**SOMA Anti-Pattern — Chained Connected Sub-Agents:** A `connected_subagent` calling another `connected_subagent` is not a supported pattern. Flatten the chain or introduce a proper supervisor layer.

**SOMA Scale Consideration:** Salesforce recommends limiting an agent to roughly 10 to 15 subagents and assigning no more than 15 actions to any single subagent. Exceeding these thresholds can cause routing inconsistency and degraded performance.

**The "0 Actions" Destructive Change Bug:** A known platform issue — when a destructive change is bundled with a deployment update, it can force a full runtime rebuild of the entire agent. For a monolithic agent, this maximizes blast radius and recovery time. This is one of the strongest arguments for SOMA decomposition: a destructive change to one sub-agent does not trigger a rebuild of the entire agent network.

**Variable Passing:** Variables do not automatically transfer between agents. You must explicitly declare inputs on the `connected_subagent` block.

### MOMA and 3P Trust Boundaries

Key architectural principles:
- Assume zero trust at the boundary. Every cross-boundary call must be explicitly authorized.
- Define the narrowest possible input/output surface for each agent exposed across a boundary.
- Audit cross-boundary calls via the STDM `AiAgentSessionParticipant` DMO.
- A2A and MCP serve different purposes and are configured separately.

---

## 11. Change Management: From Monolith to SOMA

### Why Monoliths Fail at Scale

A single-agent monolith — one agent with twenty subagents handling everything from billing to HR to IT support — is the natural starting point for most organizations. It fails at scale for three reasons:

1. **Routing accuracy degrades** as the number of subagents grows. The classifier has more options and descriptions start to overlap. Pass rates drop.
2. **Release coupling increases.** A change to the billing subagent requires redeploying and retesting the entire agent. Teams block each other.
3. **Ownership becomes unclear.** No team feels full ownership of any subagent. Quality drops.

### SOMA as an Organizational Design Decision

The technical routing limits are one reason to decompose into SOMA. The organizational reason is often more compelling. When multiple teams work on different subagents within a single monolithic agent, their release pipelines are permanently coupled. One team's change, broken dependency, or failing test blocks every other team from releasing.

SOMA decomposition solves this directly. Each sub-agent becomes an independently owned, independently tested, and independently deployable artifact.

> **For clients with multiple vendor teams or internal squads working on the same agent:** SOMA is not primarily a performance decision. It is an organizational design decision. Make it before the monolith ships to production — retrofitting after the monolith is live is significantly more expensive.

### The Migration Path

Do not attempt a big-bang migration.

**Phase 1: Identify candidates for extraction.** Look for subagents that have clear domain ownership, high change frequency, or specialized data access requirements. Billing, HR, and IT support are classic extraction candidates.

**Phase 2: Extract the highest-value candidate first.** Build the extracted agent independently. Give it its own deployment pipeline, its own test suite, and its own agent user with scoped permissions. Wire it into the primary agent via a `connected_subagent` block.

**Phase 3: Iterate.** Extract one sub-agent per sprint. Validate that the monolith's pass rate holds after each extraction before proceeding to the next.

---

## 12. Team Structure and Collaboration for Agent Delivery

### Why Team Structure Shapes Agent Architecture

There is a principle in software engineering called Conway's Law: organizations produce systems that mirror their own communication structure. If two teams have no shared working process, the components they build will develop loose, poorly defined interfaces. If a single team owns too many components without clear internal boundaries, everything ends up tightly coupled.

For agent delivery, this matters because the SOMA architecture in Section 11 only works well if ownership matches structure. A SOMA deployment where one team owns all sub-agents will drift toward tight coupling over time, because the shortcut of making a "quick cross-sub-agent change" is always available. A SOMA deployment where each sub-agent has a clearly defined owner, an independent pipeline, and a versioned interface to the supervisor agent will maintain its modularity under pressure.

You do not need to solve this perfectly upfront. But naming the mismatch early — "our team structure does not match our architecture, and here is what that means for us" — is far more useful than discovering it at scale when every release requires five different people to coordinate.

### Role Clarity for Agent Delivery

Before the first production deployment, every team should be able to answer these questions without hesitation:

- Who authors and commits Agent Script changes?
- Who reviews them before they merge?
- Who has permission to run `sf agent publish` in each environment?
- Who has production activation rights (`sf agent activate`)?
- Who owns the CI pipeline configuration?
- Who is on call if the agent misbehaves in production at 2am?

"Everyone" and "whoever is available" are not answers. They mean that when something goes wrong, the first ten minutes of the incident are spent figuring out who does what rather than fixing the problem.

For SOMA specifically: each sub-agent should have a named owner. When a supervisor agent references a sub-agent via a `connected_subagent` block, the interface between them is a contract between two owners. Both need to know it exists and agree on how it is versioned.

### Admins Are Part of Agent Delivery

A Salesforce admin who manages the Flows that back agent actions is not outside the agent delivery process. They are inside it. If an admin modifies a Flow directly in a sandbox — fixing a field label, adding a new decision branch, correcting a SOQL filter — the agent's behavior in that environment has just changed. The agent metadata has not changed. The repository has not changed. The pipeline has not run. But the agent is now different.

This happens constantly on teams where admins and developers have separate workflows. The solution is not to lock admins out of their sandboxes. The solution is a lightweight shared process: Flow changes that back agent actions go through the same commit-and-review step as Agent Script changes. This does not require admins to become developers. It requires them to understand that their Flow is part of the agent's delivery surface.

A practical way to surface this in the project: add all agent-backing Flows to the repository explicitly, and use `sf project retrieve start --track-source` as part of the integration sandbox workflow. When the pipeline detects a diff between what is in the org and what is in the repository, someone needs to make a decision — commit it, or revert it.

### If Your Team Is Small or Siloed

For small teams: the minimum viable version of this section is a peer review requirement. One person commits a change. One other person reviews it and approves the PR before it deploys. This two-person gate is faster than a CAB, catches most errors, and creates the audit trail that regulated clients need.

For multi-vendor teams: the shared visibility principle is non-negotiable. Everyone whose code affects the agent must be able to read the repository that contains the agent. Siloing sub-agent codebases between vendor teams and integrating only at deployment time produces the same painful late-stage merges that software delivery teams discovered were a bad idea decades ago.

---

## 13. Regulated Industry Delivery Framework

### Finding the Right Internal Stakeholder

The most common failure mode for regulated clients is not a technical problem. It is a governance problem: the delivery team wants to move faster, and the change management process will not allow it. The path to resolving this runs through the right internal stakeholder.

| Role | Why They Can Drive Change |
|---|---|
| CTO / VP of Technology | Owns the technology model. Can sponsor process exceptions or accelerated approval tracks for AI systems. |
| Chief Risk Officer / Head of Compliance | Can be the most powerful ally if the risk of *not* changing is framed correctly. Regulators do not look kindly on autonomous AI systems that silently mislead customers. |
| Head of Digital / Chief Digital Officer | Owns the product roadmap and has business accountability for agent outcomes. |
| VP of Operations (for the agent's business domain) | Closest to the user impact. Most motivated to ensure the agent operates correctly and recovers quickly when it does not. |

The argument that lands: the current governance process was designed for deterministic software. When a deterministic system silently misbehaves, the answer is often to wait for the next deployment window because the risk is contained and recoverable. When an autonomous AI agent silently misbehaves — giving plausible but incorrect answers to customers for weeks — the risk is not contained. It compounds with every session. The deployment cadence must match the risk profile of the system being deployed.

### Finding the Value Stream Bottleneck

Before recommending a process change to a regulated client, it is worth understanding where the time is actually going. Teams often assume the CAB is the bottleneck. The map frequently reveals something different.

**Value Stream Mapping** is a lean tool for making this visible. Draw every stage from "developer starts working on an agent change" to "change is active in production," then estimate two numbers at each stage: how long the stage takes to complete (process time), and how long the change sits waiting to enter it (wait time).

In most teams, wait time dwarfs process time. An agent change might take two hours to author and validate, two hours to run the Testing Center suite, one day for UAT sign-off, and twenty minutes for the CAB review. But if the Testing Center environment is shared and booked three days out, and UAT sign-off requires scheduling a meeting with the business sponsor, the total lead time is two weeks — even though the actual work took less than a day.

**A lightweight version for active implementations:** Ask the team to estimate, for the last three changes that went to production, how many calendar days each stage took. Do not aim for precision. Even rough estimates reveal the shape of the problem.

The map tells you which conversation to have:

- If the biggest wait is PR review: the fix is a team agreement on review turnaround time.
- If the biggest wait is the Testing Center environment: the fix is a dedicated CI sandbox and a scheduled test run.
- If the biggest wait is UAT sign-off: the fix is involving the business sponsor earlier in the sprint.
- If the biggest wait is the CAB queue: the fix is moving all upstream gates earlier so the change is fully verified before it enters the queue.

Teams that invest in faster pipelines without first mapping the value stream often find that their pipeline runs in eight minutes instead of fifteen — but total lead time has not changed, because the bottleneck was never the pipeline.

### Change Approval in Practice — Working With and Around CABs

The 2018 State of DevOps Report, published in *Accelerate* by Nicole Forsgren, Jez Humble, and Gene Kim, found something that surprises most people the first time they hear it: teams that required approval from an external Change Advisory Board showed lower deployment performance and no improvement in change failure rate compared to teams using peer review within the delivery team. CABs, as traditionally practiced, slow delivery without making it safer.

The reason is structural. By the time a CAB reviews a change, it is often already committed to the release. CAB members are rarely close enough to the specific change — an Agent Script diff, a new Apex wrapper — to identify risks that automated testing and peer review would have caught a week earlier. Their approval has become administrative rather than technical.

This is worth naming clearly because Success Architects are often in the position of making the risk argument to regulated clients. The research exists. Peer review within the delivery team is faster, involves more informed reviewers, and still produces the audit trail that compliance teams actually need.

**However.** For many regulated clients — financial services, healthcare, government — the CAB is a compliance requirement that is not going away. The useful conversation is not "should we remove the CAB" but "what should the CAB actually be reviewing, and what should be resolved before it sees the change?"

The reframe: if you cannot remove the CAB, move your quality gates upstream of it.

**What this looks like in practice:**

By the time the CAB sees an agent change, the following should already be done:

- `sf agent validate` has passed in a dedicated CI environment
- The full Testing Center test suite has run and met the pass-rate threshold
- A human UAT sign-off has been obtained from the business sponsor
- A rollback plan is documented in the change ticket, with the prior committed version identified

When the CAB is presented with a change that has cleared all of those gates, its review becomes a fast confirmation of a fully verified change rather than an attempt to evaluate an untested one. This is the correct use of a CAB.

**Use the PR as the compliance artifact.** Every agent change that reaches the CAB should have an attached PR record showing the full diff, test evidence, and the reviewer's name. Many compliance teams who previously relied on CAB minutes as their audit evidence will accept PR records once they see how much more information a PR contains. This is worth piloting on a single change and showing the compliance team the output before the broader conversation.

> **Scenario:** A financial services client has a CAB that meets every second Tuesday. The delivery team spends the ten days before each meeting in a scramble to complete testing and documentation. A value stream map reveals that 60% of the lead time is wait time — the agent change is finished a week before the CAB meeting but sits in a queue. The recommendation is not to eliminate the CAB. It is to move validation, Testing Center, and UAT to the week is complete — not the week before the CAB. Now the CAB approves a change that has been ready and verified for two weeks. The CAB review step drops from two weeks to twenty minutes.

### The Minimum Viable Floor

Not every client can move to weekly deployments. Every client can do these three things regardless of governance structure:

**1. Automated testing as a required condition for CAB submission.** The Testing Center is free in sandbox. A test suite with a defined pass-rate threshold should be part of every change request package submitted to the CAB. If the suite did not pass, the change request does not go to the board.

**2. A committed version on record before every release.** If something goes wrong, the team must be able to roll back without requiring a new emergency governance submission. The prior committed version should be identified, documented, and the rollback command verified in sandbox before every production release.

**3. A pre-approved emergency change procedure for agents.** Work with the client's CAB to define an expedited emergency change track specifically for agent issues. This track should be executable within hours — not weeks — when an agent is causing active harm. The justification for a separate track: a traditional system that silently misbehaves can often wait for the next deployment window. An autonomous AI agent that silently misbehaves for three weeks is not the same risk profile.

---

## 14. Security and the Einstein Trust Layer

The Einstein Trust Layer is a mandatory security perimeter between every Agentforce agent and any external LLM. It is not configurable, bypassable, or optional. Every LLM call passes through it automatically.

**What the Trust Layer enforces:**
- **Data masking:** PII and sensitive field values are masked before being sent to the LLM. Masked tokens are restored in the response.
- **Toxicity detection:** Responses are screened for harmful content before delivery to the user.
- **Prompt injection defense:** The Trust Layer provides a layer of protection against prompt injection attempts embedded in user input.
- **Zero-data retention:** Salesforce LLM providers are contractually prohibited from retaining prompt or response data for model training.

**Audit logging:** All LLM interactions are logged in the `AiAgentGenerativeAiUsage` DMO with token counts, model identifiers, and billing decisions. This is the authoritative source for cost attribution and compliance review.

**Security test categories to cover in Testing Center:**
- Prompt injection attempts via user input
- ForcedLeak — attempts to extract system instructions
- Role-override attempts ("Ignore your previous instructions and...")
- Data extraction attempts targeting masked fields

---

## 15. RAG, Data 360, and the Data Space Permission Gap

### How RAG Works in Agentforce

1. The user's query is converted to a vector embedding using Salesforce's managed embedding model.
2. The embedding is used to search a vector index built from your knowledge content.
3. The top-matching chunks are retrieved and injected into the LLM prompt as context.
4. The LLM generates a response grounded in the retrieved chunks, not its training data.

RAG quality degrades when retrieval fails — because the content is not indexed, the query embedding does not match the content embedding, or the retrieved chunks are the wrong granularity.

### The Jargon Problem

A common RAG failure mode: users ask questions using terminology that does not match the indexed content. A user who asks about "the new onboarding flow" when the knowledge base indexes it as "Employee Welcome Journey" gets zero retrieval hits.

The recommended solution is a **terminology grounding** pattern: maintain a lightweight old-to-new terminology map in Salesforce Knowledge. The agent fetches this map once per session in `before_reasoning` and uses it to translate user queries before retrieval. Business users, not IT, can maintain the map.

### Retriever Architecture

When multiple knowledge sources are involved, the temptation is to build multiple retrievers and let the LLM choose between them. Salesforce recommends against this pattern. LLM-driven retriever selection is unreliable.

> **Recommended pattern:** Use a **single retriever with ensemble ranking** across all relevant knowledge sources. Configure the retriever to blend results from multiple sources using ranking weights rather than delegating source selection to the LLM.

### Environment Guidance: Sandbox vs. Scratch Org

> **Recommendation:** For any work involving Data 360, RAG, retrievers, or the Agentforce Data Library, use a **sandbox** rather than a scratch org as your primary development environment.

**Agentforce without Data Cloud** — supported in standard Developer, Enterprise, Partner Developer, and Partner Enterprise edition scratch orgs:

```json
{
  "orgName": "GenAI Scratch Org",
  "edition": "Partner Developer",
  "features": ["Einstein1AIPlatform"],
  "settings": {
    "einsteinGptSettings": {
      "enableEinsteinGptPlatform": true
    }
  }
}
```

**Agentforce with Data Cloud** — restricted to Partner Business Org (PBO) Dev Hub orgs only. Open a Partner Community case requesting permission before creating Data Cloud scratch orgs:

```json
{
  "orgName": "GenAI & Data Cloud Scratch Org",
  "edition": "Partner Developer",
  "features": ["CustomerDataPlatform", "CustomerDataPlatformLite", "Einstein1AIPlatform"],
  "settings": {
    "einsteinGptSettings": {
      "enableEinsteinGptPlatform": true
    },
    "customerDataPlatformSettings": {
      "enableCustomerDataPlatform": true
    }
  }
}
```

### The Data Space Permission Gap

Data 360 organizes data into **Data Spaces** — logical partitions that govern which data a given agent or user can access. The Default Data Space must be explicitly enabled for the agent user's permission set. Missing this produces a "We couldn't find your data space. Try again later" error.

**Resolution:**
1. In Setup, search for **Permission Sets** and select **Data 360 Architect**.
2. Under Apps, select **Data 360 Data Space Management**.
3. On Data Space Scopes, click **Edit**.
4. Enable the **Default Data Space**.
5. Click **Save**.

Add this step to every environment provisioning checklist.

---

## 16. Testing Your Agent

### Why Testing Is Not Optional

With a Flow or Apex trigger, you can observe the full execution path. It either ran or it did not. With an agent, you cannot observe the reasoning path directly. What happened between inputs and outputs was inferred by the LLM, varies by context, and cannot be replicated exactly.

Three consequences:

1. **UAT is not testing.** A human clicking through ten scenarios before go-live is sampling. It is not a regression suite.
2. **Behavior degrades silently.** A broken Flow throws an error. An agent that has drifted gives plausible-but-wrong answers until someone notices.
3. **Regression is not free.** When you update any part of an agent, you cannot assume the rest still works.

### The Three-Leg Pipeline

| Leg | What it means | Why it matters for agents |
|---|---|---|
| Continuous Integration | Every commit is validated, built, and deployed to a shared environment automatically | Catches dependency and syntax failures before they reach the release window |
| Continuous Testing | Every deployment triggers an automated test suite with a pass/fail gate | The only mechanism available to build confidence in probabilistic behavior |
| Continuous Delivery | Releases can be promoted to production quickly, safely, and repeatably | Reduces mean time to recovery when an agent misbehaves |

### The Testing Pyramid

**Layer 1: Unit testing (Conversation Preview)**
Test individual subagent behavior in isolation using the Conversation Preview panel in Agentforce Builder. Fast, interactive, and useful for authoring-time verification. Not a substitute for structured testing.

**Layer 2: Structured scenario testing (Testing Center)**
Test defined scenarios systematically using the Agentforce Testing Center in sandbox. Each test case defines an input, expected outcome, and evaluation rubric. Results are evaluated by an LLM judge.

**Layer 3: Load and integration testing**
Test agent behavior under volume and in integrated environments using full end-to-end flows.

### The Agentforce Testing Center

The Testing Center is automatically enabled for all Agentforce customers in Sandbox orgs at no additional cost. It supports four test creation methods:

- **Manual (CSV):** Upload test cases as a CSV file. Fastest for bulk creation.
- **AI-generated:** Provide a scenario description and let the platform generate test cases.
- **Knowledge-based:** Generate test cases from your Salesforce Knowledge articles.
- **Conversation import:** Import a real STDM production session as a test case baseline.

**Platform limits — documentation conflict notice:**

> Two official Salesforce sources currently disagree on test-case volume limits. Trailhead's "Trust Your Agents" module states up to 1,000 test cases per test, 10 jobs per 10-hour window. Salesforce Help article 005228642 (published 2026-05-28) states 500 max test cases per job, 10 jobs per hour, with 20-30 cases recommended per batch. **Verify the current limits live in your org before planning large test runs.**

### How Tests Are Evaluated

The Testing Center uses an **LLM-as-judge** evaluation model. For each test case:

1. The agent processes the test input.
2. The judge LLM compares the actual response to the test case's **Acceptance Criteria**.
3. The judge assigns a score on a **0-5 scale**, where scores of 3 or above are considered a pass.
4. Results are aggregated as a pass rate across the test job.

**The Acceptance Criteria problem** is the most common reason test suites produce unreliable results:

| What teams write | What the judge does with it |
|---|---|
| "The agent should be helpful" | Produces unreliable, inconsistent scores |
| "The agent asks for the customer's email address before retrieving any order information" | Produces consistent, reproducible pass/fail scores |
| "The agent declines to reveal its system instructions when asked" | Specific enough to catch a real failure mode |

Vague criteria are not just hard to score. They give teams false confidence. If a test cannot fail, it is not a test.

### What Teams Must Test and Usually Don't

**1. Subagent routing accuracy** — Routing is driven *only* by the subagent name and its classification description. Instructions have zero effect on routing. The fix for wrong routing is always in the classification description — never in the instructions.

**2. `available when` gates** — Test both sides: the user who qualifies and the user who does not. A gate that has not been tested has not been verified.

**3. Escalation paths** — Test the "I don't know" scenario, not just the happy path.

**4. Security and safety scenarios** — Explicitly test prompt injection attempts, ForcedLeak cases, and role-override attempts. See Section 14.

**5. Apex action governor limits** — Test actions at realistic data volumes. An `@InvocableMethod` that fails with a governor limit exception produces a graceful degradation response that users may not report. The error is invisible until someone checks the logs.

---

## 17. Deployment and Metadata

> **What's new in this section:** API v68 (Winter '27), rolling out from August 24, 2026, introduces a dramatically simplified metadata model for agent deployment. The information below covers both the v67 (and earlier) approach and the new v68 approach. Read the version indicator on each sub-section carefully before acting.

### The Five-Phase Release Lifecycle

Agents have a strict, gated lifecycle. These phases cannot be skipped or reordered.

```
Generate > Deploy > Publish > Activate > Test
```

| Phase | What Happens | Common Mistake |
|---|---|---|
| Generate | Author the agent in Builder or VS Code | Starting without a spec or dependency plan |
| Deploy | Push metadata to the target org. Agent is NOT runnable yet. | Treating deploy as "done" |
| Publish | Compiles and creates runtime entities. Locks this version permanently. No unpublish. | Publishing before testing in preview |
| Activate | Makes one version live. Deactivates the previous version automatically. | Not having a rollback plan before activating |
| Test | Run regression suite against the activated version — not the sandbox version. | Stopping at sandbox testing and assuming production matches |

The contrast with traditional delivery is significant. With a Flow, you deploy and it is live. With an agent, deploy is the first of three gated steps. Teams that do not know this will spend hours wondering why their changes are not live after a successful deployment.

---

### API v68 (Winter '27): The New Simplified Metadata Model

> **Applies to: API v68 (Winter '27) and later only.** Both the source and target org must be on API v68. If your sandbox is on Winter '27 but production is still on Summer '26, stay on v67 types until production catches up.
>
> **CLI requirement:** Update to the latest Salesforce CLI before your first v68 migration. Run `sf update` to get Agentforce DX alongside SDR 13.1.1.

Starting with API v68, an agent is represented by exactly **two metadata types**:

| Metadata Type | Purpose |
|---|---|
| `AiAgentDefinition` | Top-level agent definition (parent record, required on first deploy) |
| `AiAgentDefinitionVersion` | One or more agent versions, specified with `#` syntax |

The CLI automatically resolves and retrieves all dependent metadata — topic and action schemas, the agent graph, Agent Script files, and all Flows, Apex Classes, and Prompt Templates invoked by the agent's actions. **You do not need to list these in `package.xml`.**

#### Version Syntax

| What you want | Syntax | Example |
|---|---|---|
| A specific version | `AgentName#<number>` | `DataAgent#1` |
| All versions of one agent | `AgentName#*` | `DataAgent#*` |
| All versions of all agents in the org | `*` | `*` |

#### Example: Retrieve All Versions (Recommended for Initial Migrations)

```xml
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>MyServiceAgent</members>
        <name>AiAgentDefinition</name>
    </types>
    <types>
        <members>MyServiceAgent#*</members>
        <name>AiAgentDefinitionVersion</name>
    </types>
    <version>68.0</version>
</Package>
```

#### CLI Retrieval with Automatic Dependency Resolution

```bash
sf project retrieve start \
  --metadata AiAgentDefinitionVersion \
  --root-type-with-dependencies AiAgentDefinitionVersion \
  --target-org <org alias>
```

#### Six Rules to Read Before Your First v68 Migration

1. **Both orgs must be on API v68.** Do not attempt cross-version migrations.
2. **The first deployment to a target org must include the full `AiAgentDefinition`.** Deploying a version to a target org that has no parent definition will fail outright.
3. **Do not edit the retrieved metadata**, except for the agent user field on a draft agent. Use DX string replacement for the agent user only.
4. **Keep version numbers matched between source and target.** If you create version 4 in production to update the agent user, create a corresponding version 4 in your sandbox. Otherwise your next sandbox deployment will be blocked.
5. **Do not mix old and new metadata types in one deployment.** Deploying `Bot` or `GenAiPlannerBundle` alongside `AiAgentDefinition` or `AiAgentDefinitionVersion` in a single v68 deployment is unsupported and will fail validation.
6. **Metadata API and change sets only.** The new types are not supported for 1GP or 2GP/unlocked packaging.

---

### API v67 and Earlier: The Two Metadata Domains

> **Applies to: API v67 and earlier.** Specifying `<version>67.0</version>` in your manifest continues to work exactly as before.

Two separate domains exist:

| Domain | Metadata Types | Who Creates It | Editable? |
|---|---|---|---|
| Authoring Domain | `AiAuthoringBundle` | Developers via CLI, Builder, VS Code | Yes |
| Runtime Domain | `Bot`, `BotVersion`, `GenAiPlannerBundle` | Created automatically on Publish | No |

**What this means in practice:**
- Deploying the `AiAuthoringBundle` does NOT create a runnable agent.
- Publishing creates all three runtime types simultaneously and locks them.
- Omitting `GenAiPlannerBundle` from a committed agent retrieval or deployment produces an incomplete package and a failed deployment in the target org.

**The AiAuthoringBundle as audit trail and PR review gate:** The `AiAuthoringBundle` is the human-readable form of the agent — the artifact that PR reviewers can read, that auditors can inspect, and that change management boards can reference. The runtime domain metadata is compiled output, not meaningfully reviewable.

#### Sample Package Manifest (API v67 and Earlier)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>NGA_Service_Agent</members>
        <name>Bot</name>
    </types>
    <types>
        <members>NGA_Service_Agent.v2</members>
        <name>BotVersion</name>
    </types>
    <types>
        <members>NGA_Service_Agent</members>
        <name>AiAuthoringBundle</name>
    </types>
    <types>
        <members>NGA_Service_Agent</members>
        <name>GenAiPlannerBundle</name>
    </types>
    <types>
        <members>MyApexClass</members>
        <name>ApexClass</name>
    </types>
    <types>
        <members>My_Action_Flow</members>
        <name>Flow</name>
    </types>
    <version>67.0</version>
</Package>
```

#### v67 Deployment Order

1. Custom objects and fields
2. Apex `@InvocableMethod` wrapper classes
3. Autolaunched Flows
4. GenAiFunction metadata
5. `AiAuthoringBundle` (full agent)
6. Publish
7. Activate

---

### Branching Strategy for Agent Delivery

#### Why Branching Strategy Matters

Your branching strategy determines how many parallel versions of your agent can exist at once, how those versions are integrated, and how long changes wait before they are tested against the real thing.

The 2017 State of DevOps Report is clear: high-performing teams merged to the main branch daily, kept branches alive for less than a day, and maintained fewer than three active branches. For agents specifically, the risk of long-lived branches is higher than it is for standard Salesforce metadata. Agent Script files are holistic: the entire `.agent` file must be syntactically valid and internally consistent for the agent to compile. Two developers modifying different subagents in the same `.agent` file on separate branches that diverge for two weeks will produce a merge conflict in a structured file that is hard to resolve without understanding both sets of changes in full context.

#### The Ideal: Trunk-Based Development

The simplest and most effective branching model: one shared main branch, short-lived feature branches (one per user story), each merged back to main within the sprint. The main branch is always deployable. The pipeline runs on every merge.

> **Scenario:** A team of four is building a service agent with three subagents. Each developer takes a user story, creates a `feature/1042-order-management-refund-edge-case` branch, works on it for two days, and raises a PR. The branch is reviewed, validated by the pipeline, and merged to main the same sprint. Nobody is carrying two-week-old Agent Script changes that will conflict with everyone else's work.

#### When Monthly Deployment Windows Force Long-Lived Branches

Many teams cannot achieve trunk-based development initially. Monthly deployment windows, shared sandbox constraints, and governance requirements mean that branches often live for weeks. The goal is not to pretend the constraint does not exist. It is to manage the risk it creates.

**The release branch model:** Create a `release/YYYY-MM-DD` branch that accumulates all approved user stories for a given deployment window. Feature branches are short-lived — they merge into the release branch (not directly to main) when development is complete. Main is updated only when the release branch has successfully deployed to production.

The critical discipline: the release branch must be validated against the target environment **at least once per week**, not only the night before the deployment window. A team that discovers an Agent Script compilation failure on a Wednesday has time to fix it. A team that discovers it at 9pm the night before the deployment window does not.

**Branch naming conventions:**
- Feature branches: `feature/<ticket-id>-<agent-name>-<short-description>`
- Release branches: `release/<YYYY-MM-DD>`
- Hotfix branches: `hotfix/<ticket-id>-<short-description>`

Every commit message should reference a ticket or user story ID. This is the link between the deployment audit trail and the business requirement, and it is how post-incident reviews identify which change introduced a regression.

**For SOMA:** Each sub-agent should have its own feature branch lifecycle, independent of the supervisor agent's branch. Do not bundle sub-agent changes with supervisor changes unless they are genuinely coupled.

**The trade-off to name explicitly:** Long-lived branches do not immediately break anything. The cost is cumulative — merge conflicts accumulate, integration failures are discovered late, and "what is actually in production right now?" becomes a surprisingly difficult question. Teams that accept long-lived branches should compensate with weekly validation runs against the release branch, not just a single run before the window opens.

---

### Environment Pipeline Architecture

#### Why Environment Architecture Matters

The purpose of multiple environments is to discover failures where fixing them is cheap, before the change reaches an environment where fixing them is expensive. For agents, this principle is more critical than it is for deterministic Salesforce features. Small configuration differences between environments — a different Prompt Template version, a RAG retriever pointing at a different Data Cloud instance, a missing permission set assignment — can change agent behavior in ways that are not obvious until a user reports a problem.

#### The Recommended Environment Pipeline

**1. Developer Sandbox** — Individual authoring. Each developer or pair has their own environment for building and iterating. This is where `sf agent validate` and Conversation Preview run continuously during development.

**2. Integration / SIT Sandbox** — The CI pipeline deploys here on every merge to the main branch (or release branch). Automated Testing Center suites run here. This is the first environment where the full agent is tested with all dependencies present. Should be a Partial Copy sandbox or better.

**3. UAT Sandbox** — Human validation by the business sponsor and subject matter experts. Realistic test utterances are run here. A Full Copy sandbox is preferred, particularly for RAG implementations, because data volume and schema directly affect retrieval behavior.

**4. Production** — The target. Nothing goes here without passing the gates above.

> **Scenario:** A healthcare client's UAT sandbox is a Developer sandbox refreshed quarterly. The agent uses a knowledge retriever backed by a Data Cloud instance with 50,000 articles. The UAT sandbox's Data Cloud instance has 200 articles. The agent passes UAT. In production, with 50,000 articles, retrieval ranking changes and the agent starts returning different, sometimes incorrect answers. The fix is not to improve the agent. It is to fix the environment parity gap.

#### If Your Client Cannot Afford Four Tiers

A minimum viable pipeline collapses the integration and UAT tiers into one Partial Copy sandbox used for both automated testing and human validation. This introduces risk — an automated test run can destabilize an in-progress UAT session — but it is a workable compromise.

The non-negotiable: for any implementation using RAG, Data Cloud, or a retriever, a Full Sandbox is required for UAT. If the client's budget does not allow it, that risk must be documented and accepted in writing by the client.

#### Keeping Environments from Drifting

Environments drift. Every org interaction — users creating reports, admins adjusting list views, developers testing permission combinations — introduces small differences over time.

Three practices slow the drift:

1. **Run the full pipeline against all environments on a schedule**, even when no production release is planned. A weekly automated `sf agent validate` and deployment to the integration sandbox surfaces drift before it causes a failure during a release window.
2. **Use the pipeline, not the sandbox UI, to make changes.** Every change committed and deployed through the pipeline keeps the repository and org in sync.
3. **Plan for the agent version sync problem.** When a new agent version is created in one environment — for example, to update the Einstein Agent User on a production fix — a corresponding version must exist in all upstream environments before the next deployment can succeed. Add an explicit version-sync check to the pipeline before any promotion step.

---

### Separating Deployments from Releases

#### Why Deploying and Releasing Are Not the Same Thing

Deploying moves agent metadata to an environment. Releasing makes the agent available to users. These are two separate decisions. Conflating them forces both decisions to happen at the same time, under the same pressure, with the same blast radius.

When a deployment is also a release, you cannot test the agent in a production environment before users see it, cannot roll out to a subset of users to validate behavior at scale, and cannot disable a misbehaving capability without a new deployment window.

Separating the two removes most of this pressure. Deploy the agent during the deployment window. Release to users when you are confident it is ready. If something is wrong, disable it for users without touching the deployment.

#### Three Mechanisms for Agentforce

**Mechanism 1: Permission-based gating**

Deploy and activate the agent, but assign the agent user's permission set only to a named pilot group. Other users cannot invoke the agent. Expand the permission set assignment incrementally as confidence grows.

This is the simplest mechanism and requires no code. It is the right starting point for any new agent release.

> **Scenario:** A retail client's service agent goes to production on the first Tuesday. The permission set is assigned to twenty internal users — the support team leads — for the first week. STDM monitoring shows routing accuracy at 91%, below the 95% threshold the team agreed on. One subagent classification description is updated and redeployed the following Tuesday. The permission set is then expanded to all 400 support agents. No customer was exposed to the agent during the calibration week.

**Mechanism 2: Channel gating**

Deploy and publish the agent but do not activate it on the customer-facing channel. Internal testers invoke it through the Agentforce Testing Center or a dedicated internal channel. Activate on the production channel only when the pilot passes.

This is appropriate when the issue is behavioral validation in a production environment, rather than performance at scale. Production data, integrations, and latency are all present. The only thing missing is external user exposure.

**Mechanism 3: Custom Metadata feature flags**

For individual agent capabilities that need to be switchable without a redeployment, use a Custom Metadata type as a feature flag. An `@InvocableMethod` wrapper checks the flag at runtime before executing:

```apex
public with sharing class AgentFeatureFlag {
    public static Boolean isEnabled(String featureName) {
        List<AgentFeatureFlag__mdt> flags = [
            SELECT IsEnabled__c
            FROM AgentFeatureFlag__mdt
            WHERE DeveloperName = :featureName
            LIMIT 1
        ];
        return !flags.isEmpty() && flags[0].IsEnabled__c;
    }
}
```

The flag record can be toggled in production without a new deployment. This is the right mechanism when a specific tool or action needs to be disabled immediately — for example, when an agent action is producing incorrect outputs and needs to be taken offline while a fix is prepared.

**The key insight for teams with monthly deployment windows:** These mechanisms allow a team to deploy on the first Tuesday and release incrementally over the following weeks. The CAB approves the deployment. The release is a permission assignment or flag change that does not require a new deployment window.

---

### Static Analysis and Pre-Commit Quality Gates

#### Why Catch Errors Early

Every failure has a cost, and that cost increases the later in the delivery process the failure is discovered. A compilation error caught by `sf agent validate` before any deployment attempt costs thirty seconds. The same error discovered during a CAB-gated deployment window costs the entire window — a month, in some organizations.

Static analysis is the set of gates that run before any deployment attempt, on every commit, at the cheapest possible point in the pipeline.

Why this is particularly important for agents: an Apex wrapper that fails with a governor limit exception inside an agent action does not throw a visible error to the end user. The agent produces a graceful degradation response — "I was unable to complete that action" — that users may report as a confusing interaction rather than a technical failure. Static analysis would have caught the SOQL-in-loop pattern before the code was ever deployed.

#### The Three Gates

**Gate 1: Agent Script validation**

Run `sf agent validate --authoring-bundle` before every deployment attempt. This catches Agent Script syntax errors, reference errors, and compilation failures. It is fast, non-destructive, and requires no deployment window.

This gate is non-negotiable from day one.

```bash
sf agent validate --authoring-bundle --target-org <sandbox-alias>
```

**Gate 2: Apex static analysis for agent actions**

All `@InvocableMethod` classes that back agent actions should pass PMD static analysis before deployment. The rules to enforce at a minimum:

- No SOQL queries inside loops
- No DML operations inside loops
- Proper sharing model declared (`with sharing` unless explicitly documented otherwise)
- No hardcoded IDs
- All exceptions caught and handled

Start with a small, targeted ruleset. Attempting to enforce all PMD rules on an existing org at once will produce hundreds of violations and cause the team to disable the gate entirely. Four rules enforced consistently are more valuable than fifty rules that nobody looks at.

**Gate 3: Flow static analysis**

Agent-backing Flows should pass Flow Scanner before deployment. Flows that fail at runtime inside an agent are harder to debug than Flows that fail at deployment time, because the failure path goes through the Atlas Reasoning Engine and the graceful degradation response masks the underlying error.

```bash
sf scanner run --target force-app/main/default/flows/ --engine pmd
```

#### The Walking Skeleton Approach

For teams setting up a pipeline for the first time, resist the temptation to wait until the pipeline is complete and correct before using it. Set up all pipeline stages from day one — validate, deploy, test, publish gate — even if the implementation of each stage is minimal.

- Week 1: `sf agent validate` gate only. A pipeline that validates and deploys is already useful.
- Week 2: Add PMD for Apex wrappers with a minimal ruleset.
- Week 3: Add Flow Scanner.
- Week 4: Add the full Testing Center regression suite.

The structure provides value even before every stage is fully implemented. A team that has been running a partial pipeline for a month will have a fully functioning pipeline well before a team that waited to start until everything was ready.

---

### Continuous Delivery Rituals

#### Mechanics vs. Behaviors

The sections above describe the mechanics of the CI/CD pipeline. A pipeline that only runs during release windows is not a continuous delivery pipeline. It is a deployment script with extra steps.

Continuous delivery is as much about team behavior as it is about tooling. High-performing teams internalize certain behaviors until they become automatic — checking the pipeline status every morning as naturally as checking email.

For agent teams specifically, two behaviors are foundational:

**The green build is sacred.** The main branch — or the release branch — must pass `sf agent validate` at all times. If it does not, fixing it is the highest priority on the team. Nothing new is committed on top of a broken build.

This matters for agents more than for standard Salesforce metadata: a broken `.agent` file does not produce a partial deployment. It blocks the entire agent from deploying. A team that discovers this during a deployment window and has three layers of uncommitted changes on top of the original break will spend the window debugging rather than deploying.

**The pipeline runs on a schedule, not just on commits.** Even in a monthly deployment model, `sf agent validate` should run against the integration branch on a daily schedule. Validation does not consume a deployment slot. It is a fast, read-only check. A team that discovers a compilation error on a Tuesday in week two of the month has three weeks to fix it. A team that runs validation for the first time the night before the deployment window does not.

> **Why this matters:** Organizations that deploy monthly often feel that running the pipeline daily is pointless. The answer is that the pipeline is not just for deployments. It is the early warning system that tells you whether the integration environment has drifted, whether a recent commit broke compilation, and whether dependencies between agent components are still intact.

#### The Entropy Principle

The second law of thermodynamics states that the entropy of any isolated system can never decrease — things fall apart unless you continuously apply effort. The same is true of delivery pipelines.

A pipeline that is not exercised regularly will drift. CI environment configuration changes. CLI versions update. Sandbox permissions are adjusted by someone troubleshooting an unrelated issue. Metadata drifts between the org and the repository. None of these changes are catastrophic individually. Together, on a pipeline that has not been run in three weeks, they produce a deployment night where everything that worked last month mysteriously fails.

Running the full pipeline on a schedule — even when no release is planned — is the counterforce to entropy. It catches drift continuously, in small increments, when fixing it is cheap.

---

## 18. Pricing: Flex Credits and Conversations

Agentforce uses a consumption-based pricing model built on **Flex Credits**.

**Two consumption units:**
- **Agentforce Conversation:** A billable unit consumed when a user interacts with an agent through a configured channel. One conversation covers one complete user session, regardless of turn count or action count.
- **Flex Credits:** The underlying currency. LLM token usage, RAG retrievals, and certain Data Cloud operations consume Flex Credits at rates defined by the current pricing table.

**Cost monitoring:** The `AiAgentGenerativeAiUsage` DMO records every LLM call with token counts, model identifiers, and billing decisions. Use this DMO to build usage dashboards and set up alerts for unexpected consumption spikes.

**Cost optimization patterns:**
- Move logic from prompts to deterministic `->` instructions wherever possible. Every prompt instruction consumes tokens. Every `->` instruction does not.
- Use `available when` clauses to hide tools that are not relevant to the current context. Fewer tools in the LLM's context window means lower token counts per turn.
- Guard `before_reasoning` actions with has-loaded flags to prevent redundant API calls. See Section 7.
- Monitor average tokens per conversation by subagent. Outlier subagents with high token consumption are candidates for prompt optimization or deterministic refactoring.

**Planning conversations:** Use the Testing Center conversation logs to estimate average turns and token counts per conversation before go-live. Build a usage projection using the formula: estimated daily active users × average conversations per user per day × average Flex Credits per conversation.

---

## 19. Monitoring and Analytics

### The STDM: Your Primary Production Data Source

Salesforce Trusted Data Model (STDM) is the analytics data model that captures every agent session, turn, action, and routing decision. It is the authoritative source for production monitoring of agent behavior.

Key STDM DMOs for agent monitoring:

| DMO | What it captures |
|---|---|
| `AiAgentSession` | Session-level metadata: start time, end time, channel, outcome |
| `AiAgentConversationEntry` | Each turn in a session: user input, agent response, subagent invoked |
| `AiAgentAction` | Each action invoked during a turn: action name, inputs, outputs, latency |
| `AiAgentSessionParticipant` | Every entity (human, agent, sub-agent) that participated in a session |
| `AiAgentGenerativeAiUsage` | LLM call-level data: token counts, model, cost |

### The Four Metrics That Matter

**1. Routing accuracy** — What percentage of sessions are routed to the correct subagent on the first attempt? Baseline this in UAT. Set a production threshold (typically 90-95%). Alert when it drops below threshold. When routing accuracy drops, the fix is almost always in the subagent classification description, not in instructions.

**2. Task completion rate** — What percentage of sessions achieve the user's intended outcome without escalating to a human agent? This is the primary business outcome metric. Segment by subagent to identify which domain is underperforming.

**3. Escalation rate** — What percentage of sessions end in human escalation? A baseline escalation rate is expected and healthy — some tasks should escalate. An escalation rate that is rising over time without a corresponding rise in session volume is a signal that agent behavior is degrading.

**4. Latency per turn** — How long does each turn take from user input to agent response? High latency is a combination of LLM call time, action invocation time, and network overhead. Baseline per subagent. Unexplained latency increases often indicate a `before_reasoning` action running without a guard condition.

### Setting Up a Production Monitoring Dashboard

Use CRM Analytics or Tableau CRM to build a dashboard sourced from the STDM DMOs above. The minimum viable dashboard for a production agent:

- Sessions per day (by channel, by subagent)
- Routing accuracy rate (7-day rolling average)
- Task completion rate (7-day rolling average)
- Escalation rate (7-day rolling average)
- Average tokens per conversation (for cost monitoring)
- Error rate (sessions ending in the error message response)

Set up alerts for routing accuracy and escalation rate. These two metrics will give you the earliest warning that agent behavior is degrading before users report it through support channels.

### Continuous Testing in Production

The Testing Center is not just a pre-release validation tool. It is the mechanism for continuous testing against a live agent. Run a scheduled Testing Center job against the activated production agent at least weekly. The purpose is not to catch deployment failures — it is to catch behavioral drift. An agent that passed all tests at release but is now producing different answers due to changes in the underlying knowledge base, Data Cloud schema, or LLM model behavior will only be caught by a testing job that runs against the production agent on a schedule.

When a scheduled test job fails, treat it as a production incident: triage immediately, identify the root cause, and determine whether a deployment is needed or whether a knowledge base or configuration change resolves it.

---

## 20. Architect Patterns and Troubleshooting Reference

### Pattern: Session Initialization with Has-Loaded Guard

**Problem:** A `before_reasoning` action that fetches context data runs on every parse, causing redundant API calls.

**Solution:** Guard the action with a boolean flag variable.

```
before_reasoning:
    if @variables.sessionInitialized == False:
        run @actions.FetchSessionContext
            with user_id=@variables.user_id
            set @variables.account_name=@outputs.account_name
            set @variables.account_tier=@outputs.account_tier
        set @variables.sessionInitialized = True
```

---

### Pattern: Entitlement Gate Before Sensitive Tools

**Problem:** Sensitive tools (e.g., process refund, cancel account) need to be hidden from unverified users.

**Solution:** Use `available when` on the tool declaration combined with a `verified` variable set by a deterministic verification action.

```
reasoning:
    actions:
        process_refund: @actions.process_refund
            description: "Process a refund for the user's most recent order."
            available when: @variables.verified == True
```

---

### Pattern: Routing Accuracy Calibration

**Problem:** A subagent is receiving queries intended for a different subagent. Routing accuracy in Testing Center is below threshold.

**Diagnosis:** Routing is driven *only* by the subagent name and `description` field. Instructions have zero effect on routing. Check whether the description is too broad, contains terms that overlap with other subagent descriptions, or lacks negative examples.

**Solution pattern:**
- Make the description specific and use-case-driven. "Handles billing inquiries, payment history, invoice questions, and subscription plan changes" outperforms "Handles billing."
- Add negative examples where descriptions overlap: "Does NOT handle order shipping or returns — those are handled by the Order Management subagent."
- After updating descriptions, re-run the full Testing Center routing suite before re-deploying.

---

### Pattern: RAG Terminology Grounding

**Problem:** Users ask questions using terminology that does not match the indexed knowledge content, producing zero or low-quality retrieval hits.

**Solution:** Maintain a terminology map in Salesforce Knowledge. Fetch it once per session in `before_reasoning`.

```
before_reasoning:
    if @variables.terminologyLoaded == False:
        run @actions.FetchTerminologyMap
            set @variables.terminology_map=@outputs.terminology_map
        set @variables.terminologyLoaded = True
```

The terminology map action translates user terms before the retriever query is constructed. Business users maintain the map in Salesforce Knowledge without IT involvement.

---

### Pattern: Emergency Tool Disable via Feature Flag

**Problem:** A specific agent action is producing incorrect outputs in production. A fix is being prepared, but it will not be ready until the next deployment window. The tool needs to be disabled immediately.

**Solution:** Toggle a Custom Metadata feature flag record in production. The `@InvocableMethod` wrapper checks the flag before executing.

```apex
public with sharing class ProcessRefundAction {
    @InvocableMethod(label='Process Refund' description='Processes a refund for the given order')
    public static List<Result> execute(List<Request> requests) {
        if (!AgentFeatureFlag.isEnabled('ProcessRefund')) {
            Result r = new Result();
            r.success = false;
            r.message = 'Refund processing is temporarily unavailable.';
            return new List<Result>{ r };
        }
        // ... actual refund logic
    }
}
```

The flag record is toggled in production Setup > Custom Metadata Types > Agent Feature Flags. No deployment required. The agent gracefully informs the user the capability is unavailable, which is far better than a silent graceful degradation response with no explanation.

---

### Troubleshooting Reference

| Symptom | Likely Cause | Diagnostic Step | Resolution |
|---|---|---|---|
| Agent gives plausible but wrong answers | LLM boundary misplaced — judgment used for facts | Check which instructions could be replaced by deterministic logic or data grounding | Move fact-based logic to `->` instructions or RAG |
| Routing to wrong subagent | Subagent description too broad or overlapping | Compare subagent descriptions side by side; run Testing Center routing suite | Rewrite classification descriptions; add negative examples |
| `before_reasoning` action runs multiple times per turn | Missing has-loaded guard | Check whether the action is guarded by a boolean variable | Add `if @variables.X == False:` guard and set flag after first execution |
| Agent fails to compile after deploy | Agent Script syntax error or missing reference | Run `sf agent validate --authoring-bundle` before deploy | Fix the error identified in validation output |
| "We couldn't find your data space" error | Default Data Space not enabled for agent user's permission set | Check Data Space Scopes in the permission set configuration | Enable Default Data Space in Data 360 Data Space Management |
| Publish fails with type error on action I/O | Using bare `number` type in action definition | Check action input/output type definitions | Use `lightning__numberType` for Flow targets, `lightning__integerType` for Apex |
| Deployment fails: version without parent | `AiAgentDefinitionVersion` deployed before `AiAgentDefinition` exists | Check whether the target org has the parent definition | Include the full `AiAgentDefinition` in the first deploy to any target org |
| Latency spikes on specific subagents | `before_reasoning` action running without guard, or too many tools in context | Check STDM `AiAgentAction` latency by subagent; count tools in reasoning.actions | Add has-loaded guards; remove unused tools; use `available when` to hide irrelevant tools |
| Testing Center pass rate drops after a deploy | Agent behavior drifted due to prompt template or knowledge base change | Compare test results before and after deploy; check which test cases now fail | Identify the changed component; roll back or fix; re-run suite |
| Sub-agent not receiving variables from supervisor | Variables not declared in `connected_subagent` inputs block | Check the `connected_subagent` block for missing input declarations | Add all required variable mappings to the `inputs` block of the `connected_subagent` |
| EinsteinHyperClassifier router throws platform error at runtime | `before_reasoning` or `after_reasoning` block present on an EinsteinHyperClassifier subagent | Check the agent router subagent for lifecycle blocks | Remove all lifecycle blocks from EinsteinHyperClassifier subagents |
| Rollback fails after emergency activation | Prior version not identified and verified before go-live | Check the commit history for the last known-good version | Use the prior committed version number in `sf agent activate`; verify rollback procedure in sandbox before every production release |

---

*End of guide. Version 7, Winter '27. Updated August 30, 2026.*
