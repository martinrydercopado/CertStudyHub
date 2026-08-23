# Data 360 from the Ground Up: The NTO Story

### Harmonize → Unify → Segment → Activate

> **Note:** As of October 14, 2025, Data Cloud was rebranded **Data 360**. Same product, new name. You will see both terms in older docs and Trailhead modules.

---

## The Cast

**Pia Larson** is NTO's enterprise architect. She is responsible for the data model — deciding what goes where, what maps to what, and making sure the whole foundation is solid before anyone builds on top of it. If Data 360 were a construction site, Pia pours the concrete.

**Luna** is the data quality specialist. She works alongside Pia, but her job is specifically to look at incoming data with suspicion. Before anything gets mapped or merged, Luna profiles it — checking whether fields are actually filled in, whether email addresses are shared across thousands of accounts (a classic placeholder problem), and whether first names have enough distinct values to be trustworthy match signals. She knows that harmonizing garbage still gives you garbage, just in a standard shape.

**Michele Hansley** is NTO's technical marketer. She does not touch pipelines or rulesets. She works in the Segment Canvas, building audiences and campaigns. She is the person who ultimately benefits from everything Pia and Luna do upstream. Without clean, unified profiles, Michele's campaigns hit the wrong people, duplicate offers, and burn sender reputation.

**Rachel Rodriguez** is an NTO customer. She has been shopping with NTO for years — in store, online, through the loyalty program, and occasionally through a support case when a jacket zipper broke. The problem is that NTO's systems do not agree on who she is. She is "Rachel Rodriguez" in POS, "R. Rodriguez" in e-commerce, a loyalty number in the rewards system, an old email address in Marketing Cloud Engagement (MCE), and a support ticket in Service Cloud. Every system has a piece of her. None of them have the whole picture.

Rachel's journey through Data 360 is the story of this document.

---

## Before the Pipeline: How Data Gets In

Before Pia can harmonize anything, the raw data has to actually arrive inside Data 360. This step is easy to overlook, but it is where the pipeline begins.

Data 360 supports over 270 connectors — through native integrations, MuleSoft, APIs, and SDKs. The underlying framework that manages all of these is the **Data 360 Connector Framework (DCF)**, which defines consistent standards for how connectors are built, administered, and how they deliver data into the platform's lakehouse storage.

For NTO, this means:

- The **Salesforce CRM connector** pulls Contact, Case, and Opportunity records from Sales Cloud and Service Cloud.
- The **Marketing Cloud Engagement connector** ingests data extensions holding email sends, opens, clicks, and subscriber attributes.
- The **B2C Commerce connector** brings in e-commerce order and cart data.
- The **POS system** streams purchase events into Data 360 via the **Ingestion API**, using OAuth/JWT authentication with idempotency keys so duplicate transactions are never committed twice.
- The **loyalty program**, hosted externally, delivers nightly files from an Amazon S3 bucket in scheduled batches.

Each of these connectors delivers data into **Data Lake Objects (DLOs)** — the persistent, long-term storage layer inside Data 360. Think of DLOs as the raw, organized tables that hold cleaned source data before any business meaning has been applied. They live in Data 360's lakehouse, which is built on Apache Iceberg and Parquet — open, cloud-native formats that support schema evolution, time travel, and petabyte-scale storage across AWS, Azure, or GCP.

Once data lands in a DLO, Data 360 can apply **Data Transforms** to shape it further before harmonization:

- **Batch Transforms** run on a schedule using a visual, low-code pipeline canvas. They handle complex restructuring — flattening JSON hierarchies from the POS system into tabular rows, or pivoting denormalized loyalty records into normalized attributes. They support incremental processing, so only records that changed since the last run get reprocessed — saving significant compute cost.
- **Streaming Transforms** process data continuously as it flows in, using SQL SELECT queries that run against a live stream of record changes. NTO uses these to standardize email formats and normalize phone numbers (into E.164 format) the moment they arrive from MCE — because downstream identity resolution match rates depend heavily on consistent formatting.

