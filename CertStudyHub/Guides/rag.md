# RAG, Agentforce & Data Cloud
## A Success Architect Guide — Version 3.2

*Updated August 20, 2026*
*This guide was generated using AI with grounding in official Salesforce documentation. Review for accuracy before using.*

---

> **How to use this guide:** Read it in order the first time. Each section builds on the last. The arc runs from "how Agentforce thinks" through "how to set up and govern a grounded agent in production." Real-world scenarios are embedded throughout to anchor abstract concepts to client conversations you will actually face.
>
> **Scope note:** This guide is written for Success Architects. It covers what you need to understand, recommend, and troubleshoot — not how to implement at a developer level. Pro-code patterns (Apex, Connect API, MuleSoft) are noted where they exist so you can have informed conversations, but implementation detail is left to the delivery team.
>
> **Terminology note:** The Agentforce reasoning engine has two names depending on context. "Atlas" is the public-facing name for the runtime engine — the term you use with clients and in documentation. "Unified Planner" is the engineering product name used in the Salesforce Engineering blog and internal architecture discussions. Both refer to the same system. This guide uses "Atlas" when discussing the runtime and "Unified Planner" when discussing the engineering architecture.

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
- [Chapter 12: Data 360 — The Intelligence Infrastructure](#chapter-12-data-360)
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

> **Important:** Salesforce's "Salesforce Default" model is a managed mix rather than a fixed single model. The current mix includes GPT-4o alongside other models. Salesforce may update the composition of this managed mix across releases without a versioned change. The table below reflects the current documented defaults, but verify against the latest release notes before quoting specific models to clients, and note that the exact model served can change.

| Builder | Documented Default Reasoning Model |
|---|---|
| Legacy Agentforce Builder | Salesforce Default (currently includes GPT-4o) |
| New Agentforce Builder | Salesforce Default; recommended configurations use GPT-4.1 or Anthropic Claude Haiku 4.5 |

Salesforce documentation recommends GPT-4.1, Claude Haiku 4.5, and Gemini 3.5 Flash as the three models most thoroughly tested with Agentforce agents. Neither GPT-4.1 nor Claude Haiku 4.5 is positioned as categorically superior — they optimize for different dimensions, and the right choice depends on your client's specific requirements.

**The trust boundary distinction is the key differentiator for SA conversations:**

- **Claude Haiku 4.5** runs within the **Salesforce trust boundary** — AWS Bedrock, using Salesforce-managed private connections. This offers stronger data residency assurance for regulated industry clients. Claude Haiku 4.5 does not support multimodal features.
- **GPT-4.1** runs over the **shared trust boundary** — public internet with contractual zero data retention protections. It supports multimodal features and is Salesforce's recommended default for most agent configurations.

> **Client conversation tip:** When a regulated industry client (financial services, healthcare, government) asks which model to use, lead with the trust boundary distinction rather than benchmark comparisons. For most compliance conversations, data residency is the deciding criterion. When capability and feature set are the primary concern, GPT-4.1 is the stronger starting point. Always recommend thorough testing with the client's own workload before committing to a model in production — benchmark scores on generic datasets do not reliably predict performance on a specific domain.

Clients migrating from legacy to new builder should be aware that the default model configuration changes and should re-evaluate their agent's performance after migration.

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
| OpenAI Ada 002 | Verify availability in current release notes — status may have changed |

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
- **Credit cost:** Hybrid search consumes more Data Cloud service credits than vector-only search. This is internally confirmed by Salesforce Data Cloud support. The exact credit multiplier is not published externally — do not quote a specific ratio to clients; quote the direction only.

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

**ADL is the right default for most client deployments.** It is faster to provision, easier to maintain, and designed specifically for the Agentforce use case. Choose manual only when the ADL's constraints genuinely prevent the required architecture.

#### 7.2 ADL Is a Single-Source Architecture — Today

This is one of the most important architectural facts to communicate clearly in discovery conversations.

**ADL currently supports only two source types: files (SFDRIVE) and Salesforce Knowledge articles (KNOWLEDGE).** No other data sources are supported through the ADL interface.

**ADL is designed as a single-source architecture.** An ADL can contain either files or knowledge articles — or both. If an ADL contains both, it creates two separate retrievers (one per source path) and bundles them into a default ensemble retriever. This works well when both sources are complementary for the same question domain.

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

SFDRIVE supports files from external storage platforms without copying the physical files into Data 360. Only the raw textual content from the chunking process, and the DMO records, reside on Data 360. The physical files stay in their original location.

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
3. But the CRM Connector has not yet committed article data to the lakehouse — there is approximately a **17-second** visibility delay before data is queryable.
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
    messaging:...    # if present

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

---

**Pillar 2: Data Masking — Scope and Current Limitations**

> **v3.2 Correction:** This pillar was incorrectly described in v3.1 as always-on for all Agentforce workloads. The accurate position is below.

Unlike Salesforce's standard turnkey generative AI features (Service Reply Recommendations, Case Summarization, Search Answers), **dynamic data masking is currently disabled for Agentforce agent workflows** — that is, any prompt generated and sent by the Atlas Reasoning Engine as part of agent planning or action execution. This is a deliberate, documented architectural decision, not a defect: masking strips business context (account names, case details, customer identifiers) that the agent needs to reason accurately. Salesforce has not published a roadmap to change this.

Masking still applies in two narrower cases:
- Turnkey GenAI features invoked outside the agent planner (Service Replies, Work Summaries, Search Answers)
- Prompt templates called directly via Flow, Apex, or LWC — outside of an agent context

**What compensates for the lack of masking in agent workflows:**
- Zero Data Retention (ZDR) still fully applies
- Data in transit and at rest is encrypted
- Prompt Injection Detection and Prompt Defense (Pillars 3 and 4) still run on every agent prompt
- Toxicity Scoring (Pillar 5) still runs on every response
- Standard Salesforce sharing, FLS, and permission sets still gate what data the agent can surface
- Data 360's ABAC framework with CEDAR policies provides granular field- and row-level security at the data layer (see Chapter 12)

**Client conversation implication:** When asked "is our PII masked before it reaches the LLM?" for an agent use case, the honest answer is no — masking is off for that path today. Lead with ZDR, encryption, and the trust-boundary model instead. Be direct that this is current-state architecture, not a client-configurable toggle.

---

**Pillar 3: Prompt Injection Detection**

Malicious users sometimes attempt to override an agent's instructions by embedding hidden commands in their messages — "Ignore your previous instructions and..." The Trust Layer scans user inputs for injection patterns and blocks or flags them before they reach the reasoning engine.

**Pillar 4: Prompt Defense**

System-level policies injected by the Trust Layer instruct the LLM to stay within the agent's defined scope and mitigate prompt injection attacks at the instruction level, complementing the detection controls in Pillar 3.

**Pillar 5: Toxicity Scoring**

Every LLM response is scored for toxic content before it reaches the user. Responses exceeding configured thresholds are blocked. The score is logged in the audit trail. Toxicity scoring is enabled by default. It is admin-configurable (thresholds can be adjusted), but it is on by default and cannot be silently bypassed.

Input-level toxicity detection (before the prompt reaches the LLM) and output-level toxicity detection (before the response reaches the user) both run. For sensitive use cases (HR grievances, healthcare discussions), test with realistic conversation samples before launch to calibrate thresholds appropriately.

> **Scenario: The Frantic Go-Live Morning**
>
> 8 AM on go-live day. The agent is deployed. Permission sets are assigned. The ADL shows READY. But every test question gets a polite decline.
>
> The four-layer diagnostic in order:
> 1. Layer 1 check: Is the Data 360 permission set assigned to the agent user? Confirmed.
> 2. Layer 2 check: Does the agent user have access to the correct Data 360 data space? Missing. The data space permission was never assigned. A 30-second fix that took 90 minutes to diagnose.
>
> Go-live is delayed by two hours. The four-layer permission model in Chapter 13 is the pre-launch checklist that prevents this scenario.

---

### Chapter 12: Data 360 — The Intelligence Infrastructure

Data 360 is Salesforce's cloud-native, metadata-driven data platform — the infrastructure layer that makes RAG possible at enterprise scale. Understanding its architecture gives SAs the vocabulary to have meaningful conversations with data architects and enterprise IT teams.

#### 12.1 The Storage Architecture

Data 360 is built on a **tiered storage model** that combines two complementary layers:

**Lakehouse layer (Apache Iceberg / Parquet):** Scalable, cost-efficient storage for large volumes of historical and batch data. Built for advanced analytics and machine learning. Abstractions stack from raw Parquet files at the base, through Iceberg table metadata, through a Salesforce Cloud Table layer that adds semantic metadata and cross-platform abstractions, up to a Lake Access Library consumed by application developers.

**Real-time layer (Low Latency Store):** A petabyte-scale NVMe SSD storage layer that sits above the Lakehouse. Processes real-time signals and engagement data. In-session data (such as recent agent conversation turns) is processed in memory and flushed to the Low Latency Store for subsequent fast millisecond access. Customer Profile Context is pre-fetched from the Lakehouse and cached here for real-time personalization. Data eventually migrates to the Lakehouse for long-term persistence.

**For RAG conversations:** This tiered model is what allows agents to access large historical document corpora (Lakehouse) while also maintaining low-latency access to real-time session context (LLS) within a single conversation.

#### 12.2 Data Organization: DLOs, DMOs, and Data Spaces

Understanding how data is organized in Data 360 is essential when discussing RAG corpus architecture with technical clients.

**Data Lake Objects (DLOs):** The core persistent storage layer. Stores cleaned, transformed data and serves as the long-term repository. DLOs include structured DLOs (traditional tabular data), Unstructured Data Lake Objects (UDLOs — directory tables pointing to unstructured content like files and documents), and External DLOs (federated views of data that stays in external systems).

**Data Model Objects (DMOs):** The harmonized layer. Created by mapping DLO fields to the standard Customer 360 Data Model. DMOs are the single source of truth for customer data — the foundation for profile creation, segmentation, and activation. For Knowledge article RAG, the search index is built against a structured DMO.

**Data Spaces:** The fundamental logical container for organizing all data and metadata. Data spaces enforce isolation at multiple layers: data-level isolation (queries cannot cross data space boundaries without explicit authorization), access control integration (permission sets tied to data spaces), and governance with full audit trails. Data spaces are how multi-tenant and multi-business-unit organizations maintain separation while sharing a single Data 360 instance.

#### 12.3 Data 360 as a Zero-Copy Infrastructure

Data 360's architecture supports zero-copy data access for structured data from external platforms — Snowflake, Databricks, BigQuery, Redshift — through both query-based federation (JDBC pushdown) and file-based federation (Apache Iceberg / Parquet directly from object storage). For RAG specifically, SFDRIVE-based libraries also follow a zero-copy model for external file storage: the physical files never move to Data 360. Only the text extracted from chunking, and the DMO records containing vectors, reside there.

This matters for:
- **Data residency compliance:** The original file stays in its source location (S3, Azure Blob, etc.)
- **Storage cost:** Clients are not paying Data 360 storage costs for large binary files
- **Governance:** Source-side access controls on the file storage remain the authoritative gate

Zero-copy also extends to unstructured data sources — hyperscaler storage (S3, GCS, Azure), Slack, and Google Drive — which Data 360's unstructured processing pipelines can access without physical data movement.

#### 12.4 Data 360 ABAC and RAG Security

Data 360 implements a comprehensive **attribute-based access control (ABAC)** framework using **CEDAR policy language** at the object, field, and row levels. This is architecturally significant for RAG deployments.

The framework operates through three interlocking components:

- **Policy Information Point (PIP):** Automated tagging and classification using LLM and ML to identify sensitive categories (PII.Email, PII.Phone, PII.Name, PHI, FinancialData) in both structured and unstructured data. Tag propagation follows data lineage automatically — from DLO through DMO through derived objects.
- **Policy Enforcement Point (PEP):** The Authorization Service intercepts all data access requests from consumption layers (queries, GenAI RAG retrievers, CRM enrichment) and consults the Policy Decision Point.
- **Policy Decision Point (PDP):** Evaluates CEDAR policy definitions against current attributes to make authoritative access decisions.

**CEDAR policy enforcement levels for RAG:**
- Object Level Security: controlling access to entire DLOs or DMOs
- Field Level Security: restricting access to specific sensitive fields
- Row Level Security: filtering data to show only relevant rows based on user attributes
- Dynamic Data Masking: masking fields in structured data and content in unstructured data at the point of access, without altering underlying data

For RAG specifically, metadata filtering (pre-filters on search indexes) restricts what gets retrieved for a given user or context, enforced at the retrieval layer before any LLM call. Together, these controls mean RAG security can be as granular as the content requires — different users retrieve from different slices of the same corpus.

**To protect against RAG poisoning attacks** — where malicious content is injected into the corpus to manipulate agent responses — apply strict data governance and validation rules through the ABAC framework before data becomes available for vector search.

#### 12.5 Incremental Processing: SNCE and CDF

Two mechanisms power Data 360's near-real-time processing, which directly affects how quickly content changes propagate to the RAG index:

**Storage Native Change Events (SNCE):** Every successful write to an Iceberg table triggers a native notification event. Downstream pipelines subscribe to these events rather than polling. This shifts Data 360 from a batch-poll model to a reactive, incremental model.

**Change Data Feed (CDF):** Built on SNCE, CDF provides a streamlined mechanism to consume only the changed records. Data 360's optimized Iceberg writer computes and persists changes as part of the write operation, making CDF generation efficient. Processing jobs selectively process only altered records, avoiding expensive full-table scans.

**For RAG conversations:** When clients ask "how quickly does the agent know about content changes?", SNCE and CDF are the architectural answer. The propagation latency from content change to retrieval availability depends on the chunking job interval (approximately 10 minutes for KNOWLEDGE libraries), not on batch ETL windows.

#### 12.6 Private Connectivity

For regulated industry clients who restrict internet-exposed data lake access, Data 360 supports private, network-level connectivity:

- **AWS PrivateLink:** Connects Data 360 directly to customer-provisioned endpoints within their AWS accounts, with all traffic remaining on the AWS backbone using private IP addressing
- **Private Interconnect:** Cross-cloud private connectivity for Azure (ExpressRoute) and Google Cloud (Cloud Interconnect) environments, available as either Customer-Managed or Salesforce-Managed configurations

This matters for SA conversations: the "we can't put our data lake on the internet" blocker is addressable through Private Connectivity, not a fundamental barrier to Data 360 adoption.

---

### Chapter 13: The Four-Layer Permission Model

When RAG is working in development but failing in production, permissions are the first diagnostic layer. The failure usually lives at exactly one of these four layers.

#### Layer 1: Data 360 Permission Set

The Einstein Agent User must be assigned the correct Data 360 permission set. Without it, the agent user cannot access Data 360 at all — no retrieval queries execute, no results return, and no error surfaces to the user. The agent just says "I don't have that information."

**Diagnostic check:** In Setup, confirm the agent user profile has the required Data 360 permission set assigned. This is frequently missed during go-live handoffs because it lives outside the Agentforce setup flow.

#### Layer 2: Data Space Access

The agent user must have access to the specific Data 360 data space that contains the search index. Without it, the retrieval query executes but returns 0 results — same symptom as Layer 1 but different fix. Data spaces enforce isolation at the permission set level.

**Diagnostic check:** In Data 360 Setup, verify the agent user's permission set includes access to the relevant data space.

#### Layer 3: Search Index Permissions

The search index itself must be configured to allow access by the agent user. This is a separate configuration from data space access.

**Diagnostic check:** In the ADL or search index configuration, verify that the agent user's permission set is listed in the index access controls.

#### Layer 4: Knowledge Article Sharing and Publish Status

For KNOWLEDGE libraries, article sharing must be configured to allow access by the agent user, and articles must have `PublishStatus = 'Online'`. Articles in Draft or Archived status are not indexed and do not appear in retrieval results.

**Diagnostic check:** SOQL query against `Knowledge__kav` filtered to `PublishStatus = 'Online'` and confirm the expected articles are present. Verify the article's Data Category assignments match the scope configured in the search index.

> **The four-layer permission checklist is pre-launch, not post-failure.** Running through these four checks before go-live takes 15 minutes. Not running them means the go-live scenario described in Chapter 11 is almost guaranteed.

---

## Part 6: Production Operations

---

### Chapter 14: Observability — Seeing Inside the Agent

#### 14.1 The Observability Architecture

Agentforce session data is captured in a set of Data Model Objects (DMOs) within Data 360. These DMOs are what power the out-of-the-box dashboards and are also queryable directly for custom reporting.

#### 14.2 The Session and Interaction DMOs

**AiAgentSession:** One record per conversation session. Contains session-level metadata: agent ID, channel, start/end timestamps, and resolution status.

**AiAgentInteraction:** One record per agent turn (parse cycle). Key fields:
- `TopicApiName` — the subagent that handled this turn (maps to Agent Script subagent API names)
- `StartTimestamp` / `EndTimestamp` — turn duration
- `TelemetryTraceId` — distributed tracing ID for correlating with LLM gateway logs

**AiAgentInteractionStep:** One record per step within a turn. Key fields:
- `StepType` — `LLM_STEP`, `ACTION_STEP`, `TRUST_GUARDRAILS_STEP`
- `EndTimestamp` — frequently `NOT_SET` for in-progress or interrupted steps

Two important data quality notes: the platform uses `"NOT_SET"` (string) as a sentinel for null values, and the `TRUST_GUARDRAILS_STEP` error field may contain the Python string `"None"` — which is not a real error. Filter accordingly in any custom queries or dashboards.

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

- **Session and interaction data:** Near real-time (typically minutes)
- **RAG quality metrics:** Available within approximately 30 minutes of session completion
- **Billing and credit consumption data:** 24-hour delay — do not use for same-day operational decisions
- **Audit trail data:** Near real-time for Trust Layer events; 24-hour delay for aggregated reports

---

### Chapter 15: When to Involve a Developer — Pro-Code RAG

#### 15.1 The No-Code Boundary

The ADL and Agent Script cover the majority of production RAG use cases. A developer conversation is warranted when the client's requirements exceed what the ADL supports.

**Escalate to a developer when:**

- The knowledge source is not Knowledge articles or files (e.g., long-text fields on Case, Order, or custom objects)
- The client needs to retrieve from an external system with its own API (e.g., a document management system, Confluence, SharePoint with custom auth)
- Retrieval requires custom business logic before returning results (e.g., filtering based on a complex entitlement calculation)
- The client needs to combine multiple heterogeneous sources in a single retrieval call
- Data residency requirements mandate that content never enters Salesforce storage, even temporarily

**The pro-code path:** Custom Apex Action that calls an external retrieval API, populates a variable with the result, and passes it to the reasoning instructions. The Agent Script pattern is identical to the ADL pattern — the variable name changes, the retrieval action changes, the guard logic is identical.

#### 15.2 MuleSoft as a Retrieval Broker

For clients with complex external knowledge stores, MuleSoft acts as a retrieval broker between the Agentforce agent and the external system. The Apex action calls MuleSoft, which applies business logic, calls the external API, and returns a normalized result. This pattern keeps the agent implementation clean and keeps external system integration complexity inside MuleSoft, where it is maintainable.

---

### Chapter 16: The Credit Model — What RAG Actually Costs

#### 16.1 The Flex Credit Framework

All Agentforce consumption is measured in Flex Credits. The base rate is $500 per 100,000 credits. Every action, retrieval, and processing event consumes credits at a published rate.

#### 16.2 The Credit Table

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

This is a one-time cost at initial indexing, but it recurs whenever the content fields are updated. Avoid unnecessary full re-indexes.

**The web search fallback cost trap:** As noted in Chapter 9, a high retrieval miss rate combined with a web search fallback doubles the per-session retrieval cost. Improving corpus quality is always more cost-effective than relying on the fallback.

---

## Part 7: Troubleshooting and Client Conversations

---

### Chapter 17: Troubleshooting — The Diagnostic Ladder

#### 17.1 The Diagnostic Principle

Agentforce failures have a predictable structure. The deterministic layer runs first. If something is wrong there, the LLM never gets a chance to succeed. Work from the bottom up: permissions, then ADL readiness, then Agent Script logic, then LLM behavior.

#### 17.2 The Four-Rung Ladder

**Rung 1: Permissions (Chapter 13)**

Before touching any Agent Script or corpus configuration, run through all four permission layers. Most "the agent isn't answering" failures at go-live live here. Start here every time.

**Rung 2: ADL Readiness**

Check the ADL status. For SFDRIVE, confirm all files show `INDEXED` status. For KNOWLEDGE, confirm the `retrieverId` is non-null *and* a live test query returns non-empty results (not just `retrieverId` non-null). The Day 0 race condition (Chapter 18) is the most common failure here.

**Rung 3: Agent Script Logic**

Reconstruct the resolved prompt. What did the LLM actually receive? Is the guard variable name correct? Is the `AnswerQuestionsWithKnowledge` call in `before_reasoning` or incorrectly placed as an LLM-callable tool? Is there an action loop?

**Rung 4: LLM Behavior**

If the resolved prompt is correct and the retrieval result is populated, but the response is still wrong, the issue is in the LLM reasoning instructions. Tighten the anti-hallucination guard, clarify the answer scope, or adjust subagent descriptions to improve routing.

#### 17.3 Testing Center for RAG — Current Limitations

> **v3.2 addition:** This note was missing from v3.1.

The Agentforce Testing Center provides powerful batch testing for topic classification, action sequences, and response quality. However, **the RAGAS-style RAG quality metrics (Context Precision, Faithfulness, Answer Relevance) are not currently available in Testing Center batch test runs.** These metrics are available in:
- Interactive (single-turn) testing within Agent Builder
- The production AiRetrieverQualityMetric DMO dashboard

Batch-test RAG quality scoring is on the roadmap (targeted approximately for Dreamforce timeframe). Until it is GA, automated Test Suite RAG scoring requires custom scorers via the Testing API. Do not promise clients that Testing Center batch runs will surface RAG quality scores — set the expectation accordingly.

The Testing Center does support:
- Topic classification validation
- Action sequence verification
- Response quality (LLM-as-judge, 0-5 scale, score ≥3 = Pass)
- Citation validation
- Instruction adherence
- Multi-turn conversation testing via conversation history import

---

### Chapter 18: Known Platform Issues

#### 18.1 The Day 0 Race Condition (KNOWLEDGE Libraries)

Covered in Chapter 8.2. The CRM Connector has approximately a **17-second** visibility delay after library creation before article data is queryable. The Day 0 chunking job fires immediately processes 0 rows, emitting a false READY status. Always verify with a live test query, not just `retrieverId` presence.

#### 18.2 Post-Day-0 Incremental Refresh Stall

> **v3.2 addition:** This is a separate and distinct failure mode from the Day 0 race condition.

After a successful Day 0 index, the KNOWLEDGE library can silently stall on *incremental* refreshes. Symptoms: the library shows READY and `retrieverId` is non-null, the Day 0 index was successful, but new or updated articles are not appearing in retrieval results.

**Root cause:** Streaming jobs stop receiving change-data-feeds (CDF) from the source DMO. This is sometimes caused by a BYOK (Bring Your Own Key) or encryption misconfiguration that prevents the SNCE/CDF pipeline from reading the underlying Iceberg table snapshots. Documented in support investigation SI-0287033.

**Standard fix:** A manual full Rebuild of the search index (not just a re-trigger) forces a complete re-scan of all current articles, bypassing the stalled CDF pipeline. After Rebuild, monitor incremental refresh for 24 hours to confirm the pipeline resumes.

**Pre-launch check:** If the org uses BYOK or custom encryption, verify CDF pipeline health as part of the go-live checklist — not just Day 0 READY status.

#### 18.3 The `after_reasoning` Skip (is_displayable: True)

Covered in Chapter 2.2. When `is_displayable: True` is set on an action, `after_reasoning` never executes for that parse. Move must-execute orchestration logic to `before_reasoning` of the next subagent.

#### 18.4 The Language Alignment Silent Failure

Covered in Chapter 8.2. `en_US` vs. `en_GB` is treated as a mismatch by the retriever. The retriever silently returns 0 results. The fix is confirming the agent user's language/locale matches the indexed articles' language.

#### 18.5 The `ARFPC_` Prefix Omission

Covered in Chapter 8.3. The `rag_feature_config_id` must include the `ARFPC_` prefix. The validation error does not explain the requirement.

#### 18.6 Circuit Breaker Failover

When an LLM provider is unavailable, the Trust Layer activates a circuit breaker that fails over to an alternate provider. The specific thresholds (error rate, latency) that trigger the circuit breaker are not published externally. No new corroboration of specific figures has been found; keep this caveat as-is in client conversations.

---

### Chapter 19: Client Conversation Frameworks

#### 19.1 "Is Our Data Safe?" — The Security Framework

Use the five Trust Layer pillars from Chapter 11. Lead with ZDR (contractual guarantee, no model training). Add encryption (in transit TLS 1.2+, at rest AES-256). Add Prompt Injection Detection and Prompt Defense. Add Toxicity Scoring.

For agent workflows specifically: be direct that dynamic data masking is currently off for the agent planner path. Lead with ZDR and the other active controls. Do not position masking as an active safeguard for agent prompts.

For regulated industries: lead with the trust boundary distinction (Salesforce trust boundary vs. shared trust boundary), ZDR, and the Data 360 ABAC framework for data-layer security.

#### 19.2 "How Does It Know About Our Products?" — The RAG Framework

Walk through the four stages of grounding maturity (Chapter 4.4). Position where the client currently sits and what Stage 4 requires. Connect corpus design (Chapter 5.5) to the business conversation about content ownership and governance.

#### 19.3 "What Does This Cost?" — The Credit Framework

Start with the action credit ($0.10 per action). Add the corpus processing cost ($0.75/MB basic, $3.00/MB enhanced). Estimate session volume. Build a simple credit model before go-live. Flag the web search fallback cost trap and the action loop billing risk.

#### 19.4 "How Do We Keep It Accurate?" — The Governance Framework

Three levers: corpus governance (quarterly Knowledge audit, clear ownership), retrieval tuning (chunking enrichment, embedding model, pre-filters), and RAG quality monitoring (AiRetrieverQualityMetric DMO). Frame it as an ongoing operational discipline, not a one-time launch activity.

---

## Part 8: Architecture Patterns

---

### Chapter 20: Six Production Architecture Patterns

#### Pattern 1: Single-Source Knowledge Agent

**When to use:** Client has a well-maintained Salesforce Knowledge base. Single line of business. Single language.

**Architecture:** ADL (KNOWLEDGE) → ensemble retriever (single source) → `AnswerQuestionsWithKnowledge` in `before_reasoning` → anti-hallucination guard → citations enabled.

**Risks:** Language alignment. Day 0 race condition. Primary index field selection (immutable). Corpus governance.

---

#### Pattern 2: File Library Agent

**When to use:** Client has proprietary documentation in PDF, HTML, or TXT format. Content is not in Knowledge articles. Document structure is complex.

**Architecture:** ADL (SFDRIVE) → file mode selection (basic vs. enhanced based on content complexity) → `AnswerQuestionsWithKnowledge` in `before_reasoning` → anti-hallucination guard.

**Risks:** Enhanced mode cost on large corpora. File size limits (100 MB). Index failure states.

---

#### Pattern 3: Hybrid Knowledge + File Agent

**When to use:** Client has both Knowledge articles and supplementary PDFs (e.g., policy documents, technical manuals) for the same domain.

**Architecture:** ADL containing both KNOWLEDGE and SFDRIVE sources → platform auto-creates two retrievers + default ensemble retriever → agent wired to ensemble retriever → cross-source reranking handles unified results.

**Risks:** Always wire to the ensemble retriever, not to individual source retrievers. Verify retriever selection in prompt template configuration.

---

#### Pattern 4: Segmented Retrieval Agent (Dynamic Pre-Filters)

**When to use:** Client serves multiple user segments with different content entitlements from a single corpus. Example: individual, business, and enterprise policyholders.

**Architecture:** Identity verification subagent → segment variable set → retrieval subagent with dynamic pre-filter passing segment variable → scoped `knowledgeSummary` returned per segment.

**Risks:** Segment variable must be set before retrieval action fires. Pre-filter placeholder must match the runtime variable name exactly.

---

#### Pattern 5: Web-Augmented Agent (Knowledge-First Fallback)

**When to use:** Client's agent scope includes both proprietary content and general public information. Compliance team has approved web search use.

**Architecture:** Proprietary ADL retrieval as primary → empty `knowledgeSummary` check → General Web Search as fallback → explicit source labeling in response.

**Risks:** High miss rate doubles cost. Not appropriate for regulated industries without explicit compliance approval.

---

#### Pattern 6: Single-Org Multi-Agent (SOMA) Orchestration

SOMA — Single-Org Multi-Agent — went GA in Summer '26. It enables a single Super Agent to own the user interaction while delegating to up to **7 Connected Subagents** within the same Salesforce org. The Supervisor pattern is used: the Super Agent receives all user requests, routes to the appropriate specialist Connected Subagent, receives results, and synthesizes the response.

**Key architectural constraints:**
- Maximum 7 Connected Subagents per Super Agent
- One level of delegation only (Super Agent → Connected Subagent; Connected Subagents cannot delegate further)
- Connected Subagents respond and return results — they do not route or orchestrate independently
- Communication within the same org uses the A2A Lite API (v1.1 Agent API)

**When to use:** Client has multiple specialized agents within a single org that need to collaborate on complex requests without context switching. Example: a financial services firm with Portfolio Agent, Risk Agent, Compliance Agent, and Client Communication Agent all coordinating under a single interface.

**MOMA (Multi-Org Multi-Agent)** extends this pattern across multiple Salesforce orgs within a shared DC1 trust boundary, with Primary Agents connecting to Secondary Agents in different orgs. All participating orgs must reside within the same DC1 trust boundary. MOMA delegation is strictly one-level (Primary → Secondary only; daisy-chaining is not supported).

---

## Appendix

---

### A1: The Four Silent Failure Checklist

Silent failures are failures where the agent responds without error but the response is wrong or empty. Check in order:

1. **Permission silent failure:** Agent user missing Data 360 permission set or data space access. Symptom: agent declines every question.
2. **Day 0 race condition:** KNOWLEDGE library shows READY but contains 0 indexed chunks. Symptom: `knowledgeSummary` always empty. Verify with live test query.
3. **Language alignment failure:** Agent user language does not match indexed article language. Symptom: retriever returns 0 results for every query. No error visible.
4. **Guard variable name mismatch:** Anti-hallucination guard references wrong variable name. Symptom: LLM answers from general knowledge when retrieval misses instead of deflecting.

---

### A2: RAG Anti-Hallucination Guard Template

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
    | Do not use general knowledge or information from outside
      @variables.knowledgeResult.
    | If @variables.knowledgeResult is empty or does not contain
      information relevant to the user's question, respond with:
      "I wasn't able to find that information in our knowledge base.
       Please contact [support channel] for assistance."
    | Always cite the source article when answering from
      @variables.knowledgeResult.
```

---

### A3: The Scoping Decision Tree

```
Is RAG needed?
|
+-- Client questions are only about CRM data (Account, Case, Order)
|    --> No RAG. Use Apex or Flow actions to fetch CRM records.
|
+-- Client questions require proprietary content knowledge
     --> RAG required.
     |
     +-- Content is in Salesforce Knowledge articles?
     |    --> ADL: KNOWLEDGE
     |
     +-- Content is in PDF/HTML/TXT files?
     |    --> ADL: SFDRIVE
     |         |
     |         +-- Complex tables/images/multi-column layouts?
     |              --> enhanced mode (verify cost first)
     |
     +-- Both Knowledge and files?
     |    --> ADL with both sources + ensemble retriever
     |
     +-- External system (Confluence, SharePoint, custom API)?
     |    --> Pro-code: Apex action + MuleSoft retrieval broker
     |
     +-- Long-text fields on non-KAV Salesforce objects?
          --> Manual configuration (pro-code)
```

---

### A4: Content Authoring Best Practices Checklist

Before go-live, review the corpus against these criteria:

- [ ] Articles are thorough, not brief. Each article provides complete information, not pointers to other resources.
- [ ] Articles include real-world examples in conversational language.
- [ ] HTML-formatted articles use heading tags (H1-H6) for logical structure.
- [ ] Knowledge articles use multiple fields (Question, Description, Resolution, Exceptions) rather than a single body field.
- [ ] Common synonyms and abbreviations are included in article text.
- [ ] The corpus scope matches the agent's topic scope. No tangentially related content.
- [ ] Content governance owner is identified. Quarterly audit cadence is scheduled.
- [ ] All articles are published (`PublishStatus = 'Online'`).
- [ ] Data categories are assigned and aligned with the search index scope.
- [ ] Language/locale of articles matches the agent user's language setting.

---

### A5: Multi-Source Architecture Decision Guide

| Scenario | Recommended Architecture |
|---|---|
| Single Knowledge source, single language | ADL (KNOWLEDGE), vector search |
| Single Knowledge source, multi-language | ADL (KNOWLEDGE), multilingual embedding model |
| Files only, simple prose | ADL (SFDRIVE), basic mode |
| Files only, complex layouts | ADL (SFDRIVE), enhanced mode (cost-justify first) |
| Knowledge + Files, same domain | ADL with both sources, default ensemble retriever |
| Knowledge + external system | ADL (KNOWLEDGE) + Apex custom action for external retrieval |
| Multiple orgs, same trust boundary | MOMA (Primary + Secondary agents) |
| Single org, multiple specialist agents | SOMA (Super Agent + up to 7 Connected Subagents) |
| External data lake, no file movement | Data 360 zero-copy federation → custom retriever |

---

### A6: Terminology Reference

| Term | Definition |
|---|---|
| Atlas Reasoning Engine | Public-facing name for the Agentforce runtime engine |
| Unified Planner | Engineering product name for the Atlas runtime; unifies Agent Graph + Voice Planner |
| ADL | Agentforce Data Library — the no-code RAG provisioning tool |
| DLO | Data Lake Object — persistent storage layer in Data 360 |
| UDLO | Unstructured Data Lake Object — directory table for unstructured content |
| DMO | Data Model Object — harmonized Customer 360 data layer |
| Data Space | Logical isolation container in Data 360 |
| SNCE | Storage Native Change Events — reactive change notification from Iceberg tables |
| CDF | Change Data Feed — incremental change consumption built on SNCE |
| ABAC | Attribute-Based Access Control — Data 360's governance framework |
| CEDAR | Policy language used to define ABAC rules in Data 360 |
| SOMA | Single-Org Multi-Agent — orchestration pattern for multiple agents within one Salesforce org (GA Summer '26) |
| MOMA | Multi-Org Multi-Agent — orchestration pattern across multiple Salesforce orgs within the same DC1 trust boundary |
| ZDR | Zero Data Retention — contractual guarantee that LLM providers do not retain prompt data |
| Salesforce trust boundary | Network path for Claude Haiku 4.5 via AWS Bedrock with Salesforce-managed private connections |
| Shared trust boundary | Network path for GPT-4.1 via public internet with contractual ZDR protections |
| ARFPC_ prefix | Required prefix on `rag_feature_config_id` in the Agent Script `knowledge:` block |
| knowledgeSummary | The string payload returned by `AnswerQuestionsWithKnowledge` containing retrieved chunks |
| Day 0 race condition | KNOWLEDGE library false READY status caused by ~17-second CRM Connector visibility delay |
| Parse | The atomic unit of Agentforce execution: one complete cycle through before_reasoning, reasoning, and after_reasoning |
