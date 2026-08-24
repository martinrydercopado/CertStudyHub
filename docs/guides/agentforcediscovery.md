# Agentforce Discovery & Requirements Gathering
### A Field Guide for Success Architects

**Audience:** Success Architects running discovery workshops with new Agentforce customers
**Purpose:** Equip you to run structured, trust-building discovery sessions that translate raw business pain into a well-scoped, buildable agent

---

## Opening: The Consultative Mindset

### The shift in thinking

Before any framework, tool, or question bank, there is a mindset question you have to answer for yourself.

The old question in AI engagements was: *"How can agents perform the same roles as humans?"* That question leads you toward replacement logic — mapping agent behavior to existing human workflows and trying to replicate them one-for-one.

The better question is: *"What can agents inherently do better than humans?"*

Faster. Cheaper. More accurate. Always available. Infinitely patient. Perfectly consistent. When you start from that question, you stop fitting agents into broken processes and start rethinking the process around what agents are actually capable of. That reframe is the foundation of every good Agentforce engagement.

> **Field example (online gaming industry):** A customer came in asking for help fixing their legacy chatbot replacement. The menus and user flows were not working. They wanted a technical architect to repair the implementation. Instead, the SA asked: *"What if we elevate the user experience instead of replicating the chatbot?"* The customer was looking for someone to fix their solution. They got a team that fixed their approach — eliminating the rigid menu structure entirely, validating the new approach in a demo org, and giving the customer the tools to build it themselves. The difference was a single reframing question asked before any code was written.

### The five pillars of the consultative mindset

A consultative mindset is what transforms technical expertise into real customer impact. It has five components, and all five must be present:

| Pillar | What it means in practice |
|---|---|
| **Technical Expertise** | You must know the platform deeply enough to know what is and is not possible. Without this, client trust is built on air. |
| **Solutions with Business Value in Mind** | Every design decision should be traceable to a business outcome. Features without KPIs are decorations. |
| **Co-Creation** | Discovery is not something you do to a client. It is something you do with them. The best specs emerge from dialogue, not questionnaires. |
| **Strategic Questioning** | The questions you ask signal your level of understanding. Surface questions get surface answers. Strategic questions unlock real context. |
| **Active Listening** | The goal is to understand the client's reality, not to confirm your pre-existing hypothesis. Ask. Then stop talking. |

None of these pillars is optional. A technically brilliant SA who dominates the room and rushes to a solution is practicing only one of the five. That is not consulting — it is lecturing.

### The Trust Equation

Technical mastery without trust gets you nowhere. The Trust Equation provides the operating framework:

> **Trust = (Credibility + Reliability + Intimacy) / Self-Orientation**

Every component matters, but the denominator is the one that can silently destroy everything else. High self-orientation — rushing to solutions, dominating the conversation, finishing a stakeholder's sentence — collapses trust regardless of how technically correct you are.

- **Credibility** comes from honest communication and demonstrated platform knowledge.
- **Reliability** comes from consistent follow-through on every commitment, no matter how small.
- **Intimacy** comes from genuine curiosity about the client's situation and a willingness to engage with their real concerns, including the uncomfortable ones.
- **Self-orientation** rises when you are more focused on impressing the room than understanding it.

Go into every discovery session trying to prove you are interested — not that you are smart.

---

## Part 1 — Why Agentforce Discovery Is Different

### From objects and fields to reasoning boundaries

In a traditional Salesforce CRM implementation, discovery is largely a data modeling and process mapping exercise. You map the as-is process, identify the gaps, and translate those gaps into objects, fields, page layouts, flows, and validation rules. The scope is bounded by records and relationships.

Agentforce discovery is categorically different. You are not just asking "what data does the user need?" You are asking:

- **What decisions should the agent be empowered to make?**
- **What actions should it be allowed to take autonomously?**
- **Where must a human remain in the loop?**
- **What does the agent do when it hits the edge of its knowledge or authority?**

An Agentforce agent reasons. It classifies incoming requests against defined subagents (specialized areas of expertise), executes scripted business logic deterministically, and then applies natural language instructions to guide behavior within each subagent. That is a fundamentally different design surface than a record-triggered flow. You are scoping **topics, actions, and reasoning boundaries** — not just objects and fields.

Discovery must therefore produce a different kind of output. Instead of a requirements matrix with field-by-field specifications, you are building:

1. A candidate set of **subagents** — the discrete domains the agent is authorized to handle
2. A candidate set of **actions** — the specific tasks the agent can execute within each domain
3. A set of **instructions** — the behavioral guardrails, tone, and decision criteria within each subagent
4. A clear map of **escalation paths** — where the agent stops and a human takes over

> **Why this matters:** If you run an Agentforce discovery the same way you run a Sales Cloud discovery, you will almost certainly over-scope the first agent, under-specify the guardrails, and hand off requirements that cannot be built reliably. The build team will spend weeks redesigning what should have been scoped in the room.

### The VFD Framework: your primary evaluation lens

Every use case you encounter in discovery must be evaluated against three dimensions. This is the VFD Framework — Viable, Feasible, Desirable — and it is the most important analytical tool you have in an Agentforce engagement.

```
   Viable          Feasible        Desirable
 (Business)      (Technology)     (Human)
Does it grow    Can the tech      Do they actually
the business?   deliver this?     want to use it?
```

All three dimensions must be satisfied for an agent to succeed in production. The field evidence is unambiguous on this point.

> **Field example (homebuilder industry):** A partner built an external-facing Agentforce Sales Agent and launched it. When the client called us to assess why it was not performing, we audited the implementation. The verdict: the solution was feasible to ship, but was neither viable nor desirable for customers to use. Critical issues with the retrieval architecture, Data Cloud utilization, and agent looping behavior had been overlooked. All three dimensions of VFD were not verified before launch.

> **Field example (financial services industry):** A partner built a service agent to automate workflows for relationship managers. When the client asked us to conduct an Architecture Design Review, our verdict was consistent: the solution might be feasible, but would be neither viable nor desirable. Key issues with scalability, auditability, and error handling. No meaningful user interaction or feedback loops had been designed.

Both failures were preventable. VFD is the framework that prevents them — but only if it is applied in discovery, not after deployment.