There is also a third ingestion path: **Zero Copy Data Federation**. If NTO's loyalty vendor stores historical spend data in Snowflake, Data 360 does not need to copy it. Instead, it creates an **External DLO** — a metadata pointer that lets Data 360 query the Snowflake table in place, using intelligent query pushdown via JDBC, without duplicating a single byte. The data stays in Snowflake; Data 360 simply reads it when needed.

All of this data lands in a **Data Space** — the fundamental logical container that organizes DLOs, DMOs, and all associated metadata within Data 360. Data spaces enforce governance boundaries between business units, brands, or regions. NTO could run separate data spaces for North America and Europe, each with its own access policies, audit trails, and compliance rules.

Now the data is inside. Now Pia can go to work.

---

## Stage 1 — Harmonize: One Legend for Every Map

Imagine you are holding five maps of the same city, each drawn by a different cartographer in a different era, using different symbols and scale. The information is all there. But you cannot overlay them because they use different legends.

That is NTO's problem. Five source systems, five sets of column names, five date formats, five ways of spelling "California." Data 360 solves this through the **Customer 360 Data Model** — a shared, standard legend that every source system's data gets mapped onto.

### The Building Blocks Pia Works With

**Subject areas** are the broadest organizing concept — business domains that group related types of data together:

- The **Party subject area** covers *who* people are: customers, contacts, account holders.
- The **Sales Order subject area** covers *what* they bought: orders, line items, returns.
- The **Engagement subject area** covers *what they did*: email opens, website visits, loyalty check-ins, shopping cart abandonment.

Within each subject area live the **Data Model Objects (DMOs)** — standardized "shapes" for one specific type of thing. An **Individual DMO** holds the core identity fields for a person. A **Contact Point Email DMO** holds email addresses. A **Sales Order DMO** holds purchase records. Each DMO has defined **attributes** — the fields that describe it — and every Data 360 org is required to have at minimum five DMOs: **Individual, Party Identification, Contact Point Email, Contact Point Phone, and Contact Point Address.**

These are non-negotiable. They are the five pillars without which unification cannot happen.

**Primary keys** uniquely identify a record within its source. **Foreign keys** link related records across datasets — they are what allow a Sales Order to be connected back to the Individual who placed it.

### The Data Mapping Workflow

Pia opens a **data stream** — for example, NTO's website behavior feed, which has already landed as a DLO. She clicks **Start Data Mapping** in the UI. She selects **Individual** as the target DMO. She then maps each source field to its DMO equivalent:

- `first_name` → `First Name`
- `last_name` → `Last Name`
- `email_address` → `Contact Point Email`
- `session_timestamp` → `Engagement Event Date`

She saves. That data stream is now harmonized. The website's understanding of Rachel — her name, her email, her page views — now speaks the same language as every other source system in the org.

Luna runs her quality checks before and during this process. She checks **fill rates** on key identifier fields (what percentage of records actually have an email address?), flags **shared contact points** (is `noreply@nto.com` showing up as the email for 5,000 accounts?), and counts **distinct values** in name fields (if "First Name" has only three distinct values, it is not a useful match signal). Luna's work here directly determines the quality of identity resolution in Stage 2. She knows the rule: a match is only as good as the data behind it.

**End of Stage 1:** Every source system's version of Rachel — her POS record, her MCE subscriber record, her e-commerce profile, her loyalty account, her support case — now speaks the same DMO/attribute language. But she is still five separate records. That is exactly what Stage 2 is designed to fix.

---

## Stage 2 — Unify: Making Rachel One Person

Harmonization gives you a common shape. It is a necessary condition. But it is not sufficient. You still have five records for Rachel, all correctly shaped, all pointing at the same human being, and none of them aware of each other.

**Identity Resolution** is what actually collapses those fragments into a single, trustworthy profile.

### How the Identity Resolution Pipeline Works

The engine runs through four stages, continuously, in near real-time:

**1. Matching (Candidate Selection)**

The system does not compare every record against every other record — that would be computationally impossible at scale. Instead, it uses two techniques to narrow the candidate pool:

