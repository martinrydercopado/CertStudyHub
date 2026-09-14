# Agentforce Voice — Success Architect Reference Guide

*Last updated: September 2026*
*This is a living reference — re-check Testing Center pilot status, Five9/SIP support, native fuzzy-matching availability, Voice Minutes eligibility, and the Digital Channels/WebRTC roadmap item periodically, as all are explicitly evolving as of this date.*

> **Note:** This guide was initially generated using AI and has been reviewed and significantly expanded by SAs working active Voice engagements. Validate all technical guidance against official Salesforce documentation before use.

---

## 1. What Agentforce Voice Is — and Why It Matters

Agentforce Voice unifies PSTN/digital telephony, speech-to-text (STT), the Atlas Reasoning Engine, and text-to-speech (TTS) inside Service Cloud. A voice agent can autonomously handle calls, hand off to human agents with full context, and be observed and tested like any other Agentforce channel. It is tightly integrated into Service Cloud rather than a bolt-on voice silo.

**Why clients care.** Phone calls remain the highest-stakes customer service channel. Callers who cannot get help on a call switch to competitors faster than any other cohort, and they are more likely to escalate publicly. At the same time, human call centers are expensive and difficult to scale — average handle time, cost per call, and after-hours coverage are persistent pressure points for nearly every contact center leader.

A well-built Voice agent changes this equation in three ways:

1. **Deflection at scale.** Routine call types — appointment changes, order status, account lookups, policy questions — can be handled entirely by the agent without a human in the loop. Every deflected call is a real cost reduction.
2. **After-hours coverage.** An agent handles calls that would otherwise go to voicemail or an expensive overnight staffing arrangement.
3. **Better human agent productivity.** When a call does escalate, the human agent receives the full transcript and verified caller identity — eliminating the "can you explain the problem again?" moment that burns handle time and frustrates callers.

Real-world outcomes SAs can cite:
- A national sporting goods retailer routes 75%+ of inbound callers to the Voice agent, scaling toward 100%.
- A home services company handles 100% of after-hours calls autonomously.
- Salesforce's own 1-800 number uses Agentforce Voice for intent-based routing across support and sales.

**The architecture in plain English.** When a caller dials in, the telephony provider (Genesys or Vonage) hands the audio stream to Salesforce via SIP. Speech Foundations (Deepgram) converts the spoken audio to text. Atlas reasons about that text using the agent's subagents, actions, and knowledge, generates a response, and Speech Foundations converts that response back to spoken audio. From the caller's perspective: a voice on the phone. From the SA's perspective: a fully observable Agentforce agent with subagent routing, action traces, and session transcripts — the same platform concepts that apply to messaging and chat.

---

## 2. Setup Path (Standard)

**Step 1 — Licensing and prerequisites**
- Agentforce license + Service Cloud Voice license. Both are required. Voice alone accomplishes nothing without Agentforce, and vice versa.
- Enable Einstein Generative AI in Setup before anything else. Agents cannot be created until this is active.

**Step 2 — Telephony**
- Activate the voice infrastructure and channel with a supported telephony provider.
- Supported providers today: **Genesys** and **Vonage** for SIP/PSTN.
- **Five9 does NOT yet support SIP with Agentforce Voice** — this is a roadmap item with no confirmed GA. Workaround: use **PSTN call forwarding**, which is GA but US/Canada only and does not pass full IVR context or caller ID. See Section 10 for the full Five9 roadmap note.

**Step 3 — Permissions**
- Create an Einstein Agent User with the voice-specific permission sets.
- Grant end-user permission sets for the voice system.
- See the Agent User Setup reference for the full permission set list — missing even one permission set is a common cause of silent runtime failures.

**Step 4 — Agent Builder**
- Create a Service Agent (Setup → Agentforce Agents) or use the Agentforce Service Agent template ("Create from a Template").
- When prompted, select **"Optimize for Voice."** This sets the correct runtime planner type and voice-capable connection surface in the compiled metadata.

**Step 5 — Inbound call flow**
- Configure how calls route to the agent, what customer context is captured (ANI, DNIS, CRM record), and when to transition to a human agent.
- The Trailhead module "Set Up Your Agentforce Voice Agent" covers this end to end.

**Step 6 — Complete voice channel wiring (UI-ONLY — do not skip)**

> **Critical gotcha: `sf agent publish authoring-bundle` does NOT wire your agent to a phone number or SIP endpoint.**

Publishing succeeds, the metadata deploys cleanly, and the voice agent is ready in the org — but it will never answer a real call until this step is completed. Teams that skip it publish successfully and then spend hours troubleshooting why the phone never rings through to the agent.

After `sf agent publish authoring-bundle` completes, open the agent in **Agent Builder → Connections → Voice → Continue**. From there:

1. Attach the agent to a voice channel (phone number or SIP endpoint).
2. Optionally customize the voice persona and tuning. The complete picklist of available voices — with names, gender, accent, and locale — is only exposed in this UI. It is not accessible from the CLI or API.

This is a tracked gap in the internal roadmap ("Steel Thread 2 — voice channel wiring not supported headless"). Until CLI support lands, treat the UI step as a required manual handoff and communicate it to the client explicitly before the deployment session. It is also worth noting to the client that the voice picklist is only available post-publish, so they cannot preview the exact voice before publishing.

**Step 7 — MCP integration (if used)**
- Transport must be Streamable HTTP. Auth is OAuth 2.0 client-credentials only — no auth-code flow.
- No user-level auth exists, so identifiers (customer ID, order number, account number) must be passed as explicit tool inputs at every step. Nothing persists automatically across MCP calls.
- Keep API response shapes flat — nested objects are not yet fully supported in Agentforce Builder.
- For verification over MCP: build a dedicated "verify customer" MCP tool that accepts phone, order, or account number, call it early in the conversation, and pass the returned verified ID explicitly into every subsequent tool call.

---

## 2a. The `modality voice:` Block — Technical Reference

