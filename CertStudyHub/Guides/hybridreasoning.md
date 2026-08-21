# The Hybrid Reasoning Chronicles
### A Phoenix Project-style story about building Agentforce agents with Agent Script

---

## Prologue: The Alert at 2 a.m.

The Slack ping landed at 2:07 in the morning, Pacific time.

Sarah Chen, Lead Agent Design Architect at Corning Industrial Solutions, woke up to a red notification she had learned to dread. It wasn't a server outage. It wasn't a data breach. It was their AI agent again, and it had done something spectacular and stupid at the same time.

A verified enterprise customer had asked the bot a simple question about a replacement order. The agent had confidently summarized order details from a completely different account, apparently mixing up context it shouldn't have been holding at all. By the time Sarah's team caught it, the customer had already sent a concerned email to their account executive.

She sat up in the dark and opened her laptop. She had been warning leadership for three months. She had the slide deck, the metrics, the customer satisfaction trend lines — all of them pointing the same direction. The single, monolithic agent they had deployed six months ago was collapsing under its own weight.

Tomorrow was going to be a very different kind of meeting.

---

## Act I: The Monolithic Maze

The conference room on the fourteenth floor had a panoramic view of the Bay. Sarah barely noticed it. She was already at the whiteboard before Marcus Webb, her lead developer, had finished pouring his coffee.

"I want to walk through what actually happened last night," she said, uncapping a red marker.

Marcus settled into a chair and opened his laptop. He had seen this meeting coming. "It's the same problem it's been for three months," he said. "The agent is trying to be everything to everyone."

He was right. Their current agent handled general product questions, order lookups, supply chain queries, and loyalty program inquiries, all in a single, undifferentiated block of natural language instructions. The instructions had grown so long that the LLM had started doing something Sharda from the Salesforce AI product team had a name for: intent collision. When a prompt contains too many overlapping responsibilities, the model begins to blur the lines between them. Sometimes it answered an order question with product knowledge. Sometimes it skipped verification steps entirely because a prior conversation had left a verification flag in a corrupted state. Sometimes it simply made things up with full confidence.

"What about the maze?" Sarah asked, drawing a grid of small boxes on the whiteboard. "You proposed that last quarter. Twelve separate specialized agents."

Marcus grimaced. He had proposed it, and then spent a week realizing why it was wrong. "Users would have to figure out which agent to talk to. There's no shared context. If someone needs to check an order and then escalate to a case, they'd have to start a completely new conversation in a completely different agent. And God help us if the conversation crosses domains."

Sarah nodded. She had marked up his proposal the same way. "No centralized governance. No session continuity. No way to maintain state across the journey."

She drew an X through the grid and uncapped a blue marker.

"There's a third architecture," she said. "And we're going to build it."

She drew a single door on the left side of the whiteboard. From that door, a line branched to four boxes on the right: **Agent Router**, **User Verification**, **Order Status**, **Case Management**.

"One front door," she said. "An agent that takes every message and routes it intelligently. Behind the scenes, a team of specialized sub-agents handles the actual work. Each one has a single job. Each one owns its own data. And the entire thing runs on deterministic guardrails so the LLM can never make the decisions that actually matter."

Marcus leaned forward, studying the diagram. "What's the glue that holds the state together?"

"Variables," Sarah said. "And Agent Script."

---

## Act II: How the Engine Actually Thinks

Before they wrote a single line of code, Sarah insisted they spend an afternoon studying the reasoning engine. She had attended all three parts of Sharda's "Agent Script Deep Dive" series and had been taking careful notes.

She pulled up her notes on the projector and walked Marcus through the architecture.

"Here's the mental model," she said. "Every time a user sends a message, that's a **turn**. One turn. The moment that turn arrives, it goes into the agent. The agent routes it to the Agent Router sub-agent. The Agent Router then decides where the conversation belongs. Once it picks a sub-agent, what happens inside that sub-agent is called a **reasoning loop**."

She drew a circle to illustrate the loop.

"The reasoning loop is not the same as a turn. A turn is the user talking. A loop is the agent thinking. Inside a single turn, the reasoning loop can spin multiple times. It evaluates conditions, calls actions, updates variables, and then asks itself: is there anything else I need to do? If yes, it loops. If no, it exits and responds to the user."

Marcus stopped her. "So in one user message, the agent could actually traverse multiple sub-agents and run multiple actions before it even responds?"

"Exactly. That's the power of the new builder. In the old builder, the router picked a topic and the agent responded. Done. Now the agent can transition mid-reasoning from sub-agent to sub-agent, collect everything it needs, and then surface a single, coherent response."

She pulled up the execution diagram Sharda had drawn during Part 1 of the webinar and traced through it.

"The anatomy of every sub-agent is the same," she continued. "At the top level, you define the sub-agent's name and description. The description matters enormously. If you're relying on the LLM to choose between sub-agents, it's reading those descriptions. Garbage in, garbage routing. Good descriptions become even more important later on if you want to move toward multi-agent patterns, because orchestration relies on those exact same names and descriptions."

"Below that, you define **sub-agent-level actions**. These are flows, Apex classes, prompt templates — whatever the sub-agent is allowed to call. Then you have the **reasoning** block, which contains its own **reasoning actions** — the actions the LLM itself can choose to invoke."

Marcus raised his hand. "What's the difference between a sub-agent action and a reasoning action?"

"That," Sarah said, pointing at him, "is the single most important question you can ask."

She wrote two columns on the whiteboard.

**Sub-agent actions:** Everything the sub-agent *could* call.
**Reasoning actions:** What the LLM is *allowed* to pick on its own.

"If an action is in the reasoning actions section, the LLM might call it. Might. It usually does if the description is good enough. But there's no guarantee. And there are certain actions you should never leave to the LLM's discretion, because you need them to fire 100% of the time when a condition is met."

She drew a hard box around the second column.

"Those actions get called **deterministically** using the `->` syntax in the reasoning instructions. The LLM never touches them. You write an `if` condition. When the condition is true, the action runs. Always. No probabilistic nonsense."

Marcus was quiet for a moment. "So inside the reasoning block, you have two completely different kinds of instructions living side by side. The LLM prompt stuff and the code stuff."

"Right. And the syntax makes it unambiguous which is which." Sarah wrote on the whiteboard:

```
->  means: this is deterministic, run it exactly as written
|   means: this is a prompt, pass it to the LLM
```

"The `|` pipe character," she said, tapping it, "is the LLM boundary. Everything to the right of a pipe is a natural language instruction to the reasoning engine. Everything driven by `->` or by `if/else` conditions is code. The agent script compiler treats them completely differently."