**Using VFD to qualify the type of engagement:**

Before a line of agent logic is written, discovery must establish what kind of deliverable the client actually needs. These are not interchangeable:

| Deliverable | What It Tests | VFD Coverage |
|---|---|---|
| **POT (Proof of Technology)** | Can this specific technology or configuration function at all? | Feasible only |
| **POC (Proof of Concept)** | Can we build this, and can a business be made from it? | Viable + Feasible |
| **MVP (Minimum Viable Product)** | Will users actually want and use this in the real world? | All three: Viable + Feasible + Desirable |

Misalignment on this question is one of the most common sources of scope disputes. A client expecting an MVP and receiving a POT will feel underdelivered. A team scoping an MVP when the client only needs a POT will over-engineer and over-spend. Establish this explicitly in the kickoff.

### Agents vs. flows vs. prompt templates

One of the most important things to establish in discovery is whether an agent is even the right tool. Share this mental model with stakeholders early:

| Situation | Right Tool |
|---|---|
| Static, predictable process that never changes | Flow in Flow Builder |
| Single-turn task: summarize a case, draft an email | Prompt Template in Prompt Builder |
| Multi-step reasoning, dynamic decisions, autonomous action | Agentforce Agent |

If a process is linear and never varies, an agent adds unnecessary complexity. Reserve Agentforce for handling messy, unpredictable human input where multiple decisions or branches are possible based on evolving context. Telling a client this is an act of trusted advising, not a product limitation.

---

## Part 2 — The Engagement Lifecycle

### The four-phase framework

Agentforce engagements follow a structured four-phase lifecycle. Discovery sits in Phase 1 (Scope), and understanding where Phase 1 ends and Phase 2 begins is critical — because Phase 1 has a defined gate that must be cleared before build begins.

| Phase | Name | Primary Goal | Key Activities |
|---|---|---|---|
| **Phase 1** | Scope | Customer and team aligned and ready to achieve outcomes | Kickoff, discovery, use case refinement, architecture assessment, Phase 1 Review |
| **Phase 2** | Activate | Drive the right product fit via use case design | Lead prompt engineering, setup data ingestion and knowledge retrieval, design agent architecture |
| **Phase 3** | Deploy | Build, test, and deploy agents to production | Setup, configure, develop, test, deploy agent; drive Responsible AI principles |
| **Phase 4** | Consume | Ensure the customer consistently uses and expands the product | Monitor performance, optimize agents, advise on agentic roadmap, identify expansion opportunities |

The standard engagement duration is 12 weeks. The process is iterative — each agent goes through its own cycle within this framework. A Phase Review gates the transition between each phase. **Nothing moves from Phase 1 to Phase 2 without a Phase 1 Review for executive alignment.**

### Phase 1 required outputs

Your discovery work is not complete until all five of these outputs are documented and ready for the Phase 1 Review:

| Output | Description |
|---|---|
| **Agent Use Case Refined** | Business needs analysis complete; use case documented with scope and problem statement |
| **Success Criteria Defined** | Business Value Metrics and KPIs aligned with both Business and IT stakeholders |
| **Technical Assessment** | Existing Salesforce systems and integrations evaluated for agent readiness |
| **Data Assessment** | Current data readiness analyzed for agent use; gaps documented with remediation owners |
| **Agent Design and Guardrails** | Agent scope defined; ethical guardrails assessed and documented |

If any of these five outputs is incomplete or has open questions, the Phase 1 Review should not proceed. Surface the gaps early — not the day before the review.

### The two-step kickoff sequence

Phase 1 opens with a specific two-step kickoff. The sequence matters. Internal alignment happens before the customer sees you in the room.

**Step 1: Internal Account Team Alignment**

Before any customer-facing session, align with the full account team. Review all case details and qualification documentation provided by the account team. The stakeholders to align internally include:

- Core Account Executive (Core AE)
- Agentforce and Data Cloud Specialist Executive (AFDC AE)
- Consumption Lead
- Solution Engineer
- Customer Success Manager
- Customer Success Area Lead
- Partner Success Manager (where applicable)
- Professional Services (where applicable)

This step gives you the political map, the pre-sales context, and the known constraints before you walk into the room. Missing this step means discovering organizational dynamics in front of the customer — which costs credibility.

**Step 2: Customer Kickoff**

Day 1 of the engagement. The agenda has five items:

1. Program overview — what this engagement is and how it works
2. Getting started and expectations — what the client should expect from you, and what you need from them
3. Initial use case and success metrics — a preliminary discussion to confirm alignment from pre-sales
4. Engagement approach — how decisions will be made, how communication will flow, what the cadence looks like
5. Discussion and next steps — schedule the discovery sessions and confirm attendees

The kickoff is not a discovery session. It is an alignment session. Do not try to gather requirements here. Establish trust, set the rhythm, and confirm the people who need to be in the room for the sessions that follow.

---

## Part 3 — Pre-Game: Structured Preparation Before the Session

> "Preparation time is where you should prepare the information you have available to you in a structured format to ensure you make the best of the discovery session."

Discovery time is expensive. Every minute spent restating what is already known is a minute not spent uncovering the unknowns that determine success or failure. Come prepared.

### Individual preparation checklist

- [ ] Review all case details, qualification documents, and pre-sales notes from the account team
- [ ] Research the company: industry, competitors, org structure, recent press
- [ ] Study their terminology — speak their language, not yours
- [ ] Review profiles of key attendees; identify the economic buyer, the operational champion, and any known skeptics
- [ ] Review similar Agentforce implementations in the same industry; note patterns that have and have not worked
- [ ] Prepare a structured set of open-ended questions — as a guide, not a script to read verbatim
- [ ] Identify which AI use cases are most likely to apply given the business context you know so far
- [ ] Confirm Data 360 provisioning status with IT before the session (see Part 4 IT/Security section)
- [ ] Pre-populate the VFD assessment and discovery territory map with what you already know, flagging the gaps

### Structuring what you already know

Before walking in, organize your pre-existing knowledge into a simple intake document divided into four buckets:

