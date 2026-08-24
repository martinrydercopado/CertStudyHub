# Agentforce Help Agent: Outcome-Based Pricing

> **Scope:** This guide covers the Agentforce Help Agent as generally available in July 2026. It is intended to help a Success Architect make an honest, grounded recommendation — knowing both where this product genuinely delivers and where current limitations will affect a client's expectations.
>
> **Pricing Note:** Salesforce pricing guidance should always be confirmed with the account executive and the current Sales Guide before a client conversation.

---

## 1. What It Is (and What It Isn't)

Agentforce Help Agent is a **prepackaged, autonomous service agent** built on top of the full Agentforce 360 Platform. It is not a new platform or a separate product. As Kishan Chetan (EVP and GM of Agentforce Service) has stated directly: *"This isn't new technology. It has everything from Agentforce — the ability to define your topics, to use Agent Script, our more deterministic approach. We just did three things on top of it."*

Those three things are:

1. **Genuinely fast setup** — a guided flow in Salesforce Go that provisions a working agent in fewer than ten steps
2. **Simplified outcome-based pricing** — pay only when an issue is resolved, start to finish
3. **A more capable portal experience** — a reimagined Customer Service Portal built around a conversational interface

The key mental model for a Success Architect: Help Agent is the **opinionated, fast-start layer** on top of Agentforce. Everything the client configures through the guided setup lives in standard Agentforce metadata. After setup, the agent is fully extensible through Agentforce Builder, Flows, and Apex — exactly as any custom-built agent would be.

---

## 2. Business Value Proposition

### 2.1 Speed to Value

The headline claim is deployment in minutes, not weeks. The setup flow provisions the following automatically in the background:

- Data 360 enablement
- Agentforce enablement and license assignment (Community, CCaaS as needed)
- A default Agentforce Data Library (ADL) for uploaded files or website sync
- Omni-Channel routing and an Omni Flow for human escalation
- Enhanced Chat and Messaging for In-App and Web

In a live demo, Prasad Raje (SVP of Product) provisioned a **working voice agent — including acquiring a phone number in-flow** — across three screens. Standing up a help line through a third-party telephony vendor is typically a multi-week project. That comparison is a genuine, credible differentiator for clients evaluating time-to-value.

### 2.2 Real-World Proof of Concept

Salesforce has run this agent on help.salesforce.com itself. The result: **4.3 million inquiries handled, 70% resolved autonomously**. That real-world learning is embedded in the product. This is a strong rebuttal to clients who worry they are early adopters of unproven technology.

### 2.3 Outcomes-Based Pricing

The pricing model finally matches the way buyers think about value. Clients pay only when the agent **autonomously resolves an issue from start to finish**. If the customer asks for a human or walks away unhappy, there is no charge — and the agent passes complete customer context to the service team. Both **Data 360 and Agentforce are unmetered during the agent interaction**, meaning companies do not need to forecast consumption or worry about overages.

> **The business case in plain language:** If the agent resolves cases that would otherwise require a human rep, the cost per resolution becomes the only variable to model. The financial conversation is clean — but see Section 5 for important caveats before a client signs.

### 2.4 Customer Experience Upgrade

The Agentforce Customer Service Portal is reimagined around a **single conversation bar**. As customers describe what they need, the experience adapts in real time, surfacing personalized responses and dynamic cards that let them complete tasks inside the conversation flow. Because the experience uses real-time data, it can also **trigger workflows proactively** — engaging the customer before an issue arises, not just reacting to one.

---

## 3. How It Works: The Technical Walkthrough

### 3.1 Prerequisites

| Requirement | Detail |
|---|---|
| **Salesforce Edition** | Enterprise Edition or Unlimited Edition |
| **Agentforce** | Must be enabled before starting setup |
| **Data 360 (Data Cloud)** | Required; provisioned automatically if not yet enabled |
| **Entry Point** | Salesforce Go (App Launcher) |
| **Not available in** | Standard Trailhead Playground |

### 3.2 The Guided Setup Flow (Fewer Than 10 Steps)

**Step 1: Enable and Accept Terms**
Navigate to Salesforce Go, search for "Help Agent," and select Get Started. If Data Cloud or Agentforce is not yet enabled, the setup displays a warning icon and directs you to complete those prerequisites first. Accepting the terms of service is a legal and compliance requirement because Enhanced Chat powers the backend.

