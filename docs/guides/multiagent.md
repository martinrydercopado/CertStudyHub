# Multi-Agent Architecture in Agentforce

---

## Table of Contents

1. [Why Multi-Agent Architecture?](#1-why-multi-agent-architecture)
2. [The Three Deployment Streams](#2-the-three-deployment-streams)
   - 2.1 [SOMA: Single-Org Multi-Agent](#21-soma-single-org-multi-agent)
   - 2.2 [MOMA: Multi-Org Multi-Agent](#22-moma-multi-org-multi-agent)
   - 2.3 [3P: Third-Party Agent Interoperability](#23-3p-third-party-agent-interoperability)
3. [Choosing the Right Stream](#3-choosing-the-right-stream)
4. [The Supervisor Pattern](#4-the-supervisor-pattern)
5. [Building a Superagent Network](#5-building-a-superagent-network)
   - 5.1 [The `connected_subagent` Block](#51-the-connected_subagent-block)
   - 5.2 [Variable Mapping and State Sync](#52-variable-mapping-and-state-sync)
   - 5.3 [Deterministic Routing with Agent Script](#53-deterministic-routing-with-agent-script)
6. [Orchestration Patterns](#6-orchestration-patterns)
   - 6.1 [Supervised Mode (GA)](#61-supervised-mode-ga)
   - 6.2 [Handoff Mode (Post-GA)](#62-handoff-mode-post-ga)
   - 6.3 [Parallel Execution (Post-GA)](#63-parallel-execution-post-ga)
   - 6.4 [Plan and Present (Post-GA)](#64-plan-and-present-post-ga)
7. [Platform Limits and Structural Constraints](#7-platform-limits-and-structural-constraints)
   - 7.1 [Two Different Scopes, Two Different Numbers](#71-two-different-scopes-two-different-numbers)
   - 7.2 [Constraints Reference Table](#72-constraints-reference-table)
   - 7.3 [Supported Agent Type Combinations](#73-supported-agent-type-combinations)
   - 7.4 [Goal-Based Agents: Beyond Turn-Based Orchestration (Pilot)](#74-goal-based-agents-beyond-turn-based-orchestration-pilot)
8. [Identity, Security, and Authentication](#8-identity-security-and-authentication)
9. [Performance and Latency](#9-performance-and-latency)
10. [Observability and Testing](#10-observability-and-testing)
    - 10.1 [Unified Trace and Session Logging](#101-unified-trace-and-session-logging)
    - 10.2 [Testing Center for Multi-Agent Workflows](#102-testing-center-for-multi-agent-workflows)
11. [Admin Experience Reference](#11-admin-experience-reference)
    - 11.1 [Agentforce Builder Views](#111-agentforce-builder-views)
    - 11.2 [Connecting Agents](#112-connecting-agents)
    - 11.3 [Validation and Network Health](#113-validation-and-network-health)
    - 11.4 [Composability and Updates](#114-composability-and-updates)
    - 11.5 [Admin Controls Summary](#115-admin-controls-summary)
12. [End-User Experience](#12-end-user-experience)
13. [Cross-Platform A2A: Third-Party and MCP Patterns](#13-cross-platform-a2a-third-party-and-mcp-patterns)
14. [Industry Use Cases](#14-industry-use-cases)
15. [Pre-Deployment Checklist](#15-pre-deployment-checklist)
16. [Change Log](#change-log)

---

## 1. Why Multi-Agent Architecture?

Single agents hit walls. When one agent tries to handle every task in a complex enterprise workflow, it makes poor decisions, loses context across long conversations, and cannot scale beyond narrow pilots. Three problems drive customers to multi-agent architecture:

**Single agents get overwhelmed.** Context overload degrades reasoning quality. Adding more tools to a single agent makes it worse, not better — each new tool is another surface for misrouting and context burnout.

**Real work requires specialists.** A financial portfolio review needs a risk analyst, a market data reader, a compliance checker, and a client communicator. These are distinct skill sets with different data sources, permissions, and regulatory requirements. One generalist agent cannot perform all four well.

**There is no infrastructure for coordination.** Even teams that build multiple agents have no standard way to make them work together, share context, or hand off tasks reliably. Orchestration logic gets rebuilt from scratch on every project.

Multi-agent architecture solves all three. The Supervisor pattern gives each domain a specialist, keeps context appropriately scoped per agent, and provides a single front door for the end user — one brand voice, one conversation thread, one consolidated response, regardless of how many agents worked behind the scenes.

---

## 2. The Three Deployment Streams

Multi-agent orchestration in Agentforce operates across three streams, each suited to a different organizational scope.

| Stream | Scope | Mechanism | GA Status |
|---|---|---|---|
| **SOMA** | Intra-org, multi-domain | `connected_subagent` block, graph-based reasoner | **GA — staged rollout complete (see §2.1)** |
| **MOMA** | Cross-org (Salesforce) | DC1 trust boundaries, MBus metadata sync, org-to-org agent sharing | GA (MuleSoft/DC1-dependent) |
| **3P Outbound (A2A)** | Salesforce to external agent platforms | A2A protocol via Named Credentials | Pilot |
| **3P Inbound (A2A)** | External platform into Salesforce | A2A protocol, ECA-scoped auth | Pilot |
| **Cross-platform A2A** | Agentforce to Google Vertex, Azure Agent Mesh, etc. | A2A protocol, cross-vendor | **Beta** |
| **MCP Client** | Salesforce to external tools | Model Context Protocol | Beta |
| **Agentforce as MCP Server** | External platforms invoking Salesforce | Salesforce-hosted MCP Server | Beta |

All patterns can coexist in the same enterprise architecture. An orchestrator can delegate to SOMA connected subagents for internal specialization, route to MOMA agents for cross-org Salesforce capabilities, and invoke or be invoked by external platforms via A2A or MCP.

### 2.1 SOMA: Single-Org Multi-Agent

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
| **Full rollout completion** | **~August 25–26, 2026** |

> **If you do not yet see SOMA enabled in your org:** Check your pod's rollout status. Full org-wide availability is expected by approximately August 25–26, 2026. This is expected behavior during staged rollout, not a configuration problem.

**When to use SOMA.** Specialized agents already exist or should be built within the same org. The workflow involves multiple distinct domains (Billing, Returns, HR, Compliance) that benefit from separate permissions, owners, and topic scopes.

**When NOT to use SOMA** (consider a single agent instead). The workflow is straightforward and all data is shared across the same domain. As a rule of thumb: when a single agent's subagent/topic count is well below 10, multi-agent architecture adds overhead without meaningful benefit. SOMA makes the most sense when distinct domains, distinct data permissions, or distinct team ownership make a single monolithic agent impractical to build and maintain.

> **Note on the "approaches 10" heuristic:** This refers to the complexity threshold for a *single agent's* topic and subagent count — the design signal that suggests it is time to consider distributing across agents. This is a different number from the SOMA connected-subagent limit described in Section 7. See §7.1 for a clear explanation of both.

### 2.2 MOMA: Multi-Org Multi-Agent

MOMA connects agents across separate Salesforce orgs within a shared trust boundary. Trust is established through DC1 (data center) relationships stored in GDoT (Global Directory of Tenants). Each org can belong to only one agent trust boundary at a time. Agent sharing follows least-privilege principles: admins must explicitly mark agents as shareable in Agentforce Builder. Shared agents are organized into Agent Groups that control visibility.

**When to use MOMA.** Your enterprise has multiple Salesforce orgs — due to business division separation, acquisitions, or data residency requirements — and needs agents from different orgs to collaborate on shared workflows. Example: a retail banking agent in one org delegating to a compliance agent in another org, both within the same DC1 trust boundary.

**Authentication in MOMA.** The system uses Multi-Org JWTs for cross-org auth. The primary identity resolver maps users across orgs by email. If email mapping fails, the system defaults to Guest User authorization. Step-up authentication (unauthenticated-to-authenticated mid-conversation) is not supported in the current release.

### 2.3 3P: Third-Party Agent Interoperability

3P orchestration enables Agentforce agents to communicate with external, vendor-built agents using the A2A (Agent-to-Agent) protocol. Two flows are supported:

**Outbound (AF to 3P).** An Agentforce agent acts as the Superagent and delegates tasks to a registered third-party agent. Registration requires OAuth credentials and an A2A Server URL, stored via Named Credentials. 3P agent calls time out after **120 seconds**; the system displays a retry prompt if no response is received within that window. This timeout applies specifically to outbound 3P agent calls — it is not an orchestrator-wide constraint.

**Inbound (3P to AF).** A third-party platform invokes an Agentforce agent. Authentication is handled via External Client Apps (ECA) scoped with the `a2a_api` custom scope. The 3P system is responsible for routing logic; Agentforce is the execution layer.

Both flows support one level of delegation only (A to B; not A to B to C). Human escalation is not supported in either direction for the current Pilot. Governance, allowlists, and monitoring UI are out of scope for Pilot.

> **Cross-platform A2A (Agentforce to Google Vertex, Azure Agent Mesh, etc.) remains in Beta as of Summer '26.** Do not present cross-platform A2A as GA. Only within-org SOMA and DC1-scoped MOMA have reached general availability.

---

## 3. Choosing the Right Stream

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

## 4. The Supervisor Pattern

All three streams — SOMA, MOMA, and 3P — use the **Supervisor pattern** as their orchestration model. It is the only pattern supported in the current GA release.

```
         User
          |
          v
  ┌───────────────┐
  │  Superagent   │  <-- Single customer-facing entry point
  │ (Orchestrator)│       Reasons, routes, synthesizes
  └──┬──────┬──┬──┘
     |      |  |
     v      v  v
  ┌────┐ ┌────┐ ┌────┐
  │ A  │ │ B  │ │ C  │  <-- Specialized agents (Billing, HR, Compliance...)
  └────┘ └────┘ └────┘
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

## 5. Building a Superagent Network

### 5.1 The `connected_subagent` Block

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

**Description quality matters more than anything else.** The Atlas Reasoning Engine routes entirely based on the description field. Overlapping descriptions across connected subagents cause misrouting. Make descriptions specific, non-overlapping, and include explicit guidance on when *not* to use the agent.

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

### 5.2 Variable Mapping and State Sync

Variables are the mechanism for passing context from the orchestrator to connected subagents. Two variable types exist:

| Variable type | Mutability | Sync direction | Use for |
|---|---|---|---|
| Context (linked) variables | Read-only | Populated at session start; not synced bidirectionally | CRM data, session metadata, stable grounding |
| Custom variables | Mutable | One-way: orchestrator to subagent (bidirectional sync is a post-GA fast-follow) | Conversation state, user choices, verified flags |

> **Type note (262.10):** The `id` primitive type is deprecated in favor of `string`. Update any variable declarations using `id` — `string` is the correct type for Salesforce record IDs and all other identifier values going forward.

**Current behavior (GA).** Variable mapping is one-way: the orchestrator pushes values down to the subagent at session start. If a subagent learns something important during its turn — the user is now verified, or has selected a product — that information does not automatically flow back to the orchestrator. Design workflows with this in mind: architect your orchestrator to re-collect needed state rather than assuming subagent updates propagate back.

**Post-GA fast-follow.** Bidirectional state sync (`<>` mapping in Agent Script) is planned as a fast-follow after GA. When available, the orchestrator will receive the full updated variable state after every subagent turn, including all variables the subagent was permitted to write back. This release will also include the last 20 messages of conversation history as the default context window (up from 10).

**Context history.** The last 10 messages of conversation history are passed to connected subagents at the time of delegation. This was confirmed as the constraint during the Pilot phase. Verify your pod's release notes for any changes to this limit post-GA rollout completion.

**Mapping validation.** If a mapped variable is renamed or deleted in either the orchestrator or the subagent, the system blocks the save and surfaces a validation error. This is intentional: a silent mapping break is nearly impossible to debug at runtime.

**System variables for channel-aware routing (262.12).** Two new system variables are populated at the start of every inbound turn and are available to all subagents, including connected ones:

- `@system_variables.current_modality` — the current channel modality (e.g., `"voice"`, `"text"`). Use this to adjust routing or response style based on whether the user is on a voice channel or a text channel.
- `@system_variables.current_connection` — the active connection context for the session.

These are read-only system variables. They are particularly useful in multi-agent networks where different connected subagents may need to behave differently depending on whether the user is on a voice call versus a chat session. Reference them in `available when` clauses or in `before_reasoning` blocks to gate behavior by modality.

**Voice interrupt system variables (262.14).** For agents deployed on voice channels, two additional system variables support interrupt-aware workflows:

- `@system_variables.last_reply.interrupted` — boolean; `true` if the user interrupted the agent's last response.
- `@system_variables.last_reply.interrupted_heard_text` — the text the user spoke during the interruption.

These variables are voice-channel-specific and will be empty on text channels. Use them in `after_response` blocks or `before_reasoning` to handle mid-response interruptions gracefully rather than treating them as new standalone utterances.

### 5.3 Deterministic Routing with Agent Script

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

**Connected subagents as valid transition targets (262.10).** Prior to 262.10, `transition to @connected_subagent.X` emitted a compile-time warning. That warning is fully resolved. Deterministic routing to connected subagents now compiles cleanly through the normal supervision path. This closes the gap where connected subagents were reachable only via LLM-driven routing — architects can now hard-code routes to connected subagents for the same mandatory prerequisite gates and tier-based routing patterns described above.

**The `escalate` statement (262.14).** The `escalate` statement is a top-level deterministic mechanism usable directly inside `reasoning.instructions`. It hands off to a fixed escalation target and fires exactly once. It cannot be re-triggered in the same turn. This single-fire guarantee is the key design property: accidental re-fires — for example, from a `before_reasoning` loop that runs multiple times — are precisely the bug class that makes escalation in complex workflows hard to reason about. Use `escalate` wherever a human handoff must happen exactly once and unconditionally.

```agentscript
if @variables.escalation_requested == true:
    -> escalate
```

**`else if` conditionals in `->` mode (262.12).** Full `else if` chains are now supported in Agent Script's deterministic (`->`) mode. Use them to write branching routing logic without nesting multiple independent `if` blocks.

```agentscript
if @variables.customer_tier == "Platinum":
    -> transition to Premium_Support_Agent
else if @variables.customer_tier == "Gold":
    -> transition to Standard_Support_Agent
else:
    -> transition to General_Inquiry_Agent
```

> **Canvas UI note:** `else if` chains are currently supported in Script view only. The Canvas UI does not yet render them. Build and maintain `else if` routing logic in Script view.

Deterministic transitions do not consume an LLM call. Use them for:
- Mandatory prerequisite gates (identity verification before order access)
- Predictable high-volume routing (customer tier-based routing)
- Required workflow steps that must not be bypassed

Reserve LLM-driven routing (the reasoning engine's default behavior) for cases where the correct subagent depends on nuanced user intent that cannot be pre-coded.

**`available when` routing guards (262.10).** The compiler now emits a lint warning when an `available when` clause resolves to a non-boolean literal. Boolean-returning conditions are required. If your routing guards use comparisons that could accidentally resolve to a string or number, the lint will catch it at compile time rather than producing silent misrouting at runtime.

---

## 6. Orchestration Patterns

### 6.1 Supervised Mode (GA)

The orchestrator receives every user request. It reads each connected subagent's description, selects the right specialist, delegates the task, buffers the specialist's output, and synthesizes a final response before it reaches the user.

**Latency note.** In supervised mode, every user turn involves at minimum: an orchestrator routing call (LLM hop 1), an agent-to-agent API call, a subagent topic selection (LLM hop 2), and response synthesis back up the chain (LLM hop 3). At P95, this adds 12–20 seconds of orchestration overhead on top of the subagent's own execution time. Design SLAs accordingly.

**Runtime configuration (262.12).** A `config.runtime` block is now available at the top level of an agent's script. It exposes boolean flags that control platform-level behaviors:

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
| `streaming` | Enables or disables token streaming for this agent. Replaces the previous `additional_parameter__disable_streaming` approach. |
| `thought_chunks` | Controls whether intermediate reasoning chunks are emitted to the reasoning panel. |
| `citation` | Enables or disables source citation in responses. |
| `groundedness` | Explicitly enables or disables groundedness validation. Previously this was an implicit platform behavior with no direct switch. |
| `reset_to_initial_node` | When `true`, resets conversation state to the initial node after the session ends. Relevant to architectures that reuse session state across turns. |

> **Compile error on empty `runtime` block:** An empty `runtime:` block is now a hard compile error. If you declare the block, you must set at least one flag. Either populate it or omit it entirely.

Two things are worth calling out for multi-agent architects specifically. The `groundedness` flag changes the prior assumption that groundedness was always active underneath your agent configuration — it is now an explicit, auditable switch. If your orchestrator's security model assumes groundedness is enforced, add `groundedness: true` explicitly rather than relying on default platform behavior. And `reset_to_initial_node` is directly relevant to Section 7's discussion of session state and statelessness: if your orchestrator accumulates state across a session that should not persist into a new turn, this flag provides the reset mechanism.

**Streaming.** With the `config.runtime` block, streaming is now controlled via `runtime.streaming: true/false`. Users see sub-agent output appearing in a collapsible reasoning panel word by word while synthesis runs — eliminating the blank waiting state. The final synthesized response then streams into the main chat area. The Superagent's flag takes precedence over subagent flags for the end-user experience.

**Progress messaging.** During delegation, users see a configurable progress message ("Collaborating with our team..."). Admins configure this per Superagent in the builder. Sub-agent outputs appear in a collapsible reasoning panel (visible on LEX, Slack, and Enhanced Chat; hidden on WhatsApp, SMS, and Mobile).

### 6.2 Handoff Mode (Post-GA)

The orchestrator routes once, then steps back for that turn. The specialist owns the conversation directly with the user and streams its response without an orchestrator synthesis step. After the turn completes, control returns to the orchestrator.

**Why this matters for latency.** Removing the synthesis step cuts the P95 overhead from ~12–20s (3-LLM-hop supervision) to ~5–6s (2-LLM-hop handoff). For high-volume contact center deployments where routing decisions are predictable, this is the SLA pattern.

**Trust model.** Only same-org, same-platform agents can receive handoffs. Third-party and cross-vendor agents are never handed off to directly — the orchestrator always mediates. Handoff is opt-out per subagent in script (`allow_direct_handoff: false`). The default for trusted subagents is on.

> **Status:** Not yet available in GA rollout. Target: post-GA fast-follow.

### 6.3 Parallel Execution (Post-GA)

The orchestrator fans out to multiple specialists simultaneously. Each runs independently. The orchestrator collects all results and synthesizes them into one response. Total wait time equals the slowest single agent, not the sum.

**When to use.** Tasks requiring multiple independent inputs: portfolio analysis, composite risk assessment, multi-system due diligence. Running several analyses in parallel — for example, risk scoring, market insights, regulatory grading, and tax harvesting — means none needs to wait for another to begin.

**Watch out.** The orchestrator waits for *all* agents before synthesizing. A single timing-out subagent blocks the whole response. Build explicit partial-result handling into synthesis logic before deploying parallel patterns in production.

> **Status:** Not yet available in GA rollout. Target: post-GA.

### 6.4 Plan and Present (Post-GA)

The orchestrator shows the user a step-by-step execution plan before running anything. The user approves. Only then does execution begin.

**Why this matters.** This is the pattern that opens regulated verticals — healthcare, financial advisory, legal, government — where automated action without human confirmation is a liability. It removes the human oversight objection while preserving automation benefits.

> **Status:** Not yet available in GA rollout. Target: post-GA.

---

## 7. Platform Limits and Structural Constraints

### 7.1 Two Different Scopes, Two Different Numbers

There are two different limit concepts that apply to subagent counts in a SOMA architecture. They are frequently confused. They describe different things and are not contradictory.

**Design heuristic (single-agent complexity threshold).** When a *single agent's* topic and subagent count approaches 10, that is a signal the agent is becoming too complex for one agent to handle well. This is a design guidance heuristic — the point at which distributing work across multiple agents in a SOMA network starts to make architectural sense. It is not a platform-enforced limit.

**SOMA network width (connected subagents in an orchestrated network).** The platform warns (but does not block) when an orchestrator's connected-subagent count exceeds 7–8 agents. This is a SOMA-specific, separately bounded constraint on the *width* of the orchestrated network — distinct from how many topics or internal subagents any single agent within that network has.

These two numbers operate at different levels of the architecture. A SOMA network can contain multiple agents each with up to 10 internal topics, connected via up to 7–8 connected-subagent links, and the two limits govern completely separate dimensions of the system.

### 7.2 Constraints Reference Table

| Dimension | Limit | Notes |
|---|---|---|
| Delegation depth | 1 level only (A to B) | Connected subagents cannot themselves delegate further. Not a soft warning — this is enforced. |
| SOMA network width | 7–8 connected subagents (Salesforce recommendation) | Not a hard platform cap; the builder warns but does not block. PM guidance confirms up to 20 connected subagents is technically supported; 8 is cited as a well-performing configuration. |
| Topics per agent | Up to 10 (Salesforce recommendation) | Not a hard cap. Part of official Agents Limits documentation. |
| Actions per subagent | Up to 10 (Salesforce recommendation) | Not a hard cap. Part of official Agents Limits documentation. |
| Session duration | 24–48 hours | Hard limit. |
| Platform reasoning-engine timeout | **30 seconds** | Platform-wide limit inherited by all reasoning engine requests, including connected subagent calls. Not a SOMA-specific constraint. Confirmed in official Agents Limits documentation. Long multi-step journeys (e.g., 11+ step workflows) are better suited to Handoff Mode than connected subagent chains for exactly this reason — complex subagent reasoning can approach this ceiling. |
| 3P agent call timeout | **120 seconds** | Scoped specifically to outbound calls to third-party (3P) agents via A2A. If a 3P agent does not respond within 120 seconds, the system prompts the user to retry. This is **not** an orchestrator-wide timeout. |
| Variable mapping direction | One-way: orchestrator to subagent | Bidirectional is a post-GA fast-follow. |
| Context history on delegation | Last 10 messages | Confirmed in Pilot PRD. Verify against your org's release notes post-GA rollout completion; this value may be updated. |
| `config.runtime` empty block | Hard compile error | An empty `runtime:` block fails compilation. Set at least one flag or omit the block. |

> **Note on subagent counts:** The previously published "5 internal subagents per connected subagent (hard limit)" figure in v3.0 has been removed. That figure could not be sourced from any Salesforce primary documentation and is directly contradicted by official PM guidance. The verified limits are: up to 10 topics per agent and up to 10 actions per subagent (both soft recommendations), with no documented hard cap on internal subagent or topic count per connected subagent.

### 7.3 Supported Agent Type Combinations

| Orchestrator type | Connected subagent type | Supported? |
|---|---|---|
| ASA (Agentforce Service Agent) | ASA | Yes |
| AEA (Agentforce Employee Agent) | AEA | Yes |
| AEA | ASA | Yes |
| ASA | AEA | No |
| Any | File-based (SDR, Analytics) | Post-GA |

### 7.4 Goal-Based Agents: Beyond Turn-Based Orchestration (Pilot)

> **Pilot status:** Everything in this section describes pilot functionality introduced in 262.14. Syntax and block structure are subject to change before GA. Do not use this section's content to represent production-ready capabilities.

The Supervisor pattern described throughout this guide — and the turn-based `start_agent` model that underlies it — assumes a user is present: a human sends a message, the orchestrator routes it, an agent responds. Every section of this guide from Section 4 onward is built on that model.

Goal-Based Agents (also referred to as AgentIQ internally) introduce a fundamentally different execution model. Instead of responding to inbound user turns, a Goal-Based Agent is triggered by a scheduled event or an external condition and executes an autonomous, multi-step workflow without a human in the loop for each step. This is not a variation of the Supervisor pattern. It is a separate agent type with its own blocks, its own scheduling primitives, and its own compile-time enforcement.

**Why it matters for this guide.** Multi-agent architects evaluating long-running, scheduled, or event-driven workflows should be aware that Goal-Based Agents exist as an emerging option — and that mixing Goal-Based Agent blocks into a standard agent script is now a hard compile error (262.14 enforces this). The two models are intentionally separated at the compiler level.

**Enabling Goal-Based Agents.** The `config.agent_type` field must be set to `"GoalBasedAgent"`. Omitting this flag while using the blocks below will produce a compile error.

```agentscript
config:
    name: "Portfolio_Review_Agent"
    agent_type: "GoalBasedAgent"
```

**New blocks introduced by Goal-Based Agents:**

| Block | Purpose |
|---|---|
| `workflows` | Defines the named multi-step workflows the agent can execute |
| `trigger` | Specifies scheduling rules (cron syntax) that initiate workflow execution without a user turn |
| `orchestrator` | Configures how the agent coordinates across workflow steps |
| `# @dialect: agentforce-plugin` | File-level declaration marking a file as an agent plugin |

**Plugins.** Goal-Based Agents can reference modular skill packages declared with the `# @dialect: agentforce-plugin` file directive. Once declared, they are referenced in script as `@plugins.<name>.*`. This is distinct from Inline Skills (see below) — plugins are externally defined, file-level constructs; Inline Skills are node-level definitions within a single agent's script.

**What to do now.** Goal-Based Agents are pilot-gated and syntax is subject to change. The appropriate action for teams evaluating scheduled or autonomous workflows is to register interest with your Salesforce account team and follow the pilot program. Do not build production dependencies on the `workflows`, `trigger`, or `orchestrator` blocks until GA guidance is published.

**Inline Skills (Pilot, 262.14).** A related pilot feature worth noting: `reasoning.skills` is a per-node block that mirrors how `reasoning.actions` maps tools to LLM-callable functions, but for skills rather than actions. Skills can be defined inline with an `instructions` body, or they can point at an external `skill://` target. A top-level `skill_definitions` block registers skills for use across subagents.

This is a new instruction-authoring primitive that sits alongside actions in the reasoning surface. It is in pilot and syntax may change. Architects designing agent networks that will need skill-level modularity should be aware it is coming, but should not build production logic against it until the GA surface is stable.

---

## 8. Identity, Security, and Authentication

**Identity propagation.** User identity and permissions propagate automatically through the entire agent chain. No agent in the network can access data beyond the permissions of the original calling user. This is enforced by the trust model, not by individual agent configuration.

**Primary identity resolution (MOMA).** The system resolves user identity across orgs using email address as the default resolver. If email mapping succeeds, the mapped identity is used. If it fails, the system defaults to Guest User authorization. Step-up authentication (triggering a login prompt mid-conversation for a previously unauthenticated user) is not supported in the current release.

**Authentication mechanisms by agent type:**
- Authenticated AEA-to-AEA: Supported
- Unauthenticated ASA-to-ASA: Supported
- Authenticated ASA-to-ASA: Not supported in current release
- AEA-to-ASA: Supported
- ASA-to-AEA: Not supported

**3P authentication.** Outbound 3P calls use OAuth credentials stored in Named Credentials. Inbound 3P calls authenticate via ECA (External Client Apps) with the `a2a_api` custom scope. AEA access from 3P platforms requires the Web-Server Flow; ASA access uses the Client Credentials Flow.

**Trust boundary rules (MOMA).** An org can belong to only one agent trust boundary at a time. Trust boundaries are stored in GDoT. Agent sharing is opt-in: admins explicitly mark agents as shareable. Shared agents are grouped into Agent Groups that control per-org visibility. An org cannot be in multiple agent trust boundaries simultaneously, though it can be in one DC1 trust boundary and one agent trust boundary at the same time.

**Who can connect agents.** Org Admin only. Connecting agents in a SOMA or MOMA network is an elevated operation restricted to administrators.

**`strip_salesforce_instructions` (262.14).** This flag removes the Salesforce system prompt from an agent's context. It can be applied top-level (removing it for the entire agent) or per-subagent (removing it for a specific node).

This has direct security and governance implications for multi-agent networks. The guide's system instruction model — described in Sections 4 and 6 — assumes a Salesforce baseline persona sits underneath any custom instructions you write. That baseline provides a behavioral floor: it constrains tone, enforces basic safety behaviors, and gives the LLM a grounded starting persona even when your own instructions are silent on a topic.

Stripping it removes that floor entirely. In a SOMA network, this means:

- Any behavioral invariant the Salesforce baseline was silently covering — safety constraints, refusal behaviors, persona defaults — must now be restated explicitly in your own system instructions or in the orchestrator's global instruction block.
- Connected subagents that inherit from the orchestrator's instructions do so against your custom baseline, not the Salesforce one. If a subagent was relying on the Salesforce baseline to fill gaps in its own instructions, those gaps are now uncovered.
- The risk is highest in networks where individual connected subagents have thin or partial instruction sets, because the baseline was doing more work per node than architects may have realized.

If you use `strip_salesforce_instructions`, treat it as a requirement to perform a full audit of all system instruction surfaces across the network — orchestrator and every connected subagent — to ensure no gap is left unaddressed.

**Escalation path governance.** The `delegate_escalation` field on connected subagents (boolean, default `true`) controls whether, when a connected subagent triggers an escalation, it uses the connected subagent's own outbound escalation flow or the orchestrator's. With the default of `true`, escalation follows the connected subagent's own flow — which may route to a queue or agent group configured in a different org or context than the orchestrator's. Set `delegate_escalation: false` on connected subagents where you want all escalation to flow through the orchestrator's centralized path. This is particularly important in MOMA networks, where connected subagents in different orgs may have escalation targets that are invisible to the orchestrating org's governance team.

---

## 9. Performance and Latency

Multi-agent architectures carry higher latency than single-agent solutions by design. The orchestration layer, additional LLM calls, and agent-to-agent API hops all add overhead. Customers must account for this when setting SLAs.

**P95 latency breakdown for a SOMA network (supervised mode):**

| Layer | P95 Overhead |
|---|---|
| Orchestrator routing (LLM hop 1) | ~3–5 seconds |
| Agent-to-agent API call | ~2–4 seconds |
| Subagent topic selection (LLM hop 2) | ~3–5 seconds |
| Topic-to-action handoff | ~1–2 seconds |
| Response synthesis (LLM hop 3) | ~2–3 seconds |
| **Total P95 SOMA overhead** | **~12–20 seconds** |

**With handoff mode (post-GA, 2-LLM-hop path):** ~5–6 seconds of orchestration overhead.

**Target end-to-end turn time:** Less than 15 seconds total (reasoning plus delegation). Streaming reduces *perceived* latency significantly — users see content appearing rather than waiting for a complete response.

**Guidance for customers.** A Superagent architecture adds approximately 12–20 seconds of orchestration overhead at P95 in supervised mode. Design for end-to-end SLAs that account for both orchestration overhead and subagent execution time. If total latency is your primary constraint, evaluate whether Handoff Mode (post-GA) or a restructured single-agent solution better fits your SLA requirements.

**The 30-second reasoning engine boundary.** Because the platform reasoning engine times out after 30 seconds, any connected subagent whose internal reasoning approaches this boundary will fail. If a subagent needs to run a complex, multi-step workflow that may take close to 30 seconds to reason through, route it to Handoff Mode (post-GA) rather than a connected subagent chain.

---

## 10. Observability and Testing

### 10.1 Unified Trace and Logging

Every multi-agent session generates independent trace logs for both the Superagent and all connected subagents, stored in STDM (Salesforce Trace Data Model). The architecture supports bidirectional lookup:

- **Forward:** Primary Agent trace step to Sub-Agent session ID (via Attributes field)
- **Backward:** Sub-Agent session to Primary Agent session (via PreviousSessionId)

**Unified trace view.** Agentforce Builder's preview mode includes a single timeline showing the reasoning steps of both the Superagent and all subagents, including the rationale for each routing decision. The State Inspector shows how context variables change as they move between agents.

**Analytics metrics available for multi-agent workflows:**
- Sub-agent invocation count (rolling time period)
- End-to-end task resolution success rate
- Error rate across the full agent chain (broken down by orchestration, handoff, authentication, and timeout errors)
- Per-hop latency (orchestration time, agent invocation time, and execution time at each delegation point)
- Handoff failure alerts
- Sub-agent downtime alerts

### 10.2 Testing Center for Multi-Agent Workflows

The Agentforce Testing Center (GA: July 18, 2026) provides dedicated evaluations for multi-agent orchestration:

**Sub-Agent Assertion.** A new standard eval that checks whether the orchestrator invoked the correct connected subagent for a given utterance — analogous to the existing Topic Assertion eval for single-agent flows.

**Task Completion Success.** Verifies end-to-end task completion across the entire multi-agent workflow, not just within a single agent.

**Multi-Hop Latency Breakdown.** Extends the existing latency evaluation to attribute time across the delegation chain, identifying which hop is the bottleneck.

**Semantic Conflict Detection (post-GA).** An LLM-as-judge evaluation that scans conversation logs for contradictory assertions across agents or signs of looping behavior.

**LLM-as-judge evaluation.** Testing Center uses an LLM evaluator for grading test runs. Available models as of the July 18 GA include Claude Sonnet and GPT-4o Mini. The exact model selection logic per org configuration is subject to change; verify current behavior in your org's release notes before relying on specific model behavior for evaluation reproducibility.

**Limits.** 500 test cases per job. Recommended batch size: 20–30 cases. Testing Center is enabled automatically for all Agentforce customers in Sandbox orgs at no additional cost.

---

## 11. Admin Experience Reference

### 11.1 Agentforce Builder Views

Agentforce Builder provides three interchangeable views, all of which compile to the same underlying Agent Script:

| View | Best for |
|---|---|
| Conversational | Describe the network in natural language ("I need a supervisor agent that coordinates my Billing Agent and Logistics Agent"). The system generates connections automatically. |
| Canvas | Point-and-click configuration via the Resource tab. Select Connected Agents, then Add. Multiple agents can be added together. |
| Script | Direct Agent Script editing. Supports conditionals, variable mappings, `else if` chains, and explicit `connected_subagent` blocks. |

Admins can switch between views at any time without losing work. All views reflect the same underlying configuration.

> **Note:** `else if` chains in deterministic (`->`) mode are only visible and editable in Script view. Canvas does not yet render them. Routing logic that uses `else if` should be authored and maintained in Script view.

### 11.2 Connecting Agents

**Prerequisites.** Sub-agents must be activated individually before being added to a network. Draft agents can be added in preview mode for testing but will not be accessible to end users until activated.

**Agent types that can be connected.** Any active agent available in the org's AiAgent BPO can be added as a connected subagent. A Superagent (that already has connected subagents) can itself be added as a connected subagent to another Superagent — but only one level deep. Circular connections (A to B to A) are detected and blocked.

**Sub-agent visibility.** Once a Superagent is selected in the agent picker, individual sub-agents are hidden from the end user. The user sees and interacts only with the Superagent.

### 11.3 Validation and Network Health

Before publishing, run **Check Network Health** to validate the agent network. Validation can also be triggered manually at any time after changes. Issues appear inline in the builder.

| Validation check | Behavior |
|---|---|
| Depth limit (more than 1 level deep) | Warn, not block |
| Width limit (more than 7–8 agents wide) | Warn, not block |
| Loop detection (A routes to B which routes back to A) | Block — not permitted |
| Skill overlap | LLM-based warning with suggestions; does not hard-block |
| Language compatibility | Error if no overlapping supported languages between Superagent and subagent |
| `available when` non-boolean condition | Lint warning — condition resolves to a non-boolean literal |
| Empty `config.runtime` block | Hard compile error — set at least one flag or omit the block |

### 11.4 Composability and Updates

Sub-agents can be added or removed from an active Superagent without deactivating it. Changes take effect without interrupting ongoing conversations.

**Version management.** Sub-agent teams can deploy new versions independently without coordinating with the Superagent owner. Deploy the new version, then activate it. The Superagent uses whichever version is currently activated. Rolling back is as simple as activating an older version. Ongoing conversations continue with the previous version until they complete; new conversations use the newly activated version.

**Draft testing in live context.** Admins can add a draft version of a sub-agent and test it within the live Superagent network before promoting it to active.

**Permanent removal.** A sub-agent cannot be permanently deleted if it is connected to an active Superagent (unlink first) or has active long-running sessions. The UI shows active sessions and connected Superagents when removal is blocked.

### 11.5 Admin Controls Summary

| Setting | Location | Configurable by | Default |
|---|---|---|---|
| Streaming on/off | `config.runtime.streaming` in agent script | Admin | On |
| Groundedness on/off | `config.runtime.groundedness` in agent script | Admin | Platform default (set explicitly to ensure it) |
| Handoff on/off (post-GA) | Per subagent, script (`allow_direct_handoff`) | Admin | On for trusted agents |
| Variable mapping direction | Script | Admin | Explicit — no default |
| Global instructions (brand tone, policies) | Orchestrator script | Admin | Off; subagent opts in |
| Progress message text | Superagent builder | Admin | "Getting answers..." |
| Trust designation | Platform | Salesforce | — |
| Reasoning panel visibility | Platform, per channel | Not configurable | Visible on rich UI channels only |
| Who can connect agents | Platform | Org Admin only | — |
| Escalation path | `delegate_escalation` on connected subagent | Admin | `true` (connected subagent's own flow) |
| Salesforce system prompt | `strip_salesforce_instructions` | Admin | Off (baseline present) |

---

## 12. End-User Experience

From the user's perspective, multi-agent orchestration is invisible. They see one conversation, one brand voice, one response — regardless of how many agents worked behind the scenes.

**Progress indication.** Users see a configurable "Getting answers..." message with animated progress markers while the Superagent coordinates sub-agents. Sub-agent outputs appear in a collapsible reasoning panel (open by default, collapsible by the user) on rich UI channels.

**Channel support for reasoning panel:**

| UI element | Channels |
|---|---|
| Reasoning panel (thinking stream) | LEX, Slack, Enhanced Chat |
| Streaming final answer | All channels |
| Progress indicator | All channels |

On WhatsApp, SMS, and Mobile, the reasoning panel is hidden. The user sees only the final answer, streamed.

**Failure handling.** Every failure message is clean, user-facing, and actionable (rephrase, retry, start over, verify identity). Internal errors, sub-agent names, and tool failures are never surfaced to the user. "No results" and "failure" are always distinct messages. Default failure handling for GA: retry the same agent twice; if that fails, return to the Superagent with an error for it to communicate to the user.

**Session duration.** Multi-agent sessions support 24–48 hour durations as a hard limit.

---

## 13. Cross-Platform A2A: Third-Party and MCP Patterns

> **Important:** Everything in this section describes **Beta** functionality as of August 2026. Do not use this section's content to represent GA capabilities.

**3P Outbound (Salesforce to external vendor agents).** Once a 3P agent is registered via the AF Registry page with OAuth credentials and A2A Server URL, it can be connected to a primary AF agent. The Planner routes requests to the 3P agent when user intent matches the agent's declared skills on its A2A card. 3P agent calls must return a single synchronous TaskResult. Streaming and partial responses are not supported in Pilot. The 120-second timeout applies to each 3P call.

**3P Inbound (external vendor to Salesforce agents).** A2A cards are auto-generated from each AF agent's existing metadata (name, description, topics, actions) and published at a `.well-known/agent-card.json` endpoint. Admins maintain an allowlist specifying which agents are accessible to external vendors. Authentication uses ECA with the `a2a_api` custom scope.

**MCP Client.** Agentforce can invoke external tools — databases, SaaS APIs, search engines — via the Model Context Protocol. This is the appropriate pattern when the external system is a *tool* rather than an *agent* (it does not reason; it executes and returns data).

**Agentforce as MCP Server.** External hosts (such as third-party AI assistants or enterprise LLM platforms) can invoke Agentforce capabilities as tools via a Salesforce-hosted MCP Server. This is the appropriate pattern when an external platform needs to use Agentforce as a specialized execution layer without building full A2A orchestration.

---

## 14. Industry Use Cases

The following use cases illustrate the business scenarios that drove SOMA, MOMA, and 3P design decisions. These are drawn from Pilot program participants and internal customer zero deployments, anonymized by industry.

### SOMA Use Cases

**Financial Services — Parallel Portfolio Analysis.**
Analysts in a financial services firm needed to review client profiles, analyze market conditions, calculate risk scores, and generate client-ready recommendations — capabilities that require distinct data sources, regulatory constraints, and specialized logic that a single agent could not handle well simultaneously. A SOMA network with four specialist agents (market data, risk scoring, regulatory compliance, client communication) operating under a single orchestrator replaced a workflow that previously required analysts to context-switch across multiple systems. Parallel execution (post-GA) is planned to run all four analyses simultaneously, reducing end-to-end response time to the duration of the slowest single agent.

**Professional Services — Internal Employee Agent Ecosystem.**
A professional services firm needed to give delivery staff access to specialized knowledge and relationship data without requiring them to leave their primary workflow. Two domains — delivery management (project tracking, opportunity splits, resourcing) and relationship management (contact lifecycle, engagement goals) — had distinct business rules, data owners, and permission models that made a single monolithic agent impractical. A SOMA Superagent coordinates two specialist agents (a Delivery Agent and a Relationship Agent), eliminating context-switching across CRM workflows while maintaining strict data boundary separation between the two domains.

### MOMA Use Cases

**Technology / Professional Services — Cross-Org Knowledge Delivery.**
A large technology organization needed to make specialized internal knowledge available to field delivery staff across a separate Salesforce org, without requiring re-authentication or manual context-switching. A Delivery Agent in the primary delivery org delegates knowledge queries to a centralized Knowledge Agent in a separate services org, both within the same DC1 trust boundary. Single login, no step-up authentication, no context switching — the multi-org boundary is fully transparent to the end user.

**Financial Services — Multi-System Loan Processing.**
Loan officers in a financial services firm handling complex secured lending products needed fast, consolidated answers when processing delays occurred. A query such as "Why is this application delayed?" triggers an orchestrator that delegates simultaneously to three specialist agents — credit eligibility, legal verification, and property valuation — then returns a unified explanation with recommended next steps. Previously, officers had to query each system independently and manually correlate the results.

### 3P Use Cases

**Technology / Document Management — RFP Response Automation (3P Outbound).**
A technology firm's sales teams were spending 6–8 hours per RFP manually assembling responses that required both deep document analysis and CRM relationship data. Neither capability resided in a single platform. A 3P Outbound pattern connects a document intelligence agent (hosted externally) with an Agentforce agent (handling sales workflow execution) at runtime. Each platform contributes its native capability; neither needs to replicate the other's functionality.

**Technology — Inbound Delegation from External AI Platform (3P Inbound).**
An enterprise AI platform serving internal staff with HR, finance, and IT queries cannot handle Salesforce-specific execution (case creation, status lookups, record updates) natively. When a user query requires Salesforce-side action, the external platform delegates inbound to an Agentforce Service Agent via the A2A protocol. Agentforce handles Salesforce execution; the external platform handles everything else. The handoff is invisible to the end user.

---

## 15. Pre-Deployment Checklist

Use this checklist before activating a SOMA Superagent network for production traffic.

### Org Readiness

- [ ] Confirm SOMA is enabled in your org — check your pod's rollout status if not yet visible (full rollout expected by ~August 25–26, 2026)
- [ ] Einstein and Agentforce features are enabled in org settings
- [ ] Org Admin permissions are confirmed for the user connecting agents
- [ ] All sub-agents are individually activated before being added to the network

### Architecture Review

- [ ] Each connected subagent has a distinct, non-overlapping description
- [ ] Delegation depth is 1 level only (no A to B to C chains)
- [ ] Network width is at or below 8 connected subagents; if wider, document the rationale and run extended performance testing
- [ ] Complex multi-step subagent workflows that may approach 30 seconds of reasoning time are identified — plan to route these to Handoff Mode (post-GA) or restructure as single-agent flows
- [ ] Circular routing (A to B back to A) has been checked and is absent
- [ ] The supported agent-type combination is confirmed (AEA-to-AEA, ASA-to-ASA, or AEA-to-ASA only; ASA-to-AEA is not supported)
- [ ] All `connected_subagent` target fields use the `agent://` URI scheme (not the deprecated `agentforce://`)
- [ ] `config.runtime` block, if present, sets at least one flag (empty block is a compile error)
- [ ] If `strip_salesforce_instructions` is enabled on any agent or subagent, a full audit of all system instruction surfaces in the network has been completed and all behavioral invariants are restated explicitly

### Variable and Context Design

- [ ] Variable mapping is one-directional (orchestrator to subagent); no workflow logic assumes subagent writes propagate back automatically
- [ ] Context history dependency is within the 10-message window per delegation call
- [ ] All mapped variables exist in both the orchestrator and the target subagent; validation errors are resolved before publishing
- [ ] All variable declarations use `string` rather than the deprecated `id` type
- [ ] All required action inputs either have an explicit `with` binding, a declared default, or an intentional `slot_filled_by: LLM` annotation — no required inputs are left implicitly unbound

### Routing and Escalation

- [ ] All `available when` conditions are confirmed to return boolean values (non-boolean conditions emit a lint warning and may produce silent misrouting)
- [ ] `delegate_escalation` is set intentionally on all connected subagents — `true` routes escalation through the connected subagent's own flow; `false` routes it through the orchestrator
- [ ] Any use of the deterministic `escalate` statement is reviewed to confirm it fires exactly once per turn and is not placed in a context where it could be re-triggered

### Performance and SLA Planning

- [ ] SLAs account for 12–20 seconds of P95 orchestration overhead (supervised mode) on top of subagent execution time
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

---