| Bucket | What to Document |
|---|---|
| Business Context | Industry, org model, strategic objectives, current Salesforce footprint |
| Known Pain Points | What the client has said they want to fix; verbatim quotes from pre-sales where possible |
| Known Constraints | Data quality concerns, integration dependencies, regulatory context (GDPR, HIPAA, etc.), IT availability |
| Open Questions | Explicitly list what you do not yet know and need discovery to answer |

This "known/unknown" map is the foundation of your session agenda. You are not running a session to gather everything — you are running a session to fill the gaps.

---

## Part 4 — Game Day: Structuring the Discovery Sessions

> "You are the Salesforce specialist. You should lead the conversation — but let the client do 80% of the talking."

### Session structure and sequencing

A typical Agentforce Phase 1 discovery spans multiple structured sessions across one to two days. Sequence them strategically:

1. **Business Owner / Executive Sponsor** — Anchor everything in business outcomes first
2. **Operational Leads / Process Owners** — Map the actual workflows the agent will touch
3. **End Users** — Surface the real friction and the real edge cases
4. **IT / Security** — Close with technical and data readiness; do not let IT concerns derail the business conversation before it starts

### Opening the room: the framing statement

Begin every session with a clear statement of purpose:

> *"We are here to understand your business deeply enough that we can design an AI agent that actually helps your team. We are not here to sell you on features. Everything we spec today will be grounded in your specific processes and constraints. And to be direct with you: not everything is drag and drop. An agent that is reliable, safe, and trustworthy requires thoughtful design. Our job today is to find the right scope — not the biggest scope."*

This sets three expectations immediately: you are here to listen, not to pitch; you are honest about complexity; and you will push back on over-scoping. Clients respond to this. It is one of the fastest ways to build credibility before the session is five minutes old.

### Discovery territory map: the eight lenses

Before getting into persona-specific questions, use the eight discovery lenses to ensure you cover the full territory of context you need. Think of this as a map of the ground you are responsible for covering — not a linear interview guide.

| Lens | Key Questions to Explore |
|---|---|
| **Industry** | Where does this company fit in the ecosystem? What are the major trends? How are others in this industry using Agentforce? |
| **Company** | How does this company differentiate itself? What are its core products and services? How would you describe it simply? |
| **Sponsor Group** | What metrics and measures matter to the sponsor? What are the key challenges and risks? What initiatives are in flight? How are they using the platform today? |
| **Company Clients** | Is this B2B or B2C? How do their customers use their products? Why do customers choose them? What do their customers need, and what do they actively avoid? |
| **Deal Context** | Has any POC or pre-work been done? Is this partner-led or DIY? Is this agent initiative isolated or supporting a broader set of initiatives? |
| **Value and Priorities** | Why did they buy Agentforce? What do they want to achieve? What do they want to avoid? What becomes possible if this succeeds? |
| **Opportunities** | Where can this engagement grow? Does the sponsor have a longer-term vision? Does a roadmap exist, or does one need to be built? |
| **Threats and Risk** | Have they tried this before and failed? Where is the risk in the proposed solution? How will risks be mitigated? |

You will not cover every lens in every session. Different stakeholders own different lenses. The executive sponsor owns Value/Priorities and Opportunities. IT owns Deal Context and Threats/Risk. End users own Company Clients. Distribute consciously.

### Four question types for going deep

Within any territory, use these four question categories to move from surface to substance. This is not a rigid sequence — it is a conversational toolkit.

| Type | Purpose | Example Questions |
|---|---|---|
| **Goal** | Understand what success looks like | What are you trying to do? What business goal are you trying to achieve? Who does the solution stand to impact? What will change when it is implemented? |
| **Issue** | Surface what is broken today | What is not working for you? What is wrong with the status quo? What have you already tried? What else is being done about this? |
| **Scope** | Define the boundaries of the engagement | How do you define success for this engagement? What are your expectations? What should the exit criteria be? |
| **Context** | Gather the situational detail that shapes everything else | What do we need to know? What has been documented about the issue? How do you think we should collaborate to address this? |

> **Field example (technology / CDN industry):** A customer wanted to build a scoring model for their customer base to power both human and agent decision-making. In the discovery call, three Goal and Scope questions drove the entire session: *"What business decisions will these metrics impact? What stakeholders are you going to affect? What exactly are you trying to measure?"* Those three questions produced more usable requirements than an hour of open-ended conversation would have.

### Interview guide by stakeholder type

#### Business Owner / Executive Sponsor

The business owner holds the "why." Without clarity here, everything downstream is guesswork.

**Questions to ask:**
- What are your top two or three business priorities for this year? How does this agent initiative connect to them?
- What does success look like in six months? In twelve?
- What KPIs will you use to judge whether this was worth the investment?
- What is the cost of the problem today — in time, revenue, customer satisfaction, or employee frustration?
- Who in the organization will champion adoption when the agent goes live?
- Are there regulatory, legal, or compliance constraints we need to understand from the start?
- What would make you proud to show this to your leadership team?

**What you are listening for:** Specific, measurable business outcomes. Vague answers ("we want to be more efficient") need to be gently reframed. Keep asking "why does that matter?" until you reach a concrete metric. This is also where you establish VFD alignment — does the sponsor believe all three dimensions (viable, feasible, desirable) are being considered, or are they fixated on one?

#### Operational Leads / Process Owners

This is where you go deep on the as-is process. These are the people who know how work actually gets done, as opposed to how it is documented.

**Questions to ask:**
- Walk me through a typical [case / lead / order / request] from start to finish — every step, including the ones that feel trivial.
- Where does the process break down most often?
- What are the top five questions your team answers repeatedly every day?
- Which of those questions could be answered with data that already exists in Salesforce or connected systems?
- Which decisions absolutely require human judgment? Which ones feel like they should be automated but are not yet?
- When a situation falls outside the normal process, what happens? Who does the agent need to involve?
- What data does your team rely on to make decisions, and where does that data live?

**Drawing the process:** Use a whiteboard, Miro, or paper to map the process in real time as they describe it. Visualizing the flow surfaces gaps the stakeholder did not think to mention, and demonstrates that you are genuinely listening. Do not just take notes — draw the workflow.

#### End Users

End users are the people closest to the actual friction. They will also be the first to reject an agent that does not fit their real workflow.