**Step 2: Background Provisioning (Automatic)**
After accepting terms, the flow provisions the full infrastructure stack in the background. When the status indicators show complete, the flow advances — there is no separate notification; the steps simply update to a completed state.

**Step 3: Define Agent Identity**
- Set the agent's name and language
- Write a welcome greeting

Salesforce automatically creates a **dedicated agent user** behind the scenes. The agent operates as this user, inheriting the org's sharing model. It can only see data the dedicated user is authorized to see. Nothing needs to be configured here during setup; the user can be reviewed or adjusted later in Setup under Users like any other user.

**Step 4: Choose and Configure a Grounding Source** *(single source per agent)*

Three options are available. **Only one can be active at a time:**

| Option | What It Does | Best For |
|---|---|---|
| **Salesforce Knowledge** | Connects to existing published articles; data categories shown, all selected by default | Orgs with an established Knowledge base |
| **Upload Files** | Drag-and-drop PDF, DOCX, or HTML; capacity approx. 300 pages | Small-to-medium businesses without a formal Knowledge base |
| **Website Sync** | Indexes one URL at a time; no deep crawl or full-site sync | Orgs with a small, stable help page |

> **Security note (from Trailhead):** Uploaded content is never published to a public website — it strictly grounds the agent. However, because the agent uses it to generate customer-facing answers, only public-facing information should ever be uploaded. Never upload internal compliance documents, sensitive architecture diagrams, or files containing PII.

After initial deployment, you can return to this screen to switch grounding sources. You can also use **Data 360 to extend grounding to additional third-party content** post-setup — but that requires separate configuration beyond the guided flow.

**Step 5: Choose Deployment Channels**
Three channels are available in the guided setup, and they can be combined:

| Channel | How it Works |
|---|---|
| **Web Chat** | Generates a JS snippet authorized to a specific domain. Paste into your CMS header or footer. The snippet only activates on the authorized domain — pasting it elsewhere will not work. |
| **Help Portal** | Provisions a starter Agentforce Customer Service Portal (guest users only). Extend later in Experience Builder. |
| **Voice** | Configures greetings, voice tone, phone number, and escalation path via Agentforce Contact Center or Salesforce telephony partners. |

Additional channels (WhatsApp, other messaging platforms) are supported but require **manual configuration outside the guided setup flow**. Future releases are expected to add more channels directly to the guided flow.

**Step 6: Preview and Test**
The built-in preview pane lets you simulate customer conversations before going live. The agent cites its knowledge sources for each answer. Test out-of-scope questions — a well-grounded agent should politely decline or offer to route to a rep rather than hallucinate. Testing the live portal requires an incognito/private browser window, since the portal is guest-user only and a logged-in Salesforce session will interfere.

**Step 7: Activate**
There is no separate Activate button. Confirming the final screen activates the agent. Deactivation is available anytime from Agentforce Builder or the Manage Agents view in Salesforce Go.

### 3.3 What Is Actually Happening Under the Hood

The simple drag-and-drop UI might prompt a skeptical technical buyer to assume this is "just RAG." According to Salesforce's product leadership, it is not. Content is **pre-processed through an LLM step that generates derived content before runtime**, and both the derived content and the original source are used together at query time via Agent Data Library structured-document handling. The simplicity of the setup UI buries this, but it is a real answer to sophisticated technical objections about retrieval reliability.

### 3.4 Security and Sharing Model

The auto-created agent user means the Help Agent **automatically respects the org's sharing model**. No special security configuration is required at setup time. Post-setup access can be adjusted in Setup under Users like any other user.

---

## 4. What the Help Agent Can and Cannot Do

### 4.1 Out of the Box (Day One, No Additional Config)

- Answer customer questions autonomously using grounded knowledge
- Create and manage cases
- Escalate to a human agent with full conversation context passed along
- Deploy across web chat, help portal, and voice simultaneously
- Cite knowledge sources in its answers
- Decline to answer out-of-scope questions rather than hallucinating
- Trigger proactive workflows in the portal experience

### 4.2 Available with Additional Configuration (Post-Setup)

