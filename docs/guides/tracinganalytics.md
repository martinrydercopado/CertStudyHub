# Tracing and Analytics in Agentforce

*Updated August 20, 2026*
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

**The business stakes are real.** Agentforce agents frequently handle customer-facing interactions at scale. A misconfigured instruction, a failing action, or a knowledge gap can affect thousands of sessions before anyone notices — unless monitoring catches it first. Observability converts reactive fire-fighting into a proactive, data-driven improvement loop.

For a Success Architect, observability is also a trust-building tool. Customers who can see exactly what their agent is doing, how it is performing, and where it needs improvement are customers who invest in the platform long-term.

---

## 2. Prerequisites and Infrastructure Setup

Agentforce observability depends on a stack of capabilities that must be explicitly enabled. None of them are on by default. Before advising a customer on tracing or analytics, confirm this infrastructure is in place.

### Required Foundation

- [ ] Data Cloud provisioned and CRM Connector active
- [ ] `CopilotSalesforceAdmin` assigned to admin users
- [ ] `GenieAdmin` assigned to admin users needing Data Cloud access
- [ ] `AgentforceServiceAgentBuilder` assigned to service agent admins
- [ ] `AgentforceDeveloperAndAdminTools` assigned to developers (verify purpose per org)
- [ ] Session Tracing enabled (Einstein Audit, Analytics, and Monitoring Setup)
- [ ] Agentforce Optimization enabled (same setup page)
- [ ] Audit and Feedback enabled with target data space selected (same setup page)
- [ ] Agent Platform Tracing enabled (Setup > Agent Platform Tracing)
- [ ] Data Space name confirmed via CLI command (not assumed)
- [ ] `config.runtime` block reviewed: if no runtime behavior needs overriding, omit the block entirely. `runtime` is a sub-block of `config` with five optional boolean parameters (`streaming`, `thought_chunks`, `citation`, `groundedness`, `reset_to_initial_node`). Agent Script's compiler expects at least one property after a block header; an empty `runtime:` declaration produces a compilation error at deployment time, not a silent runtime failure. Confirm the `groundedness` flag state if `ReasoningStep` entries are absent from traces.
- [ ] Consumption Tagging app installed (if Consumption Analytics Dashboard required)
- [ ] Alert thresholds configured relative to expected session volume before go-live

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

**What it is:** Real-time and historical dashboards that surface aggregate metrics across all agent sessions. Powered by Tableau Next, built on the Session Tracing Data Model (STDM) in Data Cloud.

**The business framing:** "Is the agent performing well overall?" Analytics is your command center. It tells you the shape of the situation: how many sessions, what escalation rate, which subagents are invoked most, where volume is trending.

**Key metrics surfaced:**

- Session volume (daily, weekly, trending)
- Escalation rate (the primary quality signal in the first weeks after go-live)
- Deflection rate (the headline ROI metric)
- Subagent invocation distribution
- Average session duration and turn count
- Agent latency

**When to rely on it:** Daily health monitoring, early-warning detection, executive reporting, and ROI calculation. Analytics answers the "what." It does not answer the "why."

**Limitation to communicate:** Analytics dashboards show aggregate trends. They cannot tell you why a specific session escalated, which instruction caused a misrouted topic, or where an action broke. For those questions, you need Pillar II or III.

### The Analytics Semantic Layer

Salesforce provides a pre-built **Analytics Semantic Layer** called Agentforce Analytics Foundations inside Data 360. It exposes calculated fields (`_clc` suffix) for every standard KPI. These fields are the recommended query target for standard metrics. Raw SOQL against the underlying DMOs is appropriate for advanced, custom, or cross-DMO use cases only.

Confirmed calculated field names:

**Measures**

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

Optimization extends the core STDM with four additional DMOs:

| DMO | API Name (`std__`) | What It Contains |
|---|---|---|
| Moment | `std__AiAgentMomentDmo__dlm` | One record per Moment; LLM-generated request and response summaries, timing |
| Moment-Interaction Junction | `std__AiAgentMomentInteractionDmo__dlm` | Links Moments to their constituent interaction turns |
| Tag Association | `std__AiAgentTagAssociationDmo__dlm` | Links each Moment to its quality data and outcome tags |
| Tag | `std__AiAgentTagDmo__dlm` | The intent tag record (clustering category label and numeric score) |

