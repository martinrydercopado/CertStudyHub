# The Agentforce Architect: A Design and Planning Guide

---

## Table of Contents

1. [Introduction](#introduction)
2. [Part 1: The Agentforce Architect: Role and Boundaries](#part-1-the-agentforce-architect-role-and-boundaries)
    - [What the Architect Does](#what-the-architect-does)
    - [The Hybrid Reasoning Boundary](#the-hybrid-reasoning-boundary)
3. [Part 2: The Agent Development Lifecycle](#part-2-the-agent-development-lifecycle)
    - [Phase 1: Ideation and Design](#phase-1-ideation-and-design)
    - [Phase 2: Development](#phase-2-development)
    - [Phase 3: Testing and Validation](#phase-3-testing-and-validation)
    - [Phase 4: Deployment and Release](#phase-4-deployment-and-release)
    - [Phase 5: Monitoring and Tuning](#phase-5-monitoring-and-tuning)
4. [Part 3: Human-in-the-Loop Design](#part-3-human-in-the-loop-design)
    - [The Core Principle: Friction Must Be Justified](#the-core-principle-friction-must-be-justified)
    - [The Plan and Present Pattern](#the-plan-and-present-pattern)
    - [Escalation to a Human Agent](#escalation-to-a-human-agent)
    - [Friction and Posture Together](#friction-and-posture-together)
5. [Part 4: Agent Taxonomy](#part-4-agent-taxonomy)
    - [Conversational Agent](#conversational-agent)
    - [Proactive Agent](#proactive-agent)
    - [Ambient Agent](#ambient-agent)
    - [Autonomous Agent](#autonomous-agent)
    - [Collaborative Agent](#collaborative-agent)
6. [Part 5: Multi-Agent Orchestration](#part-5-multi-agent-orchestration)
    - [When to Recommend Multi-Agent](#when-to-recommend-multi-agent)
    - [The Supervisor Pattern](#the-supervisor-pattern)
    - [The One-Level Delegation Rule](#the-one-level-delegation-rule)
    - [Deployment Topologies](#deployment-topologies)
    - [Trust and Identity in Multi-Agent Systems](#trust-and-identity-in-multi-agent-systems)
    - [Context and the Hierarchy Principle](#context-and-the-hierarchy-principle)
7. [Part 6: Core Architectural Principles](#part-6-core-architectural-principles)
    - [Principle 1: Manage Complexity Through Decomposition](#principle-1-manage-complexity-through-decomposition)
    - [Principle 2: Anchor Reasoning in Real Data](#principle-2-anchor-reasoning-in-real-data)
    - [Principle 3: Embed Security and Governance by Design](#principle-3-embed-security-and-governance-by-design)
    - [Principle 4: Classify Agents to Govern Them](#principle-4-classify-agents-to-govern-them)
    - [Principle 5: Design for Observability from the Start](#principle-5-design-for-observability-from-the-start)
8. [Conclusion](#conclusion)

---

## Introduction

Building an Agentforce agent is not primarily a coding exercise. It is a systems design problem. The code is the last mile. Before a single line of Agent Script is written, an Architect must have answered the hard questions: What should this agent actually do? Where does deterministic control need to take over from probabilistic reasoning? When does a human need to stay in the loop? How many agents are really needed, and how should they relate to each other?

This guide is a tool for Architects who are responsible for answering those questions. It covers the full span of the design process: from the initial conversation with a client, through system decomposition, behavioral governance, and into the continuous improvement loop that begins the moment an agent goes live.

---

## Part 1: The Agentforce Architect: Role and Boundaries

### What the Architect Does

The Architect is the strategic bridge between business objectives and AI execution. While a developer is focused on writing Agent Script, configuring actions, and debugging edge cases, the Architect works one level above: deciding *what* the system does and *how* its components interact.

Concretely, the Architect is responsible for:

- **Problem scoping.** Defining what the agent is and is not responsible for. A scope that is too broad produces an agent that hallucinates, loses context, and frustrates users. A scope that is too narrow produces something that cannot solve the client's problem.
- **Designing the experience.** Mapping the user journey through the agent, identifying every meaningful decision point in the conversation, and deciding which of those points require a human.
- **Setting the hybrid reasoning boundary.** Every agent contains a mix of deterministic logic and probabilistic LLM reasoning. The Architect decides, for each part of the workflow, which side of that boundary a decision belongs on. This is one of the most consequential design choices the Architect makes.
- **Behavioral governance.** Defining how the agent should behave when things go wrong: when it should escalate, when it should stop, and what guardrails prevent it from taking actions it should not take.

> **The Agent Spec.** The primary design artifact the Architect produces is the Agent Specification. It defines the agent's goal, persona, subagent structure, topic and action assignments, data sources, and guardrails before development begins. It functions as the behavioral baseline for developers, testers, and stakeholders. A well-written Agent Spec allows developers to build with confidence and testers to know exactly what to evaluate.

---

### The Hybrid Reasoning Boundary

The single most important conceptual tool for an Agentforce Architect is understanding the boundary between deterministic and probabilistic execution.

**Deterministic instructions** are resolved by the runtime before the LLM ever sees the prompt. They execute as code: they cannot be ignored, reinterpreted, or overridden by clever user input. Use them for anything non-negotiable.

**Probabilistic instructions** are natural language passed to the LLM. They give the model latitude to reason, interpret, and generate responses. They are powerful but inherently flexible, which means the LLM may not always follow them exactly.

The Architect's job is to place requirements on the correct side of this boundary. The rule is simple: **default to the most agentic posture that still meets the requirement, and add deterministic control only when you can name a specific cause.**

Valid causes for deterministic control:

- A step is regulated, audited, or legally constrained.
- A step involves identity verification, authentication, or authorization.
- An action is irreversible or consequential (a refund issued, a contract signed, an account deleted).
- External ordering must be preserved (step 2 cannot run until step 1 returns a confirmed success).
- A failure mode has been observed in preview or production traces.

If none of these causes apply, leave the decision to the model. Over-scripted agents are brittle, expensive to maintain, and paradoxically less reliable than agents that give the LLM appropriate latitude. An instruction like "Step 1: do X, Step 2: do Y" written in prose is not deterministic. It is a suggestion the LLM may or may not follow. Only explicit runtime gates are truly enforced.

> **Scenario.** A financial services client wants an agent that can update a customer's payment method. The update changes external state, is potentially irreversible, and has financial consequences. The Architect marks this as a consequential action and specifies that it must be protected by a machine-enforced confirmation gate: the action is only available when an explicit confirmation variable has been set by a prior confirmation subagent. The developer implements this as an `available when` guard, not as a prose instruction like "always confirm before changing payment details." The prose version the LLM may bypass. The gate version the runtime will not.

---

## Part 2: The Agent Development Lifecycle

Traditional software development assumes deterministic outputs. Given the same inputs, the same code always produces the same result. Agentic systems do not work this way. LLM reasoning is probabilistic, which means the same input may produce subtly different outputs across turns, users, and model versions.

The Agent Development Lifecycle (ADLC) accounts for this. It treats testing and monitoring not as one-time activities but as ongoing disciplines, and it treats deployment not as a finish line but as the beginning of a continuous learning loop.

---

### Phase 1: Ideation and Design

This phase produces the Agent Spec. Nothing should be built until the Spec is complete and agreed upon by all stakeholders.

**What to define in this phase:**

- **Goal.** Define the agent's goal as an observable outcome, not a procedure. A vague goal invites agent drift. "Help customers resolve service requests" is a procedure. "Resolve service cases without human escalation by correctly identifying the issue, retrieving the relevant knowledge article, and providing a verifiable next step" is an observable outcome.
- **Agent type.** Classify the agent using the taxonomy in Part 4 of this guide. Is it Conversational, Proactive, Ambient, Autonomous, or Collaborative? The type determines architecture, data access patterns, and governance requirements.
- **Persona.** Define how the agent should present itself. The persona influences tone, escalation language, and the system instructions developers will write.
- **Topics and actions.** Map the topics the agent will handle and the actions it will have access to. Audit for overlap: having more than one action that does the same task degrades the agent's ability to reason correctly about which tool to use.
- **Data sources.** Identify what data the agent needs and where it lives. Does it need real-time CRM records? Unstructured knowledge articles? External systems via MCP or MuleSoft? Each data source has implications for latency, governance, and the RAG retrieval strategy.
- **Guardrails.** Define the ethical and operational boundaries. What topics is the agent not permitted to discuss? What actions require human review before execution? What happens when the agent cannot help?
- **Prioritization.** Before committing to a scope, map the proposed capabilities against business KPIs. Build only what moves a metric the client can measure.

> **Scenario.** A retail client wants an agent that handles customer returns. During ideation, the Architect maps the return workflow and identifies three distinct moments: eligibility check (is this item returnable?), refund calculation (how much?), and refund issuance (write to the system). The first two are read-only and relatively safe. The third writes to an external system and is irreversible. The Architect specifies in the Agent Spec that the third moment requires an explicit confirmation step before the action executes. This decision is made in Phase 1. The developer implements it in Phase 2. The tester validates it in Phase 3. If it were left undecided, it would likely be skipped.

---

### Phase 2: Development

In Phase 2, developers implement the Agent Spec. The Architect's role shifts to review: validating that the implementation matches the design, that the hybrid reasoning boundary is placed correctly, and that the subagent structure reflects the intended decomposition.

**Key development activities:**

- **Authoring environment.** Developers work in Agentforce Builder, which supports both a visual Canvas view and a direct Agent Script view. For teams building complex workflows, Agent Script is the recommended authoring path because it makes the hybrid reasoning boundary explicit and auditable.
- **Subagent structure.** Each subagent should have a single, narrow responsibility. A subagent that tries to handle too many topics degrades in accuracy. The Architect should review the subagent map against the Agent Spec and flag any subagent that is trying to do more than one job.
- **Action design.** Each action should have a single responsibility. An action that creates a billing account and sends a confirmation email in the same call is harder to retry, harder to test, and harder for the agent to reason over than two discrete actions. All write operations must be idempotent: the agent's reasoning loop may retry an action if it receives an ambiguous response, and retrying a non-idempotent write causes real damage.
- **Org environment.** For agents that require Data 360 access, development happens in a sandbox org. For agents that do not, scratch orgs are also an option. The environment choice has downstream implications for how data is seeded for testing.
- **Knowledge and RAG.** If the agent retrieves knowledge at runtime, the knowledge base must be ingested and indexed in the development environment. Testing an agent against a knowledge base that differs from production is one of the most common causes of performance gaps between sandbox and live behavior.

---

### Phase 3: Testing and Validation

Testing agentic systems is fundamentally different from testing traditional software. Unit tests can verify that a deterministic tool works correctly in isolation, but they cannot tell you how the LLM will reason across a multi-turn conversation, under adversarial inputs, or when the knowledge base returns unexpected results.

Architects must design a testing strategy that covers both layers.

**Deterministic layer testing.** Unit-test every Apex action and Flow in isolation. Verify that actions return correct outputs for valid inputs, return structured error responses for invalid inputs, and behave idempotently when called more than once. These tests do not require an LLM and can run as part of a standard CI/CD pipeline.

**Agent reasoning testing.** Use the Agentforce Testing Center to evaluate how the agent reasons across full conversations. The Testing Center supports multiple test creation methods, including AI-generated test cases, CSV imports, and conversation imports. It uses an LLM-as-judge evaluation model to assess whether the agent's responses match expected behavior across topic classification, action selection, and response quality.

**Common failure scenarios to design tests for:**

- The agent calls the same action more than once without new user input (action loop).
- The agent bypasses a required prerequisite step (mandatory flow violation).
- The agent routes to the wrong subagent when intent is ambiguous.
- The agent reports success when an underlying action failed silently.
- The agent reveals information it should not (trust boundary violation).

**Adversarial testing.** Design test cases where users attempt to bypass guardrails, ask out-of-scope questions, or provide inputs that could cause the agent to behave unexpectedly. This is especially important for agents that handle sensitive operations.

**Human-in-the-loop evaluation.** Batch testing cannot capture everything. A test may confirm factual correctness while missing a tone or empathy failure. Build human review into the testing process, particularly for agents that interact with customers in emotionally sensitive contexts.

> **Scenario.** A healthcare services client builds an agent that helps patients reschedule appointments. Batch tests pass for all common paths. During human-in-the-loop review, a tester notices that when a patient says they are in pain, the agent continues the rescheduling flow without acknowledging the distress. This is not a factual error but an empathy failure that batch tests missed. The Architect revises the Agent Spec to add a persona requirement for distress recognition, and the developer adds a prompt instruction to address it.

---

### Phase 4: Deployment and Release

Agentforce defines agents through metadata. This means agents can be version-controlled, promoted through environments, and deployed using standard Salesforce procedures.

**Key deployment concepts:**

- **Agent as metadata.** An agent's entire definition, including its prompts, subagent structure, and tool configuration, is captured as metadata (specifically `AiAuthoringBundle`, `Bot`, and `BotVersion`). This metadata lives in source control as a single source of truth. Every change is traceable.
- **Draft vs. committed state.** A Draft agent is represented only by `AiAuthoringBundle` and remains editable. Once committed, the agent also generates `Bot` and `BotVersion` metadata, and the committed version becomes immutable. Changes require creating a new version. Architects should ensure teams understand this distinction before deployment, as editing a committed agent in place is not possible.
- **Deployment pipeline.** Deploy agents through standard Salesforce CI/CD pipelines using Change Sets or AFDX. Pipelines should run end-to-end tests at each stage as quality gates before promoting to the next environment. Never deploy directly to production without a validated sandbox run.
- **Activation is separate from deployment.** Deploying an agent makes it available in an org. Activating it makes it live. Treat activation as a distinct, governed step with its own approval process.
- **Phased rollout.** Release new agent versions to a small subset of users first, using canary release strategies. Monitor real-world performance before expanding. Maintain the ability to revert quickly if issues are detected.
- **Versioning for debugging.** Up to 20 versions of an agent can be created. Each version should represent a single logical change. This makes it possible to isolate exactly when a regression was introduced, turning debugging from a guessing exercise into a forensic process.

---

### Phase 5: Monitoring and Tuning

Deployment is not the end of the lifecycle. It is the beginning of the outer loop. Agents operate in unpredictable real-world environments, and the data produced by live interactions is the most valuable signal available for improving performance.

**What to monitor:**

- **Real-time performance metrics.** Track latency, token consumption, and API error rates through dashboards. These provide an immediate view of the agent's operational health.
- **Behavioral and success analytics.** Analyze conversational logs to understand task completion rates, common failure points, and escalation frequency. An agent that escalates to a human 40% of the time is not a success. It is an expensive redirect.
- **Session Tracing.** Agentforce Full Session Tracing captures turn-by-turn logs and stores them in Data 360. Each turn records the topic, LLM steps, action inputs and outputs, pre- and post-turn variable snapshots, and any error messages. This is the primary diagnostic tool for understanding exactly what the agent did and why.
- **RAG quality.** Monitor retrieval metrics including faithfulness (did the response match retrieved content?), answer relevance (was the retrieved content relevant to the question?), and context precision (how much of the retrieved content was actually useful?). Low scores in these areas point to knowledge base gaps or retrieval configuration issues.

**The continuous improvement cadence:**

| Frequency | Activity |
|---|---|
| Daily | Review high-level KPIs and flag negative trends. |
| Weekly | Analyze moments that produced low quality scores or unexpected escalations. |
| Monthly | Diagnose root causes with SMEs, implement changes, validate in sandbox, and redeploy. |

Every change validated in the outer loop re-enters the lifecycle at Phase 3, not Phase 4. Changes that skip testing before redeployment are a leading cause of production regressions.

---

## Part 3: Human-in-the-Loop Design

Human-in-the-loop (HITL) is not a fallback for a system that does not work. It is a deliberate design decision that protects users, the business, and the integrity of the agent's outputs. The Architect's job is to identify exactly where friction is justified, because unnecessary friction destroys the value of automation, and missing friction in the wrong place can cause real harm.

---

### The Core Principle: Friction Must Be Justified

The default posture is to let the agent proceed. Requiring human review or confirmation adds latency, consumes resources, and breaks the experience the agent was built to deliver. Every HITL gate must be justified by a specific reason.

**Justified reasons to add friction:**

| Condition | Why it warrants friction |
|---|---|
| The action is irreversible | A mistake cannot be undone without significant cost or harm. |
| Significant financial consequences | Errors could result in incorrect charges, refunds, or commitments. |
| Legal or regulatory sign-off required | Compliance mandates a human in the approval chain. |
| Agent is not confident in its decision | Ambiguity has surfaced that requires human judgment. |
| Action affects a vulnerable user | Health, safety, or distress context warrants additional care. |
| Policy requires it | The organization has decided this class of action always needs review. |

**Unjustified reasons to add friction:**

- **The Architect is not confident the agent will get it right.** This is a testing and posture problem, not a HITL problem. Build confidence through better testing and tighter deterministic gates.
- **The developer wants to feel safer.** Over-gating produces an agent that interrupts itself constantly and provides no value to the user.
- **The action is complex.** Complexity is not the same as consequence. A complex read-only analysis does not require HITL.

---

### The Plan and Present Pattern

For actions that are consequential or irreversible, the recommended pattern is **Plan and Present**: the agent assembles a complete plan, presents it to the user or to a human reviewer with a clear summary of what will happen, and only executes when explicit confirmation is received.

This pattern has three key properties:

1. **The plan is visible before execution.** The user or reviewer can see exactly what the agent intends to do, in plain language, before it does anything.
2. **Confirmation is machine-enforced, not LLM-dependent.** The action that writes to external state is gated by a confirmation variable that is only set by the explicit confirmation step. The LLM cannot bypass this by interpreting conversational intent as confirmation.
3. **Cancellation is always possible.** The user can cancel or modify the plan at the confirmation step. The gate and the cancel path are designed together.

> **Scenario.** A logistics company builds an autonomous agent that reroutes shipments. Rerouting involves updating external carrier systems and may trigger rebilling. The Architect specifies the Plan and Present pattern: the agent calculates the new route, presents it to the operations team member with a cost summary and a list of affected shipments, and only calls the rerouting action when the team member explicitly confirms. If the team member cancels, the agent returns to its starting state cleanly. The gate is enforced by the runtime, not by a prose instruction to "always confirm before rerouting."

---

### Escalation to a Human Agent

For customer-facing deployments, the agent must have a defined escalation path to a live human agent. This is not just a user experience consideration. It is a safety requirement. Design the escalation path as a first-class subagent transition, not an afterthought.

Key design decisions for escalation:

- **What triggers escalation?** Define explicit conditions: the user explicitly requests a human, the agent fails to resolve the issue within a defined number of turns, the agent detects distress signals, or the agent reaches a topic it cannot handle.
- **What context is carried over?** When escalating, the full conversation context must be available to the human agent. An escalation that forces the customer to repeat themselves is a failure.
- **Who can initiate escalation?** In a multi-agent system, only the orchestrating agent should escalate to a human. Subagents should not initiate escalations independently. They should signal to the orchestrator, which makes the final decision.

---

### Friction and Posture Together

The decision about where to add HITL is closely related to the choice of authoring posture: the dial between fully agentic and fully deterministic. The tighter the posture, the more control the runtime has. The more control the runtime has, the more predictable the agent's behavior. And the more predictable the agent's behavior, the less often human intervention is needed.

A well-architected agent with correctly placed deterministic gates will require *less* HITL than a loosely written agent, because the gates themselves provide the safety guarantees that would otherwise require a human to verify. Adding more HITL to compensate for weak architecture is not a governance strategy. It is a sign that the hybrid reasoning boundary was drawn incorrectly.

---

## Part 4: Agent Taxonomy

Before designing a system, classify each agent you are building. Classification is not a bureaucratic exercise. It determines the architecture, the data access pattern, the governance model, and the user experience design. Trying to build without classification leads to agents that are ambiguously scoped and architecturally mismatched to their use case.

Agentforce recognizes five agent types.

---

### Conversational Agent

**What it is.** A Conversational Agent interacts directly with a user in real time, typically through chat, voice, or a messaging channel. It understands natural language requests, takes actions on behalf of the user, and synthesizes responses in conversational form.

**Value.** It replaces or augments the front-line interaction layer. Customers get immediate responses at any hour without waiting for a human agent.

**CRM scenario.** A customer opens a chat window and asks where their order is. The Conversational Agent greets them, identifies the order, queries the fulfillment system, and returns the current status, all within a single conversation turn.

**Architectural considerations.** Conversational Agents are the most common type and serve as the front door for most user-facing deployments. They typically operate with a mixed posture: agentic for natural conversation handling, with deterministic gates for consequential actions. Latency matters significantly here. Each synchronous action adds turnaround time that the user feels directly.

---

### Proactive Agent

**What it is.** A Proactive Agent monitors data or events and initiates action when defined conditions are met, without waiting for a user to ask. It operates largely in the background and surfaces to users or downstream systems when something requires attention or response.

**Value.** It converts reactive processes into anticipatory ones. Instead of a customer calling to report a problem, the agent detects the problem and acts before the customer knows it exists.

**CRM scenario.** A Proactive Agent monitors customer health scores in real time. When a score drops below a defined threshold, it automatically creates a follow-up task for the account manager, summarizes the account's recent activity, and drafts a personalized outreach email for the manager's review.

**Architectural considerations.** Proactive Agents typically operate headlessly: there is no live user in the conversation. This shifts the governance model significantly. Without a user to confirm or redirect, the agent must have very precise scope and well-designed guardrails. Consequential actions in Proactive Agents warrant particularly careful HITL design, because there is no conversational moment to surface a confirmation.

---

### Ambient Agent

**What it is.** An Ambient Agent observes ongoing activity, such as a conversation, a stream of events, or a user's work session, and provides real-time context, suggestions, or automatic logging without interrupting the primary flow of work.

**Value.** It reduces the manual overhead of capturing and acting on information that is produced during work but would otherwise be lost.

**CRM scenario.** During a sales call, an Ambient Agent listens to the conversation in real time. It surfaces relevant product information to the sales rep as topics arise, identifies competitor mentions, and automatically logs call notes and next steps to the CRM after the call ends, without the rep needing to stop and type.

**Architectural considerations.** Ambient Agents must be designed to observe without disrupting. Their outputs are typically suggestions or automated background actions, not primary responses. Privacy considerations are especially significant: an agent that monitors work activity has access to sensitive conversations, and data governance must be explicitly designed, not assumed.

---

### Autonomous Agent

**What it is.** An Autonomous Agent independently plans and executes complex, multi-step tasks to achieve a high-level goal, with minimal human intervention during execution. It decomposes goals, selects and sequences tools, handles failures, and completes end-to-end workflows.

**Value.** It handles high-volume, complex processes that previously required significant human labor, operating continuously and at scale.

**CRM scenario.** An operations team wants to process end-of-month compliance reviews for all accounts. An Autonomous Agent is given the goal. It retrieves the list of accounts, runs each through a compliance checklist, flags exceptions, generates summary reports, and delivers a final status dashboard, completing in minutes what would take a team of analysts hours.

**Architectural considerations.** Autonomous Agents require the most careful governance design of any agent type. Because they act with minimal human oversight, the consequences of misbehavior are amplified. The Architect must define observable goals rather than vague objectives, explicit failure handling, idempotent write actions, and clear HITL gates for decisions that exceed the agent's delegated authority. An Autonomous Agent that can authorize its own exceptions is a governance failure waiting to happen.

---

### Collaborative Agent

**What it is.** A Collaborative Agent participates in a human-and-agent workflow, working alongside human team members and other agents to complete tasks that no single participant could accomplish alone. It contributes specialized capabilities, surfaces context to all participants, and coordinates handoffs between agents and humans.

**Value.** It enables complex, cross-functional work to proceed faster by bringing the right capabilities to bear at the right moment, while keeping humans meaningfully in control.

**CRM scenario.** A financial institution handles a complex customer complaint involving the customer service team, the fraud investigation team, and the legal department. A Collaborative Agent coordinates the workflow: it enriches the case with relevant account history, routes tasks to the appropriate specialist agents, surfaces a shared status view to all human participants, and ensures each party has the context they need without duplicating effort or losing information at handoffs.

**Architectural considerations.** Collaborative Agents introduce bidirectional context sharing, which requires explicit governance for sensitive information. When an agent can share context with all participants, asymmetric access (some participants should not see certain data) must be implemented as a deliberate safeguard, not assumed. Shared state becomes the persistent memory and workspace for the entire team, and its consistency must be architecturally guaranteed.

---

## Part 5: Multi-Agent Orchestration

As agent systems grow in complexity, single agents inevitably reach their limits. A single agent handling too many topics degrades in accuracy. A single agent cannot efficiently parallelize work across domains. And a single agent creates a single point of failure and a single governance bottleneck.

Multi-agent architectures solve these problems by distributing responsibility across a network of specialized agents, each focused on a narrow domain, coordinated by an orchestrating agent that manages the overall workflow.

---

### When to Recommend Multi-Agent

A single agent is the right starting point for straightforward processes within a single domain. Move to a multi-agent system when the client is hitting architectural walls:

- The agent needs to handle requests that span multiple distinct domains, each requiring different data, skills, or governance.
- Adding more topics to a single agent is degrading its accuracy on existing topics.
- Different business units need to own and update their portion of the agent independently.
- Security or compliance requirements demand strict separation between domains.
- The workflow requires parallel execution that a single sequential agent cannot provide.

---

### The Supervisor Pattern

For all multi-agent deployments, including SOMA, MOMA, and third-party integrations, Agentforce uses the **Supervisor pattern**. One orchestrating agent acts as the front door and the coordination brain. It receives the user's request, decomposes it, delegates sub-tasks to specialist agents, and synthesizes the results into a single coherent response.

The user always experiences one conversation. The complexity of coordination stays behind the scenes.

This pattern provides the governance and trust model needed to scale multi-agent systems across orgs and external partners. By centralizing orchestration, it ensures controlled context flow, consistent decision-making, and a unified user experience.

---

### The One-Level Delegation Rule

The most important structural constraint in multi-agent design is the **one-level delegation limit**: an orchestrating agent may delegate to a specialist agent, but that specialist agent must not delegate further to another agent.

In other words: **A can call B. B cannot call C.**

This is the correct architectural choice. No Architect should design beyond one level of delegation, regardless of whether the platform enforces it in a given deployment topology. The reasons are architectural, not technical:

- **Predictability.** Daisy-chaining creates execution paths that are exponentially harder to trace, test, and debug. When A calls B which calls C, a failure in C produces an error that surfaces at A with no clear diagnosis path.
- **Latency.** Each delegation hop adds round-trip time. In cross-org contexts, the end-to-end response requirement is under 15 seconds. Chains of delegation consume that budget rapidly and leave no margin for retries.
- **Failure isolation.** One level of delegation means one level of failure to handle. Two levels means two levels of partial-completion states that must be reconciled, and the reconciliation logic grows complex fast.
- **Governance and auditability.** Every handshake in a delegation chain must be logged and auditable. Deeper chains produce longer, harder-to-read audit trails that compliance teams cannot practically review.
- **Context integrity.** Each delegation is a context boundary. Too many boundaries means context degrades, fragments, or gets lost before the final response is assembled.

The orchestrating agent must be designed as a true coordinator: it plans, delegates, and synthesizes. It should not be a simple router. A router that says "if the topic is X, forward to agent X" is not an orchestrator. It is a switchboard. The orchestrator must be capable of task decomposition, parallel delegation, and result aggregation.

> **Scenario.** A global retailer is tempted to build a three-tier agent network: a master orchestrator delegates to regional agents, and each regional agent delegates further to product-specific agents. The Architect rejects this design. Instead, the regional agents are dissolved and the product-specific agents are promoted to the second tier, reporting directly to the master orchestrator. The orchestrator is given a richer decomposition capability to handle regional routing itself. The system is flatter, faster, and fully traceable from the orchestrator down to every specialist agent.

---

### Deployment Topologies

| Topology | Description | Use When |
|---|---|---|
| **SOMA** | Multiple specialized agents collaborate within a single Salesforce org, sharing governance and context. | Different domains need separate agents but operate within one org boundary. |
| **MOMA** | A primary agent delegates to specialist agents in other trusted orgs via the Agent-to-Agent (A2A) protocol. | The enterprise operates multiple Salesforce orgs and needs a unified user experience across them. |
| **3P / MCP** | Agents connect to external non-Salesforce agents or tools via the Model Context Protocol or A2A interoperability. | The workflow requires capabilities that live outside Salesforce entirely. |

---

### Trust and Identity in Multi-Agent Systems

Multi-agent systems introduce trust considerations that do not exist in single-agent designs. The Architect must address them explicitly.

- **Identity propagation.** When the orchestrating agent delegates to a specialist, the end user's identity must travel with the request. Without deliberate identity propagation, the specialist agent has no basis for making access control decisions on behalf of the user. MuleSoft's Trusted Agent Identity feature manages this at the gateway layer, using outbound authentication policies to propagate identity across A2A calls, MCP tool calls, and REST API requests.
- **No privilege elevation.** An agent receiving a delegated task must operate with the same or lesser permissions as the calling agent and the end user. A specialist agent must not be able to access data or take actions that the user who initiated the conversation is not authorized to access.
- **Least privilege sharing.** Agents are not automatically shared across orgs or boundaries. Admins must explicitly mark agents as shareable. Sharing must be intentional and governed, not a default.
- **Audit trail.** Every agent-to-agent handshake must be logged. Agentforce Observability provides a full audit trail of the reasoning chain across the agent network.

---

### Context and the Hierarchy Principle

A flat architecture where many specialist agents report to one orchestrator creates **option paralysis**: the orchestrator must evaluate too many agents at once, and its routing accuracy degrades. Well-designed multi-agent networks are hierarchical, not flat.

Group related specialist agents under domain-level coordinators. Each domain coordinator handles routing within its domain. The top-level orchestrator delegates to domain coordinators, not directly to every leaf agent. This keeps the context size at each level manageable, improves routing accuracy, enables domain-level ownership by separate teams, and makes the system traceable at each layer.

The hierarchy principle and the one-level delegation rule work together. Within the hierarchy, each relationship is still one level deep. The orchestrator calls domain coordinators. Domain coordinators call their specialists. No agent in the hierarchy calls an agent two levels below it.

---

## Part 6: Core Architectural Principles

These five principles underpin every design decision in a well-governed Agentforce system. They are not aspirational values. Each one has direct, practical implications for how the Architect makes choices.

---

### Principle 1: Manage Complexity Through Decomposition

A single agent that tries to handle every use case will fail at all of them. As an agent's number of topics and actions grows, its ability to select the right tool and reason correctly degrades. Monolithic agents are a starting point, never a destination.

**The practical rule.** Decompose agents into focused, modular subagents, each with a single responsibility. Decompose agent networks into specialized agents, each with a narrow domain. Each level of decomposition keeps context size manageable, improves accuracy, and enables traceability.

**What this means for action design.** Each action should also have a single responsibility. An action that creates a billing account and sends a confirmation email is harder to retry, harder to test, and harder for the agent to reason over than two discrete actions. Apply the same discipline to actions that you apply to agents.

**What to watch for.** An agent that is given too many topics will show degraded topic classification accuracy. When a new use case is added to an existing agent and performance on existing topics drops, that drop is the signal that decomposition is overdue.

> **Scenario.** A telecommunications company builds a single agent to handle billing, technical support, and account changes. As more topics are added, the agent increasingly misclassifies billing questions as technical support. The Architect decomposes the system into three specialist agents (Billing, Technical Support, and Account Management) under a single Concierge Agent that serves as the front door. Each specialist's classification accuracy improves because it only handles one domain. The Concierge handles the routing.

---

### Principle 2: Anchor Reasoning in Real Data

An agent that reasons without access to current, validated data will hallucinate. It will make up order statuses, invent policy details, and confabulate information that sounds plausible but is wrong. Grounding agent reasoning in real data is not a nice-to-have. It is the difference between an agent that builds trust and one that destroys it.

**The data layer.** Data 360 is the data platform that powers Agentforce's data integration. It provides:

- **Structured data** via CRM records, normalized data models, and the Single Source of Truth (SSOT) data layer, accessible with millisecond-level latency for real-time personalization.
- **Unstructured data** via the vector store, which chunks, embeds, and indexes documents and knowledge articles for semantic search.
- **RAG Retrievers** that perform semantic search, filter by metadata, and rank results by relevance to ground agent responses in the right content.
- **Real-Time Data Graphs** that provide near-real-time grounding from multiple Data 360 sources simultaneously.
- **External data sources** via 270+ connectors and MuleSoft, enabling agents to reach data that lives outside Salesforce.

**RAG governance.** The Architect must also govern what data the agent can retrieve. Data 360 supports attribute-based access control at the object, field, and row level. For unstructured data, metadata filters can restrict what gets retrieved before the query even runs. Governance over knowledge base content is equally important: data that enters the vector store without validation rules is a RAG poisoning risk.

**The design implication.** Identify every data dependency in the Agent Spec. For each dependency, specify the data source, the retrieval mechanism, the latency requirement, and the access control model. Do this before development begins.

> **Scenario.** An insurance company builds an agent that answers policy questions. Initial tests go well because developers test against their own policy documents. In UAT, agents trained on older knowledge articles return answers that contradict current policy. The Architect adds a governance requirement: knowledge articles can only enter the RAG index after approval by the policy team, and the index is re-validated after every policy update.

---

### Principle 3: Embed Security and Governance by Design

Security in agentic systems is not a layer added at the end. It is built into every architectural decision. The new attack surfaces introduced by AI agents, including prompt injection, privilege escalation through agent delegation, and model poisoning via the knowledge base, require the Architect to think about security from the first design conversation.

**The Einstein Trust Layer.** Every interaction between Agentforce and an LLM passes through the Einstein Trust Layer. It performs toxicity detection on both inputs and outputs, masks PII data before prompts are sent to external models, and enforces zero-retention: prompts sent to external models are not retained by the model provider after the API call completes. Every step of the prompt and generation flow is recorded as timestamped metadata in the audit trail.

**The guardrails lifecycle.** The Architect should think about governance across three phases:

- **Preventive (pre-deployment).** Define what the agent is and is not permitted to do before it is built. Scope the agent's topics and actions explicitly. An agent that is not given access to a tool cannot be prompted into using it.
- **Active / runtime.** Enforce behavioral boundaries at runtime through deterministic gates, `available when` conditions, and gateway-level policy enforcement. Agentforce Gateway enforces policies on outbound MCP traffic. MuleSoft Omni Gateway enforces policies on A2A and REST calls. These are runtime guarantees, not instructions to the LLM.
- **Self-improving (the outer loop).** Use session tracing and behavioral analytics to detect governance failures in production: cases where the agent behaved outside its intended boundaries, returned unsafe content, or was manipulated by adversarial inputs. Feed these findings back into the guardrail design.

**Zero trust for agents.** Identity and access management for agentic systems must shift from static, role-based controls to dynamic, intent-based permissions. An agent should be granted access to a tool or data source for a specific task, and that access should be revoked immediately after the task completes. This principle applies to both human-agent and agent-to-agent interactions.

---

### Principle 4: Classify Agents to Govern Them

Without classification, an enterprise agent landscape becomes ungovernable. Different agent types have different risk profiles, different governance requirements, and different operational patterns. A Conversational Agent serving customers through a public chat channel needs very different guardrails from an Autonomous Agent running financial reconciliation in the background.

**The two lenses.** Architects must classify agents through two complementary lenses: technical function and business impact.

*Technical function* defines what role the agent plays in the system. Is it a channel or UX agent serving as the front-facing interface? A specialist agent with deep domain knowledge in a narrow area? A utility service agent performing discrete transactional tasks like summarization or transformation? A maintenance agent handling data quality and enrichment? A long-running agent managing projects, nurturing relationships, or alerting over extended periods?

*Business impact* defines the consequence of the agent's decisions. An agent that can initiate financial transactions has a higher impact classification than one that only provides information. Impact classification determines the level of human oversight, audit requirements, and rollback procedures the agent needs.

**The Agentic Map.** The standard design artifact for documenting this classification is the Agentic Map. It defines four layers:

- **User layers:** Who are the human actors in the system? Customers, authenticated employees, non-authenticated employees?
- **Agent layers:** What agents are involved, what patterns do they implement, and how do they relate to each other?
- **Context and actions:** What resources and capabilities does each agent manage or access?
- **Sources:** What data, knowledge bases, applications, and external systems do agents connect to?

Completing an Agentic Map for a client engagement forces the classification decisions that would otherwise remain implicit and later cause governance gaps.

---

### Principle 5: Design for Observability from the Start

An agent that cannot be observed cannot be improved. Observability is not a Phase 5 activity that gets added after the agent is live. The hooks for monitoring must be designed in Phase 1 and implemented in Phase 2, or the data will not be there when Phase 5 begins.

**What observability includes:**

- **Session Tracing.** Turn-by-turn logs captured in Data 360 that record every topic classification, LLM step, action execution, and variable state change. This is the primary tool for diagnosing agent behavior in production.
- **Distributed request tracing.** In multi-agent systems, end-to-end visibility across agent handoffs requires distributed tracing. Each hop in the delegation chain must be traceable back to the originating user request.
- **Multi-agent coordination monitoring.** Capture success and failure rates of agent-to-agent interactions, detect circular invocation patterns, and track per-agent task completion rates.
- **Cost tracking.** Track token usage and associated costs per agent and per LLM call. Unmonitored token costs in a live multi-agent deployment can become significant very quickly.
- **Cognitive tracing and session replay.** The ability to visually replay an agent's reasoning step-by-step is the agentic equivalent of a debugger. It turns post-incident analysis from an exercise in speculation into a structured investigation.

**The closed learning loop.** Observability data feeds back into the agent design. Interaction logs labeled by human reviewers or LLM-based evaluation produce a curated dataset that can be used to refine prompts, adjust knowledge retrieval, retrain intent classifiers, and inform the next iteration of the Agent Spec. The outer loop only functions if the observability infrastructure was designed to capture the data the inner loop needs to act on.

> **Scenario.** A financial services firm deploys an agent to handle client portfolio inquiries. After two weeks in production, the monitoring team notices that the agent's escalation rate on questions about tax implications is 60%, well above the 15% baseline for other topics. Session traces reveal that the RAG retriever is returning generic tax documentation rather than the firm's specific advisory guidelines. The Architect updates the data ingestion configuration to index the firm's proprietary guidance separately and applies a metadata filter to prioritize it for tax-related queries. After redeployment, the escalation rate for that topic drops to 18%. This improvement was only possible because the observability infrastructure captured the signal.

---

## Conclusion

The Agentforce Architect does the work that makes everything else possible. A well-scoped agent built on a clear Agent Spec, with the hybrid reasoning boundary correctly placed, governed by the right guardrails, and monitored through a disciplined outer loop, will outperform a hastily built agent regardless of how sophisticated the underlying model is.

The principles in this guide are not prescriptive rules for every situation. They are a framework for asking the right questions, in the right order, before the development team writes the first line of code. The value of that framework is not that it prevents all mistakes. It is that it makes mistakes visible, traceable, and correctable before they reach users.

Build deliberately. Classify before you build. Gate what must be gated. Observe everything. And treat the moment of deployment as the beginning of the work, not the end of it.
