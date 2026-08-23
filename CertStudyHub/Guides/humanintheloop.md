# Human-in-the-Loop Patterns for Agentforce Agents
### A Field Guide for Success Architects

*Updated August 23, 2026*
*This guide was generated using AI with grounding in official Salesforce documentation. Review for accuracy before using.*
---

> **How to use this guide.** Each section covers a HITL pattern in three layers: *why it matters to the business*, *how it works technically*, and *what it looks like in practice*. Use the pattern descriptions to diagnose which type of oversight a client's use case actually needs, then use the implementation notes to guide them to the right Agentforce building block.

---

## Preface: What Is "Friction" and Why Does It Belong in Agent Design?

One of the most common mistakes in early agent deployments is treating autonomy as the primary goal. The real goal is *trustworthy* autonomy. Friction, in the form of a human checkpoint, is not a failure of automation. It is a deliberate design choice that protects customers, businesses, and the integrity of the system.

Human-in-the-loop (HITL) is any pattern that inserts a required human checkpoint into an otherwise autonomous agent workflow. That checkpoint can take one of three forms:

- **Approval** — "Can I do X?" The agent pauses before a risky or irreversible action and waits for a yes/no decision.
- **Input** — "Which option should I use?" The agent needs a human to supply a decision or missing data before it can continue.
- **Escalation** — "I've failed, or this is out of scope." The agent transfers the full interaction to a human, with context preserved.

Understanding which of these three patterns a situation calls for is the foundation of sound agent design. Each pattern has a different trigger, a different mechanism, and a different cost.

---

## Part 1: The Business Case for Human-in-the-Loop

### Why This Matters

Every autonomous action an agent takes is a moment where the business has decided it trusts the AI to act on its behalf. That trust is not unlimited, and it should not be. When an agent acts incorrectly on a high-stakes decision, the business pays twice: once for the bad outcome, and once for the erosion of customer or employee trust in the system.

The Salesforce Architecture Center frames the design challenge this way: *agentic workflows operating at high orchestration density should incorporate explicit human approval or escalation gates for actions with irreversible consequences, such as financial transactions, regulatory submissions, or supplier commitments.*

The business value of HITL is not just risk reduction. It is also:

- **Regulatory compliance.** In regulated industries such as financial services, healthcare, and government, auditability means demonstrating that a specific process was followed in a specific way for a specific transaction. A purely non-deterministic agent cannot provide that guarantee. The audit trail must show that a human was in the loop at the right moment.
- **Customer trust.** Customers who feel an AI acted on their account without their knowledge are far less likely to trust the channel again. A well-placed confirmation step signals respect for the customer.
- **Agent adoption.** Employees and customers are more likely to adopt AI tools when they feel control has not been taken away from them. HITL is a trust-building mechanism, not just a safety net.

### The Architect's Decision Lens

Before recommending a HITL pattern to a client, ask three questions:

1. **What is the blast radius?** If the action goes wrong, how many records, customers, or dollars are affected?
2. **Is this reversible?** Can the action be undone in under five minutes without a human expert, or is it permanent?
3. **Is there a regulatory or policy obligation?** Does the business, by contract or law, need a human to have approved this step?

If the answer to any of these three questions is "yes," a HITL checkpoint belongs in the design.

---

## Part 2: The Three Core HITL Patterns

---

### Pattern 1: Escalation

#### Why This Matters

Escalation is the most fundamental HITL pattern in Agentforce. Its business value is straightforward: some situations require human judgment, empathy, or authority that no AI agent should claim to have. Getting escalation right is the difference between a customer who feels supported and one who feels trapped in a bot loop.

Critically, escalation should be designed as a *first-class routing decision*, not as a fallback of last resort. A well-designed agent knows its own boundaries and routes gracefully when it reaches them. A poorly designed agent apologizes repeatedly before reluctantly handing off, leaving the customer frustrated before the human ever joins.

The Salesforce Architecture Center explicitly identifies the pattern: *Enable seamless escalation to human service agents when the AI agent cannot resolve the query. Configure Omni-Channel routing to assign chats to service reps and transfer the full transcript for context.*