> **Note on Moment summaries:** `std__RequestSummaryText__c` and `std__ResponseSummaryText__c` on the Moment DMO are **LLM-generated summaries**, not raw user or agent text. Raw LLM output text lives on `std__GenAiResponseGenerationDmo__dlm` (`std__GeneratedResponseText__c`), reached via `std__AiAgentInteractionStepDmo__dlm`.

#### The AgentforceOptimizeService Apex Class

`AgentforceOptimizeService` is a **custom Apex class deployed by the agentforce-observe skill** into the org as part of its setup phase. It is not a Salesforce-published platform API. The class exposes a `runObservabilityQuery(queryType)` method that wraps internal STDM queries for convenience.

Confirmed `queryType` values (sourced directly from the skill file):

| Query Type | What It Surfaces |
|---|---|
| `KnowledgeGap` | Subagents with lowest average context precision; fast knowledge gap identification |
| `Hallucination` | Moments where agent assertions diverged from retrieved context |
| `RetrievalQuality` | Retrieval quality distribution across Moments |
| `AnswerRelevancy` | Answer relevance scores across Moments |
| `Leaderboard` | Ranked subagent performance across quality dimensions |

Do not present `runObservabilityQuery()` as a native Salesforce API in customer-facing deliverables. Reference the equivalent semantic layer fields or raw SOQL patterns documented in this guide for org-agnostic implementations.

---

### Pillar III: Agent Platform Tracing

**What it is:** An OpenTelemetry-compatible span tree stored in `ssot__TelemetryTraceSpan__dlm` (or `std__TelemetryTraceSpanDmo__dlm` in newer orgs) that captures every back-end execution event — LLM calls, Flow runs, Apex invocations, timings, and errors.

**The business framing:** "Why did that take 4 seconds? Where exactly did it break?" Platform Tracing is the tool for questions that Analytics and Optimization cannot answer.

Platform Tracing data is queryable via SOQL in Data Cloud and is also exportable to enterprise APM platforms (Datadog, Dynatrace, Splunk) via the OTel standard. A fourth tracing path — the OTel API (beta) — is documented in Section 6. For non-technical stakeholders, **Tableau Concierge** — a pre-built agentic analytics skill within Tableau Next — supports natural-language queries over the telemetry data without requiring SOQL.

Full detail is in Section 6.

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

> ### Scenario 1: Wrong Subagent Invoked for a Known Intent
>
> A customer's service agent has a `Billing_Inquiry` subagent and an `Account_Management` subagent. Users asking "Can you change my billing address?" are consistently routed to `Account_Management` instead of `Billing_Inquiry`.
>
> The `EnabledToolsStep` shows both subagents listed as available. The `LLMStep.tools_sent` shows the LLM receiving descriptions for both, but the `Billing_Inquiry` description reads: _"Handles billing questions and disputes."_ The word "address" does not appear in it.
>
> The fix: Update the `Billing_Inquiry` description to include _"billing address changes, payment method updates."_ After redeployment, routing accuracy for this utterance type improves to 100%.
>
> **Lesson:** Subagent routing is purely semantic. If the description does not cover the user's vocabulary, routing fails.

---

> ### Scenario 2: Systemic Escalation Spike at Peak Hours
>
> A financial services firm deploys an employee agent for HR policy questions. During the first two weeks, the escalation rate is stable at 8%. Then, every Tuesday and Thursday between 9 and 11 AM, it spikes to 35%.
>
> The health monitoring alert fires within minutes. Investigating traces from that window, all failed sessions share a common error: the Apex action querying HR policy records is timing out — a SOQL query running without selective filters during a batch processing window that runs every Tuesday and Thursday morning.
>
> **Lesson:** Health monitoring tells you when to start trace analysis. Without it, this would have been discovered only after users complained.

---

> ### Scenario 3: Grounding Failure Causing "Unexpected Error" Responses
>
> A retail agent handles product availability questions. Users intermittently receive _"I apologize, but I encountered an unexpected error"_ responses, but only for specific product categories.
>
> In three affected sessions, the `ReasoningStep` shows two consecutive UNGROUNDED results. The `FunctionStep` output returns: `"Available: 12 units at Store #4821"`. The agent's response reads: _"That item is available at your nearest location."_ The grounding checker cannot verify that Store #4821 is the user's nearest location, because the action did not return location data.
>
> The fix: Update agent instructions to quote the store number and unit count verbatim from the action output, without inferring proximity.
>
> **Note:** Before concluding this is purely a grounding issue, check LLM Gateway health during the affected window. If Platform Tracing spans show 429s or other infrastructure errors, the fallback may be infrastructure-caused rather than double-UNGROUNDED.
>
> **Lesson:** Grounding failures are almost always fixable with a targeted instruction change.

