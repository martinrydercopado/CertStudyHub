# Agentforce Agent Surfaces
## A Reference Guide for Success Architects

*Updated August 23, 2026*
*This guide was generated using AI with grounding in official Salesforce documentation. Review for accuracy before using.*
---
> **Purpose:** To give you a complete, grounded understanding of every major surface (deployment channel) where an Agentforce agent can live — what it is, why it matters, how it works, and what can go wrong.
---

> **A note on release-sensitive information:** This guide contains references to GA dates, deprecation timelines, and surface availability for specific features. These are accurate as of the document's publication date but can shift quickly between Salesforce release cycles. Before sharing this guide with a client or quoting a specific date in a discovery or design session, verify the current status against the latest [Salesforce Release Notes](https://help.salesforce.com/s/articleView?id=release-notes.salesforce_release_notes.htm) and the relevant product roadmap. Dates marked with ⚠️ are particularly time-sensitive.

---

## How to Use This Guide

Each surface section follows the same structure:

- **What it is** — a plain-language definition
- **Why this matters** — the business case for caring about this surface
- **How it works** — technical setup and architecture
- **Typical use cases** — where this surface shines
- **Scenario** — a realistic client situation you can use in conversations
- **Pros and trade-offs** — honest assessment to help clients choose well

---

## The Foundation: "Build Once, Deploy Anywhere"

Before diving into individual surfaces, the most important concept to internalize is Agentforce's architectural promise: you build an agent once in Agent Builder (topics, actions, instructions), and then you expose it on one or more surfaces without rebuilding the logic.

This is not just a convenience feature. It is a strategic design principle. A client who understands this from day one will make better decisions about agent design, governance, and roadmap sequencing. A client who doesn't will try to build a separate "voice bot," a separate "web chat bot," and a separate "Slack bot," tripling their maintenance burden and fragmenting their logic.

Your job is to anchor every surface conversation in this principle first.

---

## Surface 1: Slack

### What it is

Agentforce agents surfaced inside Slack as native Slack apps. Employees can interact with them via `@mention` in a channel, via a direct message (DM), or through the **Agentforce Hub** — a dedicated threaded interface for multi-agent interaction.

### Why this matters

Most knowledge workers live in Slack. Every time an employee has to leave Slack, open a browser, log into Salesforce, and navigate to a record just to get an answer, you're losing seconds that compound into hours across a team. More importantly, you're creating friction that makes people give up and guess instead.

Slack agents eliminate context-switching for your client's internal workforce. They turn an AI agent into something that feels like a smart colleague sitting in the same channel, rather than a tool in a different app. That perception shift drives adoption.

### How it works

**Enabling the integration:**
1. Connect the Salesforce org to Slack via **Setup > Slack > Slack Apps Setup**. In Stage 3, enable the **Agentforce for Slack** app. If it does not appear, the org entitlement needs provisioning by Salesforce Support.
2. Build or configure the agent in Salesforce Agent Builder, then enable the **Slack** channel on the agent's Channels tab.
3. Install the resulting Slack app in the target workspace. Only a Slack Org Owner or Admin can complete the "Install Agent" step. Employee Agents auto-assign user access from Salesforce on install.

**For custom or advanced integrations:**
Create a Slack app with bot scopes (`chat:write`, `app_mentions:read`) and call the Agentforce API from a webhook listener, authenticating to Salesforce via a Connected App using OAuth JWT Bearer flow.

**Licensing note:** Each Slack user who interacts with the agent must have both Salesforce org access and Slack access. If you have employees who only need Slack access, the **Agentforce User License (AUL)** grants scoped, non-CRM access without requiring a full Salesforce seat.

**Permission model:** This surface enforces a dual permission check — Slack permissions AND Salesforce permissions. Users can only see data they are authorized to see in both systems. This is a meaningful security feature, not a footnote.

### Typical use cases

- Internal Q&A grounded in Slack canvases and company documents
- HR, IT, and sales enablement agents
- Finance or M&A assistants that surface CRM data in-channel
- Employee productivity agents for time-sensitive decision support

### Scenario