This is the primary technical surface where voice agents break during setup and the one most absent from other documentation. Developers building agents with Agent Script — and SAs debugging a Canvas-generated agent — need to know this material before going into a build session.

### When is this block required?

| Scenario | `modality voice:` Block Needed? |
|---|---|
| Text-only agent (messaging, web chat) | No |
| Voice-only agent (telephony) | Yes — required |
| Multi-channel agent (text + voice) | Yes |
| Employee agent (internal, no customer channel) | No — employee agents are text-only |

### Four required co-conditions

Every `.agent` file that includes `modality voice:` must also satisfy all four of the following. Missing any one causes either a validation failure or a silent runtime failure that is difficult to diagnose from logs alone.

**1. Standard `agent_type` in the config block — never set `Atlas__VoiceAgent`**

`Atlas__VoiceAgent` is a runtime `planner_type` value applied by the platform when the agent is published with "Optimize for Voice." It is not an authored field in the `.agent` file. Setting it there causes deployment errors.

```agentscript
config:
    agent_type: AgentforceServiceAgent   # correct
    # agent_type: Atlas__VoiceAgent      # WRONG — causes deployment errors
```

**2. A `VoiceCallId` linked variable bound to `@VoiceCall.Id`**

This is the voice-channel equivalent of `@MessagingSession.Id` for messaging agents. It provides the session identifier that ties the agent's actions and reasoning back to the specific call. Add it to the `variables:` block whenever `modality voice:` is present.

```agentscript
variables:
    VoiceCallId: linked string
        source: @VoiceCall.Id
        description: "This variable may also be referred to as Voice Call Id"
```

**3. A `language:` block with the correct locale**

```agentscript
language:
    default: en_US
```

**4. A `connection customer_web_client:` block**

`connection customer_web_client:` is the ECv2 surface that enables voice authoring and Preview. `connection messaging:` is **additive** — needed only for human escalation routing — and does not substitute for `customer_web_client:`. A common mistake is using `connection messaging:` alone for a voice agent, which generates the wrong planner surface. See Section 6a for the escalation-specific details.

### Block placement

`modality voice:` is a top-level optional block. Its position in the file matters. Place it after `language:` and before `start_agent:`.

```agentscript
system:
config:
variables:
connection:
knowledge:
language:
modality voice:       # here — after language:, before start_agent:
start_agent:
subagent:
```

### Voice V1 vs. Voice V2 syntax — you must pick one

> **This is a high-frequency developer mistake. Read this before authoring any `modality voice:` block from scratch or converting an existing one.**

As of release 262.14, the platform supports two structurally different syntaxes for the `modality voice:` block. They are informally called **Voice V1** and **Voice V2**. The rest of this section's property table documents Voice V1. **The two formats cannot be mixed** — all properties must use one syntax or the other. Mixing them will produce a validation error.

**Voice V1 — flat property syntax (the default)**

This is what the platform generates when you select "Optimize for Voice" in Agent Builder, and what the ADLC templates emit. Properties are declared directly inside `modality voice:` with no nesting.

```agentscript
modality voice:
    voice_id: "UgBBYS2sOqTuMpoF3BR0"
    outbound_speed: 1
    outbound_stability: 0.65
    outbound_similarity: 0.75
```

Voice V1 does **not** support explicit TTS model selection. The model is determined by the `voice_id` and cannot be overridden within this syntax.

**Voice V2 — nested outbound syntax (required for explicit model selection)**

Voice V2 uses a nested `outbound:` block and exposes an explicit `model:` sub-block. This is the only way to specify a TTS model (e.g., `eleven_flash_v2`) via Agent Script.

```agentscript
modality voice:
    outbound:
        persona_id: "a029af9d692c"
        model:
            id: "eleven_flash_v2"
```

> **Converting an existing V1 agent to V2 is a full block rewrite, not an additive change.** You cannot simply add a `model:` key to a V1 block. The entire `modality voice:` block — including all tuning properties — must be re-expressed in V2 syntax. Attempting to mix the two (e.g., keeping `voice_id` while adding `outbound: model:`) will fail validation.

**When to use which syntax:**

| Requirement | Use |
|---|---|
| Default voice, no model control needed | Voice V1 |
| Specific TTS model required (e.g., Flash v2 for pronunciation dictionaries, non-US English accent stability, or multilingual support) | Voice V2 |
| Agent initially created via "Optimize for Voice" checkbox | Voice V1 (already generated) |
| Agent built from scratch in Agent Script for a non-English deployment | Evaluate V2 before authoring |

**Why model selection matters in practice.** Pronunciation dictionaries (IPA/CMU) and the `outbound_speed`, `outbound_stability`, and `outbound_similarity` tuning parameters are only honored by the Flash model family. The default V3 model silently ignores all of them. If a client configures a pronunciation dictionary while implicitly on V3 (i.e., using Voice V1 without a model that supports it), the dictionary will have no effect. This is one of the most common pronunciation troubleshooting dead ends in the field.

**A note on the Canvas round-trip risk.** The V1/V2 distinction is another reason to treat voice agents as Agent Script-only artifacts. Canvas has no model selector and no concept of the V2 syntax. Opening a V2 voice agent in Canvas and saving it may silently downgrade the block to V1 — dropping model selection, pronunciation dictionaries, and all custom tuning in a single save operation.

### Full property reference — Voice V1

The following properties apply to the Voice V1 (flat) syntax. For Voice V2, consult the `voice-modality-reference.md` internal reference.

**Core TTS (outbound) properties**

| Property | Type | Range | Description |
|---|---|---|---|
| `voice_id` | string | — | TTS voice model ID. See "Default voice" below. |
| `outbound_speed` | float | 0.5–2.0 | Speech rate. 1.0 = natural pace. |
| `outbound_stability` | float | 0.0–1.0 | Voice consistency. Lower = more emotional range; higher = more stable. |
| `outbound_similarity` | float | 0.0–1.0 | How closely the AI replicates the source voice characteristics. |
| `outbound_style_exaggeration` | float | 0.0–1.0 | Emotional intensity. 0.0 = neutral, 1.0 = highly expressive. |
| `outbound_filler_sentences` | object | — | Phrases spoken while the agent is processing. Critical for masking action latency — see Section 5. |
| `pronunciation_dict` | object | — | Custom IPA or CMU pronunciation overrides for domain-specific terms. See Section 9 for known reliability issues before relying on this. |

