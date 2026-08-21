# Data 360 DevOps Guide for Success Architects

*Updated August 20, 2026*
*This guide was generated using AI with grounding in official Salesforce documentation. Review for accuracy before using.*

---

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Traditional ALM and Salesforce DevOps: The Baseline](#2-traditional-alm-and-salesforce-devops-the-baseline)
  - [2.1 What Traditional ALM Looks Like](#21-what-traditional-alm-looks-like)
  - [2.2 How Salesforce DevOps Maps to That Model](#22-how-salesforce-devops-maps-to-that-model)
  - [2.3 The Properties Teams Take for Granted](#23-the-properties-teams-take-for-granted)
- [3. Where Data 360 Breaks the Traditional Model](#3-where-data-360-breaks-the-traditional-model)
  - [3.1 The Contrast at a Glance](#31-the-contrast-at-a-glance)
  - [3.2 Why This Matters for Your Clients](#32-why-this-matters-for-your-clients)
  - [3.3 The Classic Failure Scenario](#33-the-classic-failure-scenario)
- [4. Data 360 Platform Primer](#4-data-360-platform-primer)
  - [4.1 What Data 360 Is](#41-what-data-360-is)
  - [4.2 Core Object Types](#42-core-object-types)
  - [4.3 Data Spaces](#43-data-spaces)
  - [4.4 The Data Lifecycle](#44-the-data-lifecycle)
- [5. Two Deployment Paths](#5-two-deployment-paths)
  - [5.1 Path A: DevOps Data Kits](#51-path-a-devops-data-kits)
  - [5.2 Path B: Managed Packages with Data Kits](#52-path-b-managed-packages-with-data-kits)
  - [5.3 Choosing the Right Path](#53-choosing-the-right-path)
- [6. Detailed Deployment Workflows](#6-detailed-deployment-workflows)
  - [6.1 DevOps Data Kit Workflow: Sandbox to Production](#61-devops-data-kit-workflow-sandbox-to-production)
  - [6.2 Standard Data Kit Workflow: Managed Package Distribution](#62-standard-data-kit-workflow-managed-package-distribution)
  - [6.3 Packaging Tradeoffs: 2GP vs. 1GP for Data 360](#63-packaging-tradeoffs-2gp-vs-1gp-for-data-360)
  - [6.4 Critical Deployment Considerations](#64-critical-deployment-considerations)
- [7. Known Limitations](#7-known-limitations)
- [8. Common Failure Patterns and Troubleshooting](#8-common-failure-patterns-and-troubleshooting)
  - [8.1 Failure Patterns](#81-failure-patterns)
  - [8.2 Troubleshooting Checklist](#82-troubleshooting-checklist)
- [9. DevOps Best Practices for Data 360](#9-devops-best-practices-for-data-360)
- [10. Tooling and API Overview](#10-tooling-and-api-overview)
  - [10.1 Data 360 vs. Salesforce Platform: Tool Comparison](#101-data-360-vs-salesforce-platform-tool-comparison)
  - [10.2 API Authentication: The Two-Step Process](#102-api-authentication-the-two-step-process)
  - [10.3 DevOps Tool Coverage Warning](#103-devops-tool-coverage-warning)
- [11. Roadmap Context](#11-roadmap-context)
- [12. Appendix: Key Resources](#12-appendix-key-resources)

---

## 1. Introduction

Data Kits now power over 2,000 DevOps deployments and 90,000 app deployments every month. Data Kit reliability and DevOps tooling are consistently cited as the top product asks across the Data 360 customer base. Deployment failures frequently surface as cryptic errors — "DataKit Job Failed due to Internal Error" — and because Data Kits sit in the critical path of feature delivery, these failures escalate quickly to Sev1s.

This guide exists because most clients encountering Data 360 DevOps challenges are not starting from zero. They have working Salesforce pipelines, established ALM practices, and experienced release managers. The problem is not a lack of DevOps maturity. The problem is that Data 360 operates under a fundamentally different set of rules, and the natural instinct to apply existing Salesforce DevOps patterns directly to Data 360 is the source of most escalations.

**This guide covers:**

- How traditional ALM and Salesforce DevOps work, and what properties teams take for granted
- Where and why Data 360 breaks those assumptions
- What Data 360 is and how its core components relate to deployment decisions
- The two distinct deployment paths and when to use each
- Step-by-step workflows, with callouts for gotchas that cause silent or cryptic failures
- Known limitations to plan around rather than get surprised by
- Common failure patterns and a structured troubleshooting approach
- Best practices adapted for Data 360's unique constraints
- Tooling and API guidance, including a direct comparison to standard Salesforce platform approaches

---

## 2. Traditional ALM and Salesforce DevOps: The Baseline

### 2.1 What Traditional ALM Looks Like

Application Lifecycle Management (ALM) is the discipline of managing a software application from initial requirements through retirement. In a mature enterprise implementation, ALM covers:

- **Work management:** Requirements, user stories, and defects tracked in a system of record (Jira, Azure DevOps, Salesforce User Stories in Copado).
- **Version control:** All configuration and code lives in Git. A commit is the unit of change. A branch is the unit of isolation.
- **Environment promotion:** Changes move through a defined pipeline of environments — typically Development, Integration/QA, UAT, and Production — with gates between each.
- **Build and validation:** Automated processes validate each change before promotion: unit tests, static analysis, integration tests.
- **Release governance:** Approval gates, audit trails, and rollback capability ensure that releases can be verified and reversed.

This model is well-understood, well-tooled, and largely environment-agnostic. Teams build muscle memory around it.

### 2.2 How Salesforce DevOps Maps to That Model

Salesforce DevOps maps onto this baseline more cleanly than most platforms:

| ALM Concept | Salesforce Implementation |
|---|---|
| Work items | User stories (native in Salesforce, or in Copado, Jira) |
| Version control | Git (SFDX source format or Metadata API format) |
| Deployment unit | Metadata components (XML/JSON files) |
| Environments | Sandbox orgs (Developer, Developer Pro, Partial, Full) |
| Build validation | Apex tests, PMD static analysis, Copado quality gates |
| Promotion | Change sets, Metadata API deploys, SFDX deploys, Copado promotions |
| Rollback | Prior Git commit, destructiveChanges.xml |
| ISV distribution | Managed packages (1GP/2GP), unlocked packages, AppExchange |

Tools like Copado sit on top of this model, orchestrating promotions, tracking user story commits, enforcing quality gates, and providing pipeline visibility. The Salesforce Metadata API understands the format of the artifacts. Git diffs are meaningful and auditable. Scratch orgs allow fully reproducible development environments. The model is coherent from end to end.

### 2.3 The Properties Teams Take for Granted

When a Salesforce DevOps team is operating well, they rely on a set of assumptions that feel invisible because they always hold true. These matter because Data 360 violates several of them:

- **Metadata is text.** Every component is an XML or JSON file. Git can diff it, merge it, and track its history.
- **Environments are independent.** A sandbox and a production org share a platform but not state. A deployment replaces state in the target.
- **Credentials travel with configuration.** Named Credentials, External Credentials, and similar components are metadata and can be deployed.
- **CI/CD tools understand the format.** Copado, Gearset, Flosum, and similar tools are built on the Metadata API and understand what can be deployed.
- **Rollback is possible.** If a deployment fails or produces regressions, the prior state is recoverable from Git.
- **Unlocked packages are a standard internal distribution mechanism.** They track changes, are source-driven, and are upgradable.
- **Scratch orgs support full feature development.** Ephemeral environments can be created from a definition file, seeded, used, and destroyed.

These assumptions are the foundation of confidence in a well-run Salesforce DevOps practice. Keep them in mind as you read the next section.

---

## 3. Where Data 360 Breaks the Traditional Model

### 3.1 The Contrast at a Glance

| Traditional Salesforce ALM | Data 360 Reality |
|---|---|
| Metadata is XML/JSON text in Git | Data 360 metadata is partially deployable; some components are runtime state that cannot be transported |
| Git diff shows exactly what changed | Data Kits have no native versioning or diff capability |
| CI/CD tools understand the Metadata API format | Most DevOps tools do not fully support Data Cloud metadata types |
| Rollback via prior Git commit or destructiveChanges | No built-in rollback in Data Kits; a failed mid-deployment has no automatic recovery path |
| Credentials and Named Credentials deploy as metadata | Connections and credentials never transport; manual re-authentication is required at every promotion step |
| Environments are independent; deployment replaces state | DevOps Data Kits deploy within the same data space; Standard Data Kits deploy to any data space |
| Scratch orgs are standard for development | Sandbox orgs are required for Data 360; scratch org support requires Partner Business Org enablement via a Partner Community case |
| Unlocked packages are a standard internal delivery mechanism | Unlocked packages are not supported for most Data 360 objects |
| Agentforce and platform metadata deploy together | Agentforce components (e.g., search indexes) cannot be packaged in the same kit as Data 360 components |
| Push upgrades via managed packages are standard | Versioning and push upgrades are only available through managed 1GP/2GP, not through DevOps Data Kits |

### 3.2 Why This Matters for Your Clients

The business impact of these differences is not abstract. It shows up in three concrete ways:

**1. Longer, more manual release cycles.** Without versioning, rollback, or diff tooling, teams cannot automate the same level of validation they apply to platform metadata. Every Data 360 promotion requires human checkpoints that platform metadata promotions can gate automatically.

**2. Higher escalation risk.** Generic error messages mask actionable root causes. A team that knows how to read a Salesforce deployment error log may be completely unprepared for "DataKit Job Failed due to Internal Error" with no additional context. Escalations happen faster and resolve slower.

**3. False confidence from existing tooling.** A client using Copado for their CRM pipeline will reasonably assume they are covered for Data 360. They are not, unless Copado has been explicitly verified to support the specific Data Cloud metadata types in use. This assumption is the single most common source of deployment surprises.

### 3.3 The Classic Failure Scenario

> **Scenario: "We already have a pipeline."**
>
> A retail client has a mature Copado pipeline managing their Sales Cloud and Service Cloud releases. They provision Data 360 and their admin begins building data streams, DMOs, and calculated insights in the sandbox. At release time, the release manager opens Copado and initiates a standard promotion — the same process they use for Apex and Flows.
>
> The promotion either fails silently, partially deploys (leaving the target org in an inconsistent state), or succeeds for the platform components but ignores the Data 360 components entirely. The connection to Snowflake is missing. The calculated insights are broken because their DMO dependencies were not deployed in the right order. The release manager escalates to Salesforce support with a generic internal error message and no Gack ID because the deployment history tab has already refreshed.
>
> **The root cause is not a product defect. It is a collision between a correct assumption (our pipeline handles Salesforce deployments) and an incorrect extension of that assumption (therefore it handles Data 360 deployments).**

---

## 4. Data 360 Platform Primer

### 4.1 What Data 360 Is

Data 360 (formerly Data Cloud) is a cloud-native, metadata-driven data lakehouse platform built on Hyperforce. It consolidates large volumes of data from hundreds of sources, harmonizes that data into unified customer profiles, and makes those profiles available for segmentation, AI, and activation across the Salesforce ecosystem and beyond.

At a business level, Data 360 answers the question: "Who is this customer, across every system we have, and what do we know about them right now?" It brings together CRM data, marketing data, commerce data, event streams, and external warehouse data into a single, governed, real-time view.

At a technical level, it is a lakehouse built on Apache Iceberg and Parquet, running on Hyperforce, with a metadata-driven architecture that stores all data definitions as Salesforce metadata in a fully ACID-compliant RDBMS. This dual nature — lakehouse storage, Salesforce metadata management — is exactly what makes DevOps for Data 360 different from both standard Salesforce DevOps and traditional data warehouse DevOps.

### 4.2 Core Object Types

| Object Type | What It Is | Business Analogy |
|---|---|---|
| Data Lake Object (DLO) | The persistent storage layer; holds ingested data in its original schema | A staging table in a data warehouse |
| Data Model Object (DMO) | The harmonized layer; maps DLO data to the Customer 360 Data Model | A canonical data model entity (e.g., "Customer") |
| Calculated Insight (CI) | An aggregated metric computed from DLOs/DMOs on a schedule or in real time | A KPI report, such as Lifetime Value |
| Data Transform | A batch or streaming transformation job that produces new DLOs or DMOs | An ETL pipeline stage |
| Segment | A filtered audience of unified individuals based on defined criteria | A marketing list or audience definition |
| Data Stream | The ingestion configuration for a specific data source | A data feed or connector |
| Identity Resolution Ruleset | Rules for matching and reconciling records across sources into a unified profile | A golden record matching process |
| Semantic Model | A semantic layer over the data model, supporting Tableau Next and analytics queries | A BI semantic layer or cube |

### 4.3 Data Spaces

Data Spaces are the fundamental logical containers for organizing all data and metadata within Data 360. Every DLO and DMO belongs to a specific data space. Data spaces act as governance and isolation boundaries, enabling organizations to separate data for distinct business units, brands, or regions while maintaining enterprise-wide visibility and compliance.

**Why this matters for DevOps:**

- **DevOps Data Kits** are always deployed to the same data space in the target org. You cannot use a DevOps Data Kit to move data between data spaces.
- **Standard Data Kits** are created from the default data space and can be deployed to any data space in the target org.
- When deploying to a target org, the data space with the same prefix name must exist in both source and target before the deployment begins.

Data spaces also drive access control. Permission sets in Data 360 are natively tied to data spaces, controlling read, write, and administrative operations at that boundary. This is directly relevant to the post-deployment re-authentication and permission-set verification steps every promotion requires.

### 4.4 The Data Lifecycle

Understanding the data lifecycle is essential context for why deployment ordering matters. Data flows through these stages:

1. **Ingestion:** Raw data arrives via connectors, APIs, or SDKs and lands in Data Lake Objects (DLOs).
2. **Transformation:** Batch or streaming transforms produce derived DLOs from source DLOs.
3. **Harmonization:** DLO fields are mapped to Data Model Objects (DMOs) using the Customer 360 Data Model.
4. **Unification:** Identity resolution rules match and reconcile records across sources into unified individual profiles.
5. **Insight and Segmentation:** Calculated Insights aggregate DMO data. Segments group unified individuals by defined criteria.
6. **Activation:** Segments and enriched profiles are delivered to external endpoints such as Marketing Cloud, ad platforms, and CRM records.

Each stage depends on the previous one. A DMO cannot be deployed without its source DLO mappings. A Calculated Insight cannot run without its dependent DMOs and DLOs. A Segment cannot publish without its Calculated Insights. This dependency chain is the reason that deployment sequencing is non-negotiable in Data 360, and it is also why automated tools that do not understand this chain will fail silently.

---

## 5. Two Deployment Paths

### 5.1 Path A: DevOps Data Kits

**What it is:** A DevOps Data Kit is the standard mechanism for promoting Data 360 metadata from a sandbox org to a production org within the same organization. It packages Data 360 components into a deployable unit and uses the Salesforce Metadata API and Salesforce CLI to move them between environments.

**When to use it:**
- Internal development teams moving features from sandbox to production.
- The source and target org share the same data space (same org family).
- The use case is standard sandbox-to-prod promotion, not customer distribution.

**What it packages:** Data Streams, DLOs, DMOs, Calculated Insights, Semantic Models, Data Transforms, Identity Resolution Rulesets, Data Graphs, and Tableau Next assets.

**What it does not package:**
- Connection credentials (these must be re-authenticated manually in the target org).
- KQ_ (key qualifier) fields, which are auto-excluded.
- **Einstein Retrievers and Search Indexes** — unmanaged-package support went GA in July 2026, but DevOps Data Kit support remains unreliable in practice due to multiple recent Sev1s involving Search Indexes stuck or returning incomplete data. Manual recreation is still the safest path for sandbox-to-prod promotion.
- **Governance policies (PolicyRuleDefinitionSet/PolicyRuleDefinition)** — CLI/source-based deployment is not yet broadly supported (currently in limited release, targeting a near-term upcoming release). Use Change Sets or Data Kit (RLS) instead, which are the fully supported paths today.

**Key constraint:** DevOps Data Kits have no versioning, no rollback, and no diff capability. Every change requires building a new kit from scratch.

### 5.2 Path B: Managed Packages with Data Kits

**What it is:** A managed package (1GP or 2GP) wraps a Standard Data Kit and allows it to be versioned, upgraded, and distributed to subscriber orgs — including customers outside the publisher's org family.

**When to use it:**
- ISVs and partners distributing Data 360 solutions on AgentExchange or AppExchange.
- Organizations deploying to multiple customer orgs that are not in the same org family.
- Scenarios requiring versioning, push upgrades, or intellectual property protection.

**Package types:**

| Type | Upgradable | Versioning | IP Protection | Use Case |
|---|---|---|---|---|
| Managed 1GP | Yes | Yes | Yes | AppExchange distribution, simpler dependency trees |
| Managed 2GP | Yes | Yes | Yes | Modular packaging, Git-native development; see tradeoffs in section 6.3 |
| Unmanaged | No | No | No | One-time sharing; all content editable after install |
| Unlocked | N/A | N/A | N/A | **Not supported for Data 360 objects** |

**Critical advisory — Dedicated Package Isolation:** When creating a managed package that includes Data 360 metadata, the Data 360 metadata must be isolated in its own dedicated package. It cannot be mixed with other Salesforce metadata (Apex, Flows, custom objects unrelated to Data 360). Create package dependencies between your dedicated Data 360 package and any related packages.

**Metadata locking:** All Data 360 feature metadata in a managed package is locked after deployment. Subscribers can add entities but cannot modify or delete any deployed mappings or entities. If modifications are attempted on locked metadata, they are overwritten when the data kit is redeployed. This is intentional; it is a governance control for managed ISV distributions.

### 5.3 Choosing the Right Path

| Situation | Recommended Path |
|---|---|
| Moving features from sandbox to production within the same org | DevOps Data Kit (Path A) |
| Distributing a Data 360 solution to customer orgs | Managed Package + Standard Data Kit (Path B) |
| Building on AgentExchange or AppExchange | Managed Package + Standard Data Kit |
| Deploying enrichments or direct DMO relationships across orgs | See Section 6.3: both 1GP and 2GP have specific failure modes |
| One-time sharing with a trusted partner | Unmanaged Package |
| Internal reuse with edit rights preserved | Unmanaged Package |

> **Note for Success Architects:** Most enterprise clients will use Path A for internal delivery. Path B becomes relevant when a client is building an ISV product, deploying to a multi-org architecture, or distributing pre-built Data 360 configurations across subsidiaries.

---

## 6. Detailed Deployment Workflows

### 6.1 DevOps Data Kit Workflow: Sandbox to Production

**Prerequisites before starting:**
- Data 360 must be enabled and provisioned in both the sandbox and the production org.
- A data space with the same prefix name must exist in both orgs.
- Target org CRM objects and fields that Data 360 components depend on must already exist — Data Kits do not create underlying CRM schema.
- A deployment connection between the production org and the sandbox org must be authorized.
- Salesforce CLI and VS Code with Salesforce Extension Pack (Expanded) must be installed.

**Step 1: Develop in Sandbox**

Build DLOs, DMOs, Transforms, Segments, and other components in the sandbox org. Name connectors with environment suffixes from the very first day (for example, "Snowflake_DEV", "Snowflake_PROD"). This prevents name collision issues during promotion and avoids a known edge case where internal suffix-stripping logic throws exceptions on short connector dev names.

**Step 2: Create the DevOps Data Kit**

In Data Cloud Setup in the sandbox org, navigate to Developer Tools and select Data Kits. Create a new kit and select DevOps as the type. Add the components you want to deploy: Data Streams, DLOs, Calculated Insights, Data Graphs, and other supported types.

**Step 3: Review the Publishing Sequence**

Click Publishing Sequence before publishing. The system publishes components in order of creation date by default. When there are dependencies, you must adjust the sequence manually. The key rule: dependencies must appear before the components that depend on them. If a segment relies on a Calculated Insight, the Calculated Insight must be sequenced first. If a DMO depends on a DLO mapping, the DLO must be sequenced first.

**Step 4: Download the Manifest**

In the sandbox org under Data Kits, select the DevOps Data Kit and click Download Manifest. This produces a package.xml file containing all metadata components related to the kit. This file is used in your Salesforce DX project to retrieve the data kit metadata.

**Step 5: Retrieve Metadata into the SFDX Project**

Use the package.xml file to retrieve data kit metadata via Salesforce CLI. Delete any KQ_ key qualifier files from the project before deployment — these are auto-excluded from kits but may appear in retrieval and will cause errors if included in the deployment.

**Step 6: Deploy to the Target Org**

Deploy the retrieved metadata to the production org using Salesforce CLI. Monitor deployment status via the Deployment History tab in Data Cloud Setup. If a component fails, the process stops and subsequent components in the sequence are not deployed. Take a screenshot or copy the error details immediately — the deployment history tab may refresh and clear before you can capture the Gack ID.

**Step 7: Re-Authenticate Connections**

After deployment, navigate to Connectors in the production org and identify any connectors showing an Inactive status. Re-authenticate each one. This is mandatory, not optional. Connection credentials are never transported during any Data 360 deployment.

**Step 8: Verify Permission Sets**

Confirm that the correct Data 360 permission sets are assigned to users in the target org. The standard permission sets are: Data Cloud Admin, Data Cloud Architect, Data Cloud Activation Manager, and Data Cloud User. Use standard permission sets rather than custom ones; standard sets are automatically updated by Salesforce with each release, while custom sets must be manually maintained.

**Step 9: Validate**

Test data flows, Calculated Insights, and Segment outputs in the target org. Do not assume that a successful deployment status means a correct operational state. Validate each functional layer.

### 6.2 Standard Data Kit Workflow: Managed Package Distribution

**Prerequisites:**
- A Developer Edition org with managed package support enabled.
- Data Cloud Architect permission set.
- Create AgentExchange Packages and Upload AgentExchange Packages permissions.

**Step 1: Create the Standard Data Kit**

In the Developer Edition org, navigate to Data Cloud Setup and create a new Data Kit. Select Standard as the type. Add Data 360 features by clicking Add in the appropriate section. Add and save activations in small batches — saving a large number of activations simultaneously can cause timeouts.

**Step 2: Add Dependencies Manually**

When adding Calculated Insights, manually add all dependencies, including child Calculated Insights, DMOs, DLOs, and Data Graphs. Without explicit dependency inclusion, the deployment of the insight will fail in the target org.

When adding DLOs, note that only standalone DLOs appear when using the Add option under the Data Kits tab. If your workflow includes DLO-to-DMO output mappings, the Output DLOs must be explicitly added to the kit configuration — they are not included automatically.

**Step 3: Review and Adjust the Publishing Sequence**

Click Publishing Sequence and validate the order. Adjust for dependencies: Calculated Insights before Segments that depend on them; source DLOs before DMO mappings; foundational components before derived ones.

**Step 4: Publish the Data Kit**

Click Publish. The data kit is now ready to be added to a package.

**Step 5: Add to a Package**

In Setup, navigate to Package Manager. Create or select an existing package. In Components, click Add, select Data Package Kit Definition as the component type, and select your standard data kit. Click Add to Package, then Upload to generate a package installation URL.

Ensure that source and target DLOs have identical names in both the publisher and target orgs before uploading.

**Step 6: Install in the Target Org**

Use the installation URL to install the managed package in the target org. Admin user permissions are required for installation.

**Step 7: Deploy Data Kit Components**

In the target org, navigate to Data Kits under Developer Tools. Open the installed data kit and click Data Kit Deploy. Select the data space, add the connection org details, and click Deploy. Deployments follow the order defined in the publisher org.

**Step 8: Re-Authenticate Connections**

Connections and credentials are never included in any data kit deployment, regardless of connector type. A compatible connector must already exist in the target org before deploying. After installation, verify that all connectors are active and re-authenticate any that are not.

### 6.3 Packaging Tradeoffs: 2GP vs. 1GP for Data 360

> **Engineering status note:** Both 1GP and 2GP have documented failure modes specific to Data 360 scenarios. A platform-level fix addressing both is an active engineering program, not a settled problem. Advise clients to validate their specific scenario before committing to either path, and check current release notes for updates.

Neither 1GP nor 2GP is universally the right answer for Data 360 managed package deployments. Each has a distinct failure mode. The right choice depends on what is being deployed.

**Where 1GP fails: FieldSrcTrgtRelationship dependency sequencing**

When a deployment includes a `FieldSrcTrgtRelationship` (the metadata record that defines a direct DMO relationship) alongside CRM customizations that reference that relationship — such as page layouts, Flows, or Apex classes — 1GP cannot guarantee the order in which those components deploy in the target org. All components in a 1GP package deploy together without controlled sequencing. If the referencing customization is validated before the relationship metadata is created, the deployment fails with a "Missing FieldSrcTrgtRelationship Reference for DMO Relationship" error.

2GP resolves this by allowing the relationship metadata to live in a first package and the referencing customizations to live in a dependent second package, installed in a defined sequence.

**Where 2GP fails: Custom DMOs and Data Cloud-triggered Flows**

When a 2GP package includes a custom DMO and a Data Cloud-triggered Flow that references that DMO, `sf package version create` fails during package version creation. The reason is that the temporary build org used during 2GP version creation does not get Data Cloud's off-core components provisioned, even if the scratch org definition requests Data Cloud features. The custom DMO is created in the build org but stays in an Inactive or Processing state. When the Flow is validated against it, the validation fails because the DMO is not active.

In this scenario, 1GP avoids the failure because 1GP does not create a temporary build org for validation during upload in the same way.

**Decision guide:**

| Scenario | Recommended Package Type | Reason |
|---|---|---|
| Direct DMO relationship with referencing CRM customizations (page layouts, Flows, Apex) | 2GP (split into two packages) | 1GP cannot sequence FieldSrcTrgtRelationship before referencing components |
| Custom DMO with a Data Cloud-triggered Flow in the same package | 1GP | 2GP build org cannot provision Data Cloud off-core; custom DMO stays Inactive during version create |
| Standard DMOs only, no custom DMOs, no triggered Flows | Either; 2GP preferred for Git-native workflows | No known blocking failure mode for either type in this configuration |
| Custom DMOs without triggered Flows or referencing CRM customizations | Either; validate in a sandbox before committing | Lower risk scenario; test the specific combination |

**2GP workflow for FieldSrcTrgtRelationship deployments (where 2GP is appropriate):**

**Step 1:** In a Salesforce DX project, develop foundational CRM metadata in a sandbox: custom objects and custom fields.

**Step 2:** Configure the direct DMO relationship. This creates a `FieldSrcTrgtRelationship` record.

**Step 3:** Create a Data 360 data kit in the sandbox containing all custom Data 360 metadata. Review and publish the kit to confirm all dependencies are included.

**Step 4:** Retrieve the metadata for CRM components, the data kit, and the relationship into the Salesforce DX project.

**Step 5:** Create the first 2GP package. This package contains: foundational CRM metadata (custom objects, custom fields), the `FieldSrcTrgtRelationship` and its custom lookup field, and the data kit.

**Step 6:** In the same sandbox, create additional CRM customizations — page layouts, Apex classes, Flows — that reference the direct DMO relationship. Retrieve these into the project.

**Step 7:** Create the second 2GP package. This package contains the CRM customizations that reference the direct DMO relationship and declares a dependency on the first package.

**Step 8:** Install both packages in the target org in sequence: foundational package first, customization package second.

### 6.4 Critical Deployment Considerations

These gotchas are documented in Salesforce Help and are responsible for a significant proportion of Data 360 deployment failures. Review each one before any deployment.

**Calculated Insights dependencies must be added manually.** When you add a Calculated Insight to a data kit, its dependencies are not automatically included. You must manually add child Calculated Insights, DMOs, DLOs, and Data Graphs that the insight depends on. Missing dependencies cause the insight deployment to fail.

**Save activations in small batches.** When building a data kit that includes activations, add and save them in small batches. Attempting to save a large number simultaneously causes the operation to time out and fail silently.

**Zero Copy data stream name parity is required.** For Zero Copy data streams using Google BigQuery, Snowflake, Databricks, or Redshift connections, the database, schema, and table names must be identical between your publisher org and the target org. A name mismatch causes deployment failure or produces a broken stream in the target.

**Output DLOs for DLO-to-DMO mappings must be explicitly added.** If your configuration includes DLO-to-DMO output mappings and you want those mappings carried over during deployment, the Output DLOs themselves must be explicitly added to the Data Kit configuration. They are not included automatically.

**Batch Data Transform schedules activate immediately in the target org.** When a Batch Data Transform is deployed via a data kit, the transform's schedule is included and becomes active in the destination org upon installation. If the schedule runs before the target org is fully validated, it may process against incomplete or incorrect data. Disable or update transform schedules in the target org immediately after deployment if needed.

**DLO schema must be synchronized before deployment.** If the target org contains DLO fields that are missing from the source org's DLO, deployment will fail with: `Unable to update the DLO: <field_name>`. Synchronize schemas between source and target before deploying.

**Standard Data Kits must be created from Developer Edition orgs only.** Using a non-Developer Edition org as the source for a Standard Data Kit is not supported.

---

## 7. Known Limitations

| Limitation | Detail |
|---|---|
| No versioning in DevOps Data Kits | Every change requires building a new DevOps Data Kit from scratch. There is no incremental update model. Note: Managed packages (1GP/2GP) do support versioning. |
| Connections never transport | Credentials and connections must be manually re-authenticated in the target org at every promotion step, regardless of deployment path or connector type. |
| No rollback | A failed deployment mid-sequence has no built-in rollback. Subsequent components are not deployed after a failure, leaving the target in a partial state. |
| Unlocked packages not supported | Unlocked packages are not supported for Data 360 objects. Do not use them for Data 360 metadata. |
| Dedicated package isolation required | Data 360 metadata must be isolated in separate packages from other Salesforce metadata when using managed packages. |
| Metadata locking in managed packages | Deployed components in managed packages are locked. Subscribers can add entities but cannot modify or delete deployed mappings or entities. Overwritten on redeploy. |
| Governance policies (PolicyRuleDefinitionSet/PolicyRuleDefinition) | CLI/source-based deployment is not yet broadly supported — currently in limited release, targeting a near-term upcoming release. Use Change Sets or Data Kit (RLS) instead, which are the fully supported paths today. |
| Einstein Retrievers and Search Indexes | Unmanaged-package support went GA in July 2026. DevOps Data Kit support remains unreliable in practice due to multiple recent Sev1s involving Search Indexes stuck or returning incomplete data. Manual recreation is still the safest path for sandbox-to-prod promotion. |
| Retriever deploys: direction constraints | Only sandbox-to-prod merge-back is supported via DevOps Data Kit. Sandbox-to-sandbox and prod-to-prod are not supported. Sandbox-to-sandbox support is an active gap with a formal product-input ticket pending — not yet shipped as of August 2026. |
| Private Connect | Not yet supported in Data Kits. |
| Agentforce and Data 360 components cannot be co-packaged | Agentforce components use Metadata API and change sets. Data 360 components use Data Kits. These cannot be combined in the same kit. |
| Scratch org support is limited | Sandbox orgs are the standard development environment for Data 360. Scratch org support requires Partner Business Org enablement via a Partner Community case. This is not GA for all customers. |
| Reverse promotion (prod to sandbox) | Technically possible but not the designed direction. Connector name collisions are a specific risk. Core metadata must pre-exist in the target. |
| Partial Metadata API support | The Salesforce Metadata API provides partial support for Data 360 metadata types. Not all components can be retrieved or deployed via Metadata API. Check the Metadata Coverage Report for current support. |
| 1GP and 2GP both have Data 360-specific failure modes | Neither packaging type is universally correct for all Data 360 scenarios. See Section 6.3 for scenario-specific guidance. |
| FTest Framework limited to Standard/File-Based Data Kits | The FTest framework does not support DevOps Data Kit packaging or Change Set-based deployments. It only applies to Standard (File-Based) Data Kits. Additionally, FBDK only supports Standard DMOs — custom DMOs and custom fields on standard DMOs are not supported. |

---

## 8. Common Failure Patterns and Troubleshooting

### 8.1 Failure Patterns

**Generic internal errors masking actionable root causes**

The message "DataKit Job Failed due to Internal Error. Please reach out to support team with ID: XXXX" appears across many unrelated root causes. Duplicate-key violations on setup entities, invalid or inactive DMO relationship fields, and malformed Semantic Model payloads have all produced this exact same generic message. The error does not distinguish between customer-actionable issues and engineering bugs. Salesforce engineering is actively working to improve error message specificity, but treat any internal error as potentially actionable until you rule out the common causes.

**Deployment history clears before Gack ID capture**

The local deployment history tab in Data Cloud Setup refreshes and may clear before you can copy the Gack ID and error details. Take a screenshot or copy the full error message and ID immediately when a deployment fails.

**Calculated Insights fail due to missing dependencies**

If a Calculated Insight's child insights, DMOs, or DLOs were not explicitly added to the kit, the insight deployment will fail in the target org with an error that may not immediately identify the missing dependency. Cross-reference the CI's dependency graph against the kit contents before deploying.

**DLO-to-DMO mappings not carried over**

A deployment appears to succeed but the DMO relationships are missing in the target org. This happens when Output DLOs were not explicitly added to the kit configuration. The mapping metadata has nowhere to attach.

**Zero Copy data stream broken in target org**

The data stream deploys but fails to run in the target org. Database, schema, or table names differ between publisher and target. Cross-check all three naming elements before deploying Zero Copy streams.

**Batch Data Transform fires unexpectedly**

A transform runs in the target org immediately after installation, before the team intended. The schedule was included in the kit and activated on install. Disable or update transform schedules immediately post-deployment if runs need to be controlled.

**Activation timeout on data kit save**

Saving a large number of activations simultaneously in the data kit UI causes a timeout and the save operation fails silently. Add activations in small batches and save between batches.

**Connector name edge case exceptions**

Internal logic that strips sandbox suffixes from connector names can throw exceptions (out-of-bounds string operations) when a connector's dev name is shorter than expected. Use consistent, full-length connector naming conventions from the start.

**DMO relationship errors that appear correct**

"Field is not a valid relationship field or its relationship is inactive" can surface even when the relationship is visibly present in the org. The issue is activation status, not presence. Validate that the relationship is both present and active.

**CI/CD pipeline Semantic Model payload errors**

"Post request failed with bad payload" during automated pipeline deployments has been linked specifically to Semantic Model components. If CI/CD is failing with this error, isolate the Semantic Model and test it independently.

**Batch Data Transform failures in larger kits**

Batch Data Transforms are a recurring specific failure point in larger kit deployments. Deploy transforms in isolation if they are causing kit-level failures and reintroduce them after other components are stable.

**2GP version creation failing on custom DMOs with triggered Flows**

During `sf package version create`, a 2GP build org cannot provision Data Cloud off-core components. A custom DMO stays Inactive or Processing in the build org, causing any Data Cloud-triggered Flow that references it to fail validation. If this is the scenario, switch to 1GP. See Section 6.3.

**1GP failing on FieldSrcTrgtRelationship with referencing customizations**

If a direct DMO relationship and its referencing CRM customizations (Flows, page layouts, Apex) are in the same 1GP package, the deployment may fail because 1GP cannot sequence the relationship metadata before the components that reference it. If this is the scenario, switch to 2GP with a split package approach. See Section 6.3.

**Search Indexes stuck or returning incomplete data after DevOps Data Kit deployment**

Even where a Search Index component appears to deploy successfully via a DevOps Data Kit, multiple recent Sev1s have involved indexes that are stuck in a processing state or return incomplete results in the target org. Until DevOps Data Kit support is confirmed reliable, recreate Search Indexes manually in the target org after promotion.

**Retriever child components unsynced after sandbox refresh**

After a sandbox refresh, retrievers may have child components that are out of sync, causing the merge-back deployment to fail or produce incorrect results. The confirmed workaround is to manually delete and recreate the entire retriever ensemble to force a resync into AIMS before attempting the sandbox-to-prod promotion.

### 8.2 Troubleshooting Checklist

1. **Capture the Gack ID immediately.** Do not navigate away from the deployment history tab. Screenshot or copy the full error message and ID before anything else.

2. **Check for KQ_ field errors first.** Key qualifier fields are a common early culprit in deployment failures. Confirm they were removed from the project before deploy.

3. **Validate DMO relationship status.** If the error mentions a relationship field, confirm both its presence and its active status in the source org.

4. **Verify Calculated Insight dependencies.** Cross-reference the insight's dependency graph against the kit manifest. All child insights, DMOs, DLOs, and Data Graphs must be explicitly included.

5. **Check Output DLO inclusion.** If DLO-to-DMO mappings are missing in the target, confirm Output DLOs are in the kit configuration.

6. **Isolate Semantic Model components.** If deploying via CI/CD and hitting payload errors, test the Semantic Model component alone before including it in the full kit.

7. **Verify Zero Copy name parity.** Confirm database, schema, and table names are identical between publisher and target orgs for all Zero Copy streams.

8. **Distinguish customer-actionable from engineering bugs.** If the issue is a missing field, missing DLO, incorrect permission, or misconfigured component, it is customer-actionable. If no actionable cause can be identified after checking all of the above, it is a candidate for escalation.

9. **Escalate with full context.** Provide the Gack ID, source and target org IDs, data kit name, kit type (DevOps or Standard), the component that failed, and the full error text. Internal channels: `#cdp-core-datakit`, `#support-data-cloud-swarming`.

---

## 9. DevOps Best Practices for Data 360

These recommendations are framed as: what a well-run Salesforce DevOps team expects to have, and how to approximate that for Data 360.

**Separate Data 360 deployments from platform metadata deployments.**
Flows, Apex, and custom objects deploy through the Metadata API. Data 360 components deploy through Data Kits. These are different mechanisms, different toolchains, and different sequencing rules. Mixing them in the same release operation causes sequencing surprises and makes failure diagnosis significantly harder.

**Use dedicated packages for Data 360 metadata.**
When using managed packages, Data 360 metadata must live in its own package, isolated from other Salesforce metadata. Create explicit package dependencies to manage the relationship between the Data 360 package and any related platform packages.

**Evaluate 2GP vs. 1GP against your specific scenario.**
Neither is universally correct. Consult the decision guide in Section 6.3, test your specific component combination in a sandbox before committing to a packaging strategy, and monitor the engineering roadmap for platform-level fixes to both failure modes.

**Name connectors with environment suffixes from day one.**
Use a consistent convention such as `Snowflake_DEV`, `Snowflake_QA`, `Snowflake_PROD`. This prevents name collisions during promotion and avoids the connector suffix-stripping edge case that causes out-of-bounds exceptions.

**Review and validate the Publishing Sequence before every publish.**
Do not rely on the default creation-date ordering. Explicitly review and adjust the sequence to match your dependency graph: DLOs before DMOs, DMOs before Calculated Insights, Calculated Insights before Segments that depend on them.

**Manually add all Calculated Insight dependencies.**
When including a CI in a kit, explicitly add all its dependencies: child CIs, DMOs, DLOs, and Data Graphs. Assume nothing is included automatically.

**Add activations in small batches.**
Add and save activations in small groups rather than all at once. Large batch saves cause timeouts.

**Disable or review Batch Data Transform schedules after deployment.**
Transforms activate their schedules immediately in the target org. Decide whether you want transforms running before full validation, and disable schedules if not.

**Pair Data Kits with source control.**
Data Kits have no native versioning. Pairing them with a Git repository — storing the retrieved metadata from the Salesforce DX project — provides the version history, diff capability, and audit trail that the kits themselves lack. This is the closest approximation to the Git-based workflow teams are used to.

**Validate target org prerequisites before every deployment.**
Confirm that required CRM objects and fields exist in the target org. Confirm the data space with the correct name prefix exists. Do not assume the target is ready.

**Verify that your DevOps toolchain actually covers Data 360 metadata.**
A client using Copado, Flosum, or any other CI/CD tool for their CRM pipeline is not automatically covered for Data 360 metadata types. Verify explicitly which Data Cloud metadata types are supported by the tool version in use. Failures often force a fallback to UI-based deployment.

**Use the FTest Framework for Standard/File-Based Data Kits only.**
The FTest Framework supports automated testing of deploy, undeploy, upgrade, locking, and error-logging scenarios — but only for Standard (File-Based) Data Kits. It does not support DevOps Data Kit packaging or Change Set-based deployments. Additionally, FBDK only supports Standard DMOs; custom DMOs and custom fields on standard DMOs are not currently supported. Do not assume FTest coverage extends to DevOps Data Kits.

**Use Change Sets or Data Kit (RLS) for governance policy promotion.**
PolicyRuleDefinitionSet/PolicyRuleDefinition components are not yet broadly supported via CLI or source-based deployment. Change Sets and Data Kit (RLS) are the fully supported paths today. Watch release notes for CLI support, which is in limited release targeting a near-term release.

**Recreate Search Indexes manually for sandbox-to-prod promotions.**
Unmanaged-package support for Einstein Retrievers went GA in July 2026, but DevOps Data Kit support for Search Indexes remains unreliable. Manual recreation in the target org is the safest current approach.

**Resync retriever child components after any sandbox refresh.**
If a sandbox has been refreshed, validate that all retriever child components are in sync before attempting a merge-back deployment. If they are not, delete and recreate the entire retriever ensemble to force a resync into AIMS before promoting.

**Know the synchronization boundary between dev, test, and production.**
Not all Data 360 components need to exist in every environment:
- **Non-structural components** (Calculated Insights, Segments, Activations) generally only need to exist in environments where they are being actively tested or used.
- **Structural components** (Data Model changes, Data Streams, Connections, new DLO-to-DMO mappings) must exist in dev and test before you can build or validate on top of them.

---

## 10. Tooling and API Overview

### 10.1 Data 360 vs. Salesforce Platform: Tool Comparison

| Task | Data 360 Approach | Salesforce Platform Approach |
|---|---|---|
| Migrate metadata between orgs | DevOps Data Kit, Unmanaged Package, 2GP Managed Package, Data 360 Metadata API | Unlocked Package, DevOps Center, Scratch Orgs, Salesforce Metadata API |
| Distribute apps to customers | Data Kit + Managed Package (1GP or 2GP) | Managed Package (1GP or 2GP) |
| Development and testing environment | Sandbox org with Data 360 (GA); Scratch org (Partner Business Org enablement required via Partner Community case) | Sandbox org; Scratch org (standard) |
| Managed package generation | 1GP and 2GP with Data Kits | 1GP and 2GP |
| API authentication | Two-step: Salesforce access token exchanged for Data 360 tenant-specific access token | Standard OAuth to org MyDomain endpoint |
| SOQL queries | Supported subset of SOQL via Connect API; full ANSI SQL via Data 360 Query API | Full SOQL via Salesforce REST API and Apex |
| Metadata API coverage | Partial: covers specific Data 360 metadata types only | Full coverage of all Salesforce metadata types |

### 10.2 API Authentication: The Two-Step Process

Data 360 API authentication requires two sequential steps. This differs from standard Salesforce API authentication and must be understood when building integrations or automating deployments. Interactive browser-based flows are appropriate for user-facing applications; server-to-server DevOps automation should use JWT Bearer or a Connected App with client credentials.

**Step 1: Authenticate to Salesforce and obtain a Salesforce access token.**

For server-to-server DevOps automation, use the JWT Bearer flow:

```
POST https://MY_DOMAIN_NAME/services/oauth2/token
Content-Type: application/x-www-form-urlencoded

grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer
assertion=SIGNED_JWT_TOKEN
```

The response includes a `SALESFORCE_ACCESS_TOKEN` and the instance URL for the org.

> **Note:** The Connected App must be pre-authorized. The JWT assertion must be signed with the private key corresponding to the certificate uploaded to the Connected App. If using an interactive user-facing flow rather than server-to-server automation, an authorization code grant is appropriate for Step 1, but this is not the typical DevOps use case.

**Step 2: Exchange the Salesforce access token for a Data 360 tenant-specific access token.**

```
POST https://MY_DOMAIN_NAME/services/a360/token
Content-Type: application/x-www-form-urlencoded

grant_type=urn:salesforce:grant-type:external:cdp
subject_token=SALESFORCE_ACCESS_TOKEN
subject_token_type=urn:ietf:params:oauth:token-type:access_token
```

The response returns a `DATA_CLOUD_ACCESS_TOKEN` and a tenant-specific `DATA_CLOUD_INSTANCE_URL`. All subsequent Data 360 API calls must use this tenant-specific endpoint and this token, not the standard Salesforce instance URL.

**Why this matters for DevOps:** Any automated pipeline that calls Data 360 APIs — for deployment verification, data validation, or test execution — must implement this two-step flow. Standard Salesforce OAuth libraries and Named Credential configurations designed for the Salesforce platform will not work with Data 360 APIs without modification to handle Step 2.

**Required OAuth scopes for Data 360 API access:**

| Scope | Purpose |
|---|---|
| `cdp_query_api` | ANSI SQL queries against Data 360 data |
| `cdp_profile_api` | Manage Data 360 profile records |
| `cdp_ingest_api` | Access Ingestion API |
| `api` | Standard Salesforce API access |
| `refresh_token` | Obtain a refresh token for offline access |

### 10.3 DevOps Tool Coverage Warning

Tools like Copado and Flosum are built on the Salesforce Metadata API and are designed for standard Salesforce metadata types. They do not automatically cover all Data Cloud metadata types. A client who uses Copado for their Sales Cloud and Service Cloud pipeline should not assume that their Data 360 components are managed by the same pipeline without explicit verification.

When a third-party DevOps tool does not support a specific Data Cloud metadata type, the typical result is not a clear error. The component is silently skipped or partially deployed, leaving the target org in an inconsistent state. Always verify toolchain coverage against the specific Data Cloud metadata types in use, and be prepared to fall back to UI-based or CLI-based deployment for unsupported types.

---

## 11. Roadmap Context

Salesforce engineering has explicitly acknowledged that deploying Data 360 metadata between environments today is more manual and more fragile than standard Salesforce platform deployments, and is actively tracking improvements across multiple delivery horizons.

Known areas under active development:
- **1GP and 2GP Data 360 packaging failures:** A platform-level fix addressing both the 2GP build org provisioning failure and the 1GP dependency sequencing failure is an active engineering program. Neither is a permanent limitation, but neither has a confirmed release date. Monitor release notes.
- **Governance policy CLI deployment:** PolicyRuleDefinitionSet/PolicyRuleDefinition CLI support is in limited release, targeting a near-term upcoming release. Change Sets and Data Kit (RLS) are the supported paths in the meantime.
- **Einstein Retrievers and Search Indexes:** Unmanaged-package support reached GA in July 2026. DevOps Data Kit support is unreliable in practice and remains an active area of investigation following recent Sev1s.
- **Retriever sandbox-to-sandbox support:** Currently unsupported via DevOps Data Kit. A formal product-input ticket is pending as of August 2026. Monitor release notes for updates.
- **Error message specificity:** Engineering teams are auditing failure scenarios to customer-actionable errors from internal bugs, and adopting the Data Kit User Exception Framework to improve error messaging clarity.
- **FTest coverage for Standard Data Kits:** Feature teams are building FTest coverage for FBDK scenarios. Coverage does not currently extend to DevOps Data Kits or custom DMOs.
- **Versioning and incremental updates:** The absence of native versioning in DevOps Data Kits is a recognized gap.
- **Private Connect support in Data Kits:** Tracking for a future release.
- **Scratch org support:** Available today for partners via Partner Business Org enablement. GA availability is evolving.

**Guidance for client conversations:** Frame current limitations as a maturing platform, not a broken one. The 2,000+ DevOps deployments and 90,000+ app deployments per month demonstrate real-world scale and reliability. The gaps are well-understood and on the roadmap. The tactics in this guide are the currently supported approaches, and they work reliably when followed correctly.

Always validate specific limitations against current release notes before advising clients — some of these gaps may close between the publication of this guide and your conversation.

---

## 12. Appendix: Key Resources

**Official Salesforce Documentation**
- Salesforce Help: Packaging in Data 360
- Salesforce Help: Data Kits in Data 360
- Salesforce Help: Considerations for Data Kits in Data 360
- Salesforce Help: Create and Publish a Standard Data Kit
- Salesforce Help: Packaging Data 360 Enrichments (2GP)
- Salesforce Help: Data 360 Extensibility Readiness Matrix
- Salesforce Help: Metadata Components for Data 360 Cheat Sheet
- Data Cloud Connect REST API Guide and Reference
- Data 360 Developer Guide
- Data 360 and Integration: Architecture Center Guide
- Trailhead: Packaging and Data Kits in Data Cloud

**Reference Tools**
- Metadata Coverage Report (check for current Data 360 metadata type support)
- Data 360 Connect API Postman Collection
- Salesforce CLI reference: `sf package version create`, `sf package create`
