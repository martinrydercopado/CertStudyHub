# RAG, Agentforce & Data Cloud
## A Success Architect Guide

---

## Table of Contents

**Part 1: How Agentforce Thinks**
- [Chapter 1: The Mental Model — Atlas and the Hybrid Engine](#chapter-1-the-mental-model)
- [Chapter 2: The Execution Model — Parses, Phases, and Lifecycle Blocks](#chapter-2-the-execution-model)
- [Chapter 3: The Five Instruction Surfaces](#chapter-3-the-five-instruction-surfaces)

**Part 2: The RAG Pipeline — From Data to Grounded Answer**
- [Chapter 4: Why RAG Exists](#chapter-4-why-rag-exists)
- [Chapter 5: The RAG Lifecycle — Four Phases](#chapter-5-the-rag-lifecycle)
- [Chapter 5.5: Corpus Design — Content Best Practices](#chapter-55-corpus-design)
- [Chapter 6: Search Strategies — Vector, Keyword, and Hybrid](#chapter-6-search-strategies)

**Part 3: ADL and the Data Library Architecture**
- [Chapter 7: ADL vs. Manual Setup — Choosing Your Architecture](#chapter-7-adl-vs-manual-setup)
- [Chapter 8: ADL Source Types](#chapter-8-adl-source-types)
- [Chapter 9: Web Search Grounding](#chapter-9-web-search-grounding)

**Part 4: Wiring RAG into Agentforce**
- [Chapter 10: Agent Script Syntax for RAG](#chapter-10-agent-script-syntax-for-rag)

**Part 5: Trust, Infrastructure, and Governance**
- [Chapter 11: The Einstein Trust Layer — Your Security Answer](#chapter-11-the-einstein-trust-layer)
- [Chapter 12: Data Cloud — The Intelligence Infrastructure](#chapter-12-data-cloud)
- [Chapter 13: The Four-Layer Permission Model](#chapter-13-the-four-layer-permission-model)

**Part 6: Production Operations**
- [Chapter 14: Observability — Seeing Inside the Agent](#chapter-14-observability)
- [Chapter 15: When to Involve a Developer — Pro-Code RAG](#chapter-15-pro-code-rag)
- [Chapter 16: The Credit Model — What RAG Actually Costs](#chapter-16-the-credit-model)

**Part 7: Troubleshooting and Client Conversations**
- [Chapter 17: Troubleshooting — The Diagnostic Ladder](#chapter-17-troubleshooting)
- [Chapter 18: Known Platform Issues](#chapter-18-known-platform-issues)
- [Chapter 19: Client Conversation Frameworks](#chapter-19-client-conversations)

**Part 8: Architecture Patterns**
- [Chapter 20: Six Production Architecture Patterns](#chapter-20-architecture-patterns)

**Appendix**
- [A1: The Four Silent Failure Checklist](#a1-four-silent-failure-checklist)
- [A2: RAG Anti-Hallucination Guard Template](#a2-anti-hallucination-guard-template)
- [A3: The Scoping Decision Tree](#a3-scoping-decision-tree)
- [A4: Content Authoring Best Practices Checklist](#a4-content-authoring-checklist)
- [A5: Multi-Source Architecture Decision Guide](#a5-multi-source-architecture-decision-guide)
- [A6: Terminology Reference](#a6-terminology-reference)

---

## Part 1: How Agentforce Thinks

---

### Chapter 1: The Mental Model — Atlas and the Hybrid Engine

#### 1.1 Atlas and the Unified Planner

At runtime, every Agentforce agent is powered by the **Atlas Reasoning Engine**. Atlas is what executes your agent's logic, manages the conversation state, calls actions, and coordinates LLM reasoning. It is the "brain" that clients experience — even if they never hear that name.

Underneath Atlas is the **Unified Planner** — the engineering product that powers it. The Unified Planner was built to unify what were previously two separate execution systems: the Agent Graph engine (optimized for deep reasoning and complex orchestration) and the Voice Planner (optimized for ultra-low latency). Maintaining two parallel systems created duplicate engineering work, inconsistent developer capabilities, and architectural bottlenecks. The Unified Planner solves this by separating platform-managed services (execution infrastructure, prompt injection detection, AI memory) from customer-defined business workflows. Developers build once on a common foundation.

**Why this matters for client conversations:** The Unified Planner reduced response latency from approximately 20 seconds to approximately 2.3 seconds. This was achieved through aggressive parallel execution — context gathering, citation generation, grounding validation, and knowledge retrieval, which previously ran sequentially, now run concurrently wherever possible. Multiple API and tool calls within a customer workflow can also execute in parallel. When clients ask about Agentforce performance, this is the architectural reason latency is where it is.

**The Atlas name is the one to use with clients.** "Unified Planner" is the engineering term. In client conversations, executive presentations, and client-facing documentation, use "Atlas" or "Atlas Reasoning Engine."

#### 1.2 The Fundamental Split: Hybrid Execution

Agentforce runs on a **hybrid engine** — part deterministic, part probabilistic.

- **Deterministic layer:** Evaluates conditionals, injects variable values, filters the available action list, runs pre-configured actions. Completely predictable. No LLM involved.
- **Probabilistic layer (the LLM):** Decides how to respond, which tools to call, how to phrase answers. Reasoned, but not scripted.

The deterministic layer always runs first and sets the boundaries. The LLM operates only within what the deterministic layer has allowed. This split is the source of both Agentforce's power and its diagnostic logic: when something goes wrong, you start by asking what the deterministic layer allowed before the LLM ever saw the conversation turn.

**The Agent Script connection:** Agent Script is the language that encodes this split explicitly. Logic instructions (using `->` syntax) are deterministic. Prompt instructions (using `|` syntax) are passed to the LLM. When Agent Script is compiled into the Agent Graph, deterministic nodes execute without LLM involvement. Prompt-bearing nodes trigger LLM calls. Atlas executes the graph as a state machine, not as an open-ended LLM wrapper.

#### 1.3 Which LLM Does Atlas Use?

The answer depends on which Agentforce Builder was used to create the agent — and this distinction matters for performance, cost, and capability conversations.

| Builder | Default Reasoning Model |
|---|---|
| Legacy Agentforce Builder | OpenAI / Azure OpenAI GPT-4o |
| New Agentforce Builder | OpenAI GPT-4.1 or Anthropic Claude Haiku 4.5 |

Salesforce documentation recommends GPT-4.1, Claude Haiku 4.5, and Gemini 3.5 Flash as the three models most thoroughly tested with Agentforce agents. Neither GPT-4.1 nor Claude Haiku 4.5 is positioned as categorically superior — they optimize for different dimensions, and the right choice depends on your client's specific requirements.

**The trust boundary distinction is the key differentiator for SA conversations:**

- **Claude Haiku 4.5** runs within the **Salesforce Extended Trust Boundary** — AWS Bedrock, using Salesforce-managed private connections. This offers stronger data residency assurance for regulated industry clients. Claude Haiku 4.5 does not support multimodal features.
- **GPT-4.1** runs over the **Salesforce Shared Trust Boundary** — public internet with contractual zero data retention protections. It supports multimodal features and is Salesforce's recommended default for most agent configurations.

> **Client conversation tip:** When a regulated industry client (financial services, healthcare, government) asks which model to use, lead with the trust boundary distinction rather than benchmark comparisons. For most compliance conversations, data residency is the deciding criterion. When capability and feature set are the primary concern, GPT-4.1 is the stronger starting point. Always recommend thorough testing with the client's own workload before committing to a model in production — benchmark scores on generic datasets do not reliably predict performance on a specific domain.

Clients migrating from legacy to new builder should be aware that the default model changes and should re-evaluate their agent's performance after migration.

---

### Chapter 2: The Execution Model — Parses, Phases, and Lifecycle Blocks

This chapter covers what actually happens inside Atlas when a user sends a message. Getting this right is what separates architects who can diagnose production issues in minutes from those who spend hours guessing.

#### 2.1 The Parse: The Real Unit of Execution

The primary unit of execution in Agentforce is not the user turn. It is the **parse**: a single complete cycle through a subagent's three lifecycle blocks. Atlas initiates a new parse in three situations:

1. On first entry into a subagent
2. After every tool call, when an action completes and returns a result
3. On every new user turn within the same subagent

**Why this matters:** A single user turn can trigger multiple parses if that turn involves multiple action calls. The `before_reasoning` block runs at the start of every parse — not just the first one. An architect who treats `before_reasoning` as a session constructor (a block that runs once) will build agents with initialization logic that fires repeatedly, producing unexpected behavior and unnecessary credit consumption.

#### 2.2 The Three Lifecycle Blocks

Every subagent execution runs through three sequential blocks:

| Block | When it runs | LLM involvement | Primary use |
|---|---|---|---|
| `before_reasoning` | Start of every parse, before the LLM sees anything | None | Session initialization, auth checks, context hydration |
| `reasoning` | During instruction resolution, prior to any LLM call | Mixed (deterministic + prompt) | Business logic, conditional gating, tool exposure |
| `after_reasoning` | After LLM has responded and action outputs are captured | None (with a critical caveat) | Variable cleanup, audit logging, transition setup |

Both `before_reasoning` and `after_reasoning` are fully deterministic — no LLM involved, predictable execution, low cost.

**`before_reasoning` in practice:**

Use this block for fetching context records, setting session variables, authentication checks, and context hydration. Any logic that must run before the LLM sees the conversation belongs here.

What does not belong here: logic that should only run once per session (because `before_reasoning` runs on every parse), anything that depends on user input from the current turn (that input has not been processed yet), and transitions (a transition in `before_reasoning` fires unconditionally on every parse and creates loops).

For once-per-session initialization, always guard explicitly:

```
before_reasoning:
    if @variables.sessionInitialized == False:
        run @actions.InitializeSession
        set @variables.sessionInitialized = True
```

**The `is_displayable: True` caveat — a named, documented platform behavior:**

When `is_displayable: True` is set on an action, the platform exits the reasoning loop immediately as soon as the LLM decides to surface that action's output. When this happens, `after_reasoning` never executes. Any orchestration logic placed in `after_reasoning` is silently skipped.

The fix: move must-execute logic into the `before_reasoning` block of the *next* subagent rather than relying on `after_reasoning` completing. This is one of the most common sources of production orchestration bugs in Agentforce deployments.

#### 2.3 Phase 1: Deterministic Resolution (Within the Reasoning Block)

Before the LLM sees anything, the resolver:

1. Evaluates all conditional (`available when`) logic against the current variable state
2. Injects live variable values into the instruction text
3. Filters the available action list — removing actions excluded by conditions
4. Builds a single resolved prompt string

The output of Phase 1 is a clean, context-specific prompt with a filtered action list. This is the key diagnostic insight: **when something goes wrong, reconstruct the resolved prompt.** If you know what the LLM actually received, you can usually locate the bug within minutes.

#### 2.4 Phase 2: LLM Reasoning

The resolved prompt, plus the filtered action list, is passed to the LLM. The LLM makes probabilistic decisions: call an action or answer directly; what parameters to provide; how to phrase the response. The LLM cannot call a filtered-out action. It cannot reference a variable that was not injected. Its freedom is real, but bounded.

#### 2.5 The Re-Resolution Loop

After every action execution, Phase 1 fires again. The resolver re-evaluates all conditionals with the updated state and rebuilds the resolved prompt. This is why post-action guards work correctly: an `available when` condition that depends on a previous action's output properly unlocks or locks the next action after the first action completes.

**The action loop problem — a documented platform risk:**

An action loop occurs when two conditions are simultaneously true: the `available when` gate remains open after the action runs, and the reasoning instructions do not explicitly tell the LLM to stop calling the action. The platform does not automatically suppress an action after it has been called once.

The two documented mitigations:

- Set the gate variable to a closed state as part of the action's post-execution logic
- Use a separate `has_run` boolean that closes the gate after first execution

For RAG retrieval patterns specifically, the canonical guard is:

```
if @variables.retrievalResult == "":
    run @actions.AnswerQuestionsWithKnowledge
```

This ensures the retrieval action fires once and does not loop.

**The iteration guardrail:**

Agent Scripts have a built-in guardrail that limits the ReAct reasoning loop to approximately 3-4 iterations before breaking out and returning to the Subagent Router. This prevents runaway loops but means multi-step workflows requiring more than 3-4 sequential action calls in a single turn should be restructured — breaking work across turns or subagent transitions rather than chaining actions within a single reasoning loop.

#### 2.6 Subagent Transitions — One-Way, Prompt-Discarding

When a transition occurs, Atlas immediately discards any prompt that had been resolved from the current subagent. The final prompt sent to the LLM contains only instructions from the destination subagent. Each subagent gets a clean slate.

**The cost implication:** Any actions executed before a deterministic transition are billed even though their outputs are discarded along with the prompt. Place transitions at the top of reasoning instructions so they execute before any other instructions — and before any potentially wasted action calls.

**Two subagent invocation patterns with opposite behavior:**

| Pattern | Syntax | Control returns? | Use when |
|---|---|---|---|
| Declarative transition | `@utils.transition to @subagents.name` | No — one-way, discards prompt | Permanent handoff to a specialized subagent |
| Direct reference | `@subagents.name` in reasoning.actions | Yes — returns like a function call | Temporary delegation with return to the caller |

Confusing these two patterns produces agents that either lose context unexpectedly (using transition when return was needed) or fail to route permanently (using direct reference when a handoff was intended). Know which you need before writing the routing logic.

> **Scenario: The Order Lookup That Unlocks a Refund**
>
> A retail client's agent has two actions: `LookUpOrder` and `ProcessRefund`. The refund action has an `available when` guard: `order_found = true`.
>
> Turn 1: The user asks for a refund. Phase 1 runs. `order_found` is false. `ProcessRefund` is filtered out. The LLM sees only `LookUpOrder` and calls it. The order is found. `order_found` is set to true.
>
> Phase 1 fires again. Now `order_found` is true. `ProcessRefund` is unlocked. The LLM can now present the refund option.
>
> The user never noticed the refund action was invisible on Turn 1. The deterministic layer managed the transition seamlessly.

---

### Chapter 3: The Five Instruction Surfaces

Not all instructions in an Agentforce agent are equal. They live at different levels and fire at different times. Understanding all five is what lets you diagnose "why is the agent ignoring my instruction?"

#### 3.1 Global System Instructions — The Persona Layer

Injected into every LLM call, for every subagent, in every session. These define the agent's fundamental persona, tone, and non-negotiable behavioral constraints. Think of these as the agent's constitution — the rules that apply everywhere, always.

**What belongs here:** Persona definition, tone, hard refusals, compliance guardrails, language/locale declarations.

**What does not belong here:** Business logic, action call instructions, subagent-specific behavior. Instructions at this level that conflict with subagent-level instructions create unpredictable behavior.

#### 3.2 Subagent System Instructions — The Override Layer

A subagent can declare its own `system:` block. When it does, it **completely replaces** the global system instructions for that subagent. It does not merge with them. This is critical: any global instruction you want to retain in a subagent with a system override must be explicitly restated in that subagent's system block.

**Use sparingly.** The most common use case is a specialist subagent that requires a fundamentally different persona — for example, a technical support subagent that must be precise and technical while the global agent is warm and conversational.

> **Warning:** Omitting global safety constraints from a subagent system override is a common production bug. If the global instructions say "never discuss competitor pricing" and the billing subagent has a system override that does not restate that constraint, the billing subagent will happily discuss competitor pricing. Always audit overrides against the global guardrail list.

#### 3.3 Subagent Reasoning Instructions — The Task Layer

Resolved fresh before every LLM call, within a single subagent's execution. These are the most powerful instructions for controlling behavior because they can be conditional — different instructions depending on the current variable state.

This is where most of the agent's business logic lives: when to call which action, what to do with the result, how to route next.

#### 3.4 Action Descriptions — The Tool Selection Layer

The description attached to each action in the `reasoning.actions` block is what the LLM reads to decide whether to call that action. A vague description produces unreliable tool selection. A precise description produces reliable tool selection.

This is one of the most underinvested areas in most agent designs. Treat action descriptions as contracts: "Call this action when X, and expect it to return Y."

#### 3.5 Topic/Subagent Descriptions — The Routing Layer

In multi-agent and multi-subagent designs, the description on each subagent is what the Router or Supervisor uses to decide where to send the user's request. The quality of routing is directly proportional to the quality of subagent descriptions.

Poor descriptions produce routing failures. Routing failures are the most common production issue in complex agent deployments.

---

## Part 2: The RAG Pipeline — From Data to Grounded Answer

---

### Chapter 4: Why RAG Exists

#### 4.1 The Core Problem

Large Language Models are trained on fixed datasets with a knowledge cutoff date. They know a great deal about the world up to that cutoff, but they know nothing about:

- Your client's specific products, policies, or processes
- Your client's customer data
- Events or changes that occurred after the training cutoff

When a user asks an LLM-powered agent a question about a client-specific topic, the LLM has two choices: say it does not know, or make something up. Without intervention, most LLMs choose option 2. They hallucinate a plausible-sounding answer based on general training patterns. In a customer-facing context, a confident, plausible, wrong answer is worse than a clear "I don't know."

#### 4.2 What RAG Does

**Retrieval-Augmented Generation (RAG)** solves this by giving the LLM access to a curated knowledge store at query time. Instead of relying solely on training knowledge, the agent:

1. Takes the user's question
2. Searches a managed corpus of the client's content
3. Retrieves the most relevant passages
4. Injects those passages into the prompt as grounding context
5. Instructs the LLM to answer only from the retrieved context — not from general training knowledge

The result: an agent that answers questions about the client's specific world, accurately, with citations pointing back to the source documents.

#### 4.3 The Business Case — Why Clients Buy This

At an executive level, RAG is the answer to three questions that every Agentforce client eventually asks:

- "How does the agent know about our products?" (RAG grounding from product knowledge articles and documentation)
- "How do we prevent the agent from making things up?" (the anti-hallucination guard pattern, covered in Chapter 10)
- "How do we keep the agent's answers up to date?" (corpus management, covered in Chapter 5)

RAG is not a technical feature. It is the mechanism that makes Agentforce trustworthy enough to deploy in a production customer-facing context.

#### 4.4 The Four Stages of Grounding Maturity

When helping clients understand their current state and where they need to go, this maturity model gives you a structured framing:

**Stage 1: No grounding.** The agent uses only LLM training knowledge. Works only for generic, public information. Fails immediately for anything client-specific.

**Stage 2: Stuffed prompt.** The team pastes content directly into the agent's system instructions. Works briefly. Collapses as soon as the content exceeds token limits, which happens quickly with any real-world knowledge base.

**Stage 3: Retrieval-Augmented Generation.** A search index is built from the content. At query time, only the relevant chunks are retrieved and injected. The LLM reasons over current, accurate, proprietary content. Scalable.

**Stage 4: Governed, grounded, trusted RAG.** RAG plus the Einstein Trust Layer. Permission-aware retrieval, zero data retention, audit trails, and compliance-grade observability. This is what Agentforce delivers.

> **Scenario: The Insurance Company Without RAG**
>
> An insurance client deploys a service agent without RAG. Users ask about coverage limits, claim procedures, and exclusion clauses. The agent answers confidently — but its answers are based on general insurance knowledge from its training data, not the client's specific policy documents. Two months after launch, a customer cites the agent's incorrect exclusion clause explanation in a complaint. The compliance team shuts down the agent. The project is six months behind.
>
> The same deployment with RAG: the agent retrieves the exact policy document, cites the exact clause, and declines to answer questions not found in the documents. The compliance team approves the agent for production. The project launches on time.

---

### Chapter 5: The RAG Lifecycle — Four Phases

Understanding all four phases is what lets you diagnose why a grounded agent is not producing grounded answers.

#### 5.1 Phase 1: Ingestion

Content enters the system. For SFDRIVE (file-based), files are uploaded via CLI or UI. For KNOWLEDGE (article-based), the search index reads directly from the `Knowledge__kav` object via the CRM Connector. For custom retriever configurations, content enters through a manually configured data stream.

**What can go wrong:** Files in unsupported formats, articles not published (wrong `PublishStatus`), or the CRM Connector not yet committed (the KNOWLEDGE Day 0 race condition — covered in Chapter 18).

**What content belongs in the index:** Long-form substantive text: article bodies, detailed answers, resolution narratives, policy explanations. What does not belong: short picklist values, boolean fields, or categorical metadata columns. Chunks too small to carry semantic meaning degrade retrieval quality across the whole index.

#### 5.2 Phase 2: Chunking

Long documents cannot be represented by a single vector embedding — a single vector cannot semantically represent all content in a multi-page document. The platform breaks content into smaller, semantically coherent units called chunks.

**Chunking configuration levers (for SA-level conversations):**

| Setting | What it controls | SA guidance |
|---|---|---|
| Chunk size | Token length per chunk | Larger chunks preserve more context but reduce retrieval precision. Smaller chunks improve precision but may lose surrounding context. Default is 512 tokens — verify against current release notes before quoting to clients. |
| Chunk delimiters | How the chunker decides where to split | For HTML content, heading tags (H1-H6) are used as natural delimiters. Well-structured articles chunk more cleanly. |
| Field selection | Which fields are indexed | Only indexed fields are chunked. Choose fields with substantive textual content. |
| Prepend fields | Fields prepended to every chunk | Title, product name, and category prepended to every chunk make each chunk self-identifying — critical for meaningful retrieval results. |
| Chunk enrichment | Synthetic metadata added to chunks | Three types: `PLAIN`, `QUESTION`, `METADATA`. |

**Chunk enrichment — when each type wins:**

- `PLAIN`: Sufficient when users phrase queries similarly to how the content is phrased. Lowest overhead.
- `QUESTION`: Most valuable when users ask questions in natural language while content is written as reference documentation. The enrichment generates synthetic questions per chunk, dramatically improving match rates for conversational queries that diverge from document phrasing.
- `METADATA`: Best when retrieval should be guided by structured attributes (product line, category, date) in addition to semantic similarity.

> **Scenario: The Support Documentation That Nobody Could Find**
>
> A software client's corpus had excellent documentation, but retrieval accuracy was low. Users asked "how do I export a report?" while the documentation said "Generating and downloading analytics outputs." Vector similarity was low because the phrasing differed. Switching chunking enrichment from `PLAIN` to `QUESTION` — which generated "how do I export a report?" as a synthetic question for the relevant chunk — raised first-pass retrieval accuracy from 41% to 78% with no content changes.

#### 5.3 Phase 3: Vectorization (Embedding)

Each chunk is converted into a numeric vector representation using an embedding model. Vectors capture semantic meaning — chunks about similar topics end up close together in the vector space, even if the exact words differ.

**Embedding model options:**

| Model | Best for |
|---|---|
| E5-Large V2 (open source) | English-only corpora |
| Multilingual E5-Large (open source) | Multi-language corpora |
| OpenAI Ada 002 | Verify availability in current release notes — status may have changed since this guide was written |

**Embedding model selection is an architectural commitment.** The embedding model must be the same at indexing time and query time. A mismatch produces low similarity scores for every query — which means retrievals always miss. More critically: changing the embedding model after index creation is a de facto destructive operation. Different models use entirely different vector spaces and dimensionalities — every existing vector in the index is invalidated, requiring a full teardown and re-indexing of all content. Treat model selection as an irreversible architectural decision. The multilingual model is the safe default for any org serving users in more than one language.

#### 5.4 Phase 4: Retrieval

At query time, the user's question is embedded using the same model, and the vector store is searched for the nearest-neighbor chunks. Results are ranked by similarity score and returned as the `knowledgeSummary` payload to the agent.

**Pre-filters** restrict the candidate pool before similarity search runs. Pre-filters are deterministic — they eliminate ineligible content entirely, before any vector comparison happens.

- **Static pre-filters:** Set at configuration time. Example: `PublishStatus = 'Online'`
- **Dynamic pre-filters:** Resolved at runtime from conversation context. The filter condition is specified at design time using a placeholder syntax, and the placeholder is mapped to a runtime value (such as a customer's account or product line) by the prompt template. This means one agent and one corpus can serve multiple user segments, each scoped to only their entitled content.

> **Scenario: The Insurance Agent That Filters by Policy Type**
>
> An insurance client's agent handles individual policyholders, small business owners, and enterprise accounts — each with access to different policy documents.
>
> With a static retriever, the team would need separate deployments per segment, or risk surfacing enterprise-tier policy details to individual customers.
>
> With dynamic pre-filters, the agent captures the customer's segment during identity verification and passes it as a runtime filter. Every retrieval query automatically scopes to only the content that customer is entitled to see. One agent. One corpus. Three perfectly scoped experiences.

**What can go wrong at retrieval:** Low similarity scores due to embedding model mismatch, missing permissions at the data space level, or an anti-hallucination guard that is syntactically incorrect and silently passes empty retrieval results to the LLM.

---

### Chapter 5.5: Corpus Design — Content Best Practices

This chapter covers guidance that is often overlooked in implementation conversations. The quality of the retrieval corpus is the single largest determinant of agent answer quality. A well-designed corpus compensates for many retrieval configuration imperfections. A poorly designed corpus cannot be fixed by any amount of retrieval tuning.

#### 5.5.1 Why Content Quality Is an SA Conversation

Many clients assume that once they connect their Knowledge base or upload their document library, the agent will work. The "garbage in, garbage out" principle applies directly to RAG. Corpus curation is a business process conversation, not just a technical one. SAs who understand the content best practices can run that conversation with the customer's Knowledge Manager or Content Team — before implementation begins.

#### 5.5.2 Seven Content Best Practices

These apply whether the corpus is Salesforce Knowledge articles, uploaded files, or custom indexed content.

**1. Favor thoroughness over brevity.**

Generative AI synthesizes best from complete, detailed information. A short article that says "Contact support for help with billing" gives the agent nothing to work with. A thorough article that explains the billing process, common scenarios, and resolution paths gives the agent everything it needs to answer at the right level of detail for any user. In general, err on the side of too much detail rather than too little.

**2. Include real-world examples in a conversational style.**

Users ask questions the way they talk, not the way documentation is written. Including examples — "For instance, if a customer ordered on a Friday and wants same-day delivery, the system will automatically route to the next business day..." — dramatically improves retrieval accuracy for conversational queries. The chunk now contains language patterns that match how users phrase their questions.

**3. Structure articles with heading tags.**

For HTML-formatted content (Knowledge articles, uploaded HTML files), use heading tags (H1 through H6) to signal how content is hierarchically related. The chunking process uses heading tags as chunk delimiters. An article with no headings is chunked arbitrarily by token count. An article with well-placed headings is chunked at logical topic boundaries, producing chunks that are semantically coherent units rather than random text fragments.

**4. Spread content across structured fields in Knowledge articles.**

When indexing Salesforce Knowledge articles, the search index is built against a structured DMO. Take advantage of this structure by spreading long-text content across multiple fields — for example: Question, Description, Resolution, and Exceptions. Annotate the article with metadata that can be used for filtering and prepending. This produces richer, better-targeted chunks than packing all content into a single body field.

**5. Include common synonyms and abbreviations in article text.**

The LLM understands how concepts relate to each other by what it reads in the chunks. If your documentation calls a feature "Advanced Analytics Suite" but users ask about "the dashboard" or "AAS," and neither synonym appears anywhere in the documentation, retrieval will consistently miss. Including a brief explanation of synonyms and abbreviations directly in articles closes this gap — no reindexing required.

**6. Focus content and align it with likely user questions.**

Resist the temptation to dump everything into the corpus. Content that is tangentially related to the agent's use case adds noise to retrieval results. A question about a return policy should not surface a chunk about the company's investor relations page. Curate the corpus scope to match the agent's conversation scope. Use data categories in Knowledge to scope the index explicitly.

**7. Maintain content governance as a recurring process.**

Content quality degrades over time. Products change. Policies are updated. Processes are retired. A Knowledge audit rhythm — quarterly at minimum — keeps the corpus authoritative. Stale content does not produce errors; it produces confidently wrong answers. Governance for RAG is not a launch activity. It is an ongoing operational discipline.

> **Client conversation tip:** Ask this question in every discovery: "Who owns the Knowledge base today, and what is their process for retiring outdated articles?" If there is no answer, you have found your biggest production risk. Frame corpus governance as a prerequisite for agent quality — not an afterthought.

#### 5.5.3 Special Handling: Tables and Complex Formats

Complex tables embedded in documents present a specific challenge. Standard chunking treats a table as flat text — rows become indistinguishable fragments. For documents where table content is important to retrieval quality:

- Convert complex tables to JSON or HTML structure before indexing where possible
- Split very long tables into logical sub-tables with clear headings
- Use `enhanced` index mode (Intelligent Context) for file libraries containing documents with embedded tables, multi-column layouts, or images with text

`enhanced` mode uses LLM-based document processing — sometimes called **Document AI** — to preserve spatial relationships in complex documents. This is what makes the cost meaningfully higher than `basic` mode. Apply it selectively to the files that genuinely need it.

---

### Chapter 6: Search Strategies — Vector, Keyword, and Hybrid

#### 6.1 The Three Strategies

**Vector search (semantic search):** Converts the user's query into a vector and finds the closest chunks in the vector space. Understands meaning and intent even when exact words differ. Strong for natural language questions. Weak for specific identifiers, product codes, and numeric values.

**Keyword search (lexical search):** Matches exact or near-exact terms. Strong for product codes, model numbers, specific terminology, and numeric values. Weak for paraphrased or semantically equivalent queries.

**Hybrid search:** Runs both vector and keyword search simultaneously against the same index, then reranks the combined results using a hybrid score. Strong for the broadest range of query types.

> Example: A user asks "What should I do if my LaserPrinter TX 400 has a paper jam?" Vector search understands "paper jam" and "printer problem." Keyword search matches "LaserPrinter TX 400" exactly. Hybrid search surfaces the right document by combining both strengths.

#### 6.2 Hybrid Search: Implications for SA Conversations

Hybrid search is the recommended default for most production RAG deployments. The trade-offs to communicate to clients:

- **Quality improvement:** More reliable first-hit retrieval across diverse query types
- **Latency cost:** Hybrid runs two separate search operations and then reranks — observable latency increase
- **Credit cost:** Hybrid search consumes roughly twice as many Data Cloud service credits as vector-only search

For corpora consisting of pure, continuous prose where users consistently phrase queries in natural language, vector-only search is sufficient and less expensive. For corpora containing product catalogs, SKU numbers, support case IDs, or technical specifications, hybrid is the safer choice.

**Ranking optimization levers:** Within the search index builder, two additional ranking factors can influence hybrid search results: **popularity** (a designated field representing how frequently an article is accessed) and **recency** (a designated field representing the document's date). The final ranking weights these factors, surfacing more popular and more recent content higher. These are optional and require the corresponding fields to be present and indexed.

#### 6.3 Ensemble Retrieval — Combining Multiple Sources

When the agent needs to draw on content from multiple separate search indexes (for example, both a product documentation index and a resolved-cases index), an **Ensemble Retriever** combines the results.

Ensemble retrievers do not simply merge relevance scores from individual retrievers — scores from different indexes are not directly comparable. Instead, all retrieved chunks from all sources pass through a cross-encoder reranker model that independently scores each (query, chunk) pair and produces a unified ranking. The quality of cross-source ranking improves with the reranker model, not with manual score calibration. This is architecturally significant: it means the ensemble result is genuinely better than any individual retriever result, not just a concatenation.

**ADL and ensemble retrieval:** When an ADL is created that contains both files and knowledge articles, the platform creates two separate retrievers (one for each path). The platform also creates a default ensemble retriever that bundles these two into a single retriever, dynamically reranking across both sources. This is why using the default ADL-provided retriever is recommended over manually created retrievers — the ensemble behavior is already built in.

> **Warning:** If an ADL contains both knowledge articles and files but the agent is pointed at a manually created single-source retriever rather than the ensemble retriever, it will only draw from one source. The other source is silently ignored. Always verify which retriever is wired into the prompt template.

---

## Part 3: ADL and the Data Library Architecture

---

### Chapter 7: ADL vs. Manual Setup — Choosing Your Architecture

#### 7.1 What the ADL Is

The **Agentforce Data Library (ADL)** is the no-code/low-code path to production RAG. When you create an ADL, the platform automatically provisions the complete pipeline: Data Stream, Data Lake Object (DLO), Data Model Object (DMO), Search Index, Retriever, Prompt Template, and Agent Action. One ADL per agent. The agent is the scope.

**ADL is the right default for most client deployments.** It is faster to provision, easier to maintain, and designed specifically for the Agentforce use case. Choose manual configuration only when the ADL's constraints genuinely prevent the required architecture.

#### 7.2 ADL Is a Single-Source Architecture — Today

This is one of the most important architectural facts to communicate clearly in discovery conversations.

**ADL currently supports only two source types: files (SFDRIVE) and Salesforce Knowledge articles (KNOWLEDGE).** No other data sources are supported through the ADL interface.

**ADL is designed as a single-source architecture.** An ADL can contain either files or knowledge articles — or both. If an ADL contains both, it creates two separate retrievers (one per source path) and bundles them into a default ensemble retriever. This works well when both sources are complementary for the same question domain.

However: **the Ensemble Retriever that dynamically merges results from heterogeneous external sources is currently roadmap only.** If the client needs to ground responses in content from sources that ADL does not natively support — long-text fields on non-Knowledge objects, external databases, proprietary document stores — manual configuration is required today.

> **Critical note:** When a client says "we have a knowledge base," always clarify whether they mean Salesforce Knowledge articles (`Knowledge__kav` records) or some other system. These are completely different architectures with different provisioning behaviors, permission requirements, and failure modes. Never assume.

#### 7.3 When ADL Is Not Enough

Use this checklist in every discovery conversation. If any item applies, manual configuration or a pro-code approach is required:

- Content lives in long-text fields on non-Knowledge Salesforce objects
- Content lives in an external system with data residency restrictions that prevent upload
- Access control requirements need runtime procedural logic beyond pre-filters
- The client needs ensemble retrieval across more than two heterogeneous non-ADL sources
- The client already has an active custom retriever they want to reuse (use the `RETRIEVER` source type)

#### 7.4 Multi-Source Architecture: Two Formal Approaches

When a client needs answers that draw from more than one knowledge domain, there are two formal architectural approaches. Understanding the distinction gives you vocabulary for design conversations.

**Approach 1: One prompt template with multiple retrievers**

All retrievers feed into a single prompt template. The agent asks one question and receives context from all sources, merged and reranked. Best when:
- Sources are complementary — a complete answer often requires evidence from more than one domain
- It is not possible to predict in advance which source applies to which question type

**Approach 2: Separate prompt template per retriever**

Each retriever has its own prompt template and corresponding agent action. The agent selects which action to call based on the nature of the question. Best when:
- It is possible to specify which data source applies to which question type
- Different sources require different instructions or response formats
- You want to avoid contaminating one source's results with another's noise

> **Important architecture rule:** A search index maps to exactly one data source. For four data sources (files, knowledge articles, cases, custom records), four separate search indexes are required. There is no single-index multi-source configuration. This is a key discovery question: "How many distinct data sources do you need the agent to draw from?"

#### 7.5 The Scoping Decision Tree

Use this in every discovery conversation to determine the right architecture:

```
Does the client have content to ground the agent?
|
+-- No  --> Build agent without RAG.
|            Use topics and actions for CRM-driven tasks.
|
+-- Yes --> Where does the content live?
    |
    +-- Salesforce Knowledge articles (KAV)
    |    --> ADL: KNOWLEDGE source type
    |
    +-- Files (PDF, HTML, TXT)
    |    --> ADL: SFDRIVE source type
    |
    +-- Existing active Custom Retriever
    |    --> ADL: RETRIEVER source type
    |
    +-- Public web / client website (public info only)
    |    --> General Web Search action (not ADL)
    |
    +-- External system with data residency constraints
    |    --> MuleSoft + Custom Retriever (pro-code)
    |
    +-- Long-text fields on non-KAV Salesforce objects
    |    --> Manual Configuration (pro-code)
    |
    +-- Multiple heterogeneous sources (files + cases + external)
         --> Manual Configuration + Ensemble Retriever (pro-code)
```

---

### Chapter 8: ADL Source Types

The ADL accepts exactly three source types: `sfdrive`, `knowledge`, and `retriever`. Web search grounding is a separate agent feature covered in Chapter 9.

| Source Type | Use When | Readiness Signal |
|---|---|---|
| `sfdrive` | Client has PDF/HTML/TXT files | `retrieverId` non-null AND file status = `INDEXED` |
| `knowledge` | Org has published KAV articles | `retrieverId` non-null AND live test query returns non-empty `knowledgeSummary` |
| `retriever` | Client has an existing active Custom Retriever | `retrieverId` non-null (immediately READY) |

#### 8.1 SFDRIVE: File Library

SFDRIVE indexes each file individually as it is uploaded (Just-in-Time / JIT indexing).

**Per-file indexing states:**

| Status | Meaning | Action |
|---|---|---|
| `UPLOADED` | File landed; indexing not yet started | Wait |
| `INDEXING` | Pipeline processing | Wait |
| `INDEXED` | Chunked and searchable | Success |
| `INDEX_FAILED` | Indexing failed | Delete and re-add |
| `DELETING` | Removal in progress | Wait |
| `DELETE_FAILED` | Removal failed | Retry deletion |

**Index mode — a decision that matters:**

| Mode | UI Label | When to Use | Cost |
|---|---|---|---|
| `basic` | "Text Only" | Pure, continuous prose | Standard |
| `enhanced` | "Intelligent Context" | Documents with tables, images, multi-column layouts | Substantially higher |

`enhanced` mode uses LLM-based document processing (Document AI) to parse and preserve spatial relationships in complex documents — extracting meaningful content from PDFs with embedded tables, scanned images with text, and multi-column layouts that would otherwise chunk as garbled fragments. Apply it selectively to the files that genuinely need it. For a corpus of 10,000 files, applying `enhanced` mode to all of them carries a substantial and ongoing cost that should be quantified before go-live.

**External file storage — SFDRIVE is not limited to Salesforce-hosted files:**

SFDRIVE supports files from external storage platforms without copying the physical files into Data Cloud. Only the raw textual content from the chunking process, and the DMO records, reside on Data Cloud. The physical files stay in their original location.

Supported external storage platforms:
- AWS S3
- Google Cloud Storage
- Azure Blob Store
- (Roadmap via MuleSoft direct connectors): SharePoint, Google Drive, Confluence, Sitemap

This distinction is important for clients with large existing document stores. They do not need to migrate files to Salesforce to use file-based RAG. This is frequently a blocker that disappears once clients understand the architecture.

**SFDRIVE limits (verify against current release notes before quoting):**
- Maximum file size: 100 MB
- Maximum files per library: 1,000
- Supported formats: PDF, TXT, HTML

#### 8.2 KNOWLEDGE: Knowledge Article Library

The KNOWLEDGE source type indexes directly from published Salesforce Knowledge articles. No file upload required. The CRM Connector reads article content and triggers indexing automatically.

**The `primaryIndexField` constraint:** Two primary index fields must be chosen at creation time. They are **immutable after creation** — the platform returns a `PRIMARY_FIELDS_IMMUTABLE` error if you attempt to change them. Common choices: `ArticleNumber` and `Title`. A wrong choice means deleting and recreating the library. Always confirm this choice with the client before creating the library.

**Multiple ADLs can share a search index for KNOWLEDGE libraries** — but only if they use the same identifying (primary index) fields. If the fields differ, a separate search index is created for each ADL. This matters for cost and maintenance when a client has multiple KNOWLEDGE ADLs.

##### The Day 0 Race Condition — The Most Common First-Time Failure

This is a documented platform behavior that catches almost every first-time implementer.

1. You create the KNOWLEDGE library. The CRM Connector is triggered.
2. The Day 0 chunking job fires almost immediately.
3. But the CRM Connector has not yet committed article data to the lakehouse — there is a brief visibility delay.
4. The chunking job sees 0 rows, skips processing, and emits a READY status anyway.
5. The library shows READY with a non-null `retrieverId` — but contains 0 indexed chunks.

**Do not declare success based on `retrieverId` alone for KNOWLEDGE libraries.**

After `retrieverId` appears, wait approximately 10 minutes (chunking jobs run on roughly 10-minute intervals), then send a live test query. Verify that the returned `knowledgeSummary` is non-empty. If it is still empty after 10 minutes, a delivery team member can force a re-index via the ADL CLI by updating the content fields.

##### The Language Alignment Silent Failure

The retriever filters chunks by language at query time. The Einstein Agent User's language setting must match the language of the indexed Knowledge articles. Even `en_US` vs. `en_GB` is treated as a mismatch.

When the language does not align, the retriever silently returns 0 results. The agent declines every question. No error message appears anywhere visible to the client.

**Pre-launch verification:** Confirm the agent user's language/locale setting matches the language of the Knowledge articles. A SOQL query grouped by language against `Knowledge__kav` where `PublishStatus = 'Online'` will surface any mismatches before go-live.

#### 8.3 The `ARFPC_` Prefix — The Most Common Syntax Mistake

When the `knowledge:` block is added to an agent file, the value for `rag_feature_config_id` is **not** the raw library ID. It is the library ID prefixed with `ARFPC_`:

```
rag_feature_config_id: "ARFPC_1JDg7000001hilBGAQ"
```

Omitting the `ARFPC_` prefix causes a validation failure. The error points to the `knowledge:` block but does not explain the prefix requirement. Every first-time implementer hits this.

---

### Chapter 9: Web Search Grounding

#### 9.1 What Web Search Is, and What It Is Not

Web search grounding is **not** an ADL source type. It is implemented through the **General Web Search topic and action**, configured directly on an agent independently of the ADL pipeline.

| Dimension | ADL RAG (SFDRIVE / KNOWLEDGE) | General Web Search Action |
|---|---|---|
| **Data source** | Client's proprietary content | Public internet |
| **Data governance** | Fully controlled, audited | External, uncontrolled |
| **Compliance posture** | High control, full audit trail | Lower control, external dependency |
| **Appropriate for** | Internal policies, products, processes | Public product info, general FAQs |
| **Configured via** | ADL + `knowledge:` block in agent | General Web Search topic in agent setup |

#### 9.2 When Web Search Is Appropriate

**Web search is appropriate when:**
- The agent's scope includes general public information too volatile to maintain in a managed corpus
- The client's public website is the authoritative source and uploading files would create version drift
- The agent is a general assistant rather than a compliance-governed specialist

**Web search is not appropriate when:**
- Content is proprietary
- The use case has compliance or regulatory requirements
- The client needs to prevent the agent from surfacing competitor or off-brand content

> **For regulated industries (financial services, healthcare, government, legal):** Never recommend web search grounding without explicit compliance team approval. In most regulatory frameworks, every grounded response must come from a source within the client's control.

#### 9.3 The Knowledge-First with Web Search Fallback Pattern

A valid design: use `AnswerQuestionsWithKnowledge` as primary, with web search as a fallback when the proprietary corpus returns an empty result.

```
User Question
     |
     v
AnswerQuestionsWithKnowledge (primary)
     |
     +-- [knowledgeSummary non-empty]
     |    --> Answer from proprietary corpus + citations
     |
     +-- [knowledgeSummary empty]
          --> General Web Search (fallback)
               --> Answer from web results, labeled "from public sources"
```

The agent instructions must explicitly label which source each answer came from, and must never blend proprietary and web content in the same response without clear attribution.

> **Credit cost warning:** When a retrieval miss triggers the web search fallback, the session incurs credits for the empty `AnswerQuestionsWithKnowledge` call plus credits for the General Web Search call. High miss rates effectively double retrieval cost. Improving corpus quality is always more cost-effective than relying on web search fallback at scale.

---

## Part 4: Wiring RAG into Agentforce

---

### Chapter 10: Agent Script Syntax for RAG

#### 10.1 The `knowledge:` Block

The `knowledge:` block must be placed between the `connection:` block (if present) and the `language:` block. The compiler enforces block ordering. Placing `knowledge:` after `language:` causes a compilation failure.

```yaml
# Correct placement:
connection:
    messaging: ...    # if present

knowledge:
    rag_feature_config_id: "ARFPC_<libraryId>"
    citations_enabled: True
    citations_url: ""

language: en_US
```

**`rag_feature_config_id`:** The `ARFPC_`-prefixed library ID. Most common syntax mistake on first implementation.

**`citations_enabled`:** Set to `True` to render inline citations in agent responses. Best practice for trust and transparency — users can see exactly where the answer came from.

**`citations_url`:** Optional base URL prepended to citation links. Leave empty if article URLs are self-contained.

#### 10.2 The Fetch-Data-Before-Reasoning Pattern for RAG

The canonical Agent Script pattern for RAG retrieval follows a specific contract that prevents action loops and redundant API calls:

```
before_reasoning:
    if @variables.knowledgeResult == "":
        run @actions.AnswerQuestionsWithKnowledge
            with query = @system_variables.user_input
        set @variables.knowledgeResult =
            @actions.AnswerQuestionsWithKnowledge.knowledgeSummary

reasoning:
    | Use only the content in @variables.knowledgeResult to answer
      the user's question. Do not supplement from general knowledge.
    | If @variables.knowledgeResult is empty, respond with:
      "I don't have that information in my knowledge base right now.
       Please contact our support team at support@example.com."
```

The guard check (`if @variables.knowledgeResult == ""`) ensures the retrieval action fires once and does not loop on subsequent parses within the same turn. The result is stored in a variable and referenced in the prompt, so the LLM receives pre-populated context rather than needing to request it.

#### 10.3 The `AnswerQuestionsWithKnowledge` Action

When the `knowledge:` block is present, Atlas automatically makes this action available. At runtime, it:

1. Takes the current user query as input
2. Calls the ADL's retriever with that query
3. Returns the top-ranked chunks as a `knowledgeSummary` string
4. Optionally populates citation metadata

**Why this action should run deterministically (not as an LLM-callable tool):**

If `AnswerQuestionsWithKnowledge` is placed in the `reasoning.actions` block as a tool the LLM can choose to call, the LLM decides whether retrieval is needed based on the prompt. The LLM sometimes decides it already knows the answer and skips retrieval. This produces hallucinated responses that look authoritative. Running the action deterministically in `before_reasoning` removes that risk entirely.

#### 10.4 The Anti-Hallucination Guard

The guard is the instruction that prevents the LLM from answering when the retrieval result is empty. This is the most important single instruction in any RAG-grounded agent:

```
| If @variables.knowledgeResult is empty or contains no relevant
  information, do not attempt to answer from general knowledge.
  Instead, respond: "I wasn't able to find that information in
  our knowledge base. Please contact [support channel] for help."
```

Without this guard, an empty retrieval result passes an empty `knowledgeSummary` to the LLM. The LLM, interpreting an empty context as a prompt to use its general knowledge, generates a plausible but ungrounded answer. With the guard, the agent acknowledges the gap and routes the user to a human channel.

**The guard must be syntactically correct.** A common failure: the guard references the wrong variable name, so the empty-check never fires. Always verify the variable name in the guard matches the variable name used to store the retrieval result.

#### 10.5 Agent Metadata Deployment Stages

SAs involved in deployment and CI/CD conversations need to understand how Agentforce agent metadata states affect what can be deployed and when.

Agentforce agents exist in three deployment stages, each with different metadata requirements:

| Stage | Description | Required Metadata | Editable? |
|---|---|---|---|
| **Draft** | Agent is being authored; not yet committed | `AiAuthoringBundle` only | Yes — fully editable |
| **Committed** | Agent has been published for use | `AiAuthoringBundle` + `Bot` / `BotVersion` | No — immutable |
| **Legacy** | Agent created before new builder; no authoring bundle | `Bot` / `BotVersion` only | Can be overwritten |

**Key operational implications:**
- A Committed agent cannot be edited in place. Changes require creating a new draft version.
- The full agent must be deployed to an org before deploying a specific `BotVersion` into it. Deploying a version before the parent agent exists in the target org produces a dependency error.
- For CI/CD pipelines managed through Copado or Salesforce DX, these staging states determine which metadata types must be included in each deployment package.

---

## Part 5: Trust, Infrastructure, and Governance

---

### Chapter 11: The Einstein Trust Layer — Your Security Answer

When a client or their security team asks "Is our data safe in Agentforce?", the Einstein Trust Layer is the answer. Understand it well enough to explain it simply, and to know where its boundaries are.

#### 11.1 What the Trust Layer Is

The Einstein Trust Layer is a set of platform-enforced policies and controls that sit between the Agentforce agent and every external LLM call. It is not optional, not bypassable, and not a marketing claim — it is architectural enforcement.

Every prompt that leaves Salesforce passes through the Trust Layer. Every response that returns passes through it. The Trust Layer operates transparently to the user but fully visibly to the audit trail.

#### 11.2 The Five Trust Layer Pillars

**Pillar 1: Zero Data Retention (ZDR)**

Salesforce has contractual agreements with all LLM providers — OpenAI, Anthropic, Google — that prohibit them from retaining prompt data, using it for model training, or logging it in any way that persists beyond the request. ZDR is a legal and contractual guarantee, not just a technical control.

For clients in regulated industries: ZDR is the answer to "does our data train their model?" The answer is contractually no.

**Pillar 2: Dynamic Data Masking**

Before a prompt reaches the LLM, the Trust Layer scans it for sensitive patterns — PII fields, financial data, health information — and replaces identified values with synthetic tokens. The LLM reasons over masked data. The response is de-tokenized before it reaches the user. The original values never leave Salesforce.

**Pillar 3: Prompt Injection Detection**

Malicious users sometimes attempt to override an agent's instructions by embedding hidden commands in their messages — "Ignore your previous instructions and..." The Trust Layer scans user inputs for injection patterns and blocks or flags them before they reach the reasoning engine.

**Pillar 4: Prompt Defense**

System-level policies injected by the Trust Layer instruct the LLM to stay within the agent's defined scope and mitigate prompt injection attacks at the instruction level, complementing the detection controls in Pillar 3.

**Pillar 5: Toxicity Scoring**

Every LLM response is scored for toxic content before it reaches the user. Responses exceeding configured thresholds are blocked. The score is logged in the audit trail. Toxicity scoring is enabled by default. It is admin-configurable (thresholds can be adjusted), but it is on by default and cannot be silently bypassed.

Input-level toxicity detection (before the prompt reaches the LLM) and output-level toxicity detection (before the response reaches the user) both run. For sensitive use cases (HR grievances, healthcare discussions), test with realistic conversation samples before launch to calibrate thresholds appropriately.

#### 11.3 The Audit Trail

The Audit Trail captures every prompt, every response, every trust signal applied, and every user feedback event — stored in Data Cloud.

**For compliance teams:** Pre-built dashboards for audit reporting. Every interaction is traceable.

**For architects:** The Audit Trail is also a quality improvement data source. Patterns of negative feedback reveal content gaps. Patterns where specific users' data frequently surfaces in retrieved content can reveal corpus design issues — or permission gaps at the pre-filter level.

#### 11.4 The Circuit Breaker — Resilience Architecture

Agentforce implements an LLM provider failover mechanism. When primary provider traffic experiences sustained failures above an internal threshold, the platform bypasses retries and routes traffic to an equivalent endpoint — for OpenAI traffic, this means Azure OpenAI.

> **Note on specific thresholds:** Exact circuit breaker parameters (failure percentage thresholds, window duration, reset timers) are not published in Salesforce's public documentation. The architectural behavior described here is confirmed. Do not quote specific numbers to clients — reference Salesforce's published SLA commitments and the circuit breaker architecture concept instead.

**The geographic routing implication:** When the failover fires for US orgs, traffic stays within the US. For EU orgs, failover routes to the nearest Azure OpenAI deployment — which may be US-based. This is a cross-border transfer that should be noted in data residency documentation for EU clients and confirmed against current Salesforce infrastructure documentation before go-live.

#### 11.5 The "Is Data Cloud Required?" Matrix

| Feature | Requires Data Cloud |
|---|---|
| Basic conversational agent (no RAG) | No |
| RAG via Agentforce Data Library | **Yes** |
| Full Audit Trail | **Yes** |
| Toxicity scoring storage | **Yes** |
| Agentforce Analytics | **Yes** |
| Agent Observability | **Yes** |
| Bring Your Own LLM | **Yes** |
| Unstructured data grounding (PDFs, files) | **Yes** |

**The practical answer for enterprise clients:** If they want the features that make Agentforce enterprise-grade — RAG, compliance, analytics, observability — they need Data Cloud. Frame it this way: "Data Cloud is the intelligence infrastructure that makes your agent trustworthy, measurable, and continuously improvable."

---

### Chapter 12: Data Cloud — The Intelligence Infrastructure

#### 12.1 Why Data Cloud Matters for RAG

Data Cloud is the foundational infrastructure for Agentforce grounding. The ADL provisions its entire pipeline within Data Cloud. The Audit Trail lives in Data Cloud. Observability data flows through Data Cloud. Without it, none of the enterprise-grade features discussed in this guide exist.

> **Scenario: The Frantic Go-Live Morning**
>
> 8 AM on go-live day. The agent is deployed. Permission sets are assigned. The ADL shows READY. But every test question gets a polite decline.
>
> The four-layer diagnostic in order:
> 1. Layer 1 check: Is the Data Cloud permission set assigned to the agent user? Confirmed.
> 2. Layer 2 check: Does the agent user have access to the correct Data Cloud data space? Missing. The data space permission was never assigned. A 30-second fix that took 90 minutes to diagnose.
>
> Go-live is delayed by two hours. The four-layer permission model in Chapter 13 is the pre-launch checklist that prevents this scenario.

#### 12.2 Data Cloud as a Zero-Copy Infrastructure

Data Cloud's architecture supports zero-copy data access for structured data from external platforms — Snowflake, Databricks, cloud storage. For RAG specifically, SFDRIVE-based libraries also follow a zero-copy model for external file storage: the physical files never move to Data Cloud. Only the text extracted from chunking, and the DMO records containing vectors, reside there. This matters for:

- **Data residency compliance:** The original file stays in its source location (S3, Azure Blob, etc.)
- **Storage cost:** Clients are not paying Data Cloud storage costs for large binary files
- **Governance:** Source-side access controls on the file storage remain the authoritative gate

#### 12.3 Data 360 ABAC and RAG Security

Data 360 supports **attribute-based access control (ABAC)** at the object, field, and row levels via Data Governance Policy settings. This is the primary mechanism for controlling what data is visible to whom within RAG search indexes.

For structured data, user access conditions are implemented using user attributes and permission sets. For unstructured data — the files and Knowledge articles powering RAG — metadata filtering (pre-filters on search indexes) can restrict what gets retrieved for a given user or context.

Together, these controls mean RAG security can be as granular as the content requires: different users retrieve from different slices of the same corpus, enforced at the retrieval layer before any LLM call. To protect against RAG poisoning attacks — where malicious content is injected into the corpus to manipulate agent responses — apply strict data governance and validation rules before data becomes available for vector search.

---

### Chapter 13: The Four-Layer Permission Model

When RAG is working in development but failing in production, permissions are the first diagnostic layer. The failure usually lives at exactly one of these four layers.

#### Layer 1: Data Cloud Permission Set

The Einstein Agent User must be assigned the correct Data Cloud permission set. Without it, the agent user cannot access Data Cloud at all — no retrieval queries execute, no results return, and no error surfaces to the user. The agent just says "I don't have that information."

**Diagnostic check:** In Setup, confirm the agent user profile has the required Data Cloud permission set assigned. This is frequently missed during go-live handoffs because it lives outside the Agentforce setup flow.

#### Layer 2: Data Space Access

Within Data Cloud, the agent user must have access to the correct data space — the logical partition of Data Cloud where the ADL's search index lives. Access to Data Cloud generally (Layer 1) does not automatically grant access to every data space within it.

**Diagnostic check:** Confirm the agent user is granted access to the specific data space that contains the ADL. Mismatches here produce the same symptom as Layer 1 failure: silent empty retrieval results.

#### Layer 3: Search Index Permissions

The search index itself has its own access control. The agent user must be authorized to query the specific search index powering the ADL's retriever. A user with Data Cloud access and data space access but no search index permission cannot execute retrieval queries.

**Diagnostic check:** Inspect the search index's permission configuration in Einstein Studio and confirm the agent user or its assigned role is listed.

#### Layer 4: Knowledge Article Visibility (KNOWLEDGE source type only)

For KNOWLEDGE ADLs, one additional layer applies: the Knowledge article's data categories and sharing rules. The CRM Connector respects Knowledge's native visibility controls. Articles that the agent user's profile cannot see in Salesforce are not indexed — and therefore cannot be retrieved.

**Diagnostic check:** Confirm the agent user's profile has Read access to the relevant Knowledge article types and data categories. A common mistake: the agent user has all four permission layers configured correctly, but the Knowledge articles are scoped to an internal audience and the agent user is an external community profile.

> **The four-layer mental model:** Think of these as four gates on the same path. All four must be open for retrieval to succeed. Any one closed gate produces the same visible symptom — silent retrieval failure — but a different root cause. Always check them in order, from Layer 1 to Layer 4.

---

## Part 6: Production Operations

---

### Chapter 14: Observability — Seeing Inside the Agent

#### 14.1 The Observability Data Model

All Agentforce session and interaction data flows into Data Cloud as a set of related DMOs. Understanding the data hierarchy is what makes querying it in the Salesforce AI Query Library or building custom dashboards practical.

```
AiAgentSession (1)
+-- AiAgentInteraction (N)         -- one per conversation turn
|   +-- AiAgentInteractionStep (N) -- internal steps per turn
+-- AiAgentMoment (N)              -- one per intent in the session
|   +-- AiAgentTagAssociation (N)  -- quality score junctions
AiRetrieverQualityMetric (N)       -- RAG-specific quality scores
```

#### 14.2 Key DMO Fields for SA-Level Queries

**AiAgentSession:**
- `StartTimestamp` / `EndTimestamp` — session duration
- `AiAgentChannelType` — channel (messaging, voice, web)
- `AiAgentSessionEndType` — `USER_ENDED`, `AGENT_ENDED`, or null
- `VariableText` — final variable snapshot for the session (useful for debugging workflow state)

**AiAgentInteraction:**
- `TopicApiName` — the subagent that handled this turn (maps to Agent Script subagent API names)
- `StartTimestamp` / `EndTimestamp` — turn duration
- `TelemetryTraceId` — distributed tracing ID for correlating with LLM gateway logs

**AiAgentInteractionStep:**
- `StepType` — `LLM_STEP`, `ACTION_STEP`, `TRUST_GUARDRAILS_STEP`
- `EndTimestamp` — frequently `NOT_SET` for in-progress or interrupted steps (see Known Issues)
- Two important data quality notes: the platform uses `"NOT_SET"` (string) as a sentinel for null values, and the `TRUST_GUARDRAILS_STEP` error field may contain the Python string `"None"` — which is not a real error. Filter accordingly.

#### 14.3 RAG Quality Metrics — The AiRetrieverQualityMetric DMO

This DMO provides per-retrieval quality scores for agents using RAG. It is separate from the general quality score chain and is only populated when the agent uses knowledge retrieval actions.

**Key fields:**

| Field | What it measures | What it tells you |
|---|---|---|
| `FaithfulnessRelevancyScoreNumber` (0-1) | How grounded is the response in the retrieved context? | Low score: LLM is supplementing from general knowledge despite the guard |
| `AnswerRelevancyScoreNumber` (0-1) | How relevant is the response to the user's question? | Low score: response is accurate but not helpful — misaligned scope |
| `ContextPrecisionScoreNumber` (0-1) | How relevant is the retrieved content to the query? | Low score: retrieval is missing; corpus design or enrichment issue |

**Using these three metrics together:**

| Pattern | What it indicates |
|---|---|
| Low Context Precision, High Faithfulness | Retrieval is poor but LLM is faithfully using what it got. Fix: corpus or chunking. |
| High Context Precision, Low Faithfulness | Good retrieval but LLM is ignoring the context. Fix: tighten the anti-hallucination guard. |
| High Context Precision, High Faithfulness, Low Answer Relevance | Agent is answering a different question than the user asked. Fix: query understanding or topic routing. |
| All three high | RAG pipeline is working. Focus optimization elsewhere. |

> **Note:** `AiRetrieverQualityMetric` rows only exist for sessions where a retrieval action was called. An agent that is routing to the wrong subagent and never calling `AnswerQuestionsWithKnowledge` will show 0 rows in this DMO — which is itself a diagnostic signal.

#### 14.4 Observability Data Refresh Cadences

Not all observability data appears immediately. These cadences matter for SAs setting client expectations about dashboards and reporting:

| Data type | Typical refresh | Notes |
|---|---|---|
| Session data (`AiAgentSession`) | Near real-time | Usually available within minutes of session end |
| Step data (`AiAgentInteractionStep`) | Near real-time | Same as session data |
| Quality scores (tag associations) | LLM-evaluated async | May lag session end by minutes to hours depending on evaluation queue |
| RAG quality metrics (`AiRetrieverQualityMetric`) | Async, post-session | Roadmap: real-time dashboard planned |
| Audit Trail | Near real-time | Available in Data Cloud for compliance queries |

#### 14.5 The Quality Score Join Chain

Quality scores flow through a join chain that is not obvious from the DMO names alone:

```
AiAgentMoment
    --> AiAgentTagAssociation (FK: AiAgentMomentId + FK: AiAgentTagId)
        --> AiAgentTag.Value (integer 1-5)
            --> AiAgentTagDefinition (tag type and engine)
```

The `AssociationReasonText` field in `AiAgentTagAssociation` contains the LLM-generated reasoning for the score — useful for understanding why a specific interaction received a low quality score.

---

### Chapter 15: When to Involve a Developer — Pro-Code RAG

#### 15.1 The Handoff Decision

The ADL and no-code retriever configuration covers the majority of production RAG use cases. But there are specific requirements that genuinely require developer involvement. Knowing the handoff triggers protects delivery timelines — a team that discovers a pro-code requirement at go-live is in a difficult position.

#### 15.2 Pro-Code Trigger: Apex Connect API for Advanced Retrieval

When retrieval requirements exceed what no-code retriever pre-filters can express, Apex classes can call the Data Cloud Connect API directly. This enables:

- **Full SQL query expressions** against the search index, including `WHERE` clauses, `JOIN` conditions, and `ORDER BY` on non-similarity fields
- **Post-retrieval filters** — apply filters after the similarity search has returned results, using related fields that were not included in the search index
- **Nested pre-filter conditions** that combine multiple attributes with complex boolean logic not expressible in the declarative filter UI
- **Procedural access control logic** — dynamically determine which content a user is entitled to retrieve based on runtime conditions that cannot be expressed as static or dynamic pre-filters

The Apex class wraps the Connect API call, processes the results, and returns them to the agent action as a structured payload. **This is the trigger to escalate to a developer:** when the client's access control or retrieval scoping requirements cannot be fully expressed in the retriever's pre-filter configuration.

#### 15.3 Pro-Code Trigger: Non-RAG Search Index Use Cases

Search indexes can be used for purposes other than traditional RAG. SAs may encounter these in client conversations and should be able to recognize them as legitimate use cases — even if they require developer involvement to implement.

**Use case 1: Similarity search without LLM generation**

A search index can surface similar records to a human user without sending results to an LLM at all. Example: when a service rep creates a new case, a Flow-triggered retriever searches the resolved-cases index for the 10 most similar past cases and surfaces them in the UI. No agent, no LLM call, no generative output — just semantic similarity serving a human workflow.

**Use case 2: Text classification using vector search**

A search index built from previously classified examples can classify new text by majority vote. The classification query retrieves the 50 or 100 most semantically similar examples, reads their class labels, and assigns the most frequently occurring label to the new text. This approach works for intent detection, topic annotation, and case routing — without any LLM prompt or fine-tuned classifier. It is a legitimate production pattern for clients who want semantic classification without generative AI cost or latency.

Both of these use cases require Apex or Flow-based retriever invocation rather than the Agentforce agent action. Flag them as developer-required during discovery.

#### 15.4 Pro-Code Trigger: MuleSoft for External System Content

When content lives in an external system with data residency restrictions that prevent uploading to Salesforce or Data Cloud, the recommended pattern is a MuleSoft-orchestrated custom retriever. MuleSoft handles the extraction, transformation, and secure forwarding of content from the external system. The custom retriever then exposes that content as an ADL `RETRIEVER` source type.

This pattern keeps the physical data in its original jurisdiction while still making it available for agent grounding — satisfying both the residency requirement and the grounding requirement.

---

### Chapter 16: The Credit Model — What RAG Actually Costs

#### 16.1 Two Billing Models

As of Summer '26, Agentforce offers two pricing models. Most new deployments use Flex Credits.

**Flex Credits:** Action-based billing. Every agent action execution consumes credits, whether deterministic or LLM-selected. The credit multiplier is 20 per action (production). Sandbox actions consume at 80% of the production rate (16 credits). Utilities — escalations, variable assignments, subagent transitions — are not billed as actions.

**Conversations:** Outcome-based billing for the Help Agent. A session is billed as a resolved conversation when: the session has at least two turns, the final user feedback is not explicitly negative, and the session ends without escalation to a human (or ends with explicitly positive feedback). Actions and Data 360 queries within a resolved session are not billed separately. Unresolved sessions are not billed.

#### 16.2 Flex Credits Rate Table

**100,000 Flex Credits = $500 ($0.005 per credit). Each standard action costs 20 credits = $0.10 per action.**

This table covers the usage types most relevant to RAG-grounded agent deployments:

| Usage Type | Billing Unit | Credits (Production) | Credits (Sandbox) | Cost per Unit (Production) |
|---|---|---|---|---|
| Standard Action (text) | Per action execution | 20 | 16 | $0.10 |
| Custom Action (text) | Per action execution | 20 | 16 | $0.10 |
| Help Agent Resolution | Per resolved session | 400 | 0 | $2.00 |
| Data 360 Unstructured Processing (basic) | Per MB chunked | 150 | 120 | $0.75/MB |
| Data 360 Unstructured Processing (enhanced) | Per MB chunked | 600 | 480 | $3.00/MB |
| Data 360 Queries | Per 1M rows processed | 3 | 2.4 | $0.000015/row |

**Token threshold:** Each action has a 10,000-token budget. Actions exceeding this threshold consume additional credits. 10,000 tokens is approximately 8,000 words — a very high threshold that most actions will never approach.

**Important billing rule:** Flex Credits eliminate the need for separate Einstein Requests when actions are executed through an agent. However, features that invoke prompt templates directly via Flow, Apex, or LWC (outside of an agent) still consume Einstein Requests.

#### 16.3 RAG-Specific Cost Drivers

For RAG deployments specifically, the cost drivers to monitor and manage:

**The `AnswerQuestionsWithKnowledge` action:** Every call to this action, whether it returns results or not, consumes one standard action credit ($0.10). Action loops on this action are therefore both a correctness bug and a billing issue.

**Corpus processing on index creation:** When an ADL is created or content fields are updated, the platform processes all content through the chunking and embedding pipeline. For SFDRIVE libraries:
- `basic` mode: 150 credits per MB = **$0.75 per MB**
- `enhanced` mode: 600 credits per MB = **$3.00 per MB** (4x)

For a 1,000-file corpus averaging 2 MB per file (2,000 MB total):
- `basic` mode total: 300,000 credits = **$1,500**
- `enhanced` mode total: 1,200,000 credits = **$6,000**

This is a one-time cost but it is material and should be quantified before recommending enhanced mode at scale.

**Web search fallback cost:** When a retrieval miss triggers the web search fallback, the session incurs $0.10 for the empty `AnswerQuestionsWithKnowledge` call plus $0.10 for the General Web Search call. At high volume, this doubles retrieval cost for every missed query. Improving corpus quality is always more cost-effective than relying on the fallback at scale.

#### 16.4 Buying Models

Three purchasing models are available:

| Model | Description | Best for |
|---|---|---|
| Pre-Purchase | Buy a set amount upfront for the contract term. Pay upfront, draw down from balance. Maximum savings. | Clients with predictable, high-volume usage |
| Pre-Commit | Commit to a baseline, pay monthly in arrears. True-up at term end if below commitment. | Clients scaling up over time |
| PayGo | No upfront commitment. Pay only for what you use. Monthly billing. | Pilots, new deployments, unpredictable volumes |

Agentforce 1 Edition customers receive 2.5M Flex Credits per org per year included. Agentforce add-on licenses ($125/user/month for Sales/Service, $150/user/month for Industries) include unmetered usage for licensed employees.

#### 16.5 Estimating RAG Costs for a Client

A straightforward cost model for a customer-facing RAG agent:

```
Monthly action cost =
    daily_sessions
    x avg_actions_per_session
    x $0.10 per action
    x 30 days
```

Example: 20 daily "Where Is My Order" sessions, 2 actions per session:
- 20 sessions x 2 actions x $0.10 x 30 days = **$120/month**

Add corpus indexing costs separately. For a 500-file product documentation library averaging 1 MB per file in `basic` mode:
- 500 MB x $0.75/MB = **$375 one-time indexing cost**

Always present these two line items separately to clients — they appear on different parts of the invoice and are governed by different consumption meters.

---

## Part 7: Troubleshooting and Client Conversations

---

### Chapter 17: Troubleshooting — The Diagnostic Ladder

This chapter provides a structured troubleshooting sequence for the most common production issues. Work through the ladder from top to bottom. Each rung rules out one failure class.

#### 17.1 The RAG Diagnostic Ladder

When a grounded agent fails to produce grounded answers, this is the sequence:

**Rung 1: Is the agent topic and agent action being called?**

Check the session trace in Data Cloud (`AiAgentInteractionStep`) and confirm that `AnswerQuestionsWithKnowledge` is appearing as an `ACTION_STEP`. If it is not appearing, the agent is routing to the wrong subagent or the action is being filtered out by an `available when` condition that evaluated to false.

**Rung 2: Is the right retriever being passed to the action?**

In Einstein Studio, confirm that the prompt template associated with the `AnswerQuestionsWithKnowledge` action is wired to the correct retriever — the one provisioned by the ADL, not a manually created one that may be misconfigured. A correct retriever assignment is the most common fix at this rung.

**Rung 3: Does the search index contain vectors?**

In the Data Cloud Query Editor, run a count query against the chunk DMO of the search index. Compare the count of indexed chunks against the count of source records (Knowledge articles or files). A mismatch indicates incomplete indexing — either the Day 0 race condition (Chapter 18) or a stalled incremental index job.

```sql
SELECT 'INDEX' AS Location,
       COUNT(DISTINCT SourceRecordId__c) AS RecordCount
FROM <chunk_DMO_of_search_index>
UNION
SELECT 'SOURCE' AS Location,
       COUNT(DISTINCT Id__c) AS RecordCount
FROM <source_DMO>
ORDER BY Location;
```

**Rung 4: Is the retriever augmenting the prompt with content?**

In Prompt Builder, use resolution-only mode (no LLM call) to inspect whether the prompt template is being populated with retrieved chunks. If the resolution shows an empty retriever output, the retrieval query itself is returning 0 results — which points to a permission issue (Chapters 13 or 18) or a language alignment mismatch (Chapter 8.2).

**Rung 5: Is the anti-hallucination guard syntactically correct?**

If the retriever is returning content but the agent is still hallucinating, the guard is broken. Check that the variable name in the guard exactly matches the variable name used to store the retrieval result. A case mismatch or typo causes the empty-check to never fire.

#### 17.2 Retrieval Quality Rungs — When the Agent Answers But Answers Wrongly

Once basic retrieval is confirmed working, quality problems require a different diagnostic approach.

**Check the AiRetrieverQualityMetric DMO first.** The three scores (Context Precision, Faithfulness, Answer Relevance) tell you which layer of the RAG pipeline has the quality problem. Use the pattern table in Chapter 14.3 to identify the root cause before making changes.

**Retrieval confidence and the fallback threshold:**

Each retrieved chunk has a similarity score. When the highest-scoring chunk's similarity is below a meaningful threshold, the retrieval result is technically non-empty but semantically irrelevant — and passing it to the LLM produces confidently wrong answers. Configuring a minimum similarity threshold below which the agent falls back to a clarifying question or escalation is an advanced but important production configuration. Discuss this with the delivery team when a client reports that the agent gives answers that sound authoritative but are subtly wrong.

**Content freshness and temporal accuracy:**

For time-sensitive content (pricing, regulations, policy terms that change quarterly), a freshness check on the retrieved chunk's source record update date can qualify agent responses. Example: if the most recently updated article relevant to a query was last updated 8 months ago, the agent can include a disclaimer: "This information is based on content last updated in [date]. Please verify with our team for the latest terms." This is a pro-code configuration implemented in the retrieval Apex action, but SAs should raise it as a design consideration when the corpus contains time-sensitive content.

#### 17.3 Routing Failure Diagnosis

When the agent routes to the wrong subagent:

1. Check the subagent description. It is the primary signal the Router uses for classification.
2. Check for overlapping descriptions across subagents. Ambiguous descriptions produce inconsistent routing.
3. Check whether the EinsteinHyperClassifier is being used. It is faster but has tool limitations and may produce different routing decisions than the standard reasoning engine for edge cases.

---

### Chapter 18: Known Platform Issues

These are documented, named platform behaviors — not bugs you should spend hours diagnosing from scratch. Know them before go-live.

#### Issue 1: KNOWLEDGE Day 0 Race Condition

**What happens:** KNOWLEDGE ADL shows READY with a non-null `retrieverId` but contains 0 indexed chunks. The chunking job ran before the CRM Connector's data commit propagated.

**Detection:** Live test query returns empty `knowledgeSummary`.

**Resolution:** Wait 10 minutes after `retrieverId` appears, then test. If still empty, force re-index via ADL CLI (`sf agent adl update --content-fields`).

#### Issue 2: `is_displayable: True` Skips `after_reasoning`

**What happens:** When an action has `is_displayable: True`, the platform exits the reasoning loop as soon as the action output is displayed. `after_reasoning` silently does not execute.

**Detection:** Orchestration logic in `after_reasoning` that should fire doesn't. No error. No log entry for the skipped block.

**Resolution:** Move must-execute orchestration logic to the `before_reasoning` block of the destination subagent.

#### Issue 3: Language Alignment Silent Failure

**What happens:** Agent user's language setting does not match indexed Knowledge article language. Retriever returns 0 results silently.

**Detection:** All questions get "I don't have that information" responses. SOQL on `Knowledge__kav` shows articles in a different locale than the agent user's profile.

**Resolution:** Align agent user locale with Knowledge article language, or use the Multilingual E5-Large embedding model which supports cross-language retrieval.

#### Issue 4: `NOT_SET` Sentinel in Observability Queries

**What happens:** Data Cloud uses the string `"NOT_SET"` for absent values in the STDM schema — not SQL `NULL`. Queries filtering for `IS NULL` miss these records entirely.

**Detection:** Observability queries return unexpectedly low row counts.

**Resolution:** Filter for `field != 'NOT_SET'` or use `COALESCE(field, 'NOT_SET')` patterns. Document this behavior for any internal or client-facing dashboards built on this schema.

#### Issue 5: `AiAgentInteractionStep.EndTimestamp` Frequently Missing

**What happens:** `EndTimestamp` on interaction steps is `NOT_SET` for many step records, including completed ones. Duration calculations using this field produce incorrect results.

**Resolution:** Calculate duration from `AiAgentInteraction` timestamps rather than step-level timestamps. Step-level duration analysis is unreliable without additional filtering.

#### Issue 6: `TRUST_GUARDRAILS_STEP` Python `"None"` Error Field

**What happens:** The error field on `TRUST_GUARDRAILS_STEP` records contains the Python string literal `"None"` — not a SQL null, and not a real error. Queries counting errors that include this field will overcount.

**Detection:** Error counts seem high, but no corresponding user-visible errors occurred.

**Resolution:** Filter `TRUST_GUARDRAILS_STEP` out of error counts. This step type is excluded from the `action_error_count` metric for this reason.

---

### Chapter 19: Client Conversation Frameworks

#### 19.1 The "Is My Data Safe?" Conversation

**Client concern:** A security officer or CTO asks whether Salesforce uses their customer data to train AI models.

**SA response framework:**

"The answer is contractually no. Salesforce has Zero Data Retention agreements in place with every LLM provider — OpenAI, Anthropic, Google — which prohibit them from retaining any prompt data or using it for training. These are legal commitments, not just technical settings.

Beyond ZDR, everything that leaves Salesforce passes through the Einstein Trust Layer — which masks sensitive fields like PII before the prompt reaches the model, and scans every response for toxicity before it reaches your users. Your data never trains anyone's model, and personally identifiable information never reaches the LLM in its original form.

For your compliance team: all of this is auditable. Every prompt, every response, every trust signal applied is captured in the Audit Trail in Data Cloud. You have a complete record of what the agent said and why."

#### 19.2 The "Why Is the Agent Making Things Up?" Conversation

**Client concern:** After go-live, the client reports that the agent is giving confident but incorrect answers.

**SA response framework:**

"This is a solvable problem and it has a predictable set of root causes. Let me walk through the diagnostic.

First question: is the retrieval working at all? [Pull the session trace.] If the `AnswerQuestionsWithKnowledge` action isn't appearing in the step data, the agent isn't even trying to retrieve — it's routing to the wrong place or the retrieval action is being filtered out.

If retrieval is happening but answers are still wrong, the second question is whether the anti-hallucination guard is syntactically correct. If the empty-check variable name doesn't match the variable holding the retrieval result, the guard never fires and the LLM uses its general knowledge.

If retrieval is happening and the guard is correct, the third question is whether the corpus contains the right content. What did the agent say? What should it have said? Does the correct answer exist somewhere in the knowledge base? If it doesn't, the agent will fall back to general knowledge or the guard, and the fix is corpus enrichment — not configuration.

We have three quality metrics in Data Cloud — Context Precision, Faithfulness, and Answer Relevance — that will tell us exactly which layer of the pipeline has the problem."

#### 19.3 The "What Does This Cost?" Conversation

**Client concern:** CFO or procurement asks for a cost estimate before approving production rollout.

**SA response framework:**

"Agentforce RAG costs have two main components. Let me give you the model.

The first component is agent actions: every time the agent retrieves from the knowledge base or performs another action, that consumes Flex Credits. Each standard action costs 20 credits, and 100,000 credits cost $500 — so each action costs $0.10. If your agent handles 500 conversations a day and each conversation involves 2 actions on average, that is 20 sessions per day times 2 actions times $0.10 times 30 days — $120 per month.

The second component is indexing: when we first build the knowledge corpus, there is a processing cost for chunking and vectorizing the content. For standard documents, this is $0.75 per megabyte. For complex documents with tables and images, it is $3.00 per megabyte. For a 500-file library averaging 1 MB per file in standard mode, that is a $375 one-time cost.

These two line items appear separately on the invoice — action credits and Data Cloud processing credits are billed on different meters. I can give you a precise estimate if you share your expected daily session volume, average session depth, and approximate corpus size."

#### 19.4 The "Can It Know About Our Products?" Conversation

**Client concern:** A business sponsor in the discovery phase asks whether the agent can answer questions about their specific product catalog, pricing, and policies.

**SA response framework:**

"Yes — this is exactly what Retrieval-Augmented Generation is designed to solve.

LLMs are trained on general knowledge up to a cutoff date. They know nothing about your products, your policies, or your processes. Without grounding, an agent answering a product question is guessing — and a confident, wrong guess in a customer conversation is worse than 'I don't know.'

RAG solves this by building a searchable index from your own content — your Knowledge articles, your documentation, your policy PDFs. When a customer asks a product question, the agent searches that index, retrieves the relevant passages, and answers from your content specifically. The agent cites the source, so customers — and your compliance team — can verify exactly where the answer came from.

The agent stays current because the index is built from your live Knowledge base. When you update a policy, the agent automatically reflects the update at the next indexing cycle. You are not maintaining two things — you maintain your Knowledge base and the agent follows."

---

## Part 8: Architecture Patterns

---

### Chapter 20: Six Production Architecture Patterns

These six patterns cover the most common production Agentforce + RAG configurations. Each pattern includes when to use it, how it works, and the key architectural decisions involved.

#### Pattern 1: Single ADL, Single Subagent

**When to use:** Single domain. Homogeneous corpus. Straightforward retrieval. The simplest production configuration.

**Architecture:**

```
User
  |
  v
Agent (single subagent)
  |
  v
AnswerQuestionsWithKnowledge
  |
  v
ADL (KNOWLEDGE or SFDRIVE)
  |
  v
Search Index --> Retriever --> Prompt Template --> LLM
```

**Key decisions:**
- KNOWLEDGE vs. SFDRIVE source type (based on where content lives)
- `basic` vs. `enhanced` index mode (based on document complexity)
- Chunk enrichment type (based on how users phrase queries vs. how content is written)
- Anti-hallucination guard configuration

**SA guidance:** This is the right starting point for most clients. Do not add complexity until the single-subagent configuration is working reliably.

---

#### Pattern 2: Multi-Subagent, Domain-Gated RAG

**When to use:** Multiple conversation domains. Each domain has a distinct knowledge corpus. Users should not be able to access content from the wrong domain.

**Architecture:**

```
User
  |
  v
Start Agent (Router)
  |
  +-- [billing question]  --> Billing Subagent  --> Billing ADL
  |
  +-- [product question]  --> Product Subagent  --> Product ADL
  |
  +-- [returns question]  --> Returns Subagent  --> Returns ADL
```

**Key decisions:**
- Subagent descriptions must be precise and non-overlapping
- Each subagent has its own `knowledge:` block pointing to its specific ADL
- Consider using `available when` guards to prevent cross-domain retrieval

---

#### Pattern 3: Dynamic Pre-Filter RAG (Single Corpus, Multi-Segment)

**When to use:** One corpus, multiple user segments with different content entitlements. Financial services, healthcare, multi-tier subscription products.

**Architecture:**

```
User (with segment attribute captured at session start)
  |
  v
Identity Subagent
    [captures: @variables.customerSegment]
  |
  v
Knowledge Subagent
  |
  v
AnswerQuestionsWithKnowledge
    [dynamic pre-filter: Segment__c = @variables.customerSegment]
  |
  v
Single ADL (full corpus)
    --> Retriever returns only segment-eligible chunks
```

**Key decisions:**
- Segment attribute must be captured deterministically before retrieval (not LLM-inferred)
- Dynamic pre-filter field must be indexed in the search index
- The anti-hallucination guard is especially critical here: an empty result means the content exists but is not accessible to this segment — not that it doesn't exist

---

#### Pattern 4: Knowledge-First with Web Search Fallback

**When to use:** The agent covers a mix of proprietary content (policies, processes) and public general information (industry FAQs, regulatory definitions). Compliance-approved for web access.

**Architecture:**

```
User question
  |
  v
AnswerQuestionsWithKnowledge (primary)
  |
  +-- [knowledgeSummary non-empty] --> Answer with citation
  |
  +-- [knowledgeSummary empty]
        |
        v
      General Web Search (fallback)
        |
        v
      Answer labeled "from public sources"
```

**Key decisions:**
- Responses from each source must be clearly labeled with their origin
- Proprietary and web content must never be blended without explicit attribution
- Monitor miss rates: high fallback frequency signals corpus gaps, not a successful fallback pattern

---

#### Pattern 5: Multi-Agent Orchestration (SOMA)

**When to use:** Complex enterprise deployments where different specialized agents handle different functional domains, and a Supervisor agent coordinates across them.

**Architecture:**

```
Supervisor Agent
  |
  +-- Plan Agent    (project planning, timeline)
  |
  +-- Service Agent (customer inquiries, cases)
  |
  +-- Sales Agent   (opportunity management, proposals)
```

**Two routing mechanisms:**

| Mechanism | How it works | Use when |
|---|---|---|
| LLM Reasoning Engine routing | Supervisor LLM selects subagent based on descriptions | Complex, contextual routing where the choice depends on nuanced conversation content |
| EinsteinHyperClassifier routing | Deterministic classifier routes based on trained patterns | High-volume, well-defined routing categories where latency matters; note tool limitations |

**Key decisions:**
- Subagent (specialist agent) descriptions are the routing signal — invest heavily in them
- Trust boundary configuration: agents sharing the same org can communicate natively; cross-org agent communication requires trust boundary configuration
- Each specialist agent maintains its own ADL and retrieval context

**Connected agent syntax note:** Multi-agent designs use `connected_agent` blocks in Agent Script, distinct from standard subagents. The routing description can be overridden at the tool invocation site in the calling agent's reasoning instructions — useful when the same specialist agent plays different roles in different calling contexts.

---

#### Pattern 6: Jargon Grounding Pattern

**When to use:** The client's user base uses terminology, product nicknames, or abbreviations that differ from the indexed content's vocabulary. This creates a semantic gap between how users ask questions and how documents are written — a gap that QUESTION enrichment alone cannot fully close when the terms are not known at index time.

**Architecture:**

```
User question (contains jargon)
  |
  v
Terminology Subagent
  |
  v
FetchTerminologyMap action (runs once per session)
    [retrieves: old term -> canonical term mapping from KAV]
  |
  v
Translation step (LLM translates user jargon -> canonical terms)
  |
  v
Canonical question
  |
  v
AnswerQuestionsWithKnowledge (retrieves against canonical terms)
  |
  v
Answer
```

**Why this pattern matters:** Reindexing a large corpus every time a product is renamed or a new abbreviation enters circulation is expensive and slow. Maintaining a lightweight terminology map in Salesforce Knowledge — one article, one table, business-user-editable — enables terminology updates to propagate to the agent within the Knowledge indexing cycle (minutes) with no re-indexing of the main corpus.

**Key decisions:**
- The terminology map fetch must run once per session and be guarded against loop-on-parse
- The translation step should not alter the user's question for domains outside the terminology map
- Business users, not IT, should own and maintain the terminology map

---

## Appendix

---

### A1: The Four Silent Failure Checklist

Use before every go-live. Each item on this list produces the same visible symptom — the agent says "I don't have that information" — but a different root cause.

- [ ] **Data Cloud permission set** assigned to the Einstein Agent User
- [ ] **Data space access** granted to the Einstein Agent User for the correct data space
- [ ] **Search index permission** granted to the Einstein Agent User or their role
- [ ] **Knowledge article visibility** confirmed: agent user profile can see the relevant article types and data categories
- [ ] **Language alignment** confirmed: agent user locale matches Knowledge article language
- [ ] **`retrieverId` verified non-null** and live test query returns non-empty `knowledgeSummary` (for KNOWLEDGE ADLs)
- [ ] **KNOWLEDGE Day 0 wait** completed: 10 minutes elapsed after `retrieverId` appeared before declaring success
- [ ] **`ARFPC_` prefix** present in `rag_feature_config_id`
- [ ] **Anti-hallucination guard** variable name verified to match retrieval result variable name
- [ ] **`after_reasoning` dependencies** not present on subagents with `is_displayable: True` actions

---

### A2: RAG Anti-Hallucination Guard Template

Copy this template. Substitute the variable names and support channel with client-specific values.

```
before_reasoning:
    if @variables.knowledgeResult == "":
        run @actions.AnswerQuestionsWithKnowledge
            with query = @system_variables.user_input
        set @variables.knowledgeResult =
            @actions.AnswerQuestionsWithKnowledge.knowledgeSummary

reasoning:
    | Use only the content in @variables.knowledgeResult to answer
      the user's question.
    | Do not supplement the answer with information from general
      knowledge, even if you believe the answer is correct.
    | If @variables.knowledgeResult is empty or does not contain
      information relevant to the user's question, respond with:
      "I wasn't able to find that information in our knowledge base.
       For help with this, please contact [support channel]."
    | Always cite the source of your answer using the citation
      metadata provided in the knowledgeSummary.
```

---

### A3: The Scoping Decision Tree

Use this in every discovery conversation before recommending an architecture.

```
Does the client need the agent to answer questions about
their specific products, policies, or processes?
|
+-- No  --> No RAG needed. Use agent topics and CRM actions.
|
+-- Yes --> Where does the authoritative content live?
    |
    +-- Salesforce Knowledge articles
    |    --> ADL: KNOWLEDGE source type
    |
    +-- Files (PDF, HTML, TXT) in Salesforce or external storage
    |    --> ADL: SFDRIVE source type
    |         (external storage: S3, GCS, Azure Blob supported)
    |
    +-- Existing active Custom Retriever
    |    --> ADL: RETRIEVER source type
    |
    +-- Public website only (no proprietary content)
    |    --> General Web Search action
    |         (requires compliance approval for regulated industries)
    |
    +-- External system with data residency restrictions
    |    --> MuleSoft + Custom Retriever (escalate to developer)
    |
    +-- Long-text fields on non-KAV Salesforce objects
    |    --> Manual configuration (escalate to developer)
    |
    +-- Multiple sources from different systems
         --> How many distinct sources?
              |
              +-- Two (files + KAV)
              |    --> Single ADL with ensemble retriever (built-in)
              |
              +-- More than two
                   --> Manual configuration + Ensemble Retriever
                        (escalate to developer)
```

---

### A4: Content Authoring Best Practices Checklist

Use this in the corpus design conversation with the client's Knowledge Manager or Content Team. Complete before any production indexing begins.

**Article Structure**
- [ ] Articles use heading tags (H1-H6) for all major and minor sections
- [ ] Each article covers one coherent topic — not a catch-all dump
- [ ] Articles are a minimum of 300-400 words; very short articles are consolidated or expanded
- [ ] Sentences are logically related and paragraphs cohere within a topic

**Content Depth**
- [ ] Articles include detailed explanations, not just summaries or pointers
- [ ] Real-world examples are included for each major scenario
- [ ] Examples are written conversationally, as a user would describe the situation
- [ ] Common synonyms and abbreviations for key terms are explained within the article text

**Structured Content (Knowledge Articles)**
- [ ] Long-text content is spread across multiple fields (Question, Description, Resolution, Exceptions)
- [ ] Metadata fields are populated for filtering (category, product line, audience)
- [ ] Identifying fields are chosen that will be useful as prepend fields (Title, Product Name)

**Complex Formats (Files)**
- [ ] Documents with tables have been reviewed; complex tables converted to JSON or HTML where possible
- [ ] Long tables have been split into logical sub-tables with clear headings
- [ ] Files requiring enhanced (Intelligent Context) mode have been identified and tagged

**Scope and Governance**
- [ ] Corpus scope is defined and aligned with the agent's conversation scope
- [ ] Out-of-scope content is excluded or tagged for exclusion via data categories
- [ ] Outdated articles have been retired or flagged for retirement
- [ ] Knowledge audit cadence is established (quarterly minimum)
- [ ] Content owner is identified for ongoing governance

---

### A5: Multi-Source Architecture Decision Guide

Use this when a client needs answers from more than one knowledge domain.

**Step 1: How many distinct data sources are needed?**

Count the distinct data source types. Remember: one search index per source. Four sources requires four search indexes.

**Step 2: Are the sources complementary or independent?**

- If a complete answer to a typical question requires content from more than one source, the sources are **complementary** — use Approach 1 (one prompt template, multiple retrievers / ensemble).
- If questions can be reliably classified as belonging to one source or another, the sources are **independent** — use Approach 2 (separate prompt template per source, agent selects the right action).

**Step 3: Is everything within ADL's supported scope?**

ADL today supports: Salesforce Knowledge articles (KNOWLEDGE), files from Salesforce-managed storage or external cloud storage (SFDRIVE), and existing active custom retrievers (RETRIEVER).

If any required source is outside this scope — external databases, non-KAV Salesforce objects with long-text fields, systems with residency restrictions — manual configuration and developer involvement are required.

**Step 4: Use the decision matrix**

| Sources | All ADL-compatible? | Approach |
|---|---|---|
| 1 source | Yes | Single ADL, Pattern 1 |
| 2 sources (files + KAV) | Yes | Single ADL with built-in ensemble retriever |
| 2+ sources, ADL-compatible | Yes | Multiple ADLs, Approach 1 or 2 |
| Any source outside ADL scope | No | Manual configuration (developer required) |
| 4+ heterogeneous sources | Partially | Manual configuration + Ensemble Retriever |

---

### A6: Terminology Reference

| Term | Definition |
|---|---|
| **ADL** | Agentforce Data Library. The no-code/low-code provisioning path for RAG in Agentforce. Creates and manages the full pipeline: DLO, DMO, Search Index, Retriever, Prompt Template, and Agent Action. |
| **Atlas** | The public name for the Agentforce Reasoning Engine. Executes agent logic, manages conversation state, calls actions, and coordinates LLM reasoning. Use this name with clients. |
| **Chunk** | A text fragment produced by splitting a larger document for embedding and indexing. The unit of retrieval in a RAG pipeline. |
| **CRM Connector** | The Salesforce-managed integration that reads Knowledge articles from the `Knowledge__kav` object and makes them available to Data Cloud for indexing. |
| **DMO** | Data Model Object. The structured representation of a data entity within Data Cloud. The search index is built on top of a DMO. |
| **DLO** | Data Lake Object. Raw data storage layer in Data Cloud, upstream of the DMO. |
| **Dynamic Pre-Filter** | A retriever filter whose value is resolved at runtime from conversation context, enabling per-user or per-session scoping of retrieval results. |
| **Embedding model** | The model that converts text into numerical vectors. Must be the same at indexing and query time. Changing after index creation requires full re-indexing. |
| **Ensemble Retriever** | A retriever that combines results from multiple individual retrievers, reranking across sources using a cross-encoder model. |
| **EinsteinHyperClassifier** | A faster, deterministic classifier option for subagent routing. Offers lower latency but has tool limitations compared to the standard LLM reasoning engine. |
| **Flex Credits** | Salesforce's action-based pricing model for Agentforce. 100,000 credits = $500. Each standard action execution costs 20 credits = $0.10 per action. |
| **knowledgeSummary** | The output payload from `AnswerQuestionsWithKnowledge`. Contains the retrieved chunks as a formatted string for injection into the prompt. |
| **Parse** | The atomic unit of Agent Script execution. One complete cycle through `before_reasoning`, `reasoning`, and `after_reasoning`. Fires on first subagent entry, after every action, and on every new user turn. |
| **Pre-filter** | A filter applied before the similarity search runs, narrowing the candidate pool. More efficient than post-filtering because ineligible records are excluded before vector comparison. |
| **RAG** | Retrieval-Augmented Generation. The pattern of retrieving relevant content from a managed corpus at query time and injecting it into the prompt as grounding context. |
| **SFDRIVE** | The ADL source type for file-based libraries. Supports PDF, TXT, and HTML files from Salesforce-managed storage or external platforms (S3, GCS, Azure Blob). |
| **Unified Planner** | The engineering product name for the Atlas Reasoning Engine. Use "Atlas" with clients; use "Unified Planner" when discussing engineering architecture. |
| **ZDR** | Zero Data Retention. The contractual agreements between Salesforce and LLM providers prohibiting retention of prompt data or its use for model training. |
| **Zero Copy** | A Data Cloud architecture principle where physical data files are not duplicated into Data Cloud. Only extracted text and metadata reside on Data Cloud; the source file stays in its original location. |