---

## 5. Reading Session Traces

_(Full section content preserved from v5 — no changes to this section.)_

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
| Service Name | `ssot__ServiceName__c` | TEXT | Name of the backend service emitting the span, for example `coreapp.core-on-sam`. Filter or GROUP BY this field to isolate latency to a specific service boundary when a trace spans multiple services. See Pattern F. |

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

> **Field name note:** The semantic layer formula for `Quality_Score_clc` is defined as `INT([AI Agent Tag].[Value])`. The physical DMO field that "Value" maps to be `std__ValueText__c`, cast to integer. This is the best-supported interpretation based on the official formula, but it is not confirmed by live-org sampling. Verify `std__ValueText__c` returns numeric strings in your org before relying on this query in production.

```sql
SELECT
    a.std__AiAgentMomentId__c,
    a.std__AiAgentInteractionId__c,
    a.std__OutcomeType__c,
    a.std__IsPassed__c,
    a.std__AssociationReasonText__c,
    CAST(t.std__ValueText__c AS INTEGER) AS score_numeric,
    m.std__AiAgentApiName__c            AS agent_api_name
FROM std__AiAgentTagAssociationDmo__dlm a
JOIN std__AiAgentTagDmo__dlm t
    ON a.std__AiAgentTagId__c = t.std__Id__c
JOIN std__AiAgentMomentDmo__dlm m
    ON a.std__AiAgentMomentId__c = m.std__Id__c
WHERE t.std__IsFallback__c = false
  AND t.std__ValueText__c != 'NOT_SET'
```

> **Field notes:**
> - `CAST(t.std__ValueText__c AS INTEGER)` is the best-supported raw SOQL equivalent of the `_clc` formula. Confirm in your org that `std__ValueText__c` returns numeric string values before using this in production.
> - `std__IsFallback__c = false` filters out default/catch-all tag records. Runtime behavior of this flag is unconfirmed in live-org data; treat as a best-practice filter and verify in your org.
> - All fields on `std__AiAgentTagAssociationDmo__dlm` use the `std__` prefix.

**Platform Tracing span tree by trace ID:**

```sql
SELECT
    ssot__OperationName__c,
    ssot__DurationNumber__c AS duration_ms,
    ssot__TelemetrySpanAttributeText__c,
    ssot__StatusCode__c
FROM ssot__TelemetryTraceSpan__dlm
WHERE ssot__TelemetryTrace__c = '<trace_id>'
ORDER BY ssot__DurationNumber__c DESC
```

**Average action duration by operation (last 7 days):**

```sql
SELECT
    ssot__OperationName__c,
    AVG(ssot__DurationNumber__c) AS avg_duration_ms,
    MAX(ssot__DurationNumber__c) AS max_duration_ms,
    COUNT(*)                     AS span_count
FROM ssot__TelemetryTraceSpan__dlm
WHERE ssot__OperationName__c LIKE 'run.action.%'
  AND ssot__StartDateTime__c >= LAST_N_DAYS:7
GROUP BY ssot__OperationName__c
ORDER BY avg_duration_ms DESC
```

> `ssot__DurationNumber__c` is in milliseconds (confirmed via Salesforce Platform Tracing blog). No conversion is needed. Label your output columns accordingly.

#### Full Session Reconstruction

**All messages and steps for a session in chronological order:**

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

**Where to look:** Start with AgentLens to rule out looping. Then query the TelemetryTraceSpan DMO for the interaction's trace ID. Check `ssot__DurationNumber__c` (in milliseconds — no conversion needed) and `ssot__TelemetrySpanAttributeText__c` for the action span in question. If the trace spans multiple service boundaries, filter or GROUP BY `ssot__ServiceName__c` to isolate latency to a specific backend service. The value is the internal service name emitting the span — for example, `coreapp.core-on-sam`.