**Inbound STT properties**

| Property | Type | Description |
|---|---|---|
| `inbound_filler_words_detection` | boolean | Enable recognition of filler words ("uh", "um") so the LLM does not interpret them as commands. |
| `inbound_keywords` | list | Specific keywords to improve STT recognition accuracy. Limited scope — see Section 9 for constraints. |

**Advanced configuration (sub-properties of `additional_configs`)**

*speak_up_config* — prompts the caller when silence is detected:

| Property | Type | Range | Description |
|---|---|---|---|
| `speak_up_first_wait_time_ms` | int | 10,000–300,000 | Wait (ms) before the first prompt. |
| `speak_up_follow_up_wait_time_ms` | int | 10,000–300,000 | Wait (ms) before follow-up prompts. |
| `speak_up_message` | string | — | Message spoken when the user is silent. |

*endpointing_config* — speech boundary detection:

| Property | Type | Range | Description |
|---|---|---|---|
| `max_wait_time_ms` | int | 500–60,000 | Max wait after speech stops before triggering reasoning. Critical for noisy environments — see Anti-pattern 7 in Section 5. |

*beepboop_config* — beep/tone behavior:

| Property | Type | Range | Description |
|---|---|---|---|
| `max_wait_time_ms` | int | 500–60,000 | Max wait for beep/tone behavior. |

### Default voice — always start here

There is no reliable CLI or API way to enumerate available voice IDs. Always author with the platform default and direct the client to customize in Agent Builder after publish. Do not ask the client to supply a `voice_id` before publishing.

| Field | Default value |
|---|---|
| `voice_id` | `UgBBYS2sOqTuMpoF3BR0` ("Mark") |
| `outbound_speed` | `1` |
| `outbound_stability` | `0.65` |
| `outbound_similarity` | `0.75` |

These values match the platform default `Eleven_Flash_V2_5` model configuration.

```agentscript
modality voice:
    voice_id: "UgBBYS2sOqTuMpoF3BR0"
    outbound_speed: 1
    outbound_stability: 0.65
    outbound_similarity: 0.75
```

After publishing, the client opens **Agent Builder → Connections → Voice → Continue** to select from the full voice picklist and apply custom tuning.

### Validating voice configuration before publishing

Run `sf agent validate authoring-bundle` before every publish. The validator catches voice-specific errors including:

- **Invalid `voice_id`** — must be a valid model ID from the org's voice provider.
- **Out-of-range floats** — `outbound_speed` must be 0.5–2.0; `outbound_stability` and `outbound_similarity` must be 0.0–1.0.
- **Timing values out of bounds** — speak-up timers must be 10s–5 min; endpointing and beepboop timers must be 0.5s–60s.

These errors do not always produce clear messages at runtime. Catching them with `validate` before publishing saves a publish-fail-diagnose-republish cycle on a live engagement.

### Canvas will destroy your voice configuration

> **Do not let anyone edit a voice agent in Canvas and save it.**

When a voice agent authored in Agent Script is opened in Canvas (the low-code visual builder) and saved, Canvas may overwrite or silently drop the entire `modality voice:` block — including all tuning properties, pronunciation dictionaries, filler sentence configuration, and endpointing settings. For Voice V2 agents, Canvas may additionally silently downgrade the block to V1, losing model selection. This is not limited to model selection. The entire block is at risk.

Voice agents authored in Agent Script should be treated as Agent Script-only artifacts for their entire lifetime. If the client's Admin wants to make a quick configuration change in Canvas, have that conversation early and clearly: either the SA or a developer makes the change in the `.agent` file and re-deploys, or the Admin accepts that the voice configuration will need to be fully re-authored after every Canvas save.

---

## 3. Lessons from the Field

**Background.** A healthcare software company attempted a self-implementation of Agentforce Voice. It failed: high-latency actions, a greater than 50% failure rate on customer identification, and insufficient understanding of the platform architecture required Salesforce to step in. Understanding what went wrong on that engagement prevents the same mistakes on yours.

**Lesson 1 — STT will misspell names and non-dictionary terms. Design for it from day one.**

Do not build identity or verification flows that rely on exact string capture of spoken names or structured IDs. "Sarah Johnson" becomes "Sara Jon." "CLM-2002" becomes "CLM dash 2002." Design fallback confirmation paths and alternate-ID flows as part of the initial architecture, not as a retrofit after callers start failing verification. Section 4 covers the full pattern and workarounds.

**Lesson 2 — Test with real calls, not just Preview.**

Preview testing gets an agent to feature-complete. But live-call behavior — accents, background noise, phone line quality, actual call latency under real telephony conditions — varies significantly from what Preview shows. Teams that pass Preview and go directly to go-live are regularly surprised. Build live-call testing into the timeline as a formal phase, not an afterthought.

**Lesson 3 — Voice conversation patterns differ fundamentally from text.**

Callers think out loud, interrupt themselves, have background noise, provide more context than was asked for, and are often doing something else while talking. A bot designed for clean, complete, sequential text inputs will behave surprisingly when real callers start talking over it. Review call transcripts from the client's existing IVR if they are available. Design prompts and flows around actual caller behavior, not around how a QA tester talks to a Preview window.

---

## 4. Known Issue: STT Accuracy on Names, IDs & Structured Input

This is the single most recurring field issue across Agentforce Voice engagements. Every SA working on a Voice build needs to understand it before the first client workshop — because clients will not tell you this is a problem until callers are already failing.

### The problem