She added the last piece: "And wrapping all of this are two optional but extremely powerful blocks: **before_reasoning** and **after_reasoning**. Before reasoning runs deterministically the moment the sub-agent is entered, before the LLM even starts thinking. After reasoning runs deterministically after the LLM finishes, before it responds to the user. Those two blocks are where you stamp state, enforce transitions, and prevent the LLM from ever seeing what it doesn't need to see."

"One more thing," she added. "These blocks are optional. Not every sub-agent needs them. You only add them when your use case actually requires it. The before and after reasoning blocks are what add the determinism component of hybrid reasoning. Without them, you can still have a perfectly functional sub-agent. With them, you have precise control over what happens at the edges of every reasoning cycle."

She also added a note Marcus would remember for the rest of his career. In the Canvas view of Agentforce Builder, the before_reasoning and after_reasoning blocks are not visible. You only see them when you flip to Script mode. And to add them, you write the keyword `before_reasoning:` or `after_reasoning:` at the same indentation level as `reasoning:`. The indentation is not optional. Agent Script is whitespace-sensitive.

Marcus turned back to the whiteboard diagram. He studied the four boxes for a long moment.

"Okay," he said finally. "Let's build it."

---

## Act III: The Spec Before the Script

Sarah held up a hand. "Not yet."

She was already pulling up a blank document. It was a template she had downloaded from the build session GitHub site: the Agentforce Agent Spec.

"Before we write a single line of Agent Script," she said, "we write the use case. Not the code. The use case. In plain English. With a table."

Marcus looked skeptical. He was ready to open VS Code.

"Think of an LLM like a very smart five-year-old," Sarah said, echoing something Sharda had said in Part 1 that had stuck with her. "A five-year-old that has been trained on the entire internet has a lot of basic information, but it knows nothing about our Salesforce instance, our processes, or our customers' expectations. When you write instructions, you have to be crystal clear. The best way to get crystal clear is to write down what the agent should do, in order, before you decide how."

She titled the document **Order Details Agent — Use Case Spec** and began filling in the table. The left column held the user intent. Not every possible question, just the intent, because the LLM is very capable of interpreting variations of intent from natural language. The right columns held what the agent does, and what the agent says.

| User says... | Agent does... | Agent responds... |
|---|---|---|
| "What is Gorilla Glass?" | No action called. Reason over built-in knowledge. | Answers from product knowledge. |
| "What's the weather?" | No action called. Classifies as off topic. | Politely redirects. Never reveals system config. |
| "I need to check on an order" | Collect email first. Set: UserEmail. | "To access order details I need to verify your identity. Could you provide your email?" |
| User provides their email | Call verification flow. Call: OrderDetails_Verify_User. With: UserEmail. Set: isVerified, Verification_Run = true. | Verified: "Identity confirmed!" then moves to order lookup. Not verified: "I wasn't able to verify you. Try again or raise a case?" |
| "I can't be verified — create a case" | Call case creation flow. Call: CreateVerificationCase. With: UserEmail. Set: Case creation status and ID. | "Your case has been created. Case number [X]. Our support team will reach out shortly." |
| User provides an order number | Resolve exact ID, then fetch full order. Call: GetExactOrderNumber, then GetOrderDetails. | Displays full order details: status, line items, shipping, billing. |
| "What's the delivery date?" | No action called. Read from: OrderDetails variable. No re-fetch. | Answers directly from stored order data. |
| "I need to expedite this" | Call expedite case flow. Call: CreateExpediteCase. With: ExactOrderNumber, UserEmail, Reason. Set: Case ID. | "Your request has been submitted. Case [X]. Our team will follow up shortly." |
| "Can you look up another order?" | Reset order variables only. Reset: InputOrderNumber, ExactOrderNumber, OrderDetails. | "Sure — please provide the next order number." |
| "That's all I need, thanks" | Reset all variables. | "Let me know if there's anything else I can help with." |

Sarah sat back. "See the pattern? Every row in the 'Agent does' column becomes either an action with explicit inputs and outputs, a variable set, or a no-op where the LLM just reasons. This table is the agent."

She then drew the key insight framework:

- **If 'Agent does' has an action name**, that becomes an Agent action with explicit inputs and outputs.
- **If it says 'Set'**, that becomes a setVariables utility action — something the agent needs to remember.
- **If it says 'No action called'**, the LLM reasons over stored variables or built-in knowledge.
- **If it says 'Reset variables'**, that's cleanup — preventing data from bleeding between turns.

Marcus stared at the table. "So the variables section writes itself from this."

"Almost. You need to think through four categories of memory." Sarah drew four boxes:

**Who is the user?**
- UserEmail — their email address
- isVerified — whether they've been confirmed
- Verification_Run — whether the check has actually run (prevents re-running)
- *Cleared if the user asks to try again, or after a case is created.*

**Which order are we looking at?**
- InputOrderNumber — the order number as typed by the user
- ExactOrderNumber — the confirmed system ID
- OrderDetails — the full order object once fetched
- *Cleared between order lookups so data from one order never pollutes the next.*

**What case was raised?**
- CaseType — whether this is a verification failure or an order action request
- CaseNumber — the case ID once created
- CaseCreationStatus — whether the submission succeeded
- *Cleared automatically after confirmation is shown to the user.*

**Where are we in the conversation?**
- workflow_step — the current step the agent is handling
- *Updated at the start of every sub-agent. Lets the router resume exactly where it left off if the session is interrupted.*

"That last one," Marcus said, pointing at workflow_step. "That's the breadcrumb."

"That's the breadcrumb," Sarah confirmed. "And it's the first thing we'll use in the topic selector."

---

## Act IV: Sub-Agent Anatomy — Four Jobs, Four Sub-Agents

With the spec complete, they mapped out the four sub-agents. The rule Sharda had emphasized in Part 3 guided their thinking: start from **jobs to be done**. Think of each sub-agent as a self-contained finite state machine: one job only, a clear entry condition, ownership of its own data and reasoning, and a clear exit condition.

The agent's three jobs were clear: verify identity, look up orders, manage cases. Plus the routing job that was always there. So four sub-agents:

**1. agent_router (the Topic Selector)**
One job: receive every message and decide where it belongs.
- Reads workflow_step first. If a session was in progress, resume it deterministically without bothering the LLM.
- Presents the LLM with only the sub-agents it's allowed to choose between: User Verification, General Questions, and Off Topic.
- Order Status and Case Management are never offered to the LLM in the router. They're reached deterministically.

**2. user_verification**
One job: confirm the user's identity before letting them near any order data.
- On entry (before_reasoning): stamp workflow_step = "Identify User". If isVerified is already true, skip immediately to Order_Status.
- During reasoning: ask for email, then run OrderDetails_Verify_User deterministically once email is present and Verification_Run is false.
- On success: display confirmation message (LLM), then transition to Order_Status (deterministic).
- On failure: offer retry or case creation (LLM interprets intent, but utility actions execute the transitions).
- On exit (after_reasoning): if isVerified is true, transition to Order_Status.