- **Blocking Keys:** A blocking key is a value derived from a record's data and match rules — for example, the first three letters of a last name plus a normalized phone number. Records that share a blocking key are grouped together as candidates. Only records within the same group get compared in detail, which keeps the comparison space manageable even across billions of records.
- **Locality Sensitive Hashing (LSH):** For fuzzy matching rules, the engine generates vector embeddings from trained ML models and hashes them so that similar records (like "Rodriguez" and "Rodriguiz") land near each other in the hash space, making them easy to find as candidates.

**2. Deep Matching**

After candidate groups are formed, the engine performs detailed pair-wise comparison. AI models calculate a **probabilistic match score** for each pair — a number quantifying the likelihood that two records represent the same real person. This stage handles the messy realities of human data: misspellings, abbreviations, name changes, multiple phone number formats, and old vs. current email addresses.

**3. Clustering and Unification**

Once matched pairs are identified, they are grouped into clusters. Critically, this includes **transitive matches**: if Record A matches Record B, and Record B matches Record C, then A, B, and C are all placed in the same cluster — even if A and C were never directly compared. This is essential. Without transitive resolution, you could end up with "Rachel Rodriguez" linked to "R. Rodriguez," and "R. Rodriguez" linked to the loyalty record, but never realize all three are the same person.

Each cluster becomes one **Unified Individual** — a persistent identifier that represents a single real human being.

**4. Reconciliation**

With the cluster established, the engine applies **Reconciliation Rules** to populate the Unified Individual's profile attributes. Rules can be configured per field:

- *Most Recently Updated* — NTO uses this for email, because MCE has the freshest email address.
- *Most Trusted Source* — NTO uses this for home address, because the shipping system is considered most authoritative.
- *Most Frequent* — useful for attributes like preferred name.

A critical nuance here: **the Unified Individual is not a golden record that overwrites source data.** Reconciliation populates a profile excerpt for convenience, but the original source records are all preserved and linked back via the **Unified Link Individual** object. Every source record's ID maps to the Unified Individual ID. This means for any given business use case, NTO can always choose which source system's value to actually use — the Unified Individual is more like a set of keys that unlocks all the related records, rather than a replacement for them.

**Near Real-Time Processing**

The identity resolution engine is not a nightly batch job. Because Data 360 uses **Storage Native Change Events (SNCE)** — notifications emitted by the Iceberg lakehouse every time a write operation succeeds — the engine is alerted the moment data changes. It subscribes to these events and uses the **Change Data Feed (CDF)** to identify exactly which records changed, so it only reprocesses the delta, not the full dataset. Small batches of changes can be processed as frequently as every 15 minutes. This means when Rachel updates her email address on NTO's website, her Unified Individual profile reflects that change within minutes — not the next morning.

### Rachel, Unified

Luna and Pia's ruleset matches "Rachel Rodriguez" (POS), "R. Rodriguez" (e-commerce), the loyalty number tied to the maiden-name email, and the MCE subscriber record into a single cluster. One Unified Individual is created. Her current email from MCE wins the reconciliation (most recently updated). Her most recent shipping address from the order system wins there too.

NTO's service agents can now see Rachel's complete history — every purchase, every support case, every loyalty point — in a single profile. No more agents apologizing that they "only see her e-commerce account." No more duplicate email sends. No more missed loyalty benefits because the systems did not know she was the same person.

---

## Stage 3 — Segment: Finding "People Like Rachel"

With clean, unified profiles in place, Michele can now go to work. Her tool is the **Segment Canvas** — a visual, no-code builder where she constructs filtered audiences by dragging, combining, and configuring conditions against the Unified Individual data.

### Core Building Blocks

**Segment On** is the starting point — the object the segment is built against. Salesforce strongly recommends **Unified Individual**, not the raw Individual DMO. Segmenting on raw Individual would give Michele results that still reflect fragmented source records, potentially including Rachel three times in the same audience.

The **Attribute Library** is the catalog of everything Michele can filter on. It has two types:

- **Direct attributes** — one value per person (postal code, loyalty tier, preferred language). Simple equality checks.
- **Related attributes** — many values per person (individual purchase transactions, email engagement events, support cases). These require aggregation before filtering.