**Questions to ask:**
- Describe your busiest hour of the day. What are you doing?
- What takes up the most of your time that you wish you could hand off?
- What are you most worried about if an agent handles this interaction instead of you?
- What does a "bad" resolution look like from your perspective? When do customers leave unhappy?
- If you could automate one thing today, what would it be?
- How do you currently know when something needs to go to a supervisor or specialist?

**Why this matters:** End users surface the real edge cases — the messy, non-linear situations that process documentation never captures. These edge cases become your guardrail requirements. Missing them in discovery means discovering them in production.

#### IT / Security

This conversation determines whether the agent can be built the way the business expects. The most critical nuance here is around **Data 360** — a point where client misunderstanding is common and consequential.

**Questions to ask:**
- Which systems will the agent need to read from or write to?
- What authentication and access control requirements apply to those systems?
- Are there data residency or regulatory requirements that constrain where data can travel?
- What is the data quality like in the systems the agent will rely on? Are records clean, de-duplicated, and consistently formatted?
- What is the integration landscape — REST APIs, MuleSoft, legacy systems?
- What is your team's capacity to support ongoing maintenance and monitoring?
- Are there shadow AI tools already in use that need to be accounted for in our governance design?
- **Has Data 360 been enabled in your org?** *(If yes, proceed to the next question.)*
- **Has Data 360 been implemented** — meaning have you configured Data Streams, run Identity Resolution, built unified profiles, and connected your external data sources?

**Why those last two questions are not the same thing:**

| State | What It Means | What It Unlocks for Agentforce |
|---|---|---|
| **Enabled** | The license is provisioned and the switch is on | Data Library Automation, Agent Analytics, and baseline RAG are provisioned by default |
| **Implemented** | Data Streams configured, Identity Resolution run, unified profiles built, external sources connected | Real-Time Data Graphs, zero-copy external data federation, unified-profile grounding, Unstructured Data ingestion |

A client can have Data 360 enabled and still have RAG that performs poorly — because RAG quality depends entirely on what is in the index, and the index is only as good as the data preparation underneath it. "Yes, Data 360 is on" is the start of the conversation, not the end of it.

Surface the implementation gap early. Frame it as a parallel workstream that must be planned alongside agent design.

---

## Part 5 — Red Flags: Active Risk Monitoring During Discovery

Red flags are not anti-patterns to avoid in design — they are signals to recognize in the room and respond to in real time. If you encounter one and do not address it during discovery, it will resurface as a project crisis during build or after launch.

### Red Flag 1: No Desire to Invest

**What it sounds like:** "We just want to see what this can do before we commit anything." Or: "We need to show something to leadership before we get budget." Vague success criteria. Resistance to committing to measurement baselines or change management resources.

**Why it matters:** An agent that is not supported by investment — in data preparation, change management, user training, and ongoing optimization — will underperform and erode confidence in the technology across the organization.

**How to respond:**
- Speak directly to the concept of digital labor: what is the cost per interaction today, and what does a successful agent do to that cost?
- Ground the conversation in current benchmarks. Use the Agentforce ROI Calculator if available.
- Establish a collaborative vision and roadmap early. Clients who see a multi-phase journey are more likely to invest in Phase 1 properly.

### Red Flag 2: Lift and Shift

**What it sounds like:** "We want the agent to do exactly what our team does today." Or: "Can the agent follow the same steps as our current process?" Or: "We just want to replace [role] with an agent."

**Why it matters:** Lift and shift thinking produces agents that replicate broken processes at scale. It also misses the entire value proposition of agentic AI — the ability to handle volume, availability, and consistency that humans cannot match. An agent that mirrors a human workflow will always be judged as an inferior human, not a superior agent.

**How to respond:**
- Return to the mindset reframe: *"What can agents inherently do better than humans — faster, cheaper, more accurately?"*
- Discuss the vision and roadmap. Where does the client want to be in 12 months? In 24?
- Establish credibility by naming the risk explicitly: agents built to replicate human roles tend to fail on desirability because users do not perceive them as adding value.
- Highlight risk mitigations — show what a well-designed agent looks like vs. a lifted-and-shifted one.

> **Field example (online gaming industry):** The customer asked for a technical fix to their legacy chatbot replacement. The team asked one reframing question: *"What if we elevate the experience instead of replicating the chatbot?"* The shift from lift-and-shift to genuine rethink produced a solution the customer could not have specified themselves — and gave them the tools to continue building.

### Red Flag 3: Purely Technology Focused

**What it sounds like:** "We already have [competing tool]. Can Agentforce integrate with it?" Or: "Our IT team wants to evaluate this against [alternative platform]." Or: "We need to build something that proves to leadership that Agentforce is better than what we already have."

**Why it matters:** When technology is the primary focus rather than business outcome, the VFD framework collapses to Feasible only. You end up building a proof of technology that nobody uses (desirability gap) and that cannot demonstrate business ROI (viability gap). Competitive anxiety also pulls discovery conversations off-topic and into territory that is rarely productive.

**How to respond:**
- Lean on the Competitive Analysis resources available internally (e.g., internal competitive intelligence channels).
- Redirect to business outcomes: *"Regardless of what platform is selected, what does a successful outcome look like for your team? What does it look like for your customers?"*
- Use personas and relatable education to help stakeholders understand what agent decision-making actually involves, and why platform-native integration matters for trust and governance.

---

## Part 6 — Translating Pain Points into Subagents, Actions, and Instructions

This is the analytical heart of the discovery process. Everything your stakeholders said needs to be mapped to the three levers that define an Agentforce agent's behavior.

### Step 1: Use case assessment (before the translation table)

Before mapping anything to subagents and actions, document each candidate use case through four structured dimensions. This prevents premature translation of poorly understood pain into agent design.

| Dimension | What to Document | Example |
|---|---|---|
| **Scope and Problem Statement** | High-level description of the use case, including process, pros, and cons | "The manual search process requires employees to log into multiple systems to retrieve customer data." |
| **Current Business Process** | Step-by-step detail of how the work is done today | "Employees log into three systems, retrieve PDF documents, and manually extract the relevant customer org structure." |
| **Dependencies** | Business and technical dependencies in the current process and in the future agentic process | "Automation of data retrieval depends on API-level access to the source systems." |
| **Risks and Inefficiencies** | What is wrong with the current process that would drive the move toward automation | "Employees manually download reports, categorize them, and upload them one by one into the target system — a process that takes 45 minutes per case." |

