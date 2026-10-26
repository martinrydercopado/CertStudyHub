# AgentOps Discovery Guide for Success Architects

**How to consult with clients about DevOps for Agentforce projects**

Audience: Success Architects who are not DevOps specialists.
Purpose: help you learn how a client delivers change today, explain why it matters, and recommend one or two realistic next steps.

---

## Contents

1. [How to use this guide](#1-how-to-use-this-guide)
2. [Why delivery matters for agents](#2-why-delivery-matters-for-agents)
3. [Ground rules for the conversation](#3-ground-rules-for-the-conversation)
4. [Prepare before the meeting](#4-prepare-before-the-meeting)
5. [The discovery conversation, area by area](#5-the-discovery-conversation-area-by-area)
6. [The maturity ladder](#6-the-maturity-ladder)
7. [Making the case: the cost of waiting](#7-making-the-case-the-cost-of-waiting)
8. [Scenarios](#8-scenarios)
9. [Quick reference: symptom to recommendation](#9-quick-reference-symptom-to-recommendation)
10. [Technical cheat sheet](#10-technical-cheat-sheet)
11. [Confirm before you advise](#11-confirm-before-you-advise)
12. [Glossary](#12-glossary)
13. [Further reading](#13-further-reading)

---

## 1. How to use this guide

You do not need to be a DevOps expert to run a good delivery conversation. You need to be curious, ask good questions, and know why each question matters.

**The core approach in four steps:**

1. **Learn** how the client delivers change today.
2. **Diagnose** one layer below the symptom.
3. **Pick one or two** next steps that fit where they are.
4. **Revisit** as they mature.

A client handed twenty best practices acts on none of them. A client handed two concrete steps they can start this week usually acts on both.

**What DevOps means here.** DevOps is a set of practices, not a product or a checklist. It means shipping change safely and often. It covers people and process as much as tools. Typical practices include version control, automated testing, CI/CD (automated pipelines), and rollback.

**What AgentOps means.** AgentOps is not a product. It is DevOps extended for probabilistic tools like agents. The biggest difference is that you are never done. You test and monitor continuously.

**How each section is built.** Most sections give you:

- **Why it matters**: so you can explain it in your own words.
- **Questions to ask**: sample wording you can adapt.
- **Listen for**: signals that point to a gap.
- **Good first step**: a small, realistic recommendation.

---

## 2. Why delivery matters for agents

### Why you should care as a Success Architect

- Improvements made in a sandbox only count once they reach production. If a change takes a month to get there, the work sits idle and the agent keeps misleading users in the meantime.
- In long-term engagements, you improve adoption and usage change by change. The speed and safety of the client's delivery limits how much you can achieve.
- You will be able to talk about return on investment in the client's terms: how long a change takes to ship, how often releases go wrong, and how long recovery takes.

### Why agents are different from other Salesforce features

Clients with strong Salesforce delivery habits often assume those habits carry over. Some do. Some break.

**Traditional Salesforce vs. Agentforce agents:**

- **Behavior.** Traditional features are deterministic. Agents are probabilistic. The same prompt can take different paths.
- **Errors.** A broken Flow throws a loud exception. A broken agent still answers, confidently and plausibly, and the answer may be wrong. There is nothing to alert on.
- **Testing.** Traditional tests give pass or fail assertions. Agent tests are behavioral evaluations scored against criteria.
- **Production changes.** Most config changes are reversible. Publishing an agent version is permanent. You roll back by activating an earlier version.
- **Debugging.** Traditional debugging uses stack traces and logs. Agents need you to trace the reasoning. There is no stack.

**The bottom line:** treating an agent as "just configuration" leads teams to skip version control, testing, and rollback planning. The real risk is the time between a failure starting and a fix reaching production.

### Name the old habit, then show why it breaks

Old habits formed for good reasons:

- Releases were infrequent, so process stayed light.
- Tests were skipped because configuration rarely surprised anyone.
- Production edits felt normal and reversible.

With agents these habits fail because failures are silent (you learn late), no assertion catches a bad answer unless someone wrote the test, publishing is permanent, and every untested change ships to users.

**Do not blame the team.** The habit was reasonable where it formed. Say so out loud.

### The evidence you can cite (and its limits)

DORA is Google Cloud's long-running research program on software delivery. Its findings are vendor-neutral. They are general software research, not Salesforce-specific, but the same logic applies to Salesforce teams.

- **Speed and stability improve together.** In DORA 2024, elite teams deploy on demand, with roughly a 5% change failure rate and recovery in under 1 hour. Low performers take 1 to 6 months to ship a change, with roughly a 40% failure rate and 1 week to 1 month to recover.
- **Use the labels carefully.** The same report cautions that elite and low labels are not useful for grading yourself. Use them to show what is possible, never to grade a client.
- **AI amplifies what is already there** (DORA 2025). It magnifies the strengths of strong organizations and the dysfunctions of struggling ones.
- **Version control and rollback make fast change safe** (DORA 2025). Mature version control is a psychological safety net.
- **The J-curve** (DORA 2024). Transformation often brings an initial dip, then large gains. Set that expectation early so the client does not quit at the bottom of the curve.

---

## 3. Ground rules for the conversation

### Ask before you advise

Powerful questions beat early solutions. Do not start problem solving in the first five minutes. Ask:

- What business decision does this metric or process support?
- Who is affected?
- What exactly are they trying to improve?

**Why:** discovery is not about showing what you know. It is about uncovering what the client has not yet put into words.

### Go one layer below the symptom

"Releases are slow" and "the agent keeps breaking" are symptoms. The cause might be manual deployments, no test suite, or edits made directly in production. Investigate at least one layer deeper before you form a view.

**Example probe:** "You said releases are slow. Walk me through the last one, from the moment the change was ready to the moment users had it."

### Use their words

If the client says "release window" or "go-live," use those words. Do not correct their vocabulary to match Salesforce or DevOps jargon.

**Why:** correcting vocabulary signals that you are there to grade them. Matching it signals that you are there to understand them.

### Stay in your lane

Say early which kind of engagement you are in, so nobody expects hands-on delivery.

- In pooled and Technical Health work, you assess and advise. You do not build the pipeline or write the code.
- In Agentforce Assist, you may work hands-on in the client's sandbox, but deployment to production stays with the client.

**Why:** building and running a pipeline needs a dedicated partner, vendor, or professional services team. It is also never finished. Salesforce ships three releases a year, each with a new API version, and each one means pipeline maintenance.

**Practical boundary:** your responsibility ends at the sandbox. You can share best practices and make sure the agent works well there. The client owns delivering it onward.

### Do not run a security review yourself

When the conversation moves into pipeline security, credentials, or compliance, point the client to their security team or a specialist partner. You ask the questions. You do not certify the answers.

### Be balanced

Discuss the risks of changing as honestly as the risks of doing nothing. That is how you and the client can see when the risk of not improving outweighs the risk of improving.

---

## 4. Prepare before the meeting

Do not walk into a delivery conversation cold. A short internal check saves a long session from going sideways. This matters most if you work a pooled model with many accounts.

### Who to ask

- **Customer Success Manager.** Relationship health, open delivery complaints, and what the client's leaders care about.
- **Account Executive or Solution Engineer.** Renewal timing, expansion plans, and any competing tools or partners in the picture.
- **Delivery lead or partner.** Open high-severity cases, past release problems, and commitments already made about how changes get deployed.

### Five account questions to answer first

1. Is this a red account?
2. Is a renewal coming?
3. Is there an expansion opportunity?
4. Have there been recent Sev-1 cases?
5. How does the client define success, in a number?

**Why:** a client with a recent Sev-1 caused by a release does not need a lecture on best practices. They need to feel heard first. A client with a renewal coming may have executives who care about adoption numbers. That tells you which story to tell.

---

## 5. The discovery conversation, area by area

You will not cover every area in one meeting. Start with the opener, then follow the client's pain. Use the "Five conversations before go-live" list in section 13 if time is short.

### 5.0 The opener: recovery time

**The question:**

> "If your agent starts misleading users tomorrow, how long before a fix reaches production?"

**Why it works:** the answer exposes almost everything: whether anyone owns the problem, how changes get deployed, whether rollback exists, and whether the client has ever measured any of this.

**Listen for:**

- "I don't know." (No measurement, no owner.)
- "Days," "next release window," or "we'd have to raise a change request." (Slow path with queues.)
- "We'd fix it directly in production." (No pipeline, drift risk.)
- "We'd activate the previous version." (A rollback habit exists. Ask whether they have ever rehearsed it.)

**A benchmark to share (agree it with the client, it is a starting point, not a platform guarantee):**

- **Stop further harm:** within hours, for example by switching off access or the affected action.
- **Restore known-good behavior:** under 1 hour matches the elite DORA benchmark. Treat it as a long-term goal. Many teams start by measuring in days.

---

### 5.1 Business goals and pain

**Why it matters:** tools and process only matter if they serve something the client cares about. If you cannot connect a recommendation to a number the client owns, it will be ignored.

**Questions:**

- What does success look like for this agent, in a number?
- Who is unhappy with how quickly agent changes reach users?
- When did a release last go wrong? What happened, and what did it cost?
- What is waiting in the queue right now that the business wants?

**Listen for:** executives who care about adoption or deflection numbers (use those in your recommendations), and incidents the team is embarrassed about (be gentle, they are your best evidence).

---

### 5.2 How change flows today (value stream)

**Why it matters:** the biggest delays are usually waiting, not working. Handoffs, queues, and approvals are the most common sources of delay. In one example from *Flow Engineering*, a 33-day process spent about two thirds of its time on handoffs and delays. The team cut the target to 7 days with a Kanban board and Slack notifications, not a large tool project.

**The exercise:** pick one real, recent change. Ask the client to walk you through it from idea to production. For each step, note two numbers: active time (someone is working) and waiting time (nobody is).

**Questions:**

- Take the last agent change you shipped. Who touched it, in what order?
- How long did it sit between each of those steps?
- Which step do people complain about most?
- Where did you have to ask someone for permission or wait for a slot?

**Listen for:** a single person or team that everything queues behind, and approvals that exist "because we always did it that way."

**Good first step:** record wait time per step before changing any tool. Visibility is cheap, and the first gain is often in the handoffs.

---

### 5.3 Source control and drift

**Why it matters:** version control is the audit record, the rollback source, and the safety net. Without it, nobody can answer "what changed, who changed it, and why." Also, a change made directly in an org is invisible to the repository, so the org and the repo drift apart.

**Questions:**

- Where does the agent's definition live today? Is it in Git, or only in the org?
- Who can change the agent directly in production?
- How do you know that what you tested is what is live?
- If two people edit the agent at once, what happens?
- Can you show me who approved the last production change?

**Listen for:**

- "It's in the org." (No version control.)
- "We have a repo but people also edit in the org." (Drift.)
- "Setup Audit Trail shows changes." (It did not show agent edits in testing. An agent version tells you when it was activated, not who changed what or how it differs from the previous version. Pull request approval is the audit record.)

**What belongs in the repository:** if it affects agent behavior, it belongs in the repo. That includes:

- The `.agent` file (Agent Script)
- Bundle metadata XML
- Supporting Apex classes, Flows, and prompt templates
- The agent user's permission sets
- `sfdx-project.json`

**What should not be committed:** version-suffixed bundles (the copy the CLI retrieves after publishing, such as `MyAgent_1`), hardcoded usernames, and hardcoded environment names.

**Good first step:** if the client has no version control at all, start with the agent metadata only. One island of discipline around the riskiest part beats waiting for a full process overhaul.

---

### 5.4 Environments and test data

**Why it matters:** a reliable test needs a place to run that resembles production. But every extra environment adds complexity, work, and delay.

**The ceiling, not the target.** Four stages:

1. **Developer sandbox.** Individual authoring and quick checks.
2. **Integration sandbox** (Partial Copy or better). Every merge deploys here and automated tests run here.
3. **UAT sandbox.** Business validation. Prefer Full Copy when answers depend on data volume, for example retrieval over a large knowledge base.
4. **Production.** Nothing goes here without passing the earlier stages.

Start with the fewest environments that give you a reliable test. If the client cannot afford four, combine integration and UAT in one Partial Copy sandbox and name the risk: an automated test run can disrupt a UAT session.

**Shift tests left.** A test that moves one step earlier runs sooner and shortens the time to find and fix a problem. For agents, run validation and Conversation Preview as early as possible, and use the integration sandbox for the full Testing Center suite.

**Do not rely on refreshes to keep sandboxes in sync.** Metadata that differs between orgs is a symptom of weak governance and delivery. Use deployments to keep metadata aligned, and use refreshes mainly to bring data back in line.

**Questions:**

- How many sandboxes do you have, and what is each one for?
- Does every environment run the same metadata, or do they differ?
- How do you keep test data realistic without using real customer data?
- Do external systems have test versions, or do your tests call live ones?
- What do you do with sandboxes after a refresh?

**Test data guidance to share:**

- A Developer sandbox holds no production data. Plan seeded test data, or use Partial or Full Copy with Data Mask & Seed.
- Agent tests run real actions, so sensitive data can be read, summarized, or emailed. Mask before it reaches the sandbox.
- Mock external systems where you can, so a failure points at the agent and not at a third party.
- Never put real customer data in test cases or pipelines.
- Run agent tests only in a sandbox. Tests can modify CRM data.

**Release alignment.** The updated agent metadata types arrive in API v68, and both source and target orgs must be on v68 to use them. If a sandbox is already on a newer release while production is not, the client must keep using the older types. In practice, the `sourceApiVersion` in `sfdx-project.json` decides which types can be deployed. This is a good "ask the delivery team" item, not something you debug.

---

### 5.5 Dependencies that metadata alone does not carry

**Why it matters:** an agent is not just the agent. A deployment can succeed while the agent fails in the target org because something it relies on never arrived.

**What the tooling handles:** the CLI retrieves an agent's Flow, Apex, and prompt template actions. In API v68, it retrieves the first level of dependencies for you. Custom objects still need adding by hand.

**What you must add to the client's environment checklist:**

- **Data 360 components** (data streams, data lake objects, calculated insights, data graphs, search indexes). Check the steps for moving them with a DevOps Data Kit against current Salesforce documentation before recommending them.
- **Search indexes after a refresh.** In one case, grounding failed because the retriever's search index was never rebuilt after a sandbox refresh. After every refresh, check that the retriever and its index are published and active.
- **Agentforce Data Library.** Salesforce Help says deploying Data Library changes from a sandbox to production is not supported. Plan to rebuild each library and its content in every environment and verify after each refresh.
- **Named Credentials and External Credentials.** Treat them as environment-specific. Keep secrets out of the repository. Manage them in the org, or inject them from CI variables just before deployment.
- **Agent tools that use MCP servers.** The External Service Registration, Named Credential, External Credential, and permission set names must match after a cross-org deployment, or tool action IDs change and the agent cannot call the tools. A platform fix may exist in a newer release, so check the org version.
- **Permissions for the agent user.** Check permission set and license assignments in every environment.

**Questions:**

- If I asked you to list everything this agent depends on, could you?
- What has to be rebuilt by hand after a sandbox refresh?
- Who owns the connection credentials in each environment?
- Has an agent ever worked in one environment and failed in the next? What was missing?

**Good first step:** a one-page dependency checklist per agent, kept next to the code.

---

### 5.6 Testing

**Why it matters:** UAT samples, it does not test. Ten scenarios clicked through once tell you those ten worked once. Agents drift silently, and any change can shift behavior elsewhere. Testing cannot happen only at the end of the release cycle.

**Two kinds of testing, two different approaches:**

- **Things that must be exactly right** (a calculation, a record update, an approval limit) belong in a Flow or Apex action with ordinary unit tests and a 100% gate.
- **Things that depend on understanding language** (choosing the subagent, picking an action, wording the answer) are tested with sets of cases and a threshold, plus human review.

**A simple question to separate them:** "What happens if the agent gets this one wrong, once?" The answer shows where a deterministic control is needed.

**How Testing Center scores:**

- Each test case has an input, an expected outcome, and acceptance criteria.
- An LLM judge compares the response to the criteria and scores it 0 to 5. A score of 3 or above passes.
- **Criteria must be able to fail.** "The agent should be helpful" gives unreliable scores. "The agent asks for the customer's email address before retrieving any order information" gives a consistent pass or fail. A test that cannot fail gives false confidence.
- Routing problems are fixed in the subagent name and classification description, not in the instructions.

**Five categories teams skip:**

1. **Subagent routing.** Right subagent for each request, including near misses and a request that fits none.
2. **Available-when gates.** Test a qualifying user and a non-qualifying user.
3. **Escalation paths.** Including the "I don't know" case.
4. **Security and prompt injection.** A regression suite of known attack patterns that runs on every release.
5. **Knowledge retrieval.** Check the right source is retrieved, separately from whether the answer is good. A wrong source is a data or index problem, not an instruction problem.

**Test the layer underneath.** Testing Center checks that the agent chose the right action and said the right thing. It does not prove the Flow or Apex underneath is correct. Treat that as ordinary deterministic testing.

**The shift-left schedule (the process matters more than the tool):**

- **Every pull request:** a fast smoke subset (routing, must-pass safety and escalation cases).
- **Every merge to integration:** the full suite. This is the main gate.
- **After a prompt, topic, instruction, action, Flow, or data source change:** the full suite plus cases for what changed.
- **After a permission change:** the full suite plus permission-sensitive cases.
- **After a model change or platform release:** the full suite, compared with the previous run.
- **On a schedule against the live agent:** an agreed monitoring subset, in a sandbox that mirrors production.

**Questions:**

- When do tests first run on a change?
- What pass rate blocks a release? Who decided that number?
- Can your test criteria fail? Show me one.
- Does every real defect become a permanent test?
- Which Flows can the agent call, and which of them has any automated test?
- Who can run and edit tests, and is that the same group that edits the agent?
- Do you own any UI automation tools already? (Many enterprises do, even if the team you are speaking to cannot access them.)

**Listen for:** "We test by clicking through before go-live," and "we run our tests just before each release." Both mean testing happens too late.

**Good first step:** define one pass-rate gate and build a small Testing Center suite from real conversations. Agree thresholds per use case and write them down. Keep a must-pass set (security, escalation, money, personal data) that is never waived.

**Useful facts, with a reminder to confirm them in the client's org:**

- Testing Center is included with Agentforce and enabled automatically in sandboxes. Production is not enabled automatically.
- Salesforce's release 262 note says Testing Center runs do not consume Einstein Requests or Flex Credits. Confirm edition and entitlement for the client.
- Trailhead states a limit of 10 test jobs at once in a 10-hour window and up to 1,000 test cases per test. Limits change.
- Testing Center is not a load tool. Load testing is a separate decision driven by risk (expected peak traffic, data volumes, number of integrated systems). It needs advance coordination with Salesforce, runs in a full sandbox, and never runs in production.

**On UI test tools:** they are good for deterministic checks, such as whether a case was created. They are not enough for agent answers, which need an LLM judge. UI tests also need ongoing maintenance because Salesforce does not treat the Lightning DOM as a stable API. When a client names a tool, ask these four things: does it run automatically from the pipeline, does it cover what changed (agent, Flows, Apex, prompts, permissions, not only screens), how many tests broke last release, and who maintains it.

**On AI for testing:** AI can help draft test cases. Do not treat an AI-generated check as a quality gate until it has proven stable.

---

### 5.7 Deploying, releasing, and rolling back

**Why it matters:** with a Flow, deploy and live are the same event. With an agent, deploy is only the first of several gated steps. Teams that miss this ship broken agents or cannot recover from them.

**The five-phase lifecycle (the phases cannot be skipped or reordered):**

1. **Generate:** author and iterate the draft in Builder or VS Code.
2. **Deploy:** metadata lands in the org, but the agent is not runnable yet.
3. **Publish:** compiles the runtime entities and locks that version permanently. No unpublish.
4. **Activate:** makes one version live and automatically deactivates the previous one.
5. **Test:** run the regression suite against the activated version, not just the sandbox version.

**Common mistakes to listen for:**

- Treating deploy as done.
- Publishing before testing in preview.
- Activating without a rollback plan.
- Stopping at sandbox testing and assuming production matches.

**Rollback is simple when it is prepared.** A bot can have many versions, but only one is active. Rolling back means activating the earlier version. No redeploy is needed. But it only works if someone wrote down the previous version number before the release and has rehearsed the steps.

**Two human gates.** Publish and activate are deliberate decisions. Decide who is allowed to do each in every environment before the first production release. "Whoever is available" is not an answer.

**Questions:**

- Walk me through what happens after the agent is ready in the sandbox.
- Who publishes? Who activates? Who decides?
- Before the last release, did anyone write down the previous version number?
- Have you ever rolled back an agent? Have you rehearsed it?
- What would you do if the new version started giving wrong answers in the first hour?

**Good first step:** tag every release, write down the prior version number, and rehearse a rollback in a sandbox. Decide up front whether each release rolls back or fixes forward.

**If a separate team handles deployment,** expect a person you have never met to ask for the exact name of every component and dependency. Help them by using a consistent naming prefix, keeping a dependency list, and pointing them to Salesforce's "Retrieve and Deploy Agent Metadata" guide. Do not step into their live deployment. Recommend a partner instead.

---

### 5.8 Branching and pipeline design

**Why it matters:** branching decides whether changes can be released independently. Poor branching leads to entanglement, where the business asks "Can we take story X out of this release?" and the answer is "not easily."

**The simple model (the good default):** short-lived branches that merge into `main`, so `main` always means live. Easy to teach, few long-lived branches, and fits small teams and fast release cycles.

**When a client needs an integration branch:** one `feature/*` branch per agent change, merged into `develop` (where changes come together and get tested), then into `main`, which is never committed to directly.

**Why keep branches short:** an agent is defined in one `.agent` file, so two branches editing it for weeks will conflict.

**Options and costs (ask which problem the client is trying to solve):**

- **Small batches, released often.** Helps with almost everything. Cheapest fix. Needs a fast, trusted pipeline.
- **Long-lived feature branches.** Lets you drop a story by not merging its branch. Costs branch drift and growing conflicts.
- **Feature flags and permission-based activation.** Separates deploying from releasing. Some metadata is hard to flag.
- **Back-merge every hotfix.** Every open branch needs maintenance. Count open branches when you assess risk.

There is no best model. It depends on release frequency, how often scope changes late, how many partners contribute, and Git maturity. Start simple, reduce batch size before adding branching complexity, and revisit as the team grows.

**Pull requests are the human gate.** A pull request stops unverified changes, including AI-written ones, from reaching integration or live environments. It also doubles as a compliance record: the diff, the test evidence, and the reviewer's name. A reviewer must understand agents well enough to check prompt instructions, action logic, tool bindings, and guardrails. A reviewer who cannot spot what the AI got wrong is not a gate.

**Questions:**

- How long do branches live before merging?
- How often do merge conflicts block people?
- Has the business ever asked to pull a story out of a release at the last minute? What happened?
- Who reviews changes, and what do they check?
- If you have monthly deployment windows, how often do you validate the release branch? (The night before is too late. Weekly is a better habit.)

**Hotfix pattern to describe:** branch from `main` or the live release tag, keep the fix to one change, run the same pipeline as a normal change, deploy and tag, then back-merge into every open long-lived branch so the next release does not undo the fix.

---

### 5.9 CI, CT, and CD: the three legs

**Why it matters:** clients often build part of a pipeline and stop. Continuous testing is the leg most often dropped.

- **Continuous integration (CI):** validate syntax, deploy to a sandbox, publish in the sandbox.
- **Continuous testing (CT):** preview smoke tests, regression against the active agent, and read the result file instead of trusting the exit code.
- **Continuous delivery (CD):** pull request approval, publish gate, activate gate.

**Evidence to share carefully:** the 2021 DORA report found elite performers who meet reliability targets are 3.7 times more likely to use continuous testing. This is a survey-based association from general software research. It does not prove testing alone causes better results.

**Five things that catch teams out (good questions, not for you to troubleshoot):**

1. Publish never activates. A published version stays Inactive until someone activates it.
2. Publish creates a new version every time, even if nothing changed.
3. **The agent test command can exit 0 even when tests fail.** A pipeline must read the result file and fail on any failed case. It should also fail on zero results, because a suite run against an inactive agent returned no results and no error.
4. Rolling back means activating an earlier version.
5. A retrieved bundle can carry a `<target>` tag that makes deployment to a clean org fail.

**More pipeline questions worth asking:**

- Does the pipeline run a check-only deployment first? (A validation against a real org catches most dependency and ordering problems.)
- How does it handle deployment order, deletions, and renamed components?
- Is the Salesforce CLI version pinned? (A pipeline that installs the latest version can break overnight.)
- What happens if a deployment fails halfway?

**Good first step:** set up the whole structure early, even if each stage is minimal. A partial pipeline that validates and deploys is already useful. Add static analysis and the full regression suite over the following weeks.

---

### 5.10 Roles and governance

**Why it matters:** before the first production change, every team should be able to name who does each job. "Everyone" and "whoever is available" are the gap to close.

**The six roles:**

- **Author** (admin, App Builder, or developer). Makes changes in a scratch org or development sandbox and commits them to version control.
- **Reviewer.** Reads every change before it merges. Needs enough platform knowledge to catch mistakes, including AI-generated ones.
- **QA or business tester.** Tries to break the agent, remembers recurring failures, signs off in UAT.
- **Release owner.** Publishes and activates versions, and owns the rollback plan.
- **Pipeline owner.** Owns the CI configuration and the integration user's credentials.
- **On-call owner.** First responder when the agent misbehaves in production.

**Practices to raise:**

- **Developers should not be the only testers.** Developers tend to stay on the happy path.
- **Admins who build are authors.** They should work in a scratch org or development sandbox, track changes in version control, and let the pipeline deploy. They do not need to become developers.
- **Close direct edits in production gradually.** Start by restricting Author Apex and Customize Application, and watch who holds Modify All Data and View All Data. Before you do, make sure the pipeline exists, builders are comfortable with it, it is reasonably fast, and the business reasons have been explained without implying distrust.
- **Smallest workable gate:** for a small team, one person commits and a second approves before anything deploys.
- **Across several teams,** a center of excellence lets teams share what works.

**Questions:**

- Who owns the change, and who owns the rollback?
- Who is on call when the agent misbehaves at 2 a.m.?
- What approvals does regulation or policy require? Can an emergency change have a shorter approval?
- Does your change advisory board (CAB) have a standing emergency procedure?
- Who can edit the agent in production today?

**Emergency changes.** The emergency track should use the same pipeline with a fast lane, not a separate manual route. If it is manual, it becomes the way around every control.

**Governing multiple agents.** When several teams share one large agent, one team's change can block everyone. Decomposing into smaller agents gives each team its own pipeline and tests, and a smaller blast radius. Ship deletes in a separate, later deployment as a precaution. Treat decomposition as an organizational design decision as much as a technical one, and make it before the monolith ships.

---

### 5.11 Security and permissions

**Why it matters:** the agent inherits its user's permissions. A permissions gap can look like an agent that "works but returns nothing." A permissions excess can expose data.

**Questions that matter most:**

- What laws, audits, or contractual requirements shape how this agent must be secured? Who decides whether it meets them?
- Who verified the agent user's permissions in each environment?
- How does the pipeline log in to each org? Is it tied to a person's account?
- If someone stole the pipeline's credentials tonight, what could they change in production by morning? How would you know?
- What data will the agent read, write, or log?

**What to know:**

- **Auto-generated permission sets can omit Apex classes.** In one documented case, 3 of 4 classes were missing.
- **Missing access can fail quietly.** Depending on how queries are written, a user with no field access can cause an exception that surfaces as an error, an unhelpful reply, or an empty answer. A tell-tale sign is the live preview returning empty results while the simulated preview works. Confirm on the client's own agent user.
- **For Data 360 and retrieval,** the Default Data Space must be enabled for the agent user's permission set.
- **Pipeline users:** a dedicated integration user per pipeline, not a person's account. Least privilege. Secrets in the CI platform's secrets store, never in the repository. Credentials with an owner, an expiry date, and a rotation routine.

**Paths that bypass the pipeline (ask about each):**

- Direct edits in higher environments.
- **Change Sets.** Agent metadata is Change Set eligible, and a Change Set deploy does not pass through a CI pipeline, so it skips any scans and approvals. Confirm in the client's org, and check who holds the Deploy Change Sets permission.
- Shared admin logins, which hide who did what.
- A separate manual emergency route.
- Third-party tools or partners with their own production access.

**Model changes.** A privileged user can switch the model for a subagent or prompt template, and there is no platform lock that prevents a permitted user from doing so. The approach is prevent, detect, and prove (see the federal scenario in section 8). Also remember that model retirements will keep happening, and each new model behaves differently. A model change is a big change that must be planned and tested.

**Scope reminder:** complex sharing rules, field-level security, custom profiles, and compliance reviews stay with the client's admins, security, and compliance teams.

---

### 5.12 Monitoring and cost

**Why it matters:** agent failures are silent. If nobody is watching, the first signal is an unhappy user.

**Questions:**

- How do you find out when the agent is giving poor answers? Do you hear from users first?
- Who reviews traces and abandoned sessions each week?
- Who watches credit consumption, and how?
- Has your credit usage ever jumped unexpectedly?

**Listen for:** "We only hear about problems from users."

**Good first steps:**

- Turn on enhanced logs and Observability, and review abandoned sessions weekly.
- When credit usage jumps, compare the Digital Wallet with the usage data model by subagent, then look for repeated initialization and oversized context.
- Check current credit pricing before quoting any numbers.

---

### 5.13 Tooling

**Why it matters:** tooling usually gets the blame for problems that are really about people and process. The tool is rarely the root cause. It is where the problem becomes visible.

**Common root causes behind "the tool is the problem":**

- **No onboarding or training.** Teams never learned how the tool is meant to be used.
- **Weak Git fundamentals.** Branching, merging, and pull requests are assumed knowledge.
- **Weak Metadata API knowledge.** Every Salesforce delivery tool is bounded by what the Metadata API can retrieve, deploy, and compare. No tool can remove that limit.
- **A process forced onto a tool that cannot support it.** The better order: understand the organization, understand the tools, design the process around both, then train people.

**Questions before you advise on tooling:**

- What tool do you use today, and who chose it and why?
- Who was trained on it, and who has joined since?
- What does your team believe it cannot do? Is that true, or a configuration gap?
- Where do people work around it? Workarounds show where process and tool disagree.

**The landscape, stated neutrally.** Recommend the smallest tool change that unlocks the process the client needs.

- **Commercial DevOps platform.** Buy a purpose-built Salesforce DevOps product (for example Copado or Gearset). Watch licensing cost and the vendor's model. Training and process are still required.
- **General CI tool plus Salesforce CLI.** Build on GitHub Actions, GitLab CI, or Jenkins using the `sf` CLI. You build and own the Salesforce-specific logic.
- **Hybrid.** A commercial tool for some stages, a CI runner for others. Two systems to keep in sync.
- **Salesforce Lifecycle Center** (previously DevOps Center). Salesforce's own change and release management option, built around work items, pipelines, and a source repository. The current version needs no package install and adds quality gates and governance for AI agents (Beta). How it handles agent metadata has not been tested in this program, so try an agent in a sandbox first.

Every option is built on the Salesforce CLI and Metadata API. Standardize on the CLI. Change sets are too limited. Third-party tools are fine if they run the CLI and enforce approval gates. Do not recommend or dismiss any tool on reputation. Test against the client's constraints in a proof of concept.

**Delta deployments.** Deploying only what changed is not something a CI platform does for you. The options are a full deployment every time, an open-source plugin such as `sfdx-git-delta` (a community plugin, not a Salesforce product, so pin its version), a commercial platform, or custom scripts. Ask what happens to deleted and renamed components.

**Metadata API gotchas worth asking about (do not troubleshoot them yourself):**

- **Deployment order.** Objects before fields, and code that uses those fields after both exist.
- **Profiles.** Deploying a profile overlays the target's settings, and a newly disabled permission is not exported. Prefer permission sets.
- **Destructive changes.** Deploys add and update. Removing components needs a separate destructive changes manifest.
- **Long-running changes.** A field type conversion includes data work. Plan release windows around large data volumes.

---

### 5.14 Packaging (the question clients ask early)

**Why it matters:** clients ask about packaging because Salesforce DX is marketed around it. Packaging is a step for clients who are already mature, not a place to start.

**Why clients want it:** simpler deployments (one package version ID installs identically everywhere), less drift between orgs, and a clearer structure.

**Why it is a maturity step:**

- Refactoring existing metadata into packages is the hardest part of adopting DX.
- It sits on top of version control and CI. A client without those has nothing to package from.
- Someone must own package boundaries and dependency order.

**What to say:**

1. Version control first. Get metadata into Git, reviewed through pull requests.
2. Then automated validation. Check-only deployments and tests on every change.
3. Then consider packaging, when the client has several production orgs, wants shared customizations, or has a modular codebase worth splitting.
4. If they do package, start small. An unlocked package can take ownership of existing metadata with no data loss, so one area can move at a time.

**Questions:**

- What do you hope packaging will fix? Drift, deployment errors, or sharing across orgs?
- Do you have version control and a pull request habit today?
- How many production orgs do you run?
- Who would own the package boundaries?

**Agents and packaging caution.** Packaging an agent was not tested in this program. Before promising anything, check each metadata type the agent uses in the Metadata Coverage Report and try it in a sandbox. Running packaging for some metadata and another method for the rest means running two methods side by side.

---

### 5.15 AI-assisted development

**Why it matters:** DORA 2025 found AI amplifies what is already there. Teams with weak delivery habits ship bad changes faster.

**Guardrails to recommend:**

- **Build manually first.** A developer who has never built an agent by hand cannot judge what AI produced.
- **Review AI output as rigorously as human code, through pull requests.**
- **Test AI-written code more, not less.**
- **Protect the audit trail.** Document AI-assisted authorship in pull requests. For regulated clients it can be a disclosure item.
- **Expect errors.** Agent Script is poorly represented in LLM training data, so AI tools can get platform details confidently wrong.

**Question:** "Who reviews AI-generated agent changes, and how do they know what the AI got wrong?"

---

## 6. The maturity ladder

Use the ladder to decide what to recommend. The client climbs one rung at a time.

**Rung 0: Ad hoc.**
Changes are made directly in production or moved by change sets. No version history. Testing is clicking through before go-live.
*Next step:* put the agent metadata into Git using CLI commands, with one release branch and short-lived feature branches. Add a second reviewer.

**Rung 1: Version control with review.**
Metadata is in Git and changes are reviewed through pull requests, but deployment is still manual.
*Next step:* add check-only validation and a small Testing Center suite, and write down version numbers for rollback.

**Rung 2: Automated validation and testing.**
Every change is validated and tested automatically. Deployment may still be semi-manual.
*Next step:* automate deployment to the integration sandbox, define the pass-rate gate, and rehearse rollback.

**Rung 3: Automated delivery with human gates.**
Pipeline deploys through environments. Publish and activate are recorded human gates. Rollback is rehearsed.
*Next step:* add monitoring, security scans, model allowlist checks, and flow metrics.

**Rung 4: Continuous improvement.**
Metrics (deployment frequency, lead time, change failure rate, rework rate, recovery time) drive decisions. Governance is built into the pipeline.
*Next step:* decompose large agents, consider packaging, and share practices across teams.

**Rules for using the ladder:**

- Pick one or two next steps. Do not describe all five rungs.
- A client on change sets should not hear "you need a full CI/CD pipeline with scripted quality gates." The conversation can shut down. Instead ask: "What are the next two things you could do?"
- Packaging belongs on a later rung.
- The ladder is not a grade. It is a map.

---

## 7. Making the case: the cost of waiting

Stakeholders who sign off spend do not care that releasing is hard. They care about cost and risk. Frame your recommendation as a return-on-investment conversation, and ideally bring a delivery partner into it.

**Do nothing is not free.** The comparison is between where the cost sits now and where it would sit after an improvement.

### Measure first

Track three numbers:

- How long it takes to deploy to production.
- How long regression testing takes.
- How often one team is stopped because it is waiting on another.

### Count the incidents

Add up what unplanned production changes cost: several developers pulled in to debug, often out of hours, plus the business impact on users. *Mastering Salesforce DevOps* recounts how Salesforce's own IT team compiled these costs and used the numbers to win approval for stricter change control. Use the client's own incident numbers, never the book's.

### Show what waiting costs

Every week an agent fix sits in a queue is another week of conversations with the old behavior. Put that next to the client's adoption goals.

### The five DORA metrics (use this small set instead of many)

- **Deployment frequency:** how often changes ship.
- **Lead time for changes:** how long a commit takes to reach production.
- **Rework rate** (new in 2025): the share of deployments that were unplanned fixes for an incident.
- **Change failure rate:** the share of changes needing a hotfix, rollback, or patch.
- **Failed deployment recovery time:** how long it takes to restore service.

**How to use them:** many teams already know informally how many releases were really hotfixes. That maps directly to rework rate and change failure rate, so you can benchmark without a survey.

**Cautions:**

- Older books list four metrics. Rework rate was added in 2025.
- DORA 2025 no longer publishes a simple elite versus low table. It shows distributions across bands. Most teams are not in the top band, so do not present it as a pass mark.
- Do not reuse older failure figures as 2025 numbers. The bands changed, so they are not comparable year to year.
- Do not present DORA findings as cost or ROI evidence. They show associations.
- Vendor surveys (Gearset, Copado) can be used as optional extras, with care, because they come from vendors.

### Set the J-curve expectation

Tell clients that things may feel worse before they feel better. That keeps them from abandoning the change at the bottom of the curve.

---

## 8. Scenarios

Each scenario gives the situation, what to ask, what you are probably seeing, and what to recommend.

---

### Scenario 1: "We build directly in production and have no pipeline."

**Situation.** A mid-sized client with two admins who build and tweak the agent live. Nobody has complained loudly. You are asked to improve agent quality.

**Do not open with the full pipeline.** Everything they do today still works, because Salesforce allows changes in production.

**Ask:**

- What problems does the current way of working cause?
- What does it cost to keep going this way?
- When did an edit last break something? How did you find out, and how did you fix it?
- If your agent started giving wrong answers tomorrow, how would you restore the previous behavior?

**What you are probably seeing:** no version history, no rollback, no tests, and a risk that one person's edit changes live behavior for every user.

**Recommend (one or two steps only):**

1. Create a sandbox where the agent is edited and tested first, and put the agent metadata in Git.
2. Before each publish, write down the active version number so rollback is possible.

**Why:** these steps are small, inexpensive, and address the largest risk (no way back). A full pipeline is a larger project than an engagement like this can deliver. Frame the larger investment as an ROI conversation with the stakeholders who sign off spend, and bring a delivery partner if possible.

---

### Scenario 2: "We use change sets and we're happy with them."

**Situation.** A client's Salesforce team has used change sets for years. They want to add an agent and "do it the same way."

**Meet them where they are.** Do not say they need CI/CD. Ask what the next two things they could do are.

**Ask:**

- How do you keep track of what is in each change set?
- Has a change set ever left something out, or overwritten something?
- How do you test the agent after it deploys?
- Who can deploy a change set to production?

**Likely issues:**

- Change sets have no diff history.
- Agent deployment has extra gated steps (publish, activate) that change sets do not model. Deploying is not the same as going live.
- Change sets skip any pipeline scans and approvals.

**Recommend:**

1. Put the agent metadata in version control and add a second reviewer.
2. Keep change sets for config-only items if they must, but run agent releases through the CLI path.

**Why:** you are not taking away what works. You are protecting the one area where mistakes are silent and publishing is permanent.

---

### Scenario 3: "Releases are slow. Fixes sit in a queue."

**Situation.** A well-staffed client. The agent team says it takes six weeks to ship a small instruction fix.

**Do not guess at the cause.** Run a mini value stream exercise on the last small fix.

**Ask:**

- Walk me through the last fix from idea to production.
- Where did it sit and for how long?
- Who had to approve it?

**What you might discover:** the fix took 2 hours to build and 4 days to test, but sat 5 weeks waiting for a monthly release window, a CAB meeting, and a partner to do the deployment.

**Recommend:**

1. Record active versus waiting time per step. Share the picture with leadership.
2. Attack the biggest wait first. If it is the monthly window, try smaller, more frequent releases and validate the release branch weekly.

**Why:** the first gain is often in the handoffs, and it often needs visibility and a notification, not a large tool project.

---

### Scenario 4: "Stories get pulled from UAT at the last minute."

**Situation.** A client with a shared integration sandbox and UAT. Every release the business asks to remove one or two stories, and the team scrambles.

**Likely cause:** entanglement. Many changes merge together, and pulling one out is hard and manual.

**Ask:**

- How many changes go into a typical release?
- How is a change removed once merged?
- How long do feature branches live?

**Recommend, in order:**

1. **Smaller, more frequent releases.** The cheapest fix for almost everything.
2. If that is not enough, consider feature flags or permission-based activation, which separate deploying from releasing. Note that some agent metadata is hard to flag.
3. Only then consider long-lived feature branches, knowing they cost branch drift and growing merge conflicts.

**Why:** do not add branching complexity before reducing batch size.

---

### Scenario 5: "It worked in the sandbox but production doesn't match."

**Situation.** An agent passes every test in the sandbox. After release, it behaves differently in production.

**Ask:**

- What is different between the sandbox and production? Metadata, data, permissions, or connections?
- Has anyone edited something directly in production?
- How did you check that production matched the sandbox?
- Who holds Modify All Data and Author Apex in production?

**Likely causes:**

- **Drift** from direct production edits.
- **Missing dependencies** (Data Library content, search indexes, Named Credentials, permissions).
- **Environment-specific values** such as agent usernames.

**Recommend:**

1. Treat Git as the source of truth, and reduce direct edits in higher environments.
2. Build an environment checklist for the dependencies metadata does not carry.
3. After every release, run the regression suite against the activated agent in production-like conditions, not just the sandbox version.

**Why:** a successful deploy is the halfway point. Publish and testing are the real integration tests.

---

### Scenario 6: Strong developers, no agent tests

**Situation.** A technically mature client with GitHub, a CI pipeline, and 90% Apex coverage. Agents are newly added, and the team assumes the pipeline "covers it."

**The trap:** they carry deterministic testing assumptions over. Apex tests give pass or fail. Agent behavior is probabilistic.

**Ask:**

- What tests run on the agent in the pipeline today?
- What does a failing test look like for an agent?
- Does the pipeline read the test result file, or only the exit code?
- Which Flows and Apex actions behind the agent have tests?

**Recommend:**

1. Add a small Testing Center suite with criteria that can fail, and wire it into the pipeline.
2. Make the pipeline read the results file and fail on any failed case or on zero results. (The agent test command can exit 0 even when cases fail.)
3. Keep exact logic in Flow or Apex with ordinary unit tests, and test language-driven behavior with case sets and thresholds.

**Why:** their discipline is real. You are only extending it to a probabilistic system.

---

### Scenario 7: Partner team deploys to production

**Situation.** You helped a client build an agent in a sandbox. A separate deployment team you have never met now takes over.

**Likely problem:** they ask for every component and dependency by name. An agent spreads across the bot, permission sets, Flows, Apex, Experience Cloud components, and any Omni-Channel flow.

**Prepare while you build:**

- Use a consistent naming prefix on everything you create.
- Keep a list of every component the agent depends on.
- Point the team to the official "Retrieve and Deploy Agent Metadata" guide.
- Confirm Data Library, Data 360, credentials, and permission sets are on the checklist.

**Do not** step into their live deployment to help. A live walkthrough of an unfamiliar deployment tends to run into trouble.

**Why:** your responsibility ends at the sandbox. Good preparation lets them succeed without you.

---

### Scenario 8: A sandbox refresh breaks retrieval

**Situation.** After a routine refresh, the agent stops answering knowledge questions. No errors, just "I can't find that."

**Ask:**

- Was a sandbox recently refreshed?
- Does the retriever's search index exist and is it active?
- Was the Data Library rebuilt? (Sandbox-to-production deployment of Data Library changes is not supported, so content must be rebuilt in each environment.)
- Do the agent user's permission sets include the data space?

**Likely cause:** the index was never rebuilt after the refresh, or the library content was not recreated.

**Recommend:**

1. Add a post-refresh checklist: retriever and index published and active, library rebuilt and verified, connections reactivated, permissions checked.
2. Add a knowledge retrieval test that checks the right article is retrieved, separate from answer quality.

**Why:** connections are copied to sandboxes but authentication data is not. Connectors can show "Needs Activation" until reactivated.

---

### Scenario 9: Regulated client must prove which model ran

**Situation.** A government client's employee-facing agent summarizes CRM contact records. Security rules say data may only go to approved models inside the Salesforce Trust Boundary. They need to prove the model never changed and be alerted if an unapproved one is ever used.

**Understand the threat.** It is not a platform vulnerability. It is an authorized but careless or malicious privileged user changing a model setting without peer review. There is no platform lock that stops a permitted user from switching providers. Salesforce's posture is detection.

**Frame the answer as prevent, detect, prove:**

- **Prevent.** Hide non-approved models in AI Models settings. Allow no edits to prompt templates or agents in production, so every change goes through the pipeline and peer review. Add a CI gate that fails the build if a prompt template or Agent Script references a model outside the approved list.
- **Detect.** Compare what actually ran against an allowlist, for example with a scheduled job that checks usage records for unapproved models and alerts.
- **Prove.** Auditors need evidence of what was invoked, not only what was configured. The session trace shows the model for each LLM call. Data 360 reports on AI Gateway request records provide a recurring audit artifact.

**Be honest with the client:**

- Reporting and alerting depend on Data 360, which this client had not started using.
- Demo results prove the mechanism, not the client's configuration.
- Whether Salesforce-hosted classifiers count as approved models is for the client's review board.
- Change Sets can bypass a pipeline model scan, so ask who can use them.

**Why:** prevention fails when someone has legitimate access. You need all three layers.

---

### Scenario 10: The change board blocks everything

**Situation.** A large enterprise CAB meets every two weeks and treats every agent change as high risk. Teams are frustrated and start making production edits to avoid the queue.

**Ask:**

- What does the board need to see to approve with confidence?
- What does an emergency change look like?
- How much of the board's time goes to changes that never fail?

**Recommend:**

1. Move quality gates upstream and bring test evidence (pull request diff, test results, reviewer) to the board.
2. Create an emergency track that uses the same pipeline with a fast lane, not a manual back door.
3. Agree which kinds of change need board review and which can proceed with pipeline evidence only.

**Why:** the board's real need is evidence and control. Give it better evidence and you often reduce the friction without removing control.

---

### Scenario 11: "The same incidents keep recurring."

**Situation.** An agent gives wrong answers on a specific topic, gets fixed, and later breaks again.

**Ask:**

- When it was fixed, did the fix become a permanent test?
- What changed between the fix and the recurrence (prompts, Flows, data, model)?
- How did you notice?

**Recommend:**

1. Every real defect becomes a permanent test case.
2. A few reliable blocking gates, with agent tests where agents are in scope.
3. Run the full suite after any prompt, topic, action, Flow, data, permission, or model change.

**Why:** regression is never free, and agents change behavior without code changes.

---

### Scenario 12: "The tool is the problem."

**Situation.** A client says their DevOps tool does not work and wants to switch.

**Ask before recommending anything:**

- Who was trained on it, and who has joined since?
- What do you believe it cannot do? Is that true?
- Where do people work around it?
- Do you have Git fundamentals in place?

**Likely findings:** missing onboarding, weak Git skills, or a process forced onto a tool that cannot support it.

**Recommend:** check training and fit before a swap. If a swap is justified, recommend a proof of concept against the client's real constraints. Do not recommend or dismiss any tool on reputation.

**Why:** a team that installs a new tool without changing its process reproduces its old habits inside it.

---

### Scenario 13: "Can we use packaging?"

**Situation.** An admin team saw Salesforce DX marketing and asks whether to move to unlocked packages for agents.

**Ask:**

- What do you hope packaging will fix?
- Is metadata in Git? Do you review through pull requests?
- How many production orgs do you run?

**Likely finding:** they have no version control habit and years of accumulated metadata with tangled dependencies.

**Recommend:** version control first, then automated validation, then reconsider packaging. If they proceed, start with one small area. Do not promise that an agent can ship in a package until each metadata type is checked and tried in a sandbox.

---

### Scenario 14: Git sits behind a firewall

**Situation.** A client's repository is on-premises. A commercial pipeline tool cannot reach it.

**Explain:** whatever runs the pipeline must be able to run Git commands against the repository. Common patterns for commercial tools are allow-listing the vendor's IP addresses or setting up a reverse proxy that creates a secure tunnel.

**Ask:** "If you will neither open the firewall nor pay for a tunnel, how is anyone expected to work with the repository?"

**Route it:** this is an architecture question for the client's platform and security teams.

---

### Scenario 15: "We tested thoroughly. Then a model update changed the answers."

**Situation.** An agent passed all tests at launch. Months later, answers shift after a model switch, and the client starts tuning settings such as temperature.

**Ask:**

- Do you know when the model changed?
- Did you re-run your suite when it did?
- Is there a standing check for model changes?

**Recommend:**

1. Treat a model change as a big change. Plan and test it extensively.
2. Re-run the full suite and compare with the previous run after every model change or platform release.
3. Add a scheduled monitoring subset against a sandbox that mirrors production.
4. Add a model-change check as a standing governance item.

**Why:** models will keep being retired, and each new model behaves differently.

---

## 9. Quick reference: symptom to recommendation

Use this as a prompt for your first recommendation. Always check with discovery questions first.

**"Releases are slow" or "fixes sit in a queue"**
Area: waiting time and handoffs.
First step: map the value stream and record wait time per step before changing any tool.

**"Production does not match what we tested"**
Area: version control and drift.
First step: treat Git as the source of truth and reduce direct edits in higher environments.

**"We keep getting conflicts"**
Area: branch length and Git skills.
First step: shorter branches, merge from `main` often, train people on resolving conflicts.

**"Stories get pulled late in UAT"**
Area: batch size and branching.
First step: smaller, more frequent releases.

**"The same incidents keep recurring"**
Area: quality gates and tests.
First step: a few reliable blocking gates, and agent tests where agents are in scope.

**"We cannot undo a bad release"**
Area: rollback.
First step: tag every release, decide whether each release rolls back or fixes forward, and rehearse it.

**"The tool is the problem"**
Area: training, fit, process.
First step: check onboarding and fit before recommending a swap.

**"We test by clicking through before go-live"**
Area: testing.
First step: define a pass-rate gate and build a Testing Center suite from real conversations.

**"We run our tests just before each release"**
Area: testing.
First step: shift left. Run a fast smoke subset on every pull request and the full suite on every merge.

**"The agent returns no data but nothing errors"**
Area: security.
First step: query the agent user's permission set and Apex class access.

**"We only hear about problems from users"**
Area: monitoring.
First step: turn on enhanced logs and Observability, and review abandoned sessions weekly.

**"Our credit usage jumped"**
Area: cost.
First step: compare the Wallet with the usage data by subagent, then look for repeated initialization and oversized context.

**"Our change board blocks every release"**
Area: governance.
First step: move quality gates upstream and bring test evidence to the board.

**"We need to prove which model ran"**
Area: security.
First step: prevent, detect, and prove (CI gate, allowlist check, session trace).

**"One team's change blocks everyone"**
Area: governance.
First step: consider decomposing the agent with independent pipelines.

---

## 10. Technical cheat sheet

You do not need to master this. You need enough to follow the conversation and ask good questions.

### The agent lifecycle in one line

**Deploy is not live. Publish is permanent. Activate flips the version.**

### Authoring versus runtime metadata

- **Authoring (editable, reviewable):** `AiAuthoringBundle` holds the Agent Script. It stays in Draft until published. This is what reviewers, auditors, and change boards should look at.
- **Runtime (compiled, immutable):** `Bot`, `BotVersion`, and `GenAiPlannerBundle` are created on publish. People cannot meaningfully review them.
- A version becomes Committed, then Legacy when a newer version is activated.
- Deploying the `AiAuthoringBundle` alone does not give you a runnable agent. Publishing does.

### Three generations of metadata

- **Legacy builder:** separate pieces you track yourself (`GenAiPlanner`, `GenAiPlugin`, `GenAiFunction`, `Bot`, `BotVersion`).
- **Next-gen (API v67):** you author `AiAuthoringBundle`, and publish creates `Bot`, `BotVersion`, and `GenAiPlannerBundle`. You still list Apex classes, Flows, and prompt templates yourself.
- **Latest (API v68):** two types, `AiAgentDefinition` (the parent, required on the first deploy to any target) and `AiAgentDefinitionVersion`.

**Rules for v68 to be aware of:** both orgs must be on API v68. The first deploy to a target must include the full `AiAgentDefinition`. Do not mix old and new types in one deployment. Keep version numbers matched between source and target. This area changes quickly, so check the current Agentforce developer guide.

### Deploying an agent: two paths

- **Path 1 (recommended default).** Deploy dependencies first (Apex, Flows, custom objects, prompt templates). Deploy the `AiAuthoringBundle` with the `<target>` tag omitted. Publish (creates an Inactive version). Activate.
- **Path 2 (alternative).** Requires project API 68.0 or higher. Deploy the bundle with the agent definition and version asset. Include the `<target>` tag on the first deploy into an org only. The agent still arrived Inactive in testing and needed manual activation.

These results came from one small test agent in sandboxes. Try the route in a sandbox before using it for a client.

### Build order to explain

1. Dependencies (Apex classes and Flows the actions reference).
2. The `AiAuthoringBundle`.
3. Publish.
4. Activate. The previous version becomes Legacy.

**Deploy can pass while publish fails.** Publish compiles the runtime entities and fails if something the agent references is missing.

### Rollback in two steps

1. Activate the earlier version. It takes effect immediately and needs no redeploy.
2. Verify the prior version shows as Active and run smoke tests. They also show the old version still works with today's Flows, Apex, and prompt templates.

Write down the previous version number before each release. Never search for rollback targets mid-incident.

### Why can't Salesforce teams do true source control?

The Metadata API sets the limit. You can only replicate in Git what Salesforce lets you retrieve, so teams cannot work fully locally. They use cloud sandboxes or scratch orgs, and those drift apart. No vendor can give access to what the API does not provide.

### Does the platform track what changed in a sandbox?

Source tracking is available only in Developer and Developer Pro sandboxes. It helps list changed files but is not an audit record. A client that needs a trustworthy history still needs version control.

---

## 11. Confirm before you advise

Much of this guide comes from practitioner testing in one sandbox with one small agent. Before advising, confirm the following in the client's own org:

- Steps for moving Data 360 components with a DevOps Data Kit, against current Salesforce documentation.
- How the client will rebuild Agentforce Data Library content in each environment.
- Current Testing Center limits and entitlement (edition, whether runs are unmetered).
- Named Credential and connector handling, with the client's integration and data teams.
- Whether the `WITH USER_MODE` and permission findings hold for the client's agent user.
- Whether sandbox findings (CLI exit codes, minimum permissions, Change Set behavior) hold on the client's CLI version.
- Current credit pricing, before quoting any numbers.
- Whether model-change results hold in the client's org, not only a demo org.
- How Lifecycle Center, or any tool you mention, handles agent metadata.

**Stay honest about limits:**

- Do not present DORA findings as cost or ROI evidence.
- Load testing details come from internal enablement material that has not been checked against published documentation.
- Security control areas for pipelines come from general CI/CD practice, not Salesforce documentation. Do not run a security review yourself.

---

## 12. Glossary

- **CI (continuous integration).** Merging small changes often, with each merge automatically validated and tested.
- **CT (continuous testing).** Running automated tests on every change as part of the pipeline.
- **CD (continuous delivery or deployment).** Moving a validated change to the next environment, and to production, in a repeatable way.
- **Pipeline.** The ordered set of automated steps a change passes through, from pull request to production.
- **Drift.** The org no longer matches the repository because someone changed it directly.
- **Delta deployment.** Deploying only the components that changed between two points in Git.
- **Destructive change.** A deployment instruction that deletes components from an org.
- **Validate (check-only) deployment.** A deployment run that tests whether a change would succeed, without saving it.
- **Metadata API.** The Salesforce API that retrieves and deploys configuration and code. Every pipeline tool is bounded by it.
- **Salesforce CLI (`sf`).** The command-line tool the pipeline uses to log in, deploy, and run tests.
- **Authoring bundle (`AiAuthoringBundle`).** The metadata that holds an Agent Script agent's definition. Deploying creates a draft. Publishing creates a version.
- **Publish and activate.** Publishing creates a version. Activating makes that version live.
- **Quality gate.** A rule that must pass before a change moves forward.
- **Integration user.** A dedicated, non-personal user the pipeline logs in as.
- **Back-merge.** Merging a fix made on one branch into the other open branches so it is not lost.
- **Value stream map.** A picture of one change's path from idea to production, with active and waiting time per step.
- **CAB (change advisory board).** The group that approves changes in many organizations.
- **DORA.** Google Cloud's research program on software delivery performance, and the source of the five delivery metrics.

---

## 13. Further reading

### Five conversations before go-live

If time is short, make sure these five questions have a named owner. Pick one or two to raise first rather than presenting all five at once.

1. **Testing.** When do tests first run on a change, and what is the pass-rate gate? Can the criteria fail?
2. **Security.** Who verified the agent user's permissions?
3. **Monitoring.** Who reviews traces and abandoned sessions weekly?
4. **Cost.** Who watches credit burn?
5. **Governance.** Who owns the change, and who owns the rollback?

### A simple meeting flow

1. **Open (5 minutes).** Explain your role and what you will and will not do. Ask the recovery-time opener.
2. **Explore (20 to 30 minutes).** Follow the pain. Walk one real recent change from idea to production. Go one layer below each symptom.
3. **Place them on the ladder (5 minutes).** Say back what you heard, in their words.
4. **Recommend (10 minutes).** Offer one or two next steps, each with a clear reason tied to a number the client cares about.
5. **Close.** Agree who does what this week, and when you will revisit.

### Books

- ***Mastering Salesforce DevOps*** by Andrew Davis. Salesforce-specific guidance on environments, branching, testing, deployment, and the change-management side of adoption. The final chapters help when a client resists tighter controls.
- ***Accelerate*** by Nicole Forsgren, Jez Humble, and Gene Kim. The research behind the DORA metrics, and the best background for why these questions matter.
- ***Flow Engineering*** by Steve Pereira and Andrew Davis. A practical guide to mapping how work flows. Use it to run the value stream part of discovery. It is not Salesforce-specific, so pair it with *Mastering Salesforce DevOps*.
- ***Salesforce DevOps for Architects*** by Lars Malmqvist and Rob Cowell. A vendor-aware overview for architects. It predates Agentforce and lists four DORA metrics, so use the five-metric version in this guide, and confirm vendor details before relying on them.

### Official Salesforce resources

- The Agent Development Lifecycle guide on the Salesforce Architects site. Start here when a client asks for official guidance.
- The Agentforce Developer Guide page "Retrieve and Deploy Agent Metadata."
- The Agentforce Developer Guide page "Test an Agent."
- Trailhead: agent testing tools and considerations, and deploying an AI service agent to staging or production.
- Trailhead: Learn to Develop Agents with Agentforce DX Tools.

### Research

- The latest DORA *Accelerate State of DevOps* report and the *State of AI-assisted Software Development* report.
- DORA's metrics guide and its test automation capability page.

---

*This guide is a consulting aid, not an implementation manual. Agent metadata and tooling change quickly. When in doubt, check current Salesforce documentation, try it in a sandbox, and recommend a specialist partner for pipeline build and security review.*