**Containers** are the grouping mechanism for conditions within a segment. Attributes inside the same container are evaluated with AND/OR logic relative to each other, and they share a relationship — they apply to the same related record. Attributes in separate containers are evaluated as independent conditions — they can refer to different records or time windows. This distinction matters for related attributes. "Bought a scarf" and "the scarf was yellow" belong in the same container because they must both be true of the same purchase event. Putting them in separate containers would incorrectly match someone who bought a beige scarf and a yellow hat.

**Aggregation** handles the math on related attributes: Count, Sum, Average, Max, Min. Michele uses aggregation to filter on things like "total spend greater than $1,000" (Sum) or "number of purchases greater than 3" (Count) without having to pre-compute those numbers herself.

### Worked Examples

**NTO's yellow scarf campaign:**

```
Container: Product_Category = scarf
         AND Product_Description = yellow
```

**August big spenders in SF or NYC:**

```
Container A: City is in {New York, NYC, San Francisco, San Fran}
Container B: Purchase_Order_Date between Aug 1–31
         AND Grand_Total_Amount > $1,000
```

Notice the city container uses several spelling variations — Data 360 evaluates them with OR logic within the value list. Container B is separate, so a person must satisfy both containers independently.

### Advanced Segmentation: Michele's Spring Problem

Michele's spring campaign has three overlapping offers: 25% off for high-value customers, 15% off for mid-tier, and 10% off for everyone else who is active. The problem is that many customers qualify for more than one tier. Standard filtering cannot guarantee a customer ends up in exactly one bucket. If Michele publishes all three segments separately, Rachel could get all three emails. That is a fast way to lose a subscriber.

Data 360 gives Michele four segment types and a set of refinement tools to handle exactly this:

#### Segment Types

| Type | What It Does |
|---|---|
| **Standard** | Default batch segment. Runs on a schedule, supports all refinement tools, publishes to any target. |
| **Waterfall** | A priority-ranked list of up to 20 existing segments. Each customer is placed into exactly one bucket — the first (highest-priority) segment they match. Solves the overlapping-offer problem. |
| **Dynamic** | Filter values become API parameters. Same segment definition, different audience per API call, no persisted membership. Useful for real-time API-driven personalization. |
| **Real-Time** | Evaluated in milliseconds against the real-time data graph. Used for immediate next-best-action on the website. Cannot use exclusion criteria or nested segments. |

Michele solves her spring campaign with a **Waterfall segment**: High-Value (25% off) at priority 1, Mid-Tier (15% off) at priority 2, All Active (10% off) at priority 3. The waterfall engine evaluates each customer from top to bottom and stops at the first match. Rachel qualifies for High-Value, so she never even reaches the other two.

#### Refinement Tools

**Group, Rank, and Limit (GRL)** applies after a customer qualifies for the segment. Michele first groups qualified customers by region. Within each region, she ranks them by engagement score (a pre-computed metric, described below). Then she caps each group at a maximum of 5 customers. This is how NTO turns 50,000 qualified customers into a carefully curated, geographically fair 2,000-person "Surprise and Delight" gift list — instead of accidentally sending all the gifts to one city.

**Vector Filters (Beta)** add semantic matching via the "Is Similar To" operator. If NTO's product catalog describes a jacket as "suitable for hiking and camping," and a customer's browsing history mentions "trail running shoes," a vector filter can match them — the NLP embedding space understands that trail running and hiking are semantically related, even without exact keyword overlap. This is far more powerful than keyword matching for intent-based targeting.

**Calculated Insights** are pre-computed metrics — aggregations defined once and reused across many segments. NTO's Engagement Score, for example, is computed from email opens, clicks, and purchase frequency using Spark-powered batch or streaming jobs. The result is stored in a **Calculated Insight Object (CIO)** in the lakehouse. When Michele builds a segment filtered by "Engagement Score > 75," she is not re-deriving that calculation from raw events every time the segment runs — she is reading from a pre-computed number. This is faster, cheaper, and more consistent.

**Consent filters** are the non-negotiable gate. Michele always adds `Email_Opt_In = true` as a filter condition. No matter how well a customer qualifies — high value, high engagement, geographically perfect — they do not make the final audience if they have not opted in. Consent filters are evaluated independently of the segment logic. They are the bouncer at the door.