- Order management actions
- Appointment scheduling
- Account management
- WhatsApp and additional messaging channels
- Custom actions built with Flows, Apex, or a coding agent (e.g., Claude Code)
- Multi-agent orchestration with other Agentforce agents
- Branded, multi-page portal experience (via Experience Builder)
- Additional grounding sources beyond the initial single source (via Data 360)

### 4.3 Current Limitations (Know These Before Recommending)

This is the section that matters most for an honest client conversation.

| Limitation | Detail and Impact |
|---|---|
| **Single grounding source per agent** | Each agent draws from exactly one source at setup time. Multi-source grounding requires post-setup Data 360 configuration. |
| **File upload capacity** | Maximum approximately 300 pages of PDF/DOCX/HTML. Not suitable for organizations with large knowledge repositories that have not migrated to Salesforce Knowledge. |
| **Website Sync depth** | Indexes one page at a time; no deep crawl or full-site sync. A client with a large support wiki should use Salesforce Knowledge or uploaded files. |
| **Help Portal is guest-user only** | The out-of-the-box portal does not support authenticated (logged-in) customer experiences. An authenticated portal requires additional Experience Builder configuration. |
| **Portal is a starter template** | The guided-setup portal is not a production-ready branded experience. It is a foundation that requires Experience Builder for full customization. |
| **Voice requires Agentforce Contact Center or a Salesforce telephony partner** | Clients on third-party contact center platforms (Genesys, Avaya, Cisco, etc.) need to evaluate the telephony integration path before voice is a Day One option. |
| **Additional channels require manual setup** | WhatsApp, SMS, and other messaging channels are not available in the guided setup flow. |
| **Not available in Trailhead Playground** | Dev and test environments must be Enterprise or Unlimited Edition orgs with Agentforce enabled. |
| **Resolution definition must be contractually specified** | Pricing is tied to an autonomous resolution, but the exact definition and who adjudicates it must be established in writing before signing. See Section 5. |

---

## 5. Pricing: What to Know Before the Client Signs

### 5.1 What the Approved Salesforce Sources State

The Salesforce press release is explicit on these points:

- Organizations **only pay when the Help Agent autonomously resolves an issue from start to finish**
- **No charge** if the customer gives negative feedback or asks for human escalation
- **Both Data 360 and Agentforce are unmetered during the agent interaction** — no forecasting of consumption or overages required

> **Important caveat on unmetering (from internal Sales Guide):** Data 360 and Agentforce unmetering during interactions applies to customers on **Flex Credits**. Customers on older, non-Flex-Credit Agentforce SKUs are not covered by this unmetering. Confirm the client's current Agentforce SKU before representing this benefit.

### 5.2 Portal License Upgrade Paths (from Internal Sales Guidance)