**Root cause:** The action ran successfully but returned too much data (visible as a high `db.rows_affected` value in `ssot__TelemetrySpanAttributeText__c`), causing the LLM to spend extra time processing a large payload.

**Fix direction:** Add `LIMIT` clauses and selective `WHERE` filters to the backing Apex or Flow query.

---

### Pattern G: Missing `after_reasoning` Spans

**Symptom:** A Platform Trace span tree shows no spans corresponding to an `after_reasoning` block that exists in the Agent Script.

**Where to look:** Check whether the action that preceded the missing block has `is_displayable: True` set.

**Root cause:** Expected platform behavior. When `is_displayable: True` is set on an action, the platform exits the reasoning loop immediately when the LLM decides to surface that output. `after_reasoning` never executes and no error is raised.

**Fix direction:** If logic in `after_reasoning` must execute reliably, move it into the `before_reasoning` block of the subsequent subagent.

> **Deterministic `escalate` statement (262.14+):** The new top-level `escalate` statement fires exactly once and hands off to a fixed escalation target without an LLM reasoning step. In Platform Tracing, it appears as a `TransitionStep` to the escalation target with no preceding `run.llmstep` span for that transition. This is expected behavior — not a missing-span anomaly.

---

### Pattern H: `before_reasoning` Counter Shows Inflated Count

**Symptom:** A variable used to track conversation turn count returns values higher than the number of actual user messages in the session.

**Where to look:** Check where the counter variable is incremented in the Agent Script. If the increment is in `before_reasoning`, the variable is counting parses, not turns.

**Root cause:** `before_reasoning` executes on every parse, including re-entry after each action call within a turn. In a subagent that fires two actions per user turn, `before_reasoning` runs three times per user turn.

**Additional trigger (262.12+):** If `config.runtime.reset_to_initial_node: false` is set, subagent context may persist across turns in ways that cause `before_reasoning` to execute more often than expected per user turn.

**Fix direction:** Move the counter increment to `after_reasoning`, or use an action-based incrementor that fires explicitly once per intended measurement unit.

---

### Diagnostic Quick-Reference

| Dimension | Sandbox / Development | Production |
|---|---|---|
| **Primary tracing tool** | Session traces via `sf agent preview` CLI | Data Cloud STDM tables and Agent Platform Tracing DMOs |
| **Session Tracing toggle** | Must be enabled per org — does not inherit | Must be enabled separately before go-live |
| **Agent Platform Tracing toggle** | Must be enabled per org | Must be enabled separately before go-live |
| **Data retention** | Preview trace files are local and ephemeral | STDM and Platform Tracing data persists in Data Cloud for the configured retention window |
| **Utterance quality** | Controlled test utterances | Full diversity of real-user phrasing |
| **Alert thresholds** | Not typically configured | Configure all thresholds before go-live |
| **Data volume** | Low; manual trace review is practical | High; aggregate dashboards and SOQL queries are the primary diagnostic surface |

### The Two Quality Scoring Systems

Agentforce has two distinct quality scoring instruments. Both use numeric scales, which causes frequent confusion. The key distinction is when each is used and what it measures.

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

### Transition from Sandbox to Production

When a customer promotes an agent from sandbox to production:

1. **Enable both tracing toggles in production separately.** Session Tracing and Agent Platform Tracing must be explicitly enabled. They do not transfer from sandbox.
2. **Confirm Data Cloud DMOs are accessible.** Run a test query against `std__AiAgentSessionDmo__dlm` and verify that admin users have `GenieAdmin` and `CopilotSalesforceAdmin` assigned.
3. **Verify the deployment included all three metadata pieces.** Committed-agent deployment requires `AiAuthoringBundle` + `Bot`/`BotVersion` + `GenAiPlannerBundle`. Omitting `GenAiPlannerBundle` produces an incomplete deployment that can look like a tracing or data problem rather than a deployment problem. Missing data in the STDM is the symptom.
4. **Seed baseline metrics in the first 48 hours.** Dashboards need live traffic to establish a baseline before alert thresholds can be calibrated accurately.
5. **Configure alert thresholds before launch.** Set thresholds relative to expected session volume, not arbitrary defaults.
6. **Shift from CLI trace review to SOQL.** The development workflow of opening individual trace files does not scale to production volumes.
7. **Install the Consumption Tagging app** if consumption reporting is a stakeholder requirement.