The STT engine — Deepgram Nova-3 for clean audio, Nova-2 Phonecall for noisy PSTN — performs character-level transcription. It does not do phonetic name matching. The Agentforce platform then performs identity verification using exact string matching. There is no out-of-the-box fuzzy or phonetic name-match API as of July 2026.

The business impact: legitimate customers are rejected by the agent. Every false "Account Not Found" on a real caller is a failed interaction, a frustrated customer, and — in industries like financial services or healthcare — potentially a compliance issue if the caller then disengages from a required process.

**Specific transcription failures reported in the field:**

- **Names:** "Sarah Johnson" transcribes as "Sara Jon." Exact-match identity flows return false "Account Not Found" for real callers with legitimate accounts.
- **Alphanumeric IDs:** Contract or order numbers like "CLM-2002" transcribe as "CLM dash 2002" and fail format validation in downstream Flows.
- **Email addresses:** The "@" symbol sometimes transcribes as "at the rate" instead of the symbol, producing invalid email strings even when the caller pronounces clearly.

**No STT custom vocabulary (with one narrow exception):** Speech Foundations is fixed to Deepgram Nova-3/Nova-2. Per Product as of July 2026, vocabulary boosting for proper nouns and product names on the STT input side is "being explored" — no committed timeline. The narrow exception: the `inbound_keywords` property in the `modality voice:` block can improve recognition of specific terms (e.g., "Agentforce" instead of "agent force"). This is keyword-level, not grammar or vocabulary boosting. See Section 9 for details.

### Alternate input strategies

For structured input (IDs, account numbers, email addresses) where STT transcription accuracy is not sufficient:

- **SMS link fallback:** Send the caller a link via SMS to enter structured data on their phone. Effective and widely understood. Requires a Flows-based SMS action.
- **DTMF (keypad input):** For numeric IDs, prompt the caller to enter digits via the phone keypad instead of speaking them. Requires telephony provider support and is worth confirming with Genesys/Vonage early.
- **Chunked read-back-and-confirm:** Ask for one piece of information at a time, read it back for confirmation, then proceed. Slower but more reliable for high-stakes identity workflows when neither SMS nor DTMF is available.

### Field-proven workaround: DOB-first resolver and fuzzy matching engine

A reusable, vendor-agnostic pattern was built and hardened over two versions on a regional credit union engagement. The first version used a SOSL-first 4-tier ladder (SOSL name search → phonetic token narrowing → SOQL FirstName+DOB fallback → surname LIKE + phonetic-last-resort). This worked architecturally but caused an intermittent approximately 30-second latency spike that made it worse than the problem it solved. Version 2 replaced it with a DOB-first single query that is faster and more reliable.

**Why DOB first?** Date of birth is both highly reliable spoken input — callers almost never misspeak their birth date — and a strong database discriminator that narrows the result set before any fuzzy matching runs.

**The three-layer architecture:**

**Identification tier** — locate the account using date of birth as the primary key. The SOSL-first approach was abandoned specifically because of latency.

**Verification tier** — score how well the caller's spoken answers match stored data. The custom engine combines:
- **Double Metaphone** phonetic matching (encodes names by how they sound, not how they are spelled — "Sarah" and "Sara" produce the same code)
- **Jaro-Winkler + Levenshtein + character-similarity** blended scoring
- Tunable thresholds via a 26-field custom metadata type — threshold adjustments require no code release, only metadata deployment

**Deterministic verdict boundary** — the LLM only ever receives one of three outcomes: Accept / Review / Reject. It never sees raw scores or the "right answer." This is a critical design principle. Surfacing raw similarity scores to the LLM invites hallucinated reasoning about what is "close enough" — a 0.76 match score means nothing to an LLM without the context of what 0.76 means for this dataset and this use case.

**Freshness/expiry model:** A stale verification cannot silently authorize a new request within the same session. Session expiry logic must be explicit and tested.

The full deployable source — Apex classes, custom objects, permission sets, Flow skeletons, and a deploy-error catalog — is packaged as a reusable skill. Request access via `#builder-anz-capability-hub`.

**Voice biometrics (native):** On Agentforce Voice's longer-term roadmap alongside Supervisor Monitoring, Outbound/Predictive Dialer, and Memory/Session Persistence. No committed GA date as of mid-2026. For clients who need passive voice verification today — particularly in financial services — the recommended path is a third-party integration (Pindrop, Verint, IllumaSHIELD for credit unions) feeding a verified identity signal into the Agentforce action chain or the agent desktop.

---

## 5. Latency

Salesforce engineering targets **sub-second Time to First Audio (TTFA)** via the Flash Reasoning Engine. Even 300ms of added work can break the experience — callers perceive sub-second hesitations as a technical failure, not as normal processing time. The engineering team drove approximately 100ms reductions across individual services to reach this target. Separately, a broader Atlas improvement cut LLM calls from four to two per turn — a approximately 70% latency reduction — by consolidating knowledge-lookup steps.

**Business framing for clients:** Latency is not a technical metric on the voice channel. It is a CX metric. A 2-second response time feels natural in a chat conversation. The same 2-second pause on a phone call signals "something is broken." Establish this framing with clients early and explicitly — clients who benchmark their voice agent against their web chat agent will always be disappointed. The success threshold is closer to television broadcast quality than to web page load time.

### The eight latency anti-patterns

These are the root causes behind every significant latency complaint in field engagements. Knowing them gives an SA a structured diagnostic framework when reviewing a session trace rather than guessing.

Each pattern includes a **fix classification**: "Instructional (safe to apply)" means the fix lives in the agent bundle and can be implemented without client architectural sign-off. "Flag for human" means the fix touches action implementation, org-level settings, or telephony topology and requires the client's technical team.

---

**Anti-pattern 1: Synchronous writes on the live-call critical path**

The single largest field killer. Any DML operation, external callout, or trigger cascade running synchronously during a turn adds directly to perceived response time. A simple Apex insert with a standard trigger: 300–800ms. A managed-package trigger cascade: potentially multiple seconds. The problem compounds when the write happens mid-conversation, before the agent has responded.