A financial services firm has 500 relationship managers who use Slack as their primary communication tool. They spend an average of 12 minutes per day navigating into Salesforce to look up account summaries, recent activity, and open opportunities before client calls. With a Slack-based Agentforce employee agent, reps can `@mention` the agent directly in a deal channel and get a synthesized account brief in seconds — without leaving Slack. The time savings compound across the team to a measurable reduction in pre-call prep time.

### Pros

- No context-switching for employees
- Strong dual-permission model (Slack + Salesforce enforcement)
- Native Agentforce Hub for threaded, multi-agent interaction
- Admins get full control over which users and channels can access the agent

### Trade-offs and limitations

- **No Slack Connect support.** The agent cannot be used in cross-org (Slack Connect) channels. If your client operates with external partners via Slack Connect, this is a hard limitation today.
- **No passive listening.** The agent always requires an explicit `@mention` or DM to respond. It cannot monitor a channel and proactively intervene.
- **Channel visibility.** When an agent responds in a public channel, the response is visible to all channel members. Sensitive data must be handled in DMs or in restricted channels.
- **Legacy deprecation.** The original "Channel Expert" (Agentforce-hosted version) was deprecated in favor of the native Slackbot implementation. ⚠️ The specific deprecation date cited in earlier documentation should be verified against current release notes before referencing with a client, as enforcement timelines can shift. Clients on the old pattern should plan to migrate regardless of the exact date.

---

## Surface 2: Salesforce In-App (Agentforce Assistant)

### What it is

A conversational sidebar assistant embedded directly in the Salesforce Lightning UI. Formerly called Einstein Copilot, this is the agent experience that appears when a user clicks the **Einstein icon** in the top-right corner of any Lightning app. Users ask questions and trigger actions without ever leaving the record or page they are working on.

### Why this matters

For your clients who have invested heavily in Salesforce as a CRM, this surface delivers the highest data grounding of any channel. The agent has native, real-time access to exactly the record the user is looking at — the Opportunity they are qualifying, the Case they are investigating, the Account they are preparing to call. No retrieval needed. No context lost.

This surface also comes with a built-in **admin analytics dashboard** (formerly Copilot Analytics) that gives administrators visibility into what users are asking, what actions are being taken, and where the agent is being used. That is a critical tool for proving ROI and refining the agent over time.

### How it works

**Enabling:**
1. Go to **Setup > Generative AI** and turn on Einstein.
2. Go to **Setup > Agents > Agentforce Agents** (Agent Studio) to configure or enable the default agent.
3. Users access it by clicking the Einstein icon in the top-right of any Lightning app.

**Extending and customizing:**
Use Einstein 1 Studio tools:
- **Prompt Builder** — create reusable, data-grounded prompts
- **Agent Builder / Copilot Builder** — add custom topics, actions, and skills

### Typical use cases

- Summarizing an Opportunity or Case record in plain language
- Drafting emails grounded in CRM data from the current record
- "Recommended Actions" — single-click suggestions contextual to the page the user is viewing
- General Q&A over org data without navigating away from the current record

### Scenario

A sales manager at a B2B SaaS company spends the first 10 minutes of every deal review manually reading through an Opportunity's activity history, related contacts, and open tasks to prepare talking points. With Agentforce Assistant enabled, they click the Einstein sidebar while on the Opportunity record and ask: "Summarize this deal and highlight any risks." The agent — grounded in the live record, related contacts, and recent emails — produces a concise brief in seconds. The manager reclaims that prep time for every deal reviewed.

### Pros

- Richest data grounding of any surface (native access to the live record context)
- Zero installation required for end users
- Built-in admin analytics for adoption tracking and ROI measurement
- Low-code extensibility via Einstein 1 Studio
- Works for both Service Cloud and Sales Cloud workflows

### Trade-offs and limitations

- **Salesforce-seat only.** This surface only reaches users actively working inside Salesforce. It cannot touch external customers or employees who do not have a Salesforce license.
- **Requires active CRM usage.** It is not useful for employees who are rarely in Salesforce.

---

## Surface 3: Messaging Channels (SMS, WhatsApp, Web/MIAW)

### What it is

