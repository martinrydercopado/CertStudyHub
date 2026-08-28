# AgentOps with Copado: A Success Architect's Guide
## Version 10

---

## Table of Contents

- [Introduction](#introduction)
- [Section 1: AgentOps as an Agentia Pro Pipeline Discipline](#section-1-agentops-as-an-agentia-pro-pipeline-discipline)
- [Section 2: What Agentia Pro Tracks as Metadata](#section-2-what-agentia-pro-tracks-as-metadata)
- [Section 3: Source Control and the Commit Changes Page](#section-3-source-control-and-the-commit-changes-page)
  - [Version Control Discipline](#version-control-discipline)
  - [The Copado Branching Strategy](#the-copado-branching-strategy)
- [Section 4: AI-Assisted Development and the Audit Trail](#section-4-ai-assisted-development-and-the-audit-trail)
- [Section 5: Agent Script in the Pipeline Context](#section-5-agent-script-in-the-pipeline-context)
- [Section 6: Multi-Agent Orchestration (SOMA) in Agentia Pro](#section-6-multi-agent-orchestration-soma-in-agentia-pro)
  - [Projects and Release Records](#projects-and-release-records)
  - [User Story Dependencies: Visibility, Not Enforcement](#user-story-dependencies-visibility-not-enforcement)
  - [Designing for Safe Parallel Development](#designing-for-safe-parallel-development)
  - [When and How to Use Parallel Pipelines](#when-and-how-to-use-parallel-pipelines)
- [Section 7: Environment Strategy and Pipeline Structure](#section-7-environment-strategy-and-pipeline-structure)
  - [The Reference Pipeline: Four Stages](#the-reference-pipeline-four-stages)
  - [Pipeline Connection Model](#pipeline-connection-model)
  - [Pipeline Environment Variables](#pipeline-environment-variables)
  - [Agentforce-Specific Environment Checklist](#agentforce-specific-environment-checklist)
  - [Environment Discipline](#environment-discipline)
  - [Keeping Environments Aligned: Back Promotions and Environment Sync](#keeping-environments-aligned-back-promotions-and-environment-sync)
  - [Rollback Configuration](#rollback-configuration)
  - [Scratch Orgs: When to Use Them](#scratch-orgs-when-to-use-them)
- [Section 8: Change Management in Agentia Pro](#section-8-change-management-in-agentia-pro)
  - [Structuring User Stories for Agent Delivery](#structuring-user-stories-for-agent-delivery)
  - [Promotion Cadence and Batch Size](#promotion-cadence-and-batch-size)
  - [Base Branch Handling: Preventing Duplicate Commits](#base-branch-handling-preventing-duplicate-commits)
  - [Extending the Pipeline: Deployment Steps and Copado Functions](#extending-the-pipeline-deployment-steps-and-copado-functions)
  - [Conflict Resolution in Agentia Pro](#conflict-resolution-in-agentia-pro)
  - [User Story Status Model](#user-story-status-model)
  - [Agentia Pro as the Audit Trail](#agentia-pro-as-the-audit-trail)
  - [Change Management Guardrails](#change-management-guardrails)
- [Section 9: Regulated Industry Delivery Framework](#section-9-regulated-industry-delivery-framework)
- [Section 10: Security and the Agent User in Agentia Pro](#section-10-security-and-the-agent-user-in-agentia-pro)
- [Section 11: Testing Your Agent with Copado](#section-11-testing-your-agent-with-copado)
  - [The Testing Pyramid: Three Explicit Layers](#the-testing-pyramid-three-explicit-layers)
  - [The Definition of Done](#the-definition-of-done)
  - [Connecting Testing Center Results to the Agentia Pro Pipeline](#connecting-testing-center-results-to-the-agentia-pro-pipeline)
  - [Agentia Testing: Recognizing Existing Coverage](#agentia-testing-recognizing-existing-coverage)
  - [The CopadoAI Testing Library](#the-copadoai-testing-library)
  - [Apex Test Coverage Requirements](#apex-test-coverage-requirements)
- [Section 12: Deployment and Metadata](#section-12-deployment-and-metadata)
  - [Deployment Tooling](#deployment-tooling)
  - [Deployment Scope Requirement](#deployment-scope-requirement)
  - [Deployment Order](#deployment-order)
  - [Deployment Steps](#deployment-steps)
  - [Pre-Release Gate Checklist](#pre-release-gate-checklist)
  - [Copado Environment Setup for Agentforce](#copado-environment-setup-for-agentforce)
  - [Keeping Copado Packages Up to Date](#keeping-copado-packages-up-to-date)
  - [Support and Community](#support-and-community)
- [Section 13: Pricing](#section-13-pricing)
- [Section 14: Monitoring and Closing the Loop](#section-14-monitoring-and-closing-the-loop)
- [Section 15: Agentia Pro Plan Objects: Applied to Agentforce Delivery](#section-15-agentia-pro-plan-objects-applied-to-agentforce-delivery)
- [Section 16: Cost Optimization Reference](#section-16-cost-optimization-reference)
- [Appendix A: Quick Reference: Copado + AgentOps Standards](#appendix-a-quick-reference-copado--agentops-standards)

---

## Introduction

This guide is for architects who already know Agentforce: how agents are authored, how Agent Script works, how the Testing Center and session tracing operate. The focus here is on everything Copado adds to that foundation: the pipeline discipline, source control model, environment strategy, quality gates, and change management practices that turn a working agent prototype into a governed, production-grade delivery operation.

### Where to Get Help

- **Copado documentation:** [https://docs.copado.com/](https://docs.copado.com/) — source of truth for all product-specific configuration.
- **Copado Community:** [https://success.copado.com](https://success.copado.com) — support cases, release notes, community knowledge. Register every team member from day one.

### Tool Summary

| Copado Tool | Purpose in AgentOps |
|---|---|
| **Agentia Pro (Source Format Pipelines)** | Pipeline orchestration, promotions, quality gates, audit trail |
| **Commit Changes page** | Dependency-aware commit experience for agent metadata |
| **Environment Variables + Find and Replace** | Environment-specific value injection at deploy time |
| **Copado Functions** | Governed CLI execution steps (publish, activate, rollback) |
| **Automation Rules** | Scheduled and event-driven pipeline actions (Environment Sync, back promotions) |
| **Agentia Testing (CRT)** | Pipeline-level quality gate enforcement; CopadoAI probabilistic validation |
| **Apex Test Results quality gate** | Enforces coverage thresholds per pipeline stage |
| **PMD quality gate** | Static code analysis on Apex before promotion to Integration |
| **Environment Sync** | Next-generation back promotion for Source Format Pipelines v7.29+ |

---

## Section 1: AgentOps as an Agentia Pro Pipeline Discipline

The four AgentOps lifecycle phases map directly to Agentia Pro pipeline constructs.

| AgentOps Phase | Agentia Pro Construct |
|---|---|
| **Author** | Commit Changes page and the User Story |
| **Deploy** | Agentia Pro pipeline promotion |
| **Monitor** | STDM and Agentforce Observability (Salesforce-native; Agentia Pro closes the loop when failures are reproduced as Testing Center cases) |
| **Iterate** | A new User Story, a new commit, a new promotion cycle |

The User Story is the unit of change. Every Agentforce modification, whether a new subagent, a revised classification description, or a changed `available when` clause, lives in a User Story with a full commit history, a promotion record, and an approval log.

---

## Section 2: What Agentia Pro Tracks as Metadata

The following metadata types are surfaced by the **Commit Changes page** when an agent is modified. Understanding this set is critical: missing any of these from a commit produces a deployment that succeeds in version control but fails in the target org.

| Metadata Type | Role |
|---|---|
| `AiAuthoringBundle` | Human-readable Agent Script source. The primary artifact in source control and the diff target on the Commit Changes page. |
| `GenAiPlannerBundle` | Compiled runtime artifact. Must always accompany `AiAuthoringBundle`; `BotVersion.PlannerId` is a required field. |
| `Bot` | Parent runtime record. Must exist in the target org before `BotVersion` can be deployed. |
| `BotVersion` | Agent version record. Explicitly named in the manifest; never wildcarded. |
| `Flow`, `ApexClass` | Action dependencies. The Commit Changes page's dependency analysis surfaces these at commit time. |

> **Cross-version diff limitation:** When an agent is activated and then edited, Salesforce creates a new version file (e.g., `v2.agent`) rather than editing `v1.agent` in place. Agentia Pro's diff view shows this as an Add, not a Modify, breaking line-by-line diff continuity. If the version difference surfaces as a conflict during a promotion, use the Review Conflicts UI on the Promotion record. The side-by-side view there provides a usable comparison of both versions. Alternatively, compare the two version files directly in the Git repository using standard Git tooling (for example, `git diff v1.agent v2.agent`). If the lack of clean cross-version diffing is a recurring pain point for your team, raise a feature request through the Copado Community at [https://success.copado.com](https://success.copado.com).

---

## Section 3: Source Control and the Commit Changes Page

### The Agentia Pro Commit Experience

When an agent change is ready to commit, the developer opens the **Agentia Pro Commit Changes page** rather than making a direct Git commit. This page provides:

- **Intelligent filtering** that surfaces only changed metadata files.
- **Real-time dependency analysis** flagging Bot, BotVersion, AiAuthoringBundle, GenAiPlannerBundle, Flows, and Apex as a related set.
- **Smart grouping** suggesting which changed components belong together in a single User Story.
- **Full diff view** of every changed file before the commit is confirmed.

Run `sf agent validate --authoring-bundle` locally before committing. This catches syntax errors before any org is touched and keeps the Integration environment clean.

### Version Control Discipline

**Every developer must commit work to version control every day, without exception.** This is the foundational rule that every other pipeline practice depends on.

Environment Sync preserves Work in Progress by default, retrieving the current state of affected components before deploying and merging with incoming changes. However, merge conflicts are still possible even with WIP preservation, and resolving them under time pressure introduces risk. Committing daily keeps feature branches current, reduces the surface area for conflicts, and ensures that if a conflict does occur, there is a clean committed state to resolve against. The rule is absolute, but for the right reason: consistent committing prevents conflicts and keeps the pipeline moving.

Additional version control standards:

- **Work in version control is owned by the pipeline.** Anything changed directly in a production or shared environment without being committed is invisible to the pipeline and will be overwritten on the next promotion.
- **Maintain a separate backup repository** with daily automated snapshots of all environments. Trigger a manual snapshot immediately before any major agent release.
- **Keep the pipeline repository as small as possible.** Exclude static resources and metadata that cannot be modified through the pipeline. Agent metadata (`AiAuthoringBundle`, `GenAiPlannerBundle`, `Bot`, `BotVersion`) should grow in lockstep with agent capability.
- **Never merge or modify Git branches directly** as a standard practice. In rare cases, Copado Support may recommend a targeted manual edit to a promotion branch to unblock a stuck promotion. When that guidance is given, document exactly what was changed and why, and treat it as a one-time exception.

### The Copado Branching Strategy

Agentia Pro manages three branch types. Understanding them is essential for anyone working on promotions, back promotions, or Environment Sync.

**Environment Branches** are one per Salesforce org, long-lived, always reflecting the current deployed state of that environment. The Integration environment branch represents the state of the assembled agent network as of the last successful promotion.

**Feature Branches** are one per User Story, created from the pipeline's configured default base branch (typically `main` or `master`). Every commit to a User Story's `AiAuthoringBundle` is merged into the corresponding environment branch as promotions succeed.

**Promotion Branches** are created on-demand when a promotion is executed. They merge one or more feature branches into the target environment branch. All conflicts, including `AiAuthoringBundle` conflicts, are resolved here. They are never resolved directly in environment branches.

The full promotion flow is:

1. Feature branches are merged into the Promotion branch.
2. Conflicts, if any, are resolved in the Promotion branch only.
3. The deployment runs against the target environment.
4. On success, the Promotion branch is merged into the target environment branch.

This strategy exists because Salesforce orgs are long-lived and monolithic. The branching model accommodates that reality. Agent delivery operates within it.

---

## Section 4: AI-Assisted Development and the Audit Trail

When generative AI tooling is used to generate or scaffold Agent Script, the **User Story is the disclosure artifact**. Note AI usage in the User Story description. The commit message on the Commit Changes page and the full promotion history together form the audit record for change boards and regulators.

The `AiAuthoringBundle` diff on the Commit Changes page is where human reviewers verify what the AI produced before it enters the pipeline. AI-generated Agent Script requires the same PR approval and Definition of Done checks as human-authored code.

---

## Section 5: Agent Script in the Pipeline Context

This section covers only the Copado-specific implications of Agent Script structure. For full Agent Script syntax and authoring guidance, refer to the Salesforce Agent Script documentation.

**`config.developer_name`** maps to the component name in Agentia Pro's metadata selector. Ensure it matches the intended component name before committing.

**`access.default_agent_user`** is environment-specific. It must never be hardcoded in committed metadata. Manage it via a Copado Environment Variable (see Section 7: Pipeline Environment Variables).

**Action dependencies:** A User Story that changes an agent action must include the referenced Flow or Apex class in the same commit. The Commit Changes page's dependency analysis surfaces this relationship at commit time. Do not commit them separately.

**The `->` vs. `|` boundary and testing:** Deterministic paths (`->`) can be precisely asserted in Agentia Testing. Probabilistic paths (`|`) require the CopadoAI eight-metric evaluation model. Design test strategy around this boundary from the start.

---

## Section 6: Multi-Agent Orchestration (SOMA) in Agentia Pro

### Projects and Release Records

Each sub-agent in a SOMA architecture can be managed under its own **Agentia Pro Project**. A Project is the container for a team's User Stories, pipeline assignments, and release records. Separate Projects mean separate backlogs, separate pipelines, and separate release cadences.

A **Release Record** groups related User Stories for a coordinated deployment. In a SOMA context, a Release Record might contain User Stories from the supervisor agent team alongside User Stories from one or more sub-agent teams. Release Records allow teams to coordinate a multi-team promotion without coupling their development cycles. The Release Record is the agreement about what ships together.

### User Story Dependencies: Visibility, Not Enforcement

Agentia Pro supports User Story Dependencies that formally record relationships between stories across teams. In Agentia Pro Source Format Pipelines, **these dependency records are informational only.** The pipeline will not block a promotion if a dependent story is deployed out of order.

The actual enforcement of cross-team sequencing comes from two sources:

1. **The Release Record**, which groups cross-team User Stories under a single Release and prevents independent promotion through human process discipline.
2. **The human approval gate**, where the release manager reviews the full set of User Stories in a Release before approving the production promotion.

Teams that rely solely on dependency records to enforce sequencing will be caught out. Release Records and approval gates are the real protection.

### The Blast Radius Argument in Agentia Pro Terms

A destructive change affecting only the Billing Agent travels through the Billing team's User Stories and their Release Record. It does not touch the HR team's pipeline path. The blast radius stays contained. In a monolithic agent, the same destructive change forces a full rebuild of the entire agent network and blocks every other team's User Story from promoting.

### Designing for Safe Parallel Development

The safest way to enable multiple agent teams to work in parallel without conflicts is clear **metadata ownership**. Each team owns its own subagent's `AiAuthoringBundle`, its own Flows, and its own Apex wrapper classes.

Organize agent work by rate of change to inform testing rigor:

- **Frequent change:** Individual subagent prompt instructions and classification descriptions. Lower blast radius; test carefully and promote deliberately.
- **Less frequent change:** Shared Flow actions and Apex invocable methods. Require coordinated planning before promotion.
- **Highest stability requirement:** Supervisor agent routing structure, `connected_subagent` targets, and shared `GenAiPlugin` definitions. These affect the entire agent network.

Every Agentforce component goes through the full pipeline process regardless of change frequency. There are no fast lanes for Agentforce metadata.

### When and How to Use Parallel Pipelines

Parallel pipelines are a solution for teams that need isolated sandboxes. They are not a default requirement for every SOMA architecture. The decision must be deliberate and documented before any parallel development begins.

#### Parallel Sequential Releases (Different Cadences)

When sub-agent teams operate on different release cadences, a major release deployment risks overwriting patch changes already in production.

**The solution: Continuous two-directional syncing.**

- As patch User Stories pass through shared environments, use **Environment Sync** to sync those changes into the major release environments.
- Set up an **Automation Rule** to run Environment Sync nightly. Do not rely on manual triggering.
- Once the major release is ready, use Environment Sync to sync all major release User Stories back into the minor release environments.

#### Separate Agent Teams on a Shared Platform

When isolated environment chains converge at a shared Integration or UAT environment, treat the shared environment as the authoritative integration point. Use **Environment Sync** to keep pipelines aware of each other's changes. Plan metadata ownership deliberately. Shared Permission Sets, Profiles, and Bot parent records are the highest-risk area at the convergence point.

#### Governance Rules for All Parallel Pipeline Scenarios

- Define and document the governance process before parallel development begins.
- Environment Sync must be automated with an Automation Rule.
- Conflict resolution happens in the Promotion branch only. Never in Integration, UAT, or production.
- No direct development in shared environments. All changes originate in isolated Dev environments.
- Use Release Records and filtering to avoid syncing the wrong team's stories into the wrong environment chain.

---

## Section 7: Environment Strategy and Pipeline Structure

### The Reference Pipeline: Four Stages

```
Developer Sandbox  ->  Integration Sandbox  ->  UAT / Staging Sandbox  ->  Production
```

| Stage | Sandbox Type | Purpose | Who Uses It |
|---|---|---|---|
| **Developer Sandbox** | Developer or Developer Pro | Individual feature development. Not shared. | Individual developers |
| **Integration Sandbox** | Partial Copy (preferred) | First shared environment. Proves independent changes work together. First automated quality gate. | Dev leads, QA |
| **UAT / Staging Sandbox** | Full Copy | Production-representative data and configuration. Regression suites must pass here. Publish and activate rehearsed here. | Business stakeholders, QA, release manager |
| **Production** | Production org | Live traffic. Publish and activate are human-gated. Agentia Testing quality gate runs post-activation. | Release manager, designated approvers |

> **Why Full Copy matters for UAT:** Agent behavior is sensitive to data, permissions, entitlements, and Data Cloud configuration, not just metadata. A Partial Copy sandbox may behave differently from Production in ways that only surface under real data conditions. If a Full Copy is not available, document the known gaps explicitly and treat UAT results as directional rather than definitive.

In a SOMA delivery model, each team owns its own Developer sandboxes. The shared Integration sandbox is where the assembled agent network is first validated as a whole. Integration is the first time the supervisor agent connects to sub-agents owned by other teams. That is exactly why Integration must be a stable, shared environment that no one develops directly in.

### Pipeline Connection Model

| Connection | Type | Gate |
|---|---|---|
| Feature branch to Integration org | Standard promotion | Agentia Testing quality gate + Apex/PMD quality gates |
| Integration to UAT org | Standard promotion | Agentia Testing quality gate + human review |
| UAT to Production org | Standard promotion | Agentia Testing quality gate + human approval |
| Production to Integration/Dev | Back promotion / Environment Sync | Syncs changes from higher environments back upstream to prevent drift |

### Pipeline Environment Variables

Copado's built-in **Environment Variables** feature allows teams to define values that differ per environment without hardcoding them into committed metadata. This is the correct and only acceptable mechanism for managing environment-specific values.

#### How Environment Variables Work

An Environment Variable is a key-value pair defined once and resolved automatically at deploy time with the correct value for the target environment. Copado uses this alongside its **Find and Replace** capability:

1. The committed metadata file contains a placeholder string (e.g., `agent-user@source.org`).
2. In `sfdx-project.json`, a replacement rule maps that placeholder to a named Environment Variable:

```json
{
  "replacements": [
    {
      "filename": "force-app/main/default/bots/NGA_Service_Agent/NGA_Service_Agent.bot-meta.xml",
      "stringToReplace": "agent-user@source.org",
      "replaceWithEnv": "TARGET_AGENT_USER"
    }
  ]
}
```

3. In the Copado pipeline, `TARGET_AGENT_USER` is defined with a different value for each stage.
4. At deploy time, Copado resolves and substitutes the correct value automatically.

#### What to Manage via Environment Variables

For Agentforce delivery, the following values must always be Environment Variables:

- Agent user email address (`access.default_agent_user`)
- Org-specific API endpoints
- Data Space identifiers
- External system URLs or credentials referenced in agent actions
- Any value that differs between Dev, Integration, UAT, and Production

> **The rule is absolute:** If a value changes between pipeline stages, it is an Environment Variable. No exceptions.

For current configuration steps, consult [https://docs.copado.com/](https://docs.copado.com/).

### Agentforce-Specific Environment Checklist

Before any pipeline stage is used for testing or promotion, verify:

- [ ] Einstein and Agentforce enabled in the org
- [ ] Agent user created and correctly provisioned (PSL before permission set)
- [ ] Default Data Space enabled for the agent user's permission set
- [ ] `enable_enhanced_event_logs: True` confirmed in the agent config block
- [ ] Agentforce Observability enabled in Setup
- [ ] Copado Environment Variable configured for `TARGET_AGENT_USER` at this stage
- [ ] Agentia Testing robot authorized to execute against this org (Integration and UAT stages)
- [ ] Flex Credit entitlement confirmed for this sandbox
- [ ] Testing Center test suite name confirmed for this stage's pipeline automation
- [ ] Agentia Testing quality gate configured and active for this stage's promotion connection
- [ ] Rollback version number confirmed and documented (UAT and Production stages)

### Environment Discipline

- **Never develop in production.** All development happens in sandboxes.
- **No manual changes in testing or production environments.** This includes the agent configuration UI. A classification description edited directly in the Integration sandbox is invisible to version control and will be overwritten on the next forward promotion.
- **Environments must be as similar to production as possible.** An environment that diverges from production produces test results that do not predict production behavior.
- **Refresh sandboxes deliberately.** At a minimum annually; target quarterly for active agent development teams.
- **Hotfix changes must be back-promoted immediately.** A hotfix applied to production must be synced to all lower environments before any new User Story commits are made on the affected components.

### Keeping Environments Aligned: Back Promotions and Environment Sync

#### Back Promotion Eligibility

Copado enforces four eligibility criteria for back promotion:

- The User Story must have been deployed to a higher environment at least once.
- The User Story must currently be sitting in a higher environment than the back promotion destination.
- The User Story must not have already been promoted from the destination environment.
- The User Story must not be flagged as Excluded from Pipeline.

#### Back Promotion Risks

- **Uncommitted work can be affected.** While Environment Sync preserves Work in Progress by default, merge conflicts are still possible. All work should be committed before any back promotion or Environment Sync runs to minimize conflict risk.
- **Back promoting from production requires special care.** Changes promoted to production must be back promoted to all lower environments before new User Story commits are made on the affected components.
- **Cherry-picking and co-mingling releases are not recommended.** Back promotions replay User Stories in the same order they were originally promoted.
- **Merge conflicts must be resolved by the person who owns the commit.**

#### Classic Back Promotion Practices

- **Schedule back promotions at a known, published time** via an **Automation Rule**. Nightly scheduling is the recommended default.
- **Use the Last Refreshed Date field** on the Environment record after a sandbox refresh to prevent a flood of unnecessary back promotions.
- Back promote in promotion order. Copado enforces this automatically.

#### Environment Sync (Recommended for Source Format Pipelines v7.29+)

Environment Sync is the next-generation replacement for classic back promotions. It syncs multiple User Stories at once while actively protecting uncommitted work in the destination environment.

**Prerequisites:**

- Copado Deployer v25.35 or later.
- Salesforce Source Format Pipelines v7.29 or later.
- Enable per pipeline via Pipeline Builder > Pipeline Settings > Environment Sync > Enable.

**How it works:** Copado creates two temporary branches from the source branch: a Pre Changes branch (capturing current work-in-progress from the destination org) and a Post Changes branch (from the most recently selected User Story's merge commit). These are merged and the result is deployed to the destination org. On success, the Promotion branch merges into the destination environment branch.

**Key behaviors:**

- **Work in Progress is preserved by default.** Copado retrieves the current version of affected components before deploying, then merges with incoming changes. Developers should still commit before sync runs, as merge conflicts remain possible.
- **Ignore Work in Progress option.** Use this to overwrite a sandbox with clean, release-approved changes. Appropriate for stable environments, not active development sandboxes.
- **Conflict resolution is consolidated.** All conflicts across all selected User Stories are resolved once, in a single session.
- **Maximum component limit:** 8,000 components per single Environment Sync operation.
- **User Stories older than one year** do not appear in the Environment Sync list.

Automate Environment Sync using an **Automation Rule** for nightly execution.

#### Choosing Between Environment Sync and Classic Back Promotions

| Scenario | Environment Sync | Classic Back Promotion |
|---|---|---|
| Frequent back promotions with small batches | Yes | Yes |
| Pick specific individual User Stories | No | Yes |
| Sync only approved User Stories from a stable environment | Yes | No |
| Quickly bring a new sandbox up to date | Yes | No |
| Overwrite a sandbox with clean release-approved changes | Yes (with Ignore WIP) | No |
| Large number of User Stories with multiple potential conflicts | Yes | No |

After running Environment Sync for all available User Stories, if classic back promotion still shows remaining stories, create a regular back promotion for those. The two mechanisms complement each other.

### Rollback Configuration

Because Agentforce maintains versioned published bundles, rollback means deactivating the current version and reactivating a prior one. The core of this process is two Salesforce CLI commands:

```bash
sf agent deactivate --target-org <production-alias>
sf agent activate --version-number <prior-version> --target-org <production-alias>
```

These steps can be executed manually via the Salesforce CLI. Clients who want to automate and govern this process further can explore wrapping these commands in a Copado Function; consult the Copado documentation at [https://docs.copado.com/](https://docs.copado.com/) for guidance on setting up Functions.

The prior version number must be identified and documented before the production release window opens. Not during an active incident.

> **First-release warning:** If the first release goes wrong, there is nothing to roll back to. The rollback mechanism requires a prior committed version. The first release must be right, which means the pre-release gate in Section 12 is not optional for release zero.

### Scratch Orgs: When to Use Them

Most Agentia Pro clients use sandboxes as the default. Scratch orgs are a reasonable option only when:

- The work does not involve Data Cloud, RAG, or Data Spaces.
- The component is self-contained and does not depend on org-specific configuration.
- The team has an established Dev Hub setup and is comfortable with the scratch org lifecycle.

---

## Section 8: Change Management in Agentia Pro

### Structuring User Stories for Agent Delivery

Every piece of Agentforce work lives in a User Story, structured as:

> *"As a [persona], I want to [goal], so that [benefit]."*

Every User Story must include clear, testable **Acceptance Criteria** written from the persona's point of view. For Agentforce work, this means Acceptance Criteria describing expected agent behavior: the routing decision, the response tone, the escalation trigger, not just the metadata that was changed. Write them at story creation time, not at testing time.

**Keep stories small.** The right scope for a single User Story is usually one of the following:

- One subagent's classification description update.
- One new action (Flow or Apex) added to a subagent.
- One `AiAuthoringBundle` change with its dependent `GenAiPlannerBundle`.
- One set of related Testing Center test cases added to cover an existing capability.

The User Story is the container of change in Agentia Pro. Commit history, promotion records, approval logs, Deployment Steps, and Testing Center pass rate evidence all live on the User Story record.

### Promotion Cadence and Batch Size

- **Every developer promotes their own code.** Handoffs introduce errors.
- **Deploy in small batches, frequently.** The more changes deployed at once, the greater the risk.
- **Practice daily or continuous integration.** Delaying commits increases conflict risk and hides problems.
- **Avoid large waterfall-style releases.** When a release must grow larger than usual, use **User Story Bundling** to ease the merge process before a production deployment.

### Base Branch Handling: Preventing Duplicate Commits

The pipeline record has a **default base branch** configured, typically `main` or `master`. When stories can be released quickly and completed work reaches production regularly, no custom base branch override is needed.

The problem arises when the pipeline has in-flight agent work: User Stories that have been committed and are progressing through environments but have not yet reached production. For Agentforce, this most commonly affects `AiAuthoringBundle` files and the Flows or Apex classes they reference.

**Method 1: Keep stories flowing to production (preferred).** Release completed work to production as soon as it is ready. When a story reaches production, its changes become part of the pipeline's default base branch and all subsequent stories build on top of them automatically.

**Method 2: Set a prior User Story's feature branch as the base branch.** When two stories touch the same metadata and promoting early is not possible:

1. Create the new User Story.
2. Go to the Commit screen and select **Advanced**.
3. Select the earlier User Story's feature branch as the **Base Branch**.
4. Commit components as normal.

**Critical rule:** Never deploy a User Story past its base branch environment. If this becomes necessary, recommit with Recreate Feature Branch and reset to the pipeline's default base branch.

**Method 3: Use an environment branch as the base branch.** When multiple in-flight stories touch the same metadata, use the environment branch (e.g., Integration) as the base for the new story. Do not deploy the story past the environment that matches its base branch.

> **The real risk for `AiAuthoringBundle`** is a scoping issue. If the `AiAuthoringBundle` file is not explicitly committed to the active User Story, Auto-Resolve will apply promotion-branch-wins by design, and incoming feature branch changes will be skipped. Always ensure `AiAuthoringBundle` is explicitly scoped to the User Story before promoting.

After any promotion, verify `gitresolution.json` to confirm which conflicts were resolved and which strategy was applied. Do not rely solely on a pipeline "success" status.

### Extending the Pipeline: Deployment Steps and Copado Functions

**Deployment Steps** are a first-class feature of Agentia Pro User Stories. They allow teams to define and execute a wide range of automated and manual actions as part of every promotion, logged directly on the User Story record. Agentia Pro supports nine deployment step types for Salesforce Source Format Pipelines:

| Step Type | What It Does |
|---|---|
| **Apex** | Executes an Anonymous Apex script in the destination org. For example, automatically assigning permission sets to specific users once the permission set has been deployed. |
| **Custom Settings** | Deploys data held in custom settings objects, including Id mapping for users, profiles, and the organization Id for hierarchy custom settings in the destination environment. |
| **Data Set - Salesforce** | Commits and deploys Salesforce data changes via data sets. A data set is a snapshot of data stored in a source environment, saved for deployment to other environments. When a data commit is performed on a User Story using a new data template, a step of this type is automatically added. |
| **Data Template - Salesforce** | Deploys data via data templates. The data is retrieved from the source org at the time the deployment job executes, so the data may change based on where the User Story is in the pipeline and when the deployment runs. |
| **Function** | Executes a Copado Function for more complex automations. See the Copado documentation for guidance on building and registering Functions. |
| **Manual Task** | Used for steps that cannot be automated through Copado Functions or Salesforce Flows. |
| **Salesforce Flow** | Executes a configured Salesforce Flow, for example to update records, interact with external APIs, or notify users via Slack, email, or other communication platforms. |
| **Custom Job Steps** | Custom step types added to a job template or User Story deployment step. See the Copado documentation for guidance on building custom job steps. |
| **Robotics Automation Step** | Automates deployment scenarios that would otherwise require manual configuration changes across multiple orgs, such as enabling or disabling Salesforce features. Particularly relevant for Agentforce delivery, where feature flags and configuration settings often differ between pipeline stages. |

For Agentforce delivery, common uses of deployment steps include Apex steps for permission set assignment, Salesforce Flow steps for user notification, and Manual Task steps for post-deployment activation verification.

Rules for deployment steps:

- All steps must be added before the story is considered ready for promotion to Integration. Steps discovered late are a Definition of Done failure.
- Each step must specify: what action to perform, which environment it applies to, whether it runs before or after deployment, and who is responsible.
- Steps must be marked complete in Agentia Pro at each environment as they are executed.

Consult [https://docs.copado.com/](https://docs.copado.com/) for full documentation on each step type.

### Conflict Resolution in Agentia Pro

| Strategy | Applies To | Resolution Logic |
|---|---|---|
| **Auto-Resolve** | Simple metadata: layouts, classes, flows, JSON config | Feature branch wins if file is on the User Story. Promotion branch wins if not. |
| **Semantic Merge** | Nested metadata: profiles, permission sets, labels, translations, sharing rules, workflow metadata | Same logic, applied at the individual element level. Includes de-duplication. |
| **Manual Resolution** | Programmatic metadata: Apex classes, triggers, Visualforce, LWC, Aura | Promotion stops with status "Merge Conflict." Developer resolves via the Review Conflicts UI. |
| **Smart Conflict Resolution** | Same types as Manual | Copado stores a fingerprint of a previously resolved conflict and re-applies the same resolution automatically if it recurs. Enabled by default. |

**Resuming a Promotion After Conflict Resolution:**

- Enable **Reuse Promotion Branch on Conflict** in Pipeline Builder > Pipeline Settings.
- After a conflict is resolved, the promotion resumes from the exact User Story where the conflict occurred.
- Available in Source Format Pipelines v9.8 and later.

### User Story Status Model

Every team must define their status model before going live. A status without defined entry and exit criteria is meaningless.

**Recommended considerations:**

- Define entry and exit criteria for each status.
- Align statuses to pipeline stages. A story's status must reflect where it actually is in the pipeline.
- Limit the total number of statuses. Start with the minimum required set.
- Define who is responsible for moving a story to each status.
- Use **Copado Automation Rules** to drive status transitions wherever possible.

### Agentia Pro as the Audit Trail

The User Story is the primary audit artifact. It holds:

- The full commit history and diff of every changed file.
- The promotion record at each pipeline stage.
- The approval log at each human gate.
- Linked Testing Center pass rate evidence.
- Logged Deployment Steps.

In regulated environments, this record is the structured, auditable input for change advisory boards (CABs). Testing Center results that attach to the User Story and appear in the promotion history are the evidence package. If the suite did not pass, the change request does not go to the board.

### Change Management Guardrails

- All changes must enter the pipeline through a User Story. No exceptions.
- No manual changes in Integration, UAT, or Production, including agent configuration UI changes.
- Deployment steps discovered after promotion to Integration are a Definition of Done failure.
- Pipeline automation (Copado Functions, Automation Rules, and Deployment Steps) is always preferred over manual CLI execution.

---

## Section 9: Regulated Industry Delivery Framework

Agentia Pro provides the compliance infrastructure for regulated Agentforce delivery. The key capabilities:

- **Full audit trail on every User Story:** commit history, promotion records, approval logs, and deployment steps all on a single record.
- **Human approval gates** at Integration-to-UAT and UAT-to-Production, configurable per pipeline stage.
- **Quality gate enforcement** that blocks promotion programmatically when coverage, PMD, or Testing Center thresholds are not met.
- **AI disclosure:** the User Story description is the disclosure artifact when generative AI tooling was used to generate or scaffold Agent Script.
- **Testing Center results as CAB input:** promotion history provides a structured, auditable test evidence package. If the Testing Center suite did not pass, the change request does not go to the board.

**The honest conversation:** Agentforce agents are probabilistic systems. No amount of governance eliminates variance. What Agentia Pro provides is the confidence that every change was reviewed, tested to a defined threshold, approved by a named person, and deployed in a documented, repeatable sequence. That is what regulators and auditors can actually evaluate.

---

## Section 10: Security and the Agent User in Agentia Pro

The agent user is environment-specific configuration. It must never be hardcoded in committed metadata. Manage it via a Copado Environment Variable (`TARGET_AGENT_USER`) with Find and Replace (see Section 7).

**Permission architecture for each pipeline stage:**

1. Provision the agent user for that environment.
2. Assign the `AgentforceServiceAgentUser` Permission Set License (PSL) before the Permission Set. The PSL must be assigned first; assigning the Permission Set without the PSL produces an error.
3. Assign the `AgentName_Access` Permission Set.
4. If the agent uses RAG: assign `GenieDataPlatformStarterPsl` before the Data 360 permission set; enable the Default Data Space explicitly.

Add these steps as Deployment Steps on the User Story. They run at each environment as the story promotes through the pipeline.

**The Data Space Permission Gap:** The Default Data Space must be explicitly enabled for the agent user's permission set. Missing this configuration produces a "We couldn't find your data space. Try again later" error.

Resolution:
1. In Setup, search for Permission Sets and select **Data 360 Architect**.
2. Under Apps, select **Data 360 Data Space Management**.
3. On Data Space Scopes, click **Edit**.
4. Enable the **Default Data Space**.
5. Click **Save**.

Add this step to the Agentia Pro environment setup process for each pipeline stage.

---

## Section 11: Testing Your Agent with Copado

### The Testing Pyramid: Three Explicit Layers

| Layer | Tool | What It Validates | When It Runs |
|---|---|---|---|
| **Layer 1: Smoke** | Agentforce Conversation Preview | Individual subagent behavior in isolation in the Dev sandbox | Authoring time, continuously |
| **Layer 2: Scenario and Regression** | Agentforce Testing Center | Acceptance-criteria-evaluated scenarios; LLM-judge scored | After every publish and activate at Integration and UAT |
| **Layer 3: Pipeline Gate** | Agentia Testing with CopadoAI library | Pass rate threshold enforcement; probabilistic response validation; existing org regression coverage | Automated by the Agentia Pro pipeline on each promotion |

**Key framing:** Testing Center is where tests are authored and confidence in agent behavior is built. It is the primary instrument. Agentia Testing does not replace Testing Center. It enforces the outcome of Testing Center at the pipeline level and brings existing org regression coverage into the same quality gate evaluation.

Test architecture must evolve with agent architecture. As new subagents are added and new actions are connected, new test cases must be added. Testing Center scenarios must be authored alongside the User Story, not added as a cleanup task afterward.

The economics: `Value(tests) = Cost(Failure) - Cost(tests)`. For agent delivery, the cost of failure includes not just deployment errors but undetected behavioral drift: an agent that confidently gives wrong answers until someone notices. The more frequently a team deploys, the more cost-effective automated testing becomes.

### The Definition of Done

A pipeline without enforced quality gates is a promise, not a process. The Definition of Done (DoD) is the set of conditions every User Story must satisfy before it moves from a development environment into Integration.

The most important transition to gate is **Dev to Integration.** Integration is the first shared environment. An `AiAuthoringBundle` that has not passed its DoD at this point creates problems for everyone downstream.

#### Recommended Quality Gates

**Apex Test Coverage**
- Minimum 85% Apex test coverage in the dev sandbox before promotion to Integration.
- Configure a **Copado Apex Test Results quality gate** on the Dev-to-Integration stage. Promotion is blocked if the threshold is not met.

**PMD Static Code Analysis**
- All new and modified Apex classes and triggers must pass PMD (Programming Mistake Detector) static analysis.
- Configure a **Copado PMD quality gate** on the Dev-to-Integration stage. PMD violations must be resolved by the developer and must not be suppressed without documented justification.
- Consider running PMD at commit time as well as at promotion time for earlier feedback.

**Pull Request Approval**
- A Pull Request must be opened against the feature branch and approved by at least one qualified reviewer before a story can be promoted to Integration.
- For Agentforce User Stories, the reviewer must be capable of evaluating Agent Script changes, not just Apex or Flow dependencies.
- PRs must not be self-approved.
- Configure your Git provider to require PR approval before merge, and configure Agentia Pro to enforce PR approval before the Dev-to-Integration promotion.

**Testing Center Scenario Coverage**
- At least one Testing Center test case covering the User Story's Acceptance Criteria must be authored and passing before promotion to Integration.
- The test case must be linked to the Testing Center suite configured for the Integration stage gate.

**Agent-Specific Checks**
- `sf agent validate --authoring-bundle` passes with zero errors.
- All action targets (Flows, Apex) confirmed present in the target org.
- `AiAuthoringBundle`, `GenAiPlannerBundle`, and all dependent metadata committed in the same User Story.

#### Definition of Done: Baseline Table (Agent User Stories)

| Gate | Tool | Stage | Automated |
|---|---|---|---|
| Apex test coverage >= 85% | Copado Apex Test Results quality gate | Dev to Integration | Yes |
| PMD static analysis: zero critical violations | Copado PMD quality gate | Dev to Integration | Yes |
| Pull Request approved by at least one qualified reviewer | Git provider + Agentia Pro | Dev to Integration | Partially |
| Test class committed in same User Story as code | Commit review | Dev to Integration | Manual check |
| Acceptance criteria reviewed and accepted | Product owner sign-off on User Story | Dev to Integration | Manual |
| Testing Center scenario authored and passing | Agentforce Testing Center | Dev to Integration | Manual authoring, automated execution |
| `sf agent validate --authoring-bundle` zero errors | Local validation (pre-commit) | Dev to Integration | Manual (pre-commit) |
| All required Agentforce metadata committed | Commit Changes page review | Dev to Integration | Manual check |
| All deployment steps logged on the User Story | Agentia Pro User Story | Each stage | Manual |

#### Making the Definition of Done Effective

- **Automate every gate that can be automated.** Apex coverage thresholds and PMD analysis must not depend on developer self-reporting.
- **Make the DoD visible.** Post it in the team's primary collaboration channel and include it in onboarding.
- **Review the DoD regularly.** At a minimum, review quarterly.
- **Apply it to every story, without exception.**
- **Give developers early feedback.** Configure PMD and coverage checks to run at commit time, not only at promotion time.

### Connecting Testing Center Results to the Agentia Pro Pipeline

The pipeline trigger sequence for every non-production promotion:

1. Agentia Pro pipeline completes deployment to the target environment.
2. Pipeline automation triggers the Testing Center run via a **Copado Function**.
3. The Function polls until the run completes and returns a pass rate.
4. Pass rate is evaluated against the threshold configured in the **Agentia Testing quality gate**.
5. If the threshold is met, the Agentia Testing job reports success and the pipeline stage is marked complete.
6. If the threshold is not met, the Agentia Testing job reports failure and the next promotion is blocked.

**Recommended starting thresholds:** 80% at Integration; a higher agreed bar at UAT that matches the pre-release gate commitment. Some regulated clients require 100% at UAT as a condition of CAB submission.

### Agentia Testing: Recognizing Existing Coverage

Agent actions are not new code in a vacuum. They wrap Flows, Apex classes, and external API callouts that already exist in the org.

**Bucket 1: Existing Agentia Testing regressions that already cover agent actions indirectly**
- Flow regressions testing the underlying Flows wrapped by agent actions.
- Apex regressions testing the classes invoked by agent actions.
- UI regressions testing the Salesforce pages an agent navigates or surfaces to users.
- Integration regressions testing external callouts the agent relies on.

These suites do not need to be rewritten. They need to be recognized as part of the agent testing strategy and included in the pipeline gate evaluation.

**Bucket 2: New Agentforce-specific regressions to add**
- End-to-end conversation flows through the Agentforce channel.
- Post-activation smoke tests confirming the correct agent version is live and responding.
- Routing accuracy tests sending known utterances and verifying which subagent responds.
- Escalation path tests confirming hand-off to a human agent under defined conditions.

> **For existing Agentia Testing customers:** Your pipeline quality gate is partially built. Identify which existing suites exercise the Flows and Apex classes your agent actions call. Pull those suites into the Agentforce pipeline stage gate. Then add Agentforce-specific tests on top. The incremental cost is lower than it appears.

### The CopadoAI Testing Library

The CopadoAI library provides keyword-based probabilistic validation for Agentforce agent responses, accounting for the fact that the same prompt can produce different but equally valid outputs.

**Setup path for existing Agentia Testing customers:**

1. Enable a Test Agent License in the Copado Robotics org.
2. Install the CRT Service Agent to the Salesforce sandbox via Salesforce Unlocked Package.
3. Create a new test job and select **New from Accelerator**, then select the **Agentforce Accelerator**.

**The eight evaluation metrics:**

| Metric | Focus | Priority Use Case |
|---|---|---|
| Context Faithfulness | Answers grounded in provided data, not invented | All agents |
| Context Precision | Specific answers over generic ones | All agents |
| Similarity | Response matches a known ideal output | High-consistency scenarios |
| Factual Correctness | No incorrect claims | Healthcare, financial services |
| Hallucination Level | No made-up or misleading information | All agents |
| Noise Sensitivity | Handles typos and slang gracefully | Customer-facing agents |
| Response Relevance | Stays on topic | Scoped agents |
| Response Helpfulness | Clear, actionable, step-by-step guidance | Support and service agents |

### Apex Test Coverage Requirements

Salesforce enforces a minimum of **75% Apex test coverage** for any production deployment. This applies to every promotion that includes Apex. However, **75% is a floor, not a target.**

**The coverage dilution problem:** Salesforce calculates coverage as an org-wide average. As User Stories combine through promotion, new Apex from one story is added alongside test classes from other stories. If those test classes do not exercise the new code, the org-wide average can drop below 75% even though each story individually met the requirement.

**Recommended coverage thresholds by environment:**

| Environment | Minimum Required | Recommended Target |
|---|---|---|
| Dev Sandbox | 85% | 90%+ |
| Integration / QA | 75% (platform minimum) | 85%+ |
| UAT | 75% (platform minimum) | 85%+ |
| Production | 75% (platform minimum, enforced) | 85%+ |

The 85% minimum in dev sandboxes creates a buffer against coverage dilution further up the pipeline.

**Practical rules:**
- Every Apex class committed to a User Story must have its corresponding test class committed in the same User Story.
- Test classes must include meaningful assertions. Coverage without assertions is not coverage in any meaningful sense.
- Configure Copado **Apex Test Results quality gates** on each pipeline stage.

---

## Section 12: Deployment and Metadata

### Deployment Tooling

Agentforce delivery on Copado uses **Agentia Pro (Source Format Pipelines)** as the deployment mechanism. Agentia Pro wraps and sequences the Salesforce CLI on its backend, enforcing deployment order, managing environment-specific values via Environment Variables, requiring human approval at the appropriate gates, and connecting Testing Center results to pipeline-level quality gates.

For CLI steps the pipeline needs to execute, including `sf agent publish`, `sf agent activate`, and rollback sequences, these can be run manually via the Salesforce CLI or wrapped in Copado Functions for automation and governance. Every step should be documented and, where possible, governed through the pipeline rather than executed manually.

### Deployment Scope Requirement

Committing only `AiAuthoringBundle` while excluding `GenAiPlannerBundle` will succeed at commit time but fail at deployment. `BotVersion.PlannerId` is a required field; deploying without `GenAiPlannerBundle` to a new org fails.

**Agentia Pro Commit Checklist:**

- [ ] `AiAuthoringBundle` (if NGA-enabled agent)
- [ ] `GenAiPlannerBundle` (always for net new; required for Agent Script changes)
- [ ] `Bot` (for net new agents or identity changes)
- [ ] `BotVersion` (for net new agents or scaffold changes; explicitly named, not wildcarded)
- [ ] Supporting `Flow`, `Apex`, `GenAiPromptTemplate` dependencies (if changed)
- [ ] Global `GenAiPlugin` / `GenAiFunction` (if Asset Library components are used or changed)

### Deployment Order

Configure this order in the Agentia Pro pipeline through standard deployment steps. Consult the Copado documentation for guidance on sequencing.

1. Custom objects and fields
2. Apex `@InvocableMethod` wrapper classes
3. Autolaunched Flows
4. GenAiFunction metadata
5. `AiAuthoringBundle` (full agent)
6. Publish (via CLI or Copado Function)
7. Activate (via CLI or Copado Function, human-gated at Production)

### Deployment Steps

Every agent deployment involves more than the metadata Agentia Pro pushes automatically. Agentia Pro supports nine deployment step types for Salesforce Source Format Pipelines, covering a wide range of automated and manual actions:

| Step Type | What It Does |
|---|---|
| **Apex** | Executes an Anonymous Apex script in the destination org. For example, automatically assigning permission sets to specific users once the permission set has been deployed. |
| **Custom Settings** | Deploys data held in custom settings objects, including Id mapping for users, profiles, and the organization Id for hierarchy custom settings in the destination environment. |
| **Data Set - Salesforce** | Commits and deploys Salesforce data changes via data sets. A data set is a snapshot of data stored in a source environment, saved for deployment to other environments. When a data commit is performed on a User Story using a new data template, a step of this type is automatically added. |
| **Data Template - Salesforce** | Deploys data via data templates. The data is retrieved from the source org at the time the deployment job executes, so the data may change based on where the User Story is in the pipeline and when the deployment runs. |
| **Function** | Executes a Copado Function for more complex automations. Consult the Copado documentation for guidance on building and registering Functions. |
| **Manual Task** | Used for steps that cannot be automated through Copado Functions or Salesforce Flows. |
| **Salesforce Flow** | Executes a configured Salesforce Flow, for example to update records, interact with external APIs, or notify users via Slack, email, or other communication platforms. |
| **Custom Job Steps** | Custom step types added to a job template or User Story deployment step. Consult the Copado documentation for guidance on building custom job steps. |
| **Robotics Automation Step** | Automates deployment scenarios that would otherwise require manual configuration changes across multiple orgs, such as enabling or disabling Salesforce features. Particularly relevant for Agentforce delivery, where feature flags and org configuration often differ between pipeline stages. |

Rules for deployment steps:

- All steps must be added before the story is ready for promotion to Integration. Steps discovered late are a Definition of Done failure.
- Each step must specify: what action, which environment, before or after deployment, and who is responsible.
- Steps must be marked complete in Agentia Pro at each environment as they are executed.
- Post-deployment verification steps (confirming the agent is live, the correct version is active, the permission set is assigned) must also be logged.

Consult [https://docs.copado.com/](https://docs.copado.com/) for full documentation on each step type.

### Pre-Release Gate Checklist

- [ ] `sf agent validate --authoring-bundle` passes with zero errors
- [ ] All action targets (Flows, Apex) confirmed present in the target org
- [ ] Testing Center pass rate meets defined threshold at UAT
- [ ] Security test cases reviewed and passed
- [ ] Einstein Agent User configured: `AgentforceServiceAgentUser` PSL + `AgentName_Access` permission set
- [ ] If agent uses RAG: `GenieDataPlatformStarterPsl` PSL assigned before permission set; Default Data Space enabled
- [ ] `AiAuthoringBundle` committed to source control with PR merged and approved
- [ ] Agentia Pro User Story promotion history complete and approved at each stage
- [ ] Agentia Testing quality gate configured and confirmed active for the production stage connection
- [ ] Existing Agentia Testing regression suites (Flows, Apex, UI) confirmed in the quality gate evaluation
- [ ] Copado Environment Variable confirmed for `TARGET_AGENT_USER` in production
- [ ] Prior published agent version number identified and documented (rollback target)
- [ ] Rollback CLI commands prepared and approver named
- [ ] For SOMA: Release Record confirmed to contain all cross-team User Stories; release manager has verified cross-team dependency satisfaction manually
- [ ] All deployment steps logged on the User Story in Agentia Pro
- [ ] Apex test coverage >= 85% confirmed in dev sandbox; quality gate active on Dev-to-Integration stage
- [ ] PMD static analysis: zero critical violations confirmed; quality gate active on Dev-to-Integration stage
- [ ] Copado managed packages updated within the last quarter

### Copado Environment Setup for Agentforce

1. Install VS Code and the Salesforce Extension Pack.
2. Configure Agentia Pro Source Format Pipeline with sandbox environments at each stage (Dev, Integration, UAT, Production).
3. Set Copado Environment Variables for each stage (`TARGET_AGENT_USER`, any org-specific endpoints).
4. Add all Agentforce environment checklist items to the Agentia Pro environment setup process for each stage.
5. Configure the Testing Center test suite name for each pipeline stage's automation.
6. Configure the Agentia Testing quality gate on the Integration-to-UAT and UAT-to-Production stage connections.
7. Configure PMD and Apex Test Results quality gates on the Dev-to-Integration stage connection.
8. Define the deployment step types needed for each stage and add them to the relevant User Story templates.
9. Prepare rollback CLI commands for UAT and Production stages, with the approver named and version number confirmed before each release.
10. Register all team members at [https://success.copado.com](https://success.copado.com) from day one.

**Sample Package Manifest:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>NGA_Service_Agent</members>
        <name>Bot</name>
    </types>
    <types>
        <members>NGA_Service_Agent.v2</members>
        <name>BotVersion</name>
    </types>
    <types>
        <members>NGA_Service_Agent</members>
        <name>AiAuthoringBundle</name>
    </types>
    <types>
        <members>NGA_Service_Agent</members>
        <name>GenAiPlannerBundle</name>
    </types>
    <types>
        <members>*</members>
        <name>Flow</name>
    </types>
    <types>
        <members>*</members>
        <name>ApexClass</name>
    </types>
    <version>66.0</version>
</Package>
```

### Keeping Copado Packages Up to Date

Running outdated Copado packages is one of the most common and most avoidable sources of pipeline problems. Copado now releases on a weekly cadence, which means version-count comparisons are not a useful measure of currency. A time-based cadence is the right frame.

- **Update Copado packages at least quarterly**, and more frequently if the pipeline is active or a release addresses a known issue affecting your org.
- Include package updates in the team's delivery plan with a named owner.
- Subscribe to Copado release communications via the Community.
- Test package updates in a sandbox before applying to production.
- Coordinate updates with the release calendar. Do not schedule a package update immediately before a major agent release.
- Document every update: previous version, new version, date, who performed it, testing done, issues encountered.

### Support and Community

- **Copado Community:** [https://success.copado.com](https://success.copado.com) — the primary support and knowledge-sharing resource. Open break/fix support cases here for bugs, unexpected behavior, or configuration questions.
- **Copado documentation:** [https://docs.copado.com/](https://docs.copado.com/) — source of truth for all product-specific guidance, release notes, and known issues.

---

## Section 13: Pricing

### Salesforce Pricing: Flex Credits

Testing Center runs in sandbox environments consume Flex Credits against the sandbox entitlement. Confirm that each pipeline stage has sufficient Flex Credit entitlement to support both manual testing during development and automated Testing Center runs triggered by the Agentia Pro pipeline. Agentia Testing quality gate executions that call Agentforce channel endpoints consume credits in the same way a real user session would. Account for this in sandbox budgeting.

Salesforce Foundations must be enabled to use Flex Credits.

### Copado Pricing

Copado has its own pricing, separate from Salesforce licensing:

- **Agentia Pro (Source Format Pipelines):** Primarily seat-based.
- **Agentia Testing (formerly Copado Robotic Testing):** A mixture of seat-based and consumption-based licensing.

Engage the Copado account team for pricing details specific to your contract.

### Monitoring Consumption: Two Tools, Two Purposes

**Digital Wallet:** The authoritative source for exact Flex Credit consumption, billing verification, and contractual overage calculations. Use it for billing disputes or contractual review.

**`AiAgentGenerativeAiUsage_std__dlm` DMO in Data 360:** Refreshes every 5 minutes. Suited for near-real-time operational dashboards, trend analysis, and session-level cost attribution. Use this for day-to-day monitoring and cost optimization.

> Use the Digital Wallet for billing truth. Use the DMO for operational intelligence. They are complementary, not competing.

Set **Digital Wallet alerts at 70% and 90% of entitlement.** The 70% alert gives time to investigate. The 90% alert should trigger an immediate review.

---

## Section 14: Monitoring and Closing the Loop

The STDM (Session Trace Data Model) is the primary observability surface for Agentforce in production. It lives in Data 360 and requires `enable_enhanced_event_logs: True` in the agent config block. Agentforce Observability must also be enabled in Setup, and the Default Data Space must be active for the agent user's permission set. Missing any of these three conditions means the STDM is empty.

**Closing the STDM-to-Pipeline Loop**

When STDM monitoring surfaces an error spike (`std__ErrorMessageText__c` on `AIAgentInteractionStep`), the workflow is:

1. Identify the failing interaction using STDM queries.
2. Reproduce the failure in the Agentforce Testing Center as a new test case.
3. Commit the new test case to the relevant Testing Center suite via a new User Story.
4. The new test case runs automatically on the next Agentia Pro pipeline promotion.
5. The Agentia Testing quality gate blocks promotion until the failure is resolved and the suite re-run passes.

STDM tells you what went wrong in production. Testing Center becomes the mechanism that proves it is fixed before the next release reaches users. This is the closed-loop equivalent of writing a unit test for a bug before fixing it.

**Monitoring Habits to Build from Day One**

- **Review abandoned sessions weekly.** Sessions that ended without resolution are the highest-signal source of unresolved failures.
- **Build a dashboard from `AiAgentGenerativeAiUsage`** showing sessions, cost per session, and escalation rate by subagent. This DMO refreshes every 5 minutes.

---

## Section 15: Agentia Pro Plan Objects: Applied to Agentforce Delivery

### The Object Hierarchy

| Object | Definition |
|---|---|
| **Theme** | A wide strategic area of organizational focus; spans multiple epics, applications, and teams |
| **Application** | A product delivering value to a customer group; can contain sub-applications and features |
| **Epic** | A collection of related User Stories |
| **Feature** | A large piece of work delivering business value; made up of User Stories |
| **User Story** | The smallest unit of work; the pipeline artifact that holds commits, promotions, and test links |
| **User Story Task** | A sub-unit of a User Story; typically an action item under eight hours |
| **User Story Dependency** | An informational record linking two related User Stories. Does not block deployment in Source Format Pipelines. |
| **Project** | A proposed or planned undertaking of changes to be made in Salesforce |
| **Release** | Groups User Stories for coordinated promotion and deployment |
| **Sprint** | A time-boxed work period, typically two weeks |
| **Team** | A group of users working together; supports Dependent/Provider relationships between teams |

### Monolithic Agent

| Agentia Pro Plan Object | Application |
|---|---|
| **Theme** | The business initiative the agent serves (e.g., "AI-Powered Customer Self-Service") |
| **Application** | The agent itself; sub-applications for major capability groups |
| **Epic** | Grouped by capability area: foundation, action library, routing and classification, testing |
| **Feature** | A user-facing capability increment (e.g., "Add Order Status Lookup action") |
| **User Story** | One discrete metadata change: an `AiAuthoringBundle` update, a Flow, a classification description. Must include Acceptance Criteria and at least one Testing Center test case. |
| **User Story Task** | Developer checklist: author, validate locally, commit, smoke test, add Testing Center case, log deployment steps |
| **Project** | One Project for the full agent delivery lifecycle |
| **Release** | Groups a sprint's changes for coordinated UAT and production promotion |

### SOMA Architecture

| Agentia Pro Plan Object | Application |
|---|---|
| **Theme** | Shared across all teams; the portfolio-level business goal |
| **Application** | Parent app = the full agent network; sub-applications = each individual sub-agent and the supervisor |
| **Epic** | Each team owns its own Epics independently |
| **Feature** | Cross-team Features (e.g., "New sub-agent available in agent network") reveal coordination requirements |
| **User Story** | Same unit of pipeline work; cross-team User Stories linked via dependency records for visibility. Each must have Acceptance Criteria and Testing Center coverage. |
| **User Story Dependency** | **Informational only in Source Format Pipelines.** Release Records and human approval gates are the actual enforcement mechanism. |
| **Team** | One Team per sub-agent; Dependent/Provider relationships model the runtime architecture |
| **Project** | One Project per sub-agent team (preferred); Release Records coordinate across Projects when needed |
| **Release** | **The primary coordination enforcement mechanism for SOMA.** Independent Releases for isolated changes; coordinated Release Records for cross-team deployments that must ship together. |
| **Sprint** | Each team runs its own cadence independently |

### Critical Distinction: Dependencies vs. Release Records in SOMA

**User Story Dependencies** record that a relationship exists between two stories. Useful for planning. In Agentia Pro Source Format Pipelines, they do not block or gate any pipeline action.

**Release Records** are the actual coordination tool. When two teams' User Stories must arrive in production together, those User Stories are grouped under a single Release Record. The release manager's human approval of that Release Record before the production promotion is the gate that enforces the coordinated deployment.

Architects who communicate this distinction clearly save clients from discovering it during an integration failure.

---

## Section 16: Cost Optimization Reference

Listed in order of impact:

1. **Push deterministic logic.** Every `->` instruction that replaces a `|` instruction saves one LLM call.
2. **Use the EinsteinHyperClassifier for routing.** It is faster and cheaper than a general LLM for classification.
3. **Guard data-fetch actions.** A `has-loaded` guard in `before_reasoning` prevents redundant API calls on follow-up turns.
4. **Limit subagent count.** Salesforce recommends no more than 10 to 15 subagents per supervisor. Exceeding this degrades routing performance and increases per-session LLM calls.
5. **Limit actions per subagent.** No more than 15 actions per subagent.
6. **Use short, specific classification descriptions.** Verbose descriptions reduce EinsteinHyperClassifier precision and increase misrouting.
7. **Set Digital Wallet alerts at 70% and 90% of entitlement.**
8. **Monitor cost per session in the `AiAgentGenerativeAiUsage` DMO.** Baseline cost per session by subagent on week one. Any subagent whose cost-per-session grows without a corresponding increase in resolved sessions is a candidate for architecture review.

> For all Copado-specific configuration guidance, consult [https://docs.copado.com/](https://docs.copado.com/).

---

## Appendix A: Quick Reference: Copado + AgentOps Standards

| Principle | Minimum Standard |
|---|---|
| User Story structure | Who/What/Why with Acceptance Criteria on every story; at least one Testing Center scenario matching Acceptance Criteria |
| Story size | Small enough to complete within a sprint; one discrete agent change per story |
| Commit frequency | Every day, without exception; always before any back promotion or Environment Sync runs |
| Branch management | Let Copado manage all branching; manual Git edits only under explicit Copado Support guidance |
| Deployment batch size | Small and frequent; avoid large waterfall agent releases |
| Developer ownership | Each developer promotes their own code |
| Back promotions | Scheduled automatically via Automation Rule; all developers commit before the scheduled run |
| Environment Sync | Use for Source Format Pipelines v7.29+; automate with an Automation Rule |
| Hotfix back promotion | Sync to all lower environments immediately after any production fix |
| Environment changes | No manual changes in test or production environments, including agent configuration UI |
| Sandbox refreshes | Minimum annually; target quarterly for active agent development teams |
| Base branch (default) | No override needed when stories reach production quickly |
| In-flight stories (same metadata) | Use prior story's feature branch as the base |
| Deploying past a base branch | Recommit with Recreate Feature Branch and reset to pipeline default before continuing |
| Parallel pipelines | Use when teams need isolated sandboxes; not a default requirement |
| Conflict resolution | Always in the Promotion branch only; never in Integration, UAT, or Production |
| Apex test coverage (dev sandbox) | Minimum 85%; target 90%+ |
| Apex test coverage (integration and above) | 75% platform minimum enforced; target 85%+ |
| Apex test classes | Committed in the same User Story as the code they cover |
| PMD static analysis | Zero critical violations before promotion to Integration |
| Pull Request approval | Required before Dev-to-Integration promotion; no self-approval |
| Definition of Done | Defined, documented, automated where possible; applied to every story without exception |
| Pipeline automation | Copado Functions, Automation Rules, and Deployment Steps preferred over manual CLI execution |
| Deployment steps | Logged as Deployment Steps on the User Story in Agentia Pro; no spreadsheets or verbal handoffs |
| User Story statuses | Defined status model with entry/exit criteria documented before go-live |
| Copado Community | All team members registered; support cases opened through Community |
| Copado package updates | Updated at least quarterly; more frequently if the pipeline is active; tested in sandbox before applying to production |
| User Story Dependencies (SOMA) | Informational only; Release Records and human approval gates enforce cross-team sequencing |
| Release Records (SOMA) | Primary coordination enforcement for multi-team releases |
| No fast lanes | Every Agentforce component goes through the full pipeline process |
| AI-generated code | Disclosed in User Story description; reviewed via Commit Changes page diff before entering pipeline |
| gitresolution.json | Verified after every promotion to confirm conflict resolution strategy |
| Rollback | CLI commands prepared and documented; prior version number confirmed before the release window opens |
| STDM failures | Reproduced as Testing Center test cases; fixed before next promotion is unblocked |