> **Deployment note:** Deploying a draft `AiAuthoringBundle` to an org where the agent is already in a committed state auto-creates a new draft version rather than overwriting the existing committed agent. Verify this behavior in your target org before relying on it in automated CI/CD pipelines.

> **Note on Goal-Based Agents (262.14 pilot):** Goal-Based Agents introduce scheduled/autonomous execution via `trigger` (cron) blocks and `workflows` that operate outside the turn-based model. The STDM implications are not yet fully documented for production observability. Treat the tracing guidance in this guide as a starting point, not a complete reference, for GBA deployments.

---

## 10. Mapping Observability to Business KPIs

| Technical Metric | Primary Source | Business KPI | Business Audience |
|---|---|---|---|
| Deflection Rate | `Deflection_Rate_clc` (semantic layer) | Cost-per-interaction reduction | Customer Service Operations |
| Escalation Rate | `Escalation_Rate_clc` (semantic layer) | Agent quality and trust | CX Leadership |
| Session Outcome | `Session_Outcome_Base_clc` (semantic layer) | Consolidated outcome reporting across all terminal states | CX Leadership / Operations |
| Optimization Quality Score (1–5) | `Average_Quality_Score_clc` (semantic layer); raw SOQL via `std__AiAgentTagAssociationDmo__dlm` | Agent effectiveness by intent | Product and Agent Design |
| Quality Tag Outcome | `std__AiAgentTagAssociationDmo__dlm` (`std__IsPassed__c`, `std__OutcomeType__c`, `std__AssociationReasonText__c`) | Per-Moment diagnostic drill-down | Agent Builders / QA |
| Task Resolution Status | `Task_Resolution_Status_clc` (semantic layer) | Resolution completeness by session | CX Leadership / Agent Design |
| Agent Adherence Status | `Agent_Adherence_Status_clc` (semantic layer) | Instruction compliance by response | Legal / Risk / Agent Design |
| Action span duration | TelemetryTraceSpan `ssot__DurationNumber__c` (ms — no conversion needed) | Time-to-resolution; UX quality | Service Ops / IT Ops |
| Error volume by operation type | TelemetryTraceSpan DMO | IT ops efficiency; MTTR | IT Operations |
| Usage quantity and token count | `std__AiAgentGenerativeAiUsageDmo__dlm` | AI cost-per-transaction | Finance / AI Budget Owners |
| Safety score distribution | `std__AiAgentInteractionStepDmo__dlm` (`PlannerResponseStep.safetyScore`) | Responsible AI compliance | Legal / Risk |
| Knowledge gap clusters | Agentforce Optimization Intents tab | Content strategy; knowledge base ROI | Knowledge Management |
| Total Flex Credits | `Total_Flex_Credits_clc` (semantic layer) | AI spend | Finance |

---

## 11. Credit Consumption Awareness

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

> **Confirmed field names on `std__AiAgentGenerativeAiUsageDmo__dlm`:**
> `std__AgentDeveloperName__c`, `std__UsageTypeCode__c`, `std__UsageQuantity__c`, `std__Timestamp__c`, `std__IsBillableIndicator__c`, `std__IsMeteredIndicator__c`, `std__PromptInputTokenCount__c`, `std__PromptCompletionTokenCount__c`, `std__PromptTotalTokenCount__c`.

---

## 12. Quick-Reference Cheat Sheet

### Setup Enablement Sequence

| Step | Path | What It Enables |
|---|---|---|
| 1 | Setup > Einstein Audit, Analytics, and Monitoring Setup | Session Tracing + Optimization |
| 2 | Same page > Audit and Feedback toggle | LLM prompt/response storage; feedback capture |
| 3 | Same page > "Knowledge/RAG Quality Data and Metrics" toggle (confirmed name) | RAG quality calculated fields (`_clc`) |
| 4 | Same page > Trust Layer data toggle (exact name unconfirmed — verify in Setup) | Toxicity, prompt injection, and instruction adherence calculated fields |
| 5 | Setup > Agent Platform Tracing | Back-end execution span tree |
| 6 | `sf api request rest "/services/data/v63.0/ssot/data-spaces" -o <org>` | Verify Data Space name before querying (note: `--json` flag not supported on this beta command) |
| 7 | AppExchange > Digital Wallet | Consumption Tagging app (if needed) |

### DMO Prefix Reference

