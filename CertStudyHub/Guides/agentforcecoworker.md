# Agentforce Coworker: A Success Architect's Guide

*Updated September 8, 2026*
*This guide was generated using AI with grounding in official Salesforce documentation, field activation guides, and internal product FAQs. Review for accuracy before using. Do not share externally.*

---

## Table of Contents

- [Section 0: How to Use This Guide](#section-0-how-to-use-this-guide)
- [Section 1: What Is Agentforce Coworker?](#section-1-what-is-agentforce-coworker)
  - [The Origin Story](#the-origin-story)
  - [The Three Usage Modes](#the-three-usage-modes)
  - [Skills: Extending Coworker Without Code](#skills-extending-coworker-without-code)
  - [Where Coworker Lives: Multi-Surface Reach](#where-coworker-lives-multi-surface-reach)
  - [Who Gets Access: Eligibility](#who-gets-access-eligibility)
  - [What Data It Works With](#what-data-it-works-with)
  - [Governance: Security by Default](#governance-security-by-default)
  - [Scenario: A Day in the Life with Coworker](#scenario-a-day-in-the-life-with-coworker)
- [Section 2: What Are Bespoke Agentforce Agents?](#section-2-what-are-bespoke-agentforce-agents)
  - [What Makes an Agent "Bespoke"](#what-makes-an-agent-bespoke)
  - [The Building Blocks](#the-building-blocks)
  - [Hybrid Reasoning: The Core Idea](#hybrid-reasoning-the-core-idea)
  - [Employee Agents vs. Service Agents](#employee-agents-vs-service-agents)
  - [The Agent Development Lifecycle](#the-agent-development-lifecycle)
  - [Why the Build Effort Is a Feature](#why-the-build-effort-is-a-feature)
  - [Scenario: A Custom Quoting Agent](#scenario-a-custom-quoting-agent)
- [Section 3: How Coworker and Bespoke Agents Work Together](#section-3-how-coworker-and-bespoke-agents-work-together)
  - [The Right Mental Model](#the-right-mental-model)
  - [Auto-Discovery: No Wiring Required](#auto-discovery-no-wiring-required)
  - [How Routing Actually Works](#how-routing-actually-works)
  - [The A2A Protocol](#the-a2a-protocol)
  - [What Coworker Can and Cannot Do Alone](#what-coworker-can-and-cannot-do-alone)
  - [The 90-Second Timeout](#the-90-second-timeout)
  - [Session Continuity](#session-continuity)
  - [Scenario: Coworker Delegates to a Quoting Agent](#scenario-coworker-delegates-to-a-quoting-agent)
  - [The Description Hygiene Principle](#the-description-hygiene-principle)
  - [Implicit vs. Explicit Routing: A Reliability Watchout](#implicit-vs-explicit-routing-a-reliability-watchout)
- [Section 4: Pros, Cons, and Watch-Outs](#section-4-pros-cons-and-watch-outs)
  - [Agentforce Coworker](#agentforce-coworker)
  - [Bespoke Agentforce Agents](#bespoke-agentforce-agents)
  - [Side-by-Side Comparison](#side-by-side-comparison)
- [Section 5: When to Recommend What](#section-5-when-to-recommend-what)
  - [The Decision Framework](#the-decision-framework)
  - [Decision Tree](#decision-tree)
  - [Four Customer Scenarios](#four-customer-scenarios)
- [Section 6: Customer Conversation Playbook](#section-6-customer-conversation-playbook)
  - [Common Customer Questions](#common-customer-questions)
  - [Objection Handling Table](#objection-handling-table)
  - [Slackbot vs. Coworker Positioning](#slackbot-vs-coworker-positioning)
  - [Demo and Discovery Best Practices](#demo-and-discovery-best-practices)
- [Section 7: Setup and Technical Essentials for SAs](#section-7-setup-and-technical-essentials-for-sas)
  - [Pre-Flight Checklist](#pre-flight-checklist)
  - [Step-by-Step Activation Sequence](#step-by-step-activation-sequence)
  - [Three Ways Users Access Coworker](#three-ways-users-access-coworker)
  - [Expanding Data Sources (Phase 2)](#expanding-data-sources-phase-2)
  - [Permission Requirements](#permission-requirements)
  - [Data Connectivity Options](#data-connectivity-options)
  - [Consumption and Flex Credits](#consumption-and-flex-credits)
  - [Digital Wallet Setup](#digital-wallet-setup)
  - [Key Limits to Know](#key-limits-to-know)
  - [Known Friction Points from the Field](#known-friction-points-from-the-field)
- [Section 8: Open Questions to Track](#section-8-open-questions-to-track)
- [Section 9: Quick Reference Card](#section-9-quick-reference-card)

---

## Section 0: How to Use This Guide

This guide is a thinking tool, not a sales deck. Its job is to make you the most informed person in the room when a customer asks about Agentforce Coworker, about bespoke agents, about Skills, or about the relationship between all three.

Every major concept is explained twice: once at the business level (why it matters to the customer), and once at the technical level (how it actually works). Scenarios are labeled clearly so you can jump to a specific story before a call. Tables are kept narrow so they read well on any screen.

**A note on honesty:** This guide distinguishes confirmed behavior from roadmap targets. Anything not yet confirmed GA is labeled as such. Do not over-promise to customers on unconfirmed items.

**What's new in this version:** Section 1 now includes a full Skills reference. Section 6 adds an objection handling table, a Slackbot vs. Coworker routing table, and demo best practices. Section 7 has been completely rewritten with a step-by-step activation sequence, Digital Wallet setup, expanded troubleshooting, consumption details, and eligibility constraints that were previously missing.

---

## Section 1: What Is Agentforce Coworker?

### The Origin Story

Agentforce Coworker was formerly called "Ask Agentforce." The rename reflects a more ambitious vision: not just a search tool, but an autonomous AI teammate that works alongside your employees across multiple surfaces.

It went generally available on **August 4-7, 2026**, with auto-activation confirmed for A1E and A4X orgs by August 7. Since beta, it has been adopted by approximately 30,000 users across 2,000 orgs. Customer wins span industries including logistics, global inspection and certification, insurance, airlines, and payroll and HR services, among others.

The market context matters here: **12.5 million monthly active users** already perform **1 billion CRM searches per month** inside Salesforce. Coworker meets users where they already are — it does not ask them to go somewhere new. The potential is 60x more Agentforce adoption and 12x growth in Flex Credit usage as the new interaction model for CRM takes hold.

**Business-level summary:** Coworker is an AI teammate embedded directly in Salesforce. Employees talk to it naturally, and it finds information, summarizes situations, and takes action on their behalf — all without leaving the tool they are already using.

**Technical summary:** Coworker is built on the Agentforce 360 Platform and Data 360. It is embedded in Salesforce Global Search and surfaces wherever that search bar appears. It uses a reasoning and retrieval architecture that reads connected data sources and — critically — routes work to other Agentforce agents when the task requires it.

---

### The Three Usage Modes

Coworker works in three modes. Each one solves a different kind of problem.

**Find**

Find is plain-language Q&A across CRM data and connected sources. The user asks a question in natural language and gets one synthesized answer — across 300+ sources, role-contextualized, not just keyword-matched. No dashboards, no reports, no switching between apps.

*Business value:* A rep who needs to know "what's going on with the Northstar account?" gets a real answer immediately, not a list of search results.

*Technical note:* Find queries across Salesforce CRM objects (Accounts, Opportunities, Contacts, Cases, and Custom Objects the user has access to), connected Slack channels, and — if configured — Data 360 objects and file sources like SharePoint or Google Drive.

**Catch Up**

Catch Up generates instant summaries across cases, pipeline, Slack conversations, and other connected data. It can work autonomously in the background — proactive alerts before you even ask, not just when a user prompts it.

*Business value:* A manager who was out of office for a week can be current on their team's pipeline in two minutes rather than thirty.

*Technical note:* The Catch Up mode relies on the same semantic indexing and retrieval layer as Find, but synthesizes content across multiple records and threads rather than answering a single focused question.

**Act**

Act is where Coworker moves beyond retrieval. When a user gives Coworker a task — not just a question — Coworker routes to the appropriate Agentforce agent and executes the workflow within the same conversation thread.

*Business value:* A rep who says "create a quote for this opportunity with a 10% discount" does not need to know which agent handles quoting. Coworker figures that out and delivers the result.

*Technical note:* Act is how Coworker connects to bespoke Agentforce agents and to Skills. Both are covered in detail in their respective sections below and in Section 3.

---

### Skills: Extending Coworker Without Code

Skills are one of the most important additions to the Coworker story and are completely missing from many field conversations. This section gives you everything you need.

#### What Skills Are

A Skill is a reusable, guided workflow that a user saves by name and runs on demand. It packages a multi-step process — for example, "prep for an account review" or "update my pipeline notes after a call" — so the user does not have to re-describe the process each time. Skills are the answer to the question: "What do I do after I get an answer from Coworker?"

**Skills in Coworker specifically** means the ability to build, run, and share Skills natively inside the Coworker chat window — managing the entire Skill lifecycle without leaving the conversation.

#### Three Skill Types

| Type | Who Creates It | Ready to Use? |
|---|---|---|
| **Standard** | Salesforce (out of the box) | Immediately, no building required |
| **Admin-defined** | Admins | After admin builds and publishes |
| **End-user defined** | Individual users | After user creates and optionally shares |

#### How to Build, Run, and Share a Skill

- **Build:** Create a reusable Skill conversationally, just by describing a process in plain English.
- **Run:** Trigger explicitly with "/" or let Coworker run it automatically based on the user's intent.
- **Share:** Share with teammates and user groups to scale high-performing workflows across the org.
- **Find:** In Coworker, navigate to "Ask" and click the Skills icon.

#### Pricing

**Skills are free to create and store.** Flex Credit consumption is based on the actions invoked within a Skill, not on creating or storing Skills themselves. There is no separate per-Skill charge.

#### Governance: The Question Every Customer Will Ask

*"Won't line-of-business users accidentally expose data or break things?"*

No. Governance is built in at every level:

- **Private by default:** All user-created Skills start private and require deliberate action to share.
- **Permission inheritance:** Skills execute strictly on behalf of the active user, inheriting all row- and object-level permissions. A Skill cannot see what the user cannot see.
- **Admin oversight:** Admins curate pre-approved action blocks and can require a review-and-approve ("graduation") flow before a Skill is published broadly.

#### Skills vs. Prompt Templates

This distinction comes up in technical conversations. Prompt Templates run a single one-shot instruction. Skills codify multi-step workflows — the kind of task that used to take several back-and-forth prompts — so Coworker repeats the whole process consistently every time, not just one step. Some prompts can even trigger an existing Skill or the creation of a new one.

#### How Skills Fit in the Agentforce Ecosystem

Skills are reusable, runtime workflows — not dev-time packages. Built on the `skill.md` standard, they are portable across Coworker, Slackbot, and other agents (export/import is coming), and can be exposed via MCP for third-party agents. Coworker is the first client to ship Skills. They run under the session user's normal permissions.

#### Lead Use Cases for Skills

1. **Account research routine** (Sales): Coworker pulls recent news, org changes, and Salesforce activity into one summary, then logs it as a note on the Account or Opportunity automatically.
2. **Call-prep checklist and record sync** (Sales): Compiles stage, stakeholders, and open risks into a pre-call brief, then reads notes after the call and syncs any changes back to the Opportunity.
3. **Competitive battle-card pull** (Sales): Ask for a competitor by name and get the latest positioning, objections, and win/loss notes — then logs the insight on the Opportunity.
4. **Pipeline hygiene sweep** (Sales): Scans open Opportunities on a schedule, flags stale ones, and auto-updates the next-step field or owner.
5. **Notes/thread-to-record sync** (Sales and Service): Reads call notes, meeting notes, or a Slack thread and updates the Opportunity or Case directly — status, stage, resolution — plus creates any follow-up tasks.

#### Best Practices for Building Skills

- Name and describe the Skill the way you would actually ask for it. Do not rely on Coworker to auto-name if you create it conversationally — always review the name and description it generates.
- Be prescriptive about specific steps, inputs, and where to pull data. Do not rely on the agent to guess.
- Start simple, then refine conversationally.
- Add one Skill at a time.

#### Key Soundbites for Pitching Skills

- "Codify what your best people know into deterministic agent actions."
- "Update once in a central library to instantly upgrade every connected agent."
- "Empower line-of-business users to extend Coworker in real time — no dev or admin dependency."
- "Trigger workflows explicitly with '/' or let Coworker execute them automatically based on intent."

**Availability note:** Skills in Coworker launched internally in mid-August 2026. Customer access is available through a closed Beta shortly after. Verify current GA status before committing to customers.

---

### Where Coworker Lives: Multi-Surface Reach

| Surface | Status |
|---|---|
| Salesforce (Lightning) | Generally Available |
| Slack | Generally Available |
| Microsoft Teams | Pilot / Nominate-Only |
| ChatGPT | Targeted October 2026 (not yet confirmed GA) |
| Claude (Anthropic) | Targeted October 2026 (not yet confirmed GA) |
| Salesforce Desktop App | Targeted October 2026 (not yet confirmed GA) |

**Important for customer conversations:** Do not commit to Teams, ChatGPT, Claude, or Desktop App timelines. Use the phrase "targeted for" and point customers to official release notes for confirmation.

The original Salesforce Slackbot is a related but separate product. They are complementary and work in different surfaces. Slackbot is a personal AI assistant that lives in Slack, helping users get things done across their workday. Agentforce Coworker is an autonomous AI teammate anchored in Salesforce CRM. There are active internal discussions about bringing Coworker capabilities to Slackbot, but no confirmed roadmap item to share externally. See the Slackbot vs. Coworker positioning table in Section 6.

---

### Who Gets Access: Eligibility

Coworker is available to customers on:

- Agentforce 1 Enterprise (A1E)
- Agentforce 4 (A4X)
- Enterprise Edition
- Unlimited Edition

Customers also need **Foundations Flex** to use Flex Credits for consumption billing.

**Critical eligibility constraints to communicate proactively:**

| Constraint | Detail |
|---|---|
| **Language** | English only in Beta. Other languages are not officially tested or supported. |
| **GovCloud** | Not yet supported. |
| **LLM inference geography** | LLM inference runs in North America, including for customers located outside of North America. Disclose this proactively to regulated industries in Europe. |

**Consumption model by SKU:**

| Customer SKU | Coworker Consumption |
|---|---|
| A4X or A1E | Included — unlimited/unmetered |
| Agentforce for Sales or Service (seat-based) | Unmetered — permission sets must be properly assigned or users fall into metered consumption |
| Foundations Flex (consumption-based) | Draws from existing Flex Credits and Data Cloud query credits |

**Important nuance:** Enabling Coworker at the org level does not automatically give every user access. Rolling it out to individual users requires the `Access_Ai_Search` Permission Set Group to be assigned. This is the most commonly skipped step in every field activation. See Section 7.

---

### What Data It Works With

Coworker works on three tiers of data, each requiring different setup effort.

**Tier 1 — Native CRM (zero setup):** Accounts, Opportunities, Contacts, Cases, and Custom Objects the user already has access to are searchable immediately when Coworker is turned on. No additional configuration is required. Custom Objects are included from day one — this is a point customers frequently underestimate.

**Tier 2 — Slack (low setup):** Connected Slack channels become searchable. Slack is a preconfigured data source — Salesforce has pre-programmed the searchable fields and result settings, and they cannot be customized.

**Tier 3 — Data 360 and external files (optional, Phase 2):** Data Model Objects (DMOs) from Data 360, SharePoint, and Google Drive can be added as sources. These unlock meaningfully richer experiences but require setup effort and incur additional Flex Credit consumption.

When enablement is clicked, Salesforce automatically creates an Employee 360 profile and runs identity resolution in Data 360 to map users across CRM, Slack, and third-party sources. Personalization starts immediately.

**For customers with messy or disconnected data:** Coworker's value scales with data quality and connectivity. An org with poor data hygiene will get a thinner experience. Set expectations accordingly.

---

### Governance: Security by Default

Coworker does not require a separate security model. It inherits the org's existing Salesforce sharing rules, profiles, and permission sets automatically. A user cannot see data through Coworker that they were not already allowed to see — this applies both to Coworker's own retrieval and to any agents it delegates to. Coworker only routes to agents the requesting user already has access to.

This also applies to Skills: Skills execute strictly on behalf of the active user, inheriting all row- and object-level permissions.

Coworker also supports Einstein GenAI Trust Layer features including data masking, toxicity detection, and zero data retention options.

This is enterprise-grade governance out of the box, and it is a strong answer to the security objection in customer conversations.

---

### Scenario: A Day in the Life with Coworker

**Context:** Maria is an Account Executive at a B2B software company. She is preparing for a renewal call with one of her key accounts.

**Find in action:** Maria types "What's going on with [Account]?" into Coworker from the Global Search bar. Coworker returns a synthesized summary: the renewal is at risk due to pricing concerns raised in a recent call, a competitor was mentioned, and an inside sales rep has a follow-up meeting scheduled for next week.

**Catch Up in action:** Maria asks "What did our team discuss with this account in Slack last month?" Coworker searches the connected Slack workspace and returns a threaded summary of relevant conversations, including a note that the customer flagged a training cost concern in a direct message to a Customer Success Manager.

**Act in action:** Maria says "Give me coaching on how to handle their pricing objection before the renewal call." Coworker recognizes this as a task for the Sales Coach Agent, delegates to it automatically, and returns personalized coaching advice — all in the same conversation thread. Maria never left Coworker.

**Skills in action:** At the end of the call, Maria types "/" and runs her "Post-Call Record Sync" Skill. It reads her call notes, updates the Opportunity stage and next steps automatically, and creates a follow-up task — all from a single trigger. She built that Skill herself in Coworker. No admin or developer was involved.

This single scenario covers all three modes plus Skills. Notice that Maria did not need to know which agent handled coaching, and she did not have to navigate anywhere to sync her notes.

---

## Section 2: What Are Bespoke Agentforce Agents?

### What Makes an Agent "Bespoke"

A bespoke Agentforce agent is intentionally designed around a specific business workflow. It is not general-purpose. It handles a defined set of tasks, follows specific business rules, and uses a set of purposefully configured actions. You build it because you need it to behave in a particular way, every time, reliably.

Examples include: a Quoting Agent that pre-populates fields from an opportunity and flags approval thresholds; an IT Ticket Agent that gathers structured information and creates records in the right system; and a Service Resolution Agent that follows a mandatory identity verification step before accessing customer order data.

**Business-level summary:** A bespoke agent is a specialist. You design it for one job, and it does that job predictably, even when the stakes are high or the process is regulated.

**Technical summary:** Bespoke agents are built with Agentforce Builder (visual) or Agent Script (code-based), using a combination of subagents, actions (Flows, Apex, Prompt Templates, MuleSoft APIs), variables for state management, and system instructions for persona and guardrails. They can be Employee Agents (internal workforce) or Service Agents (customer-facing).

---

### The Building Blocks

Every bespoke agent is composed of the same fundamental elements.

**Subagents** are specialized scopes within an agent, each owning a defined domain. The routing engine matches user input to the right subagent based on its name and description. Think of subagents as departments: each one has a defined area of expertise and its own set of instructions and tools.

**Actions** are the things a subagent can do. Actions invoke Salesforce Flows for declarative automation, Apex classes for custom logic, Prompt Templates for LLM-based tasks like summarization, or external APIs via MuleSoft. Each action has defined inputs and outputs.

**Variables** store state across the conversation. They allow an agent to remember what it has already learned or done, enabling multi-step workflows and conditional logic without relying on the LLM's memory.

**System instructions** define the agent's persona, guardrails, and scope at the agent level. Subagents can override these for their specific context.

**Reasoning instructions** combine two types of logic: deterministic logic instructions (which run as code, guaranteed) and prompt instructions (which the LLM interprets). This combination is called hybrid reasoning, and it is the foundation of Agentforce's reliability model.

---

### Hybrid Reasoning: The Core Idea

This concept is important enough to explain clearly, because customers will ask about it and because it explains why bespoke agents behave differently from general-purpose AI tools.

**The problem with pure LLM reasoning:** When you rely entirely on an LLM to make decisions, you get a system that is flexible but unpredictable. In a demo it looks great. In production, with real edge cases and real compliance requirements, it can drift. Steps get skipped. Context gets lost. Audits become impossible.

**The hybrid solution:** Agent Script lets you draw an explicit boundary between two types of instructions in the same agent. Logic instructions (marked with `->`) run deterministically as code — the LLM is not involved. Prompt instructions (marked with `|`) are natural language that the LLM interprets. You decide, at every step, which type applies.

*Example:* A Quoting Agent can deterministically always run an action to load the opportunity record before the LLM does anything. That is not a suggestion. It always happens. Then the LLM can reason conversationally about how to present the pre-populated quote. The deterministic part handles the business rule. The probabilistic part handles the conversation.

**Why this matters for customers:** It means you can build an agent that is reliable enough to trust with a high-stakes workflow, not just a demo. It also means there is an audit trail, because deterministic steps are logged and reproducible.

---

### Employee Agents vs. Service Agents

Agentforce supports two broad categories of agents, and the distinction matters for how Coworker interacts with them.

**Employee Agents** are built for internal users: sales reps, service managers, ops teams. They are the category most relevant to Coworker, because Coworker auto-discovers and routes to Employee Agents that are active in the org.

**Service Agents** are built for external, customer-facing interactions. They typically connect to channels like Messaging for Web or in-app chat. They support escalation to human agents via Omni-Channel. Coworker does not surface these to internal users in the same way it surfaces Employee Agents.

For any bespoke agent you expect Coworker to delegate to, it should be configured as an Employee Agent.

---

### The Agent Development Lifecycle

Building a bespoke agent is not a one-time event. It follows a lifecycle.

**Plan:** Define the use case, identify the subagents needed, design the actions, and decide where the boundary sits between deterministic logic and LLM reasoning. This is the most important phase — decisions made here determine everything downstream.

**Build:** Use Agentforce Builder (visual Canvas view) or Agent Script (code-based Script view) to construct the agent. Write actions backed by Flows, Apex, or Prompt Templates. Define inputs, outputs, and variable bindings.

**Test:** Use Agentforce Testing Center to validate agent behavior against predefined test cases before deployment. The Testing Center supports AI-generated test cases, CSV imports, and conversation-based tests. It uses LLM-as-judge evaluation to assess response quality.

**Deploy:** Package the agent metadata (AiAuthoringBundle, BotVersion, GenAiPlannerBundle) and deploy to target environments. Committed agents are immutable — a new version is required for changes.

**Monitor and Improve:** Use Agentforce Observability to track performance, identify failure patterns, and refine instructions, actions, and routing logic over time.

---

### Why the Build Effort Is a Feature

It is tempting to see the build effort for a bespoke agent as a cost. But for the right use cases, that effort is exactly what you are paying for.

When a process needs to run the same way every time — when there are compliance requirements, approval thresholds, sequential steps that cannot be skipped — you need an agent designed for that process. The build effort produces reliability, auditability, and specificity that a general-purpose tool cannot provide.

A cautionary tale: one internal use case required replacing a bespoke "T&C Intelligence Agent" built with 30 Apex classes, 7 Flows, and multiple hand-tuned prompts — entirely replaced by Coworker. The lesson is not that bespoke is bad. The lesson is that bespoke agents should be built for the right things. Using 30 Apex classes to do what Coworker does out of the box is over-engineering.

---

### Scenario: A Custom Quoting Agent

**Context:** A manufacturing company sells configurable equipment. Quotes involve product bundles, complex pricing rules, regulatory compliance checks, and a multi-tier approval workflow.

Coworker alone cannot handle this. The rules are too specific and the stakes are too high.

The company builds a Quoting Agent with three subagents: one that loads opportunity and product data, one that applies pricing rules and validates bundles, and one that routes to the appropriate approver based on deal size. Each step runs deterministically where required. The LLM handles the conversational surface — explaining options, answering questions about the quote — while the business rules execute as code.

The investment is real. The agent takes weeks to design and build. But it runs reliably in production, produces an audit trail, and handles edge cases that a general-purpose agent would miss.

And once Coworker is enabled in the org? A rep can invoke this Quoting Agent from a natural language prompt inside Coworker, without knowing the agent exists by name.

---

## Section 3: How Coworker and Bespoke Agents Work Together

### The Right Mental Model

The single most important thing to understand about the Coworker-to-bespoke-agent relationship is this: **they are not competitors. Coworker is the surface. Bespoke agents are the specialists behind it.**

When a user interacts with Coworker, Coworker handles Find and Catch Up itself. But when the user's request requires a workflow that a bespoke agent is configured to handle, Coworker steps back, delegates to that agent, and returns the result — all in the same conversation thread. The user does not change context. They do not need to know which agent is doing the work.

A well-built bespoke agent does not become less valuable when Coworker is enabled. It becomes more accessible.

---

### Auto-Discovery: No Wiring Required

Coworker does not require a separate integration step to connect to bespoke agents. It automatically discovers all active Agentforce agents in the org. At startup, Coworker reads each agent's metadata — name, description, and topic descriptions — and uses that to build an internal understanding of what each agent can do.

**Business implication:** A customer who already has Agentforce agents deployed does not need to re-architect anything to benefit from Coworker. The agents they already have become discoverable entry points the moment Coworker is turned on.

**Technical implication:** The quality of auto-discovery depends entirely on how well the agent and its subagents (topics) are described. Vague descriptions produce unreliable routing. This is the "description hygiene" principle, covered in detail below.

---

### How Routing Actually Works

When a user makes a request in Coworker, the routing decision happens in two layers.

**Layer 1 — Coworker's own scope:** Coworker first determines whether it can handle the request itself using its built-in retrieval and reasoning capabilities (Find and Catch Up).

**Layer 2 — Agent delegation:** If the request matches the scope of a bespoke agent that the user has access to, Coworker delegates to that agent via topic-based routing. The delegation is description-driven: Coworker compares the user's intent to the agent name, the agent description, and the topic descriptions of all active agents accessible to that user.

**User permissions gate the catalog:** Coworker dynamically populates the list of available agents per user. If a user does not have access to a given agent, Coworker will not route to it, regardless of how well the descriptions match.

---

### The A2A Protocol

The delegation from Coworker to a bespoke agent runs on **Agentforce's native Agent-to-Agent (A2A) capability**. This is an open protocol that lets one agent discover and invoke another via published Agent Cards, without custom connector code or hardcoded endpoints.

The A2A protocol is not Salesforce-proprietary. Microsoft Copilot Studio has also adopted it, which means it has cross-vendor relevance for customers operating in mixed AI environments.

**Status as of September 2026:** Native A2A Inbound went to Beta on March 2, 2026. GA is targeted for Summer 2026 but is not yet confirmed complete. SAs working with customers who need this capability today can use Agent API (GA) plus MuleSoft Flex Gateway as an equivalent path while waiting for native A2A GA.

---

### What Coworker Can and Cannot Do Alone

**Coworker can do alone:**
- Answer open-ended questions across CRM data
- Summarize cases, pipelines, and Slack threads
- Reason across connected data sources
- Route to and invoke bespoke agents
- Run Skills

**Coworker cannot do without a bespoke sub-agent:**
- Execute write actions (create records, update fields, trigger complex workflows)
- Follow deterministic multi-step business processes
- Enforce mandatory sequential logic
- Apply domain-specific compliance rules

This is by design. Coworker is primarily a **reasoning and retrieval layer**. Write actions and process-specific logic live in the sub-agents it delegates to. Without a properly configured sub-agent, Coworker will correctly tell the user it does not have permission to edit records.

*Practical implication for SAs:* When a customer asks Coworker to "update this opportunity stage" and gets a refusal, that is not a bug. It means no sub-agent with that action is active and accessible to that user.

---

### The 90-Second Timeout

Coworker imposes a **hard 90-second timeout** on delegated tasks. There is no async support as of September 2026.

This is a firm platform constraint. If a bespoke agent's workflow takes longer than 90 seconds end-to-end — for example, because it calls a slow external system or runs a complex calculation — the request will time out.

**Design implication:** When designing bespoke agents intended to be routed to by Coworker, ensure that individual action calls are fast. Long-running operations should be handled asynchronously (Queueable, Batch Apex, Platform Events) outside the agent's synchronous flow. Async support for delegated agents is on the roadmap, targeted post the Laulima release.

---

### Session Continuity

Session continuity — the ability for a user to continue a multi-turn conversation with a delegated agent across turns — is architecturally supported. A `session_id` exists in the delegation tool to enable continuity.

However, **server-side persistence of session state was not yet built as of mid-2026 testing**. This means that a multi-turn conversation routed through Coworker to a bespoke agent may not reliably maintain context across follow-up turns in all scenarios.

Set customer expectations accordingly. For workflows that require guaranteed multi-turn context, direct access to the bespoke agent (not through Coworker) is more reliable today.

---

### Scenario: Coworker Delegates to a Quoting Agent

**Setup:** A cybersecurity software company has deployed a Quoting Agent as an Employee Agent in their Salesforce org. Coworker is enabled. A sales rep is inside Coworker.

**The rep says:** "I want to create a new quote for this opportunity. Add 500 Cloud Security Monitoring licenses and apply a 10% discount."

**What Coworker does:**
1. Identifies that the request is outside its own retrieval scope — it requires a write action.
2. Reads the Quoting Agent's name, description, and topic descriptions.
3. Matches the request to the Quoting Agent's scope.
4. Delegates to the Quoting Agent via A2A-based routing.
5. The Quoting Agent pre-populates fields from the opportunity, applies the 10% discount, validates the bundle, and flags any approval requirements.
6. Coworker returns the result to the rep in the same conversation thread.

The rep never left Coworker. They did not navigate to a separate quoting tool or even know which agent did the work.

---

### The Description Hygiene Principle

Because Coworker routes based on descriptions, the quality of your routing is exactly as good as the quality of your agent and topic descriptions.

A bespoke agent with a vague topic description like "Handles sales tasks" will compete poorly against Coworker's own reasoning. Coworker may answer from its own capability instead of delegating, even when the bespoke agent is a better fit.

A bespoke agent with a precise description like "Creates and modifies CPQ quotes for active Salesforce opportunities, including product bundle selection, discount application, and approval routing" will be matched reliably.

**Practical guidance:**
- Review all active Employee Agent descriptions before enabling Coworker.
- Each topic (subagent) description is also a routing signal. All must be specific and distinct.
- If a customer reports that Coworker is not delegating to their agent, description quality is the first thing to check.
- The product requirement is explicit: "Description on an agent, its topic, and actions are mandatory for all agents because the orchestrator uses it to make routing decisions."

---

### Implicit vs. Explicit Routing: A Reliability Watchout

Testing has confirmed a meaningful reliability difference between two routing scenarios.

**Explicit routing (reliable):** The user names the agent or uses language that clearly matches the agent's description. Coworker delegates consistently.

**Implicit routing (less reliable):** The user's request is within the agent's scope but does not name the agent or use language that matches the description closely. In testing, Coworker sometimes answered from its own capability instead of delegating, even when delegation was the better fit.

This behavior has been flagged to the product team as an open validation item. It is not a confirmed bug, but it is a real pattern that SAs should be aware of when setting customer expectations.

**Mitigation:** Better descriptions reduce the gap between implicit and explicit routing reliability. The more specific and distinctive the agent's description, the more likely Coworker is to delegate correctly even when the user does not name the agent.

---

## Section 4: Pros, Cons, and Watch-Outs

### Agentforce Coworker

**What it does well:**

Coworker's biggest advantage is time to value. There is no agent design, no subagent authoring, no action development. A customer turns it on, grants user access, and their employees immediately have a general-purpose AI teammate working across their CRM data. The setup is genuinely two to eight steps depending on what you count — but the core is fast.

For A1E, A4X, and Agentforce for Sales/Service seat-based customers, the consumption cost is zero. This removes the financial objection for experimentation.

Coworker also carries a compelling proof point for the "replace over-engineering" conversation. One internal use case replaced a bespoke T&C Intelligence Agent — built with 30 Apex classes, 7 Flows, and multiple hand-tuned prompts — entirely with Coworker. The replacement performed better because Coworker's wider and deeper context outperformed the hand-crafted, single-purpose prompts, and its reusable Skills and History replaced the custom Flow logic.

The enterprise governance story is strong. No custom security model is required. Existing sharing rules, profiles, and permission sets apply automatically.

**Watch-outs:**

Coworker is not the right tool for deterministic, tightly-scoped processes. If a customer needs guaranteed sequential steps, compliance checkpoints, or audit-trail-level repeatability, a bespoke agent is the right answer.

Eligibility is gated. Not every Salesforce customer qualifies. Confirm edition before building a recommendation. English only in Beta. GovCloud is not supported. LLM inference runs in North America even for customers located outside of North America.

Value scales with data quality. A customer with poor data hygiene gets a thinner experience. This is worth surfacing early.

Turning on Coworker at the org level does not mean every user automatically has access. Individual user rollout requires the `Access_Ai_Search` Permission Set Group to be assigned. Customers who turn it on and then report "nobody is using it" have almost always skipped this step.

Some surfaces (Teams, ChatGPT, Claude, Desktop App) are still rolling out. Do not commit to timelines on these.

---

### Bespoke Agentforce Agents

**What they do well:**

A well-built bespoke agent handles the things Coworker cannot: precise, governed workflows with deterministic logic, specific integrations, mandatory sequential steps, and approval or compliance logic. For high-stakes processes, this specificity is not optional.

Bespoke agents also become more valuable once Coworker is enabled. Every Employee Agent that is active in the org becomes discoverable through Coworker's routing. The investment in a bespoke agent does not compete with Coworker — it compounds with it.

**Watch-outs:**

The build effort is real. Designing subagents, authoring Agent Script, building and testing actions, iterating based on Testing Center results — this takes time and skill. It is not appropriate for use cases that Coworker handles out of the box.

The maintenance burden is also real, especially for agents built the old way with custom Apex and complex Flow orchestration. The T&C Intelligence Agent cautionary tale is a reminder of what over-engineering costs over time.

---

### Side-by-Side Comparison

| Dimension | Agentforce Coworker | Bespoke Agent |
|---|---|---|
| Setup time | Minutes (2-click core) | Weeks (design, build, test) |
| Use case fit | Open-ended Q&A, summaries, catch-up | Deterministic workflows, compliance logic |
| Data access | CRM, Slack, Data 360, files (300+ sources) | Whatever actions are configured |
| Write actions | Requires a bespoke sub-agent | Built in, fully controlled |
| Governance | Inherits org sharing model | Inherits org sharing model |
| Cost (A1E/A4X) | Unmetered | Flex Credits consumed per action |
| Cost (seat-based Sales/Service) | Unmetered | Flex Credits consumed per action |
| Reliability model | Probabilistic (retrieval + reasoning) | Hybrid (deterministic + LLM) |
| Audit trail | Limited | Full (deterministic steps logged) |
| Becomes more valuable with Coworker? | Yes (it IS the surface) | Yes (auto-routed to by Coworker) |
| Right for regulated processes? | No | Yes |
| Right for open-ended knowledge work? | Yes | Often overkill |
| User extensibility? | Yes, via Skills | No (requires dev/admin) |

---

## Section 5: When to Recommend What

### The Decision Framework

**Lead with Coworker when:**
- The customer's need is answers, summaries, or catch-up across CRM data.
- There is no complex, multi-step business process involved.
- The customer is on A1E, A4X, or a seat-based Agentforce for Sales/Service license (zero consumption cost to try).
- The customer has an existing hand-built automation doing open-ended Q&A — that is a replacement candidate.
- Speed to value matters more than precision.
- Users need to extend Coworker's behavior themselves, without waiting for developers (recommend Skills).

**Recommend bespoke when:**
- The process requires deterministic sequential steps.
- Compliance, approval logic, or regulatory requirements are in scope.
- Specific integrations or custom calculations are needed.
- The workflow must produce a consistent, auditable output every time.
- Domain expertise that Coworker cannot reason about from CRM data alone is required.

**Recommend both when:**
- The workflow is complex and domain-specific, but users should access it through natural language.
- Coworker is the front door; the bespoke agent is the executor.
- The customer wants to grow into AI without committing to a large upfront build.

**Recommend Coworker as a replacement when:**
- A customer has a brittle legacy automation (many Flows, custom Apex, hand-tuned prompts) doing what is essentially open-ended Q&A.
- The automation is hard to maintain and not producing reliably better results than Coworker would.
- The T&C Intelligence Agent story is directly applicable.

---

### Decision Tree

```
Is the task open-ended Q&A, summarization, or catch-up?
    YES --> Lead with Coworker
    NO --> Continue

Does the task require deterministic multi-step logic, compliance rules,
or approval workflows?
    YES --> Recommend bespoke agent
    NO --> Continue

Does the user need to access a specific workflow through natural conversation?
    YES --> Recommend both (Coworker as front door, bespoke as executor)
    NO --> Continue

Does an existing automation do open-ended Q&A with heavy custom code?
    YES --> Recommend Coworker as replacement
    NO --> Revisit use case definition with customer

Does the user need a repeatable multi-step process they can build themselves?
    YES --> Recommend Skills within Coworker
```

---

### Four Customer Scenarios

**Scenario A: Coworker Only**

A regional sales team wants their reps to quickly understand account health, pipeline risk, and activity history before customer calls — without needing to run reports. There is no workflow to execute, no records to create. The ask is information retrieval and synthesis.

Recommendation: Coworker. Enable it, connect Slack, and let reps prompt their own data live. One field account went from 25 to 200+ seats after doing exactly this — letting the customer self-prompt rather than running a demo at them.

**Scenario B: Bespoke Agent Only**

A financial services firm needs an agent that walks advisors through a regulated compliance checklist before opening a new account. Every step must execute in sequence. The checklist cannot be skipped. A digital audit trail is required. The process involves checking external systems via API.

Recommendation: Bespoke agent with Agent Script. The deterministic logic model ensures the checklist runs in the right order, every time. Compliance steps that cannot be skipped are encoded as logic instructions, not LLM prompts.

**Scenario C: Both Together**

A technology company has a custom Quoting Agent already deployed. It handles CPQ logic, bundle validation, and approval routing. But reps find it hard to discover and use — they do not know when to go there.

Recommendation: Enable Coworker and ensure the Quoting Agent's descriptions are clean and specific. Now reps can invoke the Quoting Agent from a natural language prompt inside Coworker ("create a quote for this opportunity"), without knowing the agent exists by name. The bespoke agent's value compounds with Coworker as the front door.

**Scenario D: Coworker as Replacement**

A professional services team built a custom "Contract Intelligence Agent" two years ago with 25+ Apex classes and a series of hand-tuned prompts. It answers questions about contract terms, renewal dates, and obligation summaries. It is hard to maintain, breaks when contract formats change, and the team is spending engineering time keeping it running.

Recommendation: Replace it with Coworker connected to Data 360. Coworker's wider retrieval context and deeper CRM integration will outperform the hand-crafted single-purpose prompts. The Flows and Apex classes can be retired. The team gets their engineering time back.

---

## Section 6: Customer Conversation Playbook

### Common Customer Questions

**"We already have Agentforce agents deployed. Why do we need Coworker?"**

Coworker makes those investments more valuable, not redundant. When a user's request matches an existing Employee Agent's scope, Coworker automatically delegates and routes to it. No additional configuration is needed beyond having the agent active in the org. What you have built becomes more accessible, because users can reach it through natural conversation instead of having to know the agent exists.

---

**"How is Coworker different from our Slackbot?"**

They are complementary, not the same thing. Slackbot is a personal AI assistant that lives in Slack, helping you get things done across your workday. Agentforce Coworker is an autonomous AI teammate anchored in Salesforce CRM. It knows your accounts, opportunities, cases, and contacts. It can route to your Agentforce agents and run Skills. There are active internal discussions about bringing Coworker's capabilities to Slackbot, but no confirmed roadmap item to share publicly at this time.

---

**"Can Coworker replace our custom agent?"**

Sometimes, yes — and it is worth evaluating honestly. If the custom agent does open-ended Q&A, summaries, or knowledge retrieval across CRM data, Coworker may outperform it at a fraction of the maintenance cost. The T&C Intelligence Agent case — where 30 Apex classes, 7 Flows, and multiple hand-tuned prompts were replaced by Coworker — is a real example. However, if the custom agent runs a deterministic, multi-step business process with compliance requirements or write actions, Coworker is not a replacement. It is a front door that can route to that agent.

---

**"How does Coworker know to call our specialized agent?"**

Coworker automatically discovers all active Employee Agents in the org. It reads each agent's name, description, and topic descriptions to build an understanding of what each agent can do. When a user's request matches an agent's scope, Coworker delegates to it. No explicit wiring is required. The quality of that routing depends entirely on how clearly the agent and its topics are described.

---

**"What happens if Coworker misroutes a request?"**

If Coworker cannot confidently match a request to a bespoke agent, it may answer from its own general reasoning instead of delegating. This is more likely when the user's request does not closely match the agent's description language. The mitigation is improving the agent's and topic's descriptions to be more specific and distinctive.

---

**"Is Coworker secure? Does it respect our existing permissions?"**

Yes. Coworker inherits the org's existing sharing rules, profiles, and permission sets automatically. A user cannot see data through Coworker that they were not already allowed to see. This applies both to Coworker's own retrieval and to any agents it delegates to. Coworker also supports Einstein GenAI Trust Layer features including data masking, toxicity detection, and zero data retention options.

---

**"What does it cost?"**

For A1E and A4X customers, Coworker is included and unmetered. Agentforce for Sales or Service seat-based users also get unmetered Coworker access — as long as the `Access_Ai_Search` Permission Set Group is properly assigned. For Foundations Flex customers, Flex Credits apply. Refer customers to official Agentforce pricing documentation for current rates.

For sizing reference, internal Salesforce testing showed 34-75 standard consumption units per search (136-300 Flex Credits per search). A rough estimate for a user searching 5 times per day across 250 working days is approximately 170,000-375,000 credits per year, or $-$1,875/user/year at list price. These are internal reference numbers only — do not use them as commitments.

---

**"What about non-Salesforce data?"**

Non-Salesforce data ingested into Data 360 incurs additional costs for ingestion, processing, and querying. Customers who only use CRM and Slack out of the box have no additional ingestion costs. When customers are ready to expand, 270+ Data 360 connectors are available for Phase 2.

---

### Objection Handling Table

| Objection | Recommended Response |
|---|---|
| "We already have Einstein Search" | Einstein Search is keyword-based and returns a list of results — it doesn't reason, take action, or work proactively. Coworker is what you get **instead of** (not in addition to) Einstein Search. |
| "We're waiting for GA" | Beta is free and unlimited for A4X/A1E users. Zero risk. Customers who start now will already have it validated by GA. |
| "Our team is overwhelmed with AI tools" | Coworker lives inside Salesforce — not a new app, no new login. It reduces tool-switching rather than adding to it. |
| "IT won't approve new connectors" | CRM and Slack work out of the box with no connectors. 270+ Data 360 connectors are optional Phase 2 only. |
| "We already have Glean / Rovo / Google Agentspace" | Coworker is native Salesforce with deep CRM context, Employee 360 profiles, and the ability to invoke Agentforce agents to take action — not just find information. No separate app, no separate login. |
| "Could this hurt our Slack deal?" | Coworker is a reason to sell more Slack, not less. Slack is the collaboration layer; Coworker is the new CRM interaction model. They are complementary — see the positioning table below. |
| "We're worried about data privacy or regional compliance" | LLM inference runs in North America, including for customers outside North America. Refer to Salesforce Trust and Compliance documentation and loop in your SE or CSM before proceeding for regulated industries. |
| "We don't want users building their own workflows — governance risk" | Skills are private by default, execute under the active user's own permissions, and require admin graduation before broad publication. Admins curate the available action blocks. |

---

### Slackbot vs. Coworker Positioning

| Customer Profile | Recommended Tool |
|---|---|
| Salesforce only | Agentforce Coworker |
| Slack only | Slackbot |
| Slack and Salesforce | **Both** — use whichever surface you are working in at the time |

---

### Demo and Discovery Best Practices

- **Lead with the customer's own CRM data.** The more relevant the data, the more impressive the moment. Avoid starting with edge cases or beta limitations.
- **Show multi-turn conversations.** Ask a question, then ask a follow-up. Demonstrate it is conversational, not just search.
- **Try "put that in a table."** Ask for data, then ask Coworker to reformat the response. This shows response flexibility and tends to be a crowd-pleaser.
- **Use the Data Cloud provisioning wait time productively.** Step 3 of the activation sequence (Data Cloud provisioning) can take up to 90 minutes. Walk customers through example prompts during that wait so the call time is not wasted.
- **Lead with prompts relevant to the customer's business.** Pick 1-2 prompts from the sales or service use case list in Section 7 that match the customer's world and run them together live.
- **The "wow" moment** typically comes from seeing Coworker reason across the customer's actual CRM data with zero setup. Contrast it to what it would have taken to build a purpose-built agent to do the same thing.
- **Proof point for complex data environments:** Coworker navigated an org with 1,300+ custom objects and returned correct results with zero configuration. Custom Objects are searchable from day one.
- **Framing line that works:** *"Think of it like Claude or ChatGPT — but it actually knows your deals, accounts, cases, and customers. Connected from day one."*

---

## Section 7: Setup and Technical Essentials for SAs

This section gives you enough technical grounding to guide a customer through an actual live activation and to diagnose common issues on the spot. For deeper technical documentation, point customers to the official Agentforce Coworker Developer Guide.

---

### Pre-Flight Checklist

Send this to the customer ahead of the activation call. Ask them to complete Steps A and B before you connect.

- [ ] **A. Confirm licenses are provisioned.** Go to Setup → Company Information → scroll to Permission Set Licenses and verify `AISearchAdminPsl` and `AISearchUserPsl` are present. If they are missing, the SKUs have not been provisioned — escalate to AE/CSM before the call.
- [ ] **B. Provision Data Cloud ahead of time.** Provisioning can take up to 90 minutes. Do not wait until the activation call to start it. Customer goes to Setup → Quick Find → "Data Cloud Setup Home" → "Get Started."
- [ ] **C. Confirm the admin has the System Administrator profile**, not just the Agentforce Coworker Admin permission set. Both are required.
- [ ] **D. Confirm the org is on Enterprise, Unlimited, A1E, or A4X.** Lower editions are not eligible.

---

### Step-by-Step Activation Sequence

Follow these steps in order. Steps 1-6 are required. Steps 7 and 8 apply where noted.

**Step 1 — Activate Einstein Generative AI**
1. Navigate to Setup.
2. In Quick Find, search "Einstein Setup."
3. Toggle "Turn on Einstein" to ON.

**Step 2 — Activate Agentforce**
1. Refresh the page after turning on Einstein. The Agentforce toggle will not appear until Einstein is on.
2. In Quick Find, search "Agentforce."
3. Go to Agent Studio → Agentforce Agents.
4. Toggle "Agentforce Agents" to ON (top right corner).

**Step 3 — Confirm Data Cloud is Provisioned**
1. In Quick Find, search "Data Cloud Setup Home."
2. If a "Get Started" button is visible and the provisioning is not yet complete, do not proceed to Step 5. Data Cloud must be fully active before Coworker can be fully activated.
3. You can continue walking through the remaining steps to show the customer what to do, but do not click "Turn On" in Step 5 until Data Cloud shows active status.

> **If Data Cloud Setup Home does not appear:** The admin needs the Data Cloud Activation Manager permission set. Go to Permission Sets → Data Cloud Activation Manager → Manage Assignments → Add Assignment → find the user → Next → Assign → refresh the page.

**Step 4 — Assign Admin Permissions**

> **IMPORTANT:** Do NOT assign end-user permission sets separately in this step. Assign users inside Step 5 instead. Assigning them separately here is a common source of confusion.

1. Go to Setup → Quick Find → "Permission Sets."
2. Assign `Agentforce Coworker Admin` (may still be listed as "Ask Agentforce Admin" — search for "Ask Agentforce" if you do not see the Coworker name) to the admin who will configure Coworker.
3. Confirm the admin also has the Salesforce System Administrator profile. The permission set alone is not sufficient.

**Step 5 — Activate Agentforce Coworker**
1. PAUSE. Return to Data Cloud Setup Home and confirm Data Cloud is fully active (no "Get Started" button, no provisioning spinner) before proceeding.
2. In Quick Find, search "Get Started with Agentforce Coworker." If you do not see it, search "Get Started with Ask Agentforce."
3. Click Get Started.
4. Click Turn On.
5. Wait for setup to complete — watch for a checkmark next to each automated step and a green "On" label.
6. Scroll down to "Manage Access to Agentforce Coworker."
7. Click Manage and select the users who should have access to Coworker. **This is the step most commonly skipped.** Org-level activation and user access are two separate things.

**Step 6 — Verify It Is Working**
1. Navigate to the Sales Console or Service Console app. The Coworker button does **not** appear in standard Lightning apps — it only appears in Sales Console or Service Console.
2. Hard refresh the page (Cmd+Shift+R on Mac / Ctrl+Shift+R on Windows).
3. Look for the Agentforce Coworker button in the top nav bar next to the search bar.
4. Run a live prompt together with the customer:
   - *"Summarize my top open opportunities and what I should do next to close them."*
   - *"Which accounts haven't had any activity in the last 30 days and are closing this quarter?"*

**Step 7 — (A4X users only) Add Unmetered Access**
1. Go to Users → Permission Set License Assignments.
2. Find "Unmetered User Based AI."
3. Check the box → Save.

> **Note for seat-based Agentforce for Sales or Service users:** These users also get unmetered Coworker access, but only if the `Access_Ai_Search` Permission Set Group is properly assigned in Step 5. Do not skip that assignment even for seat-based users.

**Step 8 — Set Up Digital Wallet (see dedicated section below)**

---

### Three Ways Users Access Coworker

Once activated, users have three entry points:

- **Option A — Ask Button:** Click the Ask button next to the Global Search bar for full conversational, multi-turn mode.
- **Option B — Global Search Bar:** Type a question directly and land on the Coworker results page. Click "Ask Agentforce for more" to enter full conversational mode.
- **Option C — Search Agent:** Activate the Search Agent from within Agentforce Studio and assign the relevant permissions.

---

### Expanding Data Sources (Phase 2)

When the customer is ready to go beyond CRM and Slack:

| Source Type | Governance | Notes |
|---|---|---|
| 270+ Data 360 connectors (hyperscalers, data warehouses, enterprise apps) | Manual governance via Data 360 | Optional Phase 2 |
| Google Drive (SharedDrives) | Permission-aware — auto-inherited from Google | Closed pilot |
| SharePoint | Permission-aware — auto-inherited from SharePoint | Closed pilot |
| Non-permission-aware sources | Governance policies set manually in Data 360 | Requires careful governance planning |

**File size limit:** Files over **75MB** will not be indexed. Set this expectation early for customers with large file repositories.

---

### Permission Requirements

| Role | Requirements |
|---|---|
| Administrator configuring Coworker | Salesforce System Administrator profile **AND** `Agentforce Coworker Admin` Permission Set. Both are required — the permission set alone is not sufficient. |
| End users accessing Coworker | `Access_Ai_Search` Permission Set Group (auto-created after org enablement; assign from the Coworker Setup page) |

**Known field friction point:** The `Access_Ai_Search` Permission Set Group requires the "API Enabled" user permission. Some customer security teams reject this as a blanket policy. If this comes up, escalate to the product team — this is a known friction point with no current workaround.

---

### Data Connectivity Options

| Source | Setup Effort | Notes |
|---|---|---|
| Salesforce CRM (standard objects) | None (automatic) | Included immediately on activation |
| Custom Objects | None (automatic) | Searchable from day one for users with existing access |
| Slack | Low | Preconfigured source; searchable fields cannot be customized |
| Data 360 Objects (DMOs) | Medium | Requires Data 360 license; incurs additional Flex Credits |
| SharePoint / Google Drive | Medium | Requires Data 360; permission-aware sources in closed pilot; 75MB file size limit |

When Data 360 sources are added, three types of Flex Credits are consumed: Data 360 Unstructured Processing, Data 360 Intelligent Processing, and Data 360 Querying. Factor this into consumption conversations with customers.

---

### Consumption and Flex Credits

**How consumption works:**

Coworker consumes two types of credits: Standard Prompts (Agentforce Flex Credits) and Data Cloud query credits.

- If a customer has Agentforce on Flex but Data Cloud on legacy DC Credits, the Data Cloud portion will consume their DC Credits — both do not need to be on Flex.
- Consumption is visible in Salesforce Digital Wallet under the prompt meters.

**Critical rules to know:**

| Rule | Detail |
|---|---|
| DS Credits ≠ Flex Credits | Data Cloud Service Credits cannot be consumed by Agentforce. Only Flex Credits fund Agentforce use cases. |
| Flex Credits are fungible | Flex Credits pool together and can be consumed across all Agentforce use cases. |
| Credits are org-specific | In multi-org scenarios, credits are consumed in the specific org where the SKU was purchased — not pooled across orgs. |
| Testing in Preview/Builder consumes credits | A known issue: Flex Credits are consumed during Agentforce testing in Preview/Builder mode. Factor this into POC credit planning. |

**Consumption estimates (internal testing reference only — not for customer commitments):**

- 34-75 standard consumption units per search (136-300 Flex Credits per search)
- Rough sizing: employee searches 5 times/day x 250 working days = ~170,000-375,000 credits/year
- At list price: approximately $850-$1,875/user/year, or $70-$156 PUPM

---

### Digital Wallet Setup

Digital Wallet is the single place to monitor all Flex Credit consumption across Agentforce and Data 360. Set it up immediately after activation to establish a consumption baseline.

**Required prerequisites:**
- Customer must have a Flex Credits or consumption-based SKU (A4X, A1E, or Agentforce Foundations Flex).
- The user accessing Digital Wallet needs the "View Consumption" permission.
- Data Cloud must be provisioned (Step 3 in the activation sequence must be complete).

**How to access:**
1. In App Launcher, search "Digital Wallet."
2. Open the Digital Wallet app.
3. Review the Flex Credits consumption card, which shows:
   - Current Flex Credits remaining vs. purchased
   - Consumption broken down by type (Agentforce actions, Data 360 usage, prompts, voice)
   - Sandbox vs. production split
   - Historic usage analytics

**Critical:** Digital Wallet does **not** block execution when credits run out. Overages are billed at the contracted rate. Setting up threshold alerts is essential.

**How to set up consumption threshold alerts:**
1. In Setup, go to Flow.
2. Find and activate the "Consumption Threshold Alerts" flow template.
3. Configure alert thresholds — recommended: 75%, 90%, and 100% of credit balance.
4. Alerts are sent via email and can also trigger custom Salesforce Flows for additional automation.

---

### Key Limits to Know

| Limit | Value | Impact |
|---|---|---|
| Delegation timeout (hard) | 90 seconds | Bespoke agents called by Coworker must complete within this window |
| Search Agent (AI answer) | 100 requests per minute | Platform enforced; uses Agentforce Models API |
| Active/Committed Agents per org | 100 max | Org-level limit; relevant for large multi-agent deployments |
| File size for indexing | 75MB max | Files above this limit will not be indexed |

The 90-second timeout is the most operationally significant limit for agent design conversations.

---

### Known Friction Points from the Field

**Button not appearing next to the search bar**
- Most common cause: "Turn on End User Experience" was not completed. Go back to Setup → Ask Agentforce → click Manage and accept the Beta terms.
- The Coworker button only appears in Sales Console and Service Console. It does NOT appear in standard Lightning apps.
- Try a hard refresh (Cmd+Shift+R / Ctrl+Shift+R) or Chrome incognito to rule out browser caching.

**Agentforce toggle not showing in Agent Studio**
- Einstein Generative AI must be turned on first (Step 1). The toggle will not appear until Einstein is active.

**Activate button is greyed out or missing**
- Data Cloud provisioning has not completed. Do not proceed until Data Cloud Setup Home shows active status with no provisioning spinner.

**Permission sets not visible in the org**
- Sets may still be named "Ask Agentforce Admin/User" rather than "Agentforce Coworker Admin/User." Search for "Ask Agentforce" if you cannot find the expected names.

**Admin can see the correct SKU but still cannot access Coworker in Setup**
- The `Agentforce Coworker Admin` permission set alone is not sufficient. The admin must also hold the Salesforce System Administrator profile. Assigning the permission set without that profile does not work.

**`AI Search Setup` PSL not provisioned**
- A known gap where the `AI Search Setup` PSL is absent even for eligible customers. This must be requested through your AE/CSM for product provisioning. Escalate to the `#help-sell-agentforce-coworker` Slack channel.

**Toggle not appearing in Setup despite correct SKU**
- There is a known rollout delay of 1-2 days after eligibility is established. If a customer has the correct SKU and still does not see the toggle, wait 24-48 hours before escalating.

**Seat-based customers unexpectedly consuming Flex Credits**
- Users on Agentforce for Sales or Service per-seat licenses should be unmetered, but if the `Access_Ai_Search` Permission Set Group is not properly assigned, they fall into metered consumption. Do not skip permission assignment even for seat-based users.

**"API Enabled" permission conflict**
- The `Access_Ai_Search` Permission Set Group requires "API Enabled" for end users. Security-conscious customers may push back on this. There is no current workaround. Escalate to the product team.

**No conversation history across sessions**
- Current beta limitation. Conversations do not persist across sessions. This is on the product roadmap. Set customer expectations before demos.

**Built-in Search Agent cannot be hidden**
- The default Search Agent that comes with Coworker is not hideable or reorderable in the Employee Agent list. This has been flagged as a limitation in at least one EMEA production support case.

**Employee Agent list cannot be reordered**
- Admins cannot currently control the order in which Employee Agents appear to users in the Coworker experience.

**Localization issue**
- In at least one instance, the French-language UI showed "Ask Astro" instead of "Ask Coworker." If a customer's French-speaking users report unexpected branding, this is a known localization issue, not a configuration error.

**Implicit routing reliability**
- As described in Section 3, routing is less reliable when the user does not name the target agent. First mitigation is always description hygiene.

---

## Section 8: Open Questions to Track

These items were open or unconfirmed as of September 2026. Do not make commitments to customers on any of these. Check official Salesforce release notes for updates.

**A2A Inbound native GA:** Targeted Summer 2026; not yet confirmed as complete. Customers who need this capability today should use Agent API (GA) plus MuleSoft Flex Gateway.

**Server-side session persistence:** Architecturally supported. Not yet built as of mid-2026 testing. Multi-turn delegated conversations may not reliably maintain context across all turns.

**Teams, ChatGPT, Claude, Desktop App surfaces:** Targeted October 2026. Not confirmed GA. Do not commit to these timelines.

**CTA rendering in Coworker chat:** Not yet confirmed whether delegated agents can render buttons or structured CTAs in Coworker's chat interface, or only plain inline links.

**Coworker and Slackbot convergence:** Active internal discussions are underway. No confirmed roadmap item to share externally.

**Employee Agent list management:** No confirmed timeline for hiding or reordering agents in the Coworker experience.

**Implicit routing reliability:** Flagged to the product team as an open validation item. Resolution status unknown.

**Skills in Coworker GA:** Customer Beta access expected shortly after the mid-August 2026 internal launch. Verify current status before committing to customers.

---

## Section 9: Quick Reference Card

*Use this before a customer call for a fast orientation.*

---

**Agentforce Coworker in one sentence:** An AI teammate embedded in Salesforce Global Search that finds information, summarizes situations, runs Skills, and delegates tasks to specialized Agentforce agents — all in one conversation.

**Bespoke Agentforce agents in one sentence:** Purpose-built AI agents designed for a specific business workflow, using a combination of deterministic logic and LLM reasoning to produce reliable, auditable results.

**Skills in one sentence:** Reusable, multi-step workflows that users build conversationally inside Coworker, save by name, and run with "/" or automatically based on intent — free to create, credits only for actions invoked.

---

**The Three Modes**

- **Find:** Plain-language Q&A across 300+ sources (CRM, Slack, and connected data), role-contextualized.
- **Catch Up:** Instant summaries across cases, pipeline, and Slack threads, running proactively in the background.
- **Act:** Executes workflows by routing to bespoke agents or running Skills — within the same conversation.

---

**Quick Decision Guide**

| Signal | Recommendation |
|---|---|
| Open-ended Q&A, summaries, catch-up | Coworker |
| Deterministic process, compliance logic, audit trail | Bespoke agent |
| Natural language front door to a complex workflow | Both (Coworker routes to bespoke agent) |
| Brittle legacy automation doing open-ended Q&A | Replace with Coworker |
| Repeatable multi-step process, user wants to build it themselves | Skills in Coworker |

---

**Slackbot vs. Coworker**

| Customer Profile | Use |
|---|---|
| Salesforce only | Agentforce Coworker |
| Slack only | Slackbot |
| Both | Both — whichever surface you are working in |

---

**Activation Sequence at a Glance**

1. Einstein Setup → Turn on Einstein
2. Agentforce → Agent Studio → Toggle Agentforce Agents ON
3. Data Cloud Setup Home → Get Started (wait up to 90 min — send ahead of time)
4. Assign `Agentforce Coworker Admin` PS to admin AND confirm System Admin profile
5. Get Started with Agentforce Coworker → Turn On → Manage Access → assign users
6. Sales/Service Console → hard refresh → verify button → run a live prompt
7. (A4X) Permission Set License Assignments → Unmetered User Based AI → check box
8. App Launcher → Digital Wallet → set threshold alerts at 75%, 90%, 100%

---

**Top 3 Watch-Outs: Coworker**

1. Not for deterministic, tightly-scoped processes.
2. User access is a **separate step** from org-level activation — the most commonly missed step.
3. Routing quality is only as good as the target agent's description quality.

**Top 3 Watch-Outs: Bespoke Agents**

1. Real build effort — not appropriate for use cases Coworker handles out of the box.
2. Maintenance burden grows with complexity; avoid over-engineering.
3. Descriptions must be specific and distinct, or Coworker will not route to them reliably.

**Top 3 Watch-Outs: Skills**

1. Skills are private by default — users must explicitly share them.
2. Flex Credits are consumed by actions invoked inside a Skill, not by creating or storing Skills.
3. Creating Skills conversationally requires the user to review and correct the auto-generated name and description — do not rely on Coworker to name it correctly.

---

**Key Numbers**

- **90 seconds:** Hard timeout for Coworker-delegated tasks. No exceptions today.
- **Free:** Cost of creating and storing Skills (actions inside Skills cost credits).
- **Unmetered:** Cost of Coworker for A1E, A4X, and seat-based Agentforce for Sales/Service customers.
- **August 4-7, 2026:** General availability date.
- **~2,000 orgs, ~30,000 users:** Beta adoption benchmark.
- **12.5M monthly active users, 1B CRM searches/month:** The market Coworker is meeting where it already is.
- **34-75 consumption units per search:** Internal testing reference for Flex Credit sizing (not for customer commitments).
- **75MB:** Maximum file size for indexing in Data 360 connected sources.
- **100:** Maximum active/committed agents per org.
- **270+:** Data 360 connectors available for Phase 2 data source expansion.
- **300+:** Sources Coworker's Find mode can query across.
- **1-2 days:** Known rollout delay for the Agentforce Coworker toggle to appear for newly eligible customers.

---

**Escalation Channels**

- Field questions and live support: `#help-sell-agentforce-coworker`
- VOC and bug reports: `#agentforce-coworker-feedback`
- Demo org license requests: `#q-branch-xdo-license-extension-requests`
- Skills feedback: `#feedback-coworker-skills`