#### How It Works in Agentforce

Agentforce provides two native, GA mechanisms for escalation.

**The Escalation Subagent** is a built-in subagent that both Service Agents and Employee Agents can invoke when they cannot resolve a conversation. It connects to an outbound Omni-Channel Flow configured on the agent's Messaging connection in Agentforce Studio. When triggered, it routes the conversation to a human service rep or queue and passes the full conversation transcript, so the customer never has to repeat themselves.

The outbound Omni-Channel Flow checks whether reps are available in the target queue. If they are, it routes the session. If no rep is available, the agent retains the conversation context and attempts escalation once more per session.

**The `@utils.escalate` utility** (Agent Script) lets architects trigger escalation directly from script logic, with full programmatic control over when it fires. According to the Agentforce Developer Guide, `@utils.escalate` requires an active Omni-Channel connection defined in a `connection messaging` block with `outbound_route_type` and `outbound_route_name` values. The utility can be used as a direct alternative to the Escalation Subagent.

```agentscript
connection messaging:
    outbound_route_type: "OmniChannelFlow"
    outbound_route_name: "flow://Support_Queue_Flow"
    escalation_message: "Let me connect you with a specialist now."
    adaptive_response_allowed: True

subagent service_support:
    reasoning:
        instructions:
            | call the action {!@actions.escalate_to_human} if the user wants to speak with a human rep
        actions:
            escalate_to_human: @utils.escalate
                description: "Call this when the customer is frustrated,
                              the issue requires account authority, or the agent cannot resolve."
                available when @variables.in_business_hours
```

> **Channel-dependent behavior:** While `@utils.escalate` is available across agent types, escalation behavior varies by channel and agent type. For example, Employee Agents connected to Enhanced Web Chat transfer conversations via the Omni-Channel Flow in the same way as Service Agents, but do not support case creation as an escalation fallback. Always confirm channel-specific capabilities against the agent type and channel combination your client is deploying.

#### Scenario

A customer contacts a telecom company's service agent about a billing dispute involving a charge they believe is fraudulent. The agent can retrieve billing history and explain charges, but it cannot reverse charges above a defined threshold or make account credits. The escalation fires, passes the full conversation transcript to an available billing specialist in Omni-Channel, and displays a message to the customer: *"I'm connecting you with a billing specialist now. They can see your full conversation history and will be with you shortly."* The specialist joins without asking the customer to repeat anything.

---

### Pattern 2: Approval Gate

#### Why This Matters

An approval gate is the "Can I do X?" pattern. The agent has reasoned its way to an action, but the action is significant enough that it should not proceed without a human saying yes. This is the right pattern for irreversible operations, high-value transactions, and any action with a wide blast radius.