Only after all four dimensions are documented for a use case should you move to the translation table below.

### Step 2: The translation framework

For each documented use case, ask three questions:

**1. What domain does this belong to?** This becomes a candidate **subagent**. A well-named subagent helps the Reasoning Engine correctly classify incoming requests.

> Good subagent name: "Order Status Inquiry"
> Bad subagent name: "Help with stuff"

**2. What task does the agent need to perform?** This becomes a candidate **action**. Always check whether a standard Agentforce action can do the job before building a custom one. Design custom actions with reusability in mind.

**3. How should the agent behave within this domain?** This becomes the **instructions** — behavioral guidance, not business logic.

> Critical distinction: Instructions are non-deterministic (the LLM interprets them). Hard business rules — mandatory steps, compliance requirements, conditional logic that must always execute — belong in **Agentforce Script** or an action, not in instructions.

### Step 3: Pain-to-spec translation table

| Pain Point Surfaced in Discovery | Candidate Subagent | Candidate Actions | Key Instructions | Guardrail / Escalation |
|---|---|---|---|---|
| Agents spend 40% of time answering the same 10 policy questions | Policy FAQ | Query Knowledge Base, Summarize Article | Use a friendly, concise tone. Always cite the source article. | If question is not in KB, escalate to human; never guess |
| Customers call to check order status across three systems | Order Status Inquiry | Look Up Order (CRM), Check Fulfillment System (API), Update ETA | Offer lookup by order number or email. Confirm identity before sharing details. | If order shows a critical exception flag, transfer to specialist |
| Leads from web form are not followed up within SLA | Lead Qualification | Create Lead Record, Send Intro Email, Schedule Follow-Up Task | Qualify using BANT criteria. Always confirm email address. | If lead indicates enterprise intent, route to field sales immediately |

### Direct handoff to the Agent Spec

The output of this translation exercise maps directly to the Phase 1 fields of a formal Agent Spec document:

- **Goal:** The business outcome this agent drives (sourced from the executive sponsor interview)
- **Agent Type:** The Agentforce agent template or deployment channel (Service, Sales, Internal, etc.)
- **Persona:** The name, tone, and behavioral identity of the agent
- **Subagents:** The discrete domains of expertise, each with a name and description
- **Actions per subagent:** The specific tasks available within each domain
- **Instructions per subagent:** The behavioral guidance for conversation handling

Do not leave discovery without enough information to populate every one of these fields.

---

## Part 7 — Scoping Guardrails and Escalation Paths from Day One

Guardrails are not a deployment concern. They are a discovery deliverable.

### Why guardrails belong in the first conversation

If you wait until build to design guardrail behavior, one of two things happens: the team makes assumptions that do not align with legal or compliance requirements, or the guardrails get de-prioritized under timeline pressure. Either outcome is dangerous for a system that interacts with real customers.

AI governance requires defining risk areas proactively — data leaks, regulatory requirements, and reputation harm — and implementing technical, security, and ethical guardrails before the agent touches production.

### The three guardrail types to scope in discovery

**Technical guardrails** — What data is the agent allowed to see? Secure data retrieval means the agent only surfaces information the executing user is authorized to access. Data masking ensures sensitive data (PII, financial records) never flows to external LLMs.

**Security guardrails** — How does the agent respond to prompt injection, jailbreaking, or users trying to force it outside its scope? Agentforce Script provides the highest level of deterministic control here by encoding required sequences that execute before the LLM evaluates non-deterministic context.

**Ethical guardrails** — What happens when the agent's response might be biased, toxic, or harmful? Identify these risks by asking: "If this agent performs poorly, what is the reputational impact?" Then design the escalation path before go-live.

### The Well-Architected Three Pillars as a guardrail quality lens

Use Salesforce's Well-Architected framework to assess the quality of your guardrail design across three pillars:

| Pillar | What It Means for Agent Design |
|---|---|
| **Trusted** | Protect systems and data; definitively meet legal and ethical standards; deliver highly available, performant solutions. Sub-dimensions: Secure, Compliant, Reliable. |
| **Easy** | Deliver business value immediately; automate complex work securely at scale; create intuitive, helpful user experiences. Sub-dimensions: Intentional, Automated, Engaging. |
| **Adaptable** | Evolve smoothly with the business; handle disruption well; return to expected behavior quickly; adjust with stability. Sub-dimensions: Resilient, Composable. |

During discovery, run a lightweight Well-Architected assessment against each candidate use case. Flag any dimension rated High risk before the Phase 1 Review. High-risk items need explicit mitigation plans — not notes to revisit.

### Escalation path questions for every subagent

- At what point should the agent stop and involve a human?
- Who is that human — a specific team, role, or individual?
- How should the agent communicate the handoff to the customer?
- What context should be passed to the human so they do not start from scratch?
- Are there hard-stop scenarios where the agent should refuse to respond entirely?

Document the answers. These become the escalation rules in Agentforce Script.

---

## Part 8 — Prioritization and Success Metrics

### Use VFD to pre-qualify before you prioritize

Before plotting anything on the prioritization matrix, apply VFD to each candidate use case. A use case that fails on any one dimension should not be placed on the matrix as a Phase 1 candidate — it should be documented as a Phase 2+ item with a named condition for when it becomes viable, feasible, or desirable enough to proceed.

> **Field example (public sector healthcare industry):** An organization had purchased Agentforce licenses but never activated them. They presented five use cases they wanted to prioritize — all patient-facing, all adjacent to protected health information, all high-complexity for a team that had never built an agent. VFD analysis was clear: the use cases were desirable and viable, but not feasible as a starting point given governance constraints and zero Agentforce maturity. The team ran a collaborative prioritization session and reordered priorities using the impact-vs-complexity matrix. An internal employee support agent emerged as the right first use case: high impact, no sensitive data exposure, and data already in Salesforce. That is what VFD-gated prioritization looks like in practice.