**3. Order_Status**
One job: look up and display order details for a verified user.
- On entry (before_reasoning): stamp workflow_step = "Order Status".
- During reasoning: ask for order number (LLM), then call GetExactOrderNumber and GetOrderDetails deterministically once the correct variable state is reached.
- LLM answers follow-up questions from the stored OrderDetails variable — no re-fetch.
- If user wants to escalate, set CaseType = "order_request" and transition to Case_Management.
- On new lookup: reset order variables, ask for next order number.

**4. Case_Management**
One job: create a support case, confirm it to the user, and reset all variables.
- Receives CaseType (either "verification_issue" or "order_request") from the variable set by a prior sub-agent.
- Calls the appropriate case creation flow.
- Confirms the case number to the user.
- Resets all case variables after confirmation.

"Notice what we did," Sarah said. "Order_Status and Case_Management never appear in the agent_router's reasoning actions. The LLM in the router cannot decide to go there. A user cannot talk their way into Order_Status without passing through user_verification first. That's not a guideline. It's architecture."

She also addressed something Marcus had asked the day before about how sub-agents relate to each other structurally. All sub-agents in an agent exist at the same level of the graph — there is no deep nesting where one sub-agent sits inside another. What you can do is chain them. Sub-agent A transitions to Sub-agent B, which can then transition to Sub-agent C. But here is the critical thing to understand: `@utils.transition to` is strictly one-way. Control does not return to the calling sub-agent. The docs are explicit on this: when a transition occurs, Agentforce discards any prompt from the current sub-agent and processes the new one from top to bottom. After the second sub-agent completes, control goes back to the `start_agent` on the next turn — not back to wherever the transition originated.

"So if you need what feels like a round-trip," Sarah said, "you have to explicitly define a transition back in the destination sub-agent. And when control returns, the sub-agent starts from the beginning, not from where it left off. That's why we stamp the `workflow_step` variable — so the router knows where to send the next turn."

She also noted that for teams building multi-agent systems — networks of entirely separate agents coordinating with each other — there is a separate `connected_subagent` feature for cross-agent delegation. But that is a different capability from the intra-agent transitions they were using here, and it was still in Beta at the time they were building.

Marcus wrote in his notes: *Transitions are one-way. State is your memory. workflow_step is your breadcrumb back.*

---

## Act V: The Router Model Decision

Marcus had the sub-agent diagram open and was about to start wiring the agent_router when Sarah stopped him again.

"Before we write the router, we need to make one more design decision," she said. "Which model runs the router?"

Marcus looked up. "I assumed we just use whatever the org default is."

"We could. But there's another option worth knowing about." She pulled up the `ascript-model.md` doc on screen. "Salesforce built their own model called EinsteinHyperClassifier specifically for sub-agent classification in the router. It's faster than a general-purpose LLM and more accurate for the specific job of picking which sub-agent to go to."

Marcus leaned in. "So why wouldn't we always use it?"

"Because it comes with hard constraints." She pointed to the documentation. "EinsteinHyperClassifier cannot use `before_reasoning` or `after_reasoning`. And it can only use one tool: `@utils.transition`. That's it. No other actions, no setVariables, nothing else."

The room went quiet. Marcus looked at their router design, then back at the screen.

"Our router's entire session-resumption strategy is built on `before_reasoning`," he said slowly. "We check `workflow_step` there and redirect before the LLM even runs."

"Right," Sarah said. "If we used EinsteinHyperClassifier, we would lose the ability to do that. The router would have to route by intent every single time, with no awareness of session state. A customer who got disconnected mid-order-lookup would start over from scratch on the next turn."

"So it's a genuine trade-off," Marcus said. "Speed and accuracy for routing, versus the ability to maintain session state and resume workflows."

"Exactly. EinsteinHyperClassifier is the right choice when your routing logic is purely intent-based and you want the fastest, most accurate classification possible. It's what Salesforce's own Agentforce Service Agent template uses. But for our use case, where session continuity is a first-class requirement, we need a general LLM in the router."

She added the `model_config` block to the router design:

```
start_agent agent_router:
    description: "Welcome the user and determine the appropriate subagent based on user input"
    model_config:
        model: "model://sfdc_ai__DefaultGPT41"
```

"GPT 4.1 is well-tested with agents and supports the full feature set we need," she said. "The router's before_reasoning block stays. Our session resumption pattern stays. We just trade some routing speed for workflow continuity."

Marcus nodded and made the note. It was the kind of architectural decision that looked obvious in hindsight but could silently break an entire workflow if made without understanding the constraints. He was glad they had caught it before writing a single line of the router script.

---

## Act VI: Plain English First, Then the Boundary

Now came the step Sarah had been waiting for. For each sub-agent, they wrote the logic in plain English, then drew a line between what was deterministic and what was LLM.

She picked up the user_verification sub-agent and wrote it out in the order a person would experience it:

1. If the agent doesn't have the user's email yet and the user hasn't been verified — ask for it.
2. Once an email is provided and verification hasn't been run — run the identity check.
3. If verification succeeds — tell the user and move them straight to Order_Status.
4. If verification fails — ask if they would like to try again or create a case.
5. If they say try again — reset UserEmail, isVerified, and Verification_Run, then ask for the email again.
6. If they say create a case — set CaseType = "verification_issue" and transition to Case_Management.

Then they drew the boundary.

**Step 1:** Checking if UserEmail is empty and isVerified is false — *deterministic*. This is a pure variable check: `UserEmail == "" and isVerified == False`. There's no ambiguity. It's either empty or it isn't.

**Asking for the email:** *LLM*. The agent needs to phrase the request naturally, acknowledge the user's prior message, adapt to tone. The LLM handles this beautifully.

**Capturing what the user says and storing it in UserEmail:** *LLM-driven via utility action*. The LLM extracts the email from the user's message. It's trained on enough data to recognize that "my email is sarah@corning.com" contains an email address and to extract it cleanly, without any regex or parsing code on the developer's part. But critically, it cannot update the variable unless a `setVariables` utility action is defined. Without that utility action, the email simply vanishes after the reasoning loop. This was a common gotcha Sharda had flagged in Part 1 and repeated in Part 2.

**Step 2: Running the verification check:** *deterministic*. This must fire exactly once, exactly when UserEmail is populated and Verification_Run is false. The LLM is not consulted. An `if` condition triggers `OrderDetails_Verify_User` with UserEmail as input, and sets isVerified and Verification_Run = true as outputs.

"And this," Sarah said, "is why we do not put `OrderDetails_Verify_User` in the reasoning actions. If it's in the reasoning actions, the LLM can call it. It might call it twice. It might call it before the email is collected. By keeping it exclusively in the deterministic section, we guarantee the call happens exactly once, with a valid email, at exactly the right moment."