Agentforce Service Agents connected to Salesforce's **Enhanced Messaging** framework, enabling customers to have AI-powered conversations over SMS, WhatsApp, web messaging widgets (MIAW: Messaging for In-App and Web), or other messaging platforms. Conversation context is preserved even if a customer switches channels mid-journey.

### Why this matters

Your clients' customers do not live in Salesforce. They live on their phones. They text. They use WhatsApp. They open a web chat widget when they have a question at 10pm and expect an answer without waiting until business hours.

This surface is the primary way Agentforce reaches customers at scale. An agent on messaging channels can handle thousands of simultaneous conversations, resolve routine requests autonomously, and hand off to a human representative with full context intact — so the customer never has to repeat themselves. That last point is one of the most impactful things you can sell.

### How it works

**Routing architecture:**
1. Build an **Omni Flow** — a Salesforce Flow used within Omni-Channel — to define routing rules for incoming messages. The flow identifies the contact, creates a case if needed, and determines whether to route to a human, a legacy Einstein Bot, or an Agentforce Agent.
2. In the Route Work Action within the flow, set the routing type to **Bot** and attach it to the Messaging channel. The setup is technically identical to routing to a legacy bot.
3. Add the Agentforce agent as the connected bot for that channel and flow.

**Mid-conversation handoff:** The Omni-Channel routing infrastructure supports escalation from the agent to a live service representative, with full conversation history preserved. The representative sees everything — no cold start.

**Channel context:** Unified conversation history via Data Cloud means that if a customer reaches out over WhatsApp today and web chat tomorrow, the agent recognizes them and does not start from scratch.

### Typical use cases

- Order status and tracking inquiries (24/7, no rep required)
- Appointment scheduling and rescheduling
- Account questions and balance lookups
- Proactive outbound notifications triggered by system events
- Two-way conversational support at high volume

### Scenario

A telecom company receives 40,000 inbound SMS messages per month about billing questions. Most are simple: "What is my balance?" or "When is my payment due?" An Agentforce Service Agent connected to the SMS channel handles these autonomously, pulling real-time data from Salesforce. Complex billing disputes are escalated to a live agent, who receives the full conversation history in their Service Console. Resolution rates improve, average handle time drops, and live reps focus only on cases that genuinely need human judgment.

### Pros

- Broadest reach across the consumer platforms customers already use
- Reuses existing Omni-Channel routing infrastructure — familiar territory for Service Cloud admins
- Supports mid-conversation human handoff with full context
- Asynchronous by nature — customers can pick up a conversation where they left off

### Trade-offs and limitations

- **Setup complexity scales with channel count.** Each channel (SMS, WhatsApp, web) requires its own Omni Flow configuration. Managing multiple channels means maintaining multiple flows.
- **Message format constraints.** SMS and WhatsApp have limits on message length and formatting (no rich text, no lists in some cases). Agent response design must account for these constraints — a response that looks great in web chat may be cluttered as an SMS.

---

## Surface 4: Embedded Service (Website Web Chat)

### What it is

Agentforce deployed directly on a company's website as the first touchpoint for digital visitors, via **Embedded Service Deployments**. This is the chat widget that appears in the corner of a website, inviting visitors to start a conversation.

### Why this matters

A website is often the first interaction a prospect or customer has with a company. A traditional static FAQ page or a phone number they have to dial cannot compete with an intelligent, conversational agent that can answer their specific question in real time — at any hour.

More importantly, this surface is designed for anonymous visitors. The agent does not need to know who someone is to start helping them. And when identity is established — through a pre-chat form or a Data Cloud profile match — that context carries forward, so the experience feels personalized rather than generic.

This surface also supports **proactive engagement**: the agent can initiate a conversation based on visitor behavior, such as someone spending time on a pricing page or returning to an abandoned cart. That shifts the agent from reactive support to active pipeline contribution.

### How it works

**Setting up an Embedded Service deployment:**
1. Configure an **Embedded Service Deployment** in Salesforce Setup, including pre-chat forms (for collecting name, email, or other identifiers) and proactive messaging triggers based on visitor behavior or page activity.
2. Connect the Agentforce agent to the deployment.
3. Embed the resulting code snippet on the client's website. Salesforce creates an embedded service deployment automatically when you create a messaging channel, which you then publish and embed.