### The prioritization matrix: what makes a use case high-value and low-complexity

Use the relative prioritization matrix to plot all VFD-qualified use cases. The goal is to identify the ideal first use case — one that is both high value and low complexity to deploy.

**Signals of high value:**
- Observable improvement in the day-to-day experience of users
- Observable business impact: reduction in cost, increased capacity to serve
- Aligned with a strategic priority (revenue retention, growth, efficiency)
- Low risk profile

**Signals of low deployment complexity:**
- Fewest number of underlying systems required
- Accessible and flexible underlying data (knowledge articles, clean customer records)
- RAG-based agent design (no complex custom action chains required)
- Standard authentication (no custom SSO or complex identity requirements)
- Agent with 1-4 subagents / topics

| Quadrant | Characteristics | Action |
|---|---|---|
| **Ideal PoC** (high value, low complexity) | Clear scope, clean data, standard integrations, 1-4 topics | Build first — this is your Phase 1 agent |
| **Innovation Roadmap** (high value, high complexity) | Strong business case but complex data, integrations, or governance | Phase 2+ with named feasibility conditions |
| **Low-Hanging Fruit** (lower value, low complexity) | Easy to build but limited business impact | Consider if delivery capacity allows |
| **Poor ROI — Simplify** (low value, high complexity) | Do not build in current form | De-scope; reframe the problem or simplify the approach |

### SMART success metrics

Work with the business owner to define metrics using the SMART framework — Specific, Measurable, Achievable, Relevant, Time-bound:

| Business Goal | Candidate KPI | Measurement Method | Baseline Needed? |
|---|---|---|---|
| Reduce case volume handled by humans | % of cases fully resolved by agent without escalation | Agent Analytics dashboard | Yes — current deflection rate |
| Improve first-response time | Average time to first substantive agent response | Case timeline reports | Yes — current average |
| Increase lead follow-up speed | % of leads contacted within SLA | Lead activity reports | Yes — current SLA compliance rate |
| Reduce average handle time | AHT before vs. after agent deployment | Service reports | Yes |

The analytic plan should be designed in discovery — not after go-live. Identify who owns measurement, what baseline data needs to be captured before launch, and at what intervals success will be reviewed.

---

## Part 9 — Discovery-to-Build Handoff Checklist

When discovery closes, the build team should be able to start without a single follow-up clarification call. This checklist maps directly to the five required Phase 1 outputs.

### Business and stakeholder alignment
- [ ] Business goal documented and confirmed with executive sponsor
- [ ] SMART success metrics defined and baseline measurement agreed with both Business and IT
- [ ] Stakeholder RACI matrix completed
- [ ] Escalation owner identified for each subagent
- [ ] Governance and legal sign-off on data use confirmed
- [ ] POT / POC / MVP classification agreed and documented

### Agent design
- [ ] Agent persona defined (name, tone, deployment channel)
- [ ] Candidate subagents documented with name and description
- [ ] Candidate actions listed per subagent (standard vs. custom identified)
- [ ] Draft instructions written for each subagent
- [ ] Hard business rules identified and flagged for Agentforce Script (not instructions)
- [ ] Escalation conditions documented per subagent
- [ ] Out-of-scope requests and hard-stop scenarios documented
- [ ] Well-Architected assessment completed; High-risk items have mitigation plans

### Data and technical readiness
- [ ] Data inventory completed (source, type, update cadence, quality assessment)
- [ ] Data 360 **enabled** confirmed (baseline provisioning for Data Library Automation, Agent Analytics, RAG)
- [ ] Data 360 **implementation status** assessed — Data Streams configured, Identity Resolution run, unified profiles built, external sources connected
- [ ] Optional Data 360 features scoped: Real-Time Data Graphs, Unstructured Data, External Data Sources, BYO-LLM, Audit Trail and Feedback Logging
- [ ] Integration dependencies identified (APIs, legacy systems, external services)
- [ ] Data quality gaps documented with remediation owners and dates assigned
- [ ] Sensitive data identified; data masking and access control requirements noted

### Trust and guardrails
- [ ] Risk profile completed (data leaks, regulatory requirements, reputation harm)
- [ ] Three guardrail types scoped (technical, security, ethical)
- [ ] Einstein Trust Layer features mapped to risk areas
- [ ] Regulatory requirements confirmed with legal team (GDPR, HIPAA, industry-specific)
- [ ] Monitoring and audit plan defined (who reviews toxicity scores, feedback logs, and escalation rates)

### Scope boundaries
- [ ] VFD assessment documented for each candidate use case
- [ ] Phase 1 use cases confirmed as Ideal PoC quadrant (high value, low complexity)
- [ ] Items explicitly de-scoped for Phase 2+ documented with named conditions for progression
- [ ] Phase 1 Review scheduled with executive sponsor for scope and project plan finalization

---

## Part 10 — Common Anti-Patterns

Red flags (Part 5) are signals you read in the room and address in real time. Anti-patterns are design and process failure modes that emerge across the engagement lifecycle. Know them both.

### Anti-Pattern 1: Over-scoping the first agent

**What it looks like:** Stakeholders are excited and list fifteen use cases. The team agrees to build them all in Phase 1.

**Why it fails:** A first agent that tries to do everything does nothing reliably. Subagent classification becomes ambiguous. Instructions conflict. Testing takes forever. The agent goes live with too many rough edges, eroding organizational confidence in the technology.

**The fix:** Run the prioritization matrix in the room. Help the business owner choose one to three subagents — ideally in the Ideal PoC quadrant. Document everything else as Phase 2+. Clients respect the discipline; they do not always know how to apply it themselves.

### Anti-Pattern 2: Skipping the guardrail conversation

**What it looks like:** The session covers what the agent will do in great detail. The question of what the agent does when go wrong gets deferred: "We'll figure that out in UAT."

**Why it fails:** Guardrails are design decisions, not testing afterthoughts. Undefined escalation paths lead to build-team assumptions. Late-stage legal flags cost weeks. Unspecified data access controls produce agents that surface data they should never see.

**The fix:** Dedicate explicit agenda time to the question: "What does the agent do when it cannot help?" Walk through three to five edge-case scenarios per subagent and document the expected behavior.