**Nested segments** let Michele reuse existing segment logic inside new segments. The "High-Value Customers" standard segment already has carefully tuned logic. Instead of rebuilding it, Michele references it as a condition inside a new "High-Value + Recent Purchase" segment. If the underlying "High-Value Customers" definition ever changes, the nested segment inherits the update automatically.

**Unified Household and Unified Account** extend segmentation beyond individuals. For B2C use cases, NTO can segment on Unified Household — targeting a family unit rather than each individual member. For B2B, Unified Account supports hierarchical aggregation, rolling child-account data up to the parent so NTO can see total spend across an entire corporate family tree.

---

## Stage 4 — Activate: Getting Rachel the Right Offer

A segment is just a filtered list until it is sent somewhere useful. Activation is the configured instruction that tells Data 360 which segment to publish, which attributes to include, and which destination system to send it to.

### Supported Activation Targets

Data 360 can publish segment membership to:

- **Marketing Cloud Engagement** — for email journeys and campaign execution.
- **B2C Commerce** — for on-site personalization and promotion targeting.
- **Cloud file storage** — Amazon S3, SFTP, Google Cloud Storage, Azure Blob — for analytics teams and data science pipelines.
- **Marketing Cloud Personalization** — for real-time web and mobile personalization.
- **Google Ads and Meta** — for paid social and search audience matching.
- **AgentExchange partners** — third-party platforms in the Salesforce ecosystem.
- **Data 360 Loyalty** — for loyalty program reward and tier management.
- **Data 360 Audience DMO** — for internal downstream use by other Data 360 processes.

### Key Controls

**Lookback window** determines how far back Data 360 looks when evaluating segment criteria. The default is 90 days, configurable up to 2 years. Individual containers within a segment can set their own narrower lookback — NTO's "recent purchase" container uses 60 days inside an overall 90-day segment window.

**Publish schedule** comes in two speeds:

- **Standard Publish** runs every 12 or 24 hours, daily, weekly, monthly, or on demand. It uses the full engagement data history and can publish to any target.
- **Rapid Publish** runs every 1 or 4 hours. It is optimized for recent engagement data (limited to 7 days of history) and only publishes to MCE and cloud storage targets. NTO uses Rapid Publish for Michele's time-sensitive flash-sale campaigns.

**Publish status** tells Michele whether each run actually succeeded. Possible states: Success, Error, Skipped, Publishing, Deferred, or Blank. Skipped typically means the segment membership did not change since the last run — no new data to send. Error requires investigation. Michele checks this dashboard before every campaign send.

**Per-target attribute selection** means different destinations can receive different fields from the same segment. MCE only needs First Name, Email, and Segment ID to trigger a Journey Builder send. The S3 target gets the full attribute set for the analytics team's Tableau dashboards. One segment definition, two different attribute payloads, two different purposes.

**Data Actions** extend activation beyond scheduled publishes. Data 360 continuously monitors DLO data for changes using Storage Native Change Events and the Change Data Feed. When a configured rule is triggered — for example, a customer's lifetime spend crosses $5,000, or a consent record changes from opt-out to opt-in — Data 360 generates a Data Action event, enriches it with additional context (like the customer's loyalty tier), and immediately sends it to a destination such as a Salesforce Flow or an external webhook. This is activation driven by data events, not schedules.

### Rachel, Activated

Rachel's Unified Individual profile qualifies for NTO's High-Value tier — she has placed 14 orders in the last 12 months and her total spend is well above the threshold. The waterfall segment evaluates her against High-Value first. She matches. She stops there and is never evaluated against Mid-Tier or All Active.

Her segment membership publishes every 24 hours to Marketing Cloud Engagement via Standard Publish. MCE receives her email address, first name, and the segment ID that maps to the 25% off offer. Journey Builder picks up the segment publication, fires the email, and logs the send.

Rachel receives exactly one email: 25% off, addressed to her correctly, on a product category she has actually purchased. Never duplicated. Never sent without consent. Never containing an offer that conflicts with another one she received the same morning.