**Identity resolution:** Data Cloud can match a website visitor to a unified customer profile using identity signals collected during the interaction (email address from the pre-chat form, for example), enabling personalized responses grounded in the customer's history.

**Testing before production:** Publish and test the Embedded Service deployment in a sandbox environment before deploying to staging or production. Make sure Einstein Generative AI, Agentforce, and Data Cloud are all enabled in the target environment.

### Typical use cases

- Answering pre-sales questions for anonymous visitors
- Self-service support as an alternative to calling or emailing
- Proactive outreach to visitors who show purchase intent signals
- Lead capture and qualification before routing to a sales rep

### Scenario

A medical device manufacturer launches a new product line and updates their website. Marketing drives significant paid traffic to product pages, but the conversion rate is low because visitors have technical questions the static pages do not answer. An Agentforce agent is deployed on the product pages via Embedded Service. It answers clinical and technical questions, identifies visitors who are likely procurement leads by collecting their email, and routes qualified conversations to a human sales representative — with the full conversation history attached. The sales team receives warmer leads with more context, and the cost per qualified lead decreases.

### Pros

- First-touch coverage for anonymous and unauthenticated visitors
- Proactive engagement capability — the agent can start the conversation
- Native Data Cloud identity resolution once a visitor identifies themselves
- Supports escalation to phone or messaging without the customer having to repeat context

### Trade-offs and limitations

- **Thin context pre-identity.** Before a visitor identifies themselves, the agent has limited context to personalize the experience. Design the pre-chat form thoughtfully.
- **Rollout timelines vary significantly.** A typical deployment of web chat plus one messaging channel can take several weeks. Full omnichannel maturity — web chat plus multiple messaging channels with consistent identity resolution — can take several months. These timelines are planning heuristics only; actual duration depends heavily on data readiness, org complexity, integration requirements, and client resourcing. Do not share specific week or month estimates with clients as commitments.

---

## Surface 5: Voice (Agentforce Voice)

### What it is

The same agent configuration — the same topics, actions, and Agent Builder setup — extended to inbound phone calls. Voice is treated as a channel, not a separate product. Enabling it does not require rebuilding the agent; it requires enabling the Voice channel within Agent Builder and connecting to a telephony or CCaaS provider.

A related capability, **Voice for Digital Channels**, extends this further: it is designed to allow a single conversation to switch mid-stream between typing and speaking — across web chat, mobile, and WhatsApp — without losing context. ⚠️ Verify current GA status and supported surfaces against the latest release notes before referencing this capability in client discussions, as digital-voice feature availability has evolved across recent releases.

### Why this matters

Phone calls are not going away. Many of your clients' customers still prefer calling, especially for time-sensitive or emotionally significant issues. But phone support is expensive: it requires live agents, operating hours, and significant queue management overhead.

Agentforce Voice captures the high-volume, low-complexity end of the call spectrum — the calls that never needed a human rep in the first place. Status checks. Account lookups. Appointment confirmations. Routine requests that can be answered from data already in the Salesforce org.

The business value is straightforward: fewer calls handled by humans means lower cost per contact, shorter queue wait times, and live reps freed to focus on calls that genuinely need their judgment and empathy.

### How it works

**Enabling voice:**
1. Enable the **Voice** channel from within Agent Builder for an existing or new agent.
2. Connect to a telephony or CCaaS provider. Agentforce Voice connects via PSTN (Public Switched Telephone Network) or SIP (Session Initiation Protocol).

**Voice for Digital Channels** uses WebRTC — a lightweight internet protocol — to embed click-to-talk AI voice experiences directly into websites, portals, or mobile apps. This does not require a phone number or traditional telephony infrastructure. ⚠️ Confirm current availability and supported channel combinations in the latest release notes before recommending this pattern to a client.