**Step 3: The success message:** *LLM*. The agent is wording a result, not executing logic.

**Step 3: Transitioning to Order_Status:** *deterministic*. This is never an LLM choice. A `transition to` fires automatically the moment isVerified is true.

**Step 4: The failed verification conversation:** *LLM*. The user's response to "would you like to try again?" is completely open-ended. They might say "yes," "let me try a different email," "try again please," or "sure." You cannot write a deterministic rule that catches every phrasing. This is exactly what the LLM is built for — interpreting conversational intent.

**Steps 5 and 6: Acting on their choice:** *LLM-driven via utility actions*. The LLM interprets the intent. But the actual variable resets and transitions are executed by pre-defined utility actions that the LLM calls. The LLM decides which utility action to call; the system executes it deterministically.

Marcus stared at the whiteboard. "So it's not really deterministic versus LLM. It's: does this decision depend on a variable value, or does it depend on a human's words?"

Sarah pointed at him. "Write that down. That's the framework. If you're checking the value of a variable — deterministic. If you're interpreting what a person meant — LLM. Always."

---

## Act VII: Variables, Actions, and State

With the boundary mapped, Marcus opened Agentforce Studio and began building out the variable definitions. Sarah sat next to him, spec on screen, watching over his shoulder.

"Initialize string variables to empty strings," she reminded him. "Not null. The check `UserEmail == ""` only works if the variable was initialized as an empty string."

He created each one:

- **UserEmail** — string, default `""`
- **isVerified** — boolean, default `False`
- **Verification_Run** — boolean, default `False`
- **InputOrderNumber** — string, default `""`
- **ExactOrderNumber** — string, default `""`
- **OrderDetails** — string, default `""`
- **CaseType** — string, default `""`
- **CaseNumber** — string, default `""`
- **CaseCreationStatus** — string, default `""`
- **workflow_step** — string, default `""`

Then he turned to actions. He went to the user_verification sub-agent and added `OrderDetails_Verify_User` from the asset library. In Canvas view, when you add an action to a sub-agent, the platform's typical behavior is to make it available as a reasoning action as well. Worth checking this in your own environment, because if it ends up in the reasoning actions section and you intended to call it deterministically, you may end up with both a deterministic call and an LLM-driven call firing for the same action.

"Remove it from reasoning actions," Sarah said.

Marcus cleared it from reasoning actions. The action stayed defined at the sub-agent level — the system still knew it existed — but it was no longer available for the LLM to choose. Only the deterministic `if` block would call it.

Next, he created the utility actions for the LLM to use:

- **set_email** — setVariables utility, targets UserEmail
- **set_isVerified** — setVariables utility, targets isVerified (used to reset it to False on retry)
- **set_Verification_Run** — setVariables utility, targets Verification_Run
- **set_CaseType** — setVariables utility, targets CaseType
- **go_to_Order_Status** — transition utility, targets Order_Status sub-agent
- **go_to_Case_Management** — transition utility, targets Case_Management sub-agent

"These utility actions are what allow the LLM to affect state," Sarah explained. "Without them, you could write a hundred lines of natural language instructions telling the LLM to remember the email, and it would do nothing. The reasoning engine will not update a variable unless a utility action is there to accept the update. Think of the utility action as the contract between the LLM's decision and the system's execution."

She added: "And transitions work the same way. You cannot tell the LLM 'go to Case_Management' in your prompt instructions and expect it to work. You need a transition utility action. The LLM calls the action; the action moves the session. That distinction matters."

She also made a point about something Sharda had emphasized during Part 2 regarding deterministic action outputs specifically. Even when you run an action deterministically inside an if block, the reasoning engine does not automatically expose the output to the LLM instructions that follow. If you want to reference the result of a deterministically-called action in the LLM prompt that follows, you must store that output in a variable first. The LLM can then read it from the variable. Without that explicit storage step, the LLM has no way to see what the action returned.

For Order_Status, Marcus did the same analysis. The LLM-callable reasoning actions were:

- **set_InputOrderNumber** — stores the order number as typed by the user
- **go_to_Case_Management** — transitions for escalations
- **reset_order_variables** — clears InputOrderNumber, ExactOrderNumber, OrderDetails for a new lookup

The two heavy-lifting API calls, `OrderDetails_GetExactOrderNumber` and `OrderDetails_GetOrderDetails`, were deliberately excluded from reasoning actions. They would fire deterministically via `if` conditions in the reasoning instructions. The LLM would never decide when to call them.

"That eliminates an entire class of bug," Marcus said. "The LLM can't hallucinate an order lookup before we have a valid order number."

"That's the point," Sarah said.

---

## Act VIII: Writing the Script

Marcus opened Script Mode in Agentforce Studio. It was time to write Agent Script.

He started with user_verification.

The first thing he added was the `before_reasoning` block. This would run the moment the sub-agent was entered, before a single LLM token was processed:

```
before_reasoning:
    -> set @variables.workflow_step = "Identify User"
    if @variables.isVerified == True:
        -> transition to @subagents.Order_Status
```

"This stamps the breadcrumb," he said, "and immediately bounces a verified user back to Order_Status without the LLM seeing the verification screen at all. If someone navigated here by accident after already verifying, they never notice."

Then he built the reasoning instructions. The `->` arrow syntax meant deterministic. The `|` pipe meant LLM prompt.

```
reasoning:
    actions:
        - set_email
        - set_isVerified
        - set_Verification_Run
        - set_CaseType
        - go_to_Case_Management
    instructions:
        if @variables.UserEmail == "" and @variables.isVerified == False:
            | Ask the user for their email address. Say: "To access order details I
              will need to verify your identity. Could you please provide your email
              address?" Extract the email from the user response and use
              {!@actions.set_email} to update the UserEmail variable.

        if @variables.UserEmail != "" and @variables.Verification_Run == False:
            -> @actions.OrderDetails_Verify_User(
                   UserEmail: @variables.UserEmail,
                   Verified_status: @variables.isVerified,
                   Run_flag: @variables.Verification_Run)
            -> set @variables.Verification_Run = True

            if @variables.isVerified == True:
                | Display the following message to the user:
                  "Great news, I have successfully verified your identity!"

            if @variables.isVerified == False:
                | Say: "I'm sorry, I wasn't able to verify your identity with the
                  information provided. Would you like to try again or create a case?"
                  If the user says try again:
                    Use {!@actions.set_email} to reset UserEmail to empty.
                    Use {!@actions.set_isVerified} to reset isVerified to False.
                    Use {!@actions.set_Verification_Run} to reset Verification_Run to False.
                    Then say: "No problem! Let's try again. Could you please provide
                    your email address?"
                  If the user says create a case:
                    Use {!@actions.set_CaseType} to set CaseType to "verification_issue".
                    Use {!@actions.go_to_Case_Management} to transition to Case Management.
```

