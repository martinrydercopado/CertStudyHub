# The ADLC in an IDE: An Educational CLI Guide

*Updated August 26, 2026*
*This guide was generated using AI with grounding in official Salesforce documentation and internal FDE technical deep dive sessions. Review for accuracy before using.*

> **About this document.** This is an addendum to the AgentOps guide. That guide covers the full Agent Development Lifecycle framework, the two metadata domains, the hybrid reasoning model, and the architectural decisions behind every step. This document takes a single path through the same lifecycle using only the `sf` CLI. Every section explains why each step exists, what business risk it mitigates, and what actually happens on the platform when you run the command. It is not a command reference. It is a guided tour.

---

## Table of Contents

- [Before You Start](#before-you-start)
- [Phase 1: Ideation and Design](#phase-1-ideation-and-design)
  - [Why Design Before You Type Anything](#why-design-before-you-type-anything)
  - [Generating the Agent Spec](#generating-the-agent-spec)
  - [Generating the Authoring Bundle](#generating-the-authoring-bundle)
- [Phase 2: Development — The Inner Loop](#phase-2-development--the-inner-loop)
  - [What the Inner Loop Is and Why It Matters](#what-the-inner-loop-is-and-why-it-matters)
  - [Validating Early and Often](#validating-early-and-often)
  - [Setting Up the Einstein Agent User](#setting-up-the-einstein-agent-user)
  - [Deploying the Authoring Bundle](#deploying-the-authoring-bundle)
  - [Previewing the Agent](#previewing-the-agent)
  - [Reading Trace Files](#reading-trace-files)
  - [Provisioning a Knowledge Library — RAG Agents Only](#provisioning-a-knowledge-library--rag-agents-only)
- [Phase 3: Testing and Validation](#phase-3-testing-and-validation)
  - [Why Structured Testing Is Non-Negotiable](#why-structured-testing-is-non-negotiable)
  - [Generating a Test Spec](#generating-a-test-spec)
  - [Creating the Test in the Org](#creating-the-test-in-the-org)
  - [Running the Tests](#running-the-tests)
- [Phase 4: Deployment and Release](#phase-4-deployment-and-release)
  - [The Two Metadata Domains](#the-two-metadata-domains)
  - [The Pre-Release Gate](#the-pre-release-gate)
  - [Deploying to the Target Org](#deploying-to-the-target-org)
  - [Publishing the Authoring Bundle — Human Gate One](#publishing-the-authoring-bundle--human-gate-one)
  - [Activating the Agent — Human Gate Two](#activating-the-agent--human-gate-two)
  - [Post-Activation Verification and Rollback](#post-activation-verification-and-rollback)
- [Phase 5: Monitoring and Tuning — The Outer Loop](#phase-5-monitoring-and-tuning--the-outer-loop)
  - [Why Deployment Is Not the Finish Line](#why-deployment-is-not-the-finish-line)
  - [Querying Session Trace Data](#querying-session-trace-data)
  - [Re-entering the Inner Loop from Production Signals](#re-entering-the-inner-loop-from-production-signals)
- [Quick Reference: The Full Command Sequence](#quick-reference-the-full-command-sequence)

---

## Before You Start

**Conventions used throughout this guide.**

All commands use `--json` for structured output. In automation and CI/CD contexts this is mandatory; it gives you machine-readable output you can parse, log, and pipe. Even interactively, it prevents ambiguous human-formatted output from hiding errors in the noise. The only exception in this guide is `sf agent generate agent-spec`, which is an interactive prompt-driven command that is intentionally designed for human input and does not support `--json`. A second exception is `sf agent activate`, which may not support `--json` in all CLI versions and prints a plain-text confirmation instead — this is documented at the point of use.

Replace `<org-alias>` throughout with your target org alias, or set a default once with:

```bash
sf config set target-org <alias>
```

This guide uses `Resort_Manager` as the agent API name and `Resort_Manager_Bundle` as the authoring bundle name throughout. These come directly from the CLI reference examples. Substitute your own names wherever they appear.

---

## Phase 1: Ideation and Design

### Why Design Before You Type Anything

The ADLC documentation is clear on this point: the design phase is the most critical step for success because it translates a business need into a technical blueprint. The questions you answer here — what does the agent do, who does it serve, what can it not do, and when does it hand off to a human — directly shape every architectural decision that follows.

**Business value.** An agent that is deployed without a clear design will gradually accumulate subagents, actions, and instructions to compensate for the vagueness of its original purpose. That accumulation makes routing harder to tune, testing harder to define, and production behavior harder to reason about. Time spent on design is not overhead. It is the most cost-effective quality gate in the ADLC, because fixing a scope problem in a YAML file costs nothing, while fixing it in a published production agent costs tokens, testing cycles, change management overhead, and user trust.

**Scenario.** A team at a resort company wants to build a customer-facing agent. Without a design conversation, a developer starts adding subagents: reservations, activities, complaints, weather, spa bookings. Six months later, the agent has nineteen subagents and the routing accuracy has degraded to 71%. The fix requires redesigning the agent's routing hierarchy from scratch. A design session before development would have established three domains, a clear escalation path, and a list of things the agent deliberately does not do.

The CLI gives you a concrete artifact for the design phase: a YAML spec file. This is where design becomes code.

### Generating the Agent Spec

The agent spec is a YAML file that captures the agent's role, company context, and an LLM-generated list of topics. It is the bridge between a business conversation and a technical implementation. The LLM in your connected org generates the topics based on what you tell it, so specificity of input directly determines quality of output.

Run the interactive spec generator:

```bash
sf agent generate agent-spec
```

The command will prompt you for several fields. The most consequential are:

**Type of agent.** The CLI accepts `customer` (external-facing, runs as a dedicated service account with consistent permissions) or `internal` (internal-facing, runs as the logged-in user and respects their sharing rules). This determines the entire permission model for the agent at runtime. Getting it wrong means redesigning the access architecture later.

**Company name and description.** These are passed directly to the LLM to ground topic generation. Compare these two descriptions:

- Weak: "A hospitality company."
- Strong: "Coral Cloud Resorts provides customers with exceptional destination activities, unforgettable experiences, and reservation services, backed by a commitment to top-notch customer service."

The second produces meaningfully better topics because the LLM has context it can actually reason about.

**Agent role.** One or two sentences describing what the agent does. "The resort manager fields customer complaints, manages reservation changes, and escalates billing disputes to a live agent" is specific enough to produce useful output.

The generated file lands in `specs/Resort_Manager-agentSpec.yaml` by default. Commit this file to source control immediately. It is a design artefact, not a throwaway, and its revision history tells the story of how your agent's purpose evolved.

**Iterating the spec.** The spec is not a one-shot output. You can pass an existing spec back in and refine:

```bash
sf agent generate agent-spec \
  --spec specs/Resort_Manager-agentSpec.yaml \
  --output-file specs/Resort_Manager-agentSpec.yaml \
  --role "The resort manager handles guest complaints, reservation changes, and activity bookings, escalating billing disputes to a human agent."
```

The LLM overwrites the topic list with a new generation based on the updated role, leaving the rest of the spec intact. Repeat this until the topics accurately reflect the agent's intended scope before moving on.

You can also use `--full-interview` to be prompted for both required and optional properties including tone and the agent user username:

```bash
sf agent generate agent-spec --full-interview
```

### Generating the Authoring Bundle

Once the spec reflects your design intent, generate an authoring bundle from it. The authoring bundle is the actual development artefact: it contains a `.agent` file written in Agent Script, which is the compiled blueprint the platform uses at publish time.

```bash
sf agent generate authoring-bundle \
  --spec specs/Resort_Manager-agentSpec.yaml \
  --name "Resort Manager Bundle" \
  --target-org <org-alias>
```

What happens when you run this: the spec is sent to the org, the LLM generates an Agent Script file scaffolded around your topics, and the resulting `AiAuthoringBundle` metadata is retrieved back to your DX project under `force-app/main/default/aiAuthoringBundles/Resort_Manager_Bundle/`.

The `.agent` file now exists locally with a `config:` block, a `system:` block with persona instructions, a `start_agent:` router block, and a `topic:` block for each generated topic. This is a starting point, not a finished agent. The CLI reference is explicit about this: "The Agent Script file generated by this command is just a first draft of your agent."

**Important note on the alternative command.** There is also a `sf agent create` command. The CLI reference itself recommends against using it for new agents: "This command creates an agent that doesn't use Agent Script as its blueprint. We generally don't recommend you use this workflow." Agents created this way are less flexible and harder to maintain. Always use `agent generate authoring-bundle` as your starting point.

If you prefer to skip the spec entirely and start from boilerplate:

```bash
sf agent generate authoring-bundle \
  --no-spec \
  --name "Resort Manager Bundle" \
  --target-org <org-alias>
```

---

## Phase 2: Development — The Inner Loop

### What the Inner Loop Is and Why It Matters

The inner loop is the iterative cycle of editing the `.agent` file, validating it, deploying it, and testing it interactively. You repeat this cycle many times before anything gets published. The ADLC documentation describes development in scratch orgs as the right starting environment for this loop: "isolated, temporary environments for rapid prototyping that doesn't impact shared environments." For agents that require Data Cloud (RAG, Agentforce Data Libraries), sandboxes are preferred because scratch org support for Data Cloud requires a Partner Business Org Dev Hub.

**Business value.** The inner loop is where you surface wrong routing decisions, broken action wiring, and incorrect variable flow cheaply. Every problem caught here costs a validate-deploy-preview cycle. The same problem caught after publish costs a publish, an activate, a regression test run, and potentially a rollback. The business case for a disciplined inner loop is a direct reduction in version management overhead and production risk.

### Validating Early and Often

Validation compiles the Agent Script file and confirms it can be used to publish an agent, catching syntax errors before they cause opaque failures later. Run it any time you make a meaningful change to the `.agent` file.

```bash
sf agent validate authoring-bundle \
  --api-name Resort_Manager_Bundle \
  --target-org <org-alias>
```

When validation passes, the output confirms successful compilation. When it fails, it outputs each error with a description and a line reference in the `.agent` file.

**Why this matters.** The publish command also validates before publishing, but a publish failure is significantly more expensive to diagnose than a validate failure. Publish failures can leave metadata in partial states and are harder to recover cleanly from. Validate-first is the cheapest safety net available. In CI/CD, this should be the very first step in every pipeline run before any deployment attempt.

**Scenario.** A developer adds a new action to a subagent but misspells the target Flow name. If they skip validation and go straight to deploy and publish, the publish fails with an unhelpful error. If they run validate first, the error message identifies the exact line with the malformed target reference, and the fix takes thirty seconds.

### Setting Up the Einstein Agent User

Before live preview sessions can exercise real actions, the org needs an Einstein Agent User. This is a dedicated service account that the agent runs as at runtime. Its permission set governs what data the agent can read, write, and call. This setup applies to customer-facing (service) agents. Employee agents run as the logged-in user and do not need this service account.

**Why this matters.** The agent user's permissions are the agent's permissions. If the Apex classes the agent calls are not accessible to this user, the agent throws an "invocable action does not exist" error at runtime, even though the Flow or class exists in the org. A well-configured agent user is not an operational detail; it is a security boundary. The agent user should have only the permissions required for the agent's specific tasks, nothing more.

First, verify that an Einstein Agent license is available:

```bash
sf data query --json \
  -q "SELECT TotalLicenses, UsedLicenses FROM UserLicense WHERE Name = 'Einstein Agent'" \
  -o <org-alias>
```

If `TotalLicenses` is zero, stop here. The license gap needs to be resolved before any further work.

Check if a suitable user already exists:

```bash
sf data query --json \
  -q "SELECT Id, Username, IsActive FROM User WHERE Profile.Name = 'Einstein Agent User' AND IsActive = true" \
  -o <org-alias>
```

If none exists, get the profile ID:

```bash
sf data query --json \
  -q "SELECT Id FROM Profile WHERE Name = 'Einstein Agent User'" \
  -o <org-alias>
```

**The user creation command differs by org type.** `sf org create user` only works in scratch orgs. For production and sandbox orgs, it fails with an authorization error. Use the right command for your environment.

For scratch orgs, create a user definition file at `config/einstein-agent-user.json`:

```json
{
  "Username": "resort_manager_agent@<orgId>.ext",
  "LastName": "Resort Manager Agent",
  "Email": "noreply@example.com",
  "Alias": "agntuser",
  "ProfileId": "<profile-id-from-above>",
  "TimeZoneSidKey": "America/Los_Angeles",
  "LocaleSidKey": "en_US",
  "EmailEncodingKey": "UTF-8",
  "LanguageLocaleKey": "en_US",
  "UserPermissionsKnowledgeUser": true
}
```

Then create the user:

```bash
sf org create user --json \
  --definition-file config/einstein-agent-user.json \
  -o <org-alias>
```

For production and sandbox orgs, skip the definition file and create the record directly:

```bash
sf data create record --json --sobject User \
  --values "Username='resort_manager_agent@<orgId>.ext' LastName='Resort Manager Agent' Email='noreply@example.com' Alias='agntuser' ProfileId='<PROFILE_ID>' TimeZoneSidKey='America/Los_Angeles' LocaleSidKey='en_US' EmailEncodingKey='UTF-8' LanguageLocaleKey='en_US'" \
  -o <org-alias>
```

Assign the required permission sets. The `AgentforceServiceAgentUser` system permission set is mandatory for all service agents and must be assigned before publishing — publishing without it fails with "Internal Error." The custom `Resort_Manager_Access` permission set grants the agent user access to the specific Apex classes your agent calls:

```bash
sf org assign permset --json \
  --name AgentforceServiceAgentUser \
  --on-behalf-of resort_manager_agent@<orgId>.ext \
  -o <org-alias>

sf org assign permset --json \
  --name Resort_Manager_Access \
  --on-behalf-of resort_manager_agent@<orgId>.ext \
  -o <org-alias>
```

**Always verify that assignments actually landed.** The API can report success while the assignment silently rolls back inside a transaction. Do not trust the response code; query the assignment record directly:

```bash
sf data query --json \
  -q "SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE Assignee.Username = 'resort_manager_agent@<orgId>.ext'" \
  -o <org-alias>
```

Both `AgentforceServiceAgentUser` and `Resort_Manager_Access` must appear in the results before you proceed.

**A documented real-world failure.** Testing of the ORM1 agent revealed that Salesforce auto-generates a `NextGen_ORM1_Permissions` permission set when an agent is published. In that case, the auto-generated set included only 3 of the 4 required Apex classes, silently omitting `ShipmentTracker`. The agent threw "invocable action track_delivery does not exist" at runtime for shipment tracking. The fix was creating a custom `ORM1_Access` permission set with explicit entries for all four classes. Never rely on auto-generated permission sets; always create and maintain your own.

**The `WITH USER_MODE` gotcha.** If any of your Apex classes use `WITH USER_MODE` in their SOQL queries, class-level access in the permission set is not sufficient. `WITH USER_MODE` enforces object-level permissions on the running user — in this case the Einstein Agent User — at query time. Missing object permissions fail silently: the query returns 0 rows with no error, no exception, and no log entry that points to the cause.

The diagnostic signal is specific: if live preview returns empty results where simulated preview works correctly, object permissions on the Einstein Agent User profile are the most likely cause. Fix it by adding `<objectPermissions>` entries to your custom permission set XML alongside the `<classAccesses>`:

```xml
<objectPermissions>
    <allowRead>true</allowRead>
    <object>Vehicle__c</object>
</objectPermissions>
```

Add one block for each object the agent user needs to read. Then redeploy the permission set and retest.

### Deploying the Authoring Bundle

Deploying puts the `AiAuthoringBundle` metadata into the org. This is not the same as publishing. The deployed agent exists as editable draft metadata. No runtime entities are created, and the agent cannot be activated yet.

**Why deploy exists separately from publish.** This separation gives you a safe, iterable state. You can deploy, preview, find a problem, edit the `.agent` file, redeploy, and preview again as many times as needed, without incurring the version management overhead of publish. Once you publish, the version is locked permanently.

Deploy supporting metadata first, in this order: custom objects and fields, Apex `@InvocableMethod` classes, Autolaunched Flows, GenAiFunction metadata. Then deploy the bundle:

```bash
sf project deploy start --json \
  --metadata "AiAuthoringBundle:Resort_Manager_Bundle" \
  -o <org-alias>
```

Or deploy everything from a full manifest:

```bash
sf project deploy start --json \
  --manifest manifest/package.xml \
  -o <org-alias>
```

### Previewing the Agent

Preview is the primary testing surface during the inner loop. The CLI reference describes it clearly: "previewing an agent acts like an initial test to make sure it responds to your utterances as you expect." You can test that the agent routes to the correct subagent for a given question, and that it then invokes the correct action.

There are two modes. Choose based on what you are testing.

**Simulated mode** uses only the Agent Script file and uses AI to simulate action execution without calling real implementations. Use this when Apex classes, Flows, or Prompt Templates are not yet deployed, or when you are focused on routing logic and instructions:

```bash
sf agent preview start --json \
  --authoring-bundle Resort_Manager_Bundle \
  --simulate-actions \
  -o <org-alias>
```

**Live mode** executes real Apex classes, Flows, and other actions in the org. Use this when you need to validate actual action outputs, variable propagation from real data, and grounding behavior:

```bash
sf agent preview start --json \
  --authoring-bundle Resort_Manager_Bundle \
  --use-live-actions \
  -o <org-alias>
```

Both modes return a session ID in the JSON output. Copy it. Every subsequent command in this session requires it.

Send an utterance to the running session:

```bash
sf agent preview send --json \
  --authoring-bundle Resort_Manager_Bundle \
  --session-id <SESSION_ID> \
  --utterance "I'd like to change my reservation for next weekend" \
  -o <org-alias>
```

Walk through each routing branch with targeted utterances. When you are done:

```bash
sf agent preview end --json \
  --authoring-bundle Resort_Manager_Bundle \
  --session-id <SESSION_ID> \
  -o <org-alias>
```

**Common mistakes to avoid.**

The `--simulate-actions` and `--use-live-actions` flags are set only on `start`. Do not pass them to `send` or `end`.

`--authoring-bundle` and `--api-name` are mutually exclusive. Use `--authoring-bundle` for the draft agent during the inner loop. Use `--api-name` only after publishing, to preview an activated published agent.

Always pass `--session-id` on `send` and `end`. If an agent has more than one active session and you omit the session ID, the command errors. Use `sf agent preview sessions` to list all active sessions if you lose track:

```bash
sf agent preview sessions
```

### Reading Trace Files

After preview sessions, trace files are captured locally. These are your debugging tool during the inner loop. They record what the agent actually did: which subagent was selected, which actions were called, what variables held, and where errors occurred.

List available trace files:

```bash
sf agent trace list
```

Read a session at summary level:

```bash
sf agent trace read --session-id <SESSION_ID>
```

Drill into a specific turn:

```bash
sf agent trace read --session-id <SESSION_ID> --turn 2
```

Focus on a specific dimension:

```bash
# Subagent routing decisions
sf agent trace read --session-id <SESSION_ID> --format detail --dimension routing

# Actions called and their outcomes
sf agent trace read --session-id <SESSION_ID> --format detail --dimension actions

# Errors only
sf agent trace read --session-id <SESSION_ID> --format detail --dimension errors
```

Get raw JSON for piping to `jq`:

```bash
sf agent trace read --session-id <SESSION_ID> --format raw | jq '.turns[0].routing'
```

**How to interpret what you find.** Routing errors — where the wrong subagent is selected — are almost always caused by subagent classification description problems. The AgentOps guide is direct on this point: a subagent is selected solely based on its name and its classification description. If you are seeing wrong-subagent routing, rewriting its instructions will not fix it. Rewrite the classification description to be specific, distinct, and free of overlap with other subagents' descriptions.

Action errors — where a called action fails or returns no data — typically mean either that the Flow or Apex class is not deployed, that the action target name in the `.agent` file does not exactly match the API name in the org, or that the Einstein Agent User lacks the required permission to call it.

Clean up trace files when they accumulate:

```bash
sf agent trace delete --session-id <SESSION_ID>
```

### Provisioning a Knowledge Library — RAG Agents Only

If your agent uses a `knowledge:` block for grounded retrieval — meaning it answers questions by searching an indexed knowledge source rather than relying solely on the LLM's training — you need an Agentforce Data Library provisioned before publish. Skip this section entirely if your agent does not use knowledge grounding.

**Why this matters.** RAG is the mechanism that makes an agent's answers trustworthy for your specific business context. An agent without RAG answers from the LLM's training data, which knows nothing about your products, policies, or procedures. An agent with RAG retrieves the relevant content from your indexed sources and grounds its answer in that content. The quality of that grounding depends on how the library is created and indexed, which is why the provisioning steps below are sequenced the way they are.

Create the library. The `--developer-name` is the API name (alphanumeric and underscores, must start with a letter) and is required. The `--name` is the display label and is also required. The `--source-type` flag accepts lowercase values only: `sfdrive`, `knowledge`, or `retriever`.

```bash
sf agent adl create \
  --developer-name Resort_Policies \
  --name "Resort Policies" \
  --source-type sfdrive \
  --target-org <org-alias>
```

The command returns a library ID starting with `1JD`. Save it. You will need it for every subsequent ADL command.

**The critical distinction between `adl upload` and `adl file add`.** For a freshly created `sfdrive` library, the first file load must use `sf agent adl upload`. This command performs the full multi-step provisioning workflow: it checks upload readiness, obtains a pre-signed S3 URL, uploads the file, and triggers the Data Cloud pipeline that creates all downstream assets in sequence (DLO, DMO, SearchIndex, Retriever). A newly created library has none of those assets yet. `sf agent adl file add` attaches to an already-provisioned pipeline and will silently do nothing against a library that has not yet completed initial provisioning. Use the right command for the right stage.

Upload the initial file and wait for the pipeline to complete:

```bash
sf agent adl upload \
  --library-id 1JDSG000007IbWX4A0 \
  --file ./docs/resort-policies.pdf \
  --wait 10 \
  -o <org-alias>
```

The `--wait 10` flag blocks the command for up to ten minutes, polling until the library is ready. If you omit it, the command returns immediately after triggering indexing and you need to poll status manually.

Monitor pipeline progress at any time:

```bash
sf agent adl status \
  --library-id 1JDSG000007IbWX4A0 \
  -o <org-alias>
```

The status output shows each pipeline stage: `DATA_STREAM`, `DATA_LAKE_OBJECT`, `DATA_MODEL_OBJECT`, `SEARCH_INDEX`, and `RETRIEVER`. The library is ready when all stages complete without errors. To confirm the retriever ID that will be wired into your agent's `knowledge:` block, use `adl get`, which returns the library's full detail including its `retrieverId`:

```bash
sf agent adl get \
  --library-id 1JDSG000007IbWX4A0 \
  -o <org-alias>
```

**Adding files to an already-provisioned library.** Once the library is READY and has a `retrieverId`, subsequent files use `adl file add`:

```bash
sf agent adl file add \
  --library-id 1JDSG000007IbWX4A0 \
  --path ./docs/spa-menu.pdf \
  -o <org-alias>
```

You can also list the files currently in a library and filter by indexing status:

```bash
sf agent adl file list \
  --library-id 1JDSG000007IbWX4A0 \
  --status indexed \
  -o <org-alias>
```

**For `knowledge` libraries** (Salesforce Knowledge articles), indexing starts automatically after creation. You can pass `--wait` directly on `adl create`:

```bash
sf agent adl create \
  --developer-name Resort_KB \
  --name "Resort Knowledge Base" \
  --source-type knowledge \
  --wait 5 \
  -o <org-alias>
```

**Data Cloud permission for the Einstein Agent User.** If your agent has a `knowledge:` block, the Einstein Agent User also needs a Data Cloud permission set or permission set license. Which one exists depends on org shape and platform release; hardcoding a single name fails on at least one org shape. Discover what is available first, then assign:

```bash
# Check for the PSL form (preferred):
sf data query --json \
  -q "SELECT DeveloperName FROM PermissionSetLicense WHERE DeveloperName = 'GenieDataPlatformStarterPsl' LIMIT 1" \
  -o <org-alias>

# Check for the PS form(s):
sf data query --json \
  -q "SELECT Name, Label FROM PermissionSet WHERE Name IN ('GenieUserEnhancedSecurity', 'DataCloudUser', 'DataCloudArchitect')" \
  -o <org-alias>
```

Assign using the priority order: `GenieDataPlatformStarterPsl` (PSL) first, then `GenieUserEnhancedSecurity`, then `DataCloudUser`, and `DataCloudArchitect` only as a last resort — it is an admin-level permission set that is over-privileged for an agent user but functional if nothing else exists. Use `sf org assign permsetlicense` for PSL forms and `sf org assign permset` for PS forms. Then verify the assignment actually landed by querying the assignment record directly, as described in the Einstein Agent User setup section above. PSL assignments use a different SObject:

```bash
sf data query --json \
  -q "SELECT PermissionSetLicense.DeveloperName FROM PermissionSetLicenseAssign WHERE Assignee.Username = 'resort_manager_agent@<orgId>.ext'" \
  -o <org-alias>
```

**Data Space scope — UI-only fallback.** Some org shapes require a separate Data Space scope grant on the assigned permset, beyond the assignment itself. There is currently no API for this step; it must be done in Setup UI. You only need it if the Data Cloud permission assignment completed successfully but grounded queries still return empty `knowledgeSummary` at runtime:

> Setup > Permission Sets > click the assigned Data Cloud permset > "Data Cloud Data Space Management" under the Apps section > Edit > add the ADL's data space (typically `default`) to the Enabled Data Spaces list > Save.

The data space ID can be found via:

```bash
sf data query --json -q "SELECT Id, DeveloperName FROM DataSpace" -o <org-alias>
```

After granting the scope, retest with a grounded utterance. The agent should now return populated `knowledgeSummary`.

---

## Phase 3: Testing and Validation

### Why Structured Testing Is Non-Negotiable

With a Flow or Apex trigger, you can inspect the full execution path. It ran or it did not. The output is deterministic and inspectable. With an agent, you see inputs and outputs; what happened between them was inferred by the LLM, varies by context, and cannot be exactly replicated.

The AgentOps guide draws three direct consequences from this:

First, UAT is not testing. A team clicking through ten scenarios before go-live is sampling. The edge cases real users encounter in week one are not the scenarios the team imagined in a conference room.

Second, behavior degrades silently. A broken Flow throws an exception. An agent that has drifted gives plausible-but-wrong answers until someone notices. Nothing alerts. Nothing logs an error.

Third, regression is not free. When you update any part of an agent, you cannot assume the rest still works. Every publish requires re-validation of the full behavior surface.

**Business value.** The Testing Center is free in sandbox. A test suite with a defined pass-rate threshold that must be met before any release becomes a governance input that strengthens your change management process rather than competing with it. For regulated industries especially, "the automated test suite passed at 94%" is a significantly stronger change request justification than "we reviewed it."

### Generating a Test Spec

The test spec is a YAML file that defines your test cases in a format the Testing Center understands. Generate it interactively:

```bash
sf agent generate test-spec
```

The command uses the metadata components in your DX project when prompting — not the org — so run it from your project root with the bundle already retrieved locally. It walks you through each test case, prompting for:

**Utterance.** The natural-language input. Write it the way a real user would actually type it. "I need to change my booking for Saturday" is realistic. "Invoke reservation modification subagent" is not.

**Expected topic.** The API name of the subagent you expect to handle this utterance. This validates routing. Getting routing right is typically the highest-priority testing objective because routing failures cascade: if the wrong subagent is selected, every action, every instruction, and every variable in that subagent is executing in the wrong context.

**Expected actions.** The API names of actions you expect the agent to call. A critical technical point: these must be the Level 2 invocation names from the `reasoning: actions:` block in your `.agent` file, not the Level 1 action definition names. The two have different API names. The wrong name produces a test case that always fails even when the agent behavior is correct.

**Expected outcome.** A specific, falsifiable description of what should happen. "The agent asks for the customer's reservation number before attempting any lookup" is testable. "The agent is helpful and professional" is not.

Repeat for each test case. The generated file lands in `specs/Resort_Manager-testSpec.yaml`.

For Agentforce Studio (NGT) test format:

```bash
sf agent generate test-spec --test-runner agentforce-studio
```

You can also add `contextVariables` manually to the YAML after generation. This is how you inject session context for test cases that require a pre-existing variable state — for example, testing the Order Management subagent when `verified == True` is a precondition.

### Creating the Test in the Org

Before deploying, you can preview what the test metadata will look like without actually creating it in the org:

```bash
sf agent test create \
  --spec specs/Resort_Manager-testSpec.yaml \
  --api-name Resort_Manager_Test \
  --preview \
  -o <org-alias>
```

This writes the `AiEvaluationDefinition` XML to disk locally. Review it to confirm the structure before committing.

When ready, create the test in the org:

```bash
sf agent test create \
  --spec specs/Resort_Manager-testSpec.yaml \
  --api-name Resort_Manager_Test \
  --force-overwrite \
  -o <org-alias>
```

`--force-overwrite` suppresses the confirmation prompt when updating an existing test definition with the same API name. Useful during iteration when you are adding and refining test cases. The command retrieves the resulting `AiEvaluationDefinition` XML back to your local project when it completes.

List existing tests in the org at any time:

```bash
sf agent test list -o <org-alias>
```

### Running the Tests

The agent must be published and activated before `sf agent test run` will work against it. During the inner loop, use `agent preview` for interactive testing against the draft bundle. The formal test run executes against an activated published agent — meaning the version users are actually interacting with.

```bash
sf agent test run --json \
  --api-name Resort_Manager_Test \
  --wait 5 \
  -o <org-alias>
```

`--wait 5` tells the command to poll for up to five minutes and return results inline. Without it, the command returns a job ID immediately and exits:

```bash
sf agent test results \
  --job-id <JOB_ID> \
  -o <org-alias>
```

For CI/CD pipelines, use JUnit format so results integrate with your pipeline's test reporting:

```bash
sf agent test run \
  --api-name Resort_Manager_Test \
  --result-format junit \
  -o <org-alias>
```

Use `--verbose` to see the detailed actions that were actually invoked during each test case. This is the primary tool for diagnosing test failures where the utterance routed correctly but the action sequence differed from expectations:

```bash
sf agent test run --json \
  --api-name Resort_Manager_Test \
  --verbose \
  --wait 5 \
  -o <org-alias>
```

A test job supports up to 500 test cases per run. Keep individual batches in the 20-30 case range for optimal performance and to avoid rate limits; the Testing Center allows a maximum of 10 jobs per hour. Evaluate the pass rate against your defined threshold before proceeding to publish. Define that threshold before you build the test suite, not after you see the results.

---

## Phase 4: Deployment and Release

### The Two Metadata Domains

Understanding why the release steps are sequenced the way they are requires understanding that Agentforce agents exist in two completely separate metadata domains.

The **authoring domain** is where developers work. It contains the `AiAuthoringBundle` — the Agent Script `.agent` file and its metadata XML. This is the editable, version-controllable source of truth. Deploying the authoring bundle puts this in the org as a draft.

The **runtime domain** is created by publishing. It contains `Bot`, `BotVersion`, and `GenAiPlannerBundle` — the compiled runtime entities the platform executes. These are created by the publish command and are immutable once created. You cannot edit a published version.

Deploy creates content in the authoring domain. Publish compiles the authoring domain into the runtime domain. Activate makes one runtime version live. These are three distinct, sequenced operations and they cannot be reordered.

### The Pre-Release Gate

Before running any release commands in a shared or production environment, every item on this list must be true:

- `sf agent validate authoring-bundle` passes with zero errors.
- All action targets — Flows, Apex classes, Prompt Templates — are confirmed present in the target org.
- Preview testing with realistic utterances has covered all routing branches.
- The test suite pass rate meets your defined threshold.
- The Einstein Agent User is configured with the correct permission sets, verified by querying the assignment records.
- The `AiAuthoringBundle` is committed to source control, peer-reviewed, and merged.

Nothing proceeds until all of these are satisfied. For regulated industries, this checklist is not a workflow convenience. It is the minimum viable audit trail demonstrating that a human reviewed the change before it reached users.

### Deploying to the Target Org

Deploy supporting metadata first (same ordering as the inner loop: custom objects, Apex, Flows, GenAiFunction), then the authoring bundle.

```bash
sf project deploy start --json \
  --manifest manifest/package.xml \
  -o <org-alias>
```

For environment-specific values — agent user usernames differ across orgs — use DX string replacement in `sfdx-project.json` rather than hardcoding values:

```json
{
  "replacements": [
    {
      "filename": "force-app/main/default/bots/Resort_Manager/Resort_Manager.bot-meta.xml",
      "stringToReplace": "resort_manager_agent@source.org",
      "replaceWithEnv": "TARGET_AGENT_USER"
    }
  ]
}
```

Pass the value at deploy time through the environment:

```bash
TARGET_AGENT_USER=resort_manager_agent@<target-orgId>.ext \
  sf project deploy start --json --manifest manifest/package.xml -o <org-alias>
```

**Scenario.** A team deploys the same authoring bundle to three environments: a staging sandbox, a UAT sandbox, and production. The Einstein Agent User username is different in each org. Without string replacement, the team either maintains three separate metadata files (a versioning nightmare) or hardcodes the production username and corrects it manually before each staging deploy (an error-prone manual step). String replacement with an environment variable solves this cleanly.

### Publishing the Authoring Bundle — Human Gate One

This is the first human gate. Publishing compiles the Agent Script file, creates the runtime metadata (`Bot`, `BotVersion`, `GenAiPlannerBundle`), and locks that version permanently. There is no unpublish. The CLI documentation states this clearly: "If there are compilation errors, the command exits and you must fix the Agent Script file to continue. Once the Agent Script file compiles, then it's published to the org, which creates new associated metadata."

Do not run this command until a named human has explicitly approved it. In a CI/CD pipeline, this is the point where an approval gate should pause the pipeline for human review.

```bash
sf agent publish authoring-bundle \
  --api-name Resort_Manager_Bundle \
  --target-org <org-alias>
```

Use `--verbose` to see every metadata component retrieved and deployed during the publish operation:

```bash
sf agent publish authoring-bundle \
  --api-name Resort_Manager_Bundle \
  --verbose \
  --target-org <org-alias>
```

When publish completes, the org contains a new committed version. The runtime metadata exists, but the agent is not yet live. The prior active version, if any, remains active until you explicitly activate the new one. Users are not affected yet.

### Activating the Agent — Human Gate Two

This is the second human gate. Activation makes the new version live and immediately deactivates the prior active version. In a production org, this must be a pre-approved, named-person action — documented in your change record.

**Business value.** The separation of publish and activate is a deliberate safety mechanism. It means a new version can be published, validated with post-publish preview, and have its regression test suite run, all before it touches a single live user. The window between publish and activate is your last chance to catch something before it matters.

If you do not specify a version, the command prompts you interactively:

```bash
sf agent activate \
  --api-name Resort_Manager \
  -o <org-alias>
```

Or specify exactly. The `--version` number corresponds to the `vX` in your local BotVersion metadata file name — for example, `v2.botVersion-meta.xml` means `--version 2`:

```bash
sf agent activate \
  --api-name Resort_Manager \
  --version 2 \
  -o <org-alias>
```

> **Note on `--json`.** The universal `--json` convention used throughout this guide has one exception here: `sf agent activate` may not support `--json` in all CLI versions and prints a plain-text confirmation instead. Do not pass `--json` to this command without first confirming it is supported in the CLI version your pipeline uses. To verify activation independently of the command output, query the BotVersion status directly:
>
> ```bash
> sf data query --json \
>   -q "SELECT Id, DeveloperName, Status FROM BotVersion WHERE BotDefinition.DeveloperName = 'Resort_Manager' ORDER BY CreatedDate DESC LIMIT 1" \
>   -o <org-alias>
> ```
>
> The expected result is `Status = 'Active'`.

Only one version can be active at a time. To open the agent in the Builder UI for a visual confirmation:

```bash
sf org open agent --api-name Resort_Manager -o <org-alias>
```

### Post-Activation Verification and Rollback

After activation, run a final preview against the published agent — not the authoring bundle — to confirm the version users will interact with behaves as expected. Note the flag change: you now use `--api-name`, not `--authoring-bundle`:

```bash
sf agent preview start --json \
  --api-name Resort_Manager \
  -o <org-alias>
```

Send realistic utterances through each major routing branch before declaring the release complete.

Then run the full regression test suite against the activated version:

```bash
sf agent test run --json \
  --api-name Resort_Manager_Test \
  --wait 10 \
  -o <org-alias>
```

**Rollback.** If something goes wrong after activation, reactivate the prior committed version. Do not wait for a new change request. Have the version number ready before every production release.

Deactivate the current version:

```bash
sf agent deactivate \
  --api-name Resort_Manager \
  -o <org-alias>
```

Activate the prior version:

```bash
sf agent activate \
  --api-name Resort_Manager \
  --version 1 \
  -o <org-alias>
```

**First-release warning.** If this is the initial release, there is no prior committed version to roll back to. The pre-release gate is not optional for release zero. The AgentOps guide recommends documenting and verifying the rollback command in staging before every production release, including the first one.

---

## Phase 5: Monitoring and Tuning — The Outer Loop

### Why Deployment Is Not the Finish Line

The ADLC documentation is explicit: "ADLC is a continuous cycle; deployment isn't the end. Agents are living systems that require constant monitoring to track metrics like latency, cost, and success rates."

This matters because agents fail differently from traditional software. A broken Flow throws an exception and stops executing. An agent that has drifted, been confused by a new product name, or is routing incorrectly continues to respond confidently with wrong answers. There is no error log. There is no alert. The degradation is silent until a human notices it through outcome data.

**Business value.** The Agentforce Session Tracing Data Model (STDM) captures every logged event within a session: turn-by-turn interactions, reasoning engine executions, actions and their inputs and outputs, error messages, and final responses. This data enables systematic identification of where the agent is failing, which topics produce the lowest quality scores, and which utterances consistently route to the wrong subagent. The outer loop is not maintenance. It is the primary mechanism for making the agent more valuable over time.

### Querying Session Trace Data

The primary monitoring surface is Data 360's Agentforce Analytics dashboards. For targeted investigation during an incident or after a specific user complaint, you can query session data directly from the CLI.

Query recent sessions:

```bash
sf data query --json \
  -q "SELECT Id, CreatedDate FROM AiAgentSession WHERE CreatedDate = LAST_N_DAYS:7" \
  -o <org-alias>
```

Look at interaction-level success data for today:

```bash
sf data query --json \
  -q "SELECT Id, SessionId, IsSuccess FROM AiAgentInteraction WHERE AiAgentSession.CreatedDate = TODAY" \
  -o <org-alias>
```

The STDM structures data across five primary objects: `AiAgentSession` (the overarching container), `AiAgentSessionParticipant` (the entities involved), `AiAgentInteraction` (a single request-response segment), `AiAgentInteractionStep` (a discrete action within an interaction), and `AiAgentInteractionMessage` (a single message). You can join across these to reconstruct any session in detail.

### Re-entering the Inner Loop from Production Signals

When monitoring reveals a gap — routing accuracy has dropped, a specific action is failing, or grounded responses are returning empty — the fix follows a defined path:

1. Edit the `.agent` file to address the specific issue.
2. Validate locally: `sf agent validate authoring-bundle`.
3. Deploy: `sf project deploy start`.
4. Preview with targeted utterances that reproduce the production failure: `sf agent preview start --use-live-actions`.
5. Read traces to confirm the fix: `sf agent trace read`.
6. When the fix is confirmed through preview, follow the full publish and activation sequence again, including the human gates.

This is the outer loop. The deploy-to-activate sequence is not a one-time event. It is the cadence of continuous improvement.

**Iterating the test suite.** Every outer loop iteration should expand the regression suite. Real production sessions are the best source of edge cases you would never have written manually. Add a test case for every failure mode you discover in production:

```bash
sf agent test create \
  --spec specs/Resort_Manager-testSpec.yaml \
  --api-name Resort_Manager_Test \
  --force-overwrite \
  -o <org-alias>
```

The goal is a test suite that grows with the agent's operational history. A test suite that only covers the scenarios the team thought of at launch is a shrinking safety net as the agent's user base expands.

---

## Quick Reference: The Full Command Sequence

This is the complete ordered sequence from new agent to monitored production deployment. Human gates are marked explicitly.

```bash
# ── PHASE 1: DESIGN ──────────────────────────────────────────────────────────
sf agent generate agent-spec
sf agent generate authoring-bundle \
  --spec specs/agentSpec.yaml \
  --name "Resort Manager Bundle" \
  -o <dev-org>

# ── PHASE 2: INNER LOOP (repeat until ready) ─────────────────────────────────

# Validate the Agent Script file before every deploy
sf agent validate authoring-bundle \
  --api-name Resort_Manager_Bundle -o <dev-org>

# Deploy supporting metadata first, then the bundle
sf project deploy start --json \
  --metadata "AiAuthoringBundle:Resort_Manager_Bundle" -o <dev-org>

# Preview: simulated (routing/logic focus) or live (action validation)
sf agent preview start --json \
  --authoring-bundle Resort_Manager_Bundle \
  --simulate-actions -o <dev-org>                     # or --use-live-actions

sf agent preview send --json \
  --authoring-bundle Resort_Manager_Bundle \
  --session-id <ID> --utterance "utterance text" -o <dev-org>

sf agent trace read --session-id <ID> --format detail --dimension routing

sf agent preview end --json \
  --authoring-bundle Resort_Manager_Bundle \
  --session-id <ID> -o <dev-org>

# ── PHASE 2: KNOWLEDGE LIBRARY (RAG agents only) ─────────────────────────────

sf agent adl create \
  --developer-name Resort_Policies \
  --name "Resort Policies" \
  --source-type sfdrive -o <dev-org>

# Initial load — triggers the full DLO/DMO/SearchIndex/Retriever pipeline
sf agent adl upload \
  --library-id 1JDSG000007IbWX4A0 \
  --file ./docs/resort-policies.pdf \
  --wait 10 -o <dev-org>

sf agent adl status --library-id 1JDSG000007IbWX4A0 -o <dev-org>
sf agent adl get --library-id 1JDSG000007IbWX4A0 -o <dev-org>  # confirm retrieverId

# Day-2 additions to an already-provisioned (READY) library use file add:
# sf agent adl file add --library-id 1JDSG... --path ./docs/new-file.pdf -o <dev-org>

# ── PHASE 3: TESTING ─────────────────────────────────────────────────────────
sf agent generate test-spec

sf agent test create \
  --spec specs/Resort_Manager-testSpec.yaml \
  --api-name Resort_Manager_Test \
  --force-overwrite -o <dev-org>

sf agent test run --json \
  --api-name Resort_Manager_Test \
  --wait 5 -o <dev-org>

# ── PHASE 4: RELEASE ─────────────────────────────────────────────────────────

# CI gate: validate before touching the target org
sf agent validate authoring-bundle \
  --api-name Resort_Manager_Bundle -o <target-org>

# Deploy all metadata in order
sf project deploy start --json \
  --manifest manifest/package.xml -o <target-org>

# *** HUMAN GATE 1: review, confirm test results, approve publish ***
sf agent publish authoring-bundle \
  --api-name Resort_Manager_Bundle \
  --target-org <target-org>

# Post-publish preview to verify before going live
sf agent preview start --json \
  --api-name Resort_Manager -o <target-org>

# *** HUMAN GATE 2: named person approves activation ***
# Note: --json may not be supported in all CLI versions for this command
sf agent activate \
  --api-name Resort_Manager \
  --version 2 -o <target-org>

# Verify activation independently of command output
sf data query --json \
  -q "SELECT Status FROM BotVersion WHERE BotDefinition.DeveloperName = 'Resort_Manager' ORDER BY CreatedDate DESC LIMIT 1" \
  -o <target-org>

# Post-activation regression
sf agent test run --json \
  --api-name Resort_Manager_Test \
  --wait 10 -o <target-org>

# ── ROLLBACK (if needed) ─────────────────────────────────────────────────────
sf agent deactivate --api-name Resort_Manager -o <target-org>
sf agent activate --api-name Resort_Manager --version 1 -o <target-org>
```