*Scenario:* A financial services company builds a voice agent for account inquiries. A compliance requirement says every customer interaction must be logged. A developer adds a case creation step that fires during every turn. Average call latency jumps from 1.1 seconds to 4+ seconds. Callers hang up before the agent finishes speaking. The compliance requirement is real and non-negotiable — but it should be satisfied post-call via a Platform Event or async queue, not in-turn.

*Fix:* Move writes post-call using Platform Events or Queueable Apex. Use `outbound_filler_sentences` to mask the wait when a write genuinely cannot be deferred. **Flag for the client's technical team** — this is an action implementation change.

---

**Anti-pattern 2: Large result sets returned raw to the LLM**

Actions that return full record bodies — knowledge articles, case histories, search results — bloat the LLM context and force in-turn filtering. Every unnecessary token adds latency and reduces reasoning quality.

*Fix:* Enforce `limit`, `top_k`, and `max_chars` constraints on every retrieval action. Return summarized shapes, not raw objects. A knowledge retrieval that returns three 500-word articles when one 100-word excerpt would suffice is adding hundreds of milliseconds per turn. **Flag for the client's developer** — this is an action implementation change.

---

**Anti-pattern 3: Chained synchronous callouts**

Each synchronous external callout adds 1–3 seconds per hop. An action that calls an API that calls another API that calls an ERP system is a multi-second liability on the critical path.

*Fix:* Parallelize or batch where the external system supports it. Move to async where possible. Cache upstream responses in session variables if the same data is needed across multiple turns. **Flag for the client's technical team.**

---

**Anti-pattern 4: Over-routing through unnecessary subagents**

Unnecessary subagent hops each trigger a full LLM reasoning cycle. An agent with a router that routes to a sub-router that routes to a subagent — when a single subagent would have handled the request — adds latency with no business justification.

*Fix:* Flatten the subagent architecture. Add a routing layer only when subagents genuinely have different authority, different action sets, or different instruction requirements. This is an agent architecture change — **discuss with the client's architect** before applying.

---

**Anti-pattern 5: Long turn length**

Every additional sentence the agent generates per turn means more text for the TTS engine to render before audio begins. Long responses do not just sound unnatural on voice — they add measurable seconds before the caller hears anything at all.

*Fix (instructional — safe to apply):* Cap turns at 1–2 sentences for most voice subagents. Add an explicit instruction: "Respond in one or two short sentences. Do not provide lists or long explanations on the first response. If the caller needs more detail, they will ask." Configure `outbound_filler_sentences` to begin audio output immediately while reasoning continues in the background.

---

**Anti-pattern 6: TTS garble on non-spoken-form content**

Raw numbers, prices, IDs, phone numbers, URLs, and dates passed to TTS sound wrong and erode caller trust. "$172,576.81" is rendered as a string of disconnected digits. "+14155551212" sounds like "plus one four one five five five five one two one two." A URL reads letter by letter.

*Fix (instructional — safe to apply):* Add a spoken-form formatting instruction to all voice subagents. For example: "Before responding, convert prices to spoken form ('one hundred and seventy-two thousand dollars'), phone numbers to natural spoken form ('four one five, five five five, one two one two'), and dates to plain English ('September tenth'). Never read a URL aloud — instead say you will send a link by text message."

---

**Anti-pattern 7: STT endpointing too aggressive for the deployment environment**

If `endpointing_config.max_wait_time_ms` is too low, the STT engine signals end-of-turn before the caller finishes speaking — truncating the input and forcing a recovery turn. Truncated utterances trigger clarification questions, which trigger another STT cycle, which may also be truncated. This compounds quickly into a frustrating loop.

*Fix:* Raise `endpointing_config.max_wait_time_ms` for noisy environments. A typical safe range is 300–900ms; lean toward the high end for drive-through, retail floor, and home environments with appliances. This is a voice modality property change in the agent bundle — **safe to apply, but confirm the deployment environment with the client first** before adjusting timing values.

---

**Anti-pattern 8: SIP hops and transport topology**

Every unnecessary SIP relay between the telephony provider and Salesforce adds round-trip latency. This is largely outside the agent bundle's control.

*Fix:* Audit the SIP path topology during discovery and flag for the client's telephony team. This is not addressable at the agent-bundle level. Raise it early — topology changes have long lead times.

---

**Field note on cold-start latency:** Watch cloud-function and Lambda invocation budgets for custom telephony glue. One build hit a false "fault" because `createVoiceCall` took approximately 16 seconds against an 8-second invocation limit on a cold start. Retry before diagnosing a platform fault — cold starts are transient.

**Field note on Apex matching logic:** Custom Apex pure string manipulation (no SOQL, DML, or HTTP callouts) runs in-transaction with negligible governor-limit impact. Short-circuit matching ladders as soon as a tier returns a hit — do not run all tiers sequentially if an early tier already found the record.

---

## 6. Telephony Troubleshooting Patterns

**"Routing unbound / 0 Accepted AgentWork" in audit logs** — this finding is frequently a downstream *symptom* of a telephony-termination fault, not a routing misconfiguration. Verify the bot leg actually forms before concluding routing is broken. The bot path does not depend on human Omni-Channel queue configuration.

**"Reserve returns 200, then transfer leg gets TELECOM_BUSY"** — this pattern typically indicates a reserve-to-SCRT2 correlation gap on the client side (missing transactionId, wrong fromNumber) rather than a genuinely non-terminatable number. Check correlation data before escalating to Salesforce.

**Genesys/Vonage SIP deployments** — consult the SIP inbound-call-transfer help document and the Telephony PDF linked in the internal AF Voice resources canvas.

**Partner Telephony (BYO carrier) issues** — the official Salesforce Voice with Partner Telephony troubleshooting guide covers common problems end to end: https://developer.salesforce.com/docs/atlas.en-us.voice_pt_developer_guide.meta/voice_pt_developer_guide/voice_pt_troubleshooting.htm

