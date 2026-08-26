# Tracing and Analytics in Agentforce

*Updated August 26, 2026*
*This guide was generated using AI with grounding in official Salesforce documentation. Review for accuracy before using.*

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
9. [Triage Before You Trace](#9-triage-before-you-trace)
10. [Choosing the Right Control](#10-choosing-the-right-control)
11. [Pattern H: Unexpected Agent Behavior](#11-pattern-h-unexpected-agent-behavior)
12. [Pattern I: Latency Diagnosis](#12-pattern-i-latency-diagnosis)
13. [Validating Your Change](#13-validating-your-change)
14. [When to Contact Support](#14-when-to-contact-support)
15. [Sandbox vs. Production Tracing](#15-sandbox-vs-production-tracing)
16. [Mapping Observability to Business KPIs](#16-mapping-observability-to-business-kpis)
17. [Credit Consumption Awareness](#17-credit-consumption-awareness)
18. [Quick-Reference Cheat Sheet](#18-quick-reference-cheat-sheet)

---

## 1. Why Observability Matters

An Agentforce agent is a probabilistic system. Unlike a deterministic Flow or Apex trigger, an agent reasons, makes decisions, and produces outputs that are not fully predictable at design time. That is exactly what makes agents powerful. It is also what makes observability non-negotiable.

**Without observability, you cannot answer the questions that matter:**

- Why did the agent escalate that session?
- Why is the deflection rate lower than expected?
- Why does the agent respond slowly in the afternoons?
- Is the agent actually resolving issues, or just deflecting them?
- Which knowledge gaps are causing the most user frustration?

**The business stakes are real.** Agentforce agents frequently handle customer-facing interactions at scale. A misconfigured instruction, a failing action, or a knowledge gap can affect thousands of sessions before anyone notices — unless monitoring catches it first. Observability converts reactive fire-fighting into a proactive, data-driven improvement loop.

For a Success Architect, observability is also a trust-building tool. Customers who can see exactly what their agent is doing, how it is performing, and where it needs improvement are customers who invest in the platform long-term.

---

## 2. Prerequisites and Infrastructure Setup

Agentforce observability depends on a stack of capabilities that must be explicitly enabled. None of them are on by default. Before advising a customer on tracing or analytics, confirm this infrastructure is in place.

### Required Foundation

- [ ] Data Cloud provisioned and CRM Connector active
- [ ] **Agentforce Default Admin** (`CopilotSalesforceAdmin`) assigned to admin users
- [ ] **Data Cloud Architect** (`GenieAdmin`) assigned to admin users needing Data Cloud access
- [ ] **Agentforce Service Agent Configuration** (`AgentforceServiceAgentBuilder`) assigned to service agent admins
- [ ] **Agentforce Developer and Admin Tools** (`AgentforceDeveloperAndAdminTools`) assigned to developers
- [ ] Session Tracing enabled (Einstein Audit, Analytics, and Monitoring Setup)
- [ ] Agentforce Optimization enabled (same setup page)
- [ ] Audit and Feedback enabled with target data space selected (same setup page)
- [ ] Agent Platform Tracing enabled (Setup > Agent Platform Tracing)
- [ ] Data Space name confirmed via CLI command (not assumed)
- [ ] `config.runtime` block reviewed: if no runtime behavior needs overriding, omit the block entirely. `runtime` is a sub-block of `config` with five optional boolean parameters (`streaming`, `thought_chunks`, `citation`, `groundedness`, `reset_to_initial_node`). Agent Script's compiler expects at least one property after a block header; an empty `runtime:` declaration produces a compilation error at deployment time, not a silent runtime failure. Confirm the `groundedness` flag state if `ReasoningStep` entries are absent from traces.
- [ ] Consumption Tagging app installed (if Consumption Analytics Dashboard required)
- [ ] Alert thresholds configured relative to expected session volume before go-live

### Permission Set Quick Reference

| Label | API Name | Assign To |
|---|---|---|
| Agentforce Default Admin | `CopilotSalesforceAdmin` | Admin users |
| Data Cloud Architect | `GenieAdmin` | Admin users needing Data Cloud access |
| Agentforce Service Agent Configuration | `AgentforceServiceAgentBuilder` | Service agent admins |
| Agentforce Developer and Admin Tools | `AgentforceDeveloperAndAdminTools` | Developers |

### Sandbox vs. Production Note

Both tracing toggles (Session Tracing and Agent Platform Tracing) must be explicitly enabled in production — they do not carry over from sandbox. After go-live, confirm admin users have **Data Cloud Architect** (`GenieAdmin`) and **Agentforce Default Admin** (`CopilotSalesforceAdmin`) assigned before running any SOQL against Data Cloud DMOs.

---

### Audit and Feedback: Additional Prerequisites

> **Important — Audit and Feedback is not on by default for multi-dataspace orgs.** It is auto-enabled only for single-dataspace orgs when Agentforce is turned on. Before writing any query against GenAI Audit DMOs, confirm all of the following are in place:
>
> - **Data 360 provisioned** and Einstein enabled in the org.
> - **Salesforce Standard Data Model version 1.130 or higher.** Agent Session Tracing specifically requires SSDM v1.130+.
> - **Setup path:** Setup > Einstein Audit, Analytics, and Monitoring Setup > toggle Audit and Feedback on, then select the target data space.
> - **Data availability:** Collected data appears in Data Cloud within 24 hours and refreshes hourly thereafter. This is a separate pipeline from STDM data.
> - **RAG quality metrics** (Answer Faithfulness, Answer Relevance, Context Relevance) require a second toggle confirmed verbatim in official Salesforce documentation: **"Knowledge/RAG Quality Data and Metrics."**
> - **Trust Layer metrics** (Toxicity, Prompt Injection, Instruction Adherence) require a Trust Layer data toggle. This toggle is believed to exist based on corroborating evidence but its exact UI name is not confirmed verbatim. Verify the current toggle name in Setup before communicating it to customers.
> - **PII warning:** Stored data can contain PII, PHI, and PCI. Dynamic data masking policies and data space permissions are required before this data is accessible.
>
> Any query in this guide that touches `GenAIGeneration__dlm` or other no-prefix GenAI Audit DMOs will return no data — or fail — if these prerequisites are not met.

### DMO Prefix: Standard vs. Legacy

Agentforce DMOs exist in two prefix families. Which one is live in a given org depends on when the org was provisioned. Both families are fully SOQL-queryable and identical in capability. No automatic migration occurs between them.

| Family | Prefix | How to Identify |
|---|---|---|
| Standard (newer orgs) | `std__` | Objects like `std__AiAgentSessionDmo__dlm` return rows |
| Legacy (existing orgs) | `ssot__` | Objects like `ssot__AiAgentSession__dlm` return rows |

> **Before writing any SOQL against DMOs in a customer org, run this check to determine which family is live:**
>
> ```sql
> SELECT COUNT(*) FROM std__AiAgentSessionDmo__dlm
> ```
>
> If this returns zero rows or an object-not-found error, the org is on the legacy `ssot__` prefix. Substitute `ssot__` equivalents throughout. If it returns rows, the org is on the standard prefix.
>
> The queries in this guide use `std__` as the primary prefix, with `ssot__` alternatives noted for Platform Tracing (where official Salesforce documentation leads with `ssot__`). Always verify prefix before delivering SOQL to a customer.

### A Third DMO Family: GenAI Audit

A separate, no-prefix family exists for GenAI Audit data. This family is architecturally distinct from the standard/legacy split above.

| Family | Prefix | Example Object | Populated When |
|---|---|---|---|
| GenAI Audit | _(none)_ | `GenAIGeneration__dlm` | Only when Audit and Feedback is explicitly enabled |

Do not mix GenAI Audit DMOs into SOQL queries against the `std__` or `ssot__` families. They are populated by a separate pipeline with a separate enablement requirement (SSDM v1.130+, Audit and Feedback toggle on).

### Data Freshness

| Pipeline | Refresh Cadence | Source |
|---|---|---|
| STDM (`std__` / `ssot__` session data) | ~15 min (skill file) or ~30 min (White Paper) | Two official sources; ~15 min is the more recent signal |
| Agent Analytics dashboards (Tableau Next) | 45–60 min lag from session time | Observed platform behavior |
| GenAI Audit DMOs (`GenAIGeneration__dlm` etc.) | Within 24 hours initially; hourly thereafter | Confirmed verbatim in Audit and Feedback PDF |

These are three separate pipelines. The three numbers are not in conflict. Set customer expectations accordingly: dashboards are not real-time.

---

## 3. The Three Pillars of Agentforce Observability

Agentforce observability is not a single feature. It is a stack of three complementary capabilities that answer different questions at different levels of granularity. A Success Architect should understand all three, know when to recommend each one, and be able to explain the difference to a non-technical stakeholder.

---

### Pillar I: Agentforce Analytics

| Label | Field Name | Notes |
|---|---|---|
| Average Quality Score | `Average_Quality_Score_clc` | Average 1–5 score across sessions |
| Quality Score Reasoning | `Quality_Score_Reasoning_clc` | LLM explanation for the score |
| Escalation Rate | `Escalation_Rate_clc` | Escalated sessions / all sessions |
| Escalated Sessions | `Escalated_Sessions_clc` | Sessions escalated to human or different agent |
| Deflection Rate | `Deflection_Rate_clc` | Deflected sessions / all sessions |
| Abandonment Rate | `Abandonment_Rate_clc` | Abandoned sessions / all sessions |
| Engagement Rate | `Engagement_Rate_clc` | Engaged sessions / all sessions |
| Average Session Duration | `Average_Session_Duration_clc` | In seconds |
| Average Moment Duration | `Average_Moment_Duration_clc` | In seconds |
| Average Agent Interaction Latency | `Average_Agent_Interaction_Latency_clc` | In milliseconds |
| Interaction Error Rate | `Error_Rate_clc` | Interactions with action or LLM steps only |
| Success Rate | `Success_Rate_clc` | Action steps completing without errors |
| Average Answer Faithfulness Score | `Average_Answer_Faithfulness_Score_clc` | 0–1; requires Audit and Feedback + Knowledge/RAG Quality toggle |
| Average Answer Relevance Score | `Average_Answer_Relevance_Score_clc` | 0–1; requires same |
| Average Context Relevance Score | `Average_Context_Relevance_Score_clc` | 0–1; requires same |
| Average Agent Toxicity Score | `Average_Agent_Toxicity_Score_clc` | 0–1; requires Audit and Feedback + Trust Layer data toggle |
| Average User Prompt Injection | `Average_User_Prompt_Injection_clc` | Requires same |
| Total Flex Credits | `Total_Flex_Credits_clc` | From enriched usage events |
| Unique Sessions | `Unique_Sessions_clc` | Distinct sessions in time frame |
| Unique Moments | `Unique_Moments_clc` | Distinct intents in time frame |
| Unique Tags | `Unique_Tags_clc` | Unique tags in time frame |
| Stickiness Rate | `Stickiness_Ratio_clc` | DAU/MAU ratio |
| High Adherence Response Rate | `High_Adherence_Response_Rate_clc` | Steps classified as high adherence; requires Audit and Feedback + Trust Layer data toggle |
| Positive User Feedback | `Positive_User_Feedback_clc` | Thumbs up from GenAI feedback data |
| Negative User Feedback | `Negative_User_Feedback_clc` | Thumbs down from GenAI feedback data |
| Task Resolution Rate | `Task_Resolution_Rate_clc` | Beta; Trust Layer task resolution detector |
| Total Agent Talk Duration | `Total_Agent_Talk_Duration_clc` | [^1] |

[^1]: Voice sessions only. Total agent speaking time in seconds, based on agent output message timestamps. Only sessions with a related voice call are included. Messages with missing start or end timestamps are excluded.

**Dimensions**

| Label | Field Name | Notes |
|---|---|---|
| Session Outcome | `Session_Outcome_Base_clc` | Consolidated outcome: escalated, deflected, abandoned, ambiguous, or not set. Use for outcome filtering and reporting across all terminal states. |
| Task Resolution Status | `Task_Resolution_Status_clc` | Indicates whether the agent fully resolved, partially resolved, or didn't resolve the user's request at the session level. Distinct from the Measure `Task_Resolution_Rate_clc`. Use this dimension to JOIN or filter in raw SOQL; use the Rate field for KPI reporting. Requires Trust Layer — see beta flag on `Task_Resolution_Rate_clc`. |
| Agent Adherence Status | `Agent_Adherence_Status_clc` | Instruction adherence level for the response (e.g., high, low, uncertain), from Trust Layer InstructionAdherence evaluation on GenAIContentCategory. Complements the Measure `High_Adherence_Response_Rate_clc`. Requires Audit and Feedback + Trust Layer data toggle. |
| Time to First Agent Token | `Time_To_First_Agent_Token_clc` | Time in milliseconds from end of user's message until generation of the first agent response token, per interaction. |
| Time to Last Agent Token | `Time_To_Last_Agent_Token_clc` | Time in milliseconds from end of user's message until generation of the last agent response token, per interaction. |

---

### Pillar II: Agentforce Optimization

**What it is:** A deeper analysis layer built on top of STDM that introduces the concept of **Moments** — structured units of user intent — and applies automated quality scoring and LLM-driven clustering to surface actionable improvement insights.

**The business framing:** "Where specifically is the agent underperforming, and what should we fix first?" Optimization moves you from the "what" of Analytics to the "how" of targeted improvement.

#### What a Moment Is

A Moment represents a distinct user intent within a session. A single session can contain multiple Moments — for example, a user who first asks about order status, then asks about a return policy, generates two Moments in one session. Moments are the granular unit that Optimization scores and clusters. They are what make intent-level analysis possible.

#### How the Optimization Pipeline Works

Understanding the pipeline timing is essential for setting accurate customer expectations.

**Moment generation** runs on a frequent schedule triggered by one of two conditions:

- Every 9 hours if there is at least one new closed session.
- Every 3 hours if there are more than 10 new closed sessions since the last run.

A session is considered "closed" after 3 hours of inactivity.

**Intent clustering and quality scoring** runs on a confirmed two-tier cadence:

- **Intent association and quality scoring:** Daily. New Moments are associated with existing intent tags and receive quality scores every day.
- **New intent tag creation (full clustering):** Weekly. New intent tag categories are created once per week.

This two-tier model means useful quality scoring data is available daily, not just after the weekly full clustering run. Set customer expectations accordingly: quality score data is available on day two, but the full intent taxonomy takes a week to mature.

**Important:** Meaningful clustering requires approximately 100 Moments (roughly 100 sessions, depending on complexity). Do not begin deep optimization work until after the first full weekly clustering run completes and sufficient data has accumulated.

**Historical data note:** If Session Tracing was already enabled before Optimization was turned on, the first pipeline run will analyze sessions from the last 30 days. Subsequent runs focus on the last 7 days.

#### Quality Scores: The Core Optimization Signal

Each Moment receives a quality score from 1 to 5, applied by an LLM-as-judge process. The score returned by the LLM is 1–5 and is bucketed based on defined thresholds:

| Score Range | UI Label |
|---|---|
| 4.0–5.0 | High |
| 3.0–4.0 | Medium |
| 2.0–3.0 | Low |
| 0–2.0 | Very Low |

Each score comes with a **Quality Score Reasoning** — a plain-language explanation generated by the LLM judge (for example: _"Agent didn't address the pricing question"_ or _"Agent provided accurate information but required excessive turns"_). This reasoning is what makes quality scores actionable.

> **Important constraint:** The quality scoring LLM-as-judge uses OpenAI/Azure OpenAI GPT-4o mini and is only available when the customer's Agentforce agent uses the Salesforce default model (OpenAI). If the customer has configured a different model, automated quality scoring is not available.

**Recommended approach for surfacing quality scores:** Use `Average_Quality_Score_clc` from the Analytics Semantic Layer. This is the official calculated field. Raw SOQL is documented below for advanced use cases.

#### The `AiAgentTagAssociation` DMO: A Complementary Tagging Layer

In addition to the numeric quality score, each Moment can receive categorical outcome tags via `std__AiAgentTagAssociationDmo__dlm`. These are a separate tagging layer alongside the score — not a replacement for it.

| Field (confirmed API names) | Type | Values |
|---|---|---|
| `std__IsPassed__c` | Boolean | True / False |
| `std__OutcomeType__c` | Text | `pass`, `fail`, or `not applicable` |
| `std__AssociationReasonText__c` | Text | LLM-generated plain-language reasoning |

Use the numeric quality score for trend analysis and bucketed dashboard reporting. Use `std__OutcomeType__c` and `std__AssociationReasonText__c` for per-Moment diagnostic drill-down.

#### Optimization DMOs

Optimization extends the core STDM with four additional DMOs.

---

## 4. Session Tracing vs. Agent Platform Tracing

Two separate tracing systems operate at different layers of the Agentforce stack. Many practitioners conflate them, which leads to using the wrong tool for a given diagnosis.

| Dimension | Session Tracing (STDM) | Agent Platform Tracing |
|---|---|---|
| **What it captures** | Agent decisions: subagent routing, action invocations, LLM reasoning steps, session outcomes | Back-end execution: span durations, infrastructure errors, service call timings |
| **Where data lives** | `std__AiAgent*Dmo__dlm` family in Data Cloud | `ssot__TelemetryTraceSpan__dlm` (legacy) / `std__TelemetryTraceSpanDmo__dlm` (standard) |
| **Primary question answered** | What did the agent do? | How did it execute, how long did it take, where did it fail? |
| **Toggle required** | Session Tracing (Einstein Audit, Analytics, and Monitoring Setup) | Agent Platform Tracing (separate toggle) |
| **OTel export** | No | Yes — SOQL, APM integration, and OTel API beta (Section 6) |

**Multi-agent session audit:** `std__AiAgentSessionParticipantDmo__dlm` records every entity — human or AI — that participated in a session, including participants from connected sub-agents across SOMA, MOMA, and 3P trust boundaries. This is the most reliable current mechanism for auditing multi-agent session participation.

---

## 5. Reading Session Traces

### Understanding the Parse: Why One Turn Produces Multiple Spans

When reading Platform Tracing span trees, a common point of confusion is seeing multiple `run.llmstep` spans for what appears to be a single user message. This is expected behavior.

**The primary unit of execution in Agent Script is the parse, not the user turn.** A parse is one complete cycle through a subagent's three lifecycle blocks (`before_reasoning`, `reasoning`, `after_reasoning`). The Atlas Reasoning Engine initiates a new parse in three situations:

1. On first entry into a subagent.
2. After every action call completes and returns a result, within the same subagent.
3. On every new user turn within the same subagent.

| Step Type | What It Represents | Key Fields to Check |
|---|---|---|
| `UserInputStep` | The raw user message as received | Does it match what the user sent? Encoding or truncation issues appear here. |
| `NodeEntryStateStep` | Subagent activation | Which subagent fired? Was it the expected one? Variable values at subagent entry are visible here — including `@system_variables.current_modality` and `@system_variables.current_connection` (262.12+). |
| `EnabledToolsStep` | List of actions available to the LLM at this point | Is the expected action listed? If not, check `available when` gate conditions. |
| `LLMStep` | LLM reasoning call | `messages_sent` shows the full compiled prompt; `response_messages` shows what the LLM decided to do. |
| `FunctionStep` | Action invocation | Input, output, and error. Primary step for diagnosing action failures. |
| `ReasoningStep` | Grounding assessment | `GROUNDED` or `UNGROUNDED`. Absent when `config.runtime.groundedness: false` is set. |
| `PlannerResponseStep` | Final agent response to user | Includes the safety score. Review content against expected output. |
| `TrustGuardrailsStep` | Instruction adherence evaluation | Shows whether the agent followed its instructions. LOW adherence signals an instruction issue. |
| `TransitionStep` | Subagent routing event | Where did the agent transition? Was it expected? As of 262.10, transitions to connected sub-agents are normal. |
| `SessionEndStep` | Session termination | How and why the session ended. |

**Channel-specific system variables (262.12+):** `@system_variables.current_modality` (e.g., `"voice"` or `"text"`) and `@system_variables.current_connection` are populated at the start of every inbound turn and are visible in `NodeEntryStateStep`. When diagnosing channel-specific failures, filter session traces by `current_modality` first.

**Voice-specific variables (262.14+):** `@system_variables.last_reply.interrupted` (boolean; true if the user interrupted mid-delivery) and `@system_variables.last_reply.interrupted_heard_text` (partial text heard before interruption) are useful when diagnosing voice sessions where users appear stuck in a loop. Confirm whether the loop is caused by interruptions rather than genuine misrouting.

### Grounding: The Hidden Quality Gate

Every LLM response in Agentforce goes through a grounding check by default. The `ReasoningStep` records whether the response is `GROUNDED` or `UNGROUNDED`.

> **Practitioner observation, not officially documented:** Based on consistently observed platform behavior, the agent's terminal fallback message ("I apologize, but I encountered an unexpected error") appears to be triggered whenever a turn produces empty content. This includes two consecutive UNGROUNDED `ReasoningStep` results, but may also be triggered by LLM Gateway throttling (429 errors), upstream service errors (SageMaker 424s, bot-svc-llm 502s), or other infrastructure conditions that cause an empty response. The exact internal mechanism is `response_factory._ensure_non_empty_inform_message()`, based on Slack evidence. If a customer is seeing the fallback message, investigate both grounding failures and infrastructure/Gateway health before assuming the cause is double-UNGROUNDED alone.

> **262.12 change:** The `config.runtime.groundedness` flag can now disable grounding explicitly. When `groundedness: false` is set, no `ReasoningStep` will appear in traces. Confirm this flag before treating a missing `ReasoningStep` as an anomaly.

Grounding failures are almost always fixable. The `FunctionStep` output contains the data; the `ReasoningStep` shows UNGROUNDED; the `LLMStep.response_messages` shows the agent inferring beyond that data. The fix is a targeted instruction update telling the LLM to cite specific fields verbatim rather than summarizing.

**Safety score monitoring:** Every agent response receives a safety score visible on `PlannerResponseStep.safetyScore`. Consistently low scores in a particular subagent indicate an instruction or content configuration issue worth investigating.

### Trace Reading Checklist (Per Turn)

- [ ] `UserInputStep` — Does the utterance match what you expected?
- [ ] `NodeEntryStateStep` — Did the correct subagent activate? Check `current_modality` if the issue is channel-specific.
- [ ] `EnabledToolsStep` — Is the expected action listed? If missing, check `available when` gate variable values.
- [ ] `LLMStep.messages_sent` — Did instructions compile correctly? Are variables interpolated? Is the Salesforce system prompt present (or intentionally absent via `strip_salesforce_instructions`)?
- [ ] `FunctionStep` — Did the action fire? What inputs did it receive? What did it return? Check for slot-filled inputs.
- [ ] `ReasoningStep` — Is the status GROUNDED? If the step is absent, check `config.runtime.groundedness`.
- [ ] `PlannerResponseStep` — Review the safety score. Does the response content match action output?
- [ ] Multiple `run.llmstep` spans? — Expected in multi-action subagents (one per parse). Not a loop.
- [ ] Missing `after_reasoning` spans? — Check if `is_displayable: True` fired in that subagent.
- [ ] `run.action.*` spans with no preceding `run.llmstep`? — May originate from an `after_response` block on a connected sub-agent.

---

## 6. Agent Platform Tracing: Service-Level Visibility

| Operation Name Pattern | What It Represents |
|---|---|
| `run.interaction` | Root span for the entire interaction |
| `run.llmstep` | An LLM reasoning call |
| `run.topic.*` | Subagent-level processing — local or connected. As of 262.10, `run.topic.*` spans may represent a connected (external/BYON) sub-agent. |
| `run.action.*` | An action invocation (Apex, Flow, etc.) — including actions fired from `after_response` blocks (no preceding `run.llmstep` in that case). Inline Skills invocations (262.14 pilot) also appear here. |
| `run.invokeActions.FLOW` | A Flow action execution |
| `run.invokeActions.EXTERNAL_SERVICE` | An external (MCP) action call |

**Span attributes matter:** Always check span attributes when a span's status or duration does not match the expectation from its operation name.

- `db.rows_affected=2847` on an action span means the backing query returned nearly 3,000 records — a performance and cost problem invisible from the session trace alone.
- `db.operation.name=query` on a span named `run.createrecord.account` reveals the span is performing a lookup, not a write.

### Span Field Reference

Key fields on `ssot__TelemetryTraceSpan__dlm` (substitute `std__` prefix for newer orgs):

| Field Label | API Name | Type | Description |
|---|---|---|---|
| Operation Name | `ssot__OperationName__c` | TEXT | Operation name; for Flow elements, the customer-facing FlowName or APIName |
| Duration | `ssot__DurationNumber__c` | DOUBLE | Total span duration in **milliseconds** (confirmed via Salesforce Platform Tracing blog) |
| Start Date Time | `ssot__StartDateTime__c` | DATETIME | Span start timestamp — use this field, not `StartTimestamp` |
| Status Code | `ssot__StatusCode__c` | TEXT | Result of span execution |
| Span Kind | `ssot__SpanKind__c` | TEXT | Type of span (e.g., `SPAN_KIND_INTERNAL`, `SPAN_KIND_SERVER`) |
| Telemetry Trace | `ssot__TelemetryTrace__c` | TEXT | Trace-level identifier correlating all related spans end-to-end |
| Telemetry Parent Span Id | `ssot__TelemetryParentSpanId__c` | TEXT | Parent span identifier; enables nested span hierarchies |
| Span Attribute Text | `ssot__TelemetrySpanAttributeText__c` | TEXT | Key-value metadata pairs annotating the span. This is where per-span diagnostic metadata lives — including `db.rows_affected`, `db.operation.name`, and other runtime attributes referenced in diagnostic patterns throughout this guide. |
| Span Event Text | `ssot__TelemetrySpanEventText__c` | TEXT | Structured log annotation at a singular point in time during the span. Useful for capturing discrete events (errors, retries) within a longer-running span. |
| Service Name | `ssot__ServiceName__c` | TEXT | Name of the backend service emitting the span, for example `coreapp.core-on-sam`. Filter or GROUP BY this field to isolate latency to a specific service boundary when a trace spans multiple services. See Pattern I. |

### Conversational Observability with Slackbot

Because Platform Tracing data lives in Data Cloud, it can be queried by any connected system. A practical pattern for enterprise customers is to wire SOQL query templates into a Slack canvas and connect that canvas to Slackbot, putting diagnostic capability in the hands of non-developer ops teams.

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

---

## 7. Dashboards and the Data Model

### Out-of-the-Box Dashboard Surfaces

Salesforce provides three OOTB dashboard surfaces.

#### Agentforce Analytics Dashboard

Your primary day-to-day monitoring surface. Available with Agentforce entitlements.

| Panel | Metric | Significance |
|---|---|---|
| Conversation Volume | Sessions per day/week | Adoption curve; validates channel awareness |
| Topic / Intent Breakdown | Most-invoked subagents | Reveals demand patterns and mis-routing |
| Session Duration | Average turn count and time | Long sessions may indicate loops |
| Escalation Rate | % of sessions escalated | Primary quality signal in weeks 1–2 |
| Deflection Rate | % resolved without human | Headline ROI metric |
| Sub-agent Invocation Count | Per-subagent invocation trends | Routing health and coverage gaps |

#### Consumption Analytics Dashboard (powered by Tableau Next)

Focused on credit and token consumption. Requires the Consumption Tagging app (via Digital Wallet on AppExchange).

| Panel | Metric | Operational Value |
|---|---|---|
| Daily Active Users | Users per agent per day | Growth tracking |
| Input vs. Output Token Breakdown | Token split by direction | Cost optimization signal |
| Token Usage by User | Heaviest consumers | Identify power users or anomalies |
| Usage by Agent | Agent-level consumption | Budget attribution |

#### Consumption Insights Dashboard (Data 360 Reports)

Granular consumption data including per-feature and per-model token breakdowns. Auto-installs with Data Cloud provisioning but requires data space configuration, governance policy, and appropriate permissions before reports are viewable.

---

### Confirmed DMO Relationship Map

```
std__AiAgentSessionDmo__dlm
    |-- std__AiAgentSessionEndType__c  (resolved / escalated / deflected / other)
    |
    +-- std__AiAgentSessionParticipantDmo__dlm  (via std__AiAgentSessionId__c)
    |       -- Links sessions to participant role and agent API name
    |       -- Join on Session Id to retrieve std__AiAgentApiName__c
    |       -- Covers all participants: human, AI, connected sub-agents (SOMA/MOMA/3P)
    |
    +-- std__AiAgentMomentDmo__dlm  (via std__AiAgentSessionId__c)
    |       -- std__AiAgentApiName__c available directly
    |       -- std__RequestSummaryText__c / std__ResponseSummaryText__c
    |          are LLM-generated SUMMARIES, not raw text
    |
    +-- std__AiAgentInteractionDmo__dlm  (via std__AiAgentSessionId__c)
    |       -- std__TelemetryTraceId__c bridges to TelemetryTraceSpan
    |
    +-- std__AiAgentInteractionStepDmo__dlm  (via std__AiAgentInteractionId__c)
            -- std__AiAgentInteractionStepType__c values:
               UserInputStep | LLMExecutionStep | FunctionStep
            -- std__NameInterfaceField__c: confirmed field (official DMO schema)
               carries step name identifiers including CLOSED_TRANSFERRED,
               CLOSED_USER_REQUEST, CLOSED_ACTION
            -- Direct FKs (no trace join needed):
               std__GenAiGatewayRequestId__c
               std__GenAiGatewayResponseId__c
               std__GenerationId__c
               std__TelemetryTraceSpanId__c
            -- Most efficient join hub in the schema

std__GenAiGatewayRequestDmo__dlm  (v260+)
    +-- std__GenAiGatewayResponseDmo__dlm  (via std__AiGatewayRequestId__c)
        +-- std__GenAiResponseGenerationDmo__dlm  (via std__AiGatewayResponseId__c)
                std__GeneratedResponseText__c        <- raw LLM output
                std__MaskedGeneratedResponseText__c  <- PII-masked

ssot__TelemetryTraceSpan__dlm  (legacy) / std__TelemetryTraceSpanDmo__dlm  (standard)
    -- Reached from Interaction (std__TelemetryTraceId__c)
       or InteractionStep (std__TelemetryTraceSpanId__c)
    -- ssot__DurationNumber__c / std__DurationNumber__c is in MILLISECONDS
       (confirmed via Salesforce Platform Tracing blog — no conversion needed)
    -- ssot__StartDateTime__c on the span object (NOT StartTimestamp)
    -- ssot__ServiceName__c: name of the backend service emitting the span
    -- ssot__TelemetrySpanAttributeText__c: key-value span metadata (db.rows_affected, etc.)
    -- ssot__TelemetrySpanEventText__c: structured log events within the span

std__AiAgentGenerativeAiUsageDmo__dlm  (v260+)
    -- Cross-cutting: carries std__AiAgentSessionId__c + std__AiAgentInteractionId__c
    -- Use for billing attribution queries

Analytics Semantic Layer (Agentforce Analytics Foundations in Data 360):
    -- Pre-built _clc fields for all standard KPIs
    -- Recommended over raw SOQL for standard metrics
    -- RAG/Trust Layer _clc fields require Audit and Feedback + respective toggles

GenAI Audit DMOs (ONLY when Einstein Audit and Feedback enabled):
    GenAIGeneration__dlm, GenAIGatewayRequest__dlm, GenAIGatewayResponse__dlm, etc.
    -- No std__ prefix; no Dmo suffix
    -- Requires SSDM v1.130+, Data 360 provisioned, Einstein on
    -- Data appears within 24 hours, refreshes hourly
    -- Separate pipeline from STDM; separate enablement requirement
    -- Short retention window (days, not weeks) — do not plan historical analysis against these DMOs
```

---

### Data Cloud SOQL Query Patterns

#### Session-Level Queries

**Session count and escalations by agent (last 7 days):**

```sql
SELECT
    p.std__AiAgentApiName__c,
    COUNT(*) AS total_sessions,
    SUM(CASE WHEN s.std__AiAgentSessionEndType__c = 'escalated' THEN 1 ELSE 0 END) AS escalations
FROM std__AiAgentSessionDmo__dlm s
JOIN std__AiAgentSessionParticipantDmo__dlm p
    ON s.std__Id__c = p.std__AiAgentSessionId__c
WHERE s.std__StartTimestamp__c >= LAST_N_DAYS:7
GROUP BY p.std__AiAgentApiName__c
```

> **Escalation SOQL and the semantic layer:** `std__AiAgentSessionEndType__c = 'escalated'` is a session-level field that provides a useful approximation for escalation counts. However, the semantic layer's `Escalation_Rate_clc` is computed from a more precise formula operating at the interaction step level:
>
> ```
> Escalation: SESSION_END step where std__NameInterfaceField__c = 'CLOSED_TRANSFERRED'
> Deflection:  SESSION_END step where std__NameInterfaceField__c = 'CLOSED_USER_REQUEST' OR 'CLOSED_ACTION'
> ```
>
> **`CLOSED_USER_REQUEST` is a deflection signal, not an escalation signal.** Raw SOQL filtering on session-level end type may diverge from `Escalation_Rate_clc` in edge cases. For authoritative KPI reporting, use `Escalation_Rate_clc` from the semantic layer. Raw SOQL is appropriate for exploratory or custom cross-DMO queries, but treat its escalation counts as approximations and note this distinction in any customer-facing deliverable.
>
> To align raw SOQL with the semantic layer formula, use the step-level pattern:
>
> ```sql
> SELECT
>     i.std__AiAgentSessionId__c,
>     MAX(CASE
>         WHEN st.std__AiAgentInteractionStepType__c = 'SESSION_END'
>          AND st.std__NameInterfaceField__c = 'CLOSED_TRANSFERRED'
>         THEN 1 ELSE 0
>     END) AS is_escalated
> FROM std__AiAgentInteractionDmo__dlm i
> JOIN std__AiAgentInteractionStepDmo__dlm st
>     ON st.std__AiAgentInteractionId__c = i.std__Id__c
> WHERE i.std__StartTimestamp__c >= LAST_N_DAYS:7
> GROUP BY i.std__AiAgentSessionId__c
> ```
>
> `std__NameInterfaceField__c` is confirmed via official DMO schema documentation.

**Sessions by channel type:**

```sql
SELECT
    std__AiAgentChannelType__c,
    COUNT(*) AS session_count
FROM std__AiAgentSessionDmo__dlm
WHERE std__StartTimestamp__c >= LAST_N_DAYS:30
GROUP BY std__AiAgentChannelType__c
ORDER BY session_count DESC
```

#### Turn-Level Analysis

**Failed interactions by step error (last 24 hours):**

```sql
SELECT
    i.std__TopicApiName__c,
    st.std__AiAgentInteractionStepType__c,
    st.std__SubType__c,
    st.std__ErrorMessageText__c,
    COUNT(*) AS error_count
FROM std__AiAgentInteractionDmo__dlm i
JOIN std__AiAgentInteractionStepDmo__dlm st
    ON st.std__AiAgentInteractionId__c = i.std__Id__c
WHERE st.std__ErrorMessageText__c != 'NOT_SET'
  AND i.std__StartTimestamp__c >= LAST_N_DAYS:1
GROUP BY
    i.std__TopicApiName__c,
    st.std__AiAgentInteractionStepType__c,
    st.std__SubType__c,
    st.std__ErrorMessageText__c
ORDER BY error_count DESC
```

> `std__AiAgentInteractionStepType__c` confirmed values for the `std__` family: `UserInputStep`, `LLMExecutionStep`, `FunctionStep`. Do not filter on legacy `ssot__` family step type values — those will return zero rows against `std__` objects and vice versa.
>
> Data Cloud uses `'NOT_SET'` as a null sentinel. Use `!= 'NOT_SET'` rather than `!= null` to avoid missing rows.

**Variable state at failure (post-session debugging):**

```sql
SELECT
    std__AiAgentInteractionStepType__c,
    std__SubType__c,
    std__PreStepVariableText__c,
    std__PostStepVariableText__c,
    std__InputValueText__c,
    std__OutputValueText__c,
    std__ErrorMessageText__c
FROM std__AiAgentInteractionStepDmo__dlm
WHERE std__SessionId__c = '<session_id>'
ORDER BY std__PrevStepId__c ASC NULLS FIRST
```

#### Optimization Quality Score Analysis

**Recommended approach — semantic layer:**

Use `Average_Quality_Score_clc` from Agentforce Analytics Foundations in Data 360. This is the officially provided calculated field and requires no manual join.

**Raw SOQL fallback (advanced use only):**

> **Field name note:** The semantic layer formula for `Quality_Score_clc` is defined as `INT([AI Agent Tag].[Value])`. The physical DMO field that "Value" maps to is `std__ValueText__c`, cast to integer. This is the best-supported interpretation based on the official formula, but it is not confirmed by live-org sampling. Verify `std__ValueText__c` returns numeric strings in your org before relying on this query in production.

```sql
WITH params AS (
    SELECT '<SESSION_ID>' AS session_id
),
msgs AS (
    SELECT
        m.std__MessageSentTimestamp__c          AS event_time,
        'MESSAGE'                                AS event_kind,
        m.std__AiAgentInteractionMessageType__c AS subtype,
        i.std__TopicApiName__c                  AS topic,
        m.std__ContentText__c                   AS content,
        CAST(NULL AS VARCHAR)                   AS input_value,
        CAST(NULL AS VARCHAR)                   AS output_value
    FROM std__AiAgentInteractionMessageDmo__dlm m
    JOIN std__AiAgentInteractionDmo__dlm i
        ON m.std__AiAgentInteractionId__c = i.std__Id__c
    JOIN params p ON m.std__AiAgentSessionId__c = p.session_id
),
steps AS (
    SELECT
        st.std__StartTimestamp__c               AS event_time,
        'STEP'                                   AS event_kind,
        st.std__AiAgentInteractionStepType__c   AS subtype,
        i.std__TopicApiName__c                  AS topic,
        st.std__NameInterfaceField__c           AS content,
        st.std__InputValueText__c               AS input_value,
        st.std__OutputValueText__c              AS output_value
    FROM std__AiAgentInteractionStepDmo__dlm st
    JOIN std__AiAgentInteractionDmo__dlm i
        ON st.std__AiAgentInteractionId__c = i.std__Id__c
    JOIN params p ON i.std__AiAgentSessionId__c = p.session_id
)
SELECT * FROM (
    SELECT * FROM msgs
    UNION ALL
    SELECT * FROM steps
) combined
ORDER BY event_time ASC
```

---

> ### Scenario 4: Latency Complaint with No Obvious Cause
>
> A customer reports their claims-processing agent "takes forever to respond." The OOTB dashboard shows elevated average session duration but no escalation spike and no error alerts. Session traces show `Get_Policy_Details` completed successfully.
>
> Agent Platform Tracing (previously toggled off) is enabled. The performance profiling query shows `run.action.Get_Policy_Details` averages 3,200ms with a max of 8,100ms. The span attribute `db.rows_affected=2847` reveals the action is returning nearly 3,000 records from an unfiltered query.
>
> The fix: Adding a `LIMIT` clause and a selective `WHERE` filter reduces average action duration from 3,200ms to 180ms.
>
> **Lesson:** Session Tracing confirmed the action ran. Platform Tracing revealed how it ran. Without span attributes, this root cause is invisible.

---

> ### Scenario 5: Action Output Ignored in Agent Response
>
> A customer's agent retrieves account data but consistently responds with generic messages instead of using the fetched information.
>
> The `FunctionStep` shows the action returned a full account record. The `LLMStep.response_messages` shows the LLM produced a response mentioning none of the returned fields. The `ReasoningStep` shows GROUNDED — meaning the LLM could have used the data, but chose not to.
>
> The fix: Update subagent instructions to explicitly name the output fields: _"Use the AccountName, ContractStatus, and RenewalDate fields from the action output in your response."_ After redeployment, 100% of tested sessions reference the correct field values.
>
> **Lesson:** Grounding checks verify that assertions are supportable. They do not force the LLM to surface all data. Instruction specificity does.

---

## 8. Common Diagnostic Patterns

These patterns cover the most frequently encountered agent issues. Each has a consistent signature in traces and a reliable fix direction.

### Pattern A: Wrong Subagent Invoked

**Symptom:** Users are routed to the wrong subagent for their intent.

**Where to look:** `LLMStep.tools_sent` — examine the descriptions of the available subagents as the LLM sees them. If the description for the correct subagent does not include vocabulary that matches the user's phrasing, routing fails.

**Fix direction:** Update the subagent description to include the vocabulary users actually use. The routing decision is entirely semantic.

---

### Pattern B: Action Not Invoked

**Symptom:** The agent responds without calling an expected action. The `FunctionStep` for that action is absent from the trace.

**Where to look:** `EnabledToolsStep` — is the action listed? If not, an `available when` gate evaluated to false. Check the variable values in `NodeEntryStateStep` to see the state of gate variables at the moment of evaluation.

**Design-time note:** The `available-when-non-boolean` lint flag (262.10+) catches `available when` conditions that resolve to non-boolean literals at compile time. This class of gate failure should be caught in sandbox before reaching production.

**Slot-fill behavior change (262.10+):** If the action is listed in `EnabledToolsStep` and does invoke (a `FunctionStep` is present), but the inputs look different from what the agent script specifies, check whether the action definition has required inputs (`is_required: true`) with no bound `with` clause. As of 262.10, the compiler auto-marks such inputs as `slot_filled_by: LLM`. The action will invoke, but the LLM will prompt the user for the missing parameter rather than failing silently. In traces, this appears as additional turns between the first `EnabledToolsStep` and the eventual `FunctionStep`.

**Fix direction:** If the gate condition is wrong, correct the variable logic. For slot-filled required inputs: bind all required inputs explicitly with a `with` clause or provide a safe default to prevent LLM-driven parameter resolution on sensitive fields.

---

### Pattern C: Action Invoked but Output Ignored

**Symptom:** The `FunctionStep` shows a successful action with data in the output field. The agent response does not use that data.

**Where to look:** The `LLMStep` immediately after the `FunctionStep`. Check `response_messages` to see whether the LLM produced a text response without referencing the tool output.

**Fix direction:** Update agent instructions to explicitly name the output fields the agent should include in its reply. The more specific the instruction, the more reliably the LLM surfaces the data.

---

### Pattern D: Unexpected Error Response

**Symptom:** Users receive "I apologize, but I encountered an unexpected error" or similar terminal fallback messages.

**Where to look:** Two consecutive UNGROUNDED `ReasoningStep` entries are one trigger — but not the only one. Also check:

- LLM Gateway health: look for 429 throttling errors in Platform Tracing spans during the same window.
- Upstream service errors: SageMaker 424s or bot-svc-llm 502s can also produce empty content that triggers the fallback string.
- Infrastructure patterns: if the fallback spikes at specific times of day or correlates with high session volume, suspect capacity or throttling before suspecting grounding.

**Fix direction for grounding-caused fallbacks:** Update agent instructions to constrain the LLM to assertions the action output can support. Avoid instructions that tell the LLM to infer or summarize context that is not in the data.

**Fix direction for infrastructure-caused fallbacks:** Review Gateway error rates, consider retry logic at the action layer, and escalate to Salesforce Support if 5xx errors are persistent.

> **Note:** The two-consecutive-UNGROUNDED threshold is a practitioner observation, not officially documented by Salesforce. The actual fallback mechanism (`response_factory._ensure_non_empty_inform_message()`) fires on empty content regardless of cause.

---

### Pattern E: Escalation Spike with No Surface Error

**Symptom:** Escalation rate spikes in the Analytics dashboard, but there are no error alerts and no obvious failures in the traces reviewed.

**Where to look:** Filter STDM sessions to the spike window. Look for shared patterns across multiple sessions: same subagent? Same time of day? Same action in the `FunctionStep`? Cross-reference with Apex execution logs if actions are timing out silently.

**Fix direction:** Identify the shared characteristic and address it directly. Silent timeout failures from platform limits (CPU, SOQL rows, heap) appear as `FunctionStep` errors in traces even when the top-level session trace does not flag an obvious failure.

---

### Pattern F: Latency with No Surface Error

**Symptom:** Users report slow responses. Session traces show actions completing successfully. No error alerts are firing.

**Where to look:** Start with Agens to rule out looping. Then query the TelemetryTraceSpan DMO for the interaction's trace ID. Check `ssot__DurationNumber__c` (in milliseconds — no conversion needed) and `ssot__TelemetrySpanAttributeText__c` for the action span in question. If the trace spans multiple service boundaries, filter or GROUP BY `ssot__ServiceName__c` to isolate latency to a specific backend service. The value is the internal service name emitting the span — for example, `coreapp.core-on-sam`.

**Root cause:** The action ran successfully but returned too much data (visible as a high `db.rows_affected` value in `ssot__TelemetrySpanAttributeText__c`), causing the LLM to spend extra time processing a large payload.

**Fix direction:** Add `LIMIT` clauses and selective `WHERE` filters to the backing Apex or Flow query. For a full latency diagnostic framework — including how to isolate which pipeline step is slow before querying spans — see [Pattern I: Latency Diagnosis](#12-pattern-i-latency-diagnosis).

---

### Pattern G: Missing `after_reasoning` Spans

**Symptom:** A Platform Trace span tree shows no spans corresponding to an `after_reasoning` block that exists in the Agent Script.

**Where to look:** Check whether the action that preceded the missing block has `is_displayable: True` set.

---

### Testing Center vs. Optimization: Choosing the Right Quality Signal

| Dimension | Testing Center LLM Judge | Agentforce Optimization Quality Score |
|---|---|---|
| **When** | Pre-production, in sandbox | Post-deployment, in production |
| **Scale** | 0–5 numeric (3 or above = pass) | 1–5 numeric (bucketed: Very Low / Low / Medium / High) |
| **Scope** | Per test case | Per Moment (distinct user intent) |
| **Where results live** | Testing Center UI | STDM Optimization DMOs (`std__AiAgentTagAssociationDmo__dlm`) |
| **LLM judge model** | GPT OSS on Salesforce SageMaker, routed through Einstein Trust Layer | OpenAI/Azure OpenAI GPT-4o mini (requires Salesforce default model in the agent) |
| **Purpose** | Validate agent behavior before release | Monitor and improve quality in production |

Cross-reference between the two is useful. Moments that receive Low or Very Low quality scores in Optimization can seed new test cases in the Testing Center for regression coverage in the next release cycle.

The categorical fields `std__IsPassed__c`, `std__OutcomeType__c` (pass/fail/not applicable), and `std__AssociationReasonText__c` sit on `std__AiAgentTagAssociationDmo__dlm` alongside the numeric quality score. They are a complementary tagging layer — not a substitute for the numeric score. Use the numeric score for trend analysis and bucketed dashboard reporting. Use `std__OutcomeType__c` and `std__AssociationReasonText__c` for per-Moment diagnostic drill-down.

### Agentforce Testing Center

The Agentforce Testing Center bridges the pre-production and production observability gap. It is a sandbox-only tool that enables rigorous, at-scale testing of agent behavior before any code reaches production.

#### What Testing Center Does

Testing Center runs test cases against an agent in sandbox and evaluates each response using an LLM-as-judge process.

| Evaluation Type | What It Checks |
|---|---|
| Topic Classification | Did the right subagent handle this? |
| Action Sequences | Did the agent invoke the expected actions in the expected order? |
| Response Quality | LLM-as-judge scoring (0–5 scale; 3 or above = pass) |
| Text Quality Metrics | Conciseness, completeness, coherence |
| Citation Support | Does the agent correctly cite knowledge articles? |
| Instruction Adherence | Did the agent follow its tone and behavioral instructions? |
| Latency | Response time measurement |

The LLM-as-judge uses a separate, internally hosted model (GPT OSS on Salesforce SageMaker) — not the agent's own reasoning model — running in the same region as the customer's Data 360 instance, routed through the Einstein Trust Layer.

#### Key Limits

> **Documentation conflict — do not publish either number as authoritative without live-org verification:**
> Salesforce Help article 005228642 (published 2026-05-28) states **500 max test cases per job, 10 jobs per hour**, with 20–30 cases recommended per batch. Trailhead's "Trust Your Agents" module states **1,000 test cases per test, 10 jobs per 10-hour window**. Both are official, dated Salesforce sources and they disagree. Verify the current limits in your specific org before planning large test runs.

**No additional license required.** Testing Center is automatically available to all Agentforce customers in sandbox environments at no additional cost.

#### Recommended Testing Approach

Cover four dimensions:

- **Features** — core capabilities (case creation, order lookup, policy retrieval)
- **Scenarios** — edge cases (no match found, incomplete information, unsupported requests)
- **Personas** — authenticated vs. unauthenticated, mobile vs. desktop
- **Guardrails** — off-topic inputs, prompt injection attempts

Test cases can be created by uploading a CSV, using AI-generated suggestions, importing from knowledge articles, or importing a conversation from Agent Builder.

#### Testing Center and the Observability Continuum

1. **Build time:** CLI preview traces (`sf agent preview`) for individual utterance debugging during development.
2. **Pre-production:** Testing Center for at-scale batch evaluation, routing validation, and action sequence verification in sandbox.
3. **Production:** STDM dashboards, Optimization, and Platform Tracing for ongoing monitoring and improvement.

Each stage uses the same underlying session tracing data. The tools scale from a single developer reviewing one trace to an org-wide automated evaluation of hundreds of sessions.

---

## 9. Triage Before You Trace

> **New content — sourced from Salesforce Knowledge Article 005391239 (Aug 20, 2026)**

Before opening a trace or changing a single instruction, run these quick checks. Many issues resolve here in minutes, before any deeper investigation is needed.

**Why this matters for your customers:** Agentforce uses an LLM reasoning engine to generate responses. The instinctive fix when something goes wrong — "add another instruction telling it not to do that" — is not always the right approach, and can make the agent harder to manage over time. These checks help establish whether you are dealing with a repeatable configuration problem, normal model variability, or a runtime issue — before deciding how to respond.

### The Quick-Check Sequence

Run through these in order before doing anything else:

1. **Run the same input multiple times.** Agentforce uses an LLM and its behavior can be probabilistic. Repeating the same input helps determine whether the behavior is consistent or intermittent. A behavior that only appears once may be normal variability.

2. **Try a few different phrasings of the same request.** A fix that works only for one exact wording may not address the underlying issue.

3. **Reproduce the behavior in a minimal test configuration** — with as few custom subagents, actions, and instructions as possible. If the behavior still occurs, that points away from the specific customization and toward a broader configuration, data, or runtime issue.

4. **Check activation and permissions.** Verify that the agent, relevant subagents, actions, and required permissions are configured correctly.

5. **Use Plan Tracer when testing in Agent Builder.** It allows you to inspect the execution plan, including subagent selection and action selection, without needing full session tracing infrastructure.

6. **Use Agentforce Session Tracing when available.** Session Tracing provides structured telemetry — including interactions, reasoning-engine executions, actions, prompt and gateway inputs/outputs, errors, and final responses — that can identify exactly where a session behaved unexpectedly.

7. **If you have already made a change, verify that it was actually applied.** Confirm the configuration was saved, published or activated as required, and that you are testing the updated version. This is a common cause of apparent "my fix did nothing" situations.

### Reading the Failure Pattern

Once you have run the input multiple times, use this table to decide where to look next:

| What you observe | What it suggests | What to do |
|---|---|---|
| Fails the same way every time | A repeatable configuration, data, action, setup, or runtime issue | Locate the failing layer and address that layer directly |
| Sometimes succeeds and sometimes fails on similar requests | Ambiguous configuration or instructions, or normal LLM variability | Inspect the relevant control and test multiple variations |
| Only fails for one specific input or phrasing | An edge case, missing data, or ambiguous instruction | Add a targeted rule or fix the underlying data or action |
| Wording changes but the outcome remains correct | Normal variation in generated language | Focus on whether the required outcome is correct rather than identical wording |

---

## 10. Choosing the Right Control

> **New content — sourced from Salesforce Knowledge Article 005391239 (Aug 20, 2026)**

Not every agent problem is an instructions problem. Before troubleshooting, understand the full set of controls available — choosing the wrong one means repeatedly rewriting instructions without addressing the underlying cause.

**The business framing:** If something must happen the same way every time, do not rely solely on natural-language instructions to enforce it. Instructions are guidance to a probabilistic model. Business-critical behavior needs a deterministic control.

### The Six Controls

| # | Control | What it does | When to reach for it | Do not use it for |
|---|---|---|---|---|
| 1 | **Instruction-free subagent and prompt action selection** | Allows the agent to select the appropriate subagent and prompt action without custom instructions | Simple, low-stakes choices where flexibility is acceptable | Business-critical behavior where a specific outcome must always occur |
| 2 | **Instructions** | Provides natural-language guidance to a subagent or action | Judgment calls, tone, preferences, and general behavioral guidance | Critical validation, sensitive business rules, behavior that must happen the same way every time, or fixing subagent routing problems (instructions do not affect selection — see below) |
| 3 | **Data grounding** | Provides information from Knowledge, Data Cloud, or other sources the agent can use to answer a request | When the agent needs accurate, supported facts or records | Decisions that do not depend on retrieving specific information |
| 4 | **Variables** | Passes data explicitly through context or action outputs instead of relying on the model to infer values from conversation text | Values that must reliably control filters, actions, or subsequent steps | Simple conversational guidance that belongs in instructions |
| 5 | **Deterministic Actions** | Uses Apex, APIs, or Flow to perform defined operations | Business-critical logic, validation, calculations, integrations, or processes that must execute reliably | Simple conversational guidance where some variation is acceptable |
| 6 | **Agent Script** | Provides deterministic authoring: ordered logic, conditional behavior, and controlled transitions | When you need deterministic behavior around transitions, reasoning steps, or business rules | Problems that can be reliably handled by simpler controls above |

**Practical rule of thumb:** If you have repeatedly rewritten the same instruction and the behavior remains inconsistent, consider whether the problem actually needs a different control — such as grounding, variables, a deterministic action, or Agent Script.

### The Critical Routing Distinction

This is the single most common misconception in Agentforce troubleshooting, and it is worth calling out explicitly.

> **A subagent's routing and selection is driven only by its name and classification description — never by its scope or instructions.** Both scope and instructions are only read after a subagent has already been selected.

If the wrong subagent is being selected, editing that subagent's scope or instructions will not fix it. Rewrite the **classification description** instead. Make it specific and distinct in natural language, cover the trigger phrases you expect, and ensure it does not overlap with other subagents' descriptions.

Salesforce recommends limiting an agent to roughly **10–15 subagents** and assigning no more than **15 actions to a subagent** to help reduce inconsistency and improve routing performance. More choices make selection harder for the routing model.

### Symptom-to-Control Mapping

Use these tables to match what you are observing to where the problem is most likely occurring.

#### A. Agent behavior, instructions, and subagent/action selection

| What you're seeing | What's likely happening | Where to check | What to change |
|---|---|---|---|
| Agent is slow, inconsistent, or appears to make unsupported decisions | Instructions may be overly long, complex, or ambiguous | Review the subagent and action instructions | Make instructions concise, direct, and specific. Remove unnecessary context and contradictory rules. |
| Wrong subagent is selected | Subagent classification descriptions may overlap or be too vague — subagent instructions and scope have no effect on selection | Compare classification descriptions and names across subagents | Rewrite the classification description to be specific and distinct. Do not edit the subagent's instructions or scope to try to fix this. |
| Wrong action is selected within a subagent | Action descriptions may have overlapping or unclear boundaries | Compare action names and descriptions | Make each action description specific and clearly distinguish what belongs and does not belong to that action. |
| Agent becomes harder to manage as more subagents or actions are added | More choices can make routing and action selection harder | Review the number of subagents and actions assigned to the affected subagent | Limit an agent to roughly 10–15 subagents and no more than 15 actions per subagent. |
| Multi-step process happens out of order or a step is skipped | The sequence is expressed as natural-language instructions rather than deterministic logic | Review whether the sequence is business-critical | For critical sequences, move the logic into Flow, Apex, API-based actions, or Agent Script. |
| Action receives the wrong, missing, or malformed input | The input may not be clearly defined, validated, or mapped | Check the action input configuration, instructions, mappings, and underlying action logic | Define the input's purpose and format clearly. Prefer validation and formatting in deterministic logic and use variable mapping when the value can be passed deterministically. |
| Agent escalates unexpectedly or repeats an action | The action may be failing, instructions may trigger escalation, or the agent may be unable to complete the user's intent | Review action execution, errors, escalation instructions, and the execution trace | Fix the underlying action failure, refine escalation behavior, or simplify the execution path. |

#### B. Grounding, data, and response validation

Before the final response is delivered, Agentforce performs a grounding check to verify the response is based on accurate information from actions or instructions, follows the relevant subagent instructions, and stays within the subagent's scope. This can result in a response being revised before it is shown to the user.

| What you're seeing | What's likely happening | Where to check | What to change |
|---|---|---|---|
| Agent gives an answer and then visibly retracts or rewrites it | The generated response may not have satisfied the grounding check | Review the subagent scope, instructions, and data or action outputs | Narrow the scope and ensure the response is based on the correct data or action output. |
| Conversations feel slower, especially when responses are long | Additional context, action execution, and response validation can increase processing time | Review the amount of context and data being passed to the agent | Reduce unnecessary context, narrow scope, and avoid returning large amounts of unnecessary data. |
| Answer is incorrect or unsupported even though the agent used Knowledge | Retrieved information may be incomplete, incorrect, or not the information needed for the request | Review Knowledge retrieval, grounding configuration, and returned content | Improve the source content, retrieval configuration, or grounding strategy. |
| No citations are shown even though Knowledge was used | Citation behavior depends on the Knowledge or action configuration and response path | Review the Knowledge or action citation configuration | Enable citations where supported and appropriate. |
| Response or generated content is cut off | The response or action output may have exceeded an applicable limit | Check the size of the generated response and action output | Avoid unnecessarily large outputs and return only the information the agent needs. |
| A fixed message is altered or not delivered as expected | The message may be generated by the agent rather than delivered deterministically | Check how the message is generated | For content that must remain exact, deliver it through a deterministic mechanism such as Flow or Agent Script. |

#### C. Setup, permissions, and availability

| What you're seeing | What's likely happening | Where to check | What to change |
|---|---|---|---|
| Agent is completely unresponsive or repeatedly shows "Something went wrong, refresh the conversation" | Agentforce may not be fully activated or required configuration may be missing | Review the relevant Agentforce activation and configuration and confirm the required agent exists | Correct the activation or configuration and retest. |
| Subagent or action is unavailable even though it should apply | A filter may exclude it, or the running user or service user may lack permission | Check filter conditions and relevant permission assignments | Correct the filter or work with your org administrator to provide the required permissions. |
| Feature works live but not in Agent Builder, or vice versa | The testing environment may not have the same conversation context or variable values | Check whether filters depend on context variables | Provide appropriate test or default values when testing. |
| Subagent or action is selected correctly only sometimes | A filter variable may be populated through nondeterministic instructions rather than deterministic mapping | Check how the variable is populated | Map the variable directly from an action output or another deterministic source. |
| A Flow interview fails during agent execution | The Agentforce service user or running context may be missing required permissions, or the Flow itself may have an error | Review Flow errors, permissions, and the running context | Fix the Flow or provide the required permissions according to your Salesforce configuration. |
| Escalations are routed somewhere unexpected | Escalation, fallback, channel, or routing configuration may not match the intended behavior | Review escalation configuration and channel or routing setup | Correct the relevant escalation or routing configuration. |
| Agent responds in the wrong language | Agent language, locale, channel, or instruction language may not align | Review the agent language configuration, locale, channel or session settings, and language used in instructions | Correct the relevant language or locale configuration and keep instructions language-consistent. |
| Links are missing from responses | A URL may be filtered, unavailable to the response path, or restricted by security configuration | Review the relevant URL or trusted URL configuration and the action that produces the link | Correct the applicable URL or security configuration where supported. |

---

## 11. Pattern H: Unexpected Agent Behavior

> **New content — sourced from Salesforce Knowledge Article 005391239 (Aug 20, 2026)**

**Symptom:** The agent is doing something you did not expect — wrong routing, wrong response, wrong action, skipped step — and repeated instruction rewrites have not fixed it.

**Business impact:** Repeated instruction edits without a structured diagnosis cause agent configurations to accumulate contradictory rules over time. This makes the agent progressively less predictable and harder to maintain. The right approach is to isolate which layer of the execution path produced the unexpected behavior, then apply the control that operates at that layer.

### Diagnostic Sequence

Work through these layers in order. Stop at the first layer that explains the behavior and apply the fix at that layer rather than reaching for instructions.

**1. Subagent selection**

Check the classification description, not the instructions or scope. Run the same input multiple times. If routing is inconsistent, the descriptions of two or more subagents likely overlap in vocabulary. Rewrite the classification description of the intended subagent to be more specific and distinct.

**2. Action selection and execution**

Check whether the expected action appears in `EnabledToolsStep`. If it does not, an `available when` gate evaluated to false — inspect the gate variable values in `NodeEntryStateStep`. If the action does appear but the inputs are wrong, check whether the action has required inputs with no bound `with` clause.

**3. Data and Knowledge output**

Check `FunctionStep` output. Did the action return data? Was it the right data? If Knowledge was used, was the retrieved content accurate and complete? An incorrect response despite a successful action call usually means the LLM was not explicitly instructed to reference specific output fields.

**4. Instructions and prompting**

Only reach for instructions after confirming the problem is not in routing, action selection, or data. When editing instructions, make them concise, direct, and specific. Remove contradictory rules and unnecessary context. Long, paragraph-style instructions increase processing time and reduce reliability.

**5. Configuration and system constraints**

Check activation status, service user permissions, filter conditions, and channel configuration. A subagent or action that is unavailable in production but works in Agent Builder often indicates a filter variable that depends on conversation context not present in the testing environment.

> ### Scenario 6: Instruction Rewrites That Never Stick
>
> A financial services customer has rewritten their claims subagent's instructions four times in two weeks. Each rewrite helps briefly, then the behavior drifts back. Escalation rate on that subagent is 22% above average.
>
> Working through the diagnostic sequence: subagent routing is correct (confirmed via Plan Tracer). Action selection is consistent. Data is being retrieved. The actual problem is a multi-step claims verification process being expressed entirely in natural-language instructions — "always check claim status before providing settlement details, then verify the policy is active before discussing options."
>
> The sequence is business-critical. Moving it into a deterministic Flow action immediately stabilizes behavior. The instruction rewrites were the wrong control for the problem.
>
> **Lesson:** When instructions are being rewritten repeatedly without lasting effect, evaluate whether the problem requires a deterministic control — grounding, variables, a deterministic action, or Agent Script.

---

## 12. Pattern I: Latency Diagnosis

> **New content — sourced from Salesforce Knowledge Article 005391243 (Aug 20, 2026)**

**Symptom:** Users report the agent feels slow. Dashboard shows elevated session duration or interaction latency. No error alerts are firing and actions are completing successfully.

**Business impact:** Perceived latency is a primary driver of user abandonment and low satisfaction scores. A slow-feeling agent is rarely caused by one thing running slowly — a response passes through a sequence of steps before it reaches the user, and any one of them can add noticeable time. The diagnostic approach is to identify which step is slow, then apply the fix that targets that step directly.

### Step 1: Know What You Are Measuring

Three metrics tell you different things and are available from the Analytics Semantic Layer via `Time_To_First_Agent_Token_clc` and `Time_To_Last_Agent_Token_clc`:

| Metric | What it measures | Why it matters |
|---|---|---|
| **Time to First Token (TTFT)** | How long before the response starts appearing | Drives how responsive the agent feels — this is what a user notices while waiting |
| **Time to Last Token (TTLT)** | How long until the full response finishes | Matters most for longer answers and for anything downstream that waits on the complete response |
| **End-to-end latency** | Total time from the user's message to a fully delivered response, including everything the platform does around the model call | The number that best reflects the user's actual experience |

**Reference thresholds (text/chat):** Under approximately 5 seconds generally feels fine. 6–10 seconds is usually acceptable for a more complex request. 10–20 seconds starts to feel slow. Beyond approximately 20 seconds, most users assume something is wrong.

**Voice is much less forgiving.** Anything much past approximately 5 seconds breaks the feel of a real-time conversation. Voice has additional latency components that text does not — see the Voice section below.

These are general guidelines, not a guaranteed response-time SLA. Complex, multi-step requests will legitimately take longer than simple ones.

### Step 2: Understand the Pipeline

A single turn passes through this sequence before the user sees anything. Diagnosing slowness means finding which step is taking longer than expected — not assuming it is the model.

| Step | What happens |
|---|---|
| 1. Channel delivery | The message reaches Agentforce from its origin channel (web chat, Messaging, voice, Slack, etc.) |
| 2. Session routing | The platform sets up or resumes the conversation session |
| 3. Trust Layer safety check | An input-side safety and policy check runs before reasoning begins |
| 4. Topic/agent routing | The request is classified to the right subagent |
| 5. Reasoning and planning | The agent decides what to do, including which actions to call |
| 6. Action execution | Any Flow, Apex, or API actions run, including calls to external systems |
| 7. Response generation | The model generates the response text |
| 8. Grounding/accuracy validation | The response is checked against data and instructions before delivery |
| 9. Delivery | The response is sent back through the originating channel |

### Step 3: Find Where the Time Is Going

Enable Agentforce Observability via Setup, then search "Einstein Generative AI" and open Einstein Audit, Analytics, and Monitoring Setup. Confirm Audit and Feedback and Agentforce Session Tracing are both on. Once enabled, session data including step and turn duration becomes queryable via the STDM, and the built-in Agent Analytics dashboards surface agent-level performance metrics.

For span-level breakdown, query the `TelemetryTraceSpan` DMO as described in Section 6. Check `ssot__DurationNumber__c` (in milliseconds, no conversion needed) and filter or GROUP BY `ssot__ServiceName__c` to isolate latency to a specific backend service.

**Reading the signal:**

| What you observe | What it usually points to | Fix |
|---|---|---|
| TTFT is slow and consistent across most requests | Model choice, instruction length, or subagent/action count | Fixes 1 and 2 |
| TTFT is fast but the full response takes a long time | Response length, model choice, or streaming not enabled | Fixes 1 and 3 |
| Slowness is concentrated around specific action calls | That action's underlying Flow or Apex logic, or the external system or API it calls | Fix 4 |
| Slowness is concentrated around Knowledge or data retrieval steps | Knowledge base size, chunking, or an overly broad grounding scope | Fix 5 |
| Slowness appears mainly when a request crosses between subagents | Handoff overhead between subagents | Fix 6 |
| Slowness only shows up on one channel (e.g., voice but not web chat) | Channel-specific overhead, not the agent's reasoning | Fix 7 and the Voice section below |
| Slowness is broad, not tied to a specific subagent or action | Worth raising with Support | Fix 8 |

### Step 4: Match the Fix to What You Found

| # | Fix | When it applies |
|---|---|---|
| 1 | **Match the model to the task** | If a subagent only needs simple lookups or short factual answers, a faster or lighter model is often enough. Reserve the most capable model for genuinely complex reasoning. |
| 2 | **Shorten and simplify instructions** | Long, paragraph-style instructions take longer for the model to process on every single turn. Instead of "Please make sure to always check with the customer about their device type before helping with any troubleshooting steps, since this affects what advice is relevant," try "Before troubleshooting, identify the device type (iOS or Android) and include it in the search query." Shorter, direct instructions are both faster and more reliable. |
| 3 | **Turn on streaming where supported** | Streaming does not reduce total processing time, but it gets the first part of the response in front of the user much sooner, which significantly improves how fast the interaction feels. Streaming is generally not available for voice, where the full response is usually needed before it can be spoken. |
| 4 | **Reduce and parallelize action calls** | If a turn depends on multiple sequential actions, check whether any can run in parallel instead of one-after-another. Also check the response time of any external system or API an action calls — a slow downstream integration will make the agent look slow even when the agent itself is fine. |
| 5 | **Optimize knowledge retrieval** | Narrow the grounding scope for a subagent to what is actually relevant, and check that knowledge content is chunked into reasonably sized, well-structured pieces rather than a few very large documents. |
| 6 | **Minimize multi-agent and subagent handoffs** | Each handoff between subagents adds a processing step. Keep the structure as shallow as the use case allows rather than routing through several layers by default. |
| 7 | **Tune and test per channel** | Voice, chat, and messaging channels have different overhead. Benchmark each channel separately rather than assuming a fast web chat experience means voice will also be fast. |
| 8 | **Escalate infrastructure or region concerns to Support** | If none of the above explains broad, consistent slowness, this is worth bringing to Support rather than continuing to tune configuration. |

> **Common misconception:** Dynamic Voice Routing (DVR) simplifies how voice channels are configured and integrated, but it is not a latency fix. Do not expect enabling DVR to resolve a slow-voice-agent problem on its own.

### Voice Latency: A Separate Pass

Voice conversations feel slower than the same delay would feel in text. Real-time spoken conversation has much less tolerance for pauses. Voice requires its own dedicated assessment, separate from chat performance.

**Why voice is different:** Voice latency includes components that text does not — telephony or call setup, speech-to-text, routing, agent processing, text-to-speech, and the return path back to the caller. A delay can originate in any of these, not just in agent reasoning. A fast web chat agent does not automatically translate to a fast voice agent.

**Practical guidance for voice:**

- Target end-to-end response time well under 5 seconds where possible.
- Keep voice-specific subagent instructions especially lean. Long instructions that work acceptably in chat increase latency noticeably in voice.
- Keep spoken responses reasonably short. A response that reads fine in chat can feel long when spoken aloud.
- Test and benchmark voice as its own channel. Do not assume chat performance transfers.

> ### Scenario 7: Voice Agent Latency Complaint After Go-Live
>
> A retail customer's Agentforce voice agent receives strong marks in chat-channel testing but generates customer complaints about slow responses on voice two weeks after go-live. The OOTB dashboard shows average interaction latency of 8.2 seconds — acceptable for chat, but well past the voice threshold.
>
> Session Tracing is already enabled. Step duration data shows the slowness is not concentrated in any single action. Span-level analysis shows `run.llmstep` averaging 5.1 seconds, with the bottleneck in response generation. The voice subagent has the same lengthy instructions as the chat subagent — they were copied directly.
>
> Two targeted changes: instructions are shortened from 340 words to 80 words (Fix 2), and responses are constrained to two sentences for voice-specific subagents. Average interaction latency drops to 3.4 seconds.
>
> **Lesson:** Voice latency is a separate problem from chat latency, even on the same agent. Benchmark and tune each channel independently. Instructions that are acceptable for chat are often too long for voice.

---

## 13. Validating Your Change

> **New content — sourced from Salesforce Knowledge Article 005391239 (Aug 20, 2026)**

Do not make a change and assume it worked. Do not rely on a single conversation to prove it. Testing whether an action's logic works and testing whether the agent chooses and uses the action correctly are different questions and require different tools.

| What you're testing | The question | Where to check |
|---|---|---|
| **Action logic** | Does the Flow, Apex, or API actually do the right thing for known inputs? | Flow Debugger, Apex debug logs, or direct action testing |
| **Agent behavior** | Does the agent select the right subagent and action and follow the intended instructions? | Agent Builder testing or preview and Plan Tracer |
| **Production behavior** | Does the change work across varied real sessions? | Session Tracing and review across multiple sessions |

### A Practical Validation Pattern

1. **Record the baseline** — capture what happened before the change using the original input.
2. **Make one targeted change at a time** so you can identify which change affected the outcome.
3. **Re-run the original input plus 2–3 variations** of the same request.
4. **Check neighboring behavior** after changes to routing, scope, instructions, or filters.
5. **Validate both positive and negative cases** — confirm the agent does the intended thing and does not incorrectly apply the change to unrelated requests.
6. **Keep the change only if it improves the intended behavior without introducing a regression.**
7. **Record a short before-and-after note** so the investigation can be understood if the behavior resurfaces later.

---

## 14. When to Contact Support

> **New content — sourced from Salesforce Knowledge Articles 005391239 and 005391243 (Aug 20, 2026)**

Contact Salesforce Support when:

- The agent is completely unresponsive and there is no indication that a conversation ever started.
- You have worked through the relevant troubleshooting steps, applied the appropriate fix, and confirmed through testing that the behavior remains unchanged.
- The issue appears to be a platform or runtime problem rather than an issue with your configuration.
- Slowness is broad, consistent, not tied to a specific subagent or action, and does not match any of the signal patterns in Pattern I.

**A well-described case reaches the right team faster.** Where available, include:

- A concise description of what you expected versus what actually happened.
- One or more representative user inputs, not just a paraphrase.
- Whether the issue is consistent or intermittent, and approximately how often it reproduces.
- Session ID(s) or relevant Session Tracing data for a few representative sessions.
- The subagent and action you believe were selected, if known.
- Relevant Plan Tracer output.
- What you already tried and the before-and-after result.
- Specific error text, permission errors, or truncation symptoms.
- The agent or configuration version or deployment time, if relevant.

**For latency cases, additionally include:**

- Whether the slowness is broad or isolated to a specific subagent, action, or channel.
- Which channel or channels you tested (chat, voice, messaging, etc.) and whether behavior differs between them.
- The approximate timeframe when you observed the slowness.
- Which fixes from Pattern I you already attempted and the before-and-after result.

---

## 15. Sandbox vs. Production Tracing

### Transition from Sandbox to Production

When a customer promotes an agent from sandbox to production:

1. **Enable both tracing toggles in production separately.** Session Tracing and Agent Platform Tracing must be explicitly enabled. They do not transfer from sandbox.
2. **Confirm Data Cloud DMOs are accessible.** Run a test query against `std__AiAgentSessionDmo__dlm` and verify that admin users have **Data Cloud Architect** (`GenieAdmin`) and **Agentforce Default Admin** (`CopilotSalesforceAdmin`) assigned.
3. **Verify the deployment included all three metadata pieces.** Committed-agent deployment requires `AiAuthoringBundle` + `Bot`/`BotVersion` + `GenAiPlannerBundle`. Omitting `GenAiPlannerBundle` produces an incomplete deployment that can look like a tracing or data problem rather than a deployment problem. Missing data in the STDM is the symptom.
4. **Seed baseline metrics in the first 48 hours.** Dashboards need live traffic to establish a baseline before alert thresholds can be calibrated accurately.
5. **Configure alert thresholds before launch.** Set thresholds relative to expected session volume, not arbitrary defaults.
6. **Shift from CLI trace review to SOQL.** The development workflow of opening individual trace files does not scale to production volumes.
7. **Install the Consumption Tagging app** if consumption reporting is a stakeholder requirement.

> **Deployment note:** Deploying a draft `AiAuthoringBundle` to an org where the agent is already in a committed state auto-creates a new draft version rather than overwriting the existing committed agent. Verify this behavior in your target org before relying on it in automated CI/CD pipelines.

> **Note on Goal-Based Agents (262.14 pilot):** Goal-Based Agents introduce scheduled and autonomous execution via `trigger` (cron) blocks and `workflows` that operate outside the turn-based model. The STDM implications are not yet fully documented for production observability. Treat the tracing guidance in this guide as a starting point, not a complete reference, for GBA deployments.

---

## 16. Mapping Observability to Business KPIs

| Technical Metric | Primary Source | Business KPI | Business Audience |
|---|---|---|---|
| Deflection Rate | `Deflection_Rate_clc` (semantic layer) | Cost-per-interaction reduction | Customer Service Operations |
| Escalation Rate | `Escalation_Rate_clc` (semantic layer) | Agent quality and trust | CX Leadership |
| Session Outcome | `Session_Outcome_Base_clc` (semantic layer) | Consolidated outcome reporting across all terminal states | CX Leadership / Operations |
| Optimization Quality Score (1–5) | `Average_Quality_Score_clc` (semantic layer); raw SOQL via `std__AiAgentTagAssociationDmo__dlm` | Agent effectiveness by intent | Product and Agent Design |
| Quality Tag Outcome | `std__AiAgentTagAssociationDmo__dlm` (`std__IsPassed__c`, `std__OutcomeType__c`, `std__AssociationReasonText__c`) | Per-Moment diagnostic drill-down | Agent Builders / QA |
| Task Resolution Status | `Task_Resolution_Status_clc` (semantic layer) | Resolution completeness by session | CX Leadership / Agent Design |
| Agent Adherence Status | `Agent_Adherence_Status_clc` (semantic layer) | Instruction compliance by response | Legal / Risk / Agent Design |
| Time to First Agent Token | `Time_To_First_Agent_Token_clc` (semantic layer) | Perceived responsiveness; user experience quality | CX Leadership / Service Ops |
| Time to Last Agent Token | `Time_To_Last_Agent_Token_clc` (semantic layer) | End-to-end response completion time | Service Ops / IT Ops |
| Action span duration | TelemetryTraceSpan `ssot__DurationNumber__c` (ms — no conversion needed) | Time-to-resolution; UX quality | Service Ops / IT Ops |
| Error volume by operation type | TelemetryTraceSpan DMO | IT ops efficiency; MTTR | IT Operations |
| Usage quantity and token count | `std__AiAgentGenerativeAiUsageDmo__dlm` | AI cost-per-transaction | Finance / AI Budget Owners |
| Safety score distribution | `std__AiAgentInteractionStepDmo__dlm` (`PlannerResponseStep.safetyScore`) | Responsible AI compliance | Legal / Risk |
| Knowledge gap clusters | Agentforce Optimization Intents tab | Content strategy; knowledge base ROI | Knowledge Management |
| Total Flex Credits | `Total_Flex_Credits_clc` (semantic layer) | AI spend | Finance |

---

## 17. Credit Consumption Awareness

### The Two Consumption Tracking Tools

**Digital Wallet**
The authoritative source for exact Flex Credit consumption, billing verification, and contractual overage calculations. Use the Digital Wallet for any billing dispute or contractual review. It has a **72-hour processing lag** from the time of consumption to the time the record appears. It is not suited for real-time operational monitoring.

**`std__AiAgentGenerativeAiUsageDmo__dlm` in Data 360**
Refreshes every 5 minutes. Suited for near-real-time operational dashboards, trend analysis, feature attribution, and session-level cost attribution.

> Use the Digital Wallet for billing truth. Use the DMO for operational intelligence. They are complementary, not competing. The 72-hour Digital Wallet lag means discrepancies between the two sources are expected when looking at recent data — not a cause for concern.

### What Consumes Flex Credits

| Usage Type | Billing Basis |
|---|---|
| Actions | Per execution |
| Help Agent Resolutions | Per resolved outcome |
| Voice Minutes | Per duration |
| Prompts | Per 2,000-token LLM call chunk |
| Speech Foundations | Per audio processing unit |

**What does NOT consume Flex Credits:** Utility operations (`@utils.escalate`, `@utils.end_session`, `@utils.setVariables`, `@utils.transition`) are not billed.

### Cost Optimization Levers

Listed in order of impact:

1. **Push deterministic logic.** Every `->` instruction that replaces a `|` instruction saves one LLM call.
2. **Use the EinsteinHyperClassifier for routing.** Faster and cheaper than a general LLM for classification.
3. **Guard data-fetch actions.** A `has-loaded` guard in `before_reasoning` prevents redundant API calls on every parse.
4. **Scope RAG retrieval carefully.** Overly broad retrieval windows retrieve more chunks than needed, consuming more tokens.
5. **Choose the right model for each subagent.** Complex reasoning subagents may need GPT-4.1 or Claude Sonnet. Simple response-generation subagents can use Claude Haiku or Gemini Flash at lower cost.

### Consumption Monitoring SOQL

**Billable usage by agent (last 30 days):**

```sql
SELECT
    std__AgentDeveloperName__c,
    std__UsageTypeCode__c,
    SUM(std__UsageQuantity__c)  AS total_usage,
    COUNT(*)                    AS event_count
FROM std__AiAgentGenerativeAiUsageDmo__dlm
WHERE std__Timestamp__c >= LAST_N_DAYS:30
  AND std__IsBillableIndicator__c = true
GROUP BY std__AgentDeveloperName__c, std__UsageTypeCode__c
ORDER BY total_usage DESC
```

**Token consumption by agent (last 7 days):**

```sql
SELECT
    std__AgentDeveloperName__c,
    SUM(std__PromptInputTokenCount__c)      AS total_input_tokens,
    SUM(std__PromptCompletionTokenCount__c) AS total_completion_tokens,
    SUM(std__PromptTotalTokenCount__c)      AS total_tokens
FROM std__AiAgentGenerativeAiUsageDmo__dlm
WHERE std__Timestamp__c >= LAST_N_DAYS:7
GROUP BY std__AgentDeveloperName__c
ORDER BY total_tokens DESC
```

---

## 18. Quick-Reference Cheat Sheet

### Triage Sequence (Run Before Opening a Trace)

1. Run the same input multiple times — is the behavior consistent or intermittent?
2. Try different phrasings — does phrasing affect the outcome?
3. Reproduce in a minimal configuration — is it your customization or a platform issue?
4. Check activation and permissions.
5. Use Plan Tracer in Agent Builder.
6. Use Session Tracing if enabled.
7. Confirm your last change was actually saved and published.

### Control Selection

| Problem type | Right control |
|---|---|
| Wrong subagent selected | Rewrite the classification description — not the instructions or scope |
| Step must always happen in exact order | Deterministic action (Flow, Apex) or Agent Script |
| Agent needs accurate facts or records | Data grounding |
| Value must reliably flow between steps | Variables |
| Judgment, tone, or preference guidance | Instructions |
| Business-critical conditional logic | Agent Script |

### Latency Signal Map

| Observation | Points to |
|---|---|
| Slow TTFT, consistent across requests | Model choice, instruction length, or subagent count |
| Fast TTFT, slow TTLT | Response length, model choice, or streaming off |
| Slow on specific action calls | Action logic or external API |
| Slow on Knowledge retrieval | Chunking orerly broad grounding scope |
| Slow on subagent handoffs | Too many routing layers |
| Slow on voice only | Channel-specific overhead; benchmark separately |
| Broadly slow, no clear cause | Escalate to Support |

### Key Toggles and Where to Find Them

| Toggle | Where |
|---|---|
| Session Tracing | Setup > Einstein Audit, Analytics, and Monitoring Setup |
| Agentforce Optimization | Same setup page |
| Audit and Feedback | Same setup page |
| Agent Platform Tracing | Setup > Agent Platform Tracing |
| Knowledge/RAG Quality Data and Metrics | Same Audit and Feedback setup area |

### DMO Prefix Check

```sql
SELECT COUNT(*) FROM std__AiAgentSessionDmo__dlm
-- Zero rows or error: use ssot__ prefix throughout
-- Returns rows: use std__ prefix throughout
```

### Pattern Index

| Pattern | Symptom |
|---|---|
| A | Wrong subagent invoked |
| B | Action not invoked |
| C | Action invoked but output ignored |
| D | Unexpected error response (fallback message) |
| E | Escalation spike with no surface error |
| F | Latency with no surface error (action-level) |
| G | Missing `after_reasoning` spans |
| H | Unexpected agent behavior / repeated instruction rewrites |
| I | Latency diagnosis (full pipeline) |