**Design considerations for voice:** Voice agents require different response design than text agents. Responses must be speakable — no URLs, no markdown formatting, no visual elements. Critical data (IDs, amounts, dates) should be read back to the caller before action is taken. Filler phrases ("Let me look that up for you...") help manage the perception of latency during data retrieval. ASR (automatic speech recognition) repair prompts should be included for cases where the system cannot understand the caller.

### Typical use cases

- Inbound status checks (order status, account balance, appointment confirmation)
- Account lookups and routine information requests
- High-volume, low-complexity calls resolvable in under 2 minutes
- 24/7 coverage for calls that arrive outside business hours

### Scenario

A utility company receives 80,000 inbound calls per month. Analysis reveals that 55% are for one of three requests: outage status, payment due date, and balance confirmation. None of these require a live agent — they simply require pulling real-time data from Salesforce and communicating it verbally. Agentforce Voice handles these autonomously, with a clean escalation path to a live rep for anything outside those topics. The result is a measurable reduction in average speed to answer, lower cost per call, and live reps who spend their time on billing disputes and escalated service issues rather than answering "Is there an outage in my area?"

### Pros

- One agent configuration powers chat, messaging, and voice — true "build once, deploy anywhere"
- Designed for real-time, low-latency response
- Voice for Digital Channels is designed to enable channel-switch continuity between typing and speaking (verify current GA status)
- No separate voice-bot platform required

### Trade-offs and limitations

- **Not a replacement for complex calls.** Voice works best for low-complexity, high-volume requests. Calls requiring nuanced judgment, emotional intelligence, or multi-party escalation still need human reps.
- **Feature parity is still maturing.** Voice is a newer capability. Some features available in chat channels may not yet be available in the voice channel. Verify current parity against release notes before committing a client to a voice-first design.

---

## Surface 6: Mobile and Field (Salesforce Mobile App)

### What it is

Agentforce Assistant and agents surfaced inside the **Salesforce Mobile App**, giving field employees and mobile-first workers the same in-app assistant experience they would have on a desktop browser. No separate mobile-specific agent build is required — the same agent configuration runs on both surfaces.

### Why this matters

Not every employee who uses Salesforce sits at a desk. Field service technicians, sales reps on the road, and medical device reps visiting hospital accounts are all working from phones or tablets. Historically, these users have had a degraded experience compared to their desk-bound colleagues — fewer features, more friction, less capability.

Agentforce on mobile changes that equation. A field rep standing in a customer's lobby can ask the agent to pull up the account summary, recent service history, or open cases — and get a synthesized answer without having to navigate through multiple screens on a small touchscreen. That is a direct improvement in the quality of every in-person interaction.

### How it works

The mobile surface inherits the desktop agent configuration. No additional setup specific to mobile is required beyond enabling the agent in Agent Builder and ensuring users have the appropriate permissions. The same topics, actions, and instructions power the mobile experience.

### Typical use cases

- Field service reps checking work order details, parts availability, or customer history on-site
- Sales reps pulling account briefs and opportunity summaries before a client visit
- Quick record lookups and data entry actions without desktop access

### Scenario

A medical device sales team spends most of their time at hospital accounts, rarely sitting at a desk. Before visiting a customer, reps previously had to either memorize key details from Salesforce or accept that they would be working from memory. With Agentforce on mobile, a rep walking toward the hospital entrance can ask the agent: "What are the open opportunities at this account and what was discussed in the last meeting?" The agent responds with a synthesized brief pulled from CRM data. The rep walks in prepared.

### Pros

- Same "build once" agent logic as desktop — no separate mobile agent build required
- Extends CRM-grounded assistance to employees who are rarely at a desk
- Consistent agent behavior and configuration across mobile and desktop

### Trade-offs and limitations

- **UI real estate constraints.** Mobile screens are small. Agent responses that include long lists, formatted tables, or multi-step instructions may be harder to read on a phone. Design responses with mobile consumption in mind.
- **Connectivity dependency.** Field agents in low-signal environments (basements, rural areas, large facilities) may experience degraded performance. This is worth surfacing with clients who deploy to field-heavy workforces.

---

## Surface 7: Agentforce Coworker