**Text/chat-only customers** — clients who have agents deployed on text or chat channels can hit save/commit errors when scripts include telephony definitions (because they have missing voice config or licenses). This is a known workaround gap being tracked with the product team.

**Error 1271462884 — `modality voice:` block rejected at commit time despite save succeeding** — this error surfaces on orgs running a 260-patch release tier that does not yet support the `modality voice:` block. The symptom is deceptive: the agent saves without error, but commit fails with error code 1271462884 and the voice block is silently not applied. The voice agent appears published but behaves as a text agent. Resolution: remove the `modality voice:` block and confirm the org is on a release that supports Voice before re-adding it. If the org cannot be upgraded, escalate to the product team. This is exactly the "published but voice silently doesn't work" class of issue — always check the org's release tier early in any Voice engagement.

---

## 6a. Human Escalation — How It Actually Works

Human handoff is one of the most commonly misconfigured aspects of voice agents. Clients assume it works automatically after selecting "Optimize for Voice." It does not. Three conditions must all be true before `@utils.escalate` can successfully transfer a caller to a human.

**Why this matters to the business:** Callers who ask for a human agent are typically the ones who most need help. An escalation that silently fails — dropping the caller or routing to an empty queue — is the worst possible experience at the highest-stakes moment in the conversation.

### Condition 1: Omni-Channel must be configured and active

`@utils.escalate` routes the transfer through Omni-Channel. If Omni-Channel is not configured, or is configured but has no active queues, the escalation will fail. Verify end-to-end Omni-Channel queue routing before the first voice go-live — not as part of the go-live itself.

### Condition 2: A `connection messaging:` block must be present

For voice agents, `connection messaging:` is additive to `connection customer_web_client:`. Its specific role is to provide the escalation routing surface. Without it, `@utils.escalate` has nowhere to send the caller.

```agentscript
connection customer_web_client:    # required for voice authoring and preview
    ...

connection messaging:              # additive — required only for human escalation
    outbound_route_type: "OmniChannelFlow"
    outbound_route_name: "flow://Support_Queue_Flow"
    escalation_message: "Transferring you to one of our team members now..."
    adaptive_response_allowed: True
```

### Condition 3: Verify escalation support before the agent promises it

`@utils.escalate` ends the current agent session immediately and non-returnably. There is no built-in platform guard that checks whether Omni-Channel queues are available before attempting the transfer. If queues are full, closed, or misconfigured, the caller may be dropped.

The recommended pattern: verify that escalation is actually functional in the target environment before the agent script includes any language offering live transfer to a caller. A broken escalation promise is worse than no escalation path — it actively damages trust.

*Scenario:* A retailer builds a voice agent and includes the phrase "If you'd like to speak with a human, just ask." Testing in sandbox passes. In production, the Omni-Channel flow hasn't been deployed yet. Callers who ask for a human are transferred to nothing, and the call drops. The most vulnerable callers — those who couldn't get help from the bot — receive the worst experience. Verify the escalation path in production explicitly before go-live.

---

## 7. Billing and Flex Credits for Voice

Voice introduces billing considerations that differ meaningfully from other Agentforce channels. SAs need to understand these for two reasons: clients ask about cost in every discovery conversation, and several voice-specific billing rules regularly produce surprises after go-live if not established in advance.

### Two different billing scenarios — know which one applies

> **This distinction is the most common source of billing confusion in the field. Establish it in the first commercial conversation.**

**Scenario A — Custom-built Agentforce Voice agent (the default for SA-led builds)**

When a client builds a voice agent from scratch using Agent Builder, Agent Script, or Agentforce templates, the agent bills on the **metered Flex Credits / Voice Actions** model. Every action the agent executes during a call consumes credits. There is no resolution cap, no outcome gate, and no minimum turn count. This is the billing model that applies to the majority of SA-led Voice engagements.

**Scenario B — Agentforce Help Agent on the Voice Channel**

Help Agent is a separate, wizard-driven product ($2 per resolution). It uses an **outcome-based billing model** where you are only charged when a session is successfully resolved. The 10-minute resolution cap, the 2-resolution rule for long calls, and the outcome conditions described below apply specifically to Help Agent on the Voice channel. They do not apply to custom-built agents.

*Clients frequently conflate these two scenarios* — especially after reading Agentforce marketing materials that lead with outcome-based pricing. Clarify which scenario applies before any commercial modeling.

### How custom-built Voice agent actions are billed (Scenario A)

Voice calls consume Flex Credits through **Agentforce Voice Actions**, not standard Agentforce Actions. The credit multipliers are higher, reflecting the additional STT and TTS processing involved.

| Usage Type | Production Multiplier | Sandbox Multiplier |
|---|---|---|
| Standard Voice Action | 30 | 24 |
| Custom Voice Action | 30 | 24 |
| Standard Action (text channel) | 20 | 16 |
| Custom Action (text channel) | 20 | 16 |

Every action the agent executes during a voice call — account lookup, order status check, knowledge base query — consumes 30 Flex Credits. Agent utilities (subagent transitions, variable assignments, escalations to a human) are not billed as actions.

### Help Agent Resolutions on Voice — the 10-minute cap (Scenario B)

For clients on the **Help Agent Resolutions** outcome-based pricing model, the voice channel has a fundamentally different duration cap than other channels.

| Channel | Duration limit per single resolution |
|---|---|
| Enhanced Chat / Portal | 2 hours |
| Third-Party Messaging (WhatsApp, SMS) | 2 hours |
| **Voice Channel (Help Agent only)** | **10 minutes** |

A 12-minute resolved call counts as **2 resolutions**, not 1.

A session qualifies as a billable resolution when all three conditions are met: at least two turns of messages occurred, the final user feedback is not explicitly negative, and the session either concluded without escalation or ended with explicitly positive feedback. Unresolved sessions are not billed.