---

## The Architecture Running Underneath

The NTO team experiences Data 360 through its UI — data streams, segment canvas, activation targets. But underneath every click, a significant technical architecture is working.

Data 360 runs on **Hyperforce**, Salesforce's cloud infrastructure layer, deployed on hyperscalers like AWS. This provides zero-trust security with encryption and least-privilege policies, multi-region resilience, and automated elastic scaling.

The storage model is a **tiered lakehouse**:

- The **Lakehouse layer** (Iceberg/Parquet) stores historical and batch data at petabyte scale. This is where DLOs, DMOs, and Calculated Insight Objects live for long-term persistence.
- The **Low Latency Store (LLS)** is a petabyte-scale NVMe SSD layer that sits on top of the lakehouse. It caches "hot" data — like active session context for an Agentforce conversation — so it can be accessed in milliseconds rather than the seconds it might take to read from cold lakehouse storage. When Rachel starts a chat with NTO's service agent, her Unified Individual profile is fetched from the lakehouse and cached in the LLS for the duration of the session.
- The **Real-Time Layer** handles in-memory processing of live signals and engagement data, flushing to LLS as needed for durability.

The compute fabric runs on a **Data Processing Controller (DPC)** — a Job-as-a-Service orchestration layer that abstracts Spark (EMR on EC2 and EKS) and Kubernetes-based workloads. Pia's team never tunes Spark parameters or provisions clusters. They submit jobs through a unified Data 360 API. DPC handles cluster selection, spot vs. on-demand instance balancing, auto-retry on failures, and version management.

**SNCE and CDF** — the Storage Native Change Event and Change Data Feed system — is what makes the whole platform reactive. Instead of polling tables on a timer, every pipeline (identity resolution, streaming transforms, streaming calculated insights, segmentation) subscribes to atomic commit events from the Iceberg lakehouse. When a DLO is written to, a notification fires. Only the changed records get reprocessed. This is the engine behind the "near real-time" behavior that lets Rachel's profile update within 15 minutes of a data change, rather than overnight.

**Governance** is enforced through Attribute-Based Access Control (ABAC) using **CEDAR policies** — a formal policy language that evaluates access decisions based on user attributes, data attributes, and environmental context. PII fields (email, phone, name) are automatically tagged using LLM and ML classifiers. Those tags propagate along the full data lineage — from DLO to derived DLO to DMO — so a governance policy applied at ingestion follows the data everywhere it goes, including into segmentation and activation. Dynamic data masking ensures that analysts querying raw DLOs see masked values for sensitive fields, while authorized systems see the full data.

---

## The Full Loop, End to End

```
NTO's Five Sources (POS, E-commerce, MCE, Loyalty, Service Cloud)
        |
        |  270+ connectors, Ingestion API, Zero Copy Federation
        v
[ DATA LAKE OBJECTS (DLOs) ] — raw, cleaned, stored in Iceberg/Parquet lakehouse
        |
        |  Batch & Streaming Transforms (normalize, flatten, standardize)
        v
[ DATA MODEL OBJECTS (DMOs) ] — harmonized to Customer 360 Data Model
        |   (Individual, Contact Point Email, Sales Order, Engagement...)
        |
        |  Identity Resolution (blocking keys, LSH, deep matching, clustering)
        v
[ UNIFIED INDIVIDUAL ] — one trustworthy profile for Rachel Rodriguez
        |   (linked back to all source records via Unified Link Individual)
        |
        |  Segment Canvas (containers, GRL, vector filters, consent, waterfall)
        v
[ SEGMENT MEMBERSHIP ] — Rachel is in "High-Value Customers"
        |
        |  Activation (Standard Publish, 24h schedule)
        v
[ MARKETING CLOUD ENGAGEMENT ] — one personalized, consented email: 25% off
```

---

## Keep Learning (Trailhead)