### Anti-Pattern 3: Treating an RFP as sufficient requirements

**What it looks like:** The client sends a thirty-page RFP. The team assumes it covers everything and treats discovery as a formality.

**Why it fails:** An RFP documents what a procurement team thinks they want — written without the discovery conversation that surfaces the gap between stated pain and root cause. It rarely captures real process detail, edge cases, or data constraints.

**The fix:** Treat the RFP as pre-game input, not a requirements document. Use it to build your known/unknown map. Then use discovery to challenge, validate, and fill the gaps.

### Anti-Pattern 4: Confusing instructions with business logic

**What it looks like:** "Always verify identity before sharing account details" is written as an agent instruction and marked complete.

**Why it fails:** Instructions are non-deterministic. The LLM interprets them, and interpretation varies. A mandatory compliance step written as an instruction may be skipped in edge cases.

**The fix:** Apply a simple filter to everything you capture: "Is this a behavior (how the agent should generally act) or a rule (something that must always execute)?" Behaviors go in instructions. Rules go in Agentforce Script or an action.

### Anti-Pattern 5: Conflating "Data 360 enabled" with "Data 360 ready"

**What it looks like:** IT confirms Data 360 is on. The team checks the box and moves forward assuming RAG and grounding are fully available.

**Why it fails:** Enabling Data 360 provisions baseline features by default, but RAG quality depends on the data preparation underneath. If Data Streams have not been configured, Identity Resolution has not been run, and external sources have not been connected, grounding will be shallow and unreliable — regardless of whether the license switch is on.

**The fix:** Ask two distinct questions: "Is Data 360 enabled?" and "Has Data 360 been implemented?" If the answer to the second is no or partial, treat implementation as a parallel workstream with its own owners, timeline, and readiness gate before the agent goes live.

### Anti-Pattern 6: Skipping the end user interview

**What it looks like:** Discovery focuses entirely on executives and process owners. End users are consulted after the spec is written.

**Why it fails:** End users know the real edge cases. They also carry the greatest emotional stake in the agent. If they feel the agent was designed without them, adoption resistance is almost guaranteed.

**The fix:** Include at least one end user session in every discovery engagement. Frame it as user research, not requirements gathering. The answers will materially improve both the spec and the change management plan.

### Anti-Pattern 7: Lift and shift (in build form)

**What it looks like:** The agent spec maps agent behavior one-to-one to existing human workflows. The subagent instructions read like a step-by-step human procedure manual.

**Why it fails:** Agents built to replicate human roles will always be judged as inferior humans, not superior agents. Users perceive no added value. Desirability collapses. Adoption fails.

**The fix:** Return to the mindset reframe during spec review: *"What can this agent inherently do better than a human in this workflow — in terms of speed, availability, consistency, or volume?"* If the answer is "nothing we have designed for," the spec needs revision.

---

## Part 11 — Worksheet and Template Appendix

### Template A: Pre-Discovery Known/Unknown Map

| Category | What We Know | What We Still Need to Discover |
|---|---|---|
| Business Goal | | |
| Current Process (as-is) | | |
| Key Stakeholders | | |
| Data Sources | | |
| System Integrations | | |
| Regulatory / Compliance Context | | |
| Known Constraints | | |
| Executive Success Metrics | | |
| POT / POC / MVP Classification | | |

---

### Template B: VFD Use Case Evaluation Worksheet

Complete one table per candidate use case before prioritization.

**Use Case Name:** _______________

| Dimension | Evaluation Questions | Assessment (Strong / Partial / Gap) | Notes |
|---|---|---|---|
| **Viable** (Business) | Does it grow or protect the business? Is there a clear ROI story? Is it aligned to a strategic priority? Is the risk acceptable? | | |
| **Feasible** (Technology) | Can Agentforce deliver this today? Are the required integrations available? Is the data accessible and of sufficient quality? Is the scope technically manageable? | | |
| **Desirable** (Human) | Do users want this? Have end users been consulted? Is the experience intuitive? Is there a change management plan? | | |
| **Overall VFD Verdict** | All three Strong: proceed to prioritization. Any Gap: document the condition that would need to be true before this use case can proceed. | | |
| **Engagement Type** | POT / POC / MVP | | |

---

### Template C: Eight-Lens Discovery Territory Map

Use this before and during discovery sessions to ensure you cover all required territory. Pre-populate what you already know. Use sessions to fill the gaps.

| Lens | Pre-Session Knowledge | Gaps to Fill in Discovery | Session Owner |
|---|---|---|---|
| **Industry** | Where do they fit in the ecosystem? Trends? How are others using Agentforce? | | |
| **Company** | Differentiators? Core products/services? | | |
| **Sponsor Group** | Key metrics? Challenges? Active initiatives? Platform usage today? | | |
| **Company Clients** | B2B or B2C? Customer needs and avoidances? | | |
| **Deal Context** | POC or pre-work done? Partner-led or DIY? Isolated or part of a broader initiative? | | |
| **Value and Priorities** | Why did they buy? What do they want? What to avoid? What gets unblocked if this succeeds? | | |
| **Opportunities** | Where can the engagement grow? Does a roadmap exist? | | |
| **Threats and Risk** | Prior failures? Solution risk areas? Mitigation approaches? | | |

---

### Template D: Use Case Assessment Worksheet (Four Dimensions)

Complete one per candidate use case before the translation table.

**Use Case Name:** _______________

| Dimension | Documentation |
|---|---|
| **Scope and Problem Statement** | High-level description of the use case, including the process being addressed and its current pros and cons. |
| **Current Business Process** | Step-by-step detail of how this work is done today — every step, including the manual and error-prone ones. |
| **Dependencies** | Business and technical dependencies in the current process and in the future agentic process. Include API requirements, system access needs, and data dependencies. |
| **Risks and Inefficiencies** | Specific risks and inefficiencies in the current process that drive the case for automation. Use concrete volume, time, and error-rate data where available. |

---

### Template E: Pain-to-Spec Translation Worksheet

Use one row per use case surfaced in discovery. Complete Template D first.