Then the `after_reasoning` block — a safety net that ensured a verified user always moved forward even if the before_reasoning transition hadn't fired yet for some edge reason:

```
after_reasoning:
    if @variables.isVerified == True:
        -> transition to @subagents.Order_Status
```

"Notice the double-transition pattern," Sarah pointed out. "Before reasoning tries it first. After reasoning catches anything that slips through. This is defensive architecture. The cost is essentially zero. The benefit is correctness."

Marcus moved to Order_Status. The before_reasoning was simple:

```
before_reasoning:
    -> set @variables.workflow_step = "Order Status"
```

One line. A breadcrumb that the topic selector would read on the next turn to know where to send the user if the session was interrupted.

The reasoning instructions contained the deterministic API chain:

```
reasoning:
    actions:
        - set_InputOrderNumber
        - go_to_Case_Management
        - reset_order_variables
    instructions:
        if @variables.InputOrderNumber == "":
            | Ask the user to provide the order number they would like to look up.
              When the user provides it, extract it from their response and use
              {!@actions.set_InputOrderNumber} to store it.

        if @variables.InputOrderNumber != "" and @variables.ExactOrderNumber == "":
            -> @actions.OrderDetails_GetExactOrderNumber(
                   InputOrderNumber: @variables.InputOrderNumber,
                   ExactOrderNumber: @variables.ExactOrderNumber)

        if @variables.ExactOrderNumber == "Order Does Not Exist":
            | Say: "I'm sorry, I wasn't able to find that order number. Please check
              the number and try again."
            -> set @variables.InputOrderNumber = ""
            -> set @variables.ExactOrderNumber = ""

        if @variables.ExactOrderNumber != "" and
           @variables.ExactOrderNumber != "Order Does Not Exist" and
           @variables.OrderDetails == "":
            -> @actions.OrderDetails_GetOrderDetails(
                   ExactOrderNumber: @variables.ExactOrderNumber,
                   OrderDetails: @variables.OrderDetails)

        if @variables.OrderDetails != "":
            | Present the order details from @variables.OrderDetails to the user.
              Answer any follow-up questions about this order using the data in
              @variables.OrderDetails. Do not call any action to re-fetch order data.
              If the user asks to look up another order, use {!@actions.reset_order_variables}
              and then ask them to provide the next order number.
              If the user asks to expedite or cancel this order, use {!@actions.set_CaseType}
              to set CaseType to "order_request", then use {!@actions.go_to_Case_Management}
              to transition to Case Management.
```

"See the chain?" Marcus said, tracing through it. "InputOrderNumber gets populated by the LLM via set_InputOrderNumber. That triggers the second `if`, which resolves ExactOrderNumber. That triggers the fourth, which fetches OrderDetails. Only then does the LLM get to respond. The LLM reads from the variable and answers. It never fetches on its own."

"And that last block," Sarah added, pointing at the `OrderDetails != ""` condition, "is where the LLM lives for the rest of the order conversation. Every follow-up question, every 'what's the delivery date,' every 'how many units were ordered' — the LLM reads from the stored variable. No action. No API call. No latency. No cost."

She tapped the screen. "If `OrderDetails` is already populated and the user asks a follow-up, the first four conditions produce different results. Only the last block evaluates to true. The LLM reads and responds. This is how you avoid redundant API calls."

---

## Act IX: The Topic Selector

With user_verification and Order_Status built, they turned to the most architecturally important sub-agent: the agent_router, which Sharda had called the Topic Selector in the webinar.

"The topic selector runs on every single turn," Sarah reminded Marcus. "It's the first thing that receives every message. It has to do two things: resume interrupted sessions first, and only route new intents second."

They wrote the before_reasoning block first:

```
before_reasoning:
    if @variables.workflow_step == "Order Status":
        -> transition to @subagents.Order_Status
    if @variables.workflow_step == "Identify User":
        -> transition to @subagents.user_verification
    if @variables.workflow_step == "Case Management":
        -> transition to @subagents.Case_Management
```

"Those three checks run before the LLM sees anything," Marcus said. "If the workflow_step is set, the session resumes. The LLM is completely bypassed. A customer who got disconnected mid-order-lookup gets picked up exactly where they left off."

"Priority order matters," Sarah said. "Resume logic first. Always. The LLM routing comes after, for sessions that have no workflow_step set. And remember — this before_reasoning block is the entire reason we chose a general LLM for the router instead of EinsteinHyperClassifier. EinsteinHyperClassifier is faster and more accurate for pure classification, but it cannot use before_reasoning at all. Our session continuity pattern depends on it."

The reasoning instructions for fresh routing gave the LLM clear, explicit guidance:

```
reasoning:
    actions:
        - go_to_user_verification
        - go_to_general_questions
        - go_to_off_topic
    instructions:
        | You are a customer service assistant for Corning Industrial Solutions.
          Your job is to understand what the user needs and route them to the
          correct topic.

          Route to General Questions if the user is asking:
          - General questions about company products or technologies
          - Questions about company business segments or information
          - Any informational question that does not require order lookup

          Route to User Verification if the user is asking:
          - To look up an order
          - For order status, shipping, or tracking information
          - To expedite or cancel an order
          - Anything that requires access to order details

          If the request is unrelated to our business, route to Off Topic.

          Select the best tool to call based on the user's intent and conversation
          history.
```

Notice what was absent from the LLM routing instructions: Order_Status and Case_Management. Those sub-agents didn't exist as far as the LLM was concerned. They were only reachable through deterministic transitions. No user could phrase a message cleverly enough to skip identity verification and land directly in Order_Status. The architecture prevented it.

Sarah pointed to an additional pattern worth understanding. The LLM routing instructions listed only three tools: go_to_user_verification, go_to_general_questions, and go_to_off_topic. Even though the agent had four sub-agents total, the LLM only had three paths to choose between. The official guidance on this is qualitative: limit and filter the sub-agents available to the LLM so it can route effectively, and keep reasoning instructions as short and specific as possible, because long instruction sets confuse the reasoning engine. The fewer choices the LLM has to evaluate at once, the more reliably it classifies intent. In a hybrid routing design like this one, where most transitions are deterministic anyway, the LLM's classification job is small and focused.

---

## Act X: The Execution

It was a Friday afternoon when they finally ran the agent end to end.

Marcus had the Agentforce testing window open on his left monitor and the Agent Script on his right. Sarah stood behind him with a coffee.

He typed the opening message: **"I need to check on an order."**

The debug panel lit up. The tracer showed the execution path in real time — something Sharda had called her favorite feature in the entire builder, because it shows you exactly what is happening at every step, what prompt is being sent to the LLM, what response comes back, what variables look like before and after, and why the reasoning loop ran the number of times it did.