- [Customer 360 Data Model for Data 360](https://trailhead.salesforce.com/content/learn/modules/customer-360-data-model-for-customer-data-platform) — harmonization deep dive
- [Customer Context and Profile Unification Fundamentals](https://trailhead.salesforce.com/content/learn/modules/customer-context-and-profile-unification-fundamentals) — identity resolution deep dive
- [Segmentation in Data 360](https://trailhead.salesforce.com/content/learn/modules/customer-360-audiences-segmentation) — segmentation basics
- [Advanced Segmentation in Data 360](https://trailhead.salesforce.com/content/learn/modules/advanced-segmentation-in-data-360) — waterfall, dynamic, real-time, GRL, vector filters
- [Data 360: Explore Setup to Activation](https://trailhead.salesforce.com/en/content/learn/trails/data-cloud-explore-setup-to-activation) — the full end-to-end trail (12,200 pts / ~14 hrs)

---

## Glossary

| Term | Definition |
|---|---|
| **Data 360** | Salesforce's customer data platform (formerly Data Cloud, rebranded October 14, 2025). Ingests, harmonizes, unifies, segments, and activates customer data at scale. |
| **Hyperforce** | Salesforce's cloud infrastructure layer, deployed on hyperscalers like AWS. Provides zero-trust security, multi-region resilience, and elastic scaling. |
| **Lakehouse** | Data 360's core storage layer, built on Apache Iceberg and Parquet. Combines data lake scale with warehouse-style governance, schema evolution, and time travel. |
| **Low Latency Store (LLS)** | A petabyte-scale NVMe SSD layer on top of the lakehouse that caches hot data for millisecond-speed access. Used for active session context and real-time personalization. |
| **Data Processing Controller (DPC)** | The Job-as-a-Service compute orchestration layer. Manages Spark and Kubernetes workloads, auto-scales, handles retries, and abstracts cloud infrastructure from Data 360 users. |
| **SNCE (Storage Native Change Events)** | Atomic commit notifications emitted by the Iceberg lakehouse every time a write operation succeeds. Enables downstream pipelines to react to changes without polling. |
| **CDF (Change Data Feed)** | Builds on SNCE to identify exactly which records changed. Allows identity resolution, transforms, and calculated insights to reprocess only the delta, not the full dataset. |
| **Connector Framework (DCF)** | The unified architecture that governs how all Data 360 connectors are built, administered, and managed. Supports 270+ connectors across Salesforce products, SaaS apps, databases, cloud storage, and streaming services. |
| **Data Lake Object (DLO)** | The persistent storage layer inside Data 360. Holds cleaned, transformed data from source systems. The raw material before harmonization. Federated external data is represented as External DLOs. |
| **Zero Copy Federation** | Querying external data (Snowflake, Databricks, BigQuery, Redshift, S3 Iceberg) in place, without copying or duplicating it. Data 360 creates an External DLO as a metadata pointer and reads the source directly. |
| **Data Space** | The fundamental logical container that organizes all DLOs, DMOs, and metadata within Data 360. Acts as a governance and isolation boundary between business units, regions, or brands. |
| **Customer 360 Data Model** | The standard, shared data model (subject areas, DMOs, attributes) that all harmonized data is mapped onto so every source speaks the same language. |
| **Subject Area** | A broad business concept grouping related DMOs. Party (who), Sales Order (what they bought), Engagement (what they did). |
| **Data Model Object (DMO)** | A standardized shape for one type of business entity. Individual, Contact Point Email, Sales Order, Case — all DMOs. |
| **Attribute** | A field on a DMO. First Name, Email Address, Purchase Amount are all attributes. |
| **Primary Key** | The field(s) that uniquely identify a record within its source system. |
| **Foreign Key** | A field that links a record to a related record in another dataset. |
| **Data Stream** | An ingested feed from one source system, configured to map to a target DMO. |
| **Batch Transform** | A scheduled or on-demand transform that handles high-volume, complex restructuring operations (pivot, flatten, join) using a visual low-code pipeline canvas. |
| **Streaming Transform** | A continuous SQL-based transform that processes record changes in near real-time as they arrive. Used for standardization, enrichment, and instant profile updates. |
| **Identity Resolution** | The process of matching, clustering, and reconciling fragmented source records into a single Unified Individual. Runs in near real-time using SNCE/CDF for incremental processing. |
| **Blocking Keys** | Values derived from record data and match rules used to group candidate records together for detailed comparison, making large-scale matching computationally feasible. |
| **LSH (Locality Sensitive Hashing)** | A technique for fuzzy matching. ML model embeddings are hashed so similar records (e.g., "Rodriguez" vs. "Rodriguiz") cluster together and are found as match candidates. |
| **Transitive Matching** | If A matches B and B matches C, all three are placed in the same cluster — even if A and C were never directly compared. |
| **Unified Individual** | The single persistent identifier representing one real person, created by identity resolution. Acts as a set of keys linking all source records for that person. |
| **Unified Link Individual** | The object that maps every source record ID back to its corresponding Unified Individual, preserving full lineage. |
| **Reconciliation Rules** | Logic that determines which source value populates a Unified Individual's profile attribute. Options include Most Recent, Most Frequent, and Source Priority. |
| **Calculated Insight (CI)** | A pre-computed, reusable metric (e.g., Engagement Score, Lifetime Spend) derived from DMO data using Spark batch or streaming jobs. Stored in a Calculated Insight Object (CIO). |
| **Segment Canvas** | The visual, no-code builder where marketers define segment logic. |
| **Segment On** | The object a segment is built against. Salesforce recommends Unified Individual to avoid fragmented results. |
| **Attribute Library** | The catalog of available fields for segmentation. Split into direct attributes (one value per person) and related attributes (many values per person). |
| **Container** | A logical grouping of conditions with AND/OR logic. Conditions in the same container are related; conditions in separate containers are independent. |
| **Aggregation** | A calculation applied to related attributes before filtering. Count, Sum, Average, Max, Min. |
| **Standard Segment** | Default batch segment. Runs on a schedule, supports all refinement tools, publishes to any activation target. |
| **Waterfall Segment** | A priority-ranked list of up to 20 segments. Each customer is placed into exactly one bucket — the first match wins. |
| **Dynamic Segment** | Filter values are passed as API parameters at call time. No persisted membership. Used for API-driven real-time personalization. |
| **Real-Time Segment** | Evaluated in milliseconds against the real-time data graph. Cannot use exclusion criteria or nested segments. |
| **GRL (Group, Rank, and Limit)** | A post-qualification refinement step. Group by attribute, rank within each group, cap how many from each group make the final segment. |
| **Vector Filters (Beta)** | Use the "Is Similar To" operator with NLP embeddings to match semantically similar records even without exact keyword overlap. |
| **Consent Filter** | A hard-gate segmentation condition enforcing opt-in/opt-out status. Applied independently of all other segment logic. |
| **Nested Segment** | A segment that includes another existing segment as a condition. Updates to the inner segment propagate automatically. |
| **Activation** | The configured instruction telling Data 360 which segment, which attributes, and which destination to publish to. |
| **Activation Target** | A destination system for segment data. MCE, B2C Commerce, cloud storage, Google Ads, Meta, Data 360 Loyalty, and more. |
| **Lookback Window** | The time range Data 360 considers when evaluating segment criteria. Default is 90 days, configurable up to 2 years. |
| **Standard Publish** | Scheduled publishing at 12h, 24h, daily, weekly, monthly, or on-demand cadences. Uses full engagement history. |
| **Rapid Publish** | Faster 1h or 4h refresh. Limited to 7 days of engagement data and MCE + cloud storage targets only. |
| **Publish Status** | The outcome of a publish run: Success, Error, Skipped, Publishing, Deferred, or Blank. |
| **Data Action** | An event-driven activation mechanism. Monitors DLO data for threshold or state-change events via SNCE/CDF and immediately triggers a configured destination (Salesforce Flow, webhook, etc.). |
| **ABAC / CEDAR** | Attribute-Based Access Control using the CEDAR policy language. Governs fine-grained, contextual access to individual objects, fields, and rows within a data space. |
| **Unified Household** | A Data 360 object representing a family or group unit. Used for B2C segmentation targeting household-level conditions. |
| **Unified Account** | A Data 360 object representing a company hierarchy. Supports hierarchical aggregation rolling child-account data up to the parent for B2B segmentation. |