| # | Pain Point (verbatim from stakeholder) | Root Cause (Five Whys) | Candidate Subagent | Candidate Actions | Draft Instructions | Escalation Condition | Phase |
|---|---|---|---|---|---|---|---|
| 1 | | | | | | | 1 or 2+ |
| 2 | | | | | | | |
| 3 | | | | | | | |

---

### Template F: Agent Success Metrics Scorecard

| Business Goal | KPI | Baseline (pre-launch) | Target (post-launch) | Measurement Method | Review Cadence |
|---|---|---|---|---|---|
| | | | | | |
| | | | | | |

---

### Template G: Guardrail Planning Worksheet

Complete one table per candidate subagent.

**Subagent Name:** _______________

| Risk Area | Risk Description | Guardrail Type | Specific Control | Well-Architected Pillar | Owner |
|---|---|---|---|---|---|
| Data Leaks | What sensitive data does this subagent access? | Technical | Secure data retrieval, data masking | Trusted / Secure | IT / Security |
| Regulatory | What compliance requirements apply? | Technical | Data residency controls, retention policies | Trusted / Compliant | Legal |
| Reputation Harm | What does a bad response look like? | Ethical | Toxicity detection, escalation rule | Trusted / Reliable | Product / SA |
| Unauthorized Access | Who should NOT be able to trigger this subagent? | Security | Access controls, prompt defense | Trusted / Secure | IT / Security |
| User Experience | Is the experience intuitive and genuinely helpful? | Design | UX review, end-user testing | Easy / Engaging | SA / Design |
| Scalability | Will this hold up under real-world volume? | Technical | Load testing, error handling review | Adaptable / Resilient | IT / Build |
| Edge Cases | What happens when the agent cannot help? | All | Hard-stop rule in Agentforce Script | All pillars | Build Team |

---

### Template H: Data 360 Readiness Assessment

Use this in the IT/Security session to distinguish enabled from implemented.

| Dimension | Question | Status (Yes / Partial / No) | Notes / Owner |
|---|---|---|---|
| **Enabled** | Is Data 360 provisioned in the org? | | |
| **Data Library Automation** | Are search indexes configured to support Knowledge-based agent actions? | | |
| **Agent Analytics** | Is usage data streaming to Data 360 for Reports and Dashboards? | | |
| **Baseline RAG** | Is RAG provisioned and connected to Salesforce data? | | |
| **Data Streams** | Have Data Streams been configured for relevant data sources? | | |
| **Identity Resolution** | Has Identity Resolution been run to build unified profiles? | | |
| **External Data Sources** | Are non-CRM sources connected (zero-copy / data federation)? | | |
| **Unstructured Data** | Is unstructured data ingested and indexed for agent grounding? | | |
| **Real-Time Data Graphs** | Are near-real-time data graphs configured for grounding? | | |
| **Audit Trail and Feedback Logging** | Is generative AI audit logging enabled? | | |
| **BYO-LLM** | Is a custom LLM configured (if required)? | | |
| **Data Quality** | Are records clean, de-duplicated, and consistently formatted in the sources the agent will use? | | |

**Readiness gate:** The agent should not advance to UAT until all rows relevant to the agent's grounding requirements show "Yes" or have a documented remediation plan with an owner and date.

---

### Template I: Stakeholder Interview Question Bank

**Business Owner**
- What are your top business priorities this year?
- How does this agent initiative connect to those priorities?
- What does success look like in six months? What KPI will confirm it?
- What is the cost of inaction — what happens if you do not build this?
- What regulatory or compliance constraints must we respect?
- What type of engagement are we in — POT, POC, or MVP? (Use the definitions to align.)

**Operational Lead / Process Owner**
- Walk me through a typical [process] from start to finish.
- Where does the process break down most often?
- What are the top five questions your team answers repeatedly every day?
- Which decisions absolutely require human judgment?
- When a situation falls outside the normal process, what happens?

**End User**
- Describe your busiest hour of the day.
- What takes up the most time that you wish you could hand off?
- What are you most worried about if an agent handles this instead of you?
- What does a bad outcome look like from the customer's perspective?
- How do you know when something needs to go to a supervisor?

**IT / Security**
- Which systems will the agent need to access?
- What access control requirements apply?
- Are there data residency or regulatory constraints?
- What is the data quality like in the systems the agent will use?
- What is the integration landscape — REST APIs, MuleSoft, legacy systems?
- Has Data 360 been **enabled** in the org?
- Has Data 360 been **implemented** — Data Streams configured, Identity Resolution run, unified profiles built, external sources connected?
- Which optional Data 360 features are in scope: Real-Time Data Graphs, Unstructured Data, External Data Sources, BYO-LLM, Audit Trail and Feedback Logging?

---

### Template J: Phase 1 Discovery-to-Build Handoff Summary (one page)

**Agent Name:** _______________
**Deployment Channel:** _______________
**Agent Persona / Tone:** _______________
**Engagement Type (POT / POC / MVP):** _______________
**Business Goal:** _______________
**Phase 1 Success Metric:** _______________

**VFD Assessment Summary:**
- Viable: [Strong / Partial / Gap — brief note]
- Feasible: [Strong / Partial / Gap — brief note]
- Desirable: [Strong / Partial / Gap — brief note]

**In Scope — Phase 1:**
- Subagent 1: [Name] — [Description] — Actions: [list]
- Subagent 2: [Name] — [Description] — Actions: [list]

**Explicitly Out of Scope — Phase 2+:**
- [Item 1] — Condition for progression: [what must be true before this can be scoped]
- [Item 2] — Condition for progression: [what must be true before this can be scoped]

**Key Guardrails:**
- [Mandatory escalation conditions]
- [Data access restrictions]
- [Hard-stop rules for Agentforce Script]
- [Well-Architected High-risk items and mitigation plans]

**Data 360 Readiness:** [Green / Yellow / Red] — [brief note on what is still needed]
**Integration Dependencies:** [list]
**Legal / Compliance Sign-Off:** [Obtained / Pending / Not Required]
**Phase 1 Review Scheduled:** [Date] with [Stakeholder names and roles]

---

*This guide is intended to grow with your experience. Bring additional sources, client case studies, and your own session notes back into it as you run more Agentforce discovery engagements.*