The turn hit the agent_router. The before_reasoning block evaluated: workflow_step was empty, so no resume logic fired. The LLM read the routing instructions and identified order-related intent. It called the `go_to_user_verification` transition tool. The system executed the transition.

user_verification's before_reasoning ran: `workflow_step = "Identify User"`. Then it checked: isVerified was false, so it didn't bounce back to Order_Status. The reasoning block evaluated its first condition: `UserEmail == "" and isVerified == False` was true. The LLM was handed a prompt.

The agent responded: *"To access order details I will need to verify your identity. Could you please provide your email address?"*

Marcus typed: **"john.doe@corning.com"**

The reasoning loop restarted. The first condition — `UserEmail == "" and isVerified == False` — was now false because the LLM had used `set_email` to populate UserEmail. The second condition — `UserEmail != "" and Verification_Run == False` — was now true.

The deterministic block fired. `OrderDetails_Verify_User` ran with `UserEmail = "john.doe@corning.com"`. The flow returned `isVerified = True` and the system set `Verification_Run = True`.

Inside the same reasoning pass, the sub-condition `isVerified == True` evaluated to true. The LLM received the prompt to confirm verification.

The agent responded: *"Great news, I have successfully verified your identity!"*

Then the after_reasoning block ran: `isVerified == True` was true. The transition to Order_Status fired.

Order_Status's before_reasoning stamped `workflow_step = "Order Status"`. The reasoning block found InputOrderNumber empty. The LLM was given a prompt to ask for the order number.

The agent responded: *"Please provide the order number you'd like to look up."*

Marcus typed: **"ORD-2024-8821"**

The reasoning loop restarted. The LLM had used `set_InputOrderNumber` to store the order number. Now `InputOrderNumber != "" and ExactOrderNumber == ""` was true. The deterministic block fired `OrderDetails_GetExactOrderNumber`. It returned the confirmed system ID.

Immediately, without another user turn, the next condition evaluated: `ExactOrderNumber != "" and ExactOrderNumber != "Order Does Not Exist" and OrderDetails == ""` was true. `OrderDetails_GetOrderDetails` fired with the confirmed ID. It returned the full order object: Optical Fiber Cable, 500 units, estimated delivery April 22, billing confirmed.

The reasoning loop found no more conditions to evaluate. It exited. The LLM received the full `OrderDetails` variable and composed a natural, well-formatted summary. The tracer showed two reasoning loops on that turn: one that ran GetExactOrderNumber, and one that ran GetOrderDetails. This was exactly what Sharda had shown in the webinar — the reasoning engine keeps looping and checking until there are no more actions to run.

Marcus typed: **"What's the expected delivery date?"**

The reasoning loop ran. `InputOrderNumber` was set. `ExactOrderNumber` was set. `OrderDetails` was set. The first three conditions in the instructions all failed their inner checks. Only the fourth block — `OrderDetails != ""` — was true. The LLM read from the variable and responded instantly.

No action called. No API hit. No latency. No cost.

Sarah exhaled. "That's it. That's the whole thing."

Marcus leaned back. "The LLM answered a follow-up question with zero API calls, zero actions, and zero uncertainty. It just read from state."

"Because we told it to," she said. "We designed it to. That's hybrid reasoning."

He typed one more message: **"That's all I need, thanks."**

The LLM interpreted the closing intent, called `reset_order_variables` and the session cleanup utility. The workflow_step was cleared. The tracer showed all variables returned to their default states.

No data would bleed into the next customer's session.

---

## Act XI: The Gotcha Hall of Fame

The week after launch, Marcus spent an afternoon documenting every mistake the team had made during development. He called it the Gotcha Hall of Fame. Sarah added her own items. Together, they wrote it on the back of the conference room whiteboard in permanent marker. It stayed there for six months.

**Gotcha #1: The Reasoning-Actions Overlap**
When you add an action to a sub-agent, check whether it ends up in the reasoning actions section as well. If you're calling that action deterministically in an `if` block, you want it removed from reasoning actions — otherwise both a deterministic call and a potential LLM-driven call can fire for the same action. This is worth verifying every time you add a new action, whether in Canvas or Script view.

**Gotcha #2: The Silent Variable**
If the LLM does not have a setVariables utility action, it cannot update a variable. The agent will appear to work, it will say the right things, it will seem to have heard the user, and then on the next turn the variable will still be empty and the whole flow will repeat from the beginning. If a variable is not updating, check for a missing utility action first.

**Gotcha #3: The Silent Transition**
Same rule as variables. If the LLM does not have a transition utility action for a target sub-agent, it cannot go there. You can write "transition to Case Management" in your LLM instructions and it will do exactly nothing. Transitions require utility actions. Always.

**Gotcha #4: The Missing Breadcrumb**
If you forget to set workflow_step at the entry of a sub-agent, session resumption breaks. The topic selector's before_reasoning checks workflow_step to know where to send a returning user. If workflow_step is empty or stale, the user gets re-routed by the LLM instead of resumed to their exact location. Always set workflow_step in the before_reasoning block of every sub-agent that is part of a multi-turn workflow.

**Gotcha #5: The Invisible Blocks**
Before_reasoning and after_reasoning do not appear in Canvas view. You will not see them. You will not be prompted for them. To add them, flip to Script view and write the keyword at the correct indentation level alongside `reasoning:`. This confused every developer on the team at least once.

**Gotcha #6: The Contradicting Instructions**
Global system instructions apply across all sub-agents. Sub-agent instructions apply within that sub-agent. If they contradict each other, the LLM gets confused and produces unpredictable behavior. Review global instructions whenever you add a sub-agent whose instructions might conflict with them.

**Gotcha #7: The Long Sub-Agent**
The official guidance is clear: shorter reasoning instructions result in more accurate and reliable results. If a sub-agent has too many if conditions, too many LLM instructions, and too many actions all in one place, the reasoning engine's accuracy suffers. If you notice a sub-agent getting complex, consider splitting it by job. If you're thinking "this is getting long," it's already too long. Bite-sized sub-agents with minimal instructions produce better outcomes.

**Gotcha #8: The Forgotten Output**
When you run an action deterministically, the reasoning engine does not automatically expose the output to the LLM instructions. If you need to reference the result of a deterministic action later in the same reasoning block, you must have stored it in a variable via the action's output mapping. Otherwise the LLM has no way to read it.

**Gotcha #9: The Infinite Router Loop**
If the topic selector's before_reasoning always matches a workflow_step even after the workflow is complete, the user will be stuck in a permanent redirect loop. Clear workflow_step (set it to `""`) when a workflow completes cleanly so that the next fresh turn starts with LLM routing instead of deterministic resume. The docs flag this explicitly: avoid logic that causes a transition from sub-agent A to sub-agent B and then back to A, repeating indefinitely.