| Family | Prefix | How to Identify | Notes |
|---|---|---|---|
| Standard (newer orgs) | `std__` | `SELECT COUNT(*) FROM std__AiAgentSessionDmo__dlm` returns rows | Use `std__` queries in this guide |
| Legacy (existing orgs) | `ssot__` | Same query returns zero/error; `ssot__` equivalent returns rows | Substitute `ssot__` throughout; Platform Tracing official docs use `ssot__` |
| GenAI Audit | _(none)_ | `GenAIGeneration__dlm` | Separate pipeline; only when Audit and Feedback enabled |

> Both `std__` and `ssot__` families are fully SOQL-queryable. They are identical in capability. No auto-migration occurs. **Always confirm which prefix is live in your customer's org before delivering SOQL.**

### Decision Tree: Which Tool for Which Question?

```
Is my agent performing well overall?
  └─ Agentforce Analytics Dashboard (or semantic layer _clc fields in Data 360)

Where is it underperforming and why?
  └─ Agentforce Optimization
       └─ Average_Quality_Score_clc for KPI
       └─ std__AiAgentTagAssociationDmo__dlm for per-Moment drill-down

Why did a specific session escalate / fail?
  └─ Session Tracing via STDM SOQL
       └─ Full Session Reconstruction CTE (Section 7)
       └─ Step-level escalation: filter std__NameInterfaceField__c = 'CLOSED_TRANSFERRED'
          (confirmed field — official DMO schema)

Why was that specific session slow?
  └─ AgentLens first (FSM diagram — backward arrows indicate retry loops)
  └─ Then Agent Platform Tracing
       └─ ssot__TelemetryTraceSpan__dlm (duration in milliseconds — confirmed, no conversion needed)
       └─ GROUP BY ssot__ServiceName__c to isolate latency to a specific backend service

How much is this costing per agent?
  └─ Digital Wallet (billing truth — 72-hour lag)
  └─ std__AiAgentGenerativeAiUsageDmo__dlm (operational intelligence, 5-min refresh)

Multi-agent session audit?
  └─ std__AiAgentSessionParticipantDmo__dlm
     (std__PreviousSessionId__c is "Reserved for future use" — do not use in production)

Quality before go-live?
  └─ Testing Center (sandbox only; 0–5 scale, 3+ = pass)
     LLM judge: GPT OSS on Salesforce SageMaker via Einstein Trust Layer

Need raw OTel trace data for an APM platform?
  └─ GET /services/data/v66.0/einstein/audit/otel/{session-id}  (beta, API v66.0+)
     Returns native OTel ResourceSpans format for direct OTLP ingestion
     Requires Data Cloud enabled
     Verify availability in your org's API version before advising customers to depend on this
```

### Open Items (Pending Live-Org Confirmation)

| Item | Current State | Action Needed |
|---|---|---|
| Testing Center limits (500/job vs. 1,000/test) | Two official sources disagree | Verify in live org; update with confirmed number |
| Terminal fallback mechanism | Slack evidence, not official Salesforce docs | Practitioner hedge is appropriate; monitor for official documentation |
| `std__PreviousSessionId__c` production reliability | Officially "Reserved for future use" | Monitor Salesforce release notes |
| `std__IsFallback__c` runtime behavior on Tag DMO | Unconfirmed; schema confirms field exists | Sample `std__AiAgentTagDmo__dlm` in live org |
| Quality score raw field (`std__ValueText__c`) | Best-supported interpretation of official formula; not confirmed by live-org sampling | `SELECT std__ValueText__c FROM std__AiAgentTagDmo__dlm LIMIT 10` to verify numeric string content |
| `std__SourceType__c` distinct values | Likely: `PromptTemplate`, `Formula`, `API` | `SELECT DISTINCT std__SourceType__c FROM std__AiAgentTagAssociationDmo__dlm` |
| Trust Layer toggle exact UI name | Believed to exist; name not confirmed verbatim | Verify name in Setup before communicating to customers |
| OTel API beta (`/einstein/audit/otel/`) | Confirmed as beta capability | Verify availability in org's current API version |
| `GenAIGeneration__dlm` retention window | Short window (days, not weeks) per Slack evidence | Verify current retention in live org before planning historical analysis |
| STDM lag (15 min vs. ~30 min) | Two official sources; 15 min treated as primary | Low priority; defensible judgment call |

---
