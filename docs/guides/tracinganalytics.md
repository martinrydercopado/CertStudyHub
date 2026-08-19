# Tracing and Analytics in Agentforce

**Audience:** Success Architects  
**Purpose:** Enable Success Architects to help customers design, build, troubleshoot, and continuously improve Agentforce agents using Salesforce's native observability tooling.

---

## Contents

1. [Why Observability Matters](#1-why-observability-matters)
2. [Prerequisites and Infrastructure Setup](#2-prerequisites-and-infrastructure-setup)
3. [The Three Pillars of Agentforce Observability](#3-the-three-pillars-of-agentforce-observability)
4. [Session Tracing vs. Agent Platform Tracing](#4-session-tracing-vs-agent-platform-tracing)
5. [Reading Session Traces](#5-reading-session-traces)
6. [Agent Platform Tracing: Service-Level Visibility](#6-agent-platform-tracing-service-level-visibility)
7. [Dashboards and the Data Model](#7-dashboards-and-the-data-model)
8. [Common Diagnostic Patterns](#8-common-diagnostic-patterns)
9. [Sandbox vs. Production Tracing](#9-sandbox-vs-production-tracing)
10. [Mapping Observability to Business KPIs](#10-mapping-observability-to-business-kpis)
11. [Credit Consumption Awareness](#11-credit-consumption-awareness)
12. [Quick-Reference Cheat Sheet](#12-quick-reference-cheat-sheet)

---

## 1. Why Observability Matters

An Agentforce agent is a probabilistic system. Unlike a deterministic Flow or Apex trigger, an agent reasons, makes decisions, and produces outputs that are not fully predictable at design time. That is exactly what makes agents powerful. It is also what makes observability non-negotiable.

**Without observability, you cannot answer the questions that matter:**

- Why did the agent escalate that session?
- Why is the deflection rate lower than expected?
- Why does the agent respond slowly in the afternoons?
- Is the agent actually resolving issues, or just deflecting them?
- Which knowledge gaps are causing the most user frustration?

**The business stakes are real.** Agentforce agents frequently handle customer-facing interactions at scale. A misconfigured instruction, a failing action, or a knowledge gap can affect thousands of sessions before anyone notices — unless monitoring catches it first. Observability converts that reactive fire-fighting into a proactive, data-driven improvement loop.

For a Success Architect, observability is also a trust-building tool. Customers who can see exactly what their agent is doing, exactly how it is performing, and exactly where it needs improvement are customers who invest in the platform long-term.

---

## 2. Prerequisites and Infrastructure Setup

Agentforce observability depends on a stack of capabilities that must be explicitly enabled. None of them are on by default. Before advising a customer on tracing or analytics, confirm this infrastructure is in place.

### Required Foundation

- **Data Cloud (Data 360) provisioned** with the CRM Connector active. All session data, optimization data, and platform tracing data live in Data Cloud. Without it, none of the DMOs exist.
- **Agentforce enabled** in the org with at least one deployed agent generating sessions.
- **Appropriate permissions assigned** to admin and developer users:
  - `CopilotSalesforceAdmin` — for admin users managing agent configuration
  - `GenieAdmin` — for users who need Data Cloud query access
  - `AgentforceServiceAgentBuilder` — for service agent configuration admins
  - `AgentforceDeveloperAndAdminTools` — for developers (verify purpose per org before assigning)

### Step 1: Enable Session Tracing and Agentforce Optimization

**Path:** Setup > Einstein Audit, Analytics, and Monitoring Setup

This single setup page actually controls two related but distinct capabilities. Both must be enabled:

- **Agentforce Session Tracing and Data Model** — provisions the STDM DMOs and begins capturing session data. This is the foundation for everything in Pillar I (Analytics) and Pillar II (Optimization). Without this toggle, no session data flows into Data Cloud.
- **Agentforce Optimization** — enables the Optimization pipeline that processes sessions into Moments, scores quality, and surfaces clustered insights. This requires Session Tracing to be enabled first.

> **Timing note:** Session Tracing begins collecting data immediately after enablement. Optimization results, however, require pipeline runs (see Pillar II for timing details). Do not promise customers "instant" Optimization insights.

### Step 2: Enable Audit and Feedback

**Path:** Setup > Einstein Audit, Analytics, and Monitoring Setup > Audit and Feedback toggle

This is a separate opt-in from Session Tracing and must be enabled explicitly. It controls the storage of:

- **Generative AI Audit Data:** PII-masked prompt text, hydrated prompt text, LLM response text, response safety scores, and LLM model details — stored in `GenAIGatewayRequest__dlm` and `GenAIGeneration__dlm`.
- **Feedback Data:** Thumbs-up/thumbs-down ratings, reason text, and response acceptance signals — stored in `GenAIFeedback__dlm`.

When enabling Audit and Feedback, the admin must also select a **target data space** if the org has multiple data spaces. The pre-built Einstein Gen AI Audit and Feedback dashboards install automatically after enablement (allow a few minutes).

> **Consent implication:** Enabling Audit and Feedback constitutes explicit organizational consent to store generative AI activity logs and feedback data in Data Cloud, including any cost implications. This is documented in Setup and should be communicated to customer IT and legal stakeholders before enablement.

Without Audit and Feedback enabled, the `prompt__c` and `llm_response` fields available through `AgentforceOptimizeService.getLlmStepDetails()` will return null. This limits the ability to diagnose instruction-adherence failures at the prompt level.

### Step 3: Enable Agent Platform Tracing

**Path:** Setup > Agent Platform Tracing

This is a completely separate toggle from Session Tracing. It enables the back-end execution trace pipeline that captures every LLM call, Flow execution, and Apex invocation as an OpenTelemetry (OTEL) span tree, stored in `ssot__TelemetryTraceSpan__dlm`.

Platform Tracing is the tool for diagnosing performance issues and integration failures that are invisible in session traces. It is not enabled by default, and customers frequently do not know it exists until a Success Architect introduces it.

### Step 4: Install the Consumption Tagging App (if needed)

If consumption reporting is a stakeholder requirement, the **Consumption Tagging app** must be installed from the Digital Wallet on AppExchange before the Consumption Analytics Dashboard is available. Plan for this before go-live — it cannot be rushed in after the fact.

### Infrastructure Readiness Checklist

- [ ] Data Cloud provisioned and CRM Connector active
- [ ] `CopilotSalesforceAdmin` assigned to admin users
- [ ] `GenieAdmin` assigned to admin users needing Data Cloud access
- [ ] `AgentforceServiceAgentBuilder` assigned to service agent admins
- [ ] `AgentforceDeveloperAndAdminTools` assigned to developers (verify purpose per org)
- [ ] Session Tracing enabled (Einstein Audit, Analytics, and Monitoring Setup)
- [ ] Agentforce Optimization enabled (same setup page)
- [ ] Audit and Feedback enabled with target data space selected (same setup page)
- [ ] Agent Platform Tracing enabled (Setup > Agent Platform Tracing)
- [ ] Consumption Tagging app installed (if Consumption Analytics Dashboard required)
- [ ] Alert thresholds configured relative to expected session volume before go-live

---

## 3. The Three Pillars of Agentforce Observability

Agentforce observability is not a single feature. It is a stack of three complementary capabilities that answer different questions at different levels of granularity. A Success Architect should understand all three, know when to recommend each one, and be able to explain the difference to a non-technical customer stakeholder.

---

### Pillar I: Agentforce Analytics

**What it is:** Real-time and historical dashboards that surface aggregate metrics across all agent sessions. Powered by Tableau Next, built on the Session Tracing Data Model (STDM) in Data Cloud.

**The business framing:** "Is the agent performing well overall?" Analytics is your command center. It tells you the shape of the situation: how many sessions, what escalation rate, which subagents are invoked most, where volume is trending.

**Key metrics surfaced:**

- Session volume (daily, weekly, trending)
- Escalation rate (the primary quality signal in the first weeks after go-live)
- Deflection rate (the headline ROI metric)
- Subagent invocation distribution
- Average session duration and turn count
- Agent latency

**When to rely on it:** Daily health monitoring, early-warning detection, executive reporting, and ROI calculation. Analytics answers the "what" — it does not answer the "why."

**Limitation to communicate:** Analytics dashboards show aggregate trends. They cannot tell you *why* a specific session escalated, *which* instruction caused a misrouted topic, or *where* an action broke. For those questions, you need Pillar II or III.

---

### Pillar II: Agentforce Optimization

**What it is:** A deeper analysis layer built on top of STDM that introduces the concept of **Moments** — structured units of user intent — and applies automated quality scoring and LLM-driven clustering to surface actionable improvement insights.

**The business framing:** "Where specifically is the agent underperforming, and what should we fix first?" Optimization moves you from the "what" of Analytics to the "how" of targeted improvement.

#### What a Moment Is

A Moment represents a distinct user intent within a session. A single session can contain multiple Moments — for example, a user who first asks about order status, then asks about a return policy, generates two Moments in one session.

Moments are the granular unit that Optimization scores and clusters. They are what make intent-level analysis possible.

#### How the Optimization Pipeline Works

Understanding the pipeline timing is essential for setting accurate customer expectations.

**Moment generation** runs on a frequent schedule. A pipeline run is initiated under one of two conditions:

- Every 9 hours if there is at least one new closed session.
- Every 3 hours if there are more than 10 new closed sessions since the last run.
- A session is considered "closed" after 3 hours of inactivity.

**Intent clustering** — where the LLM groups similar Moments and applies tags — runs once per week, over the weekend. This is the step that makes the Intents tab in Agentforce Optimization filterable by quality score and browsable by topic cluster.

**Important:** Meaningful clustering requires approximately 100 Moments. This typically corresponds to roughly 100 sessions, though the exact number depends on your session complexity. Deep optimization work should not begin until after the first weekly clustering run completes and sufficient data has accumulated.

**Historical data note:** If Session Tracing was already enabled before Optimization was turned on, the first pipeline run will analyze sessions from the last 30 days. Subsequent runs focus on the last 7 days. If Session Tracing is being enabled for the first time alongside Optimization, analysis begins from the moment of enablement.

#### Quality Scores: The Core Optimization Signal

Each Moment receives a quality score from 1 to 5, applied by an LLM-as-judge process:

| Score | UI Label |
|---|---|
| 5 | High |
| 3-4 | Medium |
| 2 | Low |
| 1 | Very Low |

> **Important constraint:** The quality scoring LLM-as-judge uses OpenAI/Azure OpenAI GPT-4o mini and is only available when the customer's Agentforce agent uses the Salesforce default model (OpenAI). If the customer has configured a different model, this automated scoring capability is not available.

Each score comes with a **Quality Score Reasoning** — a plain-language explanation generated by the LLM judge (for example: *"Agent didn't address the pricing question"* or *"Agent provided accurate information but required excessive turns"*). This reasoning is what makes quality scores actionable, not just a number.

#### Optimization STDM Tables

Optimization extends the core STDM with four additional DMOs:

| DMO | What It Contains |
|---|---|
| `ssot__AiAgentMoment__dlm` | One record per Moment; includes LLM-generated request and response summaries, timing |
| `ssot__AiAgentMomentInteraction__dlm` | Junction table linking Moments to their constituent interaction turns |
| `ssot__AiAgentTagAssociation__dlm` | Links each Moment to its quality score tag, with LLM-generated reasoning |
| `ssot__AiAgentTag__dlm` | Contains the five quality score levels (values 1-5) |

Quality score queries join `AiAgentTagAssociation` to `AiAgentTag` on tag ID to retrieve the integer score per Moment.

#### The AgentforceOptimizeService Apex API

For teams comfortable with Apex, Salesforce provides a helper class called `AgentforceOptimizeService` that wraps the STDM queries into clean, typed methods. This is particularly useful for Success Architects who want to analyze sessions programmatically.

Key methods:

| Method | What It Returns |
|---|---|
| `findSessions()` | Session list with IDs, timing, channel, and end type |
| `getConversationDetails()` | Full turn-by-turn transcript for a single session |
| `getAggregatedMetrics()` | High-level health dashboard: session rates, top intents, RAG quality averages |
| `getMomentInsights()` | Moment data including quality scores, summaries, and retriever metrics |
| `getLlmStepDetails()` | Actual LLM prompts and responses for a step (requires Audit and Feedback enabled) |
| `runObservabilityQuery()` | Targeted RAG quality analysis by query type (see below) |

**`runObservabilityQuery()` is especially powerful for knowledge-grounded agents.** It accepts a `queryType` parameter that controls what kind of RAG analysis is performed:

| Query Type | What It Returns |
|---|---|
| `KnowledgeGap` | Avg context precision + answer relevancy by subagent (lowest first) — surfaces where the knowledge base is failing |
| `Hallucination` | Subagents with avg faithfulness below 0.8 — surfaces where the agent is making things up |
| `RetrievalQuality` | Avg context precision by retriever, subagent, and agent — surfaces retrieval configuration issues |
| `AnswerRelevancy` | Subagents with avg answer relevancy below 0.7 — surfaces where retrieved content doesn't match user intent |
| `Leaderboard` | Combined precision, relevancy, and faithfulness by subagent — a comparative quality ranking across subagents |

Use `getAggregatedMetrics()` for a broad health overview first, then reach for `runObservabilityQuery()` when specific RAG quality issues are suspected.

#### A Recommended Monitoring Cadence

| Frequency | Activity |
|---|---|
| Daily | Monitor high-level KPIs in Agentforce Analytics. When a negative trend appears (rising escalation, falling deflection), use Optimization to drill down to the specific Moments causing the shift. |
| Weekly | Review the Intents tab for clustered topics with low quality scores. Identify patterns — is one subagent consistently underperforming? |
| Monthly | Collaborate with agent builders and SMEs to address root causes surfaced by weekly monitoring. Implement fixes (prompt refinements, knowledge base updates, action changes), then validate in sandbox before deploying to production. |

---

### Pillar III: Agent Platform Tracing

**What it is:** Back-end execution tracing that captures every LLM call, Flow run, and Apex invocation as a hierarchical span tree in OpenTelemetry format, stored in Data Cloud's `ssot__TelemetryTraceSpan__dlm` DMO.

**The business framing:** "Why is the agent slow? Why did that action break? Why does this only happen at certain times?" Platform Tracing is the deep diagnostic tool. It answers questions that are invisible at the session level.

Platform Tracing data lives in Data Cloud and is queryable via SOQL alongside all other agent data. Because it uses the OpenTelemetry standard, it can also be exported to enterprise APM platforms such as Datadog, Dynatrace, and Splunk — a significant advantage for customers who already have established observability infrastructure. For non-technical stakeholders who need to ask questions about agent performance, **Tableau Concierge** (a pre-built agentic analytics skill within Tableau Next) supports natural-language queries over the telemetry data, producing trusted answers with visualizations without requiring SOQL knowledge.

Full detail on Platform Tracing is in Section 6.

---

## 4. Session Tracing vs. Agent Platform Tracing

Two separate tracing systems operate at different layers of the Agentforce stack. Many practitioners conflate them, which leads to using the wrong tool for a given diagnosis.

| Feature | Agentforce Session Tracing | Agent Platform Tracing |
|---|---|---|
| **Layer** | Planner (conversational) | Service (back-end execution) |
| **Captures** | User input, subagent routing, LLM decisions, grounding results, agent responses | LLM calls, Flow runs, Apex invocations, timing, errors, span attributes |
| **Primary DMO** | `ssot__AiAgentInteraction__dlm` | `ssot__TelemetryTraceSpan__dlm` |
| **Join Field** | `ssot__TelemetryTraceId__c` | `ssot__TelemetryTrace__c` |
| **Primary Question Answered** | "What did the agent decide?" | "Why did it take that long? Where did it break?" |
| **Enabled By Default?** | No — requires opt-in via Setup > Einstein Audit, Analytics, and Monitoring | No — requires separate opt-in via Setup > Agent Platform Tracing |

**The analogy:** Session Tracing is the conversation transcript. Platform Tracing is the execution log of every system call that powered each line of that transcript. You need both for complete observability.

**The join:** `ssot__TelemetryTraceId__c` on `ssot__AiAgentInteraction__dlm` matches `ssot__TelemetryTrace__c` on `ssot__TelemetryTraceSpan__dlm`. This lets you bridge from a specific conversation turn to the back-end execution chain that powered it.

**Full data hierarchy:**

```
Session  (ssot__AiAgentSession__dlm)
  └── Interaction  (ssot__AiAgentInteraction__dlm)
        └── Step  (ssot__AiAgentInteractionStep__dlm)
              └── Span  (ssot__TelemetryTraceSpan__dlm)
                    └── Span  (ssot__TelemetryTraceSpan__dlm)
                          └── ...
```

### Understanding the Parse: Why One Turn Produces Multiple Spans

When reading Platform Tracing span trees, a common point of confusion is seeing multiple `run.llmstep` spans for what appears to be a single user message. This is expected behavior, and it requires understanding the Agent Script execution model.

**The primary unit of execution in Agent Script is the parse, not the user turn.** A parse is one complete cycle through a subagent's three lifecycle blocks (`before_reasoning`, `reasoning`, `after_reasoning`). The Atlas Reasoning Engine initiates a new parse in three situations:

1. On first entry into a subagent.
2. After every action call completes and returns a result, within the same subagent.
3. On every new user turn within the same subagent.

**The practical consequence for trace reading:** A subagent that fires two actions per user turn will show three `run.llmstep` spans per user turn (once on entry, once after each action return). This is not a loop. It is the reasoning engine processing the result of each action before deciding what to do next.

### The Block-to-Span Mapping

| Agent Script Block | Span Characteristics | LLM Involved? |
|---|---|---|
| `before_reasoning` | Deterministic; no `run.llmstep` span; variables set and actions fire before LLM sees anything | No |
| `reasoning` (deterministic `->`) | Deterministic conditional; fires actions or sets variables based on logical expressions | No |
| `reasoning` (prompt `\|`) | Generates a `run.llmstep` span; LLM receives the compiled prompt | Yes |
| `after_reasoning` | Fires after LLM response; deterministic; only present if not interrupted by `is_displayable: True` | No |

**Linked variables note:** Agent Script linked variables that bind to `@MessagingSession.Id`, `@MessagingEndUser.ContactId`, or `@VoiceCall.Id` are the script-level equivalent of the `ssot__AiAgentInteractionId__c` join field in the STDM. This means the session context a variable captures at the script level flows directly into the DMO records that represent that session in Data Cloud. Architects can trace a variable's value from its definition in the `.agent` file all the way to its representation in the STDM query results.

---

## 5. Reading Session Traces

### The Step Types: What Each One Tells You

A session trace is a sequence of steps recorded for each interaction (turn). Each step type reveals a different aspect of the agent's execution.

| Step Type | What It Represents | Key Fields to Check |
|---|---|---|
| `UserInputStep` | The raw user message as received | Does it match what the user sent? Encoding or truncation issues appear here. |
| `NodeEntryStateStep` | Subagent activation | Which subagent fired? Was it the expected one? |
| `EnabledToolsStep` | List of actions available to the LLM at this point | Is the expected action listed? If not, check `available when` gate conditions. |
| `LLMStep` | LLM reasoning call | `messages_sent` shows the full compiled prompt; `response_messages` shows what the LLM decided to do. |
| `FunctionStep` | Action invocation | Input, output, and error. This is the primary step for diagnosing action failures. |
| `ReasoningStep` | Grounding assessment | GROUNDED or UNGROUNDED. This is the quality gate on agent responses. |
| `PlannerResponseStep` | Final agent response to user | Includes the safety score. Review content against expected output. |
| `TrustGuardrailsStep` | Instruction adherence evaluation | Shows whether the agent followed its instructions. Look for LOW adherence as a signal for instruction issues. |
| `TransitionStep` | Subagent routing event | Where did the agent transition to? Was it the expected destination? |
| `SessionEndStep` | Session termination | How and why the session ended. |

### Grounding: The Hidden Quality Gate

Every LLM response in Agentforce goes through a grounding check. The `ReasoningStep` records whether the agent's response is grounded — meaning it can be verified against the data the agent actually retrieved — or ungrounded, meaning the agent asserted something that its own action outputs do not support.

> **Based on consistently observed platform behavior:** Two consecutive UNGROUNDED results on `ReasoningStep` trigger the agent's terminal fallback message ("I apologize, but I encountered an unexpected error"). This specific threshold is not documented explicitly in primary Salesforce documentation, but it is a widely consistent practitioner observation.

Grounding failures are almost always fixable. The pattern is straightforward: the `FunctionStep` output contains the data; the `ReasoningStep` shows UNGROUNDED; the `LLMStep.response_messages` shows the agent paraphrasing or inferring beyond that data. The fix is a targeted instruction update telling the LLM to quote specific fields verbatim rather than summarizing.

**Safety score monitoring:** Every agent response also receives a safety score visible on `PlannerResponseStep.safetyScore`. Monitor this field as an ongoing signal. Consistently low scores in a particular subagent indicate an instruction or content configuration issue worth investigating.

### Trace Reading Checklist (Per Turn)

- [ ] `UserInputStep` — Does the utterance match what you expected?
- [ ] `NodeEntryStateStep` — Did the correct subagent activate?
- [ ] `EnabledToolsStep` — Is the expected action listed? If missing, check `available when` gate variable values.
- [ ] `LLMStep.messages_sent` — Did instructions compile correctly? Are variables interpolated?
- [ ] `FunctionStep` — Did the action fire? What inputs did it receive? What did it return?
- [ ] `ReasoningStep` — Is the status GROUNDED?
- [ ] `PlannerResponseStep` — Review the safety score. Does the response content match action output?
- [ ] Multiple `run.llmstep` spans? — Expected in multi-action subagents (one per parse). Not a loop.
- [ ] Missing `after_reasoning` spans? — Check if `is_displayable: True` fired in that subagent.

---

> ### Scenario 1: Wrong Subagent Invoked for a Known Intent
>
> A customer's service agent has a `Billing_Inquiry` subagent and an `Account_Management` subagent. Users asking "Can you change my billing address?" are consistently routed to `Account_Management` instead of `Billing_Inquiry`.
>
> A Success Architect opens a session trace for one of the affected sessions. The `EnabledToolsStep` shows both subagents listed as available. The `LLMStep.tools_sent` shows the LLM receiving descriptions for both, but the `Billing_Inquiry` description reads: *"Handles billing questions and disputes."* The word "address" does not appear in it.
>
> The fix: Update the `Billing_Inquiry` description to include *"billing address changes, payment method updates."* After redeployment, routing accuracy for this utterance type improves to 100% in the next session batch.
>
> **Lesson:** Subagent routing is purely semantic. The LLM routes based on the description it receives. If the description does not cover the user's vocabulary, routing fails.

---

> ### Scenario 2: Systemic Escalation Spike at Peak Hours
>
> A financial services firm deploys an employee agent for HR policy questions. During the first two weeks, the escalation rate is stable at 8%. Then, every Tuesday and Thursday between 9 and 11 AM, the escalation rate spikes to 35%.
>
> The health monitoring alert fires within minutes of the first failed session cluster. The team investigates traces from that window and finds that all failed sessions share a common error: the Apex action that queries HR policy records is timing out. Cross-checking the Apex logs, they see a SOQL query running without selective filters during a batch processing window that runs every Tuesday and Thursday morning.
>
> Without health monitoring, this would have been discovered only after users started complaining. With the alert, the team had a root cause within 20 minutes of the first failure.
>
> **Lesson:** Health monitoring is your early warning system. It does not replace trace analysis. It tells you *when* to start trace analysis.

---

> ### Scenario 3: Grounding Failure Causing "Unexpected Error" Responses
>
> A retail agent handles product availability questions. Users intermittently receive *"I apologize, but I encountered an unexpected error"* responses, but only when asking about specific product categories.
>
> The team opens session traces for three affected sessions. In each case, the `ReasoningStep` shows two consecutive UNGROUNDED results. Examining the `FunctionStep` output, the action returns availability data formatted as: `"Available: 12 units at Store #4821"`. The agent's response reads: *"That item is available at your nearest location."* The grounding checker cannot verify that Store #4821 is the user's nearest location, because the action did not return location data.
>
> The fix: Update the agent instructions to quote the store number and unit count verbatim from the action output, without inferring proximity.
>
> **Lesson:** Grounding failures are almost always fixable with a targeted instruction change. The `ReasoningStep` and `FunctionStep` pair gives you exactly what you need to write that fix.

---

## 6. Agent Platform Tracing: Service-Level Visibility

Agent Platform Tracing captures the back-end execution chain as an OpenTelemetry-compatible trace tree stored in Data Cloud's `ssot__TelemetryTraceSpan__dlm` DMO. Where Session Tracing tells you what the agent decided, Platform Tracing tells you how that decision was executed, how long each step took, and where failures occurred in the stack.

Because it uses the OTEL standard, this data is not siloed. Customers with enterprise APM investments (Datadog, Dynatrace, Splunk) can export Platform Tracing data to their existing monitoring infrastructure. For non-technical stakeholders who need answers without writing SOQL, Tableau Concierge supports natural-language queries over the telemetry data with visualization.

### How Trace Trees Work

Every agent interaction generates a tree of spans. Each span represents one unit of back-end work. Spans nest to show parent-child execution relationships.

**Common span operation names:**

| Operation Name Pattern | What It Represents |
|---|---|
| `run.interaction` | Root span for the entire interaction |
| `run.llmstep` | An LLM reasoning call |
| `run.topic.*` | Subagent-level processing |
| `run.action.*` | An action invocation (Apex, Flow, etc.) |
| `run.invokeActions.FLOW` | A Flow action execution |
| `run.invokeActions.EXTERNAL_SERVICE` | An external (MCP) action call |

**Span naming convention tip:** Agent Script recommends naming transition actions with a `go_to_` prefix (e.g., `go_to_order`, `go_to_identity`). Span names in Platform Tracing reflect action and subagent names directly, so this convention makes transition spans visually distinctive and easy to locate in a large trace tree.

**Example trace tree (latency breakdown):**

```
run.interaction              2,690ms  OK
  run.llmstep                  139ms  OK
    run.topic.Order_Status         3ms  OK
      run.llmstep               838ms  OK
        run.action.Get_Order    327ms  OK
          run.llmstep         1,011ms  OK   <- bottleneck (38% of total)
```

This tree immediately shows that the LLM reasoning step after the action is the bottleneck, not the action itself. Without Platform Tracing, this distinction is invisible.

### Key Fields on `ssot__TelemetryTraceSpan__dlm`

| Field | Description |
|---|---|
| `ssot__Id__c` | Unique span identifier |
| `ssot__TelemetryParentSpanId__c` | Parent span ID; `null` or `0000000000000000` = root span |
| `ssot__TelemetryTrace__c` | The trace ID; links to `ssot__TelemetryTraceId__c` on `ssot__AiAgentInteraction__dlm` |
| `ssot__OperationName__c` | The type of operation |
| `ssot__StatusCode__c` | `OK` or `ERROR` |
| `ssot__DurationNumber__c` | Duration in milliseconds |
| `ssot__StartDateTime__c` | When this span began |
| `ssot__EndDateTime__c` | When this span ended |
| `ssot__ServiceName__c` | The service that generated this span |
| `ssot__TelemetrySpanAttributeText__c` | Key-value attributes (e.g., `flow.api.name`, `db.rows_affected`, `db.operation.name`) |

**Tree reconstruction:** Match each span's `ssot__TelemetryParentSpanId__c` to another span's `ssot__Id__c`. Treat `null` or `0000000000000000` as the root. This gives the complete hierarchical execution tree.

### SOQL for Performance Profiling

**Find consistently slow operation types (first step when a customer says "the agent feels slow"):**

```sql
SELECT
    ssot__OperationName__c,
    AVG(ssot__DurationNumber__c) AS AvgDuration,
    MAX(ssot__DurationNumber__c) AS MaxDuration,
    COUNT(*) AS SpanCount
FROM ssot__TelemetryTraceSpan__dlm
WHERE ssot__StartDateTime__c >= CURRENT_DATE - 30
GROUP BY ssot__OperationName__c
ORDER BY AvgDuration DESC
LIMIT 20
```

> An `AVG` of 1,800ms on `run.action.Get_Account` immediately focuses the investigation on that specific action.

**Find all recent error spans:**

```sql
SELECT
    ssot__Id__c,
    ssot__OperationName__c,
    ssot__TelemetryTrace__c,
    ssot__StartDateTime__c,
    ssot__DurationNumber__c,
    ssot__StatusCode__c
FROM ssot__TelemetryTraceSpan__dlm
WHERE ssot__StatusCode__c = 'ERROR'
ORDER BY ssot__StartDateTime__c DESC
LIMIT 20
```

**Count errors by operation type (identify most failure-prone steps):**

```sql
SELECT
    ssot__OperationName__c,
    COUNT(*) AS ErrorCount
FROM ssot__TelemetryTraceSpan__dlm
WHERE ssot__StatusCode__c = 'ERROR'
GROUP BY ssot__OperationName__c
ORDER BY ErrorCount DESC
LIMIT 20
```

**Reconstruct the full trace tree for a specific interaction:**

```sql
SELECT
    ssot__Id__c,
    ssot__OperationName__c,
    ssot__TelemetryParentSpanId__c,
    ssot__ServiceName__c,
    ssot__StatusCode__c,
    ssot__DurationNumber__c,
    ssot__StartDateTime__c,
    ssot__EndDateTime__c,
    ssot__TelemetrySpanAttributeText__c
FROM ssot__TelemetryTraceSpan__dlm
WHERE ssot__TelemetryTrace__c = 'YOUR_TRACE_ID'
ORDER BY ssot__StartDateTime__c ASC
```

### Joining Session Tracing and Platform Tracing

Joining both systems gives end-to-end visibility: conversational context from Session Tracing, back-end execution detail from Platform Tracing.

```sql
-- Step 1: Get the TelemetryTraceId from the session interaction
SELECT
    ssot__Id__c,
    ssot__TelemetryTraceId__c,
    ssot__UserInput__c
FROM ssot__AiAgentInteraction__dlm
WHERE ssot__AiAgentSession__c = 'YOUR_SESSION_ID'
LIMIT 10
```

```sql
-- Step 2: Use that TelemetryTraceId to pull all back-end spans
SELECT
    ssot__Id__c,
    ssot__OperationName__c,
    ssot__TelemetryParentSpanId__c,
    ssot__StartDateTime__c,
    ssot__DurationNumber__c,
    ssot__StatusCode__c
FROM ssot__TelemetryTraceSpan__dlm
WHERE ssot__TelemetryTrace__c = 'TELEMETRY_TRACE_ID_FROM_STEP_1'
ORDER BY ssot__StartDateTime__c ASC
```

### The Span Attributes Signal

The `ssot__TelemetrySpanAttributeText__c` field carries key-value pairs that reveal what an operation actually did, which is often different from what its name implies:

- `db.rows_affected=2847` on an action span means the backing query returned nearly 3,000 records. This is a performance and cost problem visible only through span attributes.
- `db.operation.name=query` on a span named `run.createrecord.account` reveals the span is performing a lookup, not a write. Without this attribute, you would investigate the wrong problem.

Always check span attributes when a span's status or duration does not match the expectation from its operation name alone.

### Conversational Observability with Slackbot

Because Platform Tracing data lives in Data Cloud, it can be queried by any connected system. A practical pattern for enterprise customers is to wire SOQL query templates into a Slack canvas and connect that canvas to Slackbot. This turns trace analysis into a natural language conversation and puts diagnostic capability in the hands of non-developer ops teams.

**Example Slackbot exchange:**

```
You:      Why did interaction b9e8f7b4 take 4 seconds?

Slackbot: I queried all spans for trace b9e8f7b4. Total duration: 2,690ms.
          Breakdown:
            run.interaction        2,690ms  OK
              run.llmstep            139ms  OK
                run.topic              3ms  OK
                  run.llmstep        838ms  OK
                    run.action       327ms  OK
                      run.llmstep  1,011ms  OK  <- bottleneck (38%)

          The bottleneck is the final LLM reasoning step after the action.
          The action itself was fast at 327ms.
```

Setup requires Slackbot connected to an org with Agent Platform Tracing enabled, with SOQL query templates and DMO schemas provided via a Slack canvas.

---

> ### Scenario 4: Latency Complaint with No Obvious Cause
>
> A customer reports that their claims-processing agent "takes forever to respond." The OOTB dashboard shows elevated average session duration but no escalation spike and no error alerts. Session traces show the `FunctionStep` for `Get_Policy_Details` completed successfully.
>
> A Success Architect enables Agent Platform Tracing (it was toggled off) and runs the performance profiling query after the next morning's usage. Results show `run.action.Get_Policy_Details` averages 3,200ms with a max of 8,100ms. The span attribute `db.rows_affected=2847` reveals the action is returning nearly 3,000 records from an unfiltered query.
>
> The fix: The backing Apex class queries without a `LIMIT` clause and without a selective `WHERE` filter. Adding both reduces average action duration from 3,200ms to 180ms.
>
> **Lesson:** Session Tracing confirmed the action ran. Platform Tracing revealed how it ran — including how many rows it touched. Without span attributes, this root cause is invisible.

---

## 7. Dashboards and the Data Model

### Out-of-the-Box Dashboard Surfaces

Salesforce provides three OOTB dashboard surfaces. Know which questions each one answers before recommending one to a customer.

#### Agentforce Analytics Dashboard (also: Agentforce Observability)

Your primary day-to-day monitoring surface. Available with Agentforce entitlements.

| Panel | Metric | Significance |
|---|---|---|
| Conversation Volume | Sessions per day/week | Adoption curve; validates channel awareness |
| Topic / Intent Breakdown | Most-invoked subagents | Reveals demand patterns and mis-routing |
| Session Duration | Average turn count and time | Long sessions may indicate loops |
| Escalation Rate | % of sessions escalated | Primary quality signal in weeks 1-2 |
| Deflection Rate | % resolved without human | Headline ROI metric |
| Sub-agent Invocation Count | Per-subagent invocation trends | Routing health and coverage gaps |

#### Consumption Analytics Dashboard (powered by Tableau Next)

Focused on credit and token consumption. Requires the Consumption Tagging app to be installed first (via Digital Wallet on AppExchange).

| Panel | Metric | Operational Value |
|---|---|---|
| Daily Active Users | Users per agent per day | Growth tracking |
| Input vs. Output Token Breakdown | Token split by direction | Cost optimization signal |
| Token Usage by User | Heaviest consumers | Identify power users or anomalies |
| Usage by Agent | Agent-level consumption | Budget attribution |

#### Consumption Insights Dashboard (Data 360 Reports)

Provides granular consumption data including per-feature and per-model token breakdowns. Auto-installs with Data Cloud provisioning but requires data space configuration, governance policy, and appropriate system permissions before reports are viewable.

---

### Data Cloud STDM Tables

When OOTB dashboards are insufficient, custom analytics are built directly on Data Cloud's STDM tables via Data Cloud Query Editor or Data 360 Reports.

#### Core STDM Tables

| DMO Table | What It Contains | Common Use Cases |
|---|---|---|
| `ssot__AiAgentSession__dlm` | Session-level data: start time, end time, channel, escalation status | Session volume, duration, success rate analysis |
| `ssot__AiAgentInteraction__dlm` | Interaction metadata: intent, subagent, resolution status, TelemetryTraceId | Intent distribution, routing analysis, join to Platform Tracing |
| `ssot__AiAgentInteractionMessage__dlm` | User and agent messages within each interaction | Conversation content analysis, stuck-session detection |
| `ssot__AiAgentInteractionStep__dlm` | Action steps with error tracking | Action failure rate, error categorization |
| `ssot__AiAgentSessionParticipant__dlm` | Agent participation in sessions | Multi-subagent usage analysis |
| `AiAgentGenerativeAiUsage_std__dlm` | Per-event billing and metering: usage quantity, token counts, billable indicator | Credit consumption attribution, cost-per-session analysis |
| `ssot__TelemetryTraceSpan__dlm` | Back-end execution spans (OTEL) | Latency profiling, error localization, integration debugging |
| `GenAIGatewayRequest__dlm` | Raw LLM gateway requests including prompt text | Prompt inspection, instruction-adherence debugging |
| `GenAIGeneration__dlm` | LLM response records | Response text retrieval for quality analysis |
| `GenAIFeedback__dlm` | User feedback (thumbs up/down, reason text) | User satisfaction signal, NPS proxy |

#### Optimization STDM Tables (Agentforce Optimization)

| DMO Table | What It Contains |
|---|---|
| `ssot__AiAgentMoment__dlm` | One record per Moment; LLM-generated summaries, timing |
| `ssot__AiAgentMomentInteraction__dlm` | Junction table: Moments to interaction turns |
| `ssot__AiAgentTagAssociation__dlm` | Quality score per Moment with LLM-generated reasoning |
| `ssot__AiAgentTag__dlm` | The five quality score levels (values 1-5) |

---

### Useful SOQL Patterns

**Session volume and average duration (last 30 days):**

```sql
SELECT
    COUNT(*) AS SessionCount,
    AVG(ssot__DurationSeconds__c) AS AvgDurationSeconds
FROM ssot__AiAgentSession__dlm
WHERE ssot__CreatedDate__c >= CURRENT_DATE - 30
```

**Escalation rate by day:**

```sql
SELECT
    CAST(ssot__CreatedDate__c AS DATE) AS SessionDate,
    COUNT(*) AS TotalSessions,
    SUM(CASE WHEN ssot__IsEscalated__c = TRUE THEN 1 ELSE 0 END) AS EscalatedSessions
FROM ssot__AiAgentSession__dlm
WHERE ssot__CreatedDate__c >= CURRENT_DATE - 14
GROUP BY CAST(ssot__CreatedDate__c AS DATE)
ORDER BY SessionDate DESC
```

**Action error count by action name:**

```sql
SELECT
    ssot__Name__c AS ActionName,
    COUNT(*) AS ErrorCount
FROM ssot__AiAgentInteractionStep__dlm
WHERE ssot__AiAgentInteractionStepType__c = 'ACTION_STEP'
  AND ssot__ErrorMessageText__c IS NOT NULL
GROUP BY ssot__Name__c
ORDER BY ErrorCount DESC
LIMIT 20
```

**Credit consumption by agent (last 7 days):**

```sql
SELECT
    AgentDeveloperName__c,
    SUM(UsageQuantity__c) AS TotalUsage,
    COUNT(*) AS EventCount
FROM AiAgentGenerativeAiUsage_std__dlm
WHERE Timestamp__c >= CURRENT_DATE - 7
GROUP BY AgentDeveloperName__c
ORDER BY TotalUsage DESC
```

**Full session reconstruction (single-query approach using CTE):**

This pattern reconstructs the complete event timeline for a session in a single query, merging messages and steps into a unified, time-ordered event stream. It is more efficient for session-level investigation than querying the two DMOs separately.

```sql
WITH params AS (
    SELECT '<SESSION_ID>' AS session_id
),
msgs AS (
    SELECT
        m.ssot__MessageSentTimestamp__c AS event_time,
        'MESSAGE'                       AS event_kind,
        m.ssot__AiAgentInteractionMessageType__c AS subtype,
        i.ssot__TopicApiName__c         AS topic,
        m.ssot__ContentText__c          AS content,
        CAST(NULL AS VARCHAR)           AS input_value,
        CAST(NULL AS VARCHAR)           AS output_value
    FROM ssot__AiAgentInteractionMessage__dlm m
    JOIN ssot__AiAgentInteraction__dlm i
        ON m.ssot__AiAgentInteractionId__c = i.ssot__Id__c
    JOIN params p ON m.ssot__AiAgentSessionId__c = p.session_id
),
steps AS (
    SELECT
        st.ssot__StartTimestamp__c               AS event_time,
        'STEP'                                    AS event_kind,
        st.ssot__AiAgentInteractionStepType__c   AS subtype,
        i.ssot__TopicApiName__c                  AS topic,
        st.ssot__Name__c                         AS content,
        st.ssot__InputValueText__c               AS input_value,
        st.ssot__OutputValueText__c              AS output_value
    FROM ssot__AiAgentInteractionStep__dlm st
    JOIN ssot__AiAgentInteraction__dlm i
        ON st.ssot__AiAgentInteractionId__c = i.ssot__Id__c
    JOIN params p ON i.ssot__AiAgentSessionId__c = p.session_id
)
SELECT * FROM (
    SELECT * FROM msgs
    UNION ALL
    SELECT * FROM steps
) combined
ORDER BY event_time ASC
```

---

> ### Scenario 5: Action Output Ignored in Agent Response
>
> A customer's agent retrieves account data but consistently responds with generic messages instead of using the fetched information.
>
> The session trace `FunctionStep` shows the action returned a full account record. The `LLMStep.response_messages` that follows shows the LLM produced a response mentioning none of the returned fields. The `ReasoningStep` shows GROUNDED — which means the LLM technically could have used the data, but chose not to.
>
> The fix: The subagent instructions are updated to explicitly name the output fields the agent should reference: *"Use the AccountName, ContractStatus, and RenewalDate fields from the action output in your response."* After redeployment, 100% of tested sessions reference the correct field values.
>
> **Lesson:** Grounding checks verify that assertions are supportable. They do not force the LLM to surface all data. Instruction specificity does.

---

## 8. Common Diagnostic Patterns

These patterns cover the most frequently encountered agent issues. Each has a consistent signature in traces and a reliable fix direction.

### Pattern A: Wrong Subagent Invoked

**Symptom:** Users are routed to the wrong subagent for their intent.

**Where to look:** `LLMStep.tools_sent` — examine the descriptions of the available subagents as the LLM sees them. If the description for the correct subagent does not include vocabulary that matches the user's phrasing, the routing will fail.

**Fix direction:** Update the subagent description to include the vocabulary users actually use. The routing decision is entirely semantic.

---

### Pattern B: Action Not Invoked

**Symptom:** The agent responds without calling an expected action. The `FunctionStep` for that action is absent from the trace.

**Where to look:** `EnabledToolsStep` — is the action listed? If not, the issue is an `available when` gate that evaluated to false. Check the variable values in the `NodeEntryStateStep` to see the state of gate variables at the moment of evaluation.

**Fix direction:** If the gate condition is wrong, correct the variable logic. If the variable was not set, trace back to where it should have been set and confirm the action or `@utils.setVariables` call that should populate it actually fired.

---

### Pattern C: Action Invoked but Output Ignored

**Symptom:** The `FunctionStep` shows a successful action with data in the output field. The agent response does not use that data.

**Where to look:** The `LLMStep` immediately after the `FunctionStep`. Check `response_messages` to see whether the LLM produced a text response without referencing the tool output.

**Fix direction:** Update agent instructions to explicitly name the output fields the agent should include in its reply. The more specific the instruction, the more reliably the LLM surfaces the data.

---

### Pattern D: Unexpected Error Response

**Symptom:** Users receive "I apologize, but I encountered an unexpected error" or similar terminal fallback messages.

**Where to look:** Two consecutive UNGROUNDED `ReasoningStep` entries. Then examine the `FunctionStep` output that preceded them. Compare what the action returned to what the agent's response asserted.

**Fix direction:** Update the agent instructions to constrain the LLM to assertions the action output can support. Avoid instructions that tell the LLM to infer or summarize context that is not in the data.

---

### Pattern E: Escalation Spike with No Surface Error

**Symptom:** Escalation rate spikes in the Analytics dashboard, but there are no error alerts and no obvious failures in the traces reviewed.

**Where to look:** Filter STDM sessions to the spike window. Look for shared patterns across multiple sessions: same subagent? Same time of day? Same action in the `FunctionStep`? Cross-reference with Apex execution logs if actions are timing out silently.

**Fix direction:** Identify the shared characteristic and address it directly. Silent timeout failures from platform limits (CPU, SOQL rows, heap) appear as `FunctionStep` errors in traces even when the top-level session trace does not flag an obvious failure.

---

### Pattern F: Latency with No Surface Error

**Symptom:** Users report slow responses. Session traces show actions completing successfully. No error alerts are firing.

**Where to look:** Agent Platform Tracing. Query `ssot__TelemetryTraceSpan__dlm` for the interaction's trace ID. Check `ssot__DurationNumber__c` and `ssot__TelemetrySpanAttributeText__c` for the action span in question.

**Root cause:** The action ran successfully but returned too much data (visible as a high `db.rows_affected` value in span attributes), causing the LLM to spend extra time processing a large payload. The session trace records success; only span attributes reveal the volume problem.

**Fix direction:** Add `LIMIT` clauses and selective `WHERE` filters to the backing Apex or Flow query.

---

### Pattern G: Missing `after_reasoning` Spans

**Symptom:** A Platform Trace span tree shows no spans corresponding to an `after_reasoning` block that exists in the Agent Script. The span tree ends after the action span.

**Where to look:** Check whether the action that preceded the missing block has `is_displayable: True` set in its configuration.

**Root cause:** This is expected platform behavior. When `is_displayable: True` is set on an action, the platform exits the reasoning loop immediately when the LLM decides to surface that output. `after_reasoning` never executes, and no error is raised.

**Fix direction:** If logic in `after_reasoning` must execute reliably, move it into the `before_reasoning` block of the subsequent subagent. Do not place logic that must run in `after_reasoning` when the triggering action has `is_displayable: True`.

---

### Pattern H: `before_reasoning` Counter Shows Inflated Count

**Symptom:** A variable used to track conversation turn count returns values higher than the number of actual user messages in the session.

**Where to look:** Check where the counter variable is incremented in the Agent Script. If the increment is in `before_reasoning`, the variable is counting parses, not turns.

**Root cause:** `before_reasoning` executes on every parse, including re-entry after each action call within a turn. In a subagent that fires two actions per turn, `before_reasoning` runs three times per user turn (once on entry, once after each action return). A counter incremented here will be two to three times the actual turn count.

**Fix direction:** Move the counter increment to `after_reasoning`, or use an action-based incrementor that fires explicitly once per intended measurement unit.

---

### Diagnostic Quick-Reference

| Symptom | First Place to Look |
|---|---|
| Wrong subagent invoked | `LLMStep.tools_sent` and subagent descriptions |
| Action not invoked | `EnabledToolsStep` — is the action listed? Check `available when` gate variable values. |
| Unexpected error response | Two consecutive UNGROUNDED `ReasoningStep` entries |
| Agent ignores action data | `LLMStep.response_messages` after `FunctionStep` |
| Slow response | `ssot__TelemetryTraceSpan__dlm` performance profiling query |
| Stuck session (repetitive questions) | `ssot__AiAgentInteractionMessage__dlm` for repeated user messages |
| Missing `after_reasoning` spans | Check if triggering action has `is_displayable: True` |
| Inflated turn counter | Check if counter increment is in `before_reasoning` (counts parses, not turns) |
| High escalation spike | Health alert, then STDM session filter for affected time window |
| Credit consumption anomaly | `AiAgentGenerativeAiUsage_std__dlm` billable usage by agent |

---

> ### Scenario 6: Using Optimization to Surface a Knowledge Gap
>
> A retail banking agent has been live for three weeks. The Analytics dashboard shows an average quality score of 3.2 and a deflection rate of 41%. Both metrics are below target but the team cannot identify which part of the agent is causing the drag.
>
> A Success Architect opens Agentforce Optimization after the first weekly clustering run completes. The Intents tab shows a cluster of 47 low-quality Moments (quality score 1-2) labeled by the LLM as *"Questions about mortgage refinancing rates."* The Quality Score Reasoning for multiple Moments reads: *"Agent provided general information about the refinancing process but could not provide current rate information."*
>
> Drilling into three individual Moments, the request summaries confirm users are asking for specific current rates. The response summaries show the agent citing a knowledge article from Q3 of the prior year. A `runObservabilityQuery()` call with `queryType = 'KnowledgeGap'` confirms the `Mortgage_Refinancing` subagent has the lowest average context precision in the org.
>
> The fix: The knowledge base is updated with current rate tables, and the subagent instructions are updated to specify that the agent should always cite the publication date of the rate article. After the next clustering run, Mortgage Refinancing Moments average a quality score of 4.1.
>
> **Lesson:** Optimization surfaces problems Analytics cannot. The quality score clustering shows *where* the agent is underperforming and *why*, with enough precision to prioritize the fix without reviewing individual sessions manually.

---

## 9. Sandbox vs. Production Tracing

Success Architects need to guide customers through the full deployment lifecycle. The observability configuration and tooling differ meaningfully across environments.

### Key Differences

| Dimension | Sandbox / Development | Production |
|---|---|---|
| **Primary tracing tool** | Session traces via `sf agent preview` CLI | Data Cloud STDM tables and Agent Platform Tracing DMOs |
| **Session Tracing toggle** | Must be enabled per org — does not inherit | Must be enabled separately before go-live |
| **Agent Platform Tracing toggle** | Must be enabled per org | Must be enabled separately before go-live |
| **Data retention** | Preview trace files are local and ephemeral | STDM and Platform Tracing data persists in Data Cloud for the configured retention window |
| **Utterance quality** | Controlled test utterances | Full diversity of real-user phrasing |
| **Alert thresholds** | Not typically configured | Configure all alert thresholds before go-live |
| **Data volume** | Low; manual trace review is practical | High; aggregate dashboards and SOQL queries are the primary diagnostic surface |

### Agentforce Testing Center

The Agentforce Testing Center bridges the pre-production and production observability gap. It is a sandbox-only tool that enables rigorous, at-scale testing of agent behavior before any code reaches production — and it integrates directly with session tracing so every test run produces the same trace artifacts a Success Architect uses in production diagnosis.

**Why it matters for a Success Architect:** Testing Center is the first place a customer should go when building confidence in a new agent or validating a fix. It converts qualitative "does this feel right?" testing into quantitative, reproducible evaluation at scale.

#### What Testing Center Does

Testing Center runs test cases against an agent in sandbox and evaluates each response using an LLM-as-judge process. It supports multiple evaluation types:

| Evaluation Type | What It Checks |
|---|---|
| Topic Classification | Exact match validation — did the right subagent handle this? |
| Action Sequences | Did the agent invoke the expected actions in the expected order? |
| Response Quality | LLM-as-judge scoring (0-5 scale; score of 3 or above = Pass) |
| Text Quality Metrics | Conciseness, completeness, coherence |
| Citation Support | Does the agent correctly cite knowledge articles? |
| Instruction Adherence | Did the agent follow its tone and behavioral instructions? |
| Latency | Response time measurement |

The LLM-as-judge process uses a separate, internally hosted model (not the agent's own reasoning model) that runs in the same region as the customer's Data 360 instance, routed through the Einstein Trust Layer.

**Full conversation logs** are accessible from each test run via the same session tracing infrastructure as production. This means a testing session can be diagnosed with exactly the same trace-reading techniques covered in Section 5.

#### Key Limits

| Limit | Value |
|---|---|
| Maximum test cases per job | 500 |
| Jobs per hour | 10 |
| Recommended batch size | 20-30 test cases |
| Approximate execution time | ~5 seconds per test case |

**No additional license required.** Testing Center is automatically available to all Agentforce customers in sandbox environments at no additional cost.

#### Recommended Testing Approach

Start with 30-40 test cases in the first iteration and expand. Cover four dimensions:

- **Features** — core capabilities (case creation, order lookup, policy retrieval)
- **Scenarios** — edge cases (no match found, incomplete information, unsupported requests)
- **Personas** — authenticated vs. unauthenticated, mobile vs. desktop
- **Guardrails** — off-topic inputs, prompt injection attempts

Test cases can be created by uploading a CSV, using AI-generated suggestions, importing from knowledge articles, or importing a conversation from Agent Builder. Regular testing throughout the development lifecycle produces better agents than a single pre-launch test run.

#### Testing Center and the Observability Continuum

Testing Center fits into a three-stage observability chain:

1. **Build time:** CLI preview traces (`sf agent preview`) for individual utterance debugging during development.
2. **Pre-production:** Testing Center for at-scale batch evaluation, routing validation, and action sequence verification in sandbox.
3. **Production:** STDM dashboards, Optimization, and Platform Tracing for ongoing monitoring and improvement.

Each stage uses the same underlying session tracing data. The tools scale from a single developer reviewing one trace to an org-wide automated evaluation of hundreds of sessions.

### Transition from Sandbox to Production

When a customer promotes an agent from sandbox to production:

1. **Enable both tracing toggles in production separately.** Session Tracing and Agent Platform Tracing must be explicitly enabled. They do not transfer from sandbox.
2. **Confirm Data Cloud DMOs are accessible.** Run a test query against `ssot__AiAgentSession__dlm` and verify that admin users have `GenieAdmin` and `CopilotSalesforceAdmin` assigned.
3. **Seed baseline metrics in the first 48 hours.** Dashboards need live traffic to establish a baseline before alert thresholds can be calibrated accurately.
4. **Configure alert thresholds before launch.** Set thresholds relative to expected session volume, not arbitrary defaults. A high-volume deployment has a very different "normal" than a small internal agent.
5. **Shift from CLI trace review to SOQL.** The development workflow of opening individual trace files does not scale to production volumes. Ensure the customer team understands the STDM query patterns in Section 7 before go-live.
6. **Install the Consumption Tagging app** if consumption reporting is a stakeholder requirement. Plan for this before go-live.

---

## 10. Mapping Observability to Business KPIs

One of the most valuable things a Success Architect does is translate technical metrics into the language of business outcomes. This table provides the mappings that help customer leadership understand why observability investment matters.

### KPI Translation Table

| Technical Metric | Source | Business KPI | Business Audience |
|---|---|---|---|
| Genuine Deflection Rate | `ssot__AiAgentSession__dlm` cross-ref with `ssot__AiAgentInteractionStep__dlm` | Cost-per-interaction reduction | Customer Service Operations |
| Escalation Rate | Agentforce Analytics Dashboard | Agent quality and trust | CX Leadership |
| Quality Score (Optimization) | `ssot__AiAgentTagAssociation__dlm` / Optimization UI | Agent effectiveness by intent | Product and Agent Design |
| Action span duration | `ssot__TelemetryTraceSpan__dlm` | Time-to-resolution; UX quality | Service Ops / IT Ops |
| Error volume by operation type | `ssot__TelemetryTraceSpan__dlm` | IT ops efficiency; MTTR | IT Operations |
| Usage quantity and token count | `AiAgentGenerativeAiUsage_std__dlm` | AI cost-per-transaction | Finance / AI Budget Owners |
| Safety score distribution | `PlannerResponseStep.safetyScore` (session trace) | Brand risk and compliance posture | Legal / Compliance |
| User feedback rating | `GenAIFeedback__dlm` | NPS / user satisfaction | CX Leadership |
| Stuck session rate (custom query) | `ssot__AiAgentInteractionMessage__dlm` | Conversation quality; intent gaps | Product / Agent Design |

### Making the ROI Case

A common executive ask is: "How do we know this agent is actually saving us money?" The answer lives in STDM data.

**Step 1: Establish the cost-per-interaction baseline** (before agent). Use historical case volume and average handle time to determine the human cost per interaction in the category the agent covers.

**Step 2: Measure genuine deflection rate.** A "deflected" session that ended with an error is not a genuine deflection. Use `ssot__AiAgentInteractionStep__dlm` to filter out sessions where the agent returned a graceful failure, cross-referenced against sessions that did not escalate.

**Step 3: Calculate cost avoidance.**

```
Cost Avoidance = Genuine Deflections x (Human Cost Per Interaction - AI Cost Per Session)
```

AI cost per session comes from `AiAgentGenerativeAiUsage_std__dlm` (`SUM(UsageQuantity__c)` per session). Convert usage quantity to cost using the contracted Flex Credit rate from the Salesforce Account Executive. Do not use published list prices; credit pricing is contractual and varies.

**Step 4: Surface latency reduction as efficiency gain.** Query `AVG(ssot__DurationNumber__c)` for primary action spans before and after optimization. A reduction from 3,200ms to 180ms on a high-volume action translates directly to faster time-to-resolution.

**Step 5: Tie error trends to IT ops efficiency.** Track `COUNT(*)` on error spans by operation type over time. Each spike corresponds to a support incident. The trend line shows whether agent reliability is improving.

---

> ### Scenario 7: Proving ROI to a Skeptical VP
>
> Three months after go-live, the VP of Service Operations asks: "We're spending significantly on Agentforce credits. How do we know this is worth it?"
>
> The Success Architect runs three queries:
>
> 1. `ssot__AiAgentSession__dlm` cross-referenced with `ssot__AiAgentInteractionStep__dlm` for genuine deflection rate: 42% of sessions resolved with no escalation and at least one successful action execution.
> 2. `AiAgentGenerativeAiUsage_std__dlm` for average credit cost per session: 23 usage units on average per session.
> 3. Historical CRM data showing the pre-agent average handle time for this interaction category.
>
> With those three inputs and the contracted credit rate, the team calculates monthly cost avoidance across 50,000 sessions with 42% genuine deflection.
>
> The additional finding: 14% of non-escalated sessions had error spans with `db.rows_affected=0` indicating graceful failures rather than genuine resolution. Fixing those would push genuine deflection from 42% to approximately 56% — a significant additional monthly cost avoidance opportunity that is now a prioritized sprint item.
>
> **Lesson:** Observability data does not just help you debug. It makes the business case for continued investment, and it shows exactly where to focus optimization effort to maximize that case.

---

## 11. Credit Consumption Awareness

Understanding which operations consume credits and which do not is essential for cost management and debugging. This section provides the architectural context a Success Architect needs to have informed conversations with customers about consumption — but billing in Agentforce is genuinely complex. Always involve a Salesforce Consumption SME for any customer conversation that involves billing design, ROI modeling, or consumption forecasting.

### The Reality of Action Billing vs. Control Flow

A critical architectural distinction: **actions are billed per execution, regardless of how they were triggered.** Whether an action is invoked by the Atlas Reasoning Engine during free-form LLM reasoning, or fired deterministically by a `run @actions.name` directive in a `before_reasoning` or `after_reasoning` block, the credit cost is identical. Deterministic scripting does not exempt actions from the billing meter.

The reason hybrid reasoning saves credits is not that the actions themselves become free. It eliminates redundant LLM reasoning steps — bypassing the LLM for predictable transitions, state checks, and variable assignments prevents expensive prompt loops.

The four `@utils` functions are the only operations that are genuinely free at all times, because they are platform-native control plane utilities rather than external invocations.

### Credit Consumption Reference

| Operation | Credits | Notes |
|---|---|---|
| `@utils.transition to` | FREE | Framework navigation; never billed |
| `@utils.setVariables` | FREE | Framework state management; never billed |
| `@utils.escalate` | FREE | Framework escalation; never billed |
| `@utils.end_session` | FREE | Framework session termination; never billed |
| `if`/`else` control flow | FREE | Deterministic resolution; no LLM call |
| `before_reasoning` / `after_reasoning` hooks | FREE | Deterministic pre/post-processing; no LLM call |
| Atlas reasoning loop | FREE | The core ReAct reasoning cycle is not billed as an action |
| Flow actions | 20 credits | Per execution — billed whether triggered by LLM or deterministic script |
| Apex actions | 20 credits | Per execution — billed whether triggered by LLM or deterministic script |
| Other standard actions | 20 credits | Per execution |
| Voice actions | 30 credits | Per execution |

> **Note on Prompt Templates:** Prompt Template actions are billable per invocation as a separate usage type from standard action executions. The exact credit rate is contractual. Verify current rates with your Salesforce Account Executive.

### Billing Is More Complex Than This Table Suggests

The table above covers the most common Flex Credits scenario, but Agentforce billing has multiple coexisting models that can apply depending on customer contract type, product edition, and deployment configuration:

- **Help Agent (outcome-based):** Some deployments bill only on resolved sessions — not on every action. A "resolution" has specific platform-defined criteria involving session length, escalation status, and user feedback signals. Non-resolved sessions in this model are not billed.
- **Prompt-based billing:** LLM calls can be billed in 2,000-token chunks rather than per action, depending on model and contract. A single long-context call can generate multiple billable prompt units.
- **Voice Minutes:** Voice deployments may be billed per minute of call duration rather than per action invocation, depending on the customer's entitlement.
- **Speech processing:** Speech-to-text and text-to-speech have their own billing units (seconds of audio, characters of text) that are separate from action credits.
- **Sandbox discount:** Standard actions in sandbox environments consume approximately 16 credits (80% of the production rate of 20). Useful to know when estimating costs from sandbox testing.
- **Per-action token threshold:** Actions have a documented token budget. Exceeding this threshold on a single action invocation can trigger additional Flex Credit consumption beyond the base rate.
- **Pure conversation with no action invocation is not billed.** LLM reasoning steps that do not result in an action call do not consume Flex Credits for that step.

> **The bottom line for Success Architects:** Credit billing is contractual, multi-dimensional, and evolving. You need enough literacy to spot anomalies in `AiAgentGenerativeAiUsage_std__dlm` and to ask the right questions. For any customer conversation involving billing design or cost modeling, bring in a Consumption SME. Do not estimate from published list prices.

### Cost Implications for Troubleshooting

Every `FunctionStep` in a session trace represents a credit expenditure. A session with 5 action invocations costs at least 100 credits before accounting for any Prompt Template calls.

An elevated escalation rate is not just a user experience problem. If the fallback path involves action retries, it also represents unplanned credit consumption at scale. Tight escalation monitoring has a secondary benefit as a cost anomaly detector.

Actions that fail due to platform limits (CPU time, SOQL row limits, heap size) appear as `FunctionStep` errors in session traces. In production, each of these represents credits spent on a failed invocation. Monitoring error volume by operation type is therefore both a reliability metric and a cost metric.

---

## 12. Quick-Reference Cheat Sheet

### The Observability Decision Tree

```
Something is wrong with my agent
            |
            v
Is it affecting many users simultaneously?
  YES -> Check Health Monitoring alerts first
         |
         v
         Filter STDM tables to the affected time window
         Find common subagent or action patterns
         Pull session traces from 3-5 affected sessions
         Apply diagnostic patterns from Section 8
  NO  -> Is there a reproducible test case?
  YES -> Open session traces (via developer CLI or STDM query)
         Read the LLMStep, EnabledToolsStep, FunctionStep, ReasoningStep
   NO -> Query STDM tables to find sessions with similar characteristics
         Identify a representative session, then trace it
                              |
                              v
        Need more execution detail than the session trace provides?
        Enable Agent Platform Tracing (if not already on)
        Query ssot__TelemetryTraceSpan__dlm for the trace ID
```

### Trace Reading Checklist (Per Turn)

- [ ] `UserInputStep` — Does the utterance match what you expected?
- [ ] `NodeEntryStateStep` — Did the correct subagent activate?
- [ ] `EnabledToolsStep` — Is the expected action listed? If missing, check `available when` gate variable values.
- [ ] `LLMStep.messages_sent` — Did instructions compile correctly? Are variables interpolated?
- [ ] `FunctionStep` — Did the action fire? What inputs did it receive? What did it return?
- [ ] `ReasoningStep` — Is the status GROUNDED?
- [ ] `PlannerResponseStep` — Review the safety score. Does the response content match action output?
- [ ] Multiple `run.llmstep` spans? — Expected in multi-action subagents (one per parse). Not a loop.
- [ ] Missing `after_reasoning` spans? — Check if `is_displayable: True` fired in that subagent.

### Key DMO Tables at a Glance

| Question | Table to Query |
|---|---|
| How many sessions this week? | `ssot__AiAgentSession__dlm` |
| What did users actually say? | `ssot__AiAgentInteractionMessage__dlm` |
| Which subagents and intents were invoked? | `ssot__AiAgentInteraction__dlm` |
| What actions errored? | `ssot__AiAgentInteractionStep__dlm` |
| Which agents/subagents participated? | `ssot__AiAgentSessionParticipant__dlm` |
| How many tokens/credits consumed? | `AiAgentGenerativeAiUsage_std__dlm` |
| What did the LLM actually receive in its prompt? | `GenAIGatewayRequest__dlm` |
| What did users rate as helpful or unhelpful? | `GenAIFeedback__dlm` |
| Which steps took the longest? | `ssot__TelemetryTraceSpan__dlm` |
| Where exactly did an action break? | `ssot__TelemetryTraceSpan__dlm` filtered by `ssot__StatusCode__c = 'ERROR'` |
| What quality score did a Moment receive? | `ssot__AiAgentTagAssociation__dlm` joined to `ssot__AiAgentTag__dlm` |
| What were the top user intents? | `ssot__AiAgentMoment__dlm` (requires Optimization enabled) |

### Infrastructure Readiness Checklist (Per New Org)

- [ ] Data Cloud provisioned and CRM Connector active
- [ ] `CopilotSalesforceAdmin` assigned to admin users
- [ ] `GenieAdmin` assigned to admin users needing Data Cloud access
- [ ] `AgentforceServiceAgentBuilder` assigned to service agent configuration admins
- [ ] `AgentforceDeveloperAndAdminTools` assigned to developers (verify purpose per org)
- [ ] Session Tracing enabled: Setup > Einstein Audit, Analytics, and Monitoring
- [ ] Agentforce Optimization enabled: same setup page
- [ ] Audit and Feedback enabled with target data space selected: same setup page
- [ ] Agent Platform Tracing enabled: Setup > Agent Platform Tracing
- [ ] Consumption Tagging app installed (if Consumption Analytics Dashboard required)
- [ ] Alert thresholds configured relative to expected session volume before go-live

### Escalation Spike Response Playbook

1. Confirm the spike is sustained (not a single-session anomaly) using the escalation-rate-by-day SOQL query.
2. Filter `ssot__AiAgentSession__dlm` to the affected time window. Pull 5-10 escalated session IDs.
3. Open session traces for each session. Look for a shared pattern: same subagent, same action, same error.
4. If the failure is a timed-out action: check Apex execution logs for CPU or SOQL limit violations.
5. If the failure is a grounding failure: apply Pattern D from Section 8.
6. If no session-trace signal is found: enable Agent Platform Tracing and run the error-span query against the affected time window.
7. After identifying root cause: fix in sandbox, validate in Testing Center, promote to production.

---