**Gotcha #10: The EinsteinHyperClassifier Swap**
Some teams start from the Agentforce Service Agent template, which uses EinsteinHyperClassifier in the router by default. It is faster and more accurate for pure intent classification. But it cannot use `before_reasoning` or `after_reasoning`, and it can only call `@utils.transition` — no other tools. If your router design depends on before_reasoning for session resumption or variable initialization, you must switch to a general LLM model in the router. Understand the trade-off before you start. Swapping it out after the router is fully built is a painful afternoon.

**Gotcha #11: Build One From Scratch First**
This was the one Marcus had tried to skip and had regretted most. Sharda had said it in Part 2 and again in Part 3: before you use Claude Code, Claude, or any AI coding assistant to help you generate Agent Script, you need to have written at least one complete agent by hand. Not because the tools are bad. The tools are very good. But if the generated code produces unexpected behavior, you need to be able to read it, diagnose it, and fix it. If you haven't internalized how the reasoning loop thinks, how before and after reasoning interact with the main loop, and where the LLM boundary lives, debugging generated code will be impossible. Build one simple agent yourself first. It can be completely hypothetical. Then use the tools.

---

## Act XII: The Lessons on the Whiteboard

The following Monday, Sarah gathered the broader team in the conference room. She wrote nine things on the whiteboard and did not erase them for the rest of the sprint.

**1. A turn is a user message. A reasoning loop is the agent thinking. They are not the same.**
One turn can involve multiple reasoning loops and multiple sub-agent traversals before the user gets a response.

**2. The agent router runs on every single turn, not just the first one.**
Design your router to check session state before doing anything else. Resume logic is the highest priority.

**3. workflow_step is the breadcrumb that lets the agent pick up exactly where it left off.**
Without it, an interrupted session starts over. With it, the session resumes as if nothing happened.

**4. Deterministic versus LLM is not a preference. It is a decision framework.**
Check a variable value? Deterministic. Interpret what a person means? LLM.

**5. If an action must fire 100% of the time when a condition is met, remove it from reasoning actions.**
Anything in reasoning actions the LLM might call, or might not. Deterministic `if` conditions call with certainty.

**6. A variable update requires a utility action. Always.**
You cannot instruct the LLM in natural language to "remember the email." Without a `setVariables` utility action, nothing is stored.

**7. A sub-agent transition requires a transition utility action. Always.**
Same rule. "Go to Case_Management" in a natural language prompt does nothing without a defined utility action. And every transition is one-way — control does not return to the calling sub-agent.

**8. Your router model choice is an architecture decision, not a preference.**
EinsteinHyperClassifier is faster and more accurate for classification, but it cannot use before_reasoning, after_reasoning, or any tool except @utils.transition. If your router needs any of those, use a general LLM.

**9. The pipe `|` means LLM. The arrow `->` means code. The whitespace matters.**
Agent Script is whitespace-sensitive. Indentation is not style. It is syntax. Shorter instructions produce more accurate results — keep reasoning blocks focused.

---

## Act XIII: What Comes Next

Sarah stayed late the night the agent went live. She sat in the empty conference room with the Bay glittering below and a cold coffee at her elbow, reading through the first day's conversation traces.

The breadcrumbs were stamping correctly. The verification flows were firing once and only once. The order lookups were chaining deterministically. The follow-up questions were resolving from the cached variable with sub-second response times. The session resets were clean.

She pulled up the tracer on one conversation where a customer had gotten disconnected mid-order-lookup, then returned ten minutes later. The agent had resumed from "Order Status" exactly as designed. The customer had not noticed the gap at all.

She opened her notes document and typed a heading: **Phase 2 — The Superagent**.

The Order Details Agent was sub-agent zero. One agent, handling one domain. But the architecture she had built for it was designed to scale. The same workflow_step breadcrumb pattern, the same hybrid routing approach, the same deterministic action chain philosophy — all of it could be replicated across other agents that Corning needed to build.

A Returns Agent. A Loyalty Program Agent. A Supply Chain Visibility Agent. Superagent pattern, which Sharda had mentioned in Part 3 as something to think about for multi-agent scenarios, was the next frontier. Instead of one agent handling everything, you could have multiple specialized agents, each with their own sub-agents and workflows, and a top-level orchestrator that delegated to them based on intent. The orchestrator wouldn't need to know how any individual agent worked. It would read each agent's name and description, just as the topic selector read sub-agent names and descriptions, and route accordingly.

The agent-level name and description fields that she had filled in almost as an afterthought at the beginning of this project were, it turned out, the API contract for that future orchestration layer. Good descriptions now meant easy orchestration later. She made a note to go back and polish them.

She thought about Sharda's parting advice from Part 3: plan before you build, map the jobs before the sub-agents, draw the flow before the script. The technical implementation had turned out to be the easy part, once the thinking was done. The hard work had been the spec table, the boundary analysis, the variable category diagram, and the honest accounting of which decisions belonged to code and which belonged to the model.

The hard work had been thinking clearly.

She closed her laptop, picked up the cold coffee, and took a last look at the Bay.

Tomorrow, she would pull up a blank agent spec document, write a new heading, and start again.

---

## Epilogue: Three Months Later

The new Order Details Agent went live in week three.

In the first thirty days, the data told a story Sarah had not been bold enough to predict. Mean time to resolution on order inquiries dropped by 41%. LLM hallucinations on order data dropped to zero, structurally prevented by the deterministic execution chain. The session resumption feature quietly recovered hundreds of interrupted conversations without the customers even noticing they'd been away.

Customer satisfaction on the order support channel hit its highest point in two years.

More importantly, Marcus's team could now triage any issue in minutes. If an action failed, they checked the deterministic section. If the routing was wrong, they checked the workflow_step logic. If the LLM said something unexpected, they reviewed the reasoning instructions and checked whether a contradicting global instruction was to blame. The black box was gone. Every decision had a labeled owner: the script, or the model.

At the next architecture review, Sarah pulled up a new whiteboard.

She drew a single door. From that door, a line branched to four boxes. Then, off to the side, she drew a second agent. And a third. Each one with its own door, its own sub-agents, its own workflow.

"The Order Details Agent is sub-agent zero," she said. "Now we talk about the Superagent. And about how to connect them."

Marcus looked up from his laptop and grinned.

They were just getting started.

---

## Appendix A: Key Concepts Reference

### The Sub-Agent Anatomy
Every sub-agent in Agentforce follows a consistent structure:

```
subagent: SubAgentName
  description: |
    [Clear, specific description — the LLM reads this for routing.
     Good descriptions also matter for future multi-agent orchestration.]
  actions:
    [Sub-agent level actions: Flows, Apex, Prompt Templates]
  before_reasoning:        <- Optional. Runs deterministically on entry.
    [Variable stamps, resume transitions, pre-flight logic]
  reasoning:
    actions:
      [Reasoning actions: utility actions the LLM can choose to call.
       Verify that deterministically-called actions are not also listed here.]
    instructions:
      [Deterministic if/else blocks using -> and LLM prompts using | live here]
  after_reasoning:         <- Optional. Runs deterministically on exit.
    [Safety-net transitions, cleanup logic]
```

