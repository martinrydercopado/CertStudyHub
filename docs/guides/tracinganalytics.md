# Reference: Tracing and Analytics in Agentforce

> **Purpose:** This guide is a study reference for Success Architects and practitioners who need a deep, value-grounded understanding of Agentforce observability tooling. Every section pairs technical detail with "why it matters" analysis and real-world scenarios to make the concepts stick.

---

## Table of Contents

1. [Why Observability Matters in an AI Agent Context](#1-why-observability-matters)
2. [Infrastructure Prerequisites: Data 360 and Permissions](#2-infrastructure-prerequisites)
3. [The Three Observability Pillars](#3-the-three-observability-pillars)
   - [Pillar I: Agent Analytics (Usage and Performance)](#pillar-i-agent-analytics)
   - [Pillar II: Agent Optimization (Deep Tracing and Refinement)](#pillar-ii-agent-optimization)
   - [Pillar III: Health Monitoring (Real-Time Alerting)](#pillar-iii-health-monitoring)
4. [Session Tracing vs. Agent Platform Tracing](#4-session-tracing-vs-agent-platform-tracing)
5. [Plan Tracer / Session-Level Debugging](#5-plan-tracer--session-level-debugging)
   - [Simulated vs. Live Preview Mode](#simulated-vs-live-preview-mode)
   - [Trace File Anatomy](#trace-file-anatomy)
   - [Step Types Reference](#step-types-reference)
   - [How to Read a Trace End-to-End](#how-to-read-a-trace-end-to-end)
   - [The LLMStep: Your Most Important Signal](#the-llmstep-your-most-important-signal)
   - [Grounding: The Hidden Quality Gate](#grounding-the-hidden-quality-gate)
   - [Testing Best Practices](#testing-best-practices)
6. [Agent Platform Tracing (Service-Level)](#6-agent-platform-tracing-service-level)
   - [How Trace Trees Work](#how-trace-trees-work)
   - [Key Fields on ssot__TelemetryTraceSpan__dlm](#key-fields-on-ssotelemetrytracespan__dlm)
   - [SOQL for Performance Profiling](#soql-for-performance-profiling)
   - [Joining Session Tracing and Platform Tracing](#joining-session-tracing-and-platform-tracing)
   - [Slackbot Integration for Conversational Observability](#slackbot-integration-for-conversational-observability)
7. [MCP Actions: How Observability Changes](#7-mcp-actions-how-observability-changes)
8. [Dashboards and Metrics to Know Cold](#8-dashboards-and-metrics-to-know-cold)
   - [Out-of-the-Box Panels](#out-of-the-box-panels)
   - [Data Cloud STDM Tables](#data-cloud-stdm-tables)
   - [Einstein Trust Layer Audit Trail](#einstein-trust-layer-audit-trail)
   - [Proactive Monitoring Alerts](#proactive-monitoring-alerts)
9. [Common Diagnostic Patterns](#9-common-diagnostic-patterns)
10. [Sandbox vs. Production Tracing](#10-sandbox-vs-production-tracing)
11. [Mapping Observability to Business KPIs](#11-mapping-observability-to-business-kpis)
12. [Credit Consumption and Observability Cost Awareness](#12-credit-consumption-and-observability-cost-awareness)
13. [Roadmap Awareness: Setting Stakeholder Expectations](#13-roadmap-awareness-setting-stakeholder-expectations)
14. [Quick-Reference Cheat Sheet](#14-quick-reference-cheat-sheet)

---

## 1. Why Observability Matters

Traditional software is deterministic. Given the same input, you get the same output. You can write a unit test that covers a code path perfectly.

AI agents are **probabilistic**. The LLM's response varies based on phrasing, conversation history, instruction clarity, and model behavior that is not fully predictable. An agent that worked flawlessly in three test sessions may fail in production for the fourth user who phrases their request slightly differently. That gap — the delta between what you tested and what users actually experience — is exactly what observability tooling is designed to close.

**The core value statement:**

> Without observability, you are operating an agent on faith. With observability, you operate it on evidence.

This distinction matters enormously at the enterprise level. Stakeholders deploying Agentforce for customer service, employee enablement, or field operations need answers to three fundamental questions:

1. **Is the agent being used?** (Usage and adoption)
2. **Is it working correctly?** (Quality and deflection)
3. **Is it safe and healthy?** (Trust and reliability)

The three observability pillars map directly to these three questions.

---

## 2. Infrastructure Prerequisites

Before any tracing or analytics capability is usable, the underlying infrastructure must be in place. Skipping this step is the most common reason a Success Architect finds an org where dashboards exist but surface no data.

### Data 360 / Data Cloud: The Foundation Layer

Both Agentforce Session Tracing (STDM tables) and Agent Platform Tracing (`ssot__TelemetryTraceSpan__dlm`) store their data in **Data 360 / Data Cloud DMOs**. Neither feature works without Data Cloud provisioned and active in the org.

**Verification query:**

```soql
SELECT COUNT() FROM DataKnowledgeSpace
```

If this returns an `INVALID_TYPE` error, Data Cloud is not provisioned. Direct the customer to Setup > Data Cloud Setup and verify the CRM Connector status before proceeding with any observability configuration.

### Enabling Agent Platform Tracing

Agent Platform Tracing is off by default and must be explicitly enabled:

1. Navigate to **Setup > Agent Platform Tracing**.
2. Flip the toggle to **Enabled**.
3. Span data begins populating within minutes of the first Agentforce action execution. There is no backfill of historical data.

> **Critical:** There is no retroactive data. Any sessions that occurred before enablement are invisible to Platform Tracing. Turn this on as early as possible in every customer engagement.

### Required Permission Sets

Users querying trace DMOs need explicit access grants. Missing permissions produce empty query results, not error messages, which makes them easy to misdiagnose as "no data exists."

| API Name (use this in SOQL/CLI) | UI Label | Purpose |
|---|---|---|
| `CopilotSalesforceAdmin` | "Agentforce Default Admin" | The primary admin permset. Covers building and managing agents, org-wide access to all agents, activating and deactivating agents, customizing subagents and actions, and monitoring agent activity. Required for authoring, CLI operations (`sf agent preview`, `sf agent publish`), and all observability surfaces. |
| `GenieAdmin` | "Data Cloud Architect" | Access to Data Cloud Setup (requires Salesforce admin) and management of all standard Data Cloud functionality and data. Assign to any admin who needs to work with Data Cloud configuration or query DMO tables. Note: DMO query access via this permset should be verified in your org — the description does not explicitly grant it. |
| `GenieUserEnhancedSecurity` | "Data Cloud User" | Gives view access to Data Cloud. Assign to Einstein Agent Users that need runtime Data Cloud access, such as for knowledge-grounded agents. |
| `AgentforceServiceAgentUser` | "Agentforce Service Agent User" | Analyze topics and perform actions as an autonomous AI service agent. Assign to the Einstein Agent User identity for service agents. |
| `AgentforceServiceAgentBuilder` | "Agentforce Service Agent Configuration" | Build and manage autonomous AI service agents. Also grants org-wide access to all agents, including managing, activating, deactivating, and monitoring agent activity. Use this for admins whose primary role is service agent configuration, as distinct from the broader `CopilotSalesforceAdmin`. |
| `AgentforceDeveloperAndAdminTools` | "Agentforce Developer and Admin Tools" | Grants access to developer and admin tooling for Agentforce. No official description available at time of writing — verify in your org before assigning. |
| `CDPAdmin` | "Data Cloud Admin" | Older CDP-era equivalent of `GenieAdmin`. Same access scope. If both exist in your org, `GenieAdmin` is the current standard. Do not assign both. |

> **Do not query by UI label.** `GenieAdmin`'s UI label is "Data Cloud Architect" but querying `Name = 'DataCloudArchitect'` returns nothing in SOQL — the correct API name is `GenieAdmin`. The same trap applies to `CopilotSalesforceAdmin`, whose UI label is "Agentforce Default Admin."

**Verification query (confirm both core admin permsets are assigned):**

```bash
sf data query --json \
  --query "SELECT PermissionSet.Name FROM PermissionSetAssignment \
           WHERE AssigneeId = '<adminUserId>' \
           AND PermissionSet.Name IN ('GenieAdmin', 'CopilotSalesforceAdmin')" \
  -o TARGET_ORG
```

---

## 3. The Three Observability Pillars

**AGENTFORCE OBSERVABILITY STACK**

**Pillar I: Agent Analytics** *(Usage and Performance)*
- Tableau Next OOTB Dashboards
- Data Cloud DMOs
- KPI Tracking

**Pillar II: Agent Optimization** *(Deep Tracing)*
- Session Trace Files (`.sfdx/`)
- Platform Tracing (TelemetrySpan)
- Custom Evaluations

**Pillar III: Health Monitoring** *(Real-Time Alerting)*
- Einstein Trust Layer Fail-safes
- Platform Health Integration
- Timeout Tracking

---

### Pillar I: Agent Analytics

**What it is:** Pre-built, out-of-the-box dashboards and underlying Data Cloud DMO tables that give you a high-level view of how your agent is performing across all sessions.

**Why it exists:** You cannot manually review every conversation. Analytics provide an aggregated signal layer that surfaces trends, anomalies, and KPIs without requiring you to look at individual sessions. Think of it as the "executive layer" of observability.

#### Key Metrics

| Metric | What It Tracks | Business Value |
|---|---|---|
| Conversation Volume | Daily/weekly session counts | Adoption curve post-launch |
| Topic / Intent Breakdown | Which subagents are invoked most | Reveals unmet demand or over-routed topics |
| Session Duration | Average conversation length | Proxy for resolution complexity |
| Deflection Rate | Sessions resolved without human escalation | Headline ROI metric |
| Escalation Rate | Sessions handed off to human agents | **Primary quality signal in early adoption** |
| Sub-agent Invocations | Which subagents fire, and how often | Routing health and usage distribution |
| End-to-End Workflow Resolution | Full session success rate over rolling periods | Overall effectiveness benchmark |

#### Value-Based Analysis

The Escalation Rate is the single most important metric in the first 1-2 weeks after a production launch. When an agent launches, your test utterances, however carefully crafted, cannot perfectly represent the full diversity of how real users phrase their needs. The escalation rate is the first real-world feedback signal. A spike tells you that a category of user intent is not being handled — and it tells you this *before* users start complaining or abandoning the channel.

> **Rule of thumb:** Monitor escalation rate daily for the first two weeks. If it exceeds your baseline by more than 20%, open traces for the escalated sessions and look for a pattern. Most early spikes trace back to one or two instruction gaps or missing subagent coverage.

---

> ### Scenario 1: "Our Deflection Rate Looks Great, But Something Feels Off"
>
> A team launches an order-status agent. After two weeks, the analytics dashboard shows a 72% deflection rate, which leadership celebrates. But a customer success manager notices that users who "resolved" their session are still calling the support line about the same issues.
>
> The problem: The agent was marking sessions as "resolved" when it responded with any message, even generic fallback messages like "I cannot find your order, please contact support." Sessions that end without escalation are classified as deflected, even if the agent failed to actually help.
>
> The fix: The team queries `ssot__AiAgentInteractionStep__dlm` to find sessions with error steps, then cross-references those against sessions that did NOT escalate. They discover that 18% of "deflected" sessions actually ended in a graceful failure rather than genuine resolution. They add a custom `resolved` variable to their agent and filter the deflection metric to only count sessions where `@variables.resolved == True`.
>
> **Lesson:** Aggregate metrics tell you what happened. Trace-level data tells you why. Both layers are required for an accurate picture.

---

### Pillar II: Agent Optimization

**What it is:** Session-level and service-level tooling for deep inspection of individual conversations and back-end execution chains. This is where you go when you know something is wrong and need to find the exact cause.

**Why it exists:** The LLM is a black box at the surface level. The trace makes it a glass box. Agent Optimization is the toolset that lets you see exactly what the LLM saw, what it decided to do, what data it used, and whether its response was grounded. Platform Tracing extends this visibility into the back-end services that powered each LLM decision.

#### Custom Evaluations: LLM-as-a-Judge

Beyond manual trace review, Agent Optimization encompasses the development of **custom evaluations** that automate quality detection at scale. The most advanced pattern is **Semantic Conflict Detection**, which uses an LLM-as-a-Judge approach to scan conversation logs for:

- **Endless loops:** Repeated `LLMStep` patterns showing the agent asking the same question across multiple turns without resolving.
- **Contradictory assertions across subagents:** Subagent A tells the user their refund was approved; Subagent B later tells them it is pending. No single trace shows the contradiction — only cross-session analysis does.
- **Knowledge gaps:** Categories of user questions that consistently result in fallback responses, indicating missing coverage.

> **Roadmap note:** Semantic Conflict Detection via Custom Evals is on the Salesforce product roadmap. Today, this analysis must be built manually using Data Cloud queries against the STDM tables. Understanding the underlying data model now prepares you to use the native feature when it ships.

---

### Pillar III: Health Monitoring

**What it is:** Real-time alerting and platform health tracking built on top of the Einstein Trust Layer's fail-safe infrastructure.

**Why it exists:** Analytics dashboards show you what happened. Health monitoring tells you what is happening *right now*, so you can respond before a systemic issue affects thousands of users.

#### The Einstein Trust Layer

The Einstein Trust Layer is Salesforce's AI governance infrastructure. It enforces:

- **PII masking:** Strips personally identifiable information from prompts sent to LLMs.
- **Safety scoring:** Every agent response receives a safety score. Responses below threshold are blocked.
- **Audit trail:** Every LLM prompt and response is logged.
- **Fail-safe routing:** If the platform detects that an agent response would be harmful, unsafe, or ungrounded, it triggers a retry or a safe fallback.

#### Key Monitoring Alerts

| Alert Type | Trigger Condition | Why It Matters |
|---|---|---|
| Agent Rate Limit Errors | Org-level LLM rate limits hit | Users see delays or failures at peak load |
| Voice Agent Response Failures | TTS/STT pipeline errors | Voice channel users get silent failures |
| Planner Session Start Failures | Agent cannot initialize a session | Complete channel outage for affected users |
| LLM Model Latency | Response time exceeds threshold | Degrades UX, especially in voice (sub-2s target) |
| Agent Escalation Rates | >10 fallbacks per 5 minutes | Systemic instruction or routing failure |
| Error Volume | >25 errors per 5 minutes | Platform-level or integration issue |

Health monitoring should also track integration health: Flow execution timeouts, Apex callout failures, and Data Cloud indexing lag for knowledge-grounded agents.

---

> ### Scenario 2: Systemic Escalation Spike at Peak Hours
>
> A financial services firm deploys an employee agent for HR policy questions. During the first two weeks, the escalation rate is stable at 8%. Then, every Tuesday and Thursday between 9-11 AM, the escalation rate spikes to 35%.
>
> The health monitoring alert fires: >10 fallbacks per 5 minutes at 9:07 AM on Tuesday.
>
> The team investigates traces from that window and finds that all the failed sessions share a common `FunctionStep` error: the Apex action that queries HR policy records is timing out. Cross-checking the Apex logs, they see the SOQL query is running unselectively against a large SObject during a batch processing window that runs every Tuesday and Thursday morning.
>
> Without health monitoring, this would have been discovered only after users started complaining. With the alert, the team had a root cause within 20 minutes of the first failure.
>
> **Lesson:** Health monitoring is your early warning system. It does not replace trace analysis; it tells you *when* to start trace analysis.

---

## 4. Session Tracing vs. Agent Platform Tracing

One of the most important conceptual distinctions in Agentforce observability is understanding that two separate tracing systems exist, operating at different layers of the stack. Many practitioners conflate them, which leads to using the wrong tool for a given diagnosis.

| Feature | Agentforce Session Tracing | Agent Platform Tracing |
|---|---|---|
| **Level** | Planner (conversational) | Service (back-end execution) |
| **Captures** | User input, subagent routing, agent response, grounding results | LLM calls, Flow runs, Apex invocations, timing, errors, span attributes |
| **Primary DMO** | `ssot__AiAgentInteraction__dlm` | `ssot__TelemetryTraceSpan__dlm` |
| **Join Field** | `ssot__TelemetryTraceId__c` | `ssot__TelemetryTrace__c` |
| **Primary Use** | "What did the agent decide?" | "Why did it take that long? Where did it break?" |
| **Enabled By Default?** | Yes, with Data Cloud provisioned | No — requires manual toggle in Setup |

**The analogy:** Session Tracing is the conversation transcript. Platform Tracing is the execution log of every system call that powered each line of that transcript. You need both for complete observability.

**The join:** Because `ssot__TelemetryTraceId__c` on `ssot__AiAgentInteraction__dlm` matches `ssot__TelemetryTrace__c` on `ssot__TelemetryTraceSpan__dlm`, you can bridge from a specific interaction to the back-end execution chain that powered it in a single SOQL query.

**Full hierarchy:**

```
Session (ssot__AiAgentSession__dlm)
└── Interaction (ssot__AiAgentInteraction__dlm)
    └── Step (ssot__AiAgentInteractionStep__dlm)
        └── Span (ssot__TelemetryTraceSpan__dlm)
            └── Span (ssot__TelemetryTraceSpan__dlm)
                └── ...
```

---

## 5. Plan Tracer / Session-Level Debugging

### The Value Proposition of Tracing

The most important rule in Agentforce debugging is this:

> **Never trust the agent's text response as evidence that an action ran.**

The LLM will confidently paraphrase success even when no action was invoked. It will say "I've updated your account" even if the `FunctionStep` for the update action never appears in the trace. This is not a bug; it is an inherent property of language model generation. The trace is the only authoritative source of truth about what actually happened at the execution layer.

### Simulated vs. Live Preview Mode

| Mode | Flag | What Happens | When to Use |
|---|---|---|---|
| Simulated | `--simulate-actions` | LLM generates fake action outputs | Early development when backing code does not exist yet |
| Live | `--use-live-actions` | Real Apex/Flow/Prompt Templates execute | Any validation of real data, grounding, or variable-driven branching |

> **Critical:** Grounding failures in simulated mode may be false positives. The fake action outputs generated by the LLM do not match real data patterns. Switch to live mode before spending time diagnosing a grounding failure.

**CLI Workflow:**

```bash
# Step 1: Start a session (capture sessionId from JSON response)
sf agent preview start --json --authoring-bundle My_Agent --use-live-actions

# Step 2: Send utterances (keep session open for multi-turn testing)
sf agent preview send --json --authoring-bundle My_Agent \
  --session-id <SESSION_ID> -u "I need help with my order"

# Step 3: End session
sf agent preview end --json --authoring-bundle My_Agent --session-id <SESSION_ID>
```

> **Note:** Traces are written after every `send`, not just after `end`. You can read them mid-session.

---

### Trace File Anatomy

The per-turn trace file (`traces/<PLAN_ID>.json`) contains three sections:

1. **Top-level metadata:** `planId`, `sessionId`, `intent`, `subagent` (where routing landed).
2. **`plan` array:** The ordered list of execution steps — this is where all the diagnostic value lives.
3. **`raw` in transcript.jsonl:** Links each agent turn to its `planId`, which is the filename under `traces/`.

**How to connect a failing turn to its trace:**

```bash
# Find the planId for the failing turn
cat .sfdx/agents/My_Agent/sessions/<SESSION_ID>/transcript.jsonl | \
  grep '"role":"agent"' | tail -1 | jq '.raw[0].planId'

# Open the trace
cat .sfdx/agents/My_Agent/sessions/<SESSION_ID>/traces/<PLAN_ID>.json | jq '.'
```

---

### Step Types Reference

| Step Type | What It Tells You |
|---|---|
| `UserInputStep` | The exact utterance that triggered this turn |
| `SessionInitialStateStep` | Variable values and context at turn start |
| `NodeEntryStateStep` | Which subagent is executing and its full state snapshot |
| `VariableUpdateStep` | A variable changed; shows old value, new value, and reason |
| `BeforeReasoningIterationStep` | The `before_reasoning` block ran; lists which deterministic actions fired |
| `EnabledToolsStep` | Which actions were visible to the LLM; if an action is missing here, it cannot fire |
| `LLMStep` | The full LLM call: prompt sent, tools available, and the LLM's decision |
| `FunctionStep` | An action executed; shows inputs, outputs, and latency |
| `ReasoningStep` | Grounding check result: `GROUNDED` or `UNGROUNDED` with the specific reason |
| `TransitionStep` | Subagent routing occurred; shows source and target |
| `PlannerResponseStep` | The final response delivered to the user; includes safety scores |

---

### How to Read a Trace End-to-End

```
1. UserInputStep           <- What did the user say?
2. SessionInitialStateStep <- What was the variable state going in?
3. NodeEntryStateStep      <- Which subagent is handling this?
4. BeforeReasoningIterationStep <- Did any deterministic pre-processing fire?
5. EnabledToolsStep        <- What actions could the LLM choose from?
6. LLMStep                 <- What did the LLM see, and what did it decide?
7. FunctionStep            <- Did an action actually execute? What came back?
8. ReasoningStep           <- Did the response pass grounding?
9. TransitionStep          <- Did the agent move to a new subagent?
10. PlannerResponseStep    <- What did the user receive?
```

**Useful `jq` extraction commands:**

```bash
TRACE=".sfdx/agents/My_Agent/sessions/<SESSION_ID>/traces/<PLAN_ID>.json"

# Check subagent routing
jq '[.steps[] | select(.stepType == "TransitionStep") | .data.to]' "$TRACE"

# Check which actions fired
jq '[.steps[] | select(.stepType == "FunctionStep") | .data.function]' "$TRACE"

# Check grounding results
jq '[.steps[] | select(.stepType == "ReasoningStep") | .data.groundingAssessment]' "$TRACE"

# Check safety score
jq '.steps[] | select(.stepType == "PlannerResponseStep") | .data.safetyScore' "$TRACE"

# Check which tools were available to the LLM
jq '[.steps[] | select(.stepType == "EnabledToolsStep") | .data.enabled_tools]' "$TRACE"
```

---

### The LLMStep: Your Most Important Signal

The `LLMStep` is the single most diagnostic step in any trace. It contains:

- **`messages_sent`:** The complete prompt sent to the LLM — your Agent Script instructions, conversation history, variable interpolations, and platform-injected system prompts. If the agent is making a wrong decision, the root cause is almost always visible here.
- **`tools_sent`:** The action names available to the LLM for this reasoning cycle.
- **`response_messages`:** What the LLM decided to do: either a text response or a tool invocation.
- **`execution_latency`:** Milliseconds for the LLM call. Useful for diagnosing voice agent sub-2-second response window issues.

---

### Grounding: The Hidden Quality Gate

Grounding validates the agent's response against the actual data returned by actions.

**The retry flow:**

```
Agent calls action -> FunctionStep returns data
         |
         v
Agent generates a response using that data
         |
         v
Grounding checker compares response to FunctionStep output
         |
         v
     GROUNDED?
    /         \
  YES           NO
   |             |
   v             v
Deliver       Inject error message, give LLM a second attempt
response           |
                   v
              Still UNGROUNDED?
                   |
                   v
         "I apologize, but I encountered an unexpected error"
```

**Common grounding failure causes:**

| Cause | Example | Why It Fails |
|---|---|---|
| Date inference | Action returns `"2025-02-19"`, agent says `"today"` | Checker cannot infer relative date equals specific date |
| Unit conversion | Action returns `"48.5F"`, agent says `"about 50 degrees"` | Rounding not recognized as equivalent |
| Embellishment | Action returns temperature only, agent adds `"with a gentle breeze"` | Added detail not in action output |
| Loose paraphrasing | Agent restates facts in words that don't closely match the output | Semantic gap triggers UNGROUNDED |

**The fix pattern:**

```agentscript
# WRONG: permits paraphrasing and inference
reasoning:
    instructions: ->
        | Tell the user about the weather.

# CORRECT: instructs verbatim value usage
reasoning:
    instructions: ->
        | After getting weather results, respond using the exact date and temperature
          values returned by the action. Do NOT paraphrase dates (say "2025-02-19",
          not "today"). Do NOT round temperatures. Quote action output values verbatim.
```

---

### Testing Best Practices

#### Isolation-First Debugging

When diagnosing an action that is not behaving correctly, test the Flow or Prompt Template in isolation via Prompt Builder before testing it within the full agent execution path. The full path introduces routing decisions, variable state, instruction compilation, and LLM non-determinism as confounding variables.

#### Bi-Directional State Sync Validation

In multi-subagent architectures, verify that variables flow correctly in both directions:

1. **Superagent to subagent:** Variables set by the router must be available in the subagent's `NodeEntryStateStep`.
2. **Subagent back to superagent:** Variables updated by a subagent must appear in the superagent's `VariableUpdateStep` on re-entry.

#### Utterance Quality Requirements

| BAD (keyword-style) | GOOD (natural language) |
|---|---|
| `"cancel"` | `"I've been thinking about it and I want to cancel my subscription"` |
| `"order status"` | `"Can you look up where my package is? Order number is 12345"` |
| `"reset password"` | `"I can't log in, I think I forgot my password"` |

---

> ### Scenario 3: "The Agent Says It Worked But Nothing Changed"
>
> A developer is testing a case-creation agent. The agent responds: "I've created a support case for you. Your case number is CS-1042." The developer checks the Cases SObject and finds no new record.
>
> The developer opens the trace and searches for a `FunctionStep`. It does not exist. Instead, `LLMStep.response_messages` shows the LLM generated a text response without invoking any tool.
>
> Root cause: The action's `available when` guard requires `@variables.issue_description != ""`. The variable was never set because the instruction that populates it is in a different subagent that was bypassed. The action was silently invisible to the LLM.
>
> Fix: Relax the `available when` condition or add slot-filling logic so the action can collect the required data itself.
>
> **Lesson:** If the chat transcript says an action ran but no `FunctionStep` exists, the action never fired. The trace is ground truth. The LLM's response is not.

---

## 6. Agent Platform Tracing (Service-Level)

### How Trace Trees Work

Agent Platform Tracing captures every Agentforce action execution as an OpenTelemetry trace tree stored in Data 360. A single user utterance can trigger a cascade of downstream calls: LLM steps, Flow executions, Apex invocations, and external callouts. When you need to understand exactly what happened — a slow LLM step, a misfired flow, an Apex class that never returned — a top-level error message rarely tells the full story. Platform Tracing surfaces that chain as a **hierarchical tree** showing what happened, how long each step took, and exactly where the chain broke.

**Example trace tree (action executing a flow that errors):**

```
[OK]  run.interaction (96afcfefaa6fbfe9) -- 2,430ms
  [OK]  run.llmstep (9939b8bc33d12bfa) -- 167ms
    [OK]  run.topic.FlowAgentforce__FlowBuilderAutomationsTopic -- 3ms
      [OK]  run.llmstep (b3595456464fbe93) -- 1,341ms
        [ERROR] run.action.Get_Account_179SB000000v31B -- 481ms
          [OK]  run.invokeActions.FLOW -- 274ms [InvocableAction]
            [OK]  run.Get_Account.1 -- 266ms [Flow]
                  Attributes: flow.api.name=Get_Account
                              db.rows_affected=0
                              db.operation.name=query
          [OK]  run.llmstep (b4e5194e749ede24) -- 884ms
```

Notice what this reveals that a top-level error message would not: the Flow ran successfully (`OK`), it touched the database, and the query returned zero rows (`db.rows_affected=0`). The parent action errored because it expected data and received none — not because the flow itself broke. That distinction completely changes the remediation path.

### Value-Based Analysis

The key insight is that **the operation name on a span does not always describe what the operation actually did.** The span named `run.createrecord.account` in the example above is revealed by its attributes (`db.operation.name=query`) to actually be performing a lookup, not a write. Without span attributes, you would assume it was an insert failure. With them, you know it is a retrieval returning no results. Platform Tracing makes this level of precision available for every step in the chain.

---

### Key Fields on `ssot__TelemetryTraceSpan__dlm`

| Field | Description |
|---|---|
| `ssot__Id__c` | Unique span identifier (used for parent-child reconstruction) |
| `ssot__TelemetryParentSpanId__c` | Parent span ID; `null` or `0000000000000000` = root span |
| `ssot__TelemetryTrace__c` | The trace ID; links to `ssot__TelemetryTraceId__c` on `ssot__AiAgentInteraction__dlm` |
| `ssot__OperationName__c` | The type of operation (e.g., `run.llmstep`, `run.action.X`, `run.invokeActions.FLOW`) |
| `ssot__StatusCode__c` | `OK` or `ERROR` |
| `ssot__DurationNumber__c` | Duration in milliseconds |
| `ssot__StartDateTime__c` | When this span began |
| `ssot__EndDateTime__c` | When this span ended |
| `ssot__ServiceName__c` | The service that generated this span |
| `ssot__TelemetrySpanAttributeText__c` | Key-value attributes (e.g., `flow.api.name`, `db.rows_affected`, `db.operation.name`) |

**Tree reconstruction logic:** Match each span's `ssot__TelemetryParentSpanId__c` to another span's `ssot__Id__c`, treating `null` or `0000000000000000` as the root. This gives you the complete hierarchical execution tree client-side.

---

### SOQL for Performance Profiling

These queries are the core of a success architect's performance profiling toolkit.

**Profile performance by operation type (find consistently slow steps):**

```soql
SELECT ssot__OperationName__c,
       AVG(ssot__DurationNumber__c) AvgDuration,
       MAX(ssot__DurationNumber__c) MaxDuration,
       COUNT(Id) SpanCount
FROM ssot__TelemetryTraceSpan__dlm
WHERE ssot__StartDateTime__c > 2026-01-01T00:00:00Z
GROUP BY ssot__OperationName__c
ORDER BY AVG(ssot__DurationNumber__c) DESC
LIMIT 20
```

> This query is your first diagnostic step when a customer says "the agent feels slow." It shows you which operation types are consistently the bottleneck. An `AVG` of 1,800ms on `run.action.Get_Account` immediately focuses the investigation on that specific action.

**Find all recent error spans:**

```soql
SELECT ssot__Id__c, ssot__OperationName__c, ssot__TelemetryTrace__c,
       ssot__StartDateTime__c, ssot__DurationNumber__c, ssot__StatusCode__c
FROM ssot__TelemetryTraceSpan__dlm
WHERE ssot__StatusCode__c = 'ERROR'
ORDER BY ssot__StartDateTime__c DESC
LIMIT 20
```

**Count errors by operation type (identify most failure-prone steps):**

```soql
SELECT ssot__OperationName__c, COUNT(Id) SpanCount
FROM ssot__TelemetryTraceSpan__dlm
WHERE ssot__StatusCode__c = 'ERROR'
GROUP BY ssot__OperationName__c
ORDER BY COUNT(Id) DESC
LIMIT 20
```

**Reconstruct the full trace tree for a specific interaction:**

```soql
SELECT ssot__Id__c, ssot__OperationName__c, ssot__TelemetryParentSpanId__c,
       ssot__ServiceName__c, ssot__StatusCode__c, ssot__DurationNumber__c,
       ssot__StartDateTime__c, ssot__EndDateTime__c,
       ssot__TelemetrySpanAttributeText__c
FROM ssot__TelemetryTraceSpan__dlm
WHERE ssot__TelemetryTrace__c = 'YOUR_TRACE_ID'
ORDER BY ssot__StartDateTime__c ASC
```

---

### Joining Session Tracing and Platform Tracing

Joining both systems provides end-to-end visibility: conversational context from Session Tracing, back-end execution details from Platform Tracing.

**Get all Platform Tracing spans for a known interaction (from its Session Trace ID):**

```soql
-- Step 1: Get the TelemetryTraceId from the interaction
SELECT ssot__Id__c, ssot__TelemetryTraceId__c, ssot__UserInput__c
FROM ssot__AiAgentInteraction__dlm
WHERE ssot__AiAgentSession__c = 'YOUR_SESSION_ID'
LIMIT 10

-- Step 2: Use that TelemetryTraceId to pull all spans
SELECT ssot__Id__c, ssot__OperationName__c, ssot__TelemetryParentSpanId__c,
       ssot__StartDateTime__c, ssot__DurationNumber__c, ssot__StatusCode__c
FROM ssot__TelemetryTraceSpan__dlm
WHERE ssot__TelemetryTrace__c = 'TELEMETRY_TRACE_ID_FROM_STEP_1'
ORDER BY ssot__StartDateTime__c ASC
```

**STDM custom dashboard query: Deflection quality analysis**

Rather than counting all non-escalated sessions as "deflected," filter for sessions where the agent returned substantive data from an action.

Because SOQL does not support `JOIN`, `CASE WHEN` aggregates, or `DATEADD()`, this analysis requires two separate queries. Run them sequentially and combine the results client-side (e.g., in a Data Cloud custom dashboard, a Python script, or a Tableau calculated field).

**Step 1 — Pull session-level data for the last 14 days:**

```soql
SELECT Id, StartTime__c, EscalatedToHuman__c
FROM ssot__AiAgentSession__dlm
WHERE StartTime__c = LAST_N_DAYS:14
```

**Step 2 — Pull step-level error counts for the same window:**

```soql
SELECT SessionId__c, COUNT(Id) ErrorStepCount
FROM ssot__AiAgentInteractionStep__dlm
WHERE ErrorCount__c > 0
AND CreatedDate = LAST_N_DAYS:14
GROUP BY SessionId__c
```

**Client-side join logic (pseudocode):**
```
genuine_deflections = sessions where:
    - EscalatedToHuman__c == false
    - SessionId NOT present in error step results (or ErrorStepCount == 0)

quality_deflection_rate = COUNT(genuine_deflections) / COUNT(all_sessions) * 100
```

> **Why two queries?** SOQL is a single-object query language. It does not support cross-object `JOIN` syntax, `CASE WHEN` conditional aggregates, or SQL date functions like `DATEADD()` and `CURRENT_DATE`. Use `LAST_N_DAYS:14` for relative date filtering. For a fully automated deflection quality dashboard, implement this logic as a Data Cloud Data Transform or a scheduled Apex batch that materializes the combined result into a custom object or reporting snapshot.

---

### Slackbot Integration for Conversational Observability

Because Platform Tracing data lives in Data 360, it can be queried by any connected system — including Slackbot. The practical pattern is to wire SOQL query instructions into a Slack canvas and feed it to Slackbot, turning trace analysis into a natural language conversation.

**Why this matters for enterprise customers:** Ops teams and support managers are not SOQL experts. When a user complains that "the agent was slow," a Slack-based interface lets a non-technical team member ask the question and receive a structured trace tree in response, without waiting for a developer to run queries.

**Example Slackbot exchange:**

```
You:      Why did interaction b9e8f7b4 take 4 seconds?

Slackbot: I queried all spans for trace b9e8f7b4. Total duration: 2,690ms.
          Breakdown:

          run.interaction           2,690ms  OK
            run.llmstep               139ms  OK
              run.topic                 3ms  OK
                run.llmstep           838ms  OK
                  run.action          327ms  OK
                    run.llmstep     1,011ms  OK  <- bottleneck (38% of total)

          The bottleneck is the final run.llmstep span, accounting for
          38% of total duration. The action itself was fast (327ms);
          the LLM reasoning after it was slow.
```

**Useful natural language queries for Slackbot:**

- "Why did this agent interaction take 4 seconds?"
- "Which subagent is responsible for the most errors this week?"
- "What are the most common errors for a given operation type?"
- "Show me the full trace tree for interaction ID X."

**Setup requirement:** Slackbot must be connected to an org with Agent Platform Tracing enabled. Provide Slackbot with the DMO schemas, sample SOQL patterns, and join patterns via a Slack canvas at the start of each diagnostic conversation.

---

> ### Scenario 4: Latency Complaint with No Obvious Surface Cause
>
> A customer reports that their claims-processing agent "takes forever to respond." The OOTB dashboard shows average session duration elevated but no escalation spike and no error alerts. The Session Tracing logs show that the `FunctionStep` for `Get_Policy_Details` completed successfully.
>
> A Success Architect enables Agent Platform Tracing (it was toggled off), then runs the performance profiling query after the next morning's usage. The results show that `run.action.Get_Policy_Details` has an `AVG` duration of 3,200ms and a `MAX` of 8,100ms. Drilling into the span attributes reveals `db.rows_affected=2,847` — the action is returning nearly 3,000 records from an unfiltered policy query.
>
> The fix: The Apex class behind the action is querying without a `LIMIT` clause and without a selective `WHERE` filter. The action returns the full dataset and then the LLM tries to process it. Adding `LIMIT 1` with the correct WHERE clause reduces the action duration from 3,200ms average to 180ms.
>
> **Lesson:** Session Tracing told the architect that `Get_Policy_Details` ran. Platform Tracing told them *how* it ran, including how many rows it touched. Without span attributes, the root cause is invisible.

---

## 7. MCP Actions: How Observability Changes

When an agent relies on **Model Context Protocol (MCP)** for external actions rather than native Salesforce actions (Apex or Flow), the observability model changes in three important ways.

### What MCP Actions Are

MCP servers are registered via `sf agent mcp create` and their whitelisted tools appear as callable actions in the agent, routed via the `api://` or `externalService://` target protocol. From the agent's perspective, they are invocable just like Apex actions. But the execution chain is different: instead of a Salesforce-managed invocation, the call goes to an external HTTP endpoint.

### How Tracing Behaves with MCP

| Layer | Native Apex/Flow | MCP External Action |
|---|---|---|
| `FunctionStep` in session trace | Full input, output, and latency | Action invocation recorded, but output detail depends on MCP server logging |
| Platform Tracing span | Full span with `db.*` attributes, Flow steps, and Apex context | Spans recorded to the HTTP boundary only; internal MCP server execution is opaque |
| Error attribution | Platform owns the full stack; errors are attributable to specific Apex lines or Flow elements | Errors at or inside the MCP server are external; you see the HTTP response code, not the internal cause |
| Latency attribution | `ssot__DurationNumber__c` covers full Apex/Flow execution | `ssot__DurationNumber__c` covers the full round-trip HTTP call, including network latency and MCP server processing time |

### Diagnosing MCP Integration Latency

Because Platform Tracing cannot see inside an external MCP server, latency profiling for MCP actions requires a two-part approach:

1. **Measure the HTTP boundary:** Query `ssot__TelemetryTraceSpan__dlm` for spans with `ssot__OperationName__c` matching your MCP action name. `ssot__DurationNumber__c` gives you the full round-trip time, including network and external processing.
2. **Distinguish network from server processing:** If the MCP server has its own instrumentation (e.g., OpenTelemetry on the server side), compare the server-side logged duration against the span duration. The delta is network latency. Without server-side instrumentation, the span duration is an upper bound, not a precise internal breakdown.

### Identification Pattern

When reviewing a trace tree and you see a span pattern like this:

```
[OK]  run.action.My_MCP_Action -- 1,847ms
  [OK]  run.invokeActions.EXTERNAL_SERVICE -- 1,839ms
```

The absence of child spans under `EXTERNAL_SERVICE` (where a Flow action would show `run.Flow.1` with `db.*` attributes) is the telltale sign that this is an external call. The platform tracing tree stops at the HTTP boundary.

### Practical Implication for Success Architects

When helping a customer diagnose a slow MCP-backed agent:

1. Confirm the latency source is the MCP action span (not an LLM step or routing overhead) using the performance profiling query in Section 6.
2. If the span duration is consistently high, ask the customer to check their MCP server's own response time logs to separate network latency from server processing time.
3. For chained MCP callouts (one action triggering two or more HTTP hops), each hop compounds at p95. Two hops at 400ms each means your p95 easily exceeds 1,600ms — which is the sub-2-second voice agent threshold. Flag this as an architectural concern requiring human review.

---

## 8. Dashboards and Metrics to Know Cold

### Out-of-the-Box Panels

Salesforce provides three OOTB dashboard surfaces. Know which questions each one answers.

#### Agentforce Analytics Dashboard

| Panel | Metric | Early-Adoption Significance |
|---|---|---|
| Conversation Volume | Sessions per day/week | Adoption curve; validates channel awareness |
| Topic / Intent Breakdown | Most-invoked subagents | Reveals demand patterns, mis-routing |
| Session Duration | Average turn count and time | Long sessions may indicate instruction loops |
| Escalation Rate | % of sessions escalated | **Primary quality signal in weeks 1-2** |
| Deflection Rate | % resolved without human | Headline ROI metric |
| Sub-agent Invocation Count | Per-subagent invocation trends | Routing health, coverage gaps |

#### Consumption Analytics Dashboard (Tableau Next)

| Panel | Metric | Operational Value |
|---|---|---|
| Daily Active Users | Users per agent per day | Growth tracking |
| Input vs. Output Token Breakdown | Token split by direction | Cost optimization signal |
| Token Usage by User | Heaviest consumers | Identify power users or anomalies |
| Usage by Agent | Agent-level consumption | Budget attribution |

#### Consumption Insights Dashboard (Data 360 Reporting)

Provides more granular consumption data including per-feature and per-model token breakdowns, useful for teams managing Einstein credit budgets across multiple AI products.

---

### Data Cloud STDM Tables

When OOTB dashboards are insufficient, custom analytics are built directly on Data Cloud's Session Tracing Data Model (STDM) tables.

#### Core STDM Tables

| DMO Table | What It Contains | Common Use Cases |
|---|---|---|
| `ssot__AiAgentSession__dlm` | Session-level data (start, end, session ID) | Session volume, duration, success rate analysis |
| `ssot__AiAgentInteraction__dlm` | Interaction metadata (intent, subagent, resolution status, TelemetryTraceId) | Intent distribution, routing analysis, Platform Tracing join |
| `ssot__AiAgentInteractionMessage__dlm` | User and agent messages | Conversation content analysis, stuck-session detection |
| `ssot__AiAgentInteractionStep__dlm` | Action steps with error tracking | Action failure rate, error categorization |
| `ssot__AiAgentSessionParticipant__dlm` | Agent participation in sessions | Multi-subagent usage analysis |
| `AiAgentGenerativeAiUsage_std__dlm` | Token usage per session | Credit consumption attribution |
| `ssot__TelemetryTraceSpan__dlm` | Back-end execution spans (Platform Tracing) | Latency profiling, error attribution, trace tree reconstruction |

#### Einstein Trust Layer Audit Trail DMOs

These tables populate only when the Audit Trail data streams are explicitly enabled in Einstein Trust Layer settings.

| DMO Table | What It Contains |
|---|---|
| `GenAIGatewayRequest__dlm` | The compiled prompt sent to the LLM gateway |
| `GenAIGatewayResponse__dlm` | The LLM's raw response |
| `GenAIGeneration__dlm` | Generation metadata per LLM call |
| `GenAIFeedback__dlm` | User feedback (thumbs up/down) on agent responses |

> **Important distinction:** `GenAIGatewayRequest__dlm` captures the compiled Agent Script prompt, not the user's raw utterance. For user utterances, query `ssot__AiAgentInteractionMessage__dlm` where `role = 'user'`.

---

### Proactive Monitoring Alerts

| Alert | Default Threshold | Interpretation |
|---|---|---|
| Agent Rate Limit Errors | Configurable | Org-level LLM capacity exhaustion; scale or throttle |
| Voice Agent Response Failures | Any spike | Voice channel SLA breach; check TTS/STT pipeline |
| Planner Session Start Failures | Any sustained rate | Complete channel outage; escalate to Salesforce support |
| LLM Model Latency | Threshold breach | Especially critical for voice (sub-2s target) |
| Agent Escalation Rate | >10 fallbacks per 5 minutes | Systemic instruction or routing failure; begin trace review |
| Error Volume | >25 errors per 5 minutes | Platform or integration-level issue; check Apex/Flow health |

---

> ### Scenario 5: Building a "Stuck Session" Detection Dashboard
>
> A large retailer deploys a returns-and-refunds agent. Their OOTB dashboard shows escalation rates within normal range, but support team members report that users sometimes seem "stuck" — repeating the same phrases multiple times before the agent helps them.
>
> The OOTB dashboard does not surface this. The team builds a custom query against `ssot__AiAgentInteractionMessage__dlm` that counts sessions where the same user message appears more than twice within the same session. They surface this as a "Stuck Session Rate" panel in a custom Tableau dashboard.
>
> Within a week, they identify that 6% of sessions show this pattern, and 80% of those stuck sessions involve a specific return eligibility subagent. Opening traces from those sessions reveals a behavioral loop caused by an instruction that re-asks for the order number even when the user has already provided it.
>
> **Lesson:** The OOTB dashboards are your starting point. The STDM tables are your excavation tools. The most valuable insights almost always require custom queries.

---

## 9. Common Diagnostic Patterns

Each pattern follows: **Symptom > Trace Location > Root Cause > Fix Direction**.

### Pattern A: Wrong Subagent Routing

**Symptom:** User asks about Topic X but the agent routes to Subagent Y.

**Trace location:** `LLMStep` where `agent_name` matches the router. Check `tools_sent` to confirm all transition actions are listed.

**Root cause:** Subagent descriptions are ambiguous or overlap between topics.

**Fix direction:** Add disambiguation language to subagent descriptions. Use exclusion phrasing.

### Pattern B: Action Not Firing

**Symptom:** The agent calls an action but responds without invoking it.

**Trace location:** `EnabledToolsStep` — is the action listed? If not, check `available when` conditions against `NodeEntryStateStep` variable values.

**Root cause (missing from tools):** `available when` guard references a variable that has not been set yet.

**Root cause (listed but not called):** The action description does not match the user's phrasing closely enough.

**Fix direction:** Relax `available when` conditions. Strengthen action `description:` with trigger keywords derived from real user phrasing.

### Pattern C: Behavioral Loop

**Symptom:** Agent asks the same question across multiple turns despite the user having answered it.

**Trace location:** Repeated `LLMStep` patterns across turns where `messages_sent` shows the instruction "if you do not know X, ask" firing even though X appears in conversation history.

**Root cause:** Instructions check a variable rather than conversation history. When the variable is not explicitly set, the condition always triggers.

**Fix direction:** Rewrite instructions to use conversation history as the source of truth and slot-fill with `...` rather than checking an intermediate variable.

### Pattern D: "Unexpected" Response

**Symptom:** Agent responds with "I apologize, but I encountered an unexpected error."

**Trace location:** Consecutive `ReasoningStep` entries both showing `UNGROUNDED`. Two consecutive ungrounded results trigger this terminal error.

**Root cause:** Grounding failed twice. Either the agent embellished data, paraphrased too loosely, or the action returned an error with no data to ground against.

**Fix direction:** See grounding fix patterns in Section 5. If action errors are the cause, verify the backing Apex/Flow handles edge cases without throwing exceptions.

### Pattern E: Action Returns Data But Agent Ignores It

**Symptom:** `FunctionStep` shows a successful response with data, but the agent's reply is generic.

**Trace location:** The `LLMStep` after the `FunctionStep`. Check `response_messages` for whether the LLM invoked a platform tool instead of composing a text reply.

**Fix direction:** Update instructions to name specific output fields the agent should include in its reply.

### Pattern F: Platform Tracing Shows Slow Action But Session Trace Shows Success

**Symptom:** Users report latency. Session traces show `FunctionStep` completed with a result. No errors. But something is slow.

**Trace location:** Platform Tracing — query `ssot__TelemetryTraceSpan__dlm` filtered by operation name, check `ssot__DurationNumber__c` and `ssot__TelemetrySpanAttributeText__c`.

**Root cause:** The action ran successfully but returned too much data (e.g., `db.rows_affected=2,847`), causing downstream LLM processing to slow down. The session trace records success; only the span attributes reveal the volume problem.

**Fix direction:** Add `LIMIT` clauses and selective `WHERE` filters to the backing Apex or Flow query. Summarize large datasets before returning them to the agent.

---

### Fix Strategy Quick Reference

| Symptom | Target Block | Edit Strategy |
|---|---|---|
| Subagent not matched | `subagent X: description:` | Add trigger keywords from test utterance |
| Action not invoked | `reasoning.actions: X description:` | Make description trigger-specific |
| Action blocked by guard | `available when:` | Relax or remove overly restrictive condition |
| Two actions overlap | Both `description:` fields | Add exclusion language to each |
| Ungrounded response | `reasoning: instructions: ->` | Add explicit references with `{!@variables.X}` |
| Low safety score | `system: instructions:` | Add safety guidelines and scope boundaries |
| Tool not visible | `available when:` | Ensure guard matches variable state at test time |
| Slow action (latency) | Apex/Flow backing implementation | Add LIMIT, selective WHERE, summarize large outputs |

---

## 10. Sandbox vs. Production Tracing

Success Architects need to guide customers through the full deployment lifecycle, and the observability configuration differs meaningfully between sandbox and production environments.

### Key Differences

| Dimension | Sandbox | Production |
|---|---|---|
| **Primary tracing tool** | `sf agent preview` CLI with local `.sfdx/` trace files | Data Cloud STDM tables and Agent Platform Tracing DMOs |
| **Platform Tracing toggle** | Must be enabled per org — does not inherit from production | Must be enabled separately; treat as a separate configuration |
| **Data retention** | Preview trace files are local and ephemeral | STDM and Platform Tracing data persists in Data Cloud for the configured retention window |
| **Utterance quality** | Can use test utterances that represent expected patterns | Real users; full diversity of phrasing; no control over input |
| **Alert thresholds** | Not typically configured — sandbox is not a monitored channel | Configure all alert thresholds before go-live |
| **Credit consumption** | Every `FunctionStep` still costs credits in sandbox (except simulated mode) | Full production credit costs apply |
| **Data volume** | Low; small number of sessions makes manual trace review practical | High; aggregate dashboards and SOQL queries become the primary diagnostic surface |

### Deploying Tracing Configuration via Metadata

Agent Platform Tracing is toggled via the `AgentforcePlatformTracingSettings` custom metadata type. This means it can be deployed as part of a metadata package rather than configured manually in each target org.

```xml
<!-- AgentforcePlatformTracingSettings.md-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<AgentforcePlatformTracingSettings xmlns="http://soap.sforce.com/2006/04/metadata">
    <masterLabel>AgentforcePlatformTracingSettings</masterLabel>
    <isEnabled>true</isEnabled>
</AgentforcePlatformTracingSettings>
```

Deploy this in the same pipeline stage as your agent metadata. This ensures that Platform Tracing is always enabled in production environments without relying on manual Setup UI steps that may be missed during go-live.

### Transition from Sandbox to Production Monitoring

When a customer promotes an agent from sandbox to production:

1. **Verify Platform Tracing is enabled in production** — confirm the metadata deployment succeeded or the toggle is on in Setup.
2. **Confirm Data Cloud DMOs are accessible** — run the `DataKnowledgeSpace` query and verify that `GenieAdmin` is assigned to admins who need to work with Data Cloud configuration. If DMO query access is not functioning with `GenieAdmin` alone, also verify `CopilotSalesforceAdmin` is assigned, as monitoring access flows through that permset.
3. **Seed baseline metrics in the first 48 hours** — dashboards need traffic to establish a baseline before alerts can be calibrated.
4. **Configure alert thresholds before launch** — escalation rate alerts should be set relative to your expected volume, not the default absolute thresholds designed for high-volume orgs.
5. **Switch from CLI trace review to SOQL** — the sandbox workflow of opening individual `.sfdx/` trace files does not scale to production volumes. Teach the customer team the STDM query patterns in Section 6 before go-live.

---

## 11. Mapping Observability to Business KPIs

One of the most valuable things a Success Architect does is translate technical metrics into the language of business outcomes. This section provides the mappings that help customer leadership understand why observability investment matters.

### The KPI Translation Table

| Technical Metric | Source | Business KPI | Business Area |
|---|---|---|---|
| Deflection Rate | `ssot__AiAgentSession__dlm` | Cost-per-interaction reduction | Customer Service Operations |
| Escalation Rate | Agentforce Analytics Dashboard | Agent quality and trust | CX Leadership / Customer Success |
| `ssot__DurationNumber__c` on action spans | `ssot__TelemetryTraceSpan__dlm` | Time-to-resolution; user experience quality | Service Operations / IT Ops |
| Error volume by operation type | `ssot__TelemetryTraceSpan__dlm` | IT ops efficiency; MTTR (mean time to resolve) | IT Operations |
| Token usage per session | `AiAgentGenerativeAiUsage_std__dlm` | AI cost-per-transaction | Finance / AI Budget Owners |
| Safety score distribution | `PlannerResponseStep.safetyScore` | Brand risk and compliance posture | Legal / Compliance |
| User feedback rating | `GenAIFeedback__dlm` | NPS / user satisfaction | CX Leadership |
| Stuck session rate (custom) | `ssot__AiAgentInteractionMessage__dlm` | Conversation quality; intent coverage gaps | Product / Agent Design |

### Making the ROI Case with Observability Data

A common executive ask is: "How do we know this agent is actually saving us money?" The answer lives in STDM data.

**Step 1: Establish the cost-per-interaction baseline (before agent).**
Query historical case volume and average handle time to determine the human cost per interaction in the category the agent covers.

**Step 2: Measure genuine deflection rate (not raw deflection).**
Use the quality-corrected deflection query from Section 8 to get the true resolution rate — sessions where an action ran and the user did not escalate.

**Step 3: Calculate cost avoidance.**

```
Cost Avoidance = Genuine Deflections x (Human Cost Per Interaction - AI Credit Cost Per Session)
```

**Step 4: Surface latency reduction as efficiency gain.**

Query `AVG(ssot__DurationNumber__c)` for your primary action spans pre-optimization and post-optimization. A reduction from 3,200ms to 180ms on a high-volume action translates directly to faster time-to-resolution for users, and fewer "slow agent" escalations — which are themselves a hidden cost.

**Step 5: Tie error trends to IT ops efficiency.**

Track `COUNT(Id)` on error spans by operation type over time. Each spike corresponds to a support incident. The trend line shows whether agent reliability is improving — which is a direct input to MTTR reporting.

### Connecting Latency to Cost-Per-Interaction

`ssot__DurationNumber__c` is not just a performance metric. It is a cost driver. Every millisecond of excess latency in a voice agent risks a user abandonment or escalation. In a customer service context, an abandoned interaction that escalates to a human agent costs 5-20x more than a deflected one. Success Architects can quantify this by:

1. Pulling the distribution of `ssot__DurationNumber__c` for the primary interaction span.
2. Identifying sessions above the 2,000ms threshold (the voice agent sub-2s boundary).
3. Cross-referencing those sessions against escalation status in `ssot__AiAgentSession__dlm`.
4. Calculating what percentage of above-threshold sessions escalated vs. resolved.

If the correlation is strong, each 100ms reduction in average interaction duration translates to a measurable decrease in escalation rate — and a corresponding decrease in cost.

---

> ### Scenario 6: Proving ROI to a Skeptical VP
>
> Three months after go-live, the VP of Service Operations asks: "We're spending six figures on Agentforce credits. How do we know this is worth it?"
>
> The Success Architect runs three queries:
>
> 1. `ssot__AiAgentSession__dlm` for genuine deflection rate (42% of sessions resolved with no escalation and at least one successful action execution).
> 2. `AiAgentGenerativeAiUsage_std__dlm` for average credit cost per session (23 credits average, approximately $0.46 at list price).
> 3. Historical data from the customer's CRM showing their pre-agent average handle time for the same interaction category ($12.50 per interaction with a human agent).
>
> The math: 42% deflection on 50,000 monthly sessions = 21,000 avoided human interactions. At $12.50 per avoided interaction minus $0.46 AI cost: approximately $252,000 in monthly cost avoidance.
>
> The additional finding: 14% of non-escalated sessions had error spans with `db.rows_affected=0` — indicating graceful failures. Fixing those would push genuine deflection from 42% to approximately 56%, adding another ~$84,000/month in cost avoidance.
>
> **Lesson:** Observability data does not just help you debug. It makes the business case for continued investment, and it shows exactly where to focus optimization effort to maximize that case.

---

## 12. Credit Consumption and Observability Cost Awareness

### Credit Consumption Table

| Operation | Credits | Notes |
|---|---|---|
| `@utils.transition` | FREE | Framework navigation |
| `@utils.setVariables` | FREE | Framework state management |
| `@utils.escalate` | FREE | Framework escalation |
| `if`/`else` control flow | FREE | Deterministic resolution, no LLM call |
| `before_reasoning` / `after_reasoning` | FREE | Deterministic pre/post-processing |
| LLM reasoning turn | FREE | The reasoning step itself is not billed |
| Prompt Templates | Billed separately via Prompt Usage | Not Flex Credits per call. Billed by LLM gateway calls and token consumption (per 2,000 tokens, rounded up). Rate varies by model tier. See Flex Credits Billable Usage Types documentation for current model-tier pricing. |
| Flow actions | 20 credits | Per action execution |
| Apex actions | 20 credits | Per action execution |
| Any other action | 20 credits | Per action execution |

### Cost-Aware Debugging Practices

Every `FunctionStep` in a trace represents a credit expenditure. A session with 5 action invocations costs 100 credits. Use simulated preview mode for instruction and routing iteration (no credits for fake outputs), and reserve live preview for grounding validation and final behavioral testing.

An escalation spike alert firing at ">10 fallbacks per 5 minutes" is not just a user experience problem. If the fallback path involves action retries, it also represents unplanned credit consumption at scale. Cost anomaly detection is a secondary benefit of tight escalation monitoring.

Actions that exceed CPU time limits, SOQL row limits, or heap size limits surface as `FunctionStep` errors in traces — and in production, they represent 20 credits spent per failed action call.

---

## 13. Roadmap Awareness: Setting Stakeholder Expectations

### Currently Available (as of August 2026)

- OOTB Tableau Next dashboards for consumption and agent analytics.
- Session-level trace files via `sf agent preview` CLI.
- Agent Platform Tracing via `ssot__TelemetryTraceSpan__dlm` (requires manual enablement).
- Data Cloud STDM tables for custom query-based dashboards.
- Einstein Trust Layer audit trail DMOs (when enabled).
- Safety scoring on every agent response via `PlannerResponseStep.safetyScore`.
- Slackbot integration for natural language trace queries (requires manual canvas setup).

### On the Product Roadmap

| Feature | Description | Current Workaround |
|---|---|---|
| Error Rate Metric Splitting | Break down errors by category: orchestration, handoff failures, auth issues, timeouts | Query `ssot__AiAgentInteractionStep__dlm` and categorize manually |
| Latency Split Tracking | Show end-to-end time split by component: orchestration overhead vs. subagent execution | Extract `ssot__DurationNumber__c` from `ssot__TelemetryTraceSpan__dlm` spans manually |
| Custom Evaluations (Semantic Conflict Detection) | Native LLM-as-a-Judge to scan logs for loops and cross-subagent contradictions | Build custom queries against STDM tables with manual pattern detection |
| Spend / Consumption in Agent Analytics | Credit consumption reporting within the agent analytics dashboard | Cross-reference `AiAgentGenerativeAiUsage_std__dlm` with session data manually |
| Sentiment Analysis | Inferred user sentiment per session based on message content | Not currently available without a custom external pipeline |
| RAG Quality Metrics | Hit rate, relevance, and citation accuracy for knowledge-grounded agents | Manual inspection via `ReasoningStep` grounding results in traces |

### Safe Framing for Stakeholder Conversations

> "Today, we can monitor escalation rates, session volume, and action-level errors in near real-time using built-in dashboards and Data Cloud tables. We can dig into any individual session with full execution traces, and we can profile back-end performance down to individual Apex and Flow invocations using Agent Platform Tracing. Granular error categorization and latency split reporting by subagent are on the roadmap, and we can build approximations of those today using custom queries while native support arrives."

---

## 14. Quick-Reference Cheat Sheet

### The Observability Decision Tree

```
Something is wrong with my agent
           |
           v
Is it affecting many users simultaneously?
    YES -> Check Health Monitoring alerts first
     NO -> Is there a reproducible test case?
              YES -> Run sf agent preview and read the session trace
               NO -> Query STDM tables to find similar session patterns,
                     then reproduce with a representative utterance
                         |
                         v
                     Found the session but need more execution detail?
                     Enable Agent Platform Tracing and query
                     ssot__TelemetryTraceSpan__dlm for the trace ID
```

### Trace Reading Checklist (Per Turn)

- [ ] `UserInputStep` — Confirm the utterance matches expectation.
- [ ] `NodeEntryStateStep` — Confirm the correct subagent was entered.
- [ ] `EnabledToolsStep` — Confirm the expected action is listed.
- [ ] `LLMStep.messages_sent` — Confirm instructions compiled correctly and variables interpolated.
- [ ] `FunctionStep` — Confirm the action fired and check its inputs/outputs.
- [ ] `ReasoningStep` — Confirm `GROUNDED` status.
- [ ] `PlannerResponseStep` — Confirm `safetyScore.overall >= 0.9`.

### Key DMO Tables at a Glance

| Question | Table to Query |
|---|---|
| How many sessions today? | `ssot__AiAgentSession__dlm` |
| What actions errored? | `ssot__AiAgentInteractionStep__dlm` |
| What did users say? | `ssot__AiAgentInteractionMessage__dlm` |
| Which agents/subagents did users invoke? | `ssot__AiAgentInteraction__dlm` |
| How many tokens consumed? | `AiAgentGenerativeAiUsage_std__dlm` |
| What did the LLM receive in its prompt? | `GenAIGatewayRequest__dlm` |
| What did users rate as helpful? | `GenAIFeedback__dlm` |
| Which steps took the longest? | `ssot__TelemetryTraceSpan__dlm` (Platform Tracing) |
| Where exactly did an action break? | `ssot__TelemetryTraceSpan__dlm` filtered by `ssot__StatusCode__c = 'ERROR'` |

### Infrastructure Readiness Checklist (Per New Org)

- [ ] Data Cloud provisioned and active (`DataKnowledgeSpace` query succeeds).
- [ ] `CopilotSalesforceAdmin` permission set assigned to admin user.
- [ ] `GenieAdmin` permission set assigned to admin user.
- [ ] `GenieAdmin` assigned to any admin who will work with Data Cloud configuration or query DMO tables.
- [ ] `AgentforceServiceAgentBuilder` assigned to admins whose primary role is service agent configuration (if distinct from the `CopilotSalesforceAdmin` holder).
- [ ] `AgentforceDeveloperAndAdminTools` assigned to developers — verify purpose in your org before go-live.
- [ ] Agent Platform Tracing toggled on in Setup > Agent Platform Tracing.
- [ ] Einstein Trust Layer Audit Trail data streams enabled (if compliance logging required).
- [ ] Alert thresholds configured before production go-live.

### Escalation Rate Alert Response Playbook

```
Alert: >10 fallbacks per 5 minutes
    |
    v
Step 1: Note the time window.
Step 2: Filter STDM tables to sessions in that window.
Step 3: Find common subagent or action patterns in escalated sessions.
Step 4: Pull 3-5 trace files from escalated sessions.
Step 5: Identify the first step where behavior diverged from expectation.
Step 6: Apply the appropriate fix pattern (Section 9).
Step 7: Test with preview and deploy fix.
Step 8: Monitor escalation rate for 30 minutes post-fix.
```