The approved Salesforce press release describes the outcome-based pricing model but does not enumerate pricing variants. Per internal sales guidance (Kayla Ferrin / #pnw-tech-cmrcl-core-sales; Rachael Balsillie Sales Guide canvas), there are **existing portal-license upgrade paths** available to customers based on their current portal license type:

- **Customer Community Login** customers can upgrade to **Agentforce Portal Login** ($4/login, unmetered resolutions)
- **Customer Community+ Member** customers can upgrade to **Agentforce Portal Member** ($10/member/month, unmetered resolutions)

These are upgrade paths tied to portal license type, not vertical-specific carve-outs. Any customer on those portal license types may have access to the corresponding model. **Confirm with the AE and current Sales Guide before quoting.**

### 5.3 Contract Questions Every Success Architect Should Insist On

Two questions must be answered in writing before a client signs:

1. **What is the precise definition of an autonomous "resolution" for this client's use case, and who measures it?** The pricing model ties cost to a satisfaction signal — which is the right alignment — but it also makes "resolution" the new contested metric. Get it in writing before the deal closes.

2. **Which pricing model applies to this client — pay-per-resolution, portal login, or portal member?** The answer depends on the client's current portal license type. The financial model differs significantly for high-volume portal deployments.

### 5.4 The Fin Acquisition: What Is Known

Salesforce has signed a definitive agreement to acquire Fin, described by Salesforce as *"a customer agent platform purpose-built for small- and medium-sized businesses (SMBs) that provides autonomous, end-to-end AI service agents trusted by more than 30,000 companies globally."* The transaction is expected to close in Q4 of Salesforce's fiscal year 2027, subject to regulatory clearances. The two companies operate independently until then.

Salesforce's stated rationale is that together, the companies will give customers *"more ways to deploy AI agents across their customer service operations, with faster time-to-value options especially well suited for SMBs."* No roadmap for product integration has been published. **How Help Agent and Fin coexist at the market boundary is an open question; watch for Dreamforce guidance before advising clients on competitive positioning.**

---

## 6. Success Architect Qualification Checklist

Use these questions to determine fit — and to set honest expectations.

### Good Fit Signals

- [ ] Client has **published Salesforce Knowledge articles** ready to activate immediately
- [ ] Client's use case is **external customer service** (not internal employee support)
- [ ] Client needs to **demonstrate AI value quickly** before a longer custom build
- [ ] Client is comfortable with a **guest-user portal** or already has a web site to embed chat
- [ ] Client has **Enterprise or Unlimited Edition** with Agentforce (and Flex Credits) enabled
- [ ] Client's support volume makes **pay-per-resolution pricing financially attractive**
- [ ] Client wants to start simple and **extend over time** using standard Agentforce tools

### Proceed With Caution

- [ ] Client's knowledge base lives **entirely outside Salesforce** and is large (300+ pages)
- [ ] Client needs an **authenticated portal** experience on Day One
- [ ] Client uses a **third-party contact center** and expects voice on Day One
- [ ] Client is in a **regulated industry** with strict PII or data-residency requirements — validate that grounding source content meets compliance standards before upload
- [ ] Client expects **multi-source grounding** at launch without Data 360 configuration
- [ ] Client is currently on a **non-Flex-Credit Agentforce SKU** — the unmetering benefit may not apply

### Blockers (Resolve Before Recommending)

- [ ] Client does not have Enterprise or Unlimited Edition
- [ ] Client expects a fully branded, multi-page portal without additional Experience Builder work
- [ ] Client's entire use case requires deep, multi-turn transactional workflows beyond case management on Day One — Help Agent can reach this, but it requires post-setup configuration
- [ ] Client does not have or will not accept a **dedicated agent user** operating within their sharing model

---

## 7. The Path Forward: From Quick Start to Full Platform

Help Agent is designed as an **on-ramp, not a ceiling**. The progressive disclosure architecture means:

- A business user can get an agent live in minutes
- An admin can configure guardrails and extend topics in Agentforce Builder
- A developer can build custom actions, Flows, and Apex integrations (or drive the same setup via a coding agent like Claude Code)
- A data engineer can extend grounding via Data 360 to third-party content

The strategic vision from Salesforce leadership is coherent: an IT service product, plus Agentforce Contact Center, plus Help Agent, equals **customer service in a box** — with the option to scale to full enterprise service.

For a Success Architect, Help Agent is best positioned as **Phase 1 of a broader Agentforce Service strategy**, not as a standalone destination for complex enterprise service requirements.

---

## 8. Quick Reference Summary

| Dimension | What's True Today |
|---|---|
| **GA Date** | July 2026 |
| **Setup time** | Minutes (fewer than 10 steps) |
| **Editions required** | Enterprise or Unlimited with Agentforce |
| **Grounding sources** | 1 per agent (Knowledge, files ~300pp, or 1 URL) |
| **Channels in guided setup** | Web chat, Help Portal, Voice |
| **Channels requiring manual setup** | WhatsApp, other messaging |
| **Out-of-box actions** | Answer questions, manage cases |
| **Extensible actions** | Order mgmt, appointments, account mgmt, custom (Flows/Apex) |
| **Portal auth** | Guest users only out of the box |
| **Pricing model** | Pay-per-resolution (portal license upgrades available; confirm with AE) |
| **Unmetering applies** | Flex Credits customers only (confirm SKU) |
| **Security** | Dedicated auto-created agent user; respects org sharing model |
| **Underlying retrieval** | LLM-preprocessed via Agent Data Library; not plain vector RAG |
| **Proof of scale** | 4.3M inquiries on help.salesforce.com; 70% autonomous resolution rate |

---