### The Two Syntaxes
```
->  deterministic execution: runs exactly as written, every time
|   LLM prompt: passed to the reasoning engine as natural language
```

Both can appear in the same reasoning block. The whitespace indentation determines which block each line belongs to.

### The Decision Framework

| Question | Answer | Goes where |
|---|---|---|
| Am I checking a variable value? | Yes | Deterministic `if` condition |
| Am I interpreting user intent? | Yes | LLM instruction with `|` |
| Must this action fire every time condition X is met? | Yes | Deterministic `->` block |
| Should the LLM pick *when* to call this action? | Yes | Reasoning actions |
| Am I storing a value the LLM captures? | Yes | `setVariables` utility action |
| Am I moving to another sub-agent? | Yes | `transition to` utility action |
| Do I need the output of a deterministic action in an LLM prompt? | Yes | Store it in a variable first |

### The Variable Categories

| Category | Variables | Cleared when |
|---|---|---|
| Identity | UserEmail, isVerified, Verification_Run | On retry, or after case created |
| Order | InputOrderNumber, ExactOrderNumber, OrderDetails | Between lookups |
| Case | CaseType, CaseNumber, CaseCreationStatus | After confirmation |
| Session | workflow_step | On clean close |

### Transition Behavior
Transitions using `@utils.transition to` are strictly one-way. When a transition fires, Agentforce discards the current sub-agent's prompt and processes the destination sub-agent from top to bottom. Control does not return to the calling sub-agent. After the destination sub-agent completes, control returns to `start_agent` on the next turn. If you need the user to return to a prior sub-agent, you must define an explicit transition back in the destination sub-agent. When returning, the sub-agent starts from the beginning, not from where it previously left off.

### The Router Model Trade-Off

| Model | Speed | Accuracy | before_reasoning | after_reasoning | Tools available |
|---|---|---|---|---|---|
| EinsteinHyperClassifier | Faster | Higher for classification | Not supported | Not supported | `@utils.transition` only |
| General LLM (e.g. GPT 4.1) | Standard | Good | Supported | Supported | Full tool set |

Use EinsteinHyperClassifier when routing is purely intent-based and you need maximum speed and classification accuracy. Use a general LLM when your router needs before_reasoning or after_reasoning for session state management, variable initialization, or any tool beyond `@utils.transition`.

### The Agent Router Pattern

```
start_agent agent_router:
    model_config:
        model: "model://sfdc_ai__DefaultGPT41"  <- Use general LLM if before_reasoning needed
    before_reasoning:          <- Resume interrupted sessions (deterministic, bypasses LLM entirely)
        if workflow_step == "X":
            -> transition to subagent X
        if workflow_step == "Y":
            -> transition to subagent Y
    reasoning:
        actions:
            [Only include sub-agents the LLM is allowed to route to.
             Never include sub-agents that must be reached deterministically.
             Keep this list focused — the official guidance is to limit and filter
             subagents available to the LLM so it can route effectively.]
        instructions:
            | Clear routing instructions for fresh sessions.
              Describe each routable sub-agent's domain without ambiguity.
              Shorter instructions produce more accurate results.
```

### Before and After Reasoning

- Neither block is required. Add them only when your use case warrants it.
- Both blocks are invisible in Canvas view. Flip to Script view to see and edit them.
- Both blocks use the same `->` syntax as deterministic instructions in the reasoning block.
- Indentation must align with `reasoning:` at the same level.
- Before reasoning fires once, immediately on sub-agent entry, before any LLM processing.
- After reasoning fires once, after the LLM completes its loop, before the agent responds.
- Neither block is available when using EinsteinHyperClassifier as the sub-agent model.

### The Gotcha Checklist (Before You Declare It Done)

- [ ] Every action I call deterministically is not also listed in reasoning actions.
- [ ] Every variable I want the LLM to update has a matching setVariables utility action.
- [ ] Every sub-agent I want the LLM to transition to has a matching transition utility action.
- [ ] Every sub-agent in a multi-turn workflow stamps workflow_step in before_reasoning.
- [ ] workflow_step is cleared when a workflow completes cleanly.
- [ ] Global instructions and sub-agent instructions do not contradict each other.
- [ ] No sub-agent has so many if conditions and instructions that it becomes hard to read.
- [ ] Outputs of deterministic actions that are needed later are stored in variables.
- [ ] String variables are initialized to `""` not null so equality checks work correctly.
- [ ] My router model choice (general LLM vs. EinsteinHyperClassifier) is deliberate and matches my router's feature requirements.
- [ ] I have run at least one full end-to-end conversation in the tracer and checked the variable state panel at each step.

---

## Appendix B: The Spec-First Template

Before writing any Agent Script, complete this document. The script is a translation of this document, not the other way around.

**Agent Name:**
**Agent Description** *(will be used for orchestration — be specific):*
**Scope** *(where does this agent's responsibility start and stop):*

### User Intent Table

| User intent | Agent does | Actions called | Variables set | Agent responds |
|---|---|---|---|---|
| | | | | |

### Variable Registry

| Variable name | Type | Default | Set by | Cleared when |
|---|---|---|---|---|
| | | | | |

### Sub-Agent Map

For each sub-agent:
- **Name** *(clear, descriptive — the LLM reads this):*
- **Description** *(one sentence, unambiguous):*
- **Entry condition** *(how does the agent arrive here):*
- **Before reasoning** *(what must happen deterministically on entry):*
- **Deterministic instructions** *(if-then-else blocks):*
- **LLM instructions** *(natural language prompts — keep them short):*
- **After reasoning** *(what must happen deterministically on exit):*
- **Exit conditions** *(how does the agent leave this sub-agent):*

### Routing Plan

| Trigger | Routing method | Destination |
|---|---|---|
| workflow_step = "X" | Deterministic (before_reasoning) | Sub-agent X |
| New order intent | LLM tool call | user_verification |
| General question | LLM tool call | General Questions |
| Off-topic | LLM tool call | Off Topic |

### Router Model Decision

Answer these questions before choosing:
- Does my router need `before_reasoning` or `after_reasoning`? If yes: use a general LLM.
- Does my router need any tool other than `@utils.transition`? If yes: use a general LLM.
- Is my routing purely intent-based with no session state logic? If yes: EinsteinHyperClassifier is a strong option.

### Boundary Analysis

For each action in the system, answer: Must this fire with 100% certainty when condition X is met?
- Yes: deterministic, verify it is not also in reasoning actions.
- No: reasoning action, LLM decides when to call.
