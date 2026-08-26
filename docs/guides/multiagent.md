# Multi-Agent Architecture in Agentforce

*Updated August 20, 2026*
*This guide was generated using AI with grounding in official Salesforce documentation. Review for accuracy before using.*

---

## Table of Contents

1. [Why Multi-Agent Architecture?](#1-why-multi-agent-architecture)
2. [Agent Decomposition: What Should Each Agent Actually Do?](#2-agent-decomposition-what-should-each-agent-actually-do)
   - 2.1 [Rule of Thumb](#21-rule-of-thumb)
   - 2.2 [Five Questions to Ask Before Splitting](#22-five-questions-to-ask-before-splitting)
   - 2.3 [Three Decomposition Strategies](#23-three-decomposition-strategies)
3. [The Three Deployment Streams](#3-the-three-deployment-streams)
   - 3.1 [SOMA: Single-Org Multi-Agent](#31-soma-single-org-multi-agent)
   - 3.2 [MOMA: Multi-Org Multi-Agent](#32-moma-multi-org-multi-agent)
   - 3.3 [3P: Third-Party Agent Interoperability](#33-3p-third-party-agent-interoperability)
4. [Choosing the Right Stream](#4-choosing-the-right-stream)
5. [The Supervisor Pattern](#5-the-supervisor-pattern)
6. [Building a Superagent Network](#6-building-a-superagent-network)
   - 6.1 [The `connected_subagent` Block](#61-the-connected_subagent-block)
   - 6.2 [Variable Mapping and State Sync](#62-variable-mapping-and-state-sync)
   - 6.3 [Deterministic Routing with Agent Script](#63-deterministic-routing-with-agent-script)
   - 6.4 [Action Least Privilege](#64-action-least-privilege)
7. [Orchestration Patterns](#7-orchestration-patterns)
   - 7.1 [Supervised Mode (GA)](#71-supervised-mode-ga)
   - 7.2 [Handoff Mode (Post-GA)](#72-handoff-mode-post-ga)
   - 7.3 [Parallel Execution (In Development)](#73-parallel-execution-in-development)
   - 7.4 [Event-Driven Background Agents (In Development)](#74-event-driven-background-agents-in-development)
   - 7.5 [Plan and Present (Not Currently Supported)](#75-plan-and-present-not-currently-supported)
8. [Common Pitfalls and Anti-Patterns](#8-common-pitfalls-and-anti-patterns)
9. [Platform Limits and Structural Constraints](#9-platform-limits-and-structural-constraints)
   - 9.1 [Two Different Scopes, Two Different Numbers](#91-two-different-scopes-two-different-numbers)
   - 9.2 [Constraints Reference Table](#92-constraints-reference-table)
   - 9.3 [Supported Agent Type Combinations](#93-supported-agent-type-combinations)
   - 9.4 [Goal-Based Agents: Beyond Turn-Based Orchestration (Pilot)](#94-goal-based-agents-beyond-turn-based-orchestration-pilot)
10. [Identity, Security, and Authentication](#10-identity-security-and-authentication)
11. [Performance and Latency](#11-performance-and-latency)
12. [Observability and Testing](#12-observability-and-testing)
    - 12.1 [Unified Trace and Session Logging](#121-unified-trace-and-session-logging)
    - 12.2 [Testing Center for Multi-Agent Workflows](#122-testing-center-for-multi-agent-workflows)
13. [Admin Experience Reference](#13-admin-experience-reference)
    - 13.1 [Agentforce Builder Views](#131-agentforce-builder-views)
    - 13.2 [Connecting Agents](#132-connecting-agents)
    - 13.3 [Validation and Network Health](#133-validation-and-network-health)
    - 13.4 [Composability and Updates](#134-composability-and-updates)
    - 13.5 [Admin Controls Summary](#135-admin-controls-summary)
14. [End-User Experience](#14-end-user-experience)
15. [Cross-Platform A2A: Third-Party and MCP Patterns](#15-cross-platform-a2a-third-party-and-mcp-patterns)
16. [Industry Use Cases](#16-industry-use-cases)
17. [Pre-Deployment Checklist](#17-pre-deployment-checklist)
18. [Getting Started: Your First Multi-Agent Connection](#18-getting-started-your-first-multi-agent-connection)
19. [Change Log](#19-change-log)

---

## 1. Why Multi-Agent Architecture?

Single agents hit walls. When one agent tries to handle every task in a complex enterprise workflow, it makes poor decisions, loses context across long conversations, and cannot scale beyond narrow pilots. Three problems drive customers to multi-agent architecture:

**Single agents get overwhelmed.** Context overload degrades reasoning quality. Adding more tools to a single agent makes it worse, not better — each new tool is another surface for misrouting and context burnout.

**Real work requires specialists.** A financial portfolio review needs a risk analyst, a market data reader, a compliance checker, and a client communicator. These are distinct skill sets with different data sources, permissions, and regulatory requirements. One generalist agent cannot perform all four well.

**There is no infrastructure for coordination.** Even teams that build multiple agents have no standard way to make them work together, share context, or hand off tasks reliably. Orchestration logic gets rebuilt from scratch on every project.

Multi-agent architecture solves all three. The Supervisor pattern gives each domain a specialist, keeps context appropriately scoped per agent, and provides a single front door for the end user — one brand voice, one conversation thread, one consolidated response, regardless of how many agents worked behind the scenes.

> As you move beyond one agent, the builder's focus should shift from how to maximize agent performance to how to effectively coordinate multiple reasoning units, each operating with partial context, while preserving accountability and predictable behavior in the process. Multi-agent systems are decision systems, not just helpers — and decision systems demand explicit structure, clear roles, strict data-passing contracts, and orchestration models that keep humans in ultimate control of outcomes.

---

## 2. Agent Decomposition: What Should Each Agent Actually Do?

> **NEW SECTION — sourced from the Agentforce Interoperability Playbook.**

Before choosing a deployment stream or orchestration pattern, answer a simpler question first: what should each agent actually do? This is decomposition, and it is the most consequential design decision in a multi-agent system.

Get it right and routing is clean, agents are easy to reason about, and failures are isolated. Get it wrong and you will spend time debugging misroutes caused by overlapping descriptions and fighting context loss between agents that were not designed to hand off cleanly.

### 2.1 Rule of Thumb

> **If you cannot describe a Connected Subagent in one sentence without using "and," split it further.**

The description is the routing signal. The Atlas Reasoning Engine reads agent descriptions to decide which subagent to call. If a description covers two things, the Reasoning Engine will sometimes pick the wrong one. A conditional or compound description is doing work that the decomposition should be doing — it is a signal that the split needs to be redone, not that the description needs to be longer.

### 2.2 Five Questions to Ask Before Splitting

| Question | What to look for |
|---|---|
| **Where does the task naturally break?** | Ask the person closest to the work to walk you through it step by step. Wherever they naturally pause and say "then it goes to..." — that is a boundary. |
| **Which Actions naturally group together?** | The most reliable signal. If Agent A and Agent B never share an Action, they belong to separate agents. |
| **What different context is needed?** | Look at the data each agent needs to do its job. Completely different data requirements signal the need for separate agents. |
| **What can run simultaneously?** | If the tasks are independent, use Parallel Execution. If the tasks are sequential, use Handoff Mode. |
| **Where do you want to isolate failures?** | Ask what should happen when one agent breaks. If the answer is "everything else should keep working fine," that is your boundary. One agent should not take down another. |

### 2.3 Three Decomposition Strategies

There are three proven strategies for decomposing agents. Deciding which one fits depends on the nature of the work you are breaking apart.

**By Domain Expertise.** The most common approach in practice. Split agents based on knowledge domains that mirror how your organization actually works. If your company has a field service team, a sales team, and a support team, your agents should reflect that. Each Connected Subagent has instructions and actions scoped to one domain.

- *Example:* An industrial services firm separated their agent into four Connected Subagents for field service, support, sales, and external — one per team that already owned a separate build.
- *Example:* A government agency split by department: Education, Health, and Social Services — three departments with completely separate data and actions.

**By Workflow Stage.** Use this when the work has a fixed sequence: Step B genuinely cannot start until Step A is done. The sequence should not be left to the Reasoning Engine. Each stage owns its step; handoff between them should be deterministic.

- *Example:* A contractor placement firm across 60 countries built three sequential agents: a Matching Agent finds candidates, a Notification Agent delivers results, and a Scheduling Agent books the interview. A contractor must never be scheduled before being matched.

**By Capability.** Structure agents around what they do rather than what they know. One retrieves. One analyzes. One acts. This is the most reusable model because the same capability can plug into different workflows.

- *Example:* A financial services customer used this model for portfolio analysis: four parallel Connected Subagents, each responsible for a different type of analysis (performance grading, risk assessment, market insights, tax-loss harvesting), none depending on the others.

---

## 3. The Three Deployment Streams

Multi-agent orchestration in Agentforce operates across three streams, each suited to a different organizational scope.

| Stream | Scope | Mechanism | GA Status |
|---|---|---|---|
| **SOMA** | Intra-org, multi-domain | `connected_subagent` block, graph-based reasoner | **GA — staged rollout complete (see §3.1)** |
| **MOMA** | Cross-org (Salesforce) | DC1 trust boundaries, MBus metadata sync, org-to-org agent sharing | GA (MuleSoft/DC1-dependent) |
| **3P Outbound (A2A)** | Salesforce to external agent platforms | A2A protocol via Named Credentials | Pilot |
| **3P Inbound (A2A)** | External platform into Salesforce | A2A protocol, ECA-scoped auth | Pilot |
| **Cross-platform A2A** | Agentforce to Google Vertex, Azure Agent Mesh, etc. | A2A protocol, cross-vendor | **Beta** |
| **MCP Client** | Salesforce to external tools | Model Context Protocol | Beta |
| **Agentforce as MCP Server** | External platforms invoking Salesforce | Salesforce-hosted MCP Server | Beta |

All patterns can coexist in the same enterprise architecture. An orchestrator can delegate to SOMA connected subagents for internal specialization, route to MOMA agents for cross-org Salesforce capabilities, and invoke or be invoked by external platforms via A2A or MCP.

### 3.1 SOMA: Single-Org Multi-Agent

SOMA enables a Superagent to coordinate multiple specialized agents within a **single Salesforce org**. The orchestrator receives all user requests, selects the appropriate connected subagent based on descriptions and routing rules, delegates the task, and synthesizes the result.

**GA rollout status (as of August 20, 2026):** SOMA within-org multi-agent orchestration entered general availability in August 2026 via a staged, pod-by-pod rollout. The rollout schedule is:

| Phase | Status |
|---|---|
| Pilot orgs | Complete |
| Sandbox canary | Complete (8/17) |
| GUS + optional sandboxes | Complete (8/18) |
| Production canary | Complete (8/19) |
| Sandbox production canary | Complete (8/20) |
| Datacenter canary | Starts 8/21 |
| All remaining orgs | Starts 8/24 |
| **Full rollout completion** | **~August 25-26, 2026** |

> **If you do not yet see SOMA enabled in your org:** Check your pod's rollout status. Full org-wide availability is expected by approximately August 25-26, 2026. This is expected behavior during staged rollout, not a configuration problem.

**When to use SOMA.** Specialized agents already exist or should be built within the same org. The workflow involves multiple distinct domains (Billing, Returns, HR, Compliance) that benefit from separate permissions, owners, and topic scopes.

**When NOT to use SOMA** (consider a single agent instead). The workflow is straightforward and all data is shared across the same domain. As a rule of thumb: when a single agent's subagent/topic count is well below 10, multi-agent architecture adds overhead without meaningful benefit. SOMA makes the most sense when distinct domains, distinct data permissions, or distinct team ownership make a single monolithic agent impractical to build and maintain.

> **Note on the "approaches 10" heuristic:** This refers to the complexity threshold for a *single agent's* topic and subagent count — the design signal that suggests it is time to consider distributing across agents. This is a different number from the SOMA connected-subagent limit described in Section 9. See §9.1 for a clear explanation of both.

### 3.2 MOMA: Multi-Org Multi-Agent

MOMA connects agents across separate Salesforce orgs within a shared trust boundary. Trust is established through DC1 (data center) relationships stored in GDoT (Global Directory of Tenants). Each org can belong to only one agent trust boundary at a time. Agent sharing follows least-privilege principles: admins must explicitly mark agents as shareable in Agentforce Builder. Shared agents are organized into Agent Groups that control visibility.

**When to use MOMA.** Your enterprise has multiple Salesforce orgs — due to business division separation, acquisitions, or data residency requirements — and needs agents from different orgs to collaborate on shared workflows. Example: a retail banking agent in one org delegating to a compliance agent in another org, both within the same DC1 trust boundary.

**Authentication in MOMA.** The system uses Multi-Org JWTs for cross-org auth. The primary identity resolver maps users across orgs by email. If email mapping fails, the system defaults to Guest User authorization. Step-up authentication (unauthenticated-to-authenticated mid-conversation) is not supported in the current release.

### 3.3 3P: Third-Party Agent Interoperability

3P orchestration enables Agentforce agents to communicate with external, vendor-built agents using the A2A (Agent-to-Agent) protocol. Two flows are supported:

**Outbound (AF to 3P).** An Agentforce agent acts as the Superagent and delegates tasks to a registered third-party agent. Registration requires OAuth credentials and an A2A Server URL, stored via Named Credentials. 3P agent calls time out after **120 seconds**; the system displays a retry prompt if no response is received within that window. This timeout applies specifically to outbound 3P agent calls — it is not an orchestrator-wide constraint.

**Inbound (3P to AF).** A third-party platform invokes an Agentforce agent. Authentication is handled via External Client Apps (ECA) scoped with the `a2a_api` custom scope. The 3P system is responsible for routing logic; Agentforce is the execution layer.

Both flows support one level of delegation only (A to B; not A to B to C). Human escalation is not supported in either direction for the current Pilot. Governance, allowlists, and monitoring UI are out of scope for Pilot.

> **Cross-platform A2A (Agentforce to Google Vertex, Azure Agent Mesh, etc.) remains in Beta as of Summer '26.** Do not present cross-platform A2A as GA. Only within-org SOMA and DC1-scoped MOMA have reached general availability.

---

## 4. Choosing the Right Stream

| Decision point | Recommended stream |
|---|---|
| All agents in the same org, different domains | SOMA |
| Agents owned by different Salesforce orgs in the same enterprise | MOMA |
| Third-party SaaS vendor provides a production-ready agent | 3P Outbound |
| External portal or bot needs to invoke Agentforce execution | 3P Inbound |
| Need to access external APIs or SaaS tools as tools (not agents) | MCP Client (Beta) |
| External LLM host needs to invoke Agentforce capabilities as tools | Agentforce as MCP Server (Beta) |

When in doubt, start with SOMA. It has the lowest integration overhead, the tightest governance model, and the most mature tooling as of August 2026.

---

## 5. The Supervisor Pattern

All three streams — SOMA, MOMA, and 3P — use the **Supervisor pattern** as their orchestration model. It is the only pattern supported in the current GA release.

```
         User
          |
          v
  +-------------------+
  |    Superagent     |  <-- Single customer-facing entry point
  |   (Orchestrator)  |       Reasons, routes, synthesizes
  +---+----------+--+-+
      |          |  |
      v          v  v
  +------+  +------+  +------+
  |  A   |  |  B   |  |  C   |  <-- Specialized agents (Billing, HR, Compliance...)
  +------+  +------+  +------+
```

**How it works:**
1. The Superagent receives all user requests.
2. The Atlas Reasoning Engine reads each connected subagent's description and decides which specialist should handle the request.
3. The selected specialist executes the task and returns results to the Superagent.
4. The Superagent synthesizes the response and delivers it to the user.

**Why the Supervisor pattern and not the alternatives:**
- **Tool Calling** (treating other agents as tools) leads to context burnout — every tool's state lives in the same reasoning loop.
- **Handoffs** (agents passing control directly to each other) reduce central oversight and make governance harder in regulated or high-stakes environments.
- **Supervisor** keeps context scoped per agent, gives the orchestrator full visibility, and enforces a single governance point. It is the only pattern that supports enterprise-grade auditing of all agent decisions from one place.

**Key capabilities of the Supervisor:**
- Orchestrate multiple specialized agents, each with their own topics, actions, and permissions
- Synthesize outputs from multiple specialists into one coherent user response
- Forward specialist messages unchanged to avoid unnecessary token usage
- Apply pre- and post-processing hooks (summarize inputs, validate outputs, enforce safety checks)
- Return structured, schema-driven outputs for downstream automation
- Configure how much conversation history each specialist receives (`full_history` vs. `last_message`)

---

## 6. Building a Superagent Network

### 6.1 The `connected_subagent` Block

The `connected_subagent` block declares a connection to another Agentforce agent in the same org (SOMA). It is defined at the top level of the orchestrator's Agent Script, alongside standard subagent blocks.

```agentscript
connected_subagent Billing_Agent:
    label: "Billing_Agent"
    target: "agent://X00Dfi200000dpFZ_Billing_Agent"
    loading_text: |
        Reviewing your billing details...
    description: "Use this agent for any request about invoices, payment history, charges, refunds, or subscription billing. Do not use for shipping or returns."
    inputs:
        EndUserLanguage: string = @variables.EndUserLanguage
        CustomerTier: string = @variables.CustomerTier
```

> **Target scheme update (262.8):** The `target` field now uses the `agent://` URI scheme. The previous `agentforce://` scheme is deprecated. Update any existing scripts that reference `agentforce://` targets — deprecated URI forms will not be supported indefinitely.

**Description quality matters more than anything else.** The Atlas Reasoning Engine routes entirely based on the description field. Overlapping descriptions across connected subagents cause misrouting. Make descriptions specific, non-overlapping, and include explicit guidance on when *not* to use the agent. If two descriptions require conditional logic to disambiguate, the decomposition is wrong — go back to Section 2.

> **Agent Card descriptions (3P Inbound).** For agents exposed via 3P Inbound, the A2A Agent Card is auto-generated by an LLM from your subagent and action descriptions, and published at the `.well-known/agent-card.json` endpoint. The quality and specificity of those descriptions directly controls what external platforms see when discovering your agent. Hone descriptions with the same care you would apply for internal routing — they serve double duty as your agent's public-facing capability advertisement.

**The `loading_text` field** sets the progress message shown to users while the subagent is working. Customize this per subagent to communicate what is happening without exposing internal routing logic.

**BYON and custom nodes as the start node (262.8).** A custom or BYON (Bring Your Own Node) node can now serve as the initial — and only — `start_agent` node. This is relevant for teams building non-standard orchestrator entry points (for example, a custom routing node that enforces business rules before any topic classification runs). The standard start node model remains the default; this capability exists for architectures that need to own the very first step of the reasoning graph.

**Instruction surfaces on connected subagents.** Connected subagents support a specific set of instruction blocks. Understanding which surface to use, and where, prevents misrouted logic and compilation errors.

| Surface | Where it fires | Allowed in connected subagents |
|---|---|---|
| `before_reasoning` | Before the LLM reasoning loop | Yes |
| `reasoning.instructions` | Inside the reasoning loop | Yes |
| `after_reasoning` | After the reasoning loop | Yes |
| `reasoning.actions` (tools) | LLM-callable tools within reasoning | Yes |
| `after_response` | After the connected agent returns to the orchestrator | Yes — connected subagents only |

**`after_response` on connected subagents (262.10).** The `after_response` block is a fifth instruction surface that fires on the orchestrator side *after* a connected agent has returned its result. It accepts `run`, `set`, `if`, and `transition` statements. Prompt templates are not allowed here — there is no active reasoning loop at that point, so there is no LLM to render them.

This surface is the correct place to handle post-delegation logic: updating orchestrator variables based on what the subagent returned, conditionally routing to another agent, or marking a workflow step as complete. Without `after_response`, that logic has to live inside the orchestrator's next reasoning turn, which means it is LLM-dependent rather than deterministic.

```agentscript
connected_subagent Billing_Agent:
    ...
    after_response:
        if @variables.billing_resolved == true:
            -> transition to Close_Session
        -> set @variables.last_delegated_agent = "Billing_Agent"
```

#### Security: Unbound Required Action Inputs (262.10)

Starting in 262.10, if an action input is marked `is_required` and has no default value and no `with` clause binding it, the compiler **automatically marks it `slot_filled_by: LLM`** instead of leaving it unfilled. This is a meaningful change to previous behavior, where that gap was silent and would surface only at runtime.

The security concern is not subtle. An unbound required input that the LLM fills from user-provided text is exactly the surface through which a user can inject unexpected values into action calls — overriding filters, escalating access, or triggering unintended flows. This was already an anti-pattern before 262.10; the difference now is that the platform resolves the gap for you rather than failing loudly, so architects may not notice it has happened.

**What to do.** Audit all connected subagent action definitions for required inputs that lack an explicit `with` binding. For each one, make an explicit choice:
- Bind it deterministically using `with: @variables.SomeVariable` if the value should come from verified context.
- Add `slot_filled_by: LLM` explicitly if LLM slot-fill is intentional and the input is low-risk.
- Add input validation logic in `before_reasoning` if the value is sensitive.

Do not rely on silent LLM slot-fill for inputs that gate access to data, execute writes, or trigger external integrations.

### 6.2 Variable Mapping and State Sync

Variables are the mechanism for passing context from the orchestrator to connected subagents. Two variable types exist:

| Variable type | Mutability | Sync direction | Use for |
|---|---|---|---|
| Context (linked) variables | Read-only | Populated at session start; not synced bidirectionally | CRM data, session metadata, stable grounding |
| Custom variables | Mutable | One-way: orchestrator to subagent (bidirectional sync is a post-GA fast-follow) | Conversation state, user choices, verified flags |

> **Type note (262.10):** The `id` primitive type is deprecated in favor of `string`. Update any variable declarations using `id` — `string` is the correct type for Salesforce record IDs and all other identifier values going forward.

**Current behavior (GA).** Variable mapping is one-way: the orchestrator pushes values down to the subagent at session start. If a subagent learns something important during its turn — the user is now verified, or has selected a product — that information does not automatically flow back to the orchestrator. Design workflows with this in mind: architect your orchestrator to re-collect needed state rather than assuming subagent updates propagate back.

**Post-GA fast-follow.** Bidirectional state sync (`<>` mapping in Agent Script) is planned as a fast-follow after GA. When available, the orchestrator will receive the full updated variable state after every subagent turn, including all variables the subagent was permitted to write back. This release will also include the last 20 messages of conversation history as the default context window (up from 10).

**Context history.** The last 10 messages of conversation history are passed to connected subagents at the time of delegation. This was confirmed as the constraint during the Pilot phase. Verify your pod's release notes for any changes to this limit post-GA rollout completion.

> **Expressions in variable mapping are not yet supported.** You cannot use computed values (e.g., `@variables.matchDate + "UTC"`) in a `with` clause or connected subagent input binding. Pre-compute any transformations in a Flow before agent invocation.

**Mapping validation.** If a mapped variable is renamed or deleted in either the orchestrator or the subagent, the system blocks the save and surfaces a validation error. This is intentional: a silent mapping break is nearly impossible to debug at runtime.

**System variables for channel-aware routing (262.12).** Two new system variables are populated at the start of every inbound turn and are available to all subagents, including connected ones:

- `@system_variables.current_modality` — the current channel modality (e.g., `"voice"`, `"text"`). Use this to adjust routing or response style based on whether the user is on a voice channel or a text channel.
- `@system_variables.current_connection` — the active connection context for the session.

These are read-only system variables. They are particularly useful in multi-agent networks where different connected subagents may need to behave differently depending on whether the user is on a voice call versus a chat session. Reference them in `available when` clauses or in `before_reasoning` blocks to gate behavior by modality.

**Voice interrupt system variables (262.14).** For agents deployed on voice channels, two additional system variables support interrupt-aware workflows:

- `@system_variables.last_reply.interrupted` — boolean; `true` if the user interrupted the agent's last response.
- `@system_variables.last_reply.interrupted_heard_text` — the text the user spoke during the interruption.

These variables are voice-channel-specific and will be empty on text channels. Use them in `after_response` blocks or `before_reasoning` to handle mid-response interruptions gracefully rather than treating them as new standalone utterances.

### 6.3 Deterministic Routing with Agent Script

For critical business logic, use conditional expressions in Agent Script to define hard routing rules. These execute before the reasoning engine runs, so they are faster, more predictable, and easier to audit.

```agentscript
# Route verified users directly to Order Management
# before any LLM reasoning occurs
if @variables.identity_verified == true:
    -> transition to Order_Management_Agent

# Route VIP customers to the premium support specialist
if @variables.customer_tier == "Platinum":
    -> transition to Premium_Support_Agent
```

**Deterministic transition mechanisms.** Agent Script supports four deterministic routing and termination mechanisms. Each has a distinct purpose:

| Mechanism | Syntax | Behavior | Use for |
|---|---|---|---|
| Transition to local subagent | `-> transition to SubagentName` | One-way; control returns to start_agent after the target subagent completes | Routing to standard internal subagents |
| Transition to connected subagent | `-> transition to @connected_subagent.AgentName` | One-way; fully supported as of 262.10 | Routing deterministically to a connected (multi-agent) subagent |
| `@utils.transition to` | `-> @utils.transition to SubagentName` | One-way via utility; supports conditional logic | Routing from within reasoning actions |
| `escalate` | `-> escalate` | Deterministic; single-fire; hands off to a fixed escalation target | Escalating to a human agent or fixed fallback |

**Connected subagents as valid transition targets (262.10).** Prior to 262.10, `transition to @connected_subagent.X` emitted a compile-time warning. That warning is fully resolved. Deterministic routing to connected subagents now compiles cleanly through the normal supervision path. This closes the gap where connected subagents were reachable only via LLM-driven routing — architects can now hard-code routes to connected subagents for mandatory prerequisite gates and tier-based routing patterns.

**The `escalate` statement (262.14).** The `escalate` statement is a top-level deterministic mechanism usable directly inside `reasoning.instructions`. It hands off to a fixed escalation target and fires exactly once. It cannot be re-triggered in the same turn. Use `escalate` wherever a human handoff must happen exactly once and unconditionally.

```agentscript
if @variables.escalation_requested == true:
    -> escalate
```

**`else if` conditionals in `->` mode (262.12).** Full `else if` chains are now supported in Agent Script's deterministic (`->`) mode.

```agentscript
if @variables.customer_tier == "Platinum":
    -> transition to Premium_Support_Agent
else if @variables.customer_tier == "Gold":
    -> transition to Standard_Support_Agent
else:
    -> transition to General_Inquiry_Agent
```

> **Canvas UI note:** `else if` chains are currently supported in Script view only. The Canvas UI does not yet render them. Build and maintain `else if` routing logic in Script view.

Deterministic transitions do not consume an LLM call. Use them for mandatory prerequisite gates, predictable high-volume routing, and required workflow steps that must not be bypassed. Reserve LLM-driven routing for cases where the correct subagent depends on nuanced user intent that cannot be pre-coded.

**`available when` routing guards (262.10).** The compiler now emits a lint warning when an `available when` clause resolves to a non-boolean literal. Boolean-returning conditions are required.

### 6.4 Action Least Privilege

> **NEW SUBSECTION — sourced from the Agentforce Interoperability Playbook.**

Only give a Connected Subagent the Actions it actually needs. Each additional Action increases cognitive load and security surface. For every Action you consider adding, ask: can this agent do its job without this Action? If yes, do not add it.

If two agents share an Action, treat that as a design signal. It is either intentional — the capability genuinely applies in both domains — or it is a sign of overlapping scope between the two agents. Shared Actions that reveal overlapping scope should be resolved at the decomposition level, not patched with routing instructions.

---

## 7. Orchestration Patterns

**LLM-driven vs. deterministic routing** applies to every pattern below. The Reasoning Engine selects subagents based on their descriptions when routing is flexible. Agent Script takes that decision away entirely when routing must be guaranteed. Most production architectures use both; see §6.3 for implementation guidance.

### 7.1 Supervised Mode (GA)

The orchestrator receives every user request. It reads each connected subagent's description, selects the right specialist, delegates the task, buffers the specialist's output, and synthesizes a final response before it reaches the user.

**When to use.** Multiple domains, one entry point. The most common starting point for multi-agent architectures and the default pattern in Agentforce Builder.

**Common pitfalls.** Connected Subagent descriptions are the routing signal — overlapping descriptions cause misrouting. Latency compounds with each hop (see §11 for P95 figures).

**Latency note.** In supervised mode, every user turn involves at minimum: an orchestrator routing call (LLM hop 1), an agent-to-agent API call, a subagent topic selection (LLM hop 2), and response synthesis back up the chain (LLM hop 3). At P95, this adds 12-20 seconds of orchestration overhead on top of the subagent's own execution time. Design SLAs accordingly.

**Runtime configuration (262.12).** A `config.runtime` block is now available at the top level of an agent's script:

```agentscript
config:
    ...
    runtime:
        streaming: true
        thought_chunks: true
        citation: false
        groundedness: true
        reset_to_initial_node: false
```

| Flag | Effect |
|---|---|
| `streaming` | Enables or disables token streaming for this agent. |
| `thought_chunks` | Controls whether intermediate reasoning chunks are emitted to the reasoning panel. |
| `citation` | Enables or disables source citation in responses. |
| `groundedness` | Explicitly enables or disables groundedness validation. |
| `reset_to_initial_node` | When `true`, resets conversation state to the initial node after the session ends. |

> **Compile error on empty `runtime` block:** An empty `runtime:` block is now a hard compile error. If you declare the block, you must set at least one flag. Either populate it or omit it entirely.

**Industry examples for Supervised Mode:**
- *Higher Education:* A Student Assistant Superagent routes to a Parking subagent, a Thesis-Writing subagent, and a Course Selection subagent.
- *Enterprise HR:* A single Employee Superagent routes across HR, Accounting, IT, and Procurement subagents to provide one point of contact for all employee requests.

### 7.2 Handoff Mode (Post-GA)

> **Status: Not yet available. Target: post-GA fast-follow.**

In the intended design of Handoff Mode, the orchestrator routes once, then steps back for that session. The specialist would own the conversation directly with the user and stream its response without an orchestrator synthesis step, skipping the synthesis LLM hop and reducing P95 overhead from ~12-20s to ~5-6s.

> **IMPORTANT — Known Platform Limitation and Source Conflict.** The Interoperability Playbook's "What Agent Script Does Not Yet Support" table states explicitly: **"Connected Subagents cannot own all subsequent turns. Agent Router resets after each response. Workaround: session variable to track state."** This directly contradicts the aspirational Handoff Mode pattern description elsewhere in the same Playbook, which describes a subagent fully owning a session. The practical implication is that **true sticky handoff — where a connected subagent owns all subsequent turns in a session — is not currently supported.** After each response, control returns to the orchestrator's Agent Router. If your workflow requires a specialist to manage a multi-turn conversation continuously, you must track state manually using a session variable and re-route deterministically at the start of each turn. **Confirm the current status of sticky handoff with your Salesforce platform team before designing production workflows that depend on this behavior.**

**What works today (GA).** The orchestrator routes to a connected subagent, the subagent handles that turn and responds, and control returns to the orchestrator's Agent Router for the next turn. This is not true handoff in the session-ownership sense, but it is the current supported model.

**Workaround for multi-turn specialist workflows.** Use a session variable (e.g., `@variables.active_specialist`) to track which specialist is handling a workflow. At the start of each turn, read that variable in the orchestrator's `start_agent` block and deterministically re-route to the same specialist using an `if` transition before the Reasoning Engine runs:

```agentscript
start_agent:
    # Re-route to the active specialist deterministically,
    # bypassing LLM routing on continuation turns
    if @variables.active_specialist == "Billing":
        -> transition to @connected_subagent.Billing_Agent
    if @variables.active_specialist == "Returns":
        -> transition to @connected_subagent.Returns_Agent
```

**Trust model (post-GA design intent).** When true sticky handoff ships, only same-org, same-platform agents will be able to receive handoffs. Third-party and cross-vendor agents will always be mediated by the orchestrator. The `allow_direct_handoff: false` flag opts a subagent out.

**Decompose by.** Conversation ownership — which agent can be trusted to handle the full scope of a given user session from handoff to resolution.

### 7.3 Parallel Execution (In Development)

> **Status: Not currently available. In development.**

In Supervised Mode, the orchestrator calls Connected Subagents one at a time. Parallel Execution removes the waiting by fanning out to all Connected Subagents at once. Each runs its own reasoning loop independently. The Superagent then collects all results and synthesizes them into a single response. Total wait time equals the slowest single agent, not the sum of all four.

**When to use.** You have multiple jobs that do not depend on each other's output and you do not want to pay the latency cost of running them in sequence.

**Common pitfall.** The orchestrator waits for *all* agents before synthesizing. A single timing-out subagent blocks the whole response. You need explicit handling for partial results built into the synthesis logic before deploying this pattern in production.

### 7.4 Event-Driven Background Agents (In Development)

> **Status: Not currently available. In development.**
> **NEW SECTION — sourced from the Agentforce Interoperability Playbook.**

Every pattern described above assumes a user is on the other end waiting for a response. Event-Driven is different in a fundamental way: there is no user on the other end of the agent. These are background agents, task agents, operational agents. They run, do their job, and either produce an output or take an action in a system. Nobody typed anything to start them.

**What starts them is a trigger — a change in state.** An order volume drops below a threshold. A contractor's assignment is three days from ending. An SLA is about to be breached. Something in your data shifts, a Salesforce Flow detects it, and an agent fires.

**Layered architecture.** This pattern can be layered on top of the patterns listed above. The trigger mechanism is event-driven, but after the initial trigger, you can deploy a Supervised, Handoff, or Parallel Execution pattern underneath. You are adding a new entry point, not replacing the architecture underneath.

```agentscript
# Fire RetentionSpecialist when churn signal is detected.
on message:
    if @variables.churn_risk > 0.7:
        transition to @subagent.RetentionSpecialist
    if @connection.messaging:
        transition to @subagent.ChatIntake
    if @connection.email:
        transition to @subagent.EmailIntake

# Escalate to human after 3 failed turns — must never be an LLM decision.
on message:
    if @variables.failed_turns >= 3:
        transition to @subagent.HumanEscalation
```

**When to use.** Something should happen when data changes, not when a user sends a message.

**Common pitfall.** Requires reliable trigger infrastructure. A missed trigger means a missed proactive action.

**Industry example.** A food delivery service monitors restaurant partners for churn signals. When a partner's order volume drops 20%, a Salesforce Flow detects the signal and invokes a Partner Success Agent. The Reasoning Engine produces personalized outreach. The partner receives proactive contact before they ever reach out to support.

### 7.5 Plan and Present (Not Currently Supported)

> **Status: Not currently available. Not currently supported.**

The orchestrator builds a step-by-step plan and shows it to the user before doing anything. Execution begins only after the user approves. This is the right pattern for irreversible or regulated actions — portfolio restructuring, contract execution, anything where humans must remain in authority over the outcome.

**When to use.** Irreversible, regulated, or high-stakes actions where human sign-off is non-negotiable.

**Common pitfall.** Plan drift during execution. Validate that agents stay within the approved scope at each step boundary.

---

## 8. Common Pitfalls and Anti-Patterns

> **NEW SECTION — sourced from the Agentforce Interoperability Playbook.**

### 1. Overlapping Subagents

Some capabilities are genuinely horizontal — they apply across every interaction. Do not train every individual Connected Subagent on these. Centralize the following at the Superagent level:
- **Global compliance and guardrails.** Terms of service responses, GDPR opt-out handling, safety filtering.
- **User verification and context priming.** Verify identity once at the Superagent level and propagate it.
- **Disambiguation.** "Are you looking for billing help or a technical request?" is the Superagent's job.
- **Human handoff.** The transition to a live agent should be consistent across your entire organization.
- **End-of-session CSAT.** One closing survey, not one per subagent the customer touched.

**Fix:** Centralize these horizontal components in the Superagent.

### 2. Mesh Orchestration

Every Connected Subagent in the network can call every other. No clear Superagent. Any agent can initiate delegation in any direction. The result is undefined context ownership, endless possible reasoning loops, and impossible debugging.

**Fix:** Create one Superagent as the single entry point. Connected Subagents are dedicated to executing responses, not routing.

### 3. Too Many Delegation Layers

A Superagent delegates to a Connected Subagent, which attempts to delegate to another. The agent planner executes only one level of Connected Subagents. Deeper nesting is not recommended due to latency and is silently ignored by the platform.

**Fix:** Deploy a maximum of one level of delegation in production. If a Connected Subagent needs subcapabilities, encode them as Actions within that agent — not as further delegation.

### 4. Two Superagents in the Same Network

Two Connected Subagents are each configured as Superagents with their own Connected Subagents. A user can reach either as an entry point. The Reasoning Engine in each route is different. Behavior becomes inconsistent and context ownership is split.

**Fix:** Create one Superagent as the sole entry point. Every other agent in the network is a specialist — it responds, it does not orchestrate.

### 5. Standing Up an Agent Just to Retrieve Data

A full Connected Subagent — with subagents, actions, a system user, and OAuth auth — built just to retrieve data from an external system. The Reasoning Engine overhead, user auth complexity, and Agent Card maintenance are unnecessary for a system that just returns data when asked.

**Fix:** If the external system returns data on request and does not need to reason autonomously, use MCP Client as a service-auth Action instead (see §15).

### 6. Description Doing the Work That Decomposition Should Do

Long, conditional descriptions trying to get the Reasoning Engine to route correctly, rather than fixing the underlying split. The description becomes load-bearing logic that is fragile and breaks with novel inputs.

**Fix:** If a description needs conditional logic to route correctly, the decomposition is wrong. Clean domain boundaries produce simple, stable descriptions. Return to Section 2 and re-examine the split.

### 7. Overlapping Scope (MECE Violation)

Two Connected Subagents with similar descriptions. The Reasoning Engine will route inconsistently in the case of overlapping descriptions.

**Fix:** Merge similar Connected Subagents when possible, or separate agents using a Mutually Exclusive, Collectively Exhaustive (MECE) model — every user request maps cleanly to exactly one specialist.

### 8. Hallucinated Action Outputs

A Connected Subagent reports that an Action succeeded when it did not, or returns data that was never retrieved.

**Fix:** Configure Connected Subagent instructions to check Action return values explicitly before reporting success. For high-stakes workflows, use a Validator agent — a separate Connected Subagent whose only job is to verify the output before the Superagent synthesizes it.

---

## 9. Platform Limits and Structural Constraints

### 9.1 Two Different Scopes, Two Different Numbers

There are two different limit concepts that apply to subagent counts in a SOMA architecture. They are frequently confused but describe completely different things.

**Design heuristic (single-agent complexity threshold).** When a *single agent's* topic and subagent count approaches 10, that is a signal the agent is becoming too complex for one agent to handle well. This is a design guidance heuristic — the point at which distributing work across multiple agents in a SOMA network starts to make architectural sense. It is not a platform-enforced limit.

**SOMA network width (connected subagents in an orchestrated network).** The platform warns (but does not block) when an orchestrator's connected-subagent count exceeds 7-8 agents. This is a SOMA-specific, separately bounded constraint on the *width* of the orchestrated network — distinct from how many topics or internal subagents any single agent within that network has.

These two numbers operate at different levels of the architecture. A SOMA network can contain multiple agents each with up to 10 internal topics, connected via up to 7-8 connected-subagent links, and the two limits govern completely separate dimensions of the system.

### 9.2 Constraints Reference Table

| Dimension | Limit | Notes |
|---|---|---|
| Delegation depth | 1 level only (A to B) | Connected subagents cannot themselves delegate further. Not a soft warning — this is enforced. |
| SOMA network width | 7-8 connected subagents (Salesforce recommendation) | Post-GA: not a hard cap; the builder warns but does not block. PM guidance confirms up to 20 is technically supported; 8 is cited as a well-performing configuration. **Note:** During Beta, the Interoperability Playbook documented this as a hard cap of 7 ("Current limit during Beta. The final number will expand pending performance testing"). The shift from hard cap to warn-not-block occurred at GA. If you are referencing pre-GA documentation, this discrepancy is a timeline difference, not a contradiction. |
| Topics per agent | Up to 10 (Salesforce recommendation) | Not a hard cap. Part of official Agents Limits documentation. |
| Actions per subagent | Up to 10 (Salesforce recommendation) | Not a hard cap. Part of official Agents Limits documentation. |
| Sticky handoff (connected subagent conversation ownership) | **Not supported** | Connected Subagents cannot own all subsequent turns. Agent Router resets after each response. Workaround: session variable to track active specialist and re-route deterministically. Confirm with platform team before designing workflows that depend on session-level handoff. |
| Session duration | 24-48 hours | Hard limit. |
| Platform reasoning-engine timeout | **30 seconds** | Platform-wide limit inherited by all reasoning engine requests, including connected subagent calls. Not a SOMA-specific constraint. Confirmed in official Agents Limits documentation. Long multi-step journeys (e.g., 11+ step workflows) are better suited to post-GA Handoff Mode than connected subagent chains for exactly this reason. |
| 3P agent call timeout | **120 seconds** | Scoped specifically to outbound calls to third-party (3P) agents via A2A. If a 3P agent does not respond within 120 seconds, the system prompts the user to retry. This is **not** an orchestrator-wide timeout. |
| Variable mapping direction | One-way: orchestrator to subagent | Bidirectional is a post-GA fast-follow. |
| Variable mapping expressions | Not supported | Pre-compute transformations in a Flow before invocation. |
| Context history on delegation | Last 10 messages | Confirmed in Pilot PRD. Verify against your org's release notes post-GA rollout completion; this value may be updated. |
| `config.runtime` empty block | Hard compile error | An empty `runtime:` block fails compilation. Set at least one flag or omit the block. |

> **Note on subagent counts:** The previously published "5 internal subagents per connected subagent (hard limit)" figure in v3.0 has been removed. That figure could not be sourced from any Salesforce primary documentation and is directly contradicted by official PM guidance. The verified limits are: up to 10 topics per agent and up to 10 actions per subagent (both soft recommendations), with no documented hard cap on internal subagent or topic count per connected subagent.

### 9.3 Supported Agent Type Combinations

| Orchestrator type | Connected subagent type | Supported? |
|---|---|---|
| ASA (Agentforce Service Agent) | ASA | Yes |
| AEA (Agentforce Employee Agent) | AEA | Yes |
| AEA | ASA | Yes |
| ASA | AEA | No |
| Any | File-based (SDR, Analytics) | Post-GA |

### 9.4 Goal-Based Agents: Beyond Turn-Based Orchestration (Pilot)

> **Pilot status:** Everything in this section describes pilot functionality introduced in 262.14. Syntax and block structure are subject to change before GA. Do not use this section's content to represent production-ready capabilities.

Goal-Based Agents introduce a fundamentally different execution model from the Supervisor pattern. Instead of responding to inbound user turns, a Goal-Based Agent is triggered by a scheduled event or an external condition and executes an autonomous, multi-step workflow without a human in the loop for each step. Mixing Goal-Based Agent blocks into a standard agent script is now a hard compile error (262.14 enforces this).

**Enabling Goal-Based Agents.** The `config.agent_type` field must be set to `"GoalBasedAgent"`.

**New blocks introduced by Goal-Based Agents:**

| Block | Purpose |
|---|---|
| `workflows` | Defines the named multi-step workflows the agent can execute |
| `trigger` | Specifies scheduling rules (cron syntax) that initiate workflow execution without a user turn |
| `orchestrator` | Configures how the agent coordinates across workflow steps |
| `# @dialect: agentforce-plugin` | File-level declaration marking a file as an agent plugin |

**What to do now.** Goal-Based Agents are pilot-gated and syntax is subject to change. Register interest with your Salesforce account team. Do not build production dependencies on the `workflows`, `trigger`, or `orchestrator` blocks until GA guidance is published.

---

## 10. Identity, Security, and Authentication

**Identity propagation.** User identity and permissions propagate automatically through the entire agent chain. No agent in the network can access data beyond the permissions of the original calling user. This is enforced by the trust model, not by individual agent configuration.

**Primary identity resolution (MOMA).** The system resolves user identity across orgs using email address as the default resolver. If email mapping fails, the system defaults to Guest User authorization. Step-up authentication is not supported in the current release.

**Authentication mechanisms by agent type:**
- Authenticated AEA-to-AEA: Supported
- Unauthenticated ASA-to-ASA: Supported
- Authenticated ASA-to-ASA: Not supported in current release
- AEA-to-ASA: Supported
- ASA-to-AEA: Not supported

**3P authentication.** Outbound 3P calls use OAuth credentials stored in Named Credentials. Inbound 3P calls authenticate via ECA (External Client Apps) with the `a2a_api` custom scope. AEA access from 3P platforms requires the Web-Server Flow; ASA access uses the Client Credentials Flow.

**Trust boundary rules (MOMA).** An org can belong to only one agent trust boundary at a time. Trust boundaries are stored in GDoT. Agent sharing is opt-in: admins explicitly mark agents as shareable. Shared agents are grouped into Agent Groups that control per-org visibility.

**Who can connect agents.** Org Admin only. Connecting agents in a SOMA or MOMA network is an elevated operation restricted to administrators.

**`strip_salesforce_instructions` (262.14).** This flag removes the Salesforce system prompt from an agent's context. It can be applied top-level (removing it for the entire agent) or per-subagent. Stripping it removes the behavioral floor that the Salesforce baseline provides — any safety constraints, refusal behaviors, or persona defaults that baseline was covering silently must now be restated explicitly. If you use this flag, perform a full audit of all system instruction surfaces across the network.

**Escalation path governance.** The `delegate_escalation` field on connected subagents (boolean, default `true`) controls whether escalation follows the connected subagent's own outbound flow or the orchestrator's. Set `delegate_escalation: false` on connected subagents where you want all escalation to flow through the orchestrator's centralized path.

---

## 11. Performance and Latency

Multi-agent architectures carry higher latency than single-agent solutions by design.

**P95 latency breakdown for a SOMA network (supervised mode):**

| Layer | P95 Overhead |
|---|---|
| Orchestrator routing (LLM hop 1) | ~3-5 seconds |
| Agent-to-agent API call | ~2-4 seconds |
| Subagent topic selection (LLM hop 2) | ~3-5 seconds |
| Topic-to-action handoff | ~1-2 seconds |
| Response synthesis (LLM hop 3) | ~2-3 seconds |
| **Total P95 SOMA overhead** | **~12-20 seconds** |

**With post-GA Handoff Mode (2-LLM-hop path):** ~5-6 seconds of orchestration overhead — once sticky handoff is available.

**Target end-to-end turn time:** Less than 15 seconds total (reasoning plus delegation). Streaming reduces *perceived* latency significantly.

**The 30-second reasoning engine boundary.** Any connected subagent whose internal reasoning approaches this boundary will fail. If a subagent needs to run a complex, multi-step workflow that may take close to 30 seconds to reason through, route it to post-GA Handoff Mode rather than a connected subagent chain.

---

## 12. Observability and Testing

### 12.1 Unified Trace and Session Logging

Every multi-agent session generates independent trace logs for both the Superagent and all connected subagents, stored in STDM (Salesforce Trace Data Model). The architecture supports bidirectional lookup:

- **Forward:** Primary Agent trace step to Sub-Agent session ID (via Attributes field)
- **Backward:** Sub-Agent session to Primary Agent session (via PreviousSessionId)

**Analytics metrics available for multi-agent workflows:**
- Sub-agent invocation count (rolling time period)
- End-to-end task resolution success rate
- Error rate across the full agent chain (broken down by orchestration, handoff, authentication, and timeout errors)
- Per-hop latency (orchestration time, agent invocation time, and execution time at each delegation point)
- Handoff failure alerts
- Sub-agent downtime alerts

### 12.2 Testing Center for Multi-Agent Workflows

The Agentforce Testing Center (GA: July 18, 2026) provides dedicated evaluations for multi-agent orchestration:

**Sub-Agent Assertion.** Checks whether the orchestrator invoked the correct connected subagent for a given utterance.

**Task Completion Success.** Verifies end-to-end task completion across the entire multi-agent workflow, not just within a single agent.

**Multi-Hop Latency Breakdown.** Attributes time across the delegation chain, identifying which hop is the bottleneck.

**Semantic Conflict Detection (post-GA).** An LLM-as-judge evaluation that scans conversation logs for contradictory assertions across agents or signs of looping behavior.

**Limits.** 500 test cases per job. Recommended batch size: 20-30 cases. Testing Center is enabled automatically for all Agentforce customers in Sandbox orgs at no additional cost.

---

## 13. Admin Experience Reference

### 13.1 Agentforce Builder Views

Agentforce Builder provides three interchangeable views, all of which compile to the same underlying Agent Script:

| View | Best for |
|---|---|
| Conversational | Describe the network in natural language. The system generates connections automatically. |
| Canvas | Point-and-click configuration via the Resource tab. Select Connected Agents, then Add. |
| Script | Direct Agent Script editing. Supports conditionals, variable mappings, `else if` chains, and explicit `connected_subagent` blocks. |

> **Note:** `else if` chains in deterministic (`->`) mode are only visible and editable in Script view. Canvas does not yet render them.

### 13.2 Connecting Agents

**Prerequisites.** Sub-agents must be activated individually before being added to a network. Draft agents can be added in preview mode for testing but will not be accessible to end users until activated.

**Agent types that can be connected.** Any active agent available in the org's AiAgent BPO can be added as a connected subagent. A Superagent (that already has connected subagents) can itself be added as a connected subagent to another Superagent — but only one level deep. Circular connections (A to B to A) are detected and blocked.

### 13.3 Validation and Network Health

Before publishing, run **Check Network Health** to validate the agent network.

| Validation check | Behavior |
|---|---|
| Depth limit (more than 1 level deep) | Warn, not block |
| Width limit (more than 7-8 agents wide) | Warn, not block |
| Loop detection (A routes to B which routes back to A) | Block — not permitted |
| Skill overlap | LLM-based warning with suggestions; does not hard-block |
| Language compatibility | Error if no overlapping supported languages between Superagent and subagent |
| `available when` non-boolean condition | Lint warning |
| Empty `config.runtime` block | Hard compile error |

### 13.4 Composability and Updates

Sub-agents can be added or removed from an active Superagent without deactivating it. Changes take effect without interrupting ongoing conversations. Sub-agent teams can deploy new versions independently without coordinating with the Superagent owner.

### 13.5 Admin Controls Summary

| Setting | Location | Configurable by | Default |
|---|---|---|---|
| Streaming on/off | `config.runtime.streaming` in agent script | Admin | On |
| Groundedness on/off | `config.runtime.groundedness` in agent script | Admin | Platform default (set explicitly to ensure it) |
| Handoff on/off (post-GA) | Per subagent, script (`allow_direct_handoff`) | Admin | On for trusted agents |
| Variable mapping direction | Script | Admin | Explicit — no default |
| Global instructions (brand tone, policies) | Orchestrator script | Admin | Off; subagent opts in |
| Progress message text | Superagent builder | Admin | "Getting answers..." |
| Who can connect agents | Platform | Org Admin only | — |
| Escalation path | `delegate_escalation` on connected subagent | Admin | `true` (connected subagent's own flow) |
| Salesforce system prompt | `strip_salesforce_instructions` | Admin | Off (baseline present) |

---

## 14. End-User Experience

From the user's perspective, multi-agent orchestration is invisible. They see one conversation, one brand voice, one response — regardless of how many agents worked behind the scenes.

**Progress indication.** Users see a configurable "Getting answers..." message with animated progress markers while the Superagent coordinates sub-agents. Sub-agent outputs appear in a collapsible reasoning panel on rich UI channels.

**Channel support for reasoning panel:**

| UI element | Channels |
|---|---|
| Reasoning panel (thinking stream) | LEX, Slack, Enhanced Chat |
| Streaming final answer | All channels |
| Progress indicator | All channels |

On WhatsApp, SMS, and Mobile, the reasoning panel is hidden. The user sees only the final answer, streamed.

**Failure handling.** Every failure message is clean, user-facing, and actionable. Internal errors, sub-agent names, and tool failures are never surfaced to the user. Default failure handling for GA: retry the same agent twice; if that fails, return to the Superagent with an error for it to communicate to the user.

---

## 15. Cross-Platform A2A: Third-Party and MCP Patterns

> **Important:** Everything in this section describes **Beta** functionality as of August 2026. Do not use this section's content to represent GA capabilities.

**3P Outbound (Salesforce to external vendor agents).** Once a 3P agent is registered via the AF Registry page with OAuth credentials and A2A Server URL, it can be connected to a primary AF agent. 3P agent calls must return a single synchronous TaskResult. Streaming and partial responses are not supported in Pilot. The 120-second timeout applies to each 3P call.

**3P Inbound (external vendor to Salesforce agents).** A2A cards are auto-generated from each AF agent's existing metadata (name, description, topics, actions) by an LLM and published at a `.well-known/agent-card.json` endpoint. The quality of your subagent and action descriptions directly determines what external platforms see when discovering your agent — hone them with the same care you apply for internal routing. Admins maintain an allowlist specifying which agents are accessible to external vendors. Authentication uses ECA with the `a2a_api` custom scope.

**MCP Client.** Agentforce can invoke external tools — databases, SaaS APIs, search engines — via the Model Context Protocol. This is the appropriate pattern when the external system is a *tool* rather than an *agent* (it does not reason; it executes and returns data). See Anti-Pattern #5 in Section 8: if you are considering building a full Connected Subagent just to retrieve data, use MCP Client instead.

**Agentforce as MCP Server.** External hosts (such as third-party AI assistants or enterprise LLM platforms) can invoke Agentforce capabilities as tools via a Salesforce-hosted MCP Server.

---

## 16. Industry Use Cases

### SOMA Use Cases

**Financial Services — Parallel Portfolio Analysis.**
A SOMA network with four specialist agents (market data, risk scoring, regulatory compliance, client communication) operating under a single orchestrator replaced a workflow that previously required analysts to context-switch across multiple systems. Parallel execution (in development) is planned to run all four analyses simultaneously.

**Professional Services — Internal Employee Agent Ecosystem.**
A SOMA Superagent coordinates two specialist agents (a Delivery Agent and a Relationship Agent), eliminating context-switching across CRM workflows while maintaining strict data boundary separation between the two domains.

**Industrial Services — Domain-Based Split.**
A field services company separated their agent into four Connected Subagents: field service, support, sales, and external — one per team that already owned a separate build.

### MOMA Use Cases

**Technology / Professional Services — Cross-Org Knowledge Delivery.**
A Delivery Agent in the primary delivery org delegates knowledge queries to a centralized Knowledge Agent in a separate services org, both within the same DC1 trust boundary. Single login, no step-up authentication, no context switching.

**Financial Services — Multi-System Loan Processing.**
A query such as "Why is this application delayed?" triggers an orchestrator that delegates simultaneously to three specialist agents — credit eligibility, legal verification, and property valuation — then returns a unified explanation with recommended next steps.

### 3P Use Cases

**Technology / Document Management — RFP Response Automation (3P Outbound).**
A 3P Outbound pattern connects a document intelligence agent (hosted externally) with an Agentforce agent (handling sales workflow execution) at runtime. Each platform contributes its native capability; neither needs to replicate the other's functionality.

**Technology — Inbound Delegation from External AI Platform (3P Inbound).**
When a user query requires Salesforce-side action, an external enterprise AI platform delegates inbound to an Agentforce Service Agent via the A2A protocol. Agentforce handles Salesforce execution; the external platform handles everything else.

---

## 17. Pre-Deployment Checklist

### Decomposition Review

- [ ] Each Connected Subagent can be described in one sentence without using "and"
- [ ] Agent descriptions do not overlap — each request maps to exactly one specialist
- [ ] Horizontal concerns (compliance, identity verification, CSAT, human handoff) are centralized in the Superagent, not duplicated across subagents
- [ ] Each Connected Subagent has only the Actions it actually needs (Action Least Privilege)
- [ ] No Connected Subagent was created solely to retrieve data from an external system — use MCP Client instead

### Org Readiness

- [ ] Confirm SOMA is enabled in your org — check your pod's rollout status if not yet visible (full rollout expected by ~August 25-26, 2026)
- [ ] Einstein and Agentforce features are enabled in org settings
- [ ] Org Admin permissions are confirmed for the user connecting agents
- [ ] All sub-agents are individually activated before being added to the network

### Architecture Review

- [ ] Each connected subagent has a distinct, non-overlapping description
- [ ] Delegation depth is 1 level only (no A to B to C chains)
- [ ] Network width is at or below 8 connected subagents; if wider, document the rationale and run extended performance testing
- [ ] Any workflow that requires a specialist to own multiple consecutive turns uses the session variable workaround (sticky handoff is not currently supported — see §9.2)
- [ ] Complex multi-step subagent workflows that may approach 30 seconds of reasoning time are identified — plan to route these to post-GA Handoff Mode or restructure as single-agent flows
- [ ] Circular routing (A to B back to A) has been checked and is absent
- [ ] The supported agent-type combination is confirmed (AEA-to-AEA, ASA-to-ASA, or AEA-to-ASA only; ASA-to-AEA is not supported)
- [ ] All `connected_subagent` target fields use the `agent://` URI scheme (not the deprecated `agentforce://`)
- [ ] `config.runtime` block, if present, sets at least one flag (empty block is a compile error)
- [ ] If `strip_salesforce_instructions` is enabled on any agent or subagent, a full audit of all system instruction surfaces in the network has been completed

### Variable and Context Design

- [ ] Variable mapping is one-directional (orchestrator to subagent); no workflow logic assumes subagent writes propagate back automatically
- [ ] No computed expressions used in variable mapping — pre-compute in a Flow if transformations are needed
- [ ] Context history dependency is within the 10-message window per delegation call
- [ ] All mapped variables exist in both the orchestrator and the target subagent; validation errors are resolved before publishing
- [ ] All variable declarations use `string` rather than the deprecated `id` type
- [ ] All required action inputs either have an explicit `with` binding, a declared default, or an intentional `slot_filled_by: LLM` annotation

### Routing and Escalation

- [ ] All `available when` conditions are confirmed to return boolean values
- [ ] `delegate_escalation` is set intentionally on all connected subagents
- [ ] Any use of the deterministic `escalate` statement is reviewed to confirm it fires exactly once per turn

### Performance and SLA Planning

- [ ] SLAs account for 12-20 seconds of P95 orchestration overhead (supervised mode) on top of subagent execution time
- [ ] Streaming is confirmed on for all agents in the network (`config.runtime.streaming: true`)
- [ ] Progress messaging text is customized for your use case
- [ ] Failure messages are reviewed: clean, user-facing, and actionable; no internal errors or sub-agent names exposed

### Testing

- [ ] Agent network validated with Check Network Health in builder
- [ ] Conversation preview tested in Agentforce Builder for at least the core happy-path scenarios
- [ ] Routing logic tested: does the orchestrator select the correct subagent for each intended query type?
- [ ] Edge cases tested: ambiguous queries, out-of-scope queries, and failure paths
- [ ] Testing Center sub-agent assertion evals configured and passing for critical workflows
- [ ] Latency measured under realistic load; results within acceptable SLA range

### For 3P / Cross-Platform (Beta only)

- [ ] Named Credentials confirmed and connection status is active for all registered 3P agents
- [ ] Allowlist is configured with only the intended AF agents exposed to external vendors
- [ ] ECA is configured with `a2a_api` scope for inbound flows
- [ ] 120-second timeout and retry UX confirmed with stakeholders
- [ ] Agent Card descriptions reviewed — they are auto-generated by LLM from subagent and action descriptions and serve as the public capability advertisement for external discovery

---

## 18. Getting Started: Your First Multi-Agent Connection

> **NEW SECTION — sourced from the Agentforce Interoperability Playbook.**

You now have the working vocabulary for multi-agent orchestration: how to decompose an agent, choose an orchestration pattern, avoid common pitfalls, and apply deterministic routing with Agent Script. The right way to apply it is not to design a complete multi-agent system from scratch.

**The way in is a single workflow.**

Pick one process already running as a single agent and map its steps end to end. Look for two signals:

1. **Where would a Connected Subagent give one team clearer ownership?** If one domain's instructions are growing unwieldy, that team is fighting a boundary that should be an agent split.
2. **Where would an MCP call reach a system the agent is currently working around?** If the agent is approximating or hallucinating data from an external system, an MCP Client action replaces the workaround with a real connection.

Build that one connection. Ship it. Let what you learn shape the next one.

---

## 19. Change Log

| Version | Date | Changes |
|---|---|---|
| v5.1 | August 26, 2026 | **Three targeted corrections from source review:** (1) Reverted §7.2 Handoff Mode from "(GA)" back to "(Post-GA)" — GA promotion was an authoring error in v5.0. Added explicit sticky handoff limitation sourced directly from Playbook "What Agent Script Does Not Yet Support" table ("Connected Subagents cannot own all subsequent turns. Agent Router resets after each response."), added session variable workaround, flagged internal Playbook conflict between pattern narrative and limitation table, and added platform team confirmation guidance. Updated checklist item and performance section references accordingly. (2) Added Beta-vs-GA timeline footnote to SOMA network width row in §9.2 constraints table, clarifying that the Interoperability Playbook documented a hard cap of 7 during Beta ("current limit during Beta, final number will expand pending performance testing") — the post-GA shift to warn-not-block with PM guidance of up to 20 technically supported is a timeline progression, not a contradiction. (3) Added Agent Card auto-generation note to §6.1 near description-quality guidance: for 3P Inbound agents, A2A cards are LLM-generated from subagent and action descriptions; description quality controls external discoverability. Added matching checklist item in §17 3P section. |
| v5.0 | August 26, 2026 | Added Section 2 (Agent Decomposition) from Interoperability Playbook. Added §6.4 Action Least Privilege. Added §7.4 Event-Driven Background Agents. Added Section 8 (Common Pitfalls and Anti-Patterns). Added Section 18 (Getting Started). Expanded §7.2 Handoff Mode. Updated ToC, section numbering, and Pre-Deployment Checklist. Cross-referenced anti-patterns throughout. |
| v4.x | August 20, 2026 | Previous version — SOMA GA rollout documentation, 262.10-262.14 platform updates, Testing Center multi-agent evals, Goal-Based Agents pilot. |