*Scenario:* A mortgage services company is evaluating Help Agent. Their average call length is 12 minutes — standard for a mortgage inquiry. At 2 resolutions per call, the actual bill per call is double what the company modeled using the single-resolution price. The SA who built the business case without knowing the 10-minute cap has set client expectations that are wrong by 100%. Establish discovery, not after go-live.

This cap most commonly affects financial services, healthcare, and field service — industries where calls naturally run longer because of verification requirements, explanation of options, and scheduling.

### Agentforce Voice Minutes — an alternative billing model

A separate billing model exists for eligible customers who purchase an Agentforce Voice Minutes subscription.

- Billing is **duration-based**: rounded up to the nearest full minute. A 61-second call = 2 minutes billed.
- **Rate: 60 Flex Credits per minute.**
- **If both Voice Actions and Voice Minutes are enabled in an org, Voice Minutes take precedence.** Voice Actions usage types do not apply to the same activity when Voice Minutes are active.
- Best suited for clients with predictable, high call volumes who prefer simple per-minute billing over per-action billing.
- Not automatically available. Clients must ask their AE about this model explicitly.

### Speech Foundations credits — the sandbox trap

Running voice consumes **Speech Foundations Flex Credits** separately from Agentforce action credits.

| Usage Type | Unit | Production Multiplier | Sandbox Multiplier |
|---|---|---|---|
| Speech to Text | Per hour of transcription | 150 | 150 |
| Text to Speech | Per 1M characters translated | 6,000 | 6,000 |

**Critical: Speech Foundations multipliers are the same in Sandbox and Production.** Almost every other usage type has a reduced sandbox multiplier. STT and TTS do not. Clients running intensive testing and development in a full sandbox are burning credits at the same rate as production.

*Scenario:* A retail company runs three months of intensive voice testing in a developer sandbox. The team logs approximately 200 hours of test calls and agent responses. At 150 credits per hour, that is 30,000 Speech-to-Text credits consumed — drawn from the same Flex Credit balance as production usage. The TTS credits for the agent's spoken responses add to that total. Nobody knew. Establish this in the first billing conversation with the client and plan sandbox testing timelines accordingly.

---

## 8. Testing & Observability

### Testing Center and bulk testing

Testing Center bulk-test support for Voice is in pilot as of approximately July–September 2026. Until GA, the recommended approach is:
- Run text-based bulk tests in Testing Center for subagent routing, action invocation, and LLM-as-judge quality scoring. These work today.
- Verify voice-specific behavior manually via Agentforce Studio Preview.
- Some teams have built API-driven test harnesses for higher-volume voice testing outside the platform — ask in `#builder-anz-capability-hub` for examples.

Testing Center scoring uses a 0–5 LLM judge scale where 3+ = pass. Instruction Adherence and Latency metrics are tracked as separate dimensions.

### Observability support matrix

Both **Agent Analytics** and **Agent Optimizer** fully support voice agents. The SA does not need to set up separate observability tooling for voice.

| Tool | Supported for Voice? |
|---|---|
| Agent Analytics | Yes |
| Agent Optimizer | Yes |
| Audio playback | Yes — PSTN customers only |

From the observability tools, SAs and clients can trace full call conversations, check latency per turn, review quality scores, and examine conversation outcomes directly from recorded calls.

**Data freshness — set client expectations clearly**

| Data source | Refresh cadence |
|---|---|
| STDM (Session Trace Data Model) | ~30 minutes |
| Agent Analytics metrics | ~45–60 minutes |
| Quality scores and intent tags | Daily or weekly |

This means a live-call troubleshooting scenario will not show data in Agent Analytics immediately after a test call. Clients or developers who expect to open Agent Analytics seconds after a test call will see nothing and conclude the tool is broken. Set this expectation clearly and direct real-time troubleshooting to CLI trace tooling instead.

**STDM parsing caveat for developers:** The `LLM_STEP` input/output fields in the STDM are raw Python dict strings, not valid JSON. Standard JSON parsers will fail on them. Only `ACTION_STEP` input/output fields are structured JSON. Any custom reporting or observability tooling built against the STDM must handle this difference — typically by using Python's `ast.literal_eval` or a regex pre-processor rather than `json.loads`.

---

## 9. Language & Conversational Design Best Practices

### Format output for how it sounds, not how it reads

**Numbers, currency, and prices.** TTS reads "$172,576.81" as a sequence of disconnected digits. Instruct every voice subagent to convert numbers to spoken form before responding: "one hundred and seventy-two thousand dollars." Do the same for phone numbers, account numbers, confirmation codes, dates, and times.

**URLs.** Never instruct the agent to read a URL aloud. The experience is uniformly bad — and it is rarely useful to the caller. Instead, instruct the agent to say "I'll send that link to your phone" and trigger an SMS action.

**Lists.** Bullet points and numbered lists do not translate to voice. An agent that responds "Here are your three options: first... second... third..." sounds like a telephone tree, not a conversation. Present one option at a time and let the caller respond before offering the next.

### TTS model selection — Voice V1 vs. V2 and what each supports

As of release 262.14, choosing a specific TTS model requires using Voice V2 syntax (see Section 2a). Available models that can be specified in a V2 `model:` block include: `eleven_flash_v2` (English only), `eleven_flash_v2_5` (multilingual), `kotoba` (Japanese), and the V3 default.

**Critical:** Only the Flash models honor custom pronunciation dictionaries (IPA/CMU) and the `outbound_speed`, `outbound_stability`, and `outbound_similarity` parameters. The default V3 model silently ignores all of them. If a client configures a pronunciation dictionary while their agent is using V3 (either explicitly via Voice V2 or implicitly via Voice V1 without a Flash voice ID), the dictionary will have no effect.

Flash v2 also holds non-US English accents more stably than V3 — this was the root cause of an Australian-accent rendering defect on a real engagement. For any non-US English deployment, use `eleven_flash_v2` or `eleven_flash_v2_5` via Voice V2 syntax.

