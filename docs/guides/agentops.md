# AgentOps: A Success Architect's Guide to Agentforce

**Audience:** Success Architects helping customers design, build, troubleshoot, and improve Agentforce agents.

**Purpose:** A grounded, scenario-rich reference covering architecture fundamentals, Agent Script, execution lifecycle, multi-agent orchestration, security, testing, deployment, pricing, and monitoring — tied directly to Salesforce documentation and product specifications.
---

## Table of Contents

1. [What Is AgentOps?](#1-what-is-agentops)
2. [The New Agentforce Architecture](#2-the-new-agentforce-architecture)
3. [Agent Script: The Language of Agents](#3-agent-script-the-language-of-agents)
4. [Agent Script Blocks: The Building Blocks of an Agent](#4-agent-script-blocks-the-building-blocks-of-an-agent)
5. [The Execution Lifecycle: before_reasoning, reasoning, and after_reasoning](#5-the-execution-lifecycle-before_reasoning-reasoning-and-after_reasoning)
6. [Actions, Tools, and Variables](#6-actions-tools-and-variables)
7. [The LLM Boundary: Where Judgment Ends and Code Begins](#7-the-llm-boundary-where-judgment-ends-and-code-begins)
8. [Multi-Agent Orchestration: SOMA, MOMA, and 3P](#8-multi-agent-orchestration-soma-moma-and-3p)
9. [Change Management: From Monolith to SOMA](#9-change-management-from-monolith-to-soma)
10. [Security and the Einstein Trust Layer](#10-security-and-the-einstein-trust-layer)
11. [RAG, Data 360, and the Data Space Permission Gap](#11-rag-data-360-and-the-data-space-permission-gap)
12. [Testing Your Agent](#12-testing-your-agent)
13. [Deployment and Metadata](#13-deployment-and-metadata)
14. [Pricing: Flex Credits and Conversations](#14-pricing-flex-credits-and-conversations)
15. [Monitoring and Analytics](#15-monitoring-and-analytics)
16. [Architect Patterns and Troubleshooting Reference](#16-architect-patterns-and-troubleshooting-reference)

---

## 1. What Is AgentOps?

### The Business View

Every organization has more jobs to be done than it has people to complete them. Agentforce is Salesforce's platform for building and deploying autonomous AI agents that engage customers, support employees, and execute business processes at scale, 24 hours a day, across every channel.

**AgentOps** is the operational discipline of running those agents in production. It covers how agents are designed, built, tested, deployed, governed, monitored, and improved over time. Think of it as DevOps — but the artifact under management is an AI agent with language-model reasoning at its core.

As a Success Architect, you sit at the center of this discipline. Customers will come to you when an agent does not behave as expected, when they want to scale a pilot into production, or when they need to understand the tradeoffs between architectural patterns. This guide equips you for all of those conversations.

### Why AgentOps Is Different from Traditional ALM

Traditional application lifecycle management operates on deterministic systems. The same inputs always produce the same outputs. Regression testing is straightforward: compare output A to expected output B.

Agentforce agents have two layers of behavior. The **deterministic layer** — defined in Agent Script logic instructions — behaves exactly like compiled code. The **probabilistic layer** — powered by a large language model — produces outputs that can vary even when inputs are identical. That variability is a feature when you need natural conversation. It is a liability when you need guaranteed execution of a business rule.

AgentOps is the practice of managing both layers simultaneously. Architects who understand this distinction from the start will avoid the most common production failures.

### Mapping Traditional ALM Roles to AgentOps

Every traditional ALM role has a direct counterpart in AgentOps, but each carries expanded responsibilities.

| Traditional Role | AgentOps Responsibility |
|---|---|
| Release Manager | Tracks evaluation pass rates as a release-readiness metric alongside open defect counts |
| Architect | Ensures behavioral baselines are captured before integration; owns the LLM boundary decision |
| QA Engineer | Owns the `AiEvaluationDefinition` suite, writing utterances and configuring LLM-as-a-Judge scoring |
| Security Reviewer | Performs adversarial red-team testing including prompt injection and indirect payload attacks |
| Business Owner | Validates agent behavior against original business requirements; signs off UAT |

> **Scenario:** A QA engineer who has spent years writing Apex test assertions discovers that Agentforce evaluation scores are probabilistic — PASS/FAIL on quality dimensions, not binary correct/incorrect. Her first instinct is to treat a LOW Instruction Adherence score as a bug. The architect explains: the agent returned the right data but did not follow the subagent's tone instruction. That is a real problem, but it requires an authoring fix, not a code rollback. Understanding this distinction is the first skill gap to close on every new Agentforce team.

---

## 2. The New Agentforce Architecture

### The Business View

Before February 2026, Agentforce agents relied on LLM reasoning for nearly every decision — including routing, sequencing, and business rule enforcement. That architecture was flexible, but unpredictable. Agents that worked in demos would behave differently in production. Sequential workflows would loop. Required steps could be bypassed by a user who phrased a request in an unexpected way.

The new Agentforce, generally available since February 2026, separates deterministic execution from LLM reasoning and lets each handle only what it is suited for. The result is an architecture that enterprises can trust with high-stakes workflows.

### The Three-Stage Execution Pipeline

The authoring and runtime layers are intentionally separated. You work in the authoring layer. You cannot directly access the execution layer. That separation is by design — it allows the platform to enforce deterministic behavior independently of how the script was written.

**Stage 1: Authoring**
You work in **Agentforce Builder**, hosted within Agentforce Studio. Builder replaces the legacy Setup experience as the primary authoring path. You edit your agent in one of three interchangeable views: Conversational (natural language, "vibe building"), Canvas (low-code, document-like), or Script (direct Agent Script editing). All three views compile to the same underlying Agent Script.

**Stage 2: Compilation**
The Salesforce compiler transforms your Agent Script into an **Agent Graph** — a serialized execution plan optimized for machine execution rather than human readability. You do not debug at this layer. The Agent Graph is the artifact the runtime consumes.

**Stage 3: Runtime Execution**
The **Atlas Reasoning Engine** reads the Agent Graph, traverses it based on current session state, and decides at each node whether to execute deterministically or invoke the LLM. The engine enforces guard clauses and conditional routing explicitly, rather than inferring them.

```
Author (You)
    ↓ write
Agent Script (human-readable DSL)
    ↓ compile
Agent Graph (machine-optimized execution plan)
    ↓ execute
Atlas Reasoning Engine (state machine + LLM caller)
    ↓ produces
Agent response to user
```

### The Two Execution Paths

On every incoming user turn, the Atlas Reasoning Engine chooses one of two paths.

**Path A: Deterministic Execution**
No LLM is involved. The engine classifies the user's intent, matches a logic instruction, and runs compiled code top-to-bottom. Flow, Apex, or API actions are called with deterministic parameters. The result passes back through the trust layer with full audit logging. This path is fast, cheap, and reproducible.

**Path B: LLM Reasoning**
The engine takes this path when logic instructions alone cannot resolve intent. It traverses the Agent Graph node by node. A node with **prompt instructions** (marked with `|`) triggers an LLM call. A node without prompt instructions executes deterministically. The presence of a prompt instruction is the explicit trigger — it is declared in the script, not inferred at runtime.

### What Triggers an LLM Call

There are eight points in the execution lifecycle where the LLM is invoked:

1. Subagent classification (deciding which subagent handles the user's request)
2. Agent reasoning (deciding what action to take next)
3. Response generation (assembling the final reply from a hydrated prompt)
4. Groundedness validation (confirming output is grounded in retrieved data)
5. Action simulation (in Preview and Simulate mode)
6. Structured output generation (when response must conform to a schema)
7. Localization generation
8. Progress indicator generation

Every unnecessary LLM call adds latency, cost, and variability. Architects should push deterministic logic by default, reserving the LLM for tasks that genuinely require reasoning or natural language generation.

> **Scenario:** A bank builds an agent that checks whether a branch is currently open before offering to book an appointment. A junior developer writes a prompt instruction: "If it is not business hours, tell the user the branch is closed." An experienced architect rewrites this as a deterministic `run @actions.check_business_hours` in `before_reasoning`, storing the result in a variable. The deterministic version costs zero LLM tokens, executes in milliseconds, and produces the same result every time. The prompt version might hallucinate a business hours policy if the model is confused.

---

## 3. Agent Script: The Language of Agents

### The Business View

Agent Script is the language that defines everything about how an agent behaves: its configuration, business logic, and prompting. It is designed to be human-readable without requiring knowledge of the underlying graph architecture. Non-developers on a business team can read Agent Script and understand what an agent is supposed to do.

### Technical Overview

Agent Script is a compiled, declarative, property-based domain-specific language (DSL). Its two most important characteristics:

- **It is whitespace-sensitive.** Indentation determines structure, similar to Python.
- **It uses `@` for resource access.** Variables, actions, utilities, and subagents are all referenced with `@variables.x`, `@actions.x`, `@utils.x`, and `@subagents.x`.

The syntax uses two characters to distinguish the two types of instructions:

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
            # Deterministic: fetch order if we don't have it yet
            if @variables.order_summary == "":
                run @actions.lookup_current_order
                    with member_email=@variables.member_email
                    set @variables.order_summary=@outputs.order_summary

            # Prompt: LLM handles the natural language response
            | Refer to the user by name {!@variables.member_name}.
              Show their current order summary: {!@variables.order_summary}.
              If they want past order info, ask for Order ID and
              use {!@actions.lookup_order}.
```

In this example, the data fetch is deterministic (no LLM, every time). The user-facing response is a prompt (LLM generates natural language). The architect has placed the boundary exactly where it belongs.

### The EinsteinHyperClassifier

For subagent classification — deciding which subagent handles a given user request — Salesforce provides the **EinsteinHyperClassifier**, a Salesforce-owned model that is significantly faster and more accurate than a general LLM for this classification task.

**Advantages:**
- Significantly faster subagent classification compared to other LLMs
- Increased classification accuracy, particularly for specialized classification constraints and negative instructions

**Limitations — read these carefully before designing your agent router:**
- **Cannot use `before_reasoning` or `after_reasoning` blocks at all.** This is a hard platform constraint, not a style recommendation. If your `agent_router` uses the EinsteinHyperClassifier and you place any logic in `before_reasoning` or `after_reasoning`, the agent will throw a platform error at runtime.
- **Can only use the `@utils.transition` tool.** No other tools or actions are available to it.

> **Architect implication:** The `before_reasoning` guard patterns described throughout this guide — such as session initialization, entitlement checks, or has-loaded guards — **cannot be applied to an `agent_router` subagent that uses the EinsteinHyperClassifier.** Any initialization logic that must run before routing must live in a dedicated initialization subagent that executes before the router, or it must be handled by a standard (non-EinsteinHyperClassifier) router. If you need both fast routing and `before_reasoning` logic, use the EinsteinHyperClassifier for classification and a separate subagent for initialization.

---

## 4. Agent Script Blocks: The Building Blocks of an Agent

Every Agent Script file is composed of named blocks. Each block contains properties that describe data or procedures. Here is a complete reference.

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

Defines the agent's default user. The agent runs in the context of this user, and the user's permissions grant or deny access to Salesforce data. This is a critical security configuration — the agent user should have only the permissions required for the agent's tasks.

```
access:
    default_agent_user: "service-agent@yourcompany.com"
```

### system Block

Contains global instructions and required messages. The `welcome` and `error` messages are both required. Use linked variables to personalize messages.

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

Defines global session variables available to all subagents. Variables are typed, have defaults, and carry descriptions that help the LLM understand their purpose.

Three variable types exist:
- **Custom (mutable):** Writeable during the session. These are the primary orchestration tool.
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

### start_agent Block (Agent Router)

Every agent has exactly one `start_agent` block. Every user utterance begins execution here. This block handles subagent classification, filtering, and routing. In Canvas view, it appears as the "Agent Router."

```
start_agent agent_router:
    description: "Welcome the user and route to the correct subagent."
    reasoning:
        instructions: |
            Analyze the user's request and route to the most appropriate subagent.
        actions:
            go_to_identity: @utils.transition to @subagent.Identity_Verification
                description: "Verifies user identity before other actions."
                available when @variables.verified == False
            go_to_orders: @utils.transition to @subagent.Order_Management
                description: "Handles order lookup and updates."
                available when @variables.verified == True
            go_to_escalation: @utils.transition to @subagent.Escalation
                description: "Escalates to a human agent."
                available when @variables.verified == True
```

The `available when` clause is a hard platform-level gate, not a prompt instruction. When the condition evaluates to false, the transition is removed from the LLM's tool list entirely. The LLM cannot route to a destination it cannot see.

**Note:** If this `agent_router` uses the EinsteinHyperClassifier model, it cannot have `before_reasoning` or `after_reasoning` blocks, and it can only use `@utils.transition` as a tool. See Section 3 for the full EinsteinHyperClassifier constraint summary.

### subagent Block

A subagent handles a specific category of user intent. It contains a `description` (used by the routing engine), an optional `system.instructions` override, a `reasoning` block (instructions and tools), and an `actions` block (action definitions).

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

Used in SOMA multi-agent architectures. Defines a reference to another Agentforce agent in your Salesforce org. The connected agent is a separate, full agent — not a topic within the current agent.

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

## 5. The Execution Lifecycle: before_reasoning, reasoning, and after_reasoning

### The Business View

The most common source of unexpected agent behavior is logic placed in the wrong execution block. Understanding precisely when each block runs — and when it does not — is one of the highest-leverage skills for an AgentOps architect.

### The Parse: The Primary Unit of Execution

The primary unit of execution in Agent Script is not the user turn. It is the **parse**: a single complete cycle through a subagent's three lifecycle blocks. The Atlas Reasoning Engine initiates a new parse in three situations:

1. On first entry into the subagent
2. After every tool call, when an action completes and returns a result
3. On every new user turn within the same subagent

One user turn can trigger multiple parses if multiple tool calls occur. This has a direct implication: initialization logic placed without a guard condition in `before_reasoning` will run more than once per user turn in multi-action flows.

### The Three Blocks

| Block | When it runs | LLM involved? | EinsteinHyperClassifier supported? |
|---|---|---|---|
| `before_reasoning` | At the start of every parse, before the LLM sees anything | Never | **No — platform error if used** |
| `reasoning` | Contains both deterministic logic and prompt instructions | Mixed | Partial (`@utils.transition` only) |
| `after_reasoning` | After reasoning completes and the LLM has responded | Never (with a critical caveat) | **No — platform error if used** |

### before_reasoning

`before_reasoning` runs unconditionally at the start of every parse. A `run @actions.X` directive here is code. The LLM cannot bypass it.

**Use it for:**
- Session initialization: fetching context records, setting session variables from Apex or Flow
- Authentication and entitlement checks (you want these verified before the LLM sees any tools)
- Context hydration: pre-loading data so the LLM receives populated variables
- Counters or audit variables that must be incremented on every parse

**Do not use it for:**
- Logic that should run only once per session (without a guard condition)
- Logic that depends on the current user input (that input has not been processed yet)
- Transitions — a `transition to` directive in `before_reasoning` fires unconditionally on every parse and creates infinite routing loops
- **Any logic in a subagent that uses the EinsteinHyperClassifier model** — this combination causes a hard platform error

If you need once-per-session initialization, guard it explicitly:

```
before_reasoning:
    if @variables.sessionInitialized == False:
        run @actions.InitializeSession
        set @variables.sessionInitialized = True
```

> **Scenario:** A developer places `run @actions.FetchAccountRecord` in `before_reasoning` without a guard. The action calls an external API. A user turn that triggers three tool calls causes three API calls to the same endpoint. The developer adds `if @variables.account_loaded == False:` and sets the flag after the first successful call. API calls drop from 3 to 1 per turn.

### reasoning

The `reasoning` block contains both deterministic logic (using `->`) and prompt instructions (using `|`). When the Atlas Reasoning Engine encounters a node with a prompt instruction, it triggers an LLM call. When it encounters only logic, it executes deterministically.

The `reasoning.actions` block (also called the **tools** block) defines actions that the LLM can choose to invoke at its discretion, based on the tool's name and description.

### after_reasoning

`after_reasoning` runs once the reasoning loop is finished, after the LLM has responded and action outputs have been captured. Use it for:
- Post-action deterministic checks (evaluate action outputs and branch based on results)
- Deterministic transitions (moving to the next subagent based on variable state, not LLM judgment)
- Variable cleanup before the next turn
- Orchestration sequencing between subagents

**Critical caveat — is_displayable:** When `is_displayable: True` is set on an action, the platform exits the reasoning loop as soon as the LLM surfaces that output. `after_reasoning` never executes in this case. If you have logic in `after_reasoning` that must run reliably, move it into the `before_reasoning` block of the subsequent subagent instead.

**EinsteinHyperClassifier caveat:** `after_reasoning` cannot be used in any subagent configured with the EinsteinHyperClassifier model. Placing it there causes a platform error.

> **Scenario:** An architect places a deterministic subagent transition in `after_reasoning`. In testing it works perfectly. In production, one specific action has `is_displayable: True`, and the transition never fires for users who trigger that action. The fix: move the transition logic to `before_reasoning` of the target subagent, guarded by a variable that the displayable action sets before it exits.

---

## 6. Actions, Tools, and Variables

### Actions vs. Tools: A Critical Distinction

Agent Script has two `actions` blocks that serve different purposes. Confusing them is one of the most common beginner mistakes.

| Block | Location | Who calls it? | When? |
|---|---|---|---|
| `subagent.actions` | Subagent level | You (the developer), deterministically | When the agent parses the subagent |
| `subagent.reasoning.actions` | Inside the `reasoning` block | The LLM, at its discretion | When the LLM decides the tool is needed |

An action defined in `subagent.actions` must be explicitly referenced in `subagent.reasoning.actions` to become a tool the LLM can call. If you only define it in `subagent.actions` and call it deterministically from reasoning logic, the LLM never knows it exists.

### Action Properties

Every action definition contains:

| Property | Required? | Notes |
|---|---|---|
| `description` | Optional but important | The LLM reads this when deciding whether to call the tool |
| `inputs` | Optional | Unbound required inputs trigger LLM slot-filling |
| `outputs` | Optional | Set `filter_from_agent: True` to hide output from LLM context |
| `target` | Required | Format: `flow://DeveloperName`, `apex://ClassName`, `prompt://TemplateName` |
| `require_user_confirmation` | Optional | Forces a user confirmation step before the action runs |

### Conditional Action Availability

The `available when` clause is a hard platform-level gate. When the condition evaluates to false (including `None`, `False`, `0`, or empty string), the action is removed from the LLM's tool list. The LLM cannot call an action it cannot see.

```
actions:
    execute_transfer: @actions.execute_transfer
        available when @variables.validation_passed
        with from_account=@variables.source_account
        with to_account=@variables.destination_account
        with amount=@variables.transfer_amount
```

**Design rule:** Never let the LLM set the gate variable for a high-stakes action. Use `before_reasoning` or a deterministic `run` and `set` block to keep the gate in a known state.

### The Action Loop Problem

An action loop occurs when the LLM calls the same action repeatedly without reaching a terminal state. Two conditions must both be true: the `available when` condition remains satisfied after the action runs, and the reasoning instructions do not explicitly tell the LLM to stop calling it.

Fix: set the gate variable to a closed state as part of the action's post-execution logic, or use a separate `has_run` boolean that closes the gate after first execution.

### Action Chaining

You can specify a second action to run immediately after a reasoning action completes, creating a guaranteed execution sequence without LLM involvement.

```
reasoning:
    actions:
        GetOrderByOrderNumber: @actions.GetOrderByOrderNumber
            with orderNumber=@variables.order_number
            set @variables.orderDetails=@outputs.orderDetails

            # Automatically runs after GetOrderByOrderNumber
            run @actions.ScheduleOrder
                with orderDetails=@variables.orderDetails
                set @variables.deliveryDate=@outputs.deliveryDate
```

### Variables

Variables persist context across conversation turns and across subagents. They are the state management backbone of every Agentforce agent.

**Variable types:**
- **Mutable custom variables:** Writeable at any point. The primary tool for tracking session state.
- **Linked variables:** Bound to a source (e.g., a Salesforce record field). Read-only. Updated when the source changes.
- **System variables:** Platform-defined, read-only. Includes `@variables.user_input` (the current user message).

**Best practices:**
- Initialize mutable variables with sensible defaults (empty strings, `False`, `0`)
- Use descriptive names — the LLM reads descriptions when reasoning about state
- Store action outputs in variables before referencing them in conditionals
- Use `@utils.setVariables` when you want the LLM to set a variable from natural language (slot filling)

### The @utils Utilities

`@utils` provides four utility functions for subagent control flow:

| Utility | Purpose | Notes |
|---|---|---|
| `@utils.transition to @subagent.X` | One-way routing to another subagent | Execution does not return to the calling subagent |
| `@utils.setVariables` | LLM-driven variable assignment from natural language | Use for slot filling, not for gate variables |
| `@utils.escalate` | Transfer to a human agent via Omni-Channel | Requires Omni-Channel configuration |
| `@utils.end_session` | Immediately terminates the conversation | No further processing after this call |

---

## 7. The LLM Boundary: Where Judgment Ends and Code Begins

### The Business View

The most consequential architectural decision you will make in any Agentforce implementation is where to place the boundary between deterministic code and LLM reasoning. Get it wrong in one direction and you have an agent that is rigid, expensive to maintain, and unable to handle natural conversation. Get it wrong in the other direction and you have an agent that is flexible but unpredictable — one that works in demos but fails in production.

The new Agentforce model gives you the tools to place that boundary deliberately.

### The Decision Framework

| Use deterministic logic for | Use LLM reasoning for |
|---|---|
| Input validation and sanitization | Natural language understanding and intent detection |
| Business rule enforcement | Generating conversational, empathetic responses |
| Sequential process orchestration | Handling ambiguous or unexpected inputs |
| State management and context preservation | Providing explanations and contextual clarifications |
| Guard clauses preventing invalid operations | Adapting tone and messaging to user context |
| Counter increments and audit trails | Open-ended research and summarization |

### A Production Example: Deterministic Bank Transfer

A bank transfer workflow illustrates how these patterns work together. The user wants to move money from account A to account B. The implementation requires: collecting account details, validating the amount, checking the transfer limit, confirming available balance, and only then executing the transfer. Each step depends on the previous. None of them should be left to LLM judgment.

**Step 1 — Collect and validate inputs (deterministic):**

```
instructions: ->
    if not @variables.source_account:
        set @variables.validation_passed = False
        | Ask the user for their source account number.
    if @variables.source_account and not @variables.destination_account:
        set @variables.validation_passed = False
        | Ask the user for their destination account number.
    if @variables.transfer_amount <= 0:
        set @variables.validation_passed = False
        | The transfer amount must be greater than zero. How much would you like to transfer?
    if @variables.source_account and @variables.destination_account and @variables.transfer_amount > 0:
        set @variables.validation_passed = True
```

**Step 2 — Enforce the transfer limit (deterministic rule, conversational response):**

```
    if @variables.transfer_amount > @variables.transfer_limit:
        set @variables.validation_passed = False
        | The requested amount exceeds the maximum transfer limit of
          {!@variables.transfer_limit}. Would you like to transfer the
          maximum amount, split into multiple transfers, or contact support?
```

**Step 3 — Gate the execute action (platform-level, not a prompt):**

```
actions:
    execute_transfer: @actions.execute_transfer
        available when @variables.validation_passed
        with from_account=@variables.source_account
        with to_account=@variables.destination_account
        with amount=@variables.transfer_amount
```

The `execute_transfer` action does not exist in the LLM's tool list until `validation_passed` is true. No conversational pressure from the user can invoke it before every check has passed. The gate is enforced by the platform, not by a prompt instruction.

The gate starts closed by default:

```
variables:
    validation_passed: mutable boolean = False
        description: "True only when all transfer validations have passed"
```

Every variable starts in a known safe state. The workflow must actively earn the right to proceed at each step.

> **Key architectural principle:** When you write `| Always run the validation check first`, that is a suggestion. The LLM may or may not follow it depending on conversation context. When you write `if not @variables.validated: set @variables.validation_passed = False`, that is code. It executes on every parse without exception.

---

## 8. Multi-Agent Orchestration: SOMA, MOMA, and 3P

### The Business View

A single agent trying to handle every business function in an organization is like hiring one generalist employee and expecting them to replace your entire service, billing, logistics, and compliance teams simultaneously. It does not scale. It creates bottlenecks. And when something goes wrong, it is hard to isolate the problem.

Multi-agent orchestration solves this by allowing specialized agents — each with focused capabilities, defined permissions, and a specific data scope — to collaborate as a team. The user sees one seamless conversation. Behind the scenes, a coordinating agent delegates tasks to the right specialist, aggregates results, and returns a unified response.

Salesforce supports three multi-agent patterns, each suited to different organizational contexts.

### SOMA: Single-Org Multi-Agent

**What it is:** Multiple Agentforce agents within the same Salesforce org, coordinated by a single Superagent (also called the "front door" agent).

**Architecture:**
- The **Superagent** is the customer-facing entry point. Users only interact with it. They never see the sub-agents.
- **Sub-agents** are specialized domain agents (e.g., Billing, Logistics, HR, Compliance) that operate behind the scenes.
- Sub-agents can be connected to multiple Superagents, enabling reuse across workflows.

**How routing works:** The Superagent uses the Atlas Reasoning Engine (with the EinsteinHyperClassifier for speed) to route requests based on sub-agent descriptions and topic metadata. For critical business logic, architects define `@when` expressions in Agent Script for deterministic transitions.

**State management:** Variables sync bidirectionally between the Superagent and sub-agents. The Superagent passes recent conversation context to sub-agents. Changes a sub-agent makes to shared variables are reflected in the Superagent on the next turn.

**Failure handling:** When a sub-agent fails, the Superagent retries for transient failures (model failure, integration failure). The system gives up immediately for failures where retrying would produce the same result (auth failure, no topic matched, input too long). The user always receives a clean message — they never see internal error details or sub-agent names.

**Real-world example:** Deloitte's internal employee agent ecosystem (AEA) uses a Pursuit Agent for complex sales opportunity management and a Relationship Agent for contact lifecycle tracking. Both serve different user groups with different business rules within the same Salesforce org. A single generalist agent could not enforce the distinct permission models and workflows required by each.

### MOMA: Multi-Org Multi-Agent

**What it is:** Agentforce agents coordinating across multiple Salesforce orgs within a trusted organizational boundary.

**Use case:** A primary agent in one org delegates tasks to a specialist agent in a different org, while the user never changes interface or re-authenticates.

**Trust model:**
- Both orgs must reside within the same data center trust boundary
- Trust is established through explicit org-to-org agreements with agent allow-listing
- No automatic agent discovery — every connection is deliberate
- Identity passes at runtime via a single Salesforce login; no re-authentication required

**Delegation depth:** One level only. Org A can delegate to Org B. Org B cannot further delegate to Org C within the same chain.

**Real-world example:** Salesforce Professional Services uses a Delivery Agent in ORG62 that delegates knowledge retrieval to a Services Central Knowledge Agent in a separate ServicesORG. A Delivery Lead asks for a project template. The Delivery Agent delegates to the Knowledge Agent invisibly. The response surfaces in the Delivery Agent interface. The user never changes context.

### 3P: Third-Party Agent Interoperability

**What it is:** Agentforce agents interoperating with agents from external vendors (non-Salesforce systems) using the Agent-to-Agent (A2A) protocol.

**Two directions:**
- **Outbound (AF → 3P):** An Agentforce agent delegates tasks to a registered third-party agent. Admins register 3P agents via the Agentforce Registry, storing credentials in Named Credentials.
- **Inbound (3P → AF):** A third-party agent calls an Agentforce agent via an External Client App (ECA) with a custom `a2a_api` scope.

**Real-world example:** Box and Salesforce collaborate on RFP Response Automation. Box agents provide deep document intelligence for analyzing RFP content. Salesforce agents provide CRM relationship data and sales workflow logic. Neither company's agent can perform both functions alone. The combined workflow reduces RFP response time from hours to near-real-time.

### The Supervisor Pattern

All three multi-agent patterns (SOMA, MOMA, and 3P) use the **Supervisor pattern**: a single orchestration brain (the Superagent or Primary Agent) manages all worker agents, reasons over which agent should handle which task, maintains state, and delivers a unified response to the user.

This pattern provides the governance and trust model needed to scale multi-agent systems securely:
- **Single point of accountability:** One agent owns every interaction
- **Bounded predictability:** One-level delegation prevents unpredictable cost and failure loops
- **Auditability:** All actions trace back to the original user and the Primary Agent
- **Composability:** Specialist agents are designed for reuse across different workflows

---

## 9. Change Management: From Monolith to SOMA

### The Business View

One of the most common organizational patterns you will encounter as a Success Architect is the **monolithic agent**: a single Agentforce agent that has grown to encompass dozens of subagents across multiple business domains — billing, order management, identity verification, returns, technical support, and more.

This pattern often emerges from good intentions. A team starts with one agent, it works well, and they keep adding subagents. Over time, the agent becomes a shared asset with no clear owner. Multiple teams contribute subagents to the same monolith. Coordination overhead grows. Deployment conflicts become common. When one team changes a shared variable or a global system instruction, it can break subagents owned by a completely different team.

### When to Recognize the Problem

Watch for these signals with your customers:

- Different business units are contributing subagents to the same agent
- Teams complain that their changes "break" things they did not touch
- Deployment windows require coordination across multiple teams
- Testing one subagent requires running the entire agent's test suite
- A change to a shared Prompt Template triggers cross-team impact analysis

### The Architectural Solution: SOMA

When siloed teams are working on different subagents within a monolithic agent, a SOMA architecture is often the right answer. Instead of all teams sharing one agent, each team owns a standalone Agentforce agent — their own metadata, their own test suite, their own deployment pipeline. A lightweight routing agent acts as the Superagent and treats each team's agent as a connected sub-agent.

```
BEFORE (Monolithic):
Single Agent
├── Billing_Subagent          (owned by Finance team)
├── Order_Management_Subagent (owned by Operations team)
├── Identity_Subagent         (owned by Security team)
└── Returns_Subagent          (owned by Operations team)

AFTER (SOMA):
Superagent (thin routing layer)
├── → Billing_Agent           (owned by Finance team, standalone)
├── → Order_Agent             (owned by Operations team, standalone)
├── → Identity_Agent          (owned by Security team, standalone)
└── → Returns_Agent           (owned by Operations team, standalone)
```

### How to Guide the Conversation

This transition is a **change management conversation first and a technical conversation second.** The teams currently contributing subagents to the monolith have to accept a new ownership model. Here is how to frame it:

**What teams gain:**
- Full ownership of their agent's metadata and deployment pipeline
- Ability to deploy on their own schedule without coordinating with other teams
- Isolated test suites that only cover their domain
- Clear accountability when their agent has a problem

**What teams need to accept:**
- Their agent will be deployed as a connected sub-agent, not as a standalone experience
- They must define a clear agent description and topic metadata (the Superagent uses this for routing)
- Variable sharing between agents must be explicitly mapped at design time
- Sub-agents can be connected to multiple Superagents — they are reusable services, not exclusive components

### The Migration Path

Migration from a monolith to SOMA does not have to happen all at once. A practical approach:

1. **Identify natural boundaries.** Which subagents could stand alone as their own agents? Usually these align with business domains or team ownership.
2. **Extract one sub-agent first.** Pick the team most motivated to own their own agent. Extract their subagents into a standalone Agentforce agent. Connect it to the monolith as a `connected_subagent` before removing the original subagents.
3. **Validate routing fidelity.** Confirm the Superagent correctly routes requests that previously went to the extracted subagents.
4. **Remove the now-redundant subagents from the monolith.** The monolith is now one agent lighter.
5. **Repeat.** Each extraction reduces the monolith and grows the SOMA network.

> **Scenario:** A large retailer has a single Agentforce agent with 24 subagents. Three teams (Customer Service, Logistics, and Finance) all contribute to it. Every deployment requires a joint approval meeting. After a SOMA architecture review, Logistics and Finance each extract their subagents into standalone agents. The Customer Service team's agent becomes the Superagent. Each team now deploys on their own two-week sprint cadence. Joint deployment meetings drop from weekly to quarterly (for Superagent descriptor updates only).

### The Technical Steps

When connecting an existing agent as a sub-agent:

1. In Agentforce Builder, ensure the sub-agent has a clear `description` and meaningful topic descriptions — these drive routing accuracy.
2. Map variables explicitly. In the Superagent's `connected_subagent` block, define `inputs` that bind Superagent variables to the sub-agent's expected variables.
3. Confirm `reset_to_start_node: True` is set (it should always be true for connected sub-agents).
4. Review global `system.instructions` from the Superagent. Connected sub-agents inherit the Superagent's system instructions by default. A sub-agent can opt out with `do_not_use_orchestrator_instructions: True` in its own script if its tone or persona requirements conflict.
5. Test the full routing path, including edge cases where intent is ambiguous between two sub-agents.

---

## 10. Security and the Einstein Trust Layer

### The Business View

Every Agentforce agent that interacts with customers is a potential attack surface. Traditional Salesforce security testing covers SOQL injection, code injection, and sharing-model bypasses. These are well-understood vectors with established prevention patterns. Agentforce adds a fundamentally different attack class: **prompt injection**.

An adversarial payload embedded in data the agent retrieves or processes can cause the agent to treat that payload as system instructions — potentially overriding its authored behavior, exfiltrating data, or taking unauthorized actions.

### The Einstein Trust Layer

The Einstein Trust Layer is Salesforce's data security infrastructure for all AI interactions. It operates between your agent and any external LLM provider. Key capabilities:

**Toxicity detection:** Classifies input and output for harmful content before it reaches the LLM or the user.

**PII detection and masking:** Identifies and masks sensitive data (names, credit card numbers, social security numbers) in prompts before they are sent to LLMs. **Critical note:** Data masking is disabled by platform design for all Agentforce use cases. Per Salesforce Help documentation: *"Data masking through the Einstein Trust Layer is disabled to improve the performance and accuracy of agents."* Architects must verify that customers understand this and have compensating controls in place.

**Zero data retention:** By default, Salesforce does not allow third-party LLM providers to store or train on customer data. Prompts and responses are not persisted by the LLM provider.

**Prompt injection defense:** Salesforce defends against prompt injection using a classifier based on mDistilBERT, covering attack categories including Pretending/Role Play, Privilege Escalation, Prompt Leakage, Privacy Attacks, and Malicious Code Generation. This classifier is embedded in the Trust Layer and operates as a platform-level defense against known injection patterns.

**Extended Trust Boundary:** For organizations with heightened data residency requirements, the Anthropic Haiku option on the Extended Trust Boundary keeps data within Salesforce-managed infrastructure without routing through a shared third-party boundary.

### The ForcedLeak Vulnerability (CVSS 9.4)

This documented and now-patched vulnerability (disclosed September 2025 by Noma Security, patched by Salesforce the same month) illustrates why prompt injection testing is mandatory for every agent that ingests externally submitted data.

**The exploit chain** was more complex than a simple payload injection. It required three conditions to align:

1. **Indirect prompt injection via Web-to-Lead:** An attacker embedded malicious instructions in a public Web-to-Lead form field. The lead record was stored in Salesforce as normal CRM data. No special org access was needed — any member of the public could submit the form.

2. **Agent retrieval of the poisoned record:** When an Agentforce agent later summarized or processed leads, it retrieved the record. The malicious payload entered the agent's grounding context, causing the agent to treat it as system instructions.

3. **Data exfiltration via CSP bypass using an expired/hijacked domain:** The exfiltration step relied on a Content Security Policy (CSP) bypass. The attacker used an expired domain that was still on Salesforce's CSP allowlist. By registering or hijacking that expired domain, the attacker created a destination that Salesforce's CSP would not block. The agent was then instructed to exfiltrate data to that domain.

**Why this matters beyond the patch:** Salesforce has patched the specific CSP bypass and expired domain issue. But the underlying attack class — indirect prompt injection via user-submitted data — remains a live threat whenever an agent ingests content from forms, emails, documents, or other external sources that are not sanitized before entering the agent's context. The three-part exploit chain illustrates that real-world prompt injection attacks are typically not single-step payload injections; they chain multiple weaknesses together.

The Trust Layer's mDistilBERT classifier is the platform-level defense. Your authoring-level defenses — `ruleExpressions`, `attributeMappings`, and `filter_from_agent` on action outputs — are complementary and still required. Design Checklist

- [ ] The agent user has only the minimum permissions required for the agent's tasks
- [ ] All action outputs that should not be in LLM context have `filter_from_agent: True`
- [ ] Every agent that ingests externally submitted data has been red-team tested for prompt injection
- [ ] `ruleExpression` security guards are in place for high-stakes actions
- [ ] `enable_enhanced_event_logs: True` is configured in non-production environments for audit visibility
- [ ] The `Customize Application` permission in production is restricted to the CI/CD service account only
- [ ] Salesforce Event Monitoring is configured to alert on unauthorized production modifications to `Bot`, `GenAiPlannerBundle`, or `AiAuthoringBundle` records
- [ ] CSP allowlist has been reviewed to remove any expired or unrecognized domains

### Model Configuration Security

Agentforce allows model overrides at both the agent level and the subagent level using `model_config`. Subagent-specific models take precedence over agent-level models. Any change to `model_config` should be treated as a medium-risk change and requires a full evaluation suite run, because model changes can significantly shift agent behavior even with identical authored instructions.

Recommended models (as of August 2026): GPT 4.1, Claude Haiku 4.5, Gemini 3.5 Flash. The EinsteinHyperClassifier (Salesforce-owned) is available for subagent classification and offers faster performance, but has tool limitations — it only supports `@utils.transition`, and it cannot use `before_reasoning` or `after_reasoning`. See Section 3 for the full constraint summary.

---

## 11. RAG, Data 360, and the Data Space Permission Gap

### The Business View

Retrieval-Augmented Generation (RAG) is the capability that allows an Agentforce agent to ground its responses in real enterprise data — not just in its authored instructions. Instead of relying on what the LLM already knows, a RAG-powered agent retrieves the most relevant chunks of your organization's documents, knowledge articles, or structured data at runtime, and uses those chunks to compose an accurate, current, and contextually relevant response.

This is why RAG is often the difference between an agent that sounds smart and an agent that actually knows your business. Without it, an agent answering product questions is working from general training data. With it, the agent is working from your actual product catalog, your current policies, and your specific customer history.

Data 360 (Salesforce's unified data platform) is the infrastructure backbone of RAG in Agentforce. It handles ingestion, chunking, vectorization, and retrieval of your enterprise content. Understanding the relationship between RAG, Data 360, and the Agentforce Agent User is essential for anyone deploying a RAG-enabled agent.

### How RAG Works in Agentforce

The RAG pipeline has two phases: offline preparation and online retrieval.

**Offline (preparation):**
1. Your content — knowledge articles, files, PDFs, structured Data 360 objects — is ingested into Data 360.
2. Data 360 chunks the content into smaller fragments optimized for semantic search.
3. Each chunk is vectorized (converted into a numerical embedding) using an embedding model such as E5-Large Multilingual or E5-Large V2.
4. The vectors are stored in a Data 360 Vector Database, alongside a keyword index for hybrid search.

**Online (retrieval at agent runtime):**
1. The user sends a message to the agent.
2. The agent's retriever action converts the user's query into a vector using the same embedding model.
3. Hybrid search (combining semantic vector search and keyword search) finds the most relevant chunks.
4. Those chunks are injected into the LLM prompt, grounding the response in real data.
5. The LLM generates a response based on both the authored instructions and the retrieved content.

```
User Query
    ↓ vectorized
Hybrid Search (vector + keyword)
    ↓ retrieves top-N chunks
Prompt Template hydrated with chunks
    ↓
LLM generates grounded response
    ↓
Agent response to user
```

### Agentforce Data Libraries (ADLs)

Salesforce provides Agentforce Data Libraries (ADLs) as the primary low-code path to configure RAG. ADLs automate the creation of search indexes and retrievers. When you add a knowledge article source or a file source to an ADL, the platform handles indexing automatically.

For agents with a `knowledge:` block in their Agent Script, or for agents using the standard "Answer Questions with Knowledge" action, RAG via ADL is provisioned by default. No additional configuration is required beyond enabling Einstein and Data Cloud in the org.

The following Agentforce features are powered by Data 360:

| Feature | Description | Provisioning |
|---|---|---|
| Data Library Automation | Auto-creates search indexes and retrievers for standard knowledge actions | Default |
| Agent Analytics | Streams usage data to Data 360 for reporting | Default |
| RAG (Retrieval Augmented Generation) | Grounds prompts with Salesforce and Data 360 data | Default |
| Audit Trail and Feedback Logging | Generative AI audit data | Optional |
| BYO-LLM | Bring your own language model | Optional |
| External Data Sources | Ground responses in non-CRM external sources | Optional |
| Unstructured Data | Ground responses in files, PDFs, transcripts | Optional |
| Real-Time Data Graphs | Near-real-time grounding from normalized Data 360 sources | Optional |

> **Note for architects:** The "Does Agentforce need Data 360?" question comes up frequently in customer conversations. The short answer is yes — Data 360 infrastructure powers Agent Analytics, the Digital Wallet (Flex Credits tracking), RAG, and audit/feedback logs. Even customers who are not actively using RAG are already using Data 360 for other Agentforce features. Architects should ensure customers understand this dependency before deployment.

### The Data Space Permission Gap: A Critical Deployment Pitfall

This is one of the most impactful silent failures in Agentforce deployments. It affects every team deploying a RAG-enabled agent through a CI/CD pipeline, and it will not produce an obvious error message when it occurs.

#### What Is a Data Space?

A Data Space is a logical partitioning mechanism within Data 360 that organizes data and controls which users and agents can access which data sets. The default Data Space is created automatically when Data Cloud is enabled. Custom Data Spaces can be created for data isolation, multi-tenancy, or compliance requirements.

For an Agentforce agent to query Data Cloud content — including RAG retrievers — the **Einstein Agent User** (the user defined in the `access.default_agent_user` block) must have explicit Data Space access granted in their Permission Set.

#### The Metadata API Limitation

Here is the critical problem: **assigning Data Space scope to a Permission Set is a UI-only operation in Salesforce Setup.** The Metadata API does not support packaging or migrating Data Space assignments within Permission Sets. There is no supported XML node (such as `dataspaceScopes` or `DataSpaceManagement`) in the standard Permission Set metadata schema.

This means that a perfectly configured CI/CD pipeline will:

1. Successfully deploy the Permission Set to the target environment.
2. Successfully deploy the Agent and all associated metadata.
3. **Silently drop the Data Space linkage in the target environment.**

The deployment registers as a success. No error is thrown. But the agent cannot access Data Cloud content.

#### The Failure Mode: Silent Empty Results

When the post-deployment manual step is missed, the agent user in the target environment lacks Data Space visibility. The platform's security model treats the Data Space as if it contains zero records. The agent does not throw a hard error. Instead:

- Grounded queries and retriever actions (such as `productQnA` or any custom RAG action) return empty results.
- The agent may hallucinate a response based on its system prompt alone — because it has nothing to ground against.
- Conversation Preview in Agentforce Builder may indicate an access error or return nothing when the agent tries to invoke a retriever.
- Developers troubleshoot a silent permissions gap that looks like a retrieval or indexing issue, not a permissions issue.

> **Scenario:** A team deploys a product knowledge agent to production after successful sandbox testing. In sandbox, the agent returns accurate, grounded product answers. In production, it either returns nothing or gives vague, hallucinated responses. The team spends two days investigating the search index, the ADL configuration, and the prompt template — all of which are identical across environments. Eventually they discover the agent user in production has no Data Space access. The entire issue is resolved with a two-minute Setup change. The two days of investigation could have been avoided with a documented runbook.

#### The Required Agent User Permission Stack

For any `AgentforceServiceAgent` that uses RAG or has a `knowledge:` block, the Einstein Agent User requires the following permissions:

| Permission | Type | Notes |
|---|---|---|
| `AgentforceServiceAgentUser` | System Permission Set | Required for all customer-facing agents |
| Data Cloud access (one of the below) | Permission Set or PSL | Required when agent has a `knowledge:` block or uses RAG |
| `GenieDataPlatformStarterPsl` | Permission Set License | Assigned via `PermissionSetLicenseAssign`, not `PermissionSetAssignment` |
| `GenieUserEnhancedSecurity` | Permission Set (label: "Data Cloud User") | Seen on some org shapes |
| `DataCloudUser` | Permission Set | Seen on some org shapes |
| Data Space scope assignment | UI-only | **Cannot be automated — requires manual post-deployment step** |

**Why the Data Cloud permset name varies:** The correct permset or PSL depends on org shape (scratch org, Dev Edition, Trailhead trial, sandbox, or production) and platform release. All three names above are seen in production orgs. Hardcoding any single name fails on at least one org shape. The correct approach is to query the org first and assign whichever one exists.

```bash
# Discover which Data Cloud permset exists in this org
sf data query --json \
  --query "SELECT Id, Name, Label FROM PermissionSet WHERE Name IN ('GenieDataPlatformStarterPsl', 'GenieUserEnhancedSecurity', 'DataCloudUser')" \
  -o TARGET_ORG
```

#### Mandatory Post-Deployment Runbook Step

Because Data Space assignment cannot be automated through standard metadata deployments, every Agentforce deployment runbook that involves a RAG-enabled agent must include the following manual step. This step must be completed in every target environment — sandbox, UAT, and production — after every deployment that creates or modifies the agent user's Permission Set.

**Step 1 — Navigate to Permission Sets**
In the target Salesforce environment: Setup > Permission Sets.

**Step 2 — Select the Agent Permission Set**
Locate and open the Permission Set assigned to your Einstein Agent User. This is typically named after the agent (for example, `Agentforce SDR Agent Permissions` or your custom agent permission set name).

**Step 3 — Access Data Space Management**
Under the Apps section within the Permission Set, click **Data Cloud Data Space Management**.

**Step 4 — Assign the Data Space**
Click **Edit**, check the box to enable the Default Data Space (or the specific custom Data Space your agent queries), and click **Save**.

**Important:** Permission changes may take a few minutes to propagate. Test the agent's retriever actions in Conversation Preview after completing this step to confirm access is restored.

#### Change Management Implications

This limitation has two important implications for your customer engagements:

**For existing deployments:** If a customer reports that their RAG-enabled agent worked in sandbox but returns empty or hallucinated responses in production, check Data Space access before investigating any other potential cause. This is the most common root cause of this symptom pattern.

**For new implementations:** Add the post-deployment Data Space assignment step to your project's Definition of Done checklist. Treat it the same way you would treat any post-deployment configuration step — documented, assigned to a named owner, and verified before sign-off.

#### SOMA-Specific Consideration

In a SOMA architecture where multiple sub-agents each handle a different RAG domain, each sub-agent runs as its own Einstein Agent User. **Each agent user requires its own Data Space assignment.** A common mistake is to configure the Superagent's user correctly and assume the sub-agents inherit the same access. They do not. Each connected sub-agent's agent user must be independently configured in the target environment.

> **Scenario:** A retailer deploys a SOMA architecture with a Superagent and three sub-agents: a Product Knowledge Agent (RAG over product catalog), a Warranty Agent (RAG over policy documents), and an Order Agent (no RAG, pure CRM data). After deployment, the Order Agent works correctly because it has no Data Space dependency. The Product Knowledge and Warranty Agents return empty results. The team correctly identifies the Data Space gap, but configures only the Product Knowledge Agent's user — assuming the fix will carry over. The Warranty Agent continues to fail. The fix requires separate Data Space assignments for each sub-agent's Einstein Agent User.

#### Scratch Org Limitation

Scratch orgs do not support Data 360. If your development environment is a scratch org, RAG-based features cannot be tested there. Use a sandbox for any agent that requires Data Cloud access, whether for RAG, Agent Analytics, or Data Space-dependent features.

---

## 12. Testing Your Agent

### The Business View

Testing an Agentforce agent is not like testing an Apex class. There is no single correct output to compare against. A response can be accurate, coherent, appropriately toned, and still fail an Instruction Adherence check because the agent did not follow a specific directive in its subagent instructions. Your testing framework has to capture all of these dimensions simultaneously.

### The Agentforce Testing Center

The Agentforce Testing Center is a sandbox environment for rigorous pre-deployment testing of agent responses, topic classification, and action sequences. It is automatically enabled for all Agentforce customers in Sandbox orgs at no additional cost.

**Test creation methods:**
- **Manual:** Write utterances and expected behaviors directly
- **CSV import:** Upload test cases in bulk
- **AI-generated:** Salesforce generates test cases based on your agent's topics and actions
- **Knowledge-based:** Generate tests from your Knowledge articles
- **Conversation import:** Import conversation logs from previous sessions

**Evaluation dimensions:** The Testing Center uses LLM-as-Judge evaluation. A response is not simply correct or incorrect. It scores on dimensions including:
- **Topic Classification:** PASS / FAIL — Did the agent route to the correct subagent?
- **Action Sequencing:** PASS / FAIL — Did the agent invoke the correct actions in the correct order?
- **Completeness:** PASS / FAIL — Did the response cover everything the user asked?
- **Instruction Adherence:** HIGH / LOW / UNCERTAIN — Did the agent follow its authored instructions?

**Limits:** 500 test cases per job. Recommended batch size: 20-30 cases for reliability.

**Testing RAG-powered agents:** When testing agents that use RAG, add test cases that specifically exercise retriever actions. Verify that the agent retrieves relevant chunks for known queries — do not just test the final response quality. An agent that retrieves the wrong chunks may still generate a plausible-sounding response, making the retrieval failure invisible without explicit retriever-level testing.

> **Scenario:** A QA engineer writes a test: "User says 'I need to check my order status.'" Expected behavior: route to Order_Management subagent, invoke `GetOrderDetails` action, return a coherent summary. The evaluation run scores: Topic Classification — PASS. Action Sequencing — PASS. Completeness — PASS. Instruction Adherence — LOW. The LOW score reveals that the agent returned the right data but did not follow the subagent's tone instruction to address the user by name. Exact-match assertion on action invocation alone would have missed this entirely.

### Behavioral Baselines

In traditional Salesforce delivery, regression tests compare the current build against a fixed set of expected outputs. In Agentforce, regression is measured against a **behavioral baseline** — a scored snapshot of how the agent behaved across a representative test suite at a known point in time.

**Capture the baseline** immediately after each successful promotion to a new environment. Store baseline artifacts in source control alongside the corresponding metadata. Any future evaluation run that scores materially lower than the baseline triggers a regression investigation — regardless of whether any metadata changed.

### Configuration Drift vs. Behavioral Drift

These are two distinct failure modes that require different responses.

**Configuration drift:** The org's metadata state has diverged from what is in source control. The fix is to redeploy from source. This is the familiar ALM problem.

**Behavioral drift:** The agent acts differently even when no metadata change has been made — typically because the LLM platform received a background model update that shifted how it interprets your authored instructions. The metadata is correct. The behavior is not. Redeploying from source control will not fix behavioral drift. The fix is an authoring revision to tighten instructions.

| Signal | Likely cause | Response |
|---|---|---|
| Sudden behavior change immediately after a deployment | Configuration drift or deployment bug | Hotfix or BotVersion rollback |
| Gradual behavior change over days with no deployments | Model-level behavioral drift | Authoring revision to tighten instructions |

> **Scenario:** Two teams report agent problems in the same week. Team A's agent started behaving oddly two hours after a Friday deployment — that is configuration drift. Team B's agent has been gradually giving less complete responses over ten days with no deployments — that is model drift. Treating both with the same rollback procedure wastes time and can mask the real root cause.

### Rollback: Metadata vs. Behavioral

**Metadata rollback:** Reverts the deployed artifacts. Appropriate when a deployment introduced a regression.

**Behavioral rollback:** Activates a prior `BotVersion` without changing underlying metadata. Appropriate when the compiled runtime behavior of the current version is producing poor results but the authored source is not the problem.

Always identify the cause of the regression before choosing the rollback type.

---

## 13. Deployment and Metadata

### The Business View

Agentforce agents have a metadata lifecycle that is distinct from standard Salesforce metadata. Understanding the three agent states and their corresponding metadata requirements prevents the most common deployment failures.

### The Three Agent States

| State | Description | Required Metadata | Editable? |
|---|---|---|---|
| **Draft** | Agent is being authored, not yet committed | `AiAuthoringBundle` only | Yes |
| **Committed** | Agent has been committed for deployment | `AiAuthoringBundle` + `Bot`/`BotVersion` | No (immutable) |
| **Legacy** | Created via the legacy Setup experience | `Bot`/`BotVersion` only | Can be overwritten |

A Committed agent requires both the `AiAuthoringBundle` and the `Bot`/`BotVersion` metadata to be deployed together. Deploying one without the other will fail or produce unexpected behavior.

### The Full Agent vs. Individual Version

When deploying a specific agent version (a specific `BotVersion`), the full agent must already exist in the target org. You cannot deploy a `BotVersion` into an org that has never received the parent `Bot` metadata.

A typical `package.xml` for a full agent deployment:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>NGA_Service_Agent</members>
        <name>Bot</name>
    </types>
    <types>
        <members>NGA_Service_Agent.NGA_Service_Agent_v2</members>
        <name>BotVersion</name>
    </types>
    <types>
        <members>NGA_Service_Agent</members>
        <name>AiAuthoringBundle</name>
    </types>
    <types>
        <members>NGA_Service_Agent.NGA_Service_Agent_v2</members>
        <name>GenAiPlannerBundle</name>
    </types>
    <version>62.0</version>
</Package>
```

### Risk Classification for Change Types

| Change Type | Risk Level | Approval Path |
|---|---|---|
| Iterating on Agent Script instructions | Low | PR peer review + evaluation suite pass |
| Adding or removing a subagent | Medium | PR review + evaluation suite + QA sign-off |
| Modifying `ruleExpression` security guards | High | Full CAB review + Security sign-off |
| Releasing a net-new agent to production | High | Full CAB review + UAT approval + Security sign-off |
| Modifying a shared Prompt Template | High | Full CAB + cross-agent impact analysis |
| Changing `model_config` | Medium | PR review + full evaluation suite |
| Emergency hotfix to a live agent | High | Pre-authorized emergency approver + post-incident review |
| **Deploying a RAG-enabled agent** | **High** | **Full CAB + post-deployment Data Space assignment verification** |

### Preventing Unauthorized Production Changes

- Restrict the `Customize Application` permission in production to the CI/CD service account only
- Configure Salesforce Event Monitoring to alert when `Bot`, `GenAiPlannerBundle`, or `AiAuthoringBundle` records are modified by any account other than the CI/CD service account
- Emergency hotfix branches must originate from the **production release tag** in Git, never from `main` (which may contain unreleased features)

### Agentforce DX: CLI-Based Development

For pro-code development, Agentforce DX provides CLI tooling for agent deployment and testing.

**Environment setup:**
1. Install VS Code, Salesforce CLI, and the Salesforce Extension Pack (includes Agentforce-specific tools)
2. Choose sandbox or scratch org (**use scratch orgs only if Data 360 access is not required — scratch orgs do not support Data 360, which means RAG-powered agents cannot be tested there**)
3. Enable Einstein and Agentforce in the org
4. Create a DX project from the agent template
5. Authorize the org and assign system permissions
6. Create a default agent user via CLI

**Key CLI commands:**
- `sf agent validate authoring-bundle` — Validates Agent Script syntax before deployment (this gate cannot be skipped even in emergency hotfixes)
- String replacement in `sfdx-project.json` can automatically update agent usernames during deployment using the `TARGET_AGENT_USER` environment variable

---

## 14. Pricing: Flex Credits and Conversations

### The Business View

Agentforce pricing directly affects how your customers architect their agents. An agent that makes unnecessary LLM calls or triggers redundant actions does not just perform poorly — it costs more money. Understanding the billing model helps you make the case for deterministic logic over excessive prompting.

### The Two Pricing Models

**Flex Credits** (introduced May 15, 2025, per Salesforce's official press release)
Action-based, pay-per-consumption pricing. Rate: $500 per 100,000 credits ($0.10 per action). Enterprise Edition customers receive free credits. Requires Salesforce Foundations.

**Conversations**
Outcome-based pricing for customer-facing use cases. Billed per resolved conversation rather than per action.

### What Is Billed Under Flex Credits

| Usage Type | Billing Unit | Notes |
|---|---|---|
| Actions | Per execution | Flow, Apex, MuleSoft, MCP tool invocations |
| Help Agent Resolutions | Per resolved outcome | Outcome-based, for Help Agent deployments |
| Voice Minutes | Per minute of voice interaction | |
| Prompts (LLM calls) | Per 2,000-token chunk | Each LLM call is billed in 2,000-token increments |
| Speech Foundations | Per audio processing event | |

**What is not billed:** Utility functions like `@utils.escalate` and `@utils.setVariables` do not consume Flex Credits. Variable assignments are not billed.

### Architectural Cost Implications

Every unnecessary LLM call costs credits. Every redundant action execution costs credits. This pricing model creates a direct financial incentive for the architecture patterns described throughout this guide:

- Placing data fetches in `before_reasoning` with a `has_loaded` guard prevents redundant API calls on subsequent parses
- Using the EinsteinHyperClassifier for routing bypasses a full LLM classification call (though remember: this model cannot use `before_reasoning` or `after_reasoning`)
- Moving validation logic from prompt instructions to deterministic logic eliminates LLM calls entirely for those checks
- `filter_from_agent: True` on action outputs reduces context size, which reduces token counts for subsequent LLM calls

**RAG cost consideration:** Each RAG retriever action is a billed action execution. In agents with multiple retrievers or multiple RAG-dependent subagents, retriever calls can accumulate quickly. Use the `before_reasoning` guard pattern to ensure retrievers are called only when needed, and cache retrieved content in variables to avoid redundant calls within the same session.

> **Scenario:** A customer's agent has a `fetch_account_data` action in `before_reasoning` without a guard. A single user turn that triggers 3 tool calls results in 3 executions of `fetch_account_data` — 3 billed actions, 3 external API calls, 3x the latency. Adding `if @variables.account_loaded == False:` and setting the flag after the first call reduces this to 1 action per turn. At scale across thousands of conversations, this is a meaningful cost reduction.

### Digital Wallet and Consumption Tracking

Customers access Flex Credits consumption data through the **Digital Wallet** in Salesforce. The `AiAgentGenerativeAiUsage` data model object provides 30+ queryable fields for analyzing billable usage by agent, token consumption by model, and usage patterns across communication channels.

---

## 15. Monitoring and Analytics

### The Business View

An agent you cannot observe is an agent you cannot improve. Production Agentforce deployments require monitoring at multiple levels: conversation-level data for debugging individual interactions, aggregate analytics for trend analysis, and audit trails for compliance.

### The STDM: Session Trace Data Model

The **Session Trace Data Model (STDM)** captures data about every agent interaction. For SOMA architectures, both the Superagent and each sub-agent generate independent session traces. The `AiAgentInteractionStep` table records a discrete entry whenever a handoff to a sub-agent occurs, enabling bidirectional trace queries.

**Forward lookup:** Primary Agent Step → Sub-Agent Session ID (via Attributes field)
**Backward lookup:** Sub-Agent Session → Primary Agent ID (via `PreviousSessionId`)

### Quality Scores

Quality scores are calculated by an external LLM-as-Judge that evaluates how well your agent responds to user requests, on a scale from 1 (lowest) to 5 (highest). Scores are bucketed into quality labels:

| Quality Bucket | Score Range |
|---|---|
| Very Low | 0 to 2.0 |
| Low | 2.0 to 3.0 |
| Medium | 3.0 to 4.0 |
| High | 4.0 to 5.0 |

Quality scores are calculated per intent and assess helpfulness across the multiple interactions within that intent — not per individual response.

### The AiAgentGenerativeAiUsage Data Model Object

This DMO records every generative AI interaction event with billing decisions, token metrics, and audit identifiers. It provides 30+ queryable fields including:

- Billable usage by agent
- Token consumption by model
- Usage patterns across communication channels
- Conversation IDs for cross-referencing with session traces

### Key Monitoring Dimensions

**Behavioral metrics:**
- Topic classification accuracy (are users being routed to the right subagent?)
- Action invocation success rate (are actions completing without errors?)
- Session escalation rate (are users being handed off to humans more than expected?)
- Conversation resolution rate (are users achieving their goals?)

**Operational metrics:**
- Token consumption per conversation (cost efficiency)
- Action execution latency (performance bottlenecks)
- Error rate by subagent (which domains are failing most often?)

**RAG-specific metrics:**
- Retriever action success rate (are retrievers returning results, or empty responses?)
- Chunk relevance (are retrieved chunks actually relevant to the query?)
- Groundedness score (is the LLM response grounded in the retrieved content, or hallucinated?)

**Security metrics:**
- Prompt injection attempt rate (from Trust Layer logs)
- Unauthorized production modification alerts (from Event Monitoring)

### Behavioral Drift Monitoring

Behavioral drift — where agent behavior changes without any metadata change — requires a different monitoring approach than traditional error monitoring. The signal is not a spike in errors. It is a gradual decline in evaluation scores over time.

Set up automated evaluation runs against your behavioral baseline on a regular schedule. Configure alerts when scores fall below a threshold. A sudden drop after a deployment is likely a code problem. A slow decline with no deployments is likely model drift requiring an authoring update.

---

## 16. Architect Patterns and Troubleshooting Reference

### Key Patterns Quick Reference

| Pattern | When to use | Key mechanism |
|---|---|---|
| **Fetch before reasoning** | Pre-load data before LLM sees any context | `before_reasoning` with has-loaded guard (not available with EinsteinHyperClassifier) |
| **Gate + validate** | Protect high-stakes actions from premature invocation | `available when @variables.x` on actions |
| **Required flow** | Enforce prerequisite steps (e.g., identity before order access) | Conditional `@utils.transition` at top of instructions |
| **Action chaining** | Guaranteed multi-step execution without LLM memory | `run` inside a `reasoning.actions` definition |
| **Subagent transition** | One-way routing to a specialized subagent | `@utils.transition to @subagent.X` |
| **Step variable sequencing** | Multi-turn required workflows | Integer step variable incremented in `after_reasoning` |
| **Instruction override** | Subagent needs different persona or tone from global | `system.instructions` in the subagent block |
| **Terminology grounding** | Agent needs to map user jargon to indexed content | Fetch terminology map from Knowledge at session start |
| **SOMA front door** | Multiple teams, multiple domains, one user experience | Superagent + connected sub-agents per domain team |
| **RAG cache guard** | Prevent redundant retriever calls within a session | `before_reasoning` guard + variable to store retrieved content |

### Common Troubleshooting Scenarios

**Agent routes to the wrong subagent**
- Check subagent descriptions. They must be distinct and specific — the routing engine uses them to classify intent.
- Verify `available when` conditions are not accidentally excluding the correct subagent.
- Test with utterances that closely mirror real user language, not idealized test phrases.
- If using EinsteinHyperClassifier: remember it cannot use `before_reasoning` or `after_reasoning`. Any initialization logic must live outside the router.

**Action runs when it should not**
- Check the `available when` condition. Is the gate variable being set by the LLM (unreliable) or by deterministic code (reliable)?
- Verify there is no action loop: does the gate variable close after the action runs?
- Check if the action is in `before_reasoning` without a guard — it will run on every parse.

**Action does not run when it should**
- Confirm the action is referenced in both `subagent.actions` (definition) and `subagent.reasoning.actions` (tool exposure) if it needs to be LLM-accessible.
- Check that all required inputs have values. Unbound required inputs trigger slot-filling — the LLM will ask the user for the value before running the action.
- Verify `available when` condition is evaluating to `True` when expected.

**after_reasoning logic is skipped**
- Check whether any action in the reasoning flow has `is_displayable: True`. If so, the platform exits the reasoning loop when that action surfaces, and `after_reasoning` never runs.
- Check whether the subagent is using the EinsteinHyperClassifier model — `after_reasoning` is not supported with that model and will throw a platform error.
- Solution: move the critical logic to `before_reasoning` of the subsequent subagent.

**Platform error on agent_router with EinsteinHyperClassifier**
- Verify the `agent_router` does not contain `before_reasoning` or `after_reasoning` blocks.
- Verify the `agent_router` only uses `@utils.transition` as a tool — no other actions or utilities.
- If initialization logic is needed before routing, move it to a dedicated initialization subagent that transitions to the router.

**Transition creates an infinite loop**
- Never place `@utils.transition to` in `before_reasoning` without a condition that can become false.
- Ensure transitions in `reasoning.actions` have `available when` conditions that close after the transition fires.
- Add a `has_transitioned` boolean that gates the transition action.

**RAG-enabled agent returns empty or hallucinated responses**
- First check: does the Einstein Agent User have Data Space access in this environment? This is the most common cause of this symptom.
- Navigate to Setup > Permission Sets > [Agent Permission Set] > Data Cloud Data Space Management and verify the correct Data Space is assigned.
- If Data Space access is confirmed, check whether the search index is populated. An empty index returns zero results.
- Verify the retriever is configured to query the correct Data Space and the correct content objects.
- Test the retriever directly in Einstein Studio using a known query that should return results.
- Check for jargon mismatch: if the user's terminology does not match the indexed content, consider implementing the terminology grounding pattern.

**Evaluation scores declining gradually with no deployments**
- This is likely model-level behavioral drift, not a code problem.
- Review prompt instructions in the affected subagents and tighten any that rely on LLM interpretation of ambiguous phrasing.
- Do not rollback metadata — it will not fix model drift.

**SOMA sub-agent routing is inaccurate**
- Improve sub-agent descriptions. Make them as specific and distinct as possible.
- Add topic metadata to sub-agents — the Superagent can use topic-level descriptions for more accurate routing, not just the top-level agent description.
- For critical routing rules, use `@when` expressions in Agent Script for deterministic transitions instead of relying on LLM-based routing.

**Variable not available in sub-agent (SOMA)**
- Variables must be explicitly mapped in the `connected_subagent` block's `inputs` section.
- Confirm bidirectional sync is enabled.
- Check that variable names in both agents match the mapping configuration.

### The AgentOps Readiness Checklist

Use this checklist before recommending a customer go-live with a production agent.

**Architecture**
- [ ] LLM boundary is explicitly defined: every decision that can be code is code
- [ ] High-stakes actions are gated with `available when` using deterministically-set variables
- [ ] `before_reasoning` guards prevent redundant action calls
- [ ] Infinite transition loops have been eliminated
- [ ] Sub-agent descriptions are distinct and specific enough for accurate routing
- [ ] Any subagent using EinsteinHyperClassifier has no `before_reasoning` or `after_reasoning` blocks, and uses only `@utils.transition` as a tool

**Security**
- [ ] Agent user has minimum required permissions
- [ ] Sensitive action outputs have `filter_from_agent: True`
- [ ] Prompt injection red-team testing completed for agents ingesting external data
- [ ] `Customize Application` permission restricted to CI/CD service account in production
- [ ] Event Monitoring alerts configured for unauthorized production changes
- [ ] CSP allowlist reviewed to remove expired or unrecognized domains

**RAG and Data 360**
- [ ] Agent user has Data Cloud access permission set assigned (`GenieDataPlatformStarterPsl`, `GenieUserEnhancedSecurity`, or `DataCloudUser` depending on org shape)
- [ ] Data Space scope manually assigned to agent user's Permission Set in every target environment
- [ ] Post-deployment Data Space assignment step documented in the deployment runbook
- [ ] For SOMA architectures: each sub-agent's Einstein Agent User has been individually configured with Data Space access
- [ ] Development environment is a sandbox (not a scratch org) if the agent uses RAG or any Data 360-dependent feature
- [ ] Retriever actions have been tested independently (not just end-to-end response quality)
- [ ] RAG guard pattern implemented to prevent redundant retriever calls

**Testing**
- [ ] `AiEvaluationDefinition` test suite covers primary flows, edge cases, and security scenarios
- [ ] Behavioral baseline captured and stored in source control
- [ ] Topic classification tested with real user language, not idealized test phrases
- [ ] Escalation paths tested
- [ ] Rollback procedure documented and tested

**Deployment**
- [ ] `AiAuthoringBundle` and `Bot`/`BotVersion` packaged together for Committed agents
- [ ] Full agent deployed to target org before attempting BotVersion-only deployment
- [ ] `sf agent validate authoring-bundle` passes in CI pipeline
- [ ] Prior BotVersion retained in production (not deleted) to enable behavioral rollback
- [ ] Post-deployment Data Space assignment verified in target environment after every agent deployment

**Monitoring**
- [ ] Session trace logging configured (STDM)
- [ ] Flex Credits consumption baseline established in Digital Wallet
- [ ] Automated evaluation runs scheduled against behavioral baseline
- [ ] Escalation rate monitoring in place
- [ ] Behavioral drift alerting configured
- [ ] RAG retriever success rate monitoring configured

---
