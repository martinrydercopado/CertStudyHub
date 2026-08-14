# RAG, Agentforce & Data 360: Complete Success Architect Study Guide

> **Version:** 2.0 | **Last Updated:** August 2026
> This guide is written for Salesforce Success Architects preparing to advise enterprise clients on Agentforce, Retrieval-Augmented Generation (RAG), and the Data 360 platform. It is structured as a study reference and a client conversation toolkit. Every section answers questions your clients will ask you.

---

## Table of Contents

1. [The Big Picture: What You Are Actually Selling](#1-the-big-picture)
2. [Core Architectural Paradigms: Agents vs. Prompt Templates](#2-core-architectural-paradigms)
3. [How Agentforce Reasons: The Engine Behind the Agent](#3-how-agentforce-reasons)
4. [Context Engineering: The Successor to Prompt Engineering](#4-context-engineering)
5. [The RAG Lifecycle: Four Phases in Depth](#5-the-rag-lifecycle)
6. [Search Indexing and Retrieval Strategies](#6-search-indexing-and-retrieval-strategies)
7. [ADL vs. Manual Setup: Choosing the Right Architecture](#7-adl-vs-manual-setup)
8. [ADL Source Types: Deep Technical Walkthrough](#8-adl-source-types)
9. [Web Search Grounding: The Public Knowledge Pattern](#9-web-search-grounding)
10. [Wiring RAG into Agent Script](#10-wiring-rag-into-agent-script)
11. [The Einstein Trust Layer: Security Architecture for RAG](#11-the-einstein-trust-layer)
12. [Data 360 Architecture: The Intelligence Infrastructure](#12-data-360-architecture)
13. [Permission Model: The Four Layers That Cause Silent Failures](#13-permission-model)
14. [Prompt Engineering for RAG Grounding](#14-prompt-engineering-for-rag-grounding)
15. [Agentforce Observability: Governing Agents in Production](#15-agentforce-observability)
16. [Pro-Code RAG: Apex and the Connect API](#16-pro-code-rag)
17. [MuleSoft as the RAG Extension Layer](#17-mulesoft-as-the-rag-extension-layer)
18. [Cost Model: RAG Consumes Credits](#18-cost-model)
19. [Troubleshooting and Quality Metrics](#19-troubleshooting-and-quality-metrics)
20. [Known Platform Issues and Production Gotchas](#20-known-platform-issues)
21. [Success Architect Client Conversation Frameworks](#21-client-conversation-frameworks)
22. [Architecture Pattern Reference](#22-architecture-pattern-reference)

---

## 1. The Big Picture: What You Are Actually Selling

Before you walk into any client meeting, understand what you are actually positioning. RAG with Agentforce is not a chatbot feature. It is a governed, enterprise-grade AI delivery system built on four pillars:

**Grounding:** The agent answers from your proprietary data, not from general LLM knowledge. This eliminates hallucinations about your products, policies, and processes.

**Trust:** The Einstein Trust Layer ensures that your data never trains third-party LLMs, that sensitive PII is masked before it leaves your org, and that every AI interaction is audited.

**Intelligence Infrastructure:** Data 360 (formerly Data Cloud) is the vector database, identity engine, audit store, and analytics layer that powers every enterprise-grade Agentforce feature.

**Continuous Improvement:** Agentforce Observability closes the loop between production conversations, content quality, and agent improvement. It is a product, not a project.

The bottom line: clients who understand these four pillars make better architecture decisions. Your job is to make sure they understand them before they sign the SOW.

---

## 2. Core Architectural Paradigms: Agents vs. Prompt Templates

### 2.1 The Fundamental Decision

Every Agentforce engagement starts with this decision. Getting it wrong wastes months and budget.

| Dimension | Prompt Template | Agentforce Agent |
|---|---|---|
| **Memory** | Stateless: no memory across turns | Stateful: maintains conversation history |
| **Decision-making** | None: executes a fixed template | Autonomous: decides what to do next |
| **Ideal for** | Single-turn tasks (summarize a case, generate an email) | Multi-turn conversations (handle a support request end-to-end) |
| **Complexity** | Low: one template, one LLM call | High: subagents, actions, routing logic |
| **RAG integration** | Via dynamic retriever in template | Via `knowledge:` block and `AnswerQuestionsWithKnowledge` action |
| **Cost model** | 2-16 credits per invocation | 20 credits per action execution |

### 2.2 The Hybrid Pattern

In practice, the two are not mutually exclusive. A common enterprise pattern is:

- An **Agentforce agent** manages the conversation, routing, and multi-turn context.
- The agent calls **Prompt Template actions** for structured content generation tasks (drafting a case summary, generating a proposal paragraph).
- The Prompt Template uses **RAG via a dynamic retriever** to ground that content in proprietary data.

This is the highest-value pattern for complex service and sales use cases.

### 2.3 When to Recommend Each

**Recommend a Prompt Template when:**
- The task is a single-turn operation triggered by a user or a Flow.
- The output goes into a specific Salesforce field (use a Field Generation Template).
- Multiple unrelated data objects need to be merged into a single context window (use a Flex Template).
- The client wants to start small and prove AI value quickly.

**Recommend an Agentforce Agent when:**
- Users need a conversational experience across multiple turns.
- The agent must make decisions based on user input (routing, escalation, data lookup).
- The use case involves multiple steps that depend on each other.
- The client needs governed, audited AI interactions.

---

## 3. How Agentforce Reasons: The Engine Behind the Agent

Understanding the reasoning loop is critical. When a client asks "why did the agent do that?", this is the framework you use to diagnose and explain the behavior.

### 3.1 The Ten-Step Reasoning Loop

Every agent interaction follows this sequence. Knowing each step lets you diagnose failures precisely.

| Step | Activity | What Happens |
|---|---|---|
| 1 | Agent Invocation | The user sends a message; the agent session begins |
| 2 | Classify Subagent | The reasoning engine reads the user's message |
| 3 | Subagent Selection | The engine matches the message to a subagent based on the subagent's `name` and `description` fields |
| 4 | Execute Scripted Logic | Any `before_reasoning:` hooks and deterministic `run` actions execute first (free, no LLM involved) |
| 5 | Build Prompt | The resolved instructions, variable values, and conversation history are assembled into a prompt string |
| 6 | Send to LLM | The prompt and available actions are sent to the LLM |
| 7 | LLM Decision | The LLM decides: respond directly, ask for more information, or execute an action |
| 8 | Action Execution | If an action is selected, the engine runs it (Apex, Flow, Prompt Template, etc.) |
| 9 | After-Action Logic | `after_reasoning:` hooks fire; deterministic transitions or guards evaluate the result |
| 10 | Grounding Check + Response | The response is validated against scope and grounding before reaching the user |

### 3.2 The Grounding Check

Step 10 is the most important one to explain to clients. Before any response reaches the user, the reasoning engine verifies that:
- The response is based on accurate information.
- The response follows the agent's configured guidelines and instructions.
- The response stays within the agent's defined scope and subagent boundaries.

This is why a well-configured anti-hallucination instruction (telling the agent to refuse when retrieval is empty) is enforced at the engine level, not just at the LLM level.

### 3.3 Phase 1 vs. Phase 2 Execution

Agent Script has a two-phase execution model that architects must understand deeply.

**Phase 1 (Deterministic):** The engine evaluates all conditionals against current variable values, runs any deterministic actions, and builds the final prompt string. No LLM is involved. This is instant and free.

**Phase 2 (LLM):** The resolved prompt string is passed to the LLM with the list of available tools. The LLM reasons over the prompt and decides what to do.

The critical implication: only the Phase 1 output reaches the LLM. If a conditional evaluates to false, the LLM never sees that branch. This is how deterministic authorization gates work. The agent user never knows what content was hidden from the LLM.

---

## 4. Context Engineering: The Successor to Prompt Engineering

### 4.1 What Context Engineering Means

Context engineering is the discipline of designing systems that give an AI agent the exact information and boundaries it needs to succeed. It is not about writing clever prompts. It is about designing the entire information environment the agent operates in.

The three levers of context engineering are:

**Subagents** define specialized areas of expertise. Each subagent has a name and description that the routing engine uses to classify incoming messages. A well-written subagent description is the most important routing tool you have.

**Instructions** define the conversation flow, tone, and behavioral constraints within a subagent. These are the natural language directives the LLM receives in Phase 2.

**Actions and Rules** execute real-world operations (query data, create records, call APIs) and enforce deterministic business logic that the LLM cannot override.

### 4.2 The Principle of Minimal Context

A common mistake in early Agentforce implementations is adding too much to the context window. More context does not always mean better answers. In fact, overly large context windows:
- Increase latency.
- Increase cost (each action execution is 20 credits).
- Dilute the signal-to-noise ratio, causing the LLM to anchor on irrelevant context.

The principle: put only the information the agent needs for the current turn into the context window. For RAG, this means retrieving 3-5 highly relevant chunks rather than dumping an entire knowledge base.

### 4.3 Reliable Context: Filters

Filters control what the LLM sees and what it can do on each turn of a conversation. They work at three levels:

**Subagent-level filters** control which subagents are available to a given user. An internal HR subagent should only be visible to logged-in employees.

**Action-level filters** (`available when`) control which actions a subagent can call based on current variable values. A "Process Refund" action should only be available when the customer has been verified.

**Retriever-level filters** control which content is retrieved. Dynamic pre-filters allow the retriever to restrict results based on runtime values such as the current user's region, the account type, or the product category the conversation is about.

Enhanced retriever pre-filters support:
- Up to 10 dynamic filters per retriever.
- AND/OR logic for combining conditions.
- LIKE operators for pattern matching.

This is a key architectural tool for regulated industries. A financial services agent can retrieve only the articles relevant to the customer's account tier. A healthcare agent can retrieve only the clinical guidelines applicable to the patient's condition category.

---

## 5. The RAG Lifecycle: Four Phases in Depth

RAG quality is determined entirely during these four phases. A failure in any phase cannot be fixed by better prompts. It can only be fixed by going back to the phase where the problem was introduced.

### 5.1 Phase 1: Ingestion

Ingestion connects your enterprise data to Data 360 so it can be indexed. The architectural approach depends on the nature of the source data.

#### Structured Content: Data Model Objects (DMOs)

Structured content, such as Salesforce Knowledge articles or custom objects, is ingested into **Data Model Objects (DMOs)**. DMOs are the harmonized, structured data layer in Data 360. They represent the final, clean source of truth after raw ingested data has been processed through Data Lake Objects (DLOs).

**Why DMOs matter for RAG:** You can configure which fields of a DMO are indexed. This means you can choose to semantically index the `Answer__c` and `Summary__c` fields of a Knowledge article, while using `Title` and `ProductCategory__c` as metadata for pre-filtering. You get semantic search on the long-form content and deterministic filtering on the categorical content. These are two fundamentally different capabilities applied to the same record.

**Best practice for Knowledge articles:** Spread content across multiple fields. A question in one field, a detailed resolution in another, related examples in a third. This gives the chunker more to work with and reduces the risk of a critical answer being split across a chunk boundary.

#### Unstructured Content: Unstructured Data Lake Objects (UDLOs)

Unstructured content, including PDFs, HTML pages, TXT files, and external documents, is ingested into **Unstructured Data Lake Objects (UDLOs)**. UDLOs function as directory tables: they store structured metadata about the unstructured asset (location, file type, language, creation date) while the actual content is processed by the indexing pipeline.

**Audio and video files** are a special case. The files remain at their external location using zero-copy file stores. They are submitted to a transcription service, and only the resulting text transcript is brought into Data 360 for indexing. The original files are never moved.

#### What Not to Index

**Do not index categorical columns** such as picklist values, boolean fields, or short label fields. These produce micro-chunks that are too short to carry semantic meaning. The vector search component of a hybrid search becomes erratic when applied to micro-chunks.

**Do not over-index.** Only include fields that contain substantive information a user would actually ask about. Indexing metadata fields alongside content fields confuses the semantic model.

### 5.2 Phase 2: Chunking

Chunking breaks ingested text into smaller units that represent passages or specific factoids. This is where most RAG quality problems originate.

#### The Fundamental Tension

- **For retrieval:** Smaller chunks are better. A small chunk represents a single, focused factoid. When a user asks a specific question, a small chunk matches precisely.
- **For generation:** Larger chunks are better. The LLM needs enough surrounding context to generate a coherent, accurate answer.

**The practical approach:** Start with the platform default chunk size. Evaluate retrieval quality using debug mode in Prompt Builder. If you see precise but contextually thin answers, increase chunk size. If you see retrieval misses on specific factoids, decrease it.

**Maximum chunk size:** 512 tokens, approximately 400-500 words in Latin-script languages.

#### The Docling Parser: When You Need It

The default semantic extraction parser handles continuous prose well. But it catastrophically fails on:
- Tabular data (pricing grids, comparison tables, specification sheets)
- Multi-column layouts
- Documents with embedded figures and captions
- Complex hierarchical structures (nested lists, outline-format documents)

When the default parser encounters a table, it extracts the text row by row, destroying the column relationships. "Product X" in one row and "450 Nm max torque" several rows later become disconnected chunks with no relationship between them.

**The Docling Parser** is a specialized, third-party intelligent document parsing framework built directly into Data 360. It combines open-source models to execute layout understanding, reading order detection, and advanced table extraction. Tables are kept together as coherent chunks.

**How to enable it:** In the Data 360 Setup, change the UDMO search index's parser setting to Docling. This is configured on the search index, not on the library.

**When to use it:** Any corpus that includes structured documents with tables, pricing grids, technical specifications, or multi-column layouts. When in doubt, test both parsers on a representative document and compare retrieval quality.

#### Field Prepending: Giving Isolated Chunks Context

When a chunk is extracted from its parent document, it loses context. A chunk reading "The maximum torque output is 450 Nm at 3,500 RPM" is meaningless without knowing which product it refers to.

**Field prepending** solves this by prefixing each chunk with metadata fields at indexing time. The chunk becomes: "Product: Industrial Compressor Model X7. Section: Technical Specifications. The maximum torque output is 450 Nm at 3,500 RPM."

This works for DMOs (Salesforce objects) where you can specify which metadata fields to prepend. The result is dramatically improved retrieval precision for corpus-specific queries.

**Good candidates for prepending:** product name or category, article title, document section header, last modified date, author or department, applicable product version.

**Temporal prepending for "What Changed" queries:** A common RAG failure mode is the user asking "What changed in the November update?" Pure vector search cannot answer this because the query's meaning is temporal, not semantic. Prepending a `last_modified_date` or `version` field, combined with a temporal pre-filter on the retriever, enables the agent to answer these queries correctly.

### 5.3 Phase 3: Embedding

Embedding converts text chunks into high-dimensional numeric vectors that capture semantic meaning. This is the mathematical foundation of semantic search.

#### The 1:1 Relationship

One chunk produces exactly one embedding vector. The entire semantic content of that chunk is compressed into a fixed-length array of floating-point numbers. At query time, the user's question is embedded using the same model, and the engine computes cosine similarity between the query vector and every stored vector to find the most semantically similar chunks.

#### The Role of Milvus

Once embeddings are generated, they are managed by **Milvus**, the open-source vector database that Data 360 uses internally for unstructured data indexing and semantic search execution. Milvus is purpose-built for storing and querying billions of high-dimensional embedding vectors at low latency. This is the component that makes millisecond-level semantic search possible even against large corpora.

The architecture layering is:
- **Apache Iceberg/Parquet (Lakehouse Layer):** Stores the original chunk text and metadata permanently.
- **Milvus (Vector Store Layer):** Stores the embedding vectors and serves all similarity queries at query time.
- **Low-Latency NVMe Store:** Provides sub-millisecond access to hot vector data for real-time agent interactions.

As a Success Architect, you do not configure Milvus directly. It is fully managed by the Data 360 platform. But knowing it exists and what it does gives you credibility with a client's data engineering team and helps explain the performance characteristics of semantic search at scale.

#### Embedding Model Selection

**Default model: E5-Large-V2** performs well on English-language enterprise content. It is the right default for monolingual English corpora.

**Multilingual corpora:** Explicitly select the `multilingual-e5-large` model. Even a subtle language variant mismatch, such as indexing in `en_US` and querying in `en_GB`, can cause retrieval degradation. For mixed-language corpora, the multilingual model maintains cross-lingual synonymity, meaning a Spanish query can retrieve a semantically equivalent English chunk without any translation step.

**The cost of model mismatch:** If you index content with one embedding model and later change it, all existing embeddings become incompatible. You must re-index the entire corpus. Finalize your model selection before you index production content.

### 5.4 Phase 4: Retrieval

Retrievers act as the bridge between the vector search index and the prompt template or agent action. They translate a user's natural language query into a vector search, retrieve the most relevant chunks, and return them for LLM consumption.

#### Ensemble Retrievers

When a client has multiple content sources (Knowledge articles, PDFs, external documents), an ensemble retriever bundles multiple individual retrievers into one. At query time, it:
1. Runs the query against each individual retriever simultaneously.
2. Collects the result sets from each retriever.
3. Applies a reranking algorithm to merge and score the combined results.
4. Returns the top N results, drawn from across all sources.

This is the right architecture when users ask questions that span multiple content domains.

#### Dynamic Pre-Filters: Deterministic Data Access Control

Pre-filters are conditions applied at the retriever level, before any vector similarity calculation, to restrict the candidate chunk pool. This is machine-enforceable data access control. It is fundamentally stronger than a prompt-level instruction telling the LLM "do not reveal confidential information."

**Static pre-filters:** Set at configuration time. Example: "Only retrieve chunks where `PublishStatus = 'Online'`."

**Dynamic pre-filters:** Passed at runtime from conversation context or prompt inputs. Example: "Only retrieve chunks where `ProductLine = [current user's assigned product line]`."

Enhanced retriever pre-filters support up to 10 dynamic filters per retriever with AND/OR logic and LIKE operators for pattern matching.

#### Advanced Retrieval Mode

Advanced Retrieval Mode combines iterative retrieval with LLM-based query rewriting:
1. User asks an imprecise or complex question.
2. System runs an initial retrieval.
3. An LLM summarizes the retrieved results.
4. The LLM rewrites the original query using the retrieved context to form a better-targeted query.
5. System runs a second retrieval with the improved query.
6. The second retrieval's results are used for the final response.

This pattern dramatically improves performance on complex, multi-part questions where the initial query phrasing is not optimal.

---

## 6. Search Indexing and Retrieval Strategies

### 6.1 Strategy Comparison Table

| Search Strategy | How It Works | Best For | Limitations | Credit Cost |
|---|---|---|---|---|
| **Vector (Semantic)** | Converts query and chunks to embeddings; finds by cosine similarity | Long-form prose, narrative articles, cross-lingual content | Can miss highly specific keywords, SKUs, product codes | Standard |
| **Keyword (BM25)** | Classic lexical matching on exact and stemmed terms | Short, specific queries; product codes; jargon | No semantic understanding; "car" does not match "automobile" | Standard |
| **Hybrid** | Combines vector + BM25; reranks merged results | Corpora with both narrative content and domain-specific terminology | ~2x credit cost; higher latency; unstable on micro-chunks | ~2x |

### 6.2 When to Use Hybrid Search

Hybrid search is not the automatic upgrade from vector search. It is a deliberate architectural choice that adds cost and latency. Use it when there is a measurable and material reason.

**Use hybrid search when:**
- The corpus contains product names, SKUs, order numbers, or technical codes that vector search consistently fails to retrieve.
- Testing shows a 10-15% or greater recall improvement over pure vector search.
- The client can absorb approximately 2x the Data Cloud services credit consumption.
- Latency is not a primary constraint.

**Do not use hybrid search when:**
- The corpus is primarily categorical (short labels, picklist values, brief descriptions). The keyword component destabilizes retrieval on micro-chunks.
- Response time is critical.
- The content is all narrative prose with no domain-specific terminology that vector search cannot handle.

### 6.3 The Hybrid Search Warning for Categorical Content

When clients ask "why is the agent giving wrong answers on simple category questions?" the answer is often that they turned on hybrid search for a corpus of short categorical content.

The vector component of hybrid search requires chunks with enough semantic scope to produce meaningful embeddings. A chunk containing only "Gold Tier Warranty" has near-zero semantic scope. The vector component produces a near-random similarity score. The reranking algorithm then combines a meaningful keyword score with a near-random vector score, producing unpredictable results.

The fix: use pure vector search for categorical corpora and rely on dynamic pre-filters to enforce categorical constraints deterministically.

---

## 7. ADL vs. Manual Setup: Choosing the Right Architecture

### 7.1 Agentforce Data Library (ADL): The Fast Path

The ADL is the no-code/low-code path to RAG. When you create an ADL, the platform automatically provisions the entire pipeline:

- Data stream (connection to source data)
- Data Lake Object (DLO)
- Data Model Object or Unstructured Data Model Object (DMO/UDMO)
- Search index (with embedding model and chunking configuration)
- Retriever (the bridge to the agent)
- Prompt template (`AnswerQuestionsWithKnowledge`)

The entire pipeline is created from a single CLI command or Setup UI interaction.

**ADL is strictly recommended when:**
- The source data is Salesforce Knowledge articles (KAV objects), OR
- The source data is files (PDFs, HTML, TXT) stored in a Salesforce-managed file store, OR
- The client has an existing active Custom Retriever they want to wire in.

**ADL is not sufficient when:**
- You need to retrieve from long-text fields on standard or custom Salesforce objects that are not Knowledge articles.
- You need complex multi-source merging with custom reranking logic the ensemble retriever does not support.
- Access control requirements require procedural, runtime logic that pre-filters cannot express.

### 7.2 Manual Configuration: The Pro-Code Path

Manual configuration gives you full control over every component of the RAG pipeline. You create and configure each Data 360 object explicitly: data streams, DLOs, DMOs/UDMOs, search indexes, custom retrievers, and ensemble retrievers.

**Manual configuration is required when:**
- The client's content lives in long-text fields on non-KAV Salesforce objects.
- You are retrieving from external systems that require custom data streams.
- You need an ensemble retriever combining more than one ADL source.
- Access control requirements are complex enough to require custom retriever logic.

### 7.3 The Scoping Decision Tree

```
Does the client have content to ground the agent?
├── No → Build agent without RAG; use topics and actions.
└── Yes → Where does the content live?
    ├── Salesforce Knowledge articles (KAV) → ADL KNOWLEDGE source type
    ├── Files (PDF, HTML, TXT) → ADL SFDRIVE source type
    ├── Existing Custom Retriever → ADL RETRIEVER source type
    ├── Public web / client website → General Web Search action (Section 9)
    ├── External system with data residency constraints → MuleSoft + Custom Retriever
    ├── Long-text fields on non-KAV Salesforce objects → Manual Configuration
    └── Multiple heterogeneous sources → Manual Configuration + Ensemble Retriever
```

---

## 8. ADL Source Types: Deep Technical Walkthrough

The ADL CLI (`sf agent adl create --source-type`) accepts exactly three source type values: **`sfdrive`**, **`knowledge`**, and **`retriever`**. These are the three native ADL source types. Web search grounding is a separate agent feature, covered in Section 9.

### 8.1 Source Type Decision Guide

| Source Type | Use When | Provisioning Time | Readiness Signal |
|---|---|---|---|
| **SFDRIVE** | Client has PDF/HTML/TXT files to upload | 2-10 minutes per file (JIT indexing) | `retrieverId` non-null AND file status = `INDEXED` |
| **KNOWLEDGE** | Org has Salesforce Knowledge articles (KAV) | 2-10 minutes (async, can race) | `retrieverId` non-null AND live test query returns non-empty `knowledgeSummary` |
| **RETRIEVER** | Client has an existing active Custom Retriever | Immediately READY | `retrieverId` non-null (same as the provided retriever ID) |

When intent is ambiguous, always ask. "Knowledge base" could mean SFDRIVE (upload PDFs) or KNOWLEDGE (use existing KAV articles). Never guess.

### 8.2 SFDRIVE: File Library Deep Dive

SFDRIVE uses a Just-in-Time (JIT) indexing pipeline. Each file is indexed individually as it is uploaded. The library becomes READY when at least one file has reached `INDEXED` status.

#### Per-File Indexing States

The top-level library status can show READY while individual files are still processing. Always check per-file status for SFDRIVE libraries.

| File Status | Meaning | Action Required |
|---|---|---|
| `UPLOADED` | File landed in storage; indexing not yet started | Wait; indexing is queued |
| `INDEXING` | JIT pipeline is processing the file | Wait |
| `INDEXED` | File is chunked and searchable | Success state |
| `INDEX_FAILED` | Indexing failed for this file | Delete and re-add the file to retry |
| `DELETING` | File removal in progress | Wait |
| `DELETE_FAILED` | Removal failed | Retry deletion |

#### The `--index-mode` Flag: Intelligent Context

| `--index-mode` | UI Label | Effect | Cost |
|---|---|---|---|
| `basic` | "Text Only" | Standard semantic extraction | Standard |
| `enhanced` | "Intelligent Context" | LLM-based processing for tables, images, complex layouts | Substantially higher per-file |

**When to use `enhanced`:** The corpus contains tables, embedded images, infographics, multi-column layouts, or any content where spatial relationships carry meaning.

**When to use `basic`:** The corpus is pure, continuous prose. The cost differential is material for large corpora; do not apply IC universally.

#### SFDRIVE File Limits

- Maximum file size: 100 MB per file.
- Maximum files per library: 1,000 files.
- Supported file types: PDF, TXT, HTML.

### 8.3 KNOWLEDGE: Knowledge Article Library Deep Dive

The KNOWLEDGE source type indexes directly from published Salesforce Knowledge articles (KAV objects). No file upload is required.

#### The `primaryIndexField` Constraint

Two primary index fields must be specified at creation time. These fields are **immutable** after the library is created. Common choices: `ArticleNumber` and `Title`. If you choose the wrong fields, you must delete the library and recreate it.

#### The Day 0 Race Condition

This is the #1 cause of early-stage KNOWLEDGE library failures. The platform has a documented race condition where:

1. The library is created and the CRM Connector is triggered.
2. The Day 0 chunking job fires almost immediately.
3. The CRM Connector has not yet committed article data to the lakehouse (~17-second visibility window).
4. The chunking job sees 0 rows, skips processing, and emits a READY status anyway.
5. The library shows READY with a non-null `retrieverId`, but contains 0 indexed chunks.

**Do not declare success based on `retrieverId` alone for KNOWLEDGE libraries.** Wait approximately 10 minutes, then send a live test query and verify that the returned `knowledgeSummary` is non-empty.

If the `knowledgeSummary` is still empty after 10 minutes, force a re-index:
```bash
sf agent adl update -i "$LIBRARY_ID" \
  --target-org "$TARGET_ORG" \
  --content-fields "Answer__c,Summary__c"
```

#### Language Alignment: The Silent Failure

The retriever filters chunks by language at query time. Even subtle mismatches, such as `en_US` vs. `en_GB`, cause the retriever to silently return 0 results. Always verify that article language matches the agent user's `LanguageLocaleKey` before go-live.

### 8.4 The `rag_feature_config_id` Prefix: The Most Common Implementation Mistake

The value in the `.agent` file's `knowledge:` block is NOT the raw `libraryId`. It is the `libraryId` prefixed with `ARFPC_`:

```
rag_feature_config_id: "ARFPC_1JDg7000001hilBGAQ"
```

Omitting the `ARFPC_` prefix causes a validation failure. The error message points to the `knowledge:` block but does not explain the prefix requirement.

---

## 9. Web Search Grounding: The Public Knowledge Pattern

### 9.1 What Web Search Is (and What It Is Not)

**Important distinction for architects:** Web search grounding in Agentforce is **not** an ADL source type. The three ADL source types are `sfdrive`, `knowledge`, and `retriever`. Web search is implemented through a separate feature: the **General Web Search Topic and Action**, which is configured directly on an Agentforce agent independently of the ADL pipeline.

Confusing these two is a common mistake. The architectural, security, and cost implications are completely different.

| Dimension | ADL RAG (SFDRIVE / KNOWLEDGE) | General Web Search Action |
|---|---|---|
| **Data source** | Your proprietary content | Public internet |
| **Data flow** | Content ingested and indexed in Data 360 | Queries executed against web at runtime |
| **Trust Layer masking** | Applied to retrieved content before LLM | Applied to response content |
| **Citation control** | Citations from your corpus only | Citations from public web pages |
| **Appropriate for** | Proprietary policies, products, processes | Public product info, general FAQs |
| **Compliance posture** | High control, full audit trail | Lower control, external dependency |
| **Configured via** | ADL + `knowledge:` block in `.agent` | General Web Search topic in agent setup |

### 9.2 When to Use Web Search Grounding

Web search is appropriate when:
- The agent's scope includes general public information that is too volatile to maintain in a managed corpus (e.g., current news, publicly available product announcements, publicly listed business hours).
- A client website is the authoritative source for public-facing content, and uploading and maintaining that content in SFDRIVE would create version drift.
- The agent is explicitly positioned as a general assistant with broad scope rather than a compliance-governed specialist.

Web search is **not** appropriate when:
- The content is proprietary (internal policies, pricing, customer data, processes).
- The use case has compliance or regulatory requirements that demand a fully auditable, controlled grounding source.
- The client needs to prevent the agent from surfacing competitor information or off-brand content.
- Data residency requirements restrict processing of content from arbitrary external sources.

### 9.3 The Knowledge-First with Web Search Fallback Pattern

A valid and documented Agentforce design pattern is to configure the agent to use `AnswerQuestionsWithKnowledge` as the primary grounding source, and the General Web Search action as a fallback when the proprietary corpus returns an empty result.

**How it works:**
1. The agent calls `AnswerQuestionsWithKnowledge` for every substantive question.
2. If `knowledgeSummary` is non-empty, the agent answers from the proprietary corpus.
3. If `knowledgeSummary` is empty, the agent invokes the General Web Search action.
4. The agent answers from the web search results, clearly indicating the source is publicly available information, not the internal knowledge base.

**Implementation in Agent Script instructions:**

```agentscript
reasoning:
    instructions: ->
        | For every substantive question, first call
          AnswerQuestionsWithKnowledge.
        | If the knowledge summary is non-empty, answer only from
          that summary and include the returned citations.
        | If the knowledge summary is empty, call the
          GeneralWebSearch action to find publicly available
          information. When answering from web search results,
          tell the user: "I didn't find that in our knowledge base,
          but here is what I found from public sources."
        | Never combine content from the knowledge base and web
          search in the same response without clearly labeling
          which source each piece of information came from.
```

### 9.4 The Use Case Qualifier

The choice between the refuse/escalate fallback (Section 10.3) and the web search fallback depends on the client's risk tolerance and the agent's purpose.

| Fallback Type | Use When | Risk Profile |
|---|---|---|
| **Refuse and escalate** | Compliance-governed agents; regulated industries; proprietary-only scope | Low risk; full control |
| **Web search fallback** | General assistants; public-information agents; broad-scope use cases | Higher risk; external dependency; content not controlled |

**Never recommend the web search fallback to a client in a regulated industry** (financial services, healthcare, government, legal) without first confirming that their compliance team has reviewed and approved the use of public web content as an agent grounding source.

---

## 10. Wiring RAG into Agent Script

### 10.1 The `knowledge:` Block

Place this block between the `connection:` block (if present) and the `language:` block. Block ordering is enforced by the Agent Script compiler.

```agentscript
knowledge:
    rag_feature_config_id: "ARFPC_<libraryId>"
    citations_enabled: True
    citations_url: ""
```

- `rag_feature_config_id`: The `ARFPC_`-prefixed library ID. Required.
- `citations_enabled`: Set to `True` to render inline citations in agent responses.
- `citations_url`: Optional base URL prepended to citation links.

### 10.2 The `AnswerQuestionsWithKnowledge` Action

The reasoning engine auto-instantiates this action when a `knowledge:` block is present. At runtime, it:
1. Takes the current user query as input.
2. Vectorizes the query using the configured embedding model.
3. Runs a similarity search against the configured search index via Milvus.
4. Returns the top N retrieved chunks as `knowledgeSummary`.
5. Returns citation metadata alongside the summary.

### 10.3 The Anti-Hallucination Guard Pattern

This is the most critical instruction block to get right. When retrieval fails, the `knowledgeSummary` output is empty. Without an explicit guard, the LLM may fabricate an answer from its pre-training data.

```agentscript
reasoning:
    instructions: ->
        | For every substantive customer question, call
          AnswerQuestionsWithKnowledge before generating any response.
        | Base your response only on the content returned in the
          knowledge summary. Do not add information from outside
          the knowledge summary.
        | If the knowledge summary is empty or does not contain
          enough information to answer the question, respond with:
          "I don't have that information in my knowledge base right now.
          Please contact our support team at support@example.com or
          call 1-800-EXAMPLE."
        | Include only sources and URLs that were returned
          alongside the knowledge summary. Do not fabricate
          citations or add external links.
```

The four duties are explicit and non-negotiable: call before answering, ground only in returned content, decline gracefully when retrieval is empty, and cite only returned sources.

**When to use the web search fallback instead of refusing:** See Section 9.4 for the use-case qualifier. The refuse pattern is the right default for compliance-governed agents. The web search fallback is appropriate for general-purpose public-facing agents.

### 10.4 Domain-Tuned Refuse Messages

Tailor the refuse message to the agent's domain:

- **Compliance agent:** "I don't have that in our current Policy Manual. Please contact the Compliance team directly at compliance@example.com for guidance."
- **Technical support agent:** "That issue isn't documented in our knowledge base yet. I'll create a case so our Level 2 team can investigate and document a resolution."
- **HR agent:** "I couldn't find that in our HR policies. Please contact HR directly through the employee portal at hr.company.com."

---

## 11. The Einstein Trust Layer: Security Architecture for RAG

This section answers the question every enterprise client will ask you within the first three meetings: "Is our data safe?"

### 11.1 Overview

The Einstein Trust Layer is a set of technical agreements, security controls, and data governance policies built directly into the Salesforce platform. It sits between your org and any external LLM provider. All AI-powered features, including Agentforce and RAG, route through the Trust Layer. It is not optional, configurable middleware. It is mandatory, always-on security infrastructure.

### 11.2 Zero Data Retention

Salesforce maintains contractual zero-data retention agreements with all external LLM providers, including OpenAI and Azure OpenAI. Under these agreements:

- No data sent to the LLM is retained by the third-party provider after the API call completes.
- No customer data is used to train or improve the external LLM models.
- No human at the LLM provider organization has access to your data during or after the transaction.

**How to position this with clients:** "Your data goes in, the answer comes out, and nothing stays. Your proprietary content, customer data, and business logic cannot leak into a shared model that your competitors might also use."

### 11.3 Secure Data Retrieval and Dynamic Grounding

When RAG augments a prompt with retrieved content, the Trust Layer enforces the requesting user's Salesforce permission model. The retrieval query runs under the Einstein Agent User's permission set (for service agents) or the logged-in user's permissions (for employee agents).

This means:
- If an article is in a Knowledge data category that the agent user does not have access to, that article's chunks cannot enter the context window.
- There is no configuration that bypasses these permission checks. They are enforced at the platform level.

**The critical implication:** Permission configuration is not just an IT task. It is a security architecture decision.

### 11.4 Pattern-Based Data Masking

Before the augmented prompt leaves Salesforce and reaches the external LLM, the Trust Layer scans the entire prompt (including retrieved content) for sensitive data patterns and masks them.

**Standard patterns detected and masked:**
- Credit card numbers (PCI DSS compliance)
- Social Security Numbers and National ID numbers
- Healthcare identifiers (HIPAA compliance)
- Bank account numbers
- Passport numbers

**Custom patterns:** Administrators can configure additional custom masking patterns for organization-specific sensitive data.

**How masking works:** Detected patterns are replaced with placeholder tokens (e.g., `[MASKED_CC]`) before the prompt is transmitted. The LLM sees and processes the masked version. The actual values never leave the Trust Layer boundary.

**The architect's responsibility:** Configure and test masking rules before go-live. Run test prompts that include intentionally seeded PII to verify that masking fires correctly. This is a standard item in every Agentforce pre-launch checklist.

### 11.5 Toxicity Scoring and Content Filtering

Every LLM response is automatically scored for toxic content before it is returned to the user. The scoring covers harassment, threatening language, harmful content, discriminatory content, and inappropriate sexual content.

Responses that exceed configured toxicity thresholds are blocked. The toxicity score is logged in the audit trail and stored in Data 360.

**What architects need to know:** Toxicity scoring is always-on and cannot be disabled. For use cases involving emotional or sensitive conversations, test with realistic conversation samples before launch to ensure legitimate content is not being flagged.

### 11.6 Prompt Defense and Prompt Injection Prevention

System-level prompt defense policies are injected by the Trust Layer before the prompt reaches the LLM. These policies:
- Instruct the LLM to stay within the agent's defined scope.
- Prevent the LLM from responding to instructions embedded in user input that attempt to override system behavior (prompt injection attacks).
- Reduce the likelihood of harmful or off-topic outputs.

### 11.7 The Audit Trail

The Audit Trail captures:
- Every prompt sent to the LLM and every response received.
- The trust signals applied to each interaction (masking events, toxicity scores, grounding sources used).
- User feedback on AI responses.

**Storage:** All audit data is stored in Data 360. This is why Data Cloud/Data 360 is required for full Trust Layer functionality.

**Why this matters for architects:** The Audit Trail is also a quality improvement data source. Analyzing patterns of negative user feedback across the audit trail reveals content gaps in the RAG corpus. Analyzing masking events reveals where the data ingestion pipeline is inadvertently pulling sensitive content into the index.

### 11.8 The "Is Data Cloud Required?" Matrix

| Agentforce Feature | Requires Data 360 |
|---|---|
| Basic conversational agent (no RAG) | No |
| RAG via Agentforce Data Library | Yes |
| Full Audit Trail and compliance reporting | Yes |
| Toxicity scoring data storage | Yes |
| Trust Layer Dashboards | Yes |
| Agentforce Analytics | Yes |
| Agent Observability (session tracing, quality scores) | Yes |
| Bring Your Own LLM | Yes |
| External Data Sources for grounding | Yes |
| Unstructured Data (files, PDFs) | Yes |

**The practical answer for enterprise clients:** If they want the features that make Agentforce enterprise-grade (RAG, compliance, analytics, observability), they need Data 360. Frame it as: "Data 360 is the intelligence infrastructure that makes your agent trustworthy, measurable, and improvable."

---

## 12. Data 360 Architecture: The Intelligence Infrastructure

Data 360 (formerly Salesforce Data Cloud, rebranded in 2025) is the foundational platform layer that powers every enterprise Agentforce feature.

### 12.1 The Eight Design Principles

**1. Openness and Interoperability:** Federates with Snowflake, Databricks, BigQuery, and Redshift without data du

**2. Storage-Compute Separation:** Storage and processing scale independently.

**3. Multi-Model Storage:** Supports structured data (DMOs), unstructured data (UDMOs for documents, audio, video), and vector embeddings all in one platform.

**4. Metadata-Driven Design:** All configuration is metadata and can be version-controlled and deployed via Salesforce CLI.

**5. Real-Time Hybrid Processing:** Supports both low-latency retrieval (millisecond response for agent queries) and batch processing (content ingestion, index refresh).

**6. Intelligent and Active Data:** Continuously ingests, analyzes, and pushes insights into business workflows.

**7. Governance and Privacy by Design:** Data lineage, access control, residency rules, encryption, and compliance are built in at the storage layer.

**8. One-to-Many Tenancy:** A single Data 360 org can serve as the source of truth for multiple Salesforce orgs.

### 12.2 The Data 360 Storage Model: Three Integrated Layers

Data 360's storage architecture is a tiered, integrated model. Understanding the three layers helps you explain performance characteristics and design for scale.

**Layer 1: The Lakehouse (Apache Iceberg + Parquet)**
The permanent storage layer. All ingested content, structured records, and metadata live here. The Lakehouse provides ACID transactions, schema evolution, time travel, and high-volume batch processing. This is where chunk text and document metadata are stored permanently.

**Layer 2: Milvus (Vector Store)**
After chunks are embedded, the resulting high-dimensional vectors are managed by **Milvus**, an open-source vector database purpose-built for large-scale embedding storage and similarity search. Milvus is managed internally by the **Data Processing Center (DPC)**, the compute layer responsible for:
- Unstructured data processing pipelines (chunking, embedding generation).
- Event delivery for Data Actions.
- Management of the Milvus vector database for unstructured data indexing.
- Low-latency storage infrastructure.

At query time, the retriever converts the user's query into a vector using the same embedding model, then queries Milvus for the most similar chunk vectors. Milvus handles the cosine similarity computation. This is what enables semantic search at millisecond latency even across millions of chunks.

**You do not configure Milvus directly.** It is fully managed by the Data 360 platform. But knowing it exists and understanding its role gives you the ability to explain performance, scaling, and retrieval characteristics to technically sophisticated clients.

**Layer 3: Low-Latency NVMe Store**
An NVMe SSD-based layer that provides millisecond-level access to frequently queried data. Hot vector data, customer profiles, and real-time engagement signals live here. The retriever accesses embeddings from this layer at query time, not from the Lakehouse directly. This decoupling is what makes real-time RAG retrieval fast even for large corpora.

### 12.3 Zero-Copy Federation: RAG Without Data Movement

Zero-copy federation allows Agentforce to retrieve from data that physically lives in an external system (Snowflake, Databricks, BigQuery) without moving that data into Salesforce storage.

**How it works:** Data 360's query federation layer connects to external data warehouses via JDBC. It translates Data 360 queries into the target system's SQL dialect (query pushdown). For file-based federation, external data must be in Apache Parquet format using the Apache Iceberg tabular format.

**Why this matters for RAG:**
- A client with a massive product catalog in Snowflake can create a search index backed by federated data without an ETL pipeline.
- A client with data residency requirements can keep sensitive content in their own cloud storage and still ground Agentforce on it.

**The latency warning:** Federated data sources have higher retrieval latency than native Data 360 storage because each query crosses a network boundary. Always benchmark retrieval response times for federated sources before committing to this architecture.

### 12.4 Identity Resolution: Unified Profiles for Personalized Grounding

Identity resolution unifies customer records across disparate source systems (CRM, commerce, marketing, support) into a single Unified Individual profile, enabling Agentforce agents to ground on a holistic, unified view of the customer.

**The identity resolution pipeline:**
1. **Matching:** Blocking keys and Locality Sensitive Hashing (LSH) identify candidate record pairs.
2. **Deep Matching:** AI models calculate probabilistic match scores.
3. **Clustering:** Matched records are grouped using transitive closure.
4. **Reconciliation:** Reconciliation rules (Most Frequent, Most Recent, Source Priority) populate the Unified Profile.

Processing frequency: near-real-time, processing small batches of changes as often as every 15 minutes.

### 12.5 Data Spaces: Multi-Tenant Governance

Data Spaces are logical partitions within a Data 360 org used to enforce governance boundaries.

**Use cases:**
- Separating data by business unit or region.
- Separating by sensitivity level (public-facing vs. internal-only content).
- Preventing cross-domain retrieval between unrelated agents.

**The critical gotcha:** The Data Space scope must be configured on the Einstein Agent User's permission set in Setup UI. This is a UI-only configuration. It cannot be deployed via metadata XML. Automated deployment pipelines must include this as a documented manual post-deployment step.

---

## 13. Permission Model: The Four Layers That Cause Silent Failures

This is the section that will save you the most time in production support. The vast majority of "agent is not answering questions" tickets trace back to one of these four layers. All four can fail silently.

### 13.1 Layer 1: Data Cloud Permission Set on the Agent User

The Einstein Agent User must hold a Data Cloud permission set or permission set license.

**Assignment priority:**
1. `GenieDataPlatformStarterPsl` (PSL) if found
2. `GenieUserEnhancedSecurity` (PS)
3. `DataCloudUser` (PS)
4. `DataCloudArchitect` (PS) — last resort, over-privileged but functional

**What happens when this is missing:** `AnswerQuestionsWithKnowledge` returns an empty `knowledgeSummary` for every query. The agent refuses every question. The user sees "I don't have that information" for everything.

### 13.2 Layer 2: Knowledge Object and FLS (KNOWLEDGE Source Type Only)

The Einstein Agent User must have:
- Object-level Read on `Knowledge__kav`.
- Field-level Read on every field configured in the library: `primaryIndexField1`, `primaryIndexField2`, and all `contentFields`.

Custom fields (`Answer__c`, `Summary__c`) require explicit grants. What happens when this is missing: the runtime returns an access error visible only in server-side logs. The user sees no error.

**Deployment template for custom Knowledge field FLS:**

```xml
<PermissionSet>
    <objectPermissions>
        <allowRead>true</allowRead>
        <object>Knowledge__kav</object>
    </objectPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Knowledge__kav.Answer__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Knowledge__kav.Summary__c</field>
        <readable>true</readable>
    </fieldPermissions>
</PermissionSet>
```

### 13.3 Layer 3: Language Alignment (KNOWLEDGE Source Type Only)

The retriever filters chunks by language at query time. The agent user's `LanguageLocaleKey` must match the language of the indexed Knowledge articles. Even `en_US` vs. `en_GB` is treated as a mismatch.

The failure mode is silent: the retriever applies the language filter, finds no matching chunks, and returns an empty result. No error is logged in a way that connects the empty result to the language filter.

**Pre-launch verification:**
```sql
SELECT Language, COUNT(Id) ct
FROM Knowledge__kav
WHERE PublishStatus = 'Online'
GROUP BY Language
```

Compare results to the agent user's `LanguageLocaleKey`.

### 13.4 Layer 4: Data Space Scope

The Data Space scope grant on the agent user's permission set is a separate configuration from the permission set assignment itself. It must be set through Setup UI:

> Setup -> Permission Sets -> click the assigned Data Cloud permission set -> "Data Cloud Data Space Management" -> Edit -> add the ADL's data space (typically `default`) to the Enabled Data Spaces list -> Save.

**This cannot be deployed via metadata XML.** Any automated deployment pipeline must include this as a documented manual post-deployment step. All other layers can be perfectly configured, but grounded queries will still return empty results if this step is missed.

---

## 14. Prompt Engineering for RAG Grounding

### 14.1 Template Types and When to Use Each

**Flex Templates** are used when you need to combine multiple disparate data objects into a single context window. For example: combining a customer's case history, recent Knowledge article views, and a retrieved knowledge summary into one prompt. Right choice for complex, multi-source grounding.

**Field Generation Templates** generate a structured summary directly into a specific Salesforce record field. The target field must be placed on the Lightning page layout in App Builder. Ideal for AI-generated content (case summaries, opportunity summaries, product descriptions) triggered directly on a record page.

### 14.2 Prompt Instruction Design Principles

**Be explicit about the call order.** Tell the LLM to call the retriever action before responding. The default LLM behavior without explicit instruction may attempt to respond from general knowledge first.

**Be explicit about what "no result" means.** The LLM will try to be helpful. Without an explicit instruction, it will fabricate an answer when retrieval is empty rather than admitting it does not know.

**Be explicit about citations.** Tell the LLM which citations it is and is not allowed to use. Explicitly prohibit any citation that was not returned by the retriever.

**Avoid over-constraining.** Instructions that are too long or too specific reduce the LLM's ability to handle edge cases gracefully. Aim for the minimum set of directives that prevent the behaviors you want to prevent.

### 14.3 The Dynamic Retriever Reference

When building Prompt Templates manually (without ADL), the retrieved content enters the prompt via a dynamic retriever reference:

```
{!$EinsteinSearch:sfdc_ai__DynamicRetriever.results}
```

This placeholder is resolved at runtime by executing the configured retriever query and injecting the results into the prompt string. Place it immediately before the instruction block that tells the LLM to use it.

### 14.4 Debugging Without Spending Credits

Append `&c__debug=1` to the URL of any Prompt Builder page to enable debug mode. In debug mode:
- The retrieval step executes normally.
- The retrieved content is displayed in the UI.
- The LLM generation step does NOT execute.
- No credits are consumed.

This allows you to verify retrieval quality independently of generation quality.

---

## 15. Agentforce Observability: Governing Agents in Production

Deploying an agent is not the end of the project. It is the beginning of the product. Agentforce Observability (GA as of November 2025) is the platform for monitoring, analyzing, and continuously improving deployed agents.

### 15.1 Session Tracing

Every agent conversation is logged with a full waterfall trace of each step in the reasoning loop:
- Which subagent handled the message and why.
- Which actions were invoked and in what order.
- What content was retrieved (the actual chunks returned by the retriever).
- Where the agent escalated or ended the conversation.
- The exact prompt sent to the LLM and the response received.

**How architects use session tracing:** Diagnose routing failures, retrieval gaps, and action errors with exact diagnostic data rather than user reports.

### 15.2 Conversation Clusters by Intent

Agentforce Observability uses AI classification to group production conversations by user intent without requiring manual labeling. This creates a real-time view of what users are actually asking the agent, not what you assumed they would ask during design.

**Using conversation clusters:**
- Which intent clusters have the highest escalation rate? These are content gaps.
- Which intent clusters have the highest session length? These are efficiency gaps.
- Which intent clusters were not anticipated in the original design? These reveal new use cases.

### 15.3 Quality Scores

Quality Scores are AI-generated assessments of each interaction's relevance and helpfulness. They surface agent misinterpretations, inefficient subagent flows, and generation failures automatically.

**Using Quality Scores operationally:** Set a threshold (e.g., Quality Score below 60 flags for review) and review flagged conversations weekly. This creates a structured, systematic improvement cadence rather than relying on anecdotal user complaints.

### 15.4 Proactive Health Monitoring

Configure near-real-time alerts on KPIs:
- **Error rate alert:** Fires when error percentage exceeds a threshold.
- **Escalation rate spike:** Fires when escalation rate rises unusually, potentially indicating retrieval failure.
- **Latency degradation:** Fires when average response time increases significantly.

### 15.5 The Agentforce Testing Center

Before deploying changes to the knowledge corpus or agent configuration, upload a synthetic Q&A test set (question + expected answer pairs) and run a bulk evaluation. The platform measures recall, precision, and faithfulness metrics across the full test set.

**Best practice:** Treat synthetic test sets as unit tests for your RAG pipeline. Generate them using an LLM from your document corpus. Run them every time a significant content update is made.

### 15.6 The Continuous Improvement Loop

```
Content Added or Updated
        ↓
Index Refresh (automatic for KNOWLEDGE, triggered for SFDRIVE)
        ↓
Testing Center: synthetic test set evaluation
        ↓
Deploy to Production only if quality threshold passes
        ↓
Observability: session traces + quality scores + conversation clusters
        ↓
Weekly review: content gaps, routing failures, efficiency opportunities
        ↓
Content team addresses identified gaps
        ↓
(cycle repeats)
```

---

## 16. Pro-Code RAG: Apex and the Connect API

### 16.1 When to Use Pro-Code Retrieval

No-code retrievers (ADL + standard retrievers) cover most use cases. Apex retrieval is appropriate in four scenarios:

1. **Procedural access control:** Retrieval results must be filtered based on dynamic runtime user attributes that cannot be expressed as static pre-filter conditions.
2. **Multi-corpus merging with custom ranking:** You need to merge results from multiple search indexes using custom ranking logic the ensemble retriever does not support.
3. **External vector database integration:** The data lives in an external vector database exposed via a MuleSoft API or external service.
4. **Custom reranking models:** You want to apply a fine-tuned reranking model to the retrieval results before they enter the LLM context window.

### 16.2 Data Cloud Connect API SQL Functions

**`vector_search` - Pure Semantic Search:**
```sql
SELECT chunk_text, similarity_score
FROM vector_search(
    search_index_name => 'My_Product_Manual_Index',
    query_text => :userQuery,
    num_results => 5
)
WHERE similarity_score > 0.75
```

**`hybrid_search` - Semantic + Keyword Combined:**
```sql
SELECT chunk_text, similarity_score, keyword_score
FROM hybrid_search(
    search_index_name => 'My_Product_Manual_Index',
    query_text => :userQuery,
    num_results => 5,
    hybrid_weight => 0.5
)
```

The `hybrid_weight` parameter (0.0 to 1.0) controls the balance: 0.0 is pure keyword, 1.0 is pure vector, 0.5 is equal weighting.

### 16.3 Apex Class Architecture for RAG

When implementing pro-code retrieval, the Apex class should:

1. Accept the user query as an `@InvocableVariable` input.
2. Apply runtime access control logic to determine pre-filter values.
3. Build the SQL query string with the appropriate pre-filters.
4. Call the Data Cloud Connect API.
5. Process and format the returned chunks.
6. Return the formatted context as an `@InvocableVariable` output.
7. Return citation metadata (source names, URLs) as separate output fields.

**Governor limit awareness:** Data Cloud Connect API calls count against callout limits (100 callouts per transaction). Design the Apex class to batch multiple queries into a single API call where possible.

---

## 17. MuleSoft as the RAG Extension Layer

### 17.1 The Use Case for MuleSoft in RAG Architecture

MuleSoft enables Agentforce to retrieve from external systems that the ADL and standard Data 360 retrievers cannot reach natively:

- **External knowledge systems:** Confluence, SharePoint, ServiceNow where content cannot be uploaded to SFDRIVE due to licensing or data residency constraints.
- **External vector databases:** Pinecone, Weaviate, Chroma, exposed as a standardized REST endpoint.
- **Legacy content repositories:** Mainframe-era document stores or proprietary CMS platforms via MuleSoft's connector ecosystem.

### 17.2 Agent-to-Agent (A2A) Retrieval via MuleSoft

MuleSoft enables A2A communication where a central Agentforce orchestrator hands off a retrieval-heavy subtask to a specialized external agent:

- **Legal RAG agent:** Grounded on legal documents and contracts. Too sensitive to mix with general customer service content.
- **Finance RAG agent:** Grounded on financial reports, pricing models, and financial policies.
- **Technical Documentation agent:** Grounded on deep technical content too large and specialized for the general service agent corpus.

MuleSoft manages the handoff, receives structured results from the specialized agent, and returns them to the orchestrating Agentforce agent.

### 17.3 MCP Integration for Unified Observability

The Model Context Protocol (MCP) integration between MuleSoft and Agentforce enables retrieval telemetry from external RAG sources to flow into enterprise observability platforms (Splunk, Datadog, Dynatrace), giving operations teams a unified view of AI agent performance across Salesforce-native and externally-integrated data sources.

---

## 18. Cost Model: RAG Consumes Credits

### 18.1 The Credit Consumption Table

| Operation | Credits | Notes |
|---|---|---|
| Routing, transitions (`@utils.transition`) | FREE | Framework navigation |
| Variable management (`@utils.setVariables`) | FREE | State management |
| Escalation (`@utils.escalate`) | FREE | Omni-channel handoff |
| Conditional logic (`if`/`else`) | FREE | Deterministic resolution |
| `before_reasoning:` / `after_reasoning:` hooks | FREE | Pre/post-processing |
| LLM reasoning turn | FREE | The LLM call itself |
| Prompt Template invocation | 2-16 | Varies by template complexity |
| Flow action execution | 20 | Per execution |
| Apex action execution | 20 | Per execution |
| External Service action | 20 | Per execution |
| `AnswerQuestionsWithKnowledge` | 20 | Per call (it is an action) |
| General Web Search action | 20 | Per call (also an action) |

**The key insight:** LLM reasoning is free. Actions cost credits. A user who asks 5 questions in one session costs 100 credits for `AnswerQuestionsWithKnowledge` alone, before any other actions. If the web search fallback fires for 2 of those questions, add another 40 credits.

### 18.2 The Hybrid Search Credit Premium

Hybrid search consumes approximately twice as many Data Cloud services credits as pure vector search. This is because it executes two parallel operations (vector + BM25) and runs a reranking operation over the merged results.

**Recommendation:** Start with pure vector search. Establish a quality baseline. Upgrade to hybrid only if there is a measurable 10-15% or greater recall improvement that justifies the credit premium.

### 18.3 The Web Search Fallback Credit Implication

When using the knowledge-first with web search fallback pattern, be aware that a session where retrieval misses result in web search fallback incurs credits for both the `AnswerQuestionsWithKnowledge` action (20 credits, empty result) and the General Web Search action (20 credits, search executed). High miss rates in the proprietary corpus effectively double the retrieval cost for affected queries. This reinforces why improving corpus quality is always more cost-effective than relying on web search fallback at scale.

### 18.4 The Loop Iteration Limit

Agentforce enforces a hard limit of approximately 3-4 loop iterations per agent session. Do not design agents that rely on retry loops. Always build explicit fallback branches:

```agentscript
reasoning:
    instructions: ->
        | Call AnswerQuestionsWithKnowledge once.
        | If knowledgeSummary is empty, transition immediately to
          the escalation subagent. Do not retry.
```

### 18.5 Credit Optimization Strategies

- **Preemptive action execution in `before_reasoning:`:** Actions that must always run (identity verification, session initialization) run deterministically before the LLM, eliminating unnecessary multi-turn loops.
- **Filter retrieval by pre-conditions:** Use `available when` guards on the `AnswerQuestionsWithKnowledge` action to prevent it from being called when the query is too vague.
- **Cache context in variables:** Store retrieved data (account tier, customer type) in session variables after the first retrieval. Do not call the retrieval action again for the same data.

---

## 19. Troubleshooting and Quality Metrics

### 19.1 The 7-Layer Diagnostic Ladder

When a client reports "the agent is not answering correctly," walk through these layers in order.

**Layer 1: Content Existence**
Does the answer actually exist in the corpus? Search the raw source content before diagnosing the retrieval pipeline.

**Layer 2: Content Quality**
Is the content written in a way that supports semantic retrieval? Short, categorical, or overly technical content without explanatory context retrieves poorly.

**Layer 3: Chunking**
Is the answer split across a chunk boundary? Adjust chunk size or rethink content structure.

**Layer 4: Retrieval**
Are the right chunks being retrieved? Use Prompt Builder debug mode (`&c__debug=1`) to inspect exact chunks returned.

**Layer 5: Context Window**
Is enough relevant context being returned? Increase `num_results` on the retriever and re-test.

**Layer 6: Generation**
Is the LLM ignoring the retrieved context? Strengthen the grounding directive in the instructions.

**Layer 7: Permissions**
Is the agent user blocked from accessing the content? Check all four permission layers from Section 13.

### 19.2 Interpreting RAG Quality Metrics

| Metric | Meaning | Low Score Indicates |
|---|---|---|
| **Faithfulness** | Is the generated answer grounded in the retrieved context? | LLM is fabricating or paraphrasing beyond retrieved content |
| **Context Relevance** | Is the retrieved context relevant to the user's query? | Retriever is returning wrong or off-topic chunks |
| **Answer Relevance** | Does the final answer address the user's question? | Content gap or context window size issue |

**Pattern: Low Faithfulness + High Context Relevance**
Right content retrieved, LLM not using it correctly. Fix: strengthen the grounding directive in instructions.

**Pattern: Low Context Relevance + Any Faithfulness**
Wrong content retrieved. Fix: check embedding model, search strategy, or content quality.

**Pattern: High Faithfulness + High Context Relevance + Low Answer Relevance**
Agent is accurately grounded but the content does not fully answer the question. Fix: content gap; add the missing information to the corpus.

---

## 20. Known Platform Issues and Production Gotchas

### 20.1 KNOWLEDGE Library Race Condition
**Symptom:** Library shows READY with `retrieverId` populated, but every grounded query returns empty `knowledgeSummary`.
**Fix:** Wait 10 minutes, send a live test query. If still empty, force re-index with `sf agent adl update --content-fields "<fields>"`.

### 20.2 Language Filtering Silent Failure
**Symptom:** KNOWLEDGE library is READY and permissions are correct, but grounded queries return empty results.
**Fix:** Align the agent user's `LanguageLocaleKey` with the article language. Even `en_US` vs. `en_GB` is a mismatch.

### 20.3 ADL Upload Gate on Some Orgs
**Symptom:** `sf agent adl upload` fails with "One or more files have not been uploaded..."
**Fix:** Upload files via the Agentforce Setup UI as a workaround until the feature gate rolls out.

### 20.4 Top-Level ADL Status Lag
**Symptom:** `sf agent adl get` shows `IN_PROGRESS` even though all sub-stages show `SUCCESS`.
**Fix:** Do not wait for the top-level status. Use a non-null `retrieverId` as the actual readiness signal.

### 20.5 `@knowledge.*` Compilation Failure
**Symptom:** `sf agent validate` fails with "unresolved reference @knowledge.rag_feature_config_id."
**Fix:** Add the `knowledge:` block and place it before `language:` per Agent Script block ordering rules.

### 20.6 Data Space Scope Is UI-Only
**Symptom:** All permissions are assigned correctly, but grounded queries still return empty results.
**Fix:** Set the Data Space scope in Setup UI on the agent user's Data Cloud permission set. Cannot be automated via metadata deploy.

### 20.7 The `ARFPC_` Prefix
**Symptom:** `sf agent validate` fails with an unresolved reference pointing to the `knowledge:` block.
**Fix:** Prepend `ARFPC_` to the library ID in `rag_feature_config_id`.

### 20.8 Reserved `@InvocableVariable` Keywords
**Symptom:** Apex compiles but agent fails with "SyntaxError: Unexpected 'model'" (or 'description', 'label').
**Fix:** Rename reserved field names. Use `vehicle_model` instead of `model`, `issue_description` instead of `description`.

### 20.9 `@inputs` Scope Violation: The Silent Drop
**Symptom:** An action executes successfully, but a variable set from `@inputs` shows its default value.
**Fix:** Use `@outputs` to capture action results. `@inputs` is only valid during action invocation inside the `with` directive.

### 20.10 The Loop Limit in Action
**Symptom:** An agent that works in preview fails in production after 3-4 turns with a generic error.
**Fix:** Map all execution paths and identify circular references or retry loops. Replace with explicit fallback branches.

### 20.11 Web Search Fallback Content Control Risk
**Symptom (operational, not technical):** The web search fallback surfaces competitor information or off-brand content in agent responses.
**Fix:** Scope the General Web Search action to a specific domain or set of domains. If domain scoping is not sufficient, remove the web search fallback and use the refuse/escalate pattern instead.

---

## 21. Success Architect Client Conversation Frameworks

### 21.1 The Discovery Conversation Opener

Before scoping any Agentforce RAG solution, establish the answers to these five questions:

1. **What is the business outcome?** ("Reduce Tier 1 support tickets" is an outcome. "Build a chatbot" is not.)
2. **Where does the content live today?** (Salesforce Knowledge? SharePoint? PDFs? Public website?)
3. **Who is the audience?** (Customer-facing service agent? Internal employee agent? Sales productivity agent?)
4. **What does success look like in 90 days?** (Drives metric selection and scope boundaries.)
5. **Is Data Cloud already provisioned?** (Determines timeline and whether RAG is in scope for initial delivery.)

### 21.2 The "Is Data Cloud Required?" Conversation

Lead with: "It depends on what you need the agent to do."

If the client wants a basic conversational agent that routes to human agents and executes Salesforce actions, Data Cloud is not required.

If the client wants the agent to answer questions from their knowledge base, produce compliance audit trails, use their preferred LLM, or measure agent performance with analytics, Data Cloud is required.

The practical reality for most enterprise clients: they want at least one of those features. Position Data 360 proactively as the intelligence infrastructure that makes the investment enterprise-grade.

### 21.3 The "Why Is the Agent Not Answering Correctly?" Conversation

Use the 7-layer diagnostic ladder from Section 19.1. The framing for clients:

"When an agent gives a wrong or incomplete answer, the root cause is always in one of these seven places. Let's go through them in order, because fixing the wrong layer wastes time and budget."

This positions you as methodical and expert. It prevents the client from jumping to "rewrite the prompt" as a first response to every quality issue.

### 21.4 The "When Do We Need Hybrid Search?" Conversation

Default recommendation: start with pure vector search.

Upgrade trigger: when the client reports that the agent is not finding answers to questions that involve specific product names, order numbers, policy codes, or other exact-match terminology.

Frame the upgrade decision as measurement-driven: "Let's run a test set of 20 failing queries and compare vector-only retrieval against hybrid. If hybrid delivers 10% or more recall improvement, it is worth the cost increase."

### 21.5 The "Should We Add Web Search?" Conversation

Key question: "Is this agent's scope restricted to proprietary content, or does it include general public information?"

If proprietary only: use the refuse/escalate pattern exclusively. Do not add web search.

If public information is in scope: ask two follow-up questions before recommending web search. First, does the compliance team approve the use of uncontrolled external content as a grounding source? Second, can the client's specific website or domains be scoped to prevent surfacing competitor or off-brand content?

If both answers are yes: the knowledge-first with web search fallback pattern is appropriate, with domain scoping configured on the General Web Search action.

### 21.6 The Architecture Recommendation Framework

**Step 1: State the requirements.** What specific capabilities does this solution need?

**Step 2: State the constraints.** Data residency, existing licenses, content location, timeline.

**Step 3: Apply the decision tree.** Walk through the scoping decision tree from Section 7.3 explicitly.

**Step 4: Recommend the pattern.** Name one of the six patterns from Section 22 and explain why it fits.

**Step 5: Identify the risks.** Name the two or three most likely failure modes and your mitigation approach.

**Step 6: Define success metrics.** Name the specific Agentforce Observability metrics you will use to declare the solution successful.

---

## 22. Architecture Pattern Reference

### Pattern 1: Simplest Viable RAG (ADL + KNOWLEDGE)

**Use when:** Client has existing, well-maintained Salesforce Knowledge articles. Fastest time-to-value.

```
Salesforce Knowledge Articles (Published KAV)
        ↓
ADL KNOWLEDGE source type (auto-provisions full pipeline)
        ↓
Search Index → Milvus Vector Store → Retriever
        ↓
.agent file: knowledge: block + AnswerQuestionsWithKnowledge action
        ↓
User Query → Embedding → Milvus Similarity Search → Grounded Response + Citations
```

**Key risks:** Language alignment failure; Day 0 race condition; Knowledge article quality not optimized for semantic retrieval.

---

### Pattern 2: Document Library RAG (ADL + SFDRIVE)

**Use when:** Client has knowledge in PDF, HTML, or TXT files with no existing Salesforce Knowledge setup.

```
Client Files (PDF / HTML / TXT)
        ↓
sf agent adl upload → JIT Indexing (basic or enhanced mode)
        ↓
UDMO → Docling or Default Parser → Chunks → Embedding → Milvus
        ↓
ADL SFDRIVE Library → Retriever
        ↓
User Query → Retrieval → Grounded Response + Citations
```

**Key decisions:** `basic` vs. `enhanced` index mode; chunk size tuning; per-file `INDEXED` status verification.

**Key risks:** Files with tables fail silently with default parser. Always test with representative documents before bulk upload.

---

### Pattern 3: Multi-Source Ensemble RAG

**Use when:** Client has content in multiple formats that users ask questions across.

```
Source A: Knowledge Articles → ADL KNOWLEDGE → Retriever A
Source B: Product PDFs → ADL SFDRIVE → Retriever B
        ↓
Ensemble Retriever (merges + reranks across both sources)
        ↓
Prompt Template with Dynamic Retriever binding
        ↓
Agentforce Agent → Grounded Response (citations from A and B)
```

**Key risks:** Source overlap creates noisy context windows. Content governance must be consistent across both sources.

---

### Pattern 4: Knowledge-First with Web Search Fallback

**Use when:** The agent's scope includes both proprietary knowledge AND general public information. Compliance team has approved public web grounding.

```
User Question
        ↓
AnswerQuestionsWithKnowledge (primary)
        ↓
[knowledgeSummary non-empty] → Answer from proprietary corpus + citations
        ↓
[knowledgeSummary empty] → General Web Search action (fallback)
        ↓
Answer from web results, labeled as "from public sources"
```

**Key decisions:** Domain scoping on the General Web Search action; compliance review before deployment; credit model implications of double-action miss scenarios.

**Not appropriate for:** Regulated industries, compliance-governed agents, proprietary-only scope.

---

### Pattern 5: Pro-Code RAG with Access Control (Apex)

**Use when:** Retrieval results must enforce dynamic, runtime user-specific access rules that cannot be expressed as static pre-filters.

```
Agent Action (Apex @InvocableMethod)
        ↓
Runtime: query user's role/clearance from Salesforce objects
        ↓
Build dynamic SQL with user-specific pre-filters
        ↓
Data Cloud Connect API: vector_search() or hybrid_search() → Milvus
        ↓
Filtered, ranked chunks returned to Apex
        ↓
Apex formats chunks into structured context string
        ↓
LLM generates response grounded in filtered context
```

**Key risks:** Governor limit exposure; Apex errors fail the action gracefully; requires thorough Apex test coverage.

---

### Pattern 6: External RAG via MuleSoft

**Use when:** The grounding data cannot be ingested into Salesforce due to data residency restrictions, licensing constraints, or volume constraints.

```
External System (Confluence / SharePoint / External Vector DB)
        ↓
MuleSoft API (retrieval endpoint with auth + scoping)
        ↓
Agentforce External Service action → calls MuleSoft API
        ↓
MuleSoft executes retrieval against external system
        ↓
Returns structured chunks + citation metadata
        ↓
Agent formats results into grounding context
        ↓
LLM generates response from externally-retrieved content
```

**Key decisions:** MuleSoft API authentication; error handling if MuleSoft is unavailable; latency benchmarking.

**Key risks:** External system availability becomes an agent dependency. Trust Layer masking still applies to returned content.

---

*Guide Version: 2.0 | Created: August 2026 | Based on Agentforce GA release, Data 360 Architecture official documentation, Einstein Trust Layer Summer 2026*

*v2.0 Changes: Added Section 9 (Web Search Grounding), added Milvus/DPC architecture to Section 12.2, added web search fallback pattern to Section 10.3, added Pattern 4 to Section 22, updated cost model for web search action, corrected ADL source type count to three (not four).*