**Model selection is Agent Script-only.** Canvas has no model selector. As noted in Section 2a, round-tripping a voice agent through Canvas can reset the agent to V1 syntax and V3 model behavior — silently breaking pronunciation dictionaries and accent stability. Treat model selection as one of many reasons to keep voice agents out of Canvas.

### Pronunciation Dictionary — test before you trust

Custom pronunciation is available for TTS output only, and only on Flash models. The dictionary supports IPA and CMU formats:

```agentscript
pronunciation_dict:
    pronunciations:
        - grapheme: "Xfinity"
          phoneme: "ɛks.ˈfɪn.ɪ.ti"
          type: "IPA"
        - grapheme: "SkyMiles"
          phoneme: "S K AY M AY L Z"
          type: "CMU"
```

**Known reliability issues reported in field engagements:**
- IPA entries can be rejected outright with "Enter a valid phonetic spelling" even when the IPA is syntactically correct.
- CMU entries can be spelled out letter-by-letter instead of applied phonetically.
- Brand-name keyword boosting can be silently ignored or produce inconsistent results even when configured correctly.
- A Southeast Asian telecommunications provider's deployment found that the Bahasa Indonesia pronunciation dictionary was not applying any registered words, and Loading Text fell back to auto-translated English defaults instead of the configured localized string.
- Japanese (Kotoba model) custom pronunciation via Kana is planned but not yet available.

**Always confirm pronunciation behavior in Preview before committing it to a go-live plan.** Do not build a client's go-live timeline around pronunciation dictionary entries until you have verified they work in that specific org with that specific model.

### STT keyword support — what's possible today

The `inbound_keywords` property in the `modality voice:` block can improve STT recognition of specific terms. For example, adding "Agentforce" as a keyword reduces the frequency of it being transcribed as "agent force." This is keyword-level hint, not full vocabulary or grammar boosting.

Per Product as of July 2026, broader vocabulary boosting for proper nouns and brand names on the STT input side is "being explored" — no committed timeline. Check the [Agentforce Voice Considerations](https://help.salesforce.com/s/articleView?id=ai.agentforce_voice_considerations.htm&type=5) doc for supported languages, limits, and updated constraints before scoping any engagement that depends on STT accuracy for specialized terminology.

---

## 10. What's Coming — Roadmap Items to Know

SAs should know these items to set correct client expectations during scoping conversations. None have committed GA dates as of September 2026.

**Digital Channels / WebRTC — in-app and web voice without a phone number**
Agentforce Voice for Digital Channels will support click-to-talk AI voice embedded directly in websites, portals, and mobile apps via WebRTC. No phone number or traditional telephony infrastructure required. Clients with digital portals will ask about this. The answer is: it's coming, it's not available now, and it should not be included in any current go-live scope.

**STT vocabulary boosting for proper nouns and brand names**
Moving beyond the current `inbound_keywords` workaround to proper domain vocabulary boosting on the STT side. Being explored, no committed timeline.

**Native voice biometrics**
Passive voice verification (confirming caller identity from the voice signal itself) is on the longer-term roadmap alongside Supervisor Monitoring, Outbound/Predictive Dialer, and Memory/Session Persistence. For clients needing this today, third-party integrations (Pindrop, Verint, IllumaSHIELD) remain the path.

**Five9 SIP support**
PSTN call forwarding is the current workaround for Five9 customers (US/Canada only, no full IVR context or caller ID pass-through). SIP support for Five9 is roadmap with no confirmed GA.

**Testing Center bulk testing for Voice**
Full bulk automated test support for voice is in pilot and expected to move toward GA following the July–September 2026 window. Until then: text-based bulk tests in Testing Center plus manual voice verification via Preview.

**Multi-turn voice conversation testing and deterministic controls via Agent Script**
Formally testing multi-turn voice conversation flows and applying Agent Script deterministic controls in a voice context is on the roadmap.

---

## 11. Enablement & Further Reading

**Public:**
- [Agentforce Voice Full Guide](https://www.salesforce.com/agentforce/voice/agentforce-voice-guide-full/) — end-to-end planning and deployment reference.
- [Set Up Your Agentforce Voice Agent (Trailhead)](https://trailhead.salesforce.com/content/learn/modules/ai-integration-for-agentforce-contact-center/set-up-your-agentforce-voice-agent)
- [Agentforce Voice Best Practices (Salesforce Help)](https://help.salesforce.com/s/articleView?id=ai.agentforce_voice_best_practices.htm&type=5)
- [Agentforce Voice Considerations](https://help.salesforce.com/s/articleView?id=ai.agentforce_voice_considerations.htm&type=5) — supported languages, limits, and technical constraints. Check this before scoping any non-English deployment.
- [Salesforce Voice with Partner Telephony Troubleshooting](https://developer.salesforce.com/docs/atlas.en-us.voice_pt_developer_guide.meta/voice_pt_developer_guide/voice_pt_troubleshooting.htm)
- [Salesforce Engineering — Sub-Second Latency for Agentforce Voice](https://engineering.salesforce.com/how-ai-driven-testing-enabled-sub-second-latency-for-agentforce-voice/)
- [Flex Credits Rate Card](https://www.salesforce.com/agentforce/rates/)
- [Agentforce Billing Usage Types (Salesforce Help)](https://help.salesforce.com/s/articleView?id=ai.agentforce_usage_billing.htm&type=5)

**Internal:**
- **Voice 101/201/301** enablement series in the AI Practitioner Hub. Voice 301 — mastery-level architecture decisions — is the right starting point for senior SAs and technical leads going into a complex Voice engagement.
- Internal Agentforce Voice & Chat Agents — Feedback, Trade-offs & Known Issues canvas — living document of known STT/limitation issues. Check it before any engagement kickoff.
- `#builder-anz-capability-hub` — request access to the reusable identity-resolution skill package (Apex classes including Double Metaphone and fuzzy matching, custom objects, permission sets, Flow skeletons, and a deploy-error catalog).
- Internal TSE support channel for live questions during engagements.
- Internal collaboration channel for active AF Voice projects.