> **GA status:** Agentforce Coworker reached General Availability in August 2026. Surface rollout is phased — see the Availability section below for current details. Source: [Salesforce Blog, August 2026](https://www.salesforce.com/blog/agentforce-coworker-salesforce-ai-teammate/)

### What it is

Agentforce Coworker is an enterprise AI teammate designed to act as a universal front door across an organization's enterprise data via **Data 360**, living natively inside the apps employees already use. Rather than being a single-purpose agent built for one task, Coworker routes each request to the right trusted data source, workflow, or specialized agent — automatically, without the employee needing to know which tool to use.

Three core capabilities define the Coworker experience:

- **Find** — answer questions from CRM data, Slack conversations, files, knowledge bases, and 270+ connected enterprise sources
- **Catch up** — deliver proactive insights and alerts relevant to the user's context
- **Plan and act** — orchestrate specialized AI agents to take action, including drafting follow-ups, sending emails, and escalating issues

### Why this matters

As organizations build multiple specialized agents, a new problem emerges: agent sprawl. Employees do not know which agent to use for which question. They route to the wrong one, get a dead end, and give up. The promise of AI-assisted productivity erodes because of discovery friction.

Coworker solves this by providing a single, persistent entry point that routes intelligently. It also compounds value over time — the more data sources and specialized agents connected to it, the more capable it becomes, without requiring a rebuild of the underlying agents. That is a powerful argument for thinking about your client's agent ecosystem strategically from day one, rather than building one-off agents without a unified access layer.

### How it works

**Enabling Coworker:**
- Coworker is enabled for eligible Salesforce orgs from Setup. It can be reached via the **"Ask Agentforce"** experience in Salesforce Global Search.
- Before enabling, Salesforce recommends completing a **SABWA readiness pass** — reviewing question categories and separating what users need to *know* (route to data sources and knowledge) from what they need to *do* (route to an existing Agentforce agent or specialized workflow).
- Connect the data sources and specialized agents you want Coworker to route to. Effectiveness grows as more sources are added.

**Current surface availability (as of August 2026):**
- Salesforce Lightning Experience — generally available, currently in beta within the Salesforce surface as rollout completes
- Microsoft Teams — coming later in 2026
- ChatGPT — coming later in 2026
- Claude — coming later in 2026
- Desktop app — coming later in 2026

⚠️ Surface-by-surface rollout is ongoing. Confirm the current availability of each surface against the [Salesforce Blog announcement](https://www.salesforce.com/blog/agentforce-coworker-salesforce-ai-teammate/) and the latest release notes before committing a client to a specific surface.

**Routing behavior:** Coworker automatically determines the right destination for each request and orchestrates the work. It can both answer questions and trigger actions across connected agents and flows.

### Typical use cases

- A single entry point for employee questions that span multiple systems or specialized agents
- HR and benefits questions routed to knowledge articles or an employee handbook agent
- "How do I..." questions answered from internal documentation
- Multi-step requests where Coworker identifies the right specialized agent and hands off execution

### Scenario

A large enterprise has deployed five specialized Agentforce agents: an HR agent, an IT help agent, an Opportunity management agent, a finance reporting agent, and a facilities agent. Employees are not sure which agent to use for a given question. Adoption is fragmented. With Coworker enabled, employees have one place to go in Salesforce, and Coworker routes the request intelligently. An employee asking "How do I submit a reimbursement and then check if my laptop order has shipped?" gets both questions handled in one interaction, routed to the finance and IT agents respectively, without the employee needing to know those agents exist. As Teams, ChatGPT, and Claude integrations roll out later in 2026, that same single entry point extends to wherever the employee is working.

### Pros

- One consistent entry point across Salesforce today, with Teams and other surfaces coming later in 2026
- Gets more effective as more agents and data sources are connected — no rebuild required
- Can answer questions and orchestrate work across existing agents and flows
- Grounded in the same Data 360 platform as other Agentforce surfaces
- Generally available — clients can enable and deploy today

### Trade-offs and limitations

- **Surface rollout is phased.** The Salesforce surface is the starting point; Teams, ChatGPT, Claude, and the desktop app are all slated for later in 2026. If a client's workforce is primarily in Teams, the value proposition is partially deferred.
- **Effectiveness depends on upfront setup.** Connecting the right data sources and agents, and completing the SABWA readiness pass, are prerequisites — not optional. A poorly configured Coworker provides a worse experience than no Coworker at all.
- **Rich UI patterns are not yet portable.** Response formatting features (tables, record links, step-completion UI) are specific to Coworker's own experience and are not yet a reusable pattern for custom Employee Agents.

---

## Surface Selection: A Decision Framework

Use these questions to guide a client conversation about which surface or surfaces to prioritize.

**Who is the end user?**
- Internal employee in Salesforce → In-App (Agentforce Assistant)
- Internal employee in Slack → Slack Surface
- Internal employee in the field → Mobile/Field
- External customer → Messaging Channels or Embedded Service (web chat)
- Calling in by phone → Agentforce Voice

**Where does the user spend their time?**
Start on the surface where your users already are. Adoption is always easier when you bring the agent to the user rather than asking the user to go somewhere new.

**How complex is the interaction?**
- Single-question, single-answer → Any surface
- Multi-step workflow with data retrieval → In-App or Messaging
- Requires live record context → In-App (richest grounding)
- High-volume, low-complexity, needs 24/7 → Voice or Messaging

**What is the rollout timeline?**
- Fastest to enable → In-App (native, just turn it on)
- Moderate setup → Slack, Voice, Mobile
- Longer lead time → Messaging Channels (Omni Flow complexity), Embedded Service

**Is this one agent or many?**
- One specialized agent → Direct surface deployment
- Multiple specialized agents + unified employee access → Agentforce Coworker (GA, Salesforce surface available now; Teams and others coming later in 2026)

---

## Key Concepts Glossary

**Agent Builder** — Salesforce's low-code tool for creating and configuring Agentforce agents: defining topics, instructions, and actions.

**Agentforce Hub** — The threaded Slack interface where employees can converse with one or more Agentforce agents, similar to a dedicated DM or channel thread.

**Agentforce User License (AUL)** — A scoped Salesforce license granting a Slack-only user limited, non-CRM access to an Agentforce agent without requiring a full Salesforce seat.

**Atlas Reasoning Engine** — The AI reasoning engine that powers Agentforce agents, interpreting user requests, identifying the right topics and actions, and generating plans of action steps.

**Data 360** — Salesforce's unified data platform (formerly Data Cloud) that consolidates customer and enterprise data across systems, providing agents with a single, trusted view of information.

**Einstein 1 Studio** — The set of low-code tools (Prompt Builder, Agent Builder) for customizing AI assistants and embedding prompts and actions across Salesforce apps.

**Einstein Trust Layer** — The security and compliance layer embedded in all Agentforce interactions, including data masking, toxicity detection, prompt injection detection, and zero data retention with external LLM providers.

**Embedded Service** — Salesforce's website chat widget framework. Embedded Service Deployments place an Agentforce agent on a company website as the first digital touchpoint.

**Employee Agent** — An Agentforce agent configured for internal, employee-facing use cases (HR, IT, sales enablement), distinct from customer-facing Service Agents.

**Enhanced Messaging** — Salesforce's messaging channel framework supporting SMS, WhatsApp, web messaging (MIAW), and other platforms through a unified conversation model.

**MIAW (Messaging for In-App and Web)** — Salesforce's product name for embeddable web and in-app messaging and chat.

**Omni Flow** — A Salesforce Flow used within Omni-Channel to define routing logic for incoming work, determining whether to route to a human, an Einstein Bot, or an Agentforce Agent.

**Omni-Channel** — Salesforce's routing engine that assigns incoming work items (cases, chats, messages) to the right queue, human agent, or bot based on configured rules.

**SABWA** — A governance and readiness review practice Salesforce recommends before enabling Agentforce Coworker, focused on categorizing what employees need to know vs. what they need to do.

**Voice for Digital Channels** — An Agentforce Voice capability designed to allow a single conversation to switch between typed and spoken interaction across web, mobile, and messaging channels without losing context. ⚠️ Verify current GA status and supported surfaces before referencing in client conversations.

---
