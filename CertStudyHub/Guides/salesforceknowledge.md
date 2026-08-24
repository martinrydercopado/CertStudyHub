# Salesforce Knowledge: The Architect's Guide to Knowledge-Grounded Agents

*Updated August 24, 2026*
*This guide was generated using AI with grounding in official Salesforce documentation. Review for accuracy before using.*

---

## Table of Contents

1. [What Salesforce Knowledge Is and Why It Is the Default Grounding Source](#1-what-salesforce-knowledge-is-and-why-it-is-the-default-grounding-source)
2. [Setting Up Lightning Knowledge](#2-setting-up-lightning-knowledge)
3. [Data Categories: Why Accurate Categorization Is Critical for Grounding](#3-data-categories-why-accurate-categorization-is-critical-for-grounding)
4. [How Knowledge Becomes RAG-Ready: Agentforce Data Libraries](#4-how-knowledge-becomes-rag-ready-agentforce-data-libraries)
5. [Under the Hood: Data Objects, Indexes, and Naming Conventions](#5-under-the-hood-data-objects-indexes-and-naming-conventions)
6. [Citations: Standard Action vs. Custom Prompt-Template Actions](#6-citations-standard-action-vs-custom-prompt-template-actions)
7. [Multimodal Grounding: Beyond Article Text](#7-multimodal-grounding-beyond-article-text)
8. [Common Pitfall: The Default Retriever Casts a Wide Net](#8-common-pitfall-the-default-retriever-casts-a-wide-net)
9. [Governance: Keeping Unvalidated Content Out of the Vector Store](#9-governance-keeping-unvalidated-content-out-of-the-vector-store)
10. [Testing: Retrieval Before Agent](#10-testing-retrieval-before-agent)
11. [Migrating from Classic Knowledge to Lightning Knowledge](#11-migrating-from-classic-knowledge-to-lightning-knowledge)
12. [Architect's Quick-Reference Checklist](#12-architects-quick-reference-checklist)

---

## 1. What Salesforce Knowledge Is and Why It Is the Default Grounding Source

### What It Is

Salesforce Knowledge is a centralized repository for structured articles. Think of it as a carefully curated library with the most capable librarian imaginable: one who can rapidly answer any question, from a customer asking about a return policy to a service agent troubleshooting a technical issue, to an AI agent generating a grounded response. Articles can capture FAQs, step-by-step procedures, product guidelines, legal notices, customer service scripts, and more. Because Knowledge is native to Salesforce, it inherits the platform's security model, permissions, and administrative tooling. Everything is managed in one place.

### Why This Matters for the Business

LLMs are trained on public internet data. They have no knowledge of your client's products, policies, contracts, case history, or internal procedures unless that information is explicitly supplied at reasoning time. Without grounding, an agent asked about a specific warranty term, a regional compliance rule, or a proprietary product specification will either refuse to answer or hallucinate a plausible-sounding but incorrect response.

That failure is not just a technical problem. It is a trust problem. Customers who receive incorrect information from an AI agent are less likely to trust the agent, less likely to self-serve, and more likely to escalate to a human. The business case for grounding is simple: grounded agents give accurate, citable answers. Ungrounded agents give confident-sounding guesses.

Knowledge is the highest-quality, lowest-risk starting point for grounding Agentforce agents in proprietary enterprise content.

### Why Knowledge Wins for RAG

Many source types can feed a RAG pipeline. Here is how they compare:

**Knowledge articles** are native to Salesforce, structured, and version-controlled. They go through a managed lifecycle (Draft, Validation, Published, Archived) backed by approval workflows and explicit categorization. That lifecycle means content entering the vector store has been reviewed, tagged, and approved. Other sources often bypass that rigor entirely.

**Service replies and case notes** are rich with conversational context but lack curation. They are useful but noisy.

**FAQ documents (PDF, HTML, TXT)** are supported via Agentforce Data Library (ADL) file upload or manual Data Cloud ingestion. They are good for static reference material.

**RFP responses and email threads** are valuable for sales and support contexts but require significant preprocessing.

**Call transcripts and meeting notes** are supported as audio/video files in manual Data Cloud setups. They require transcription and chunking before they are useful.

**Cases (standard Salesforce Object)** require manual search-index configuration outside ADL.

Knowledge also happens to be purpose-built for retrieval. Its structured Data Model Object, `KnowledgeArticleVersion__dlm`, maps cleanly to the Data Cloud indexing pipeline. Its field structure (Title, Summary, Body, Question, Answer, Resolution) gives architects multiple levers for chunking strategy, field prepending, and filter-based retrieval.

> **Scenario.** A financial services firm deploys a customer-facing agent to answer questions about savings account terms. They start with PDFs of product brochures fed through the file upload path. The agent retrieves the correct chunk about interest rates but misses a regional regulatory caveat buried in a footnote on page 14. After migrating that content to structured Knowledge articles with clear sections for Terms, Exceptions, and Regional Notes, retrieval recall improves significantly because the chunking process can now target individual structured fields rather than treating the whole brochure as a single block of text.

---

## 2. Setting Up Lightning Knowledge

### Why This Matters

Getting the configuration right before articles are created is dramatically easier than refactoring later. Record types, page layouts, permission sets, and category structures all influence how content is authored, governed, and ultimately indexed. Mistakes at setup time cascade into retrieval quality problems that are difficult to diagnose.

### Licensing

Knowledge User licenses are required for anyone who **creates or manages** articles. Internal users can **read** articles without a special license. Licensing is often bundled with Agentforce Service editions, but confirm with the account executive.

To assign the license:

```
Setup > Users > [select user] > Edit > Knowledge User (checkbox) > Save
```

Once assigned, the Knowledge pages appear in that user's Setup menu.

### Enabling Lightning Knowledge

Enable Knowledge via the Lightning Knowledge Setup Flow:

```
Setup > Salesforce Go > Knowledge Setup (tile) > Start
```

The setup flow assigns Knowledge Authors and creates initial data categories in a single workflow.

**Critical:** Once enabled, Knowledge cannot be disabled. Treat enablement as a one-way door. Always validate your org design in a sandbox before enabling in production.

### Record Types

Record types control article structure and determine which page layout a user sees. They also drive workflow and approval-process assignment. Common record types include:

- **FAQ:** Question/Answer format. Ideal for self-service and agent grounding.
- **How To:** Step-by-step procedural format. Strong for technical troubleshooting scenarios.

Create a record type for each distinct presentation format. From a RAG perspective, record types act as implicit content filters. Architects can scope a retriever to pull only from a specific record type's data by using prefilter conditions on the `DataSource__c` field in the index DMO.

### Page Layouts

Page layouts control the fields visible to article authors. For a **FAQ** layout, expose `Submit for Approval` and `Assign` in the Lightning Actions section. Add structured sections such as:

- **Knowledge Detail:** Publication Status, Validation Status
- **Article Details:** Summary
- **Assignment Information:** Assigned By, Assigned To, Assignment Date/Due Date/Note
- **Properties:** Article Created Date/By, Last Modified By, Last Published Date

These fields are not just UI conveniences. Summary, Title, and structured body fields are prime candidates for indexing, prepending, and augmentation in the RAG pipeline.

### Permission Sets and CRUD Permissions

Use a dedicated permission set, not profile modifications, to grant Knowledge management permissions. The recommended pattern is a **"Knowledge Manager"** permission set containing:

**Object permissions on Knowledge:**
- Read, Create, Edit, Delete, View All Records, Modify All Records

**App permissions under Knowledge Management:**
- Manage Articles
- Manage Knowledge Article Import/Export
- Manage Salesforce Knowledge
- Publish Articles
- Share Internal Knowledge Articles Externally
- (Auto-enabled) View Archived Articles, View Draft Articles

**System permission:**
- Manage Data Categories

Assign this permission set to knowledge admins and senior contributors. Junior contributors may warrant a lighter-weight permission set with Create/Edit but without Publish or Delete.

### Article Lifecycle

Understanding the lifecycle is foundational to RAG governance:

```
Draft > (Assign / Submit for Approval) > Validated > Published > (Edit as Draft) > Archived / Deleted
```

**Only Published articles flow into the RAG index.** Articles in Draft or Validation states do not surface to agents. Architects must map the approval workflow to the index refresh cadence. See Section 9 for the full governance discussion.

> **Scenario.** A client's knowledge team asks why their agent is answering "I don't know" for a question about a newly launched product feature. The article was written and submitted for approval three days ago. Investigation reveals it is sitting in "Validation" status, waiting for a subject-matter expert to review it. The article is not published, so it has never entered the vector store. This is a governance-process gap, not a technical failure.

---

## 3. Data Categories: Why Accurate Categorization Is Critical for Grounding

### Why This Matters

Data categories are the hidden infrastructure of retrieval quality. They look like an organizational convenience, but they serve as access controls, runtime filters, and semantic signals that directly shape which articles an agent can see and retrieve. Misconfigured categories are one of the most common causes of silent retrieval failure: the agent says "I don't know" not because the answer does not exist, but because the article is not visible or is filed under the wrong category.

### What They Are

Data categories organize articles into hierarchical groups (Category Group > Category > Subcategory). A typical implementation pairs two or three Category Groups, each with a flat or nested set of categories.

**Example taxonomy (a solar energy company):**

```
Category Group: Solar Installation & Maintenance
  |-- Solar Panels
  |-- Inverters
  |-- Charge Controllers
  `-- Batteries

Category Group: Support Options
  |-- Product Support
  |-- Billing Support
  `-- Order Support
```

### Why They Matter for RAG

Data categories do three things for grounding:

**1. Access control.** A user profile can only retrieve articles in data categories they are permitted to see. At runtime, the agent's retrieval respects the visibility rules of the user or service context. Misconfigured visibility can silently exclude relevant articles from the vector store, causing the agent to answer "I don't know" when the answer exists and is simply not visible.

**2. Filter-based retrieval.** Categories can be exposed as filter fields in the search index. Architects can configure a retriever's dynamic prefilters to restrict results to a specific category at runtime. This is powerful for multi-product or multi-tenant deployments where different agent personas must draw from distinct knowledge domains.

**3. AI search surface.** Salesforce documentation is explicit: accurate categorization is what allows generative AI tools to surface the most relevant, trusted articles. Miscategorized articles either surface in wrong contexts, producing off-topic agent responses, or get buried entirely.

### Practical Guidance for Architects

- **Keep the taxonomy shallow.** Complex hierarchies lead to miscategorization and retrieval noise. Authors need to be able to classify reliably without a cheat sheet.
- **Classify before indexing.** Articles added without category assignments cannot be filtered by category at retrieval time.
- **Review category visibility settings** in both Default Data Category Visibility and the Knowledge Manager permission set. Both must be configured for the correct scope.
- **Treat categories as metadata, not indexable text.** Do not add category fields as index fields in the search index. Single-word category values produce micro-chunks that degrade semantic search quality. Use them as prepend fields or filter fields instead.

> **Scenario.** A client operates a multi-brand service organization. Brand A's agent should only retrieve articles tagged `Brand_A`. Brand B's agent should only retrieve articles tagged `Brand_B`. Without category-based prefilters on the retrievers, a customer asking Brand A's agent about a return policy might receive a response grounded in Brand B's policy. The answer sounds correct but is wrong for that customer's context.

---

## 4. How Knowledge Becomes RAG-Ready: Agentforce Data Libraries

### Why This Matters

Before an article can ground an agent response, it must be chunked into passages, converted into vector embeddings, and stored in a searchable index. This pipeline, if built manually, requires Data Cloud configuration, embedding model selection, search index setup, retriever configuration, prompt template engineering, and agent action creation. The Agentforce Data Library abstracts all of that into a single configuration step. Knowing when to use the fast path and when to build manually is one of the most impactful architectural decisions an architect makes.

### The Fast Path: Agentforce Data Libraries (ADL)

The fastest way to make Knowledge articles RAG-ready is to add an **Agentforce Data Library (ADL)** in Agentforce Builder or Setup. When an ADL is configured with Knowledge articles selected as the content source, Salesforce automatically creates all of the following with default settings:

- **Data Stream and Mapping:** Ingests `KnowledgeArticleVersion` into Data Cloud.
- **DMO:** `KnowledgeArticleVersion__dlm` (auto-created if it does not already exist).
- **Search Index:** Named with the `KA_` prefix (for example, `KA_Agentforce_Default_Library`).
- **Retriever:** Per-ADL retriever prefiltered to that ADL's grounding source ID.
- **Ensemble Retriever:** Dynamically merges and reranks file and article results.
- **Prompt Template:** "Answer Questions with Knowledge" (pre-written RAG instructions).
- **Agent Action:** "Answer Questions with Knowledge" (calls the prompt template).

This single configuration decision replaces what would otherwise require manual Data Cloud pipeline setup, search index configuration, retriever creation, and prompt template engineering. That is the business value of ADL: a complete, connected RAG pipeline from zero.

### ADL Supports Two Source Types Only

**Supported by ADL:**
- Salesforce Knowledge articles
- Uploaded files (PDF up to 100 MB, HTML up to 4 MB, TXT up to 4 MB)

**Requires manual setup (not supported by ADL):**
- Cases, custom objects, long-text fields on any other sObject
- Files in AWS S3, Azure Blob, or Google Cloud Storage
- Audio/video transcripts
- Structured JSON or CSV from external systems

For anything outside these two categories, architects must build the RAG pipeline manually in Data Cloud: connect the data source, create a search index, configure a retriever, and wire it into a custom prompt template and agent action.

**Important:** A single search index can only map to one data source (one DMO/UDMO). For four data sources (files, Knowledge articles, cases, and a custom object), you need four separate search indexes, each with at least one retriever.

### When to Choose Manual Setup

Use manual configuration when you need:
- A different chunking strategy, for example smaller chunks for dense technical content
- Vector-only search instead of hybrid search
- A different embedding model, such as Multilingual E5-Large for non-English content
- Granular control over which articles enter the index via data stream filters
- Custom retriever prefilters not expressible in the ADL default settings
- Multiple data sources merged into a single prompt template

### Content Authoring Best Practices That Directly Affect RAG Quality

How articles are written has a direct impact on retrieval accuracy and generation quality. These practices matter because the chunking pipeline works on raw text, and the quality of that text determines the quality of the vectors.

1. **Be thorough.** Generative AI synthesizes information. Favor detail over brevity in article bodies. An agent can always condense a detailed answer; it cannot invent detail that is missing.
2. **Include real-world examples.** Conversational, scenario-based phrasing in articles improves semantic match against user queries.
3. **Use structural HTML headings (H1-H6).** The chunking process uses heading tags as chunk delimiters, keeping related content together in the same chunk.
4. **Spread content across fields.** For Knowledge articles indexed as a DMO, use multiple fields (Question, Description, Resolution, Exceptions) rather than one mega-body field. This gives the search index more targeted vectors and enables field-level filtering.
5. **Explain synonyms and abbreviations.** Including common alternate phrasings for key terms helps the LLM understand how concepts relate, improving retrieval recall.
6. **Annotate media.** Charts and diagrams embedded in articles should have descriptive alt-text or caption annotations, both for accessibility and because text is what gets chunked and vectorized.

> **Scenario.** A client's knowledge base has 2,000 published articles but agent responses are consistently vague. Investigation reveals that most articles follow a style guide that prioritizes brevity: each article is three to five sentences long. The chunking process creates vectors from these micro-articles, but there is simply not enough semantic content for the retriever to produce high-confidence matches. Recommendation: revise the style guide to require a minimum article depth (for example, at least one scenario, one step-by-step section, and a "When This Does Not Apply" field) before articles are approved for publication.

---

## 5. Under the Hood: Data Objects, Indexes, and Naming Conventions

### Why This Matters

When something goes wrong with a grounded agent (and something eventually will), architects need to know exactly which object to query, which index to inspect, and which naming convention to follow to isolate the problem. This section provides the internal map of the Knowledge RAG pipeline.

### The Knowledge DMO

When ADL ingests Knowledge articles, it creates (or reuses) a structured Data Model Object:

```
KnowledgeArticleVersion__dlm
```

This DMO is the foundation of the knowledge-article RAG path. It is created automatically along with its data stream and mapping if it does not already exist in the org. The actual vectors are stored in a separate index DMO derived from this object.

### Search Index Naming Convention

All Knowledge article-based search indexes are prefixed with `KA_`, followed by the name provided at creation time. Examples:

```
KA_Agentforce_Default_Library
KA_Published_Articles
KA_Service_Agent_Index
```

This prefix makes Knowledge indexes immediately identifiable in the Data Cloud Search Index Builder and distinguishes them from file-based indexes (`FileUDMO_SI`) and any manually created DMO-based indexes.

One search index can contain vectors from multiple ADLs if those ADLs were created using the same identifying fields. The `GroundingSourceId__c` field on the index DMO tracks which ADL each vector belongs to, enabling per-ADL prefiltering at the retriever level.

### File-Based Index: FileUDMO_SI

When ADL ingests files (PDF, HTML, TXT), there is a single shared search index for all ADLs named `FileUDMO_SI`. The corresponding index DMO is named `FileUDMO_SI_index__dlm`. A special DMO named `AiGroundingFileRefCustom__dlm` stores the mapping between uploaded files and their respective ADLs.

Default file-based index settings:
- Hybrid search (semantic and keyword)
- 512 tokens per chunk, approximately 400-500 words in Latin-script languages
- E5 Large Multilingual embedding model
- Returns 10 results per retriever invocation

### The Ensemble Retriever

Each ADL gets its own retriever, prefiltered using `GroundingSourceId__c` so it only returns content from that ADL's articles or files. The ensemble retriever bundles the article retriever and file retriever into a single retriever that dynamically reranks results by relevance to the query. Only the most relevant results, regardless of source, surface at the top. This prevents irrelevant file results from diluting article-grounded answers and vice versa.

### The Prompt Template: "Answer Questions with Knowledge"

The auto-created prompt template uses a dynamic retriever reference:

```
{!$EinsteinSearch:sfdc_ai__DynamicRetriever.results}
```

This dynamic retriever is resolved at runtime by the Agentforce reasoning engine, which selects the correct retriever based on the agent's ADL. Multiple agents can share the same prompt template while each pulls from its own discrete ADL. Salesforce recommends using this default dynamic retriever rather than overriding it with a manually created retriever in the standard template.

### Verifying the Index Is Populated

Use the Data Cloud Query Editor to confirm vectors exist before testing the agent:

```sql
SELECT 'INDEX' AS Location,
       COUNT(DISTINCT rc.SourceRecordId__c) AS ArticleCount,
       now() AS Timestamp
FROM <chunk DMO of the Search Index> rc
UNION
SELECT 'DMO' AS Location,
       COUNT(DISTINCT kav.Id__c) AS ArticleCount,
       now() AS Timestamp
FROM KnowledgeArticleVersion__dlm kav
ORDER BY Location;
```

A mismatch between the DMO count and the index count means the incremental index refresh has not completed or has failed.

---

## 6. Citations: Standard Action vs. Custom Prompt-Template Actions

### Why This Matters

Citations are how agents earn user trust. A response that says "The warranty period is 2 years [Source: Product Warranty Policy, Section 3]" is fundamentally more trustworthy than a response that says "The warranty period is 2 years." The citation gives the user a path to verify the claim. In high-stakes use cases (legal, financial, medical), citations are not optional. They are the minimum bar for an agent response that is fit for purpose.

This is one of the most commonly misunderstood distinctions in Knowledge-grounded agent design, and the choice cannot be easily changed after an agent goes live.

### Standard "Answer Questions with Knowledge" Action: Inline Citations

The standard out-of-the-box agent action supports **inline citations** embedded directly in the generated response text. Example:

> "The warranty period for solar panels is 2 years [1]. For inverters, the coverage extends to 5 years [2]."

The prompt template extracts the `source_id` from the most relevant article chunk and sets it in the structured JSON response alongside the `generated_response`. The agent surfaces these citations as clickable references tied to the originating article. This is the richest citation experience available on the platform.

The Einstein Trust Layer governs the full prompt and generation flow, including the grounding step where Knowledge article content is injected into the prompt context before the LLM generates a response. The Trust Layer white paper describes this grounding flow (vector search pulling from Knowledge articles, merge field replacement, PII masking, zero-retention enforcement) but does not use specific named labels for citation modes. When discussing citation behavior with customers, describe the mechanics directly: inline numbered citations are produced by the standard action; a sources list is produced by custom prompt templates.

### Custom Prompt-Template Actions: Sources List Only

When architects build a **custom prompt-template agent action** to add filters, change chunking behavior, combine multiple retrievers, or use a custom retriever, the citation capability is reduced. Custom prompt templates only support a **sources list appended at the bottom** of the response, not inline numbered citations.

This distinction matters for agent UX. An inline citation lets the user immediately trace which part of a statement came from which article. A bottom-of-response sources list is less precise; the user cannot tell which source supports which claim.

**Architect decision guide:**

- **Standard K/A grounding, citation transparency is required:** Use ADL plus the standard "Answer Questions with Knowledge" action.
- **Custom retrieval logic needed, citation precision is secondary:** Build a custom prompt template. Accept the sources-list citation model.
- **Both custom retrieval AND inline citations required:** This combination is not currently supported without pro-code workarounds.

> **Scenario.** A healthcare client wants an agent that answers questions about clinical procedures grounded in their internal protocol library. Their legal team requires inline citations on every response so that clinicians can trace the exact protocol document that grounded each statement. The architect recommends ADL plus the standard action specifically to preserve the inline citation model. The custom retriever with domain-specific prefilters is considered but ultimately deferred because losing inline citations is a non-starter for compliance.

---

## 7. Multimodal Grounding: Beyond Article Text

### Why This Matters

A significant amount of enterprise knowledge lives inside charts, diagrams, process flows, and product images embedded in articles. If those visuals are not annotated with descriptive text, they are effectively invisible to the RAG pipeline. An article about a complex manufacturing tolerance chart, for example, might be retrieved but provide zero grounding value if the chart has no caption and the surrounding text simply says "see the chart above."

### What This Means in Practice

Agentforce can ground responses in visual content embedded within Knowledge articles, including charts, graphs, diagrams, and other images, not just the article text body. An article explaining solar panel efficiency degradation that includes a performance curve chart can ground an agent response that references the trend shown in the chart, provided the visual is properly annotated. This extends the effective surface area of Knowledge articles for RAG grounding beyond raw text.

### Architect Guidance

- **Annotate all visual content with descriptive alt-text or caption fields.** The chunking and vectorization pipeline operates on text. Visuals that have no text context around them will not be meaningfully retrieved.
- **Use structured field metadata to signal visual content.** A field such as `Contains_Diagram__c` (boolean) can serve as a filter or prepend field that signals to the retriever and prompt template that the chunk references a visual component.
- **Test multimodal articles explicitly.** When auditing the knowledge base for RAG readiness, flag every article that contains a chart or diagram and verify that the surrounding text adequately describes the visual's key takeaways. If the visual is the primary information carrier and the surrounding text is thin, that article is a RAG liability.

> **Scenario.** A manufacturing client's product articles include engineering diagrams with measurements and tolerances. Authors have historically embedded diagrams with a one-line caption like "Figure 3." An audit reveals that 40% of articles with diagrams have no descriptive text adjacent to the visual. Recommendation: update the article page layout to include a required "Diagram Description" rich-text field, and enforce completion via a validation rule before publication.

---

## 8. Common Pitfall: The Default Retriever Casts a Wide Net

### Why This Matters

The default retriever is designed for broad, general-purpose use. Most Agentforce deployments are not general-purpose. They serve a specific product line, a specific customer segment, or a specific domain. When the retriever is too broad, it pulls in irrelevant articles that dilute the quality of the retrieved context. The agent then generates responses that are technically "grounded" but grounded in the wrong source. This failure mode is harder to detect than a hallucination because the agent cites a real article; it just cites the wrong one.

### The Problem

The default dynamic retriever in the "Answer Questions with Knowledge" prompt template (`sfdc_ai__DynamicRetriever`) is designed to search both web and internal knowledge sources by default. For narrow, domain-specific deployments, it can pull in irrelevant results that dilute the quality of retrieved context.

Consider a specialized technical support agent scoped to a single product line. If the dynamic retriever also pulls from web content or other ADLs not relevant to that product line, the prompt is augmented with irrelevant context. The result is either a lower-quality answer or, if the combined retrieved content exceeds the LLM's context window, a failed request with the error "Something went wrong during generation of the response."

### When to Evaluate a Custom Retriever

Architects should evaluate replacing or supplementing the default retriever with a custom retriever when:

- The agent is scoped to a specific product line, region, or topic domain
- Multiple agents share the same org but must draw from distinct knowledge pools
- Retrieved results consistently include articles from the wrong category or topic
- The agent is a high-stakes deployment where hallucination from irrelevant context is unacceptable

### Custom Retriever Pattern

A custom retriever is created in Einstein Studio against a specific search index (for example, `KA_Product_Line_A`). It can be configured with:

- **Prefilters** (for example, `DataCategory = 'Solar_Panels'`) to scope retrieval to a specific knowledge domain
- **Dynamic prefilters** mapped to prompt template inputs, enabling context-aware scoping at runtime (for example, filtering by `Language__c` or `Region__c` on the article)
- **Reduced result count** (fewer than the default 10) when context window headroom is limited
- **Specific return fields** aligned to what the prompt template actually needs

Reference the custom retriever in a custom prompt template instead of the dynamic retriever. Salesforce recommends against overriding the dynamic retriever in the standard "Answer Questions with Knowledge" template. Instead, build a separate custom prompt template and agent action for the scoped use case.

### Hybrid Search: Calibration Note

The default index uses hybrid search (semantic and keyword combined). Hybrid search improves recall for content with product names, brand terms, jargon, and specific technical terminology. But it consumes roughly twice the Data Cloud credits of vector-only search and introduces additional latency. For knowledge bases written in natural, everyday language with no technical terminology, vector-only search is worth evaluating to reduce cost and latency.

**Do not** add category picklist fields as index fields. Single-word category values produce micro-chunks that degrade semantic search quality. Use categories as prepend or filter fields.

> **Scenario.** A global retail client has three distinct agent personas: one for returns, one for loyalty rewards, and one for product recommendations. All three agents are deployed in the same org and all three use the default dynamic retriever. The loyalty agent is occasionally returning articles from the returns knowledge category, causing it to answer questions about return windows when customers ask about points redemption. The architect creates three separate search indexes, each scoped to the relevant data category, and creates custom retrievers for the loyalty and returns agents. The product recommendations agent keeps the default retriever because its domain is broad.

---

## 9. Governance: Keeping Unvalidated Content Out of the Vector Store

### Why This Matters

The RAG pipeline is only as trustworthy as the content that enters it. An agent grounded in a validated, accurate article responds correctly. An agent grounded in an incorrect, outdated, or misleading article responds confidently and incorrectly. The second scenario is worse than no grounding at all, because a confident-sounding wrong answer erodes user trust in ways that are difficult to detect and trace. This principle is documented explicitly in the architecture literature as the **"RAG poisoning" risk**: bad content enters the vector store and poisons agent responses downstream.

Governance of the knowledge base is not a content management concern. It is a quality and compliance engineering concern.

### The Article Publication Lifecycle Is the Control Point

Architects should verify that the following are in place before any Agentforce deployment goes live:

**1. Approval processes on sensitive record types.** Any article type that could materially affect customer decisions (safety instructions, warranty terms, legal obligations, pricing) must require explicit reviewer approval before publication. Add approval processes to the relevant record types via record type configuration.

**2. Validation Status is activated and enforced.** Enable the Validation Status field in Knowledge Settings. Establish a clear status taxonomy (for example, Work In Progress, Validated, Not Validated) and make "Validated" a prerequisite for publication in the approval workflow.

**3. Index refresh cadence is understood and communicated.** When an article is published, the Data Cloud data stream must re-ingest it and the search index must update before the agent can retrieve the new content. Understand the org's index refresh schedule and communicate the lag between publication and RAG availability to content teams.

**4. Archival triggers index removal.** When articles are archived, verify that the corresponding vectors are removed from the index on the next refresh. Stale vectors for archived articles are a silent risk.

**5. Version control is meaningful.** Knowledge tracks article versions. When a version is updated and republished, the old version should not persist in the vector store. Confirm the data stream ingests `KnowledgeArticleVersion` correctly and that superseded versions are excluded.

### RAG Security at the Retrieval Layer

Data 360 supports attribute-based access control (ABAC) at the object, field, and row levels via Data Governance Policy settings. This is the primary mechanism for controlling what data is visible to whom, including within RAG search indexes. For unstructured data, metadata filtering (prefilters on search indexes) can restrict what gets retrieved.

The Einstein Trust Layer routes all prompt traffic through a sequence of security controls before and after the LLM call: PII data masking is applied first, followed by prompt toxicity detection, LLM inference (with zero data retention enforced via enterprise API), and output toxicity detection before the response reaches the end user. Every step of the prompt and generation flow is recorded as timestamped metadata in the audit trail. To protect against RAG poisoning specifically, strict data governance and validation rules must be applied before data becomes available for vector search, since Trust Layer controls operate on the prompt at inference time, not on the content of the retrieval corpus itself.

Retrieved content is injected into the LLM context window and may influence or appear in the agent's response. Treat every document in the retrieval corpus as potentially visible to the end user and govern content membership accordingly.

### Governance Checklist for Architects

- [ ] Approval process attached to all sensitive record types
- [ ] Validation Status field enabled and defaulted to "Work In Progress" for new articles
- [ ] Index refresh schedule documented and communicated to content teams
- [ ] Archived articles confirmed to be excluded from the vector store on refresh
- [ ] Category assignments required before publication (enforced via validation rule if needed)
- [ ] Regular knowledge audits scheduled (monthly or quarterly) aligned to article rating reports
- [ ] Article feedback mechanism (thumbs up/down) enabled and reviewed periodically

> **Scenario.** A client publishes a corrected version of a product safety article after discovering a factual error. The corrected article is published at 9:00 AM. The client's support team begins directing customers to the agent at 9:15 AM, assuming the correction is live. But the index refresh schedule runs every four hours. The agent is still retrieving the old, incorrect version of the article until 1:00 PM. The architect recommends documenting the refresh cadence explicitly in the team's publication runbook and building a pre-launch validation step that queries the index to confirm the new version is retrievable before agent go-live.

---

## 10. Testing: Retrieval Before Agent

### Why This Matters

Most architects test a grounded agent by talking to it. That is the least efficient way to debug a RAG problem. When an agent gives an unsatisfactory response, the failure could be in the agent's topic classification, the action selection, the retriever routing, the search index population, or the LLM's use of retrieved content. Jumping straight to agent-level testing means investigating all five layers at once. Testing retrieval in isolation first eliminates four of them.

The Agentforce Testing Center also eliminates the risk of deploying an agent that hallucinates, gives inconsistent responses, or fails on edge-case queries. Without pre-deployment testing, those failures happen in production, in front of customers.

### The Core Principle

Test retrieval at the **prompt-template level in isolation** before testing the full agent. This is not optional. It is the only reliable way to distinguish retrieval problems from LLM generation problems from agent orchestration problems.

### Four-Layer Troubleshooting Model

When a RAG-powered agent gives an unsatisfactory response, investigate these layers in order:

**Layer 1: Agent Orchestration.** Is the right topic and action being called? Use Agentforce Agent Builder or the Testing Center to inspect the reasoning path. If the wrong topic is being selected, or the right topic is selected but the wrong action is called, the issue is in the agent's instructions and classification descriptions. This is an agent configuration problem, not a RAG problem.

**Layer 2: ADL Retriever Routing.** Is the right retriever being passed to the action? When using ADL and the standard action, Agent Builder shows the reasoning engine's intermediate results. Confirm the correct grounding source and retriever are being passed into the prompt template.

**Layer 3: Search Index.** Does the index contain vectors? Run a query in the Data Cloud Query Editor against the index DMO. Compare the article count in the index DMO against the count in `KnowledgeArticleVersion__dlm` to detect a partial or failed index refresh. Also use Data Explorer to confirm records exist.

**Layer 4: Prompt Template.** Is the prompt being augmented with retrieved content? Use **Prompt Builder** to preview the resolved prompt with representative inputs. Prompt Builder renders the grounded prompt, including retrieved chunks, so you can inspect what the LLM is actually receiving without triggering a full agent run. For prompt templates that invoke Flows as data providers, use **Flow Builder's debugger** to trace flow execution and confirm the correct records are being fetched. Standard **system debug logs** can also be enabled for Apex-backed data providers to verify retrieval logic is executing as expected.

### RAG Quality Metrics: Three Key Signals

Once the pipeline is confirmed to be connected, evaluate qualitative performance using three RAG evaluation metrics. These metrics are recorded in the `AiRetrieverQualityMetricDmo__dlm` DMO in Data Cloud. The DMO's field prefix is **`std__`** in most orgs (for example, `std__AnswerRelevancyScoreNumber__c`), though some older or differently-provisioned orgs may surface it under the **`ssot__`** prefix. Always verify the actual prefix in the target org's Data Cloud schema before writing queries.

**Context Precision** (`std__ContextPrecisionScoreNumber__c`): What proportion of the retrieved chunks were actually relevant to the query? Low scores indicate a retrieval scoping problem. The retriever is surfacing articles from the wrong domain, category, or topic. Fix the retriever prefilters or tighten the search index scope.

**Faithfulness** (`std__FaithfulnessRelevancyScoreNumber__c`): Is the response grounded in the retrieved content, or is the LLM generating beyond it? Low scores indicate hallucination. The retrieved context is being ignored or supplemented by the model. Improve prompt template instructions, reduce the temperature setting, or consider a stronger model.

**Answer Relevancy** (`std__AnswerRelevancyScoreNumber__c`): Is the final answer actually relevant to the original user question? This is the end-to-end quality signal. Low scores despite high Faithfulness and Context Precision usually mean not enough context is being retrieved to fully answer the query. Increase the number of retrieved results or broaden the search index.

**Common diagnostic patterns:**

- High Faithfulness + Low Context Precision: The agent is faithfully citing the wrong articles. Fix the retriever scope, search string, or content categorization.
- Low Faithfulness + High Context Precision: The right articles are surfaced but the LLM is not using them. Improve prompt template instructions or consider a stronger model.
- High Faithfulness + High Context Precision + Low Answer Relevancy: Not enough context is being retrieved to fully answer the query. Increase the number of retrieved results or broaden the search index.

### Using the Agentforce Testing Center

The Agentforce Testing Center is automatically enabled for all Agentforce customers in Sandbox orgs at no additional cost. It supports:

- **CSV Upload:** Manual test case creation using the provided template
- **AI-Generated Test Cases:** Automated generation based on agent configuration
- **Knowledge-Based Generation:** Create Q/A pairs directly from Agentforce Data Library content
- **Conversation History Import:** Import multi-turn conversations from Agent Builder

Evaluation metrics include topic classification (exact match), action sequences, response quality scored by an LLM judge (0-5 scale; 3 or higher is a pass), citation support, instruction adherence, and latency measurement.

> **Note on Testing Center limits:** The internal knowledge base document (published May 2026) states a maximum of 500 test cases per job, 10 jobs per hour, and a recommended batch size of 20-30 test cases. However, there is an unresolved discrepancy between this source and Salesforce Help article 005228642, which reportedly states different limits (1,000 test cases per job; a 10-per-10-hour window). Treat any quoted limits as subject to change and verify against the org's current Testing Center configuration before quoting them to a customer.

Always build test cases that cover:
- Queries well within the knowledge base scope (should produce grounded, cited responses)
- Queries at the edge of scope (should produce "I can't find an answer" responses, not hallucinations)
- Queries in languages other than English, if the Multilingual E5-Large embedding model is in use

> **Scenario.** An architect is debugging an agent that intermittently gives vague responses to warranty questions. Layer 1 confirms the right topic and action are being selected. Layer 3 confirms the index is fully populated. Layer 4, previewing the prompt template in Prompt Builder, reveals the problem: the resolved prompt contains 10 retrieved chunks, but 8 of them are from an unrelated "General FAQs" category because the retriever lacks a prefilter scoping it to the "Warranty" category. Fixing the retriever prefilter resolves the problem. Querying `std__ContextPrecisionScoreNumber__c` in `AiRetrieverQualityMetricDmo__dlm` afterwards confirms the precision score climbed from 0.2 to 0.9. Without the layered troubleshooting approach, this would have taken hours to find.

---

## 11. Migrating from Classic Knowledge to Lightning Knowledge

### Why This Matters

Many Salesforce orgs in use today still run on Classic Knowledge. Classic Knowledge cannot feed Agentforce Data Libraries directly. Before a client can take full advantage of ADL-based RAG grounding, they must migrate to Lightning Knowledge. This migration has architectural implications that directly affect the RAG pipeline design, so architects need to plan it carefully rather than treat it as a routine technical upgrade.

### When This Applies

If the customer's org is running Salesforce Classic Knowledge (available in Classic and Lightning, but not natively Lightning-native), the migration to Lightning Knowledge is required before ADL configuration. Classic Knowledge articles are stored in separate article type objects (for example, `FAQ__kav`, `How_To__kav`) rather than the unified `Knowledge__kav` object that Lightning Knowledge uses.

### Migration Path

Salesforce provides the **Knowledge Migration Tool** (Setup > Knowledge > Knowledge Migration) to move Classic Knowledge content to Lightning Knowledge. Key architectural implications:

**1. Article type objects collapse into record types.** Each Classic article type becomes a record type in Lightning Knowledge. Map Classic article types to Lightning record types before migrating.

**2. Data categories and visibility settings are preserved.** Category assignments on articles carry over, but verify category group structure after migration.

**3. Page layouts must be rebuilt.** Classic article type page layouts do not migrate. Rebuild them in Lightning as described in Section 2.

**4. Custom fields migrate with the article type.** Custom fields from Classic article types are preserved but may need re-evaluation, particularly long-text fields that will be targeted as index fields in the RAG pipeline.

**5. Lightning Knowledge cannot be disabled after enablement.** Enable it in a sandbox first, run the migration, validate article content and category assignments, then proceed to production.

**6. Versioning behavior differs.** Classic Knowledge has its own version model. Review article history carefully after migration to confirm versioning integrity before configuring the data stream.

### Post-Migration RAG Readiness Audit

After migrating to Lightning Knowledge, before configuring ADL:

- [ ] Confirm all migrated articles have accurate Publication Status (Published, Draft, or Archived)
- [ ] Confirm all migrated articles have category assignments
- [ ] Review article body field content for quality (see Section 4 authoring best practices)
- [ ] Rebuild page layouts with appropriate fields for the RAG field mapping strategy
- [ ] Enable Validation Status and assign statuses to migrated articles
- [ ] Set up approval processes on record types before enabling article creation by authors

### External Content Integration

For customers with knowledge content in external systems such as SharePoint, Google Drive, Confluence, or ServiceNow, note that the Knowledge Migration Tool is specifically for Classic-to-Lightning migration. External content is a separate ingestion path via Data Cloud connectors or manual file upload into ADL. Architects should determine early whether external content warrants a separate search index and retriever or whether it should be consolidated into Knowledge articles before ADL configuration.

> **Scenario.** A client migrates 8,000 Classic Knowledge articles to Lightning Knowledge. Post-migration, the architect discovers that approximately 1,200 articles had their Publication Status reset to "Draft" during migration due to a validation rule conflict on the new page layout. The agent's index contains only the 6,800 articles that migrated cleanly as Published. The architect identifies the gap by comparing the index DMO count to the full `Knowledge__kav` count in the Query Editor, as described in Section 5.

---

## 12. Architect's Quick-Reference Checklist

Use this checklist when scoping or auditing a Knowledge-grounded Agentforce deployment.

### Pre-Configuration Audit

- [ ] Lightning Knowledge enabled (or migration path from Classic planned)
- [ ] Knowledge User licenses assigned to all article authors and admins
- [ ] Permission set(s) defined for Knowledge managers, contributors, and readers
- [ ] Record types defined for each article category (FAQ, How To, etc.)
- [ ] Page layouts configured with appropriate fields for authoring and RAG targeting
- [ ] Data category groups and categories defined, activated, and communicated to authors
- [ ] Approval workflows attached to sensitive record types
- [ ] Validation Status field enabled and defaults set

### RAG Pipeline Design Decisions

- [ ] ADL path vs. manual Data Cloud pipeline selected (rationale documented)
- [ ] Source scope defined: Knowledge articles only, files only, or both
- [ ] If Knowledge plus other sources: separate search indexes planned for each source type
- [ ] Field selection strategy documented (which fields to index, prepend, filter, and return)
- [ ] Chunking strategy chosen (max 512 tokens; smaller for dense technical content)
- [ ] Embedding model selected (E5-Large V2 for English; Multilingual E5-Large for non-English)
- [ ] Hybrid search vs. vector-only decision made and cost/latency implications accepted
- [ ] Retriever scope evaluated: default dynamic retriever vs. custom scoped retriever
- [ ] Citation model decided: standard action (inline) vs. custom action (sources list)

### Governance and Ongoing Operations

- [ ] Article publication tied to index refresh schedule; lag communicated to content teams
- [ ] Archival process confirmed to remove articles from vector store on next refresh
- [ ] Knowledge audit schedule established (monthly or quarterly)
- [ ] Article feedback mechanism (ratings) enabled and reporting configured
- [ ] Multimodal content (charts, diagrams) audited for adequate text annotation
- [ ] Retrieval access permissions reviewed (ABAC, permission sets on agent user, `AllowViewKnowledge`)
- [ ] Language alignment confirmed: agent user locale matches article language field values

### Testing and Validation

- [ ] Prompt Builder used to preview resolved prompt in isolation (Layer 4) before agent testing
- [ ] Flow Builder debugger and system debug logs used for data provider tracing where applicable
- [ ] Index population verified via Data Cloud Query Editor (Layer 3)
- [ ] Agent topic and action routing verified via Agent Builder (Layers 1 and 2)
- [ ] Agentforce Testing Center scenarios built for in-scope, edge-scope, and out-of-scope queries
- [ ] Testing Center limits confirmed against current org configuration before planning test runs (published limits have a known discrepancy between sources)
- [ ] RAG quality metrics (Context Precision, Faithfulness, Answer Relevancy) baselined in `AiRetrieverQualityMetricDmo__dlm`
- [ ] Prefix verified in target org schema (`std__` vs. `ssot__`) before writing quality metric queries
- [ ] Multilingual retrieval tested if Multilingual E5-Large model is in use
- [ ] Citation rendering verified in the target channel (web, mobile, voice)

---