The business value is protection. In the StackAI reference architecture for approval workflows, five production-grade characteristics are called out: evidence packs (the agent presents *why* it wants to act), idempotency keys (so retried approvals don't double-execute), asynchronous durability (approvals survive timeouts), state re-validation before execution (conditions may have changed during the approval window), and a full audit trail.

Clients often push back on approval gates because they feel they undermine the point of having an AI agent. The right response is this: an approval gate is not friction for friction's sake. It is a deliberate decision that *this specific action, at this specific risk level, requires a human's authority*. Reserve hard stops for irreversible, regulated, or high blast-radius actions. Let the agent operate autonomously everywhere else.

#### How It Works in Agentforce

**The `require_user_confirmation` Property**

The Agent Script action reference documents `require_user_confirmation` as a legitimate, optional boolean action property. Its documented purpose is: *"Indicates whether the customer must confirm before the agent runs the action."* It is a real, documented feature of the Agent Script action definition schema.

That said, for high-stakes or irreversible actions, relying on any single property for a safety gate is an architectural risk. A more robust and deterministic approach is the two-step guard variable pattern, which gives you explicit programmatic control over when an action fires, independent of any platform-level confirmation UI behavior.

**The Two-Step Guard Variable Pattern (Recommended for Critical Actions)**

This pattern makes the confirmation state an explicit, queryable variable in your script. The agent summarizes what it is about to do, waits for explicit user confirmation, and only then makes the action available to the LLM.

```agentscript
variables:
    user_confirmed: mutable boolean = False
    action_summary: mutable string = ""

subagent account_changes:
    reasoning:
        instructions: ->
            # Step 1: Summarize the action and ask for confirmation.
            if @variables.user_confirmed == False:
                run @actions.build_action_summary
                    set @variables.action_summary = @outputs.summary
                | I am about to: {!@variables.action_summary}
                | Please confirm with "yes" to proceed, or "cancel" to stop.

            # Step 2: Execute only after confirmation.
            if @variables.user_confirmed == True:
                | Proceeding with the update as confirmed.

        actions:
            confirm_action: @utils.setVariables
                with user_confirmed = ...
                description: "Set to True when the user explicitly confirms they
                              want to proceed."

            execute_change: @actions.update_account_record
                description: "Update the account record with the approved change."
                available when @variables.user_confirmed == True
```

**Flow-Based Approval for Internal Workflows**

For employee-facing agents where a manager or second approver is required, a Salesforce Flow approval process can gate the underlying agent action. The agent invokes the Flow, the Flow submits the record to the standard approval process, and the action completes only when the approver responds. This pattern is fully achievable with standard GA building blocks.

> **Design principle:** Re-validate state before executing an approved action. The world may have changed during the approval window. Build your Flow to check current conditions before writing, not just when the approval was granted.

#### Scenario

An internal HR agent helps employees request equipment upgrades. Requests under $500 are handled autonomously. Requests over $500 require manager approval. When a request crosses the threshold, the agent summarizes the request, submits it to the manager's approval queue via a Flow, and tells the employee: *"I've sent this request to your manager for approval. I'll proceed as soon as they confirm."* The action is idempotent: if the manager approves twice by accident, the equipment is only ordered once.

---

### Pattern 3: Identity Verification Gate

#### Why This Matters

Verification is a specialized form of approval: instead of approving a specific action, the human proves who they are before any protected actions become available. This pattern is critical for any use case involving sensitive data, financial operations, or PII.

The business value is twofold. First, it protects customers from unauthorized access to their accounts. Second, it protects the business from liability. An agent that performs account changes without verifying identity creates legal and reputational risk that no automation benefit can offset.

The verification gate is also the pattern most architects under-design. They rely on natural language instructions like "verify the customer before showing their account." That approach is probabilistic: the LLM may or may not enforce it consistently. The correct implementation is deterministic.

#### How It Works in Agentforce

The verification gate uses a boolean variable and a deterministic conditional to enforce the gate before the LLM ever reasons about the request. This means the gate cannot be bypassed by clever phrasing or conversational drift.

```agentscript
variables:
    is_verified: mutable boolean = False

start_agent agent_router:
    description: "Route all requests through identity verification first."
    reasoning:
        instructions: ->
            # Deterministic gate: fires before LLM reasoning.
            if @variables.is_verified == False:
                transition to @subagent.identity_verification

            | Select the best tool based on the user's current intent.
        actions:
            to_account: @utils.transition to @subagent.account_mgmt
                description: "Account management requests."
                available when @variables.is_verified == True
            to_billing: @utils.transition to @subagent.billing_support
                description: "Billing inquiries and adjustments."
                available when @variables.is_verified == True

subagent identity_verification:
    description: "Verify customer identity before granting account access."
    reasoning:
        instructions: ->
            if @variables.is_verified == True:
                | Identity confirmed. How can I help you today?
            else:
                | To protect your account, I need to verify your identity first.
                | Please provide your email address.
        actions:
            verify_identity: @actions.send_and_verify_code
                description: "Send a verification code and confirm the customer's identity."
                set @variables.is_verified = @outputs.verified
```

The `available when @variables.is_verified == True` guard on downstream actions is a second layer of defense. Even if routing logic were bypassed, the actions themselves would not appear to the LLM until the variable is set.

> **Key design note:** Keep the verification state (`is_verified`) separate from any conversational focus state. The authorization output is trusted machine state that must persist across the session. It is not a conversational hint to be overwritten by subsequent user input.

#### Scenario

A financial services agent handles account inquiries and balance transfers. A customer asks to move $5,000 between accounts. Before routing to the transfers subagent, the router checks `is_verified`. Because this is the customer's first request in the session, `is_verified` is `False`. The agent transitions deterministically to the identity verification subagent, which sends a one-time code to the customer's registered phone number. Once the customer confirms the code, `is_verified` is set to `True`, and the transfer subagent becomes available for the remainder of the session.

---

### Pattern 4: Confidence-Based Routing

#### Why This Matters

Not every situation falls cleanly into "the agent handles it" or "a human handles it." Confidence-based routing is the pattern that handles the middle ground: the agent acts autonomously when it is confident, and escalates when it is not. This is the pattern that makes an agent feel intelligent rather than brittle.

The business value is efficiency and accuracy working together. High-confidence cases resolve instantly without human involvement. Low-confidence cases get human attention before a mistake is made, not after. This reduces both unnecessary escalations (which cost human rep time) and over-confident autonomous errors (which cost customer trust).

The Salesforce Architecture Center captures this pattern as: *high confidence leads to autonomous action, medium or low confidence leads to escalation to the right person by exception type.*

#### How It Works in Agentforce

Confidence-based routing is implemented through action output analysis combined with conditional Agent Script logic. An action, typically a Flow or Apex class, returns a confidence score or classification result. The script evaluates it and branches accordingly.

```agentscript
variables:
    confidence_score: mutable number = 0
    classification: mutable string = ""

subagent issue_classifier:
    description: "Classify the customer's issue and route based on confidence."
    reasoning:
        instructions: ->
            run @actions.classify_issue
                set @variables.confidence_score = @outputs.score
                set @variables.classification = @outputs.category

            # High confidence: resolve autonomously.
            if @variables.confidence_score >= 85:
                | Address the {!@variables.classification} request using
                  available actions.

            # Low confidence: escalate with context.
            if @variables.confidence_score < 85:
                | I want to make sure you get the right help here.
                  Let me connect you with a specialist.
        actions:
            escalate_low_confidence: @utils.escalate
                description: "Escalate when confidence in classification is below threshold."
                available when @variables.confidence_score < 85
```

> **Use `filter_from_agent: True` on confidence outputs.** The customer should never see a raw confidence score. Mark the output field with `filter_from_agent: True` so the raw score is excluded from the agent's context window while still being available for your conditional logic.

#### Scenario

An insurance claims agent receives a first notice of loss. Simple claims (a cracked phone screen with a clear photo and matching policy) score above 85% confidence and the agent processes them autonomously, generating a payout within minutes. A claim for water damage to a commercial building scores 42% because the damage description is ambiguous and the policy has a contested exclusion clause. The agent escalates immediately to a senior claims adjuster, passing the classification, the confidence score, and the full conversation context. The adjuster does not start from scratch.

---

### Pattern 5: Proactive Human-in-the-Loop (Collaborative Agent)

#### Why This Matters

The previous four patterns are reactive: they respond to what a user asked for, or to what the agent is about to do. Proactive HITL is different. Here, the agent proposes a complete plan or recommendation and surfaces it to a human *before* anything is executed. The human reviews, adjusts, and approves the plan. Then the agent acts.

This is the "humans in control" model that Salesforce's Agentforce platform is built around. The Architecture Center describes it as: *The orchestrator informs the customer and offers to escalate to a human service rep with clear guidance on next steps. It then proposes a complete solution to the service rep for approval. The service rep joins the conversation, reviews the data and recommended solution, and makes the final call.*

The business value is highest in complex, multi-step, or high-stakes workflows. The agent can reason across large amounts of data and propose an optimal path far faster than a human can. But the human brings judgment, authority, and accountability. The combination is more powerful than either alone.

#### How It Works in Agentforce

Proactive HITL is implemented as a multi-agent collaborative pattern. The orchestrating agent gathers context, reasons across it, and produces an artifact (a recommended action, a plan, a draft response) that is presented to a human reviewer. Only after the human approves does the agent execute.

In Agentforce, this pattern uses:

- A specialized **subagent or orchestrator** that produces the recommendation artifact.
- A **Flow approval process** or a **Slack notification step** that routes the artifact to the appropriate human reviewer.
- A **post-approval action** that executes only after the approval record is updated.

The monitoring layer is equally important. The Architecture Center calls out three tiers: goal progress monitoring (tracking whether the agent is achieving its objective), operations monitoring (real-time status for intervention), and governance monitoring (trace and audit logs for compliance).

> **Multi-agent note:** As of Summer '26 (GA June 15, 2026), multi-agent orchestration is generally available. In a supervised orchestration pattern, only the orchestrating agent can escalate to a human; subagents cannot initiate escalation independently. Plan your HITL placement accordingly.

#### Scenario

A complex service escalation arrives: a business customer's internet service has been intermittent for six days, affecting their e-commerce operations. The orchestrating agent gathers the network diagnostics, the customer's service history, the SLA breach calculation, and the available remediation options. It produces a recommended resolution package: a technician dispatch, a 10% discount on the next invoice, and a proactive service credit. It surfaces this package to the senior service rep assigned via Omni-Channel, along with all supporting data. The rep reviews, adjusts the discount to 15% based on the customer's lifetime value, and approves. The agent then executes all three remediation steps and sends the customer a confirmation.

---

## Part 3: The Anti-Pattern You Must Know

### Confirmation Fatigue

This is the most commonly overlooked design failure in HITL implementations. Confirmation fatigue occurs when approval or confirmation prompts fire so often that the human stops reading them and clicks through automatically. At that point, the approval gate provides no protection at all. Worse, it creates a false sense of security.

The SAP and DigitalApplied research on HITL design is explicit: over-prompting trains users to rubber-stamp everything, which is itself a security gap. A prompt-injected malicious action can sail through an unread approval click just as easily as a legitimate one.

**How to avoid it:**

- Reserve hard stops for irreversible, regulated, or high blast-radius actions only.
- Distinguish between a *confirmation* (the user says "yes, proceed") and a *notification* (the agent tells the user what it did). Use confirmations sparingly. Notifications are low-friction and appropriate for many routine actions.
- If a client's design has approval prompts on more than 20-30% of agent interactions, that is a signal to revisit the design.
- Combine confidence-based routing with thresholds: auto-approve high-confidence, low-risk actions, and reserve confirmation for the cases that genuinely need it.

---

## Part 4: Design Principles for Production-Grade HITL

These principles apply regardless of which pattern you are implementing.

### Preserve Context on Every Handoff

When an agent transfers a conversation to a human, the human must have full context. Salesforce's native escalation pattern, the Escalation Subagent connected to an Omni-Channel Flow, passes the full conversation transcript to the receiving rep automatically. Never design an escalation path that requires the customer to repeat themselves. It is the single fastest way to destroy trust in an AI-assisted channel.

### Design Escalation as a First-Class Routing Decision

Escalation should be a named, intentional subagent or utility call, not a residual behavior that happens when everything else fails. Name it clearly. Define its trigger conditions explicitly. Give it its own instructions, including what to say to the customer during the transfer.

### Use Async, Durable Approval Over Synchronous Blocking

Approval requests should survive timeouts. If a manager must approve a request and they are unavailable for 30 minutes, the conversation and the pending action should persist. Re-validate the state of the world before the approved action executes: the conditions that made the action appropriate may have changed while the approval was pending. This is especially critical in financial and inventory-related workflows.

### Build Fallbacks for System Failures, Not Just Out-of-Scope Requests

The Salesforce Architecture Center's agentic patterns note this explicitly: build fallbacks for API failures and data mismatches, not just for requests the agent cannot handle. An agent that fails silently because an upstream system timed out, and then escalates to a human with no context, creates more work than it saves. Error messages returned from actions must be structured and actionable, not raw exceptions. The agent needs to know whether to retry, ask the user for corrected input, or halt and escalate.

### Log Everything That Matters

In regulated industries, "the agent decided" is not a defensible answer in a compliance review. Use the AI Agent Generative AI Usage data model (available in Data 360) to capture interaction events, billing decisions, token metrics, and audit identifiers. The Salesforce AI Query Library provides validated SQL queries for monitoring agent sessions, LLM prompts and responses, errors, and safety scoring across the platform. Build your HITL audit trail from day one.

---

## Part 5: Choosing the Right Pattern

Use these questions to guide pattern selection in a client engagement.

**Start here:** Is the action irreversible or does it have a blast radius larger than a single record?

- **Yes** and a human must authorize it before it happens: use an **Approval Gate**.
- **Yes** and it involves sensitive data or PII before any action: use an **Identity Verification Gate**.
- **No** but the agent is uncertain: use **Confidence-Based Routing**.

**Is the customer stuck, frustrated, or the request is outside the agent's scope?**

- Use an **Escalation** pattern. Make it available proactively, not as a last resort.

**Is the workflow multi-step and complex, requiring human judgment on a plan rather than a single action?**

- Use a **Proactive/Collaborative** HITL pattern with an orchestrating agent and a human reviewer in the loop.

**Is the same approval prompt firing on most conversations?**

- Reconsider whether it belongs in the design at all. You may be solving a design gap with friction that should instead be solved with better action scoping or guardrails.

---

## Part 6: Feature Availability Reference

| Pattern | Agentforce Mechanism | Status |
|---|---|---|
| Escalation to human rep | Escalation Subagent + Omni-Channel Flow | GA (Service and Employee Agents) |
| Script-driven escalation | `@utils.escalate` in Agent Script | GA (requires Omni-Channel connection) |
| Identity verification gate | Deterministic conditional + boolean guard variable | GA |
| Action confirmation | `require_user_confirmation` property on action definition | GA (documented property) |
| Two-step guard variable confirmation | Guard variable + `available when` | GA (recommended for critical actions) |
| Flow-based approval process | Salesforce Flow Approval Process gating an agent action | GA |
| Confidence-based routing | Action output + conditional Agent Script | GA |
| Proactive plan approval | Multi-agent orchestration + Flow approval | GA (multi-agent GA since June 15, 2026) |

---

## Glossary

**Agentforce Studio** — The Salesforce setup app where agents, their topics, actions, and channel connections are configured.

**Agent Script** — The domain-specific language in the new Agentforce Builder that lets architects write explicit control-flow logic, combining deterministic instructions (`->`) with LLM prompt instructions (`|`).

**Atlas Reasoning Engine** — The runtime that executes Agent Script and orchestrates agent reasoning loops.

**Approval gate** — A HITL pattern where the agent pauses before executing a risky or irreversible action and waits for explicit human authorization.

**Blast radius** — The scope of impact if an agent action goes wrong, measured in records, customers, or dollars affected.

**Confidence-based routing** — A design pattern where a classification action returns a confidence score, and the agent branches to autonomous action or human escalation based on that score.

**Confirmation fatigue** — A UX and security failure mode where humans are asked to approve agent actions so frequently that they stop reading the prompts and rubber-stamp everything, undermining the safeguard.

**Escalation subagent** — A built-in Agentforce subagent that Service Agents and Employee Agents invoke to hand a conversation to a human via an Omni-Channel Flow. Carries the full conversation transcript.

**Human-in-the-loop (HITL)** — Any design pattern that inserts a required human checkpoint (approval, input, or escalation) into an otherwise autonomous agent workflow.

**Idempotency** — The property of an action that ensures it produces the same outcome regardless of how many times it is called with the same inputs. Critical for approval and retry patterns.

**Omni-Channel** — Salesforce's routing engine that assigns incoming work to the right human agent or queue based on skills, capacity, and routing rules.

**`require_user_confirmation`** — A documented optional boolean property on Agent Script action definitions. Indicates whether the customer must confirm before the agent runs the action.

**`@utils.escalate`** — The Agent Script utility function that triggers escalation to a human via an active Omni-Channel connection. Available to agents configured with a `connection messaging` block.

**Verification gate** — A specialized HITL pattern where a user must prove their identity before any protected actions or subagents become available in the current session.

---
