# Custom Lightning Components in Agentforce Agents
## A Field Guide for Success Architects

> **Audience:** Success Architects designing and guiding client implementations of Agentforce agents with rich, branded user experiences.
> **Last Updated:** August 2026

---

## Table of Contents

1. [Why This Matters](#1-why-this-matters)
2. [Concept Overview: Standard vs. Custom Lightning Types](#2-concept-overview-standard-vs-custom-lightning-types)
3. [The Three-Layer Architecture](#3-the-three-layer-architecture)
4. [Supported Channels and Surfaces](#4-supported-channels-and-surfaces)
5. [Build Path: Step-by-Step](#5-build-path-step-by-step)
   - 5.1 [Design the Apex Data Shape](#51-design-the-apex-data-shape)
   - 5.2 [Build the LWC Components](#52-build-the-lwc-components)
   - 5.3 [Create the Lightning Type Bundle](#53-create-the-lightning-type-bundle)
   - 5.4 [Register the Agent Action (GenAiFunction)](#54-register-the-agent-action-genaifunctiontion)
   - 5.5 [Wire the CLT in Agent Script](#55-wire-the-clt-in-agent-script)
   - 5.6 [Connect the CLT to the Agent Action in Setup](#56-connect-the-clt-to-the-agent-action-in-setup)
6. [Object-Based vs. Apex-Based CLTs](#6-object-based-vs-apex-based-clts)
7. [Naming Alignment: The Critical Rule](#7-naming-alignment-the-critical-rule)
8. [Deployment](#8-deployment)
9. [Iteration and Live Preview](#9-iteration-and-live-preview)
10. [Modification Rules (After Go-Live)](#10-modification-rules-after-go-live)
11. [Known Issues and Workarounds](#11-known-issues-and-workarounds)
12. [Detailed Troubleshooting Guide](#12-detailed-troubleshooting-guide)
13. [SA Decision Checklist](#13-sa-decision-checklist)
14. [Quick Reference](#14-quick-reference)

---

## 1. Why This Matters

Agentforce is conversational by default. A user types, the agent responds in text. That works for the majority of use cases. But enterprise workflows often demand more: dropdowns with validated values, structured data entry forms, and rich output cards displaying multi-field results, all without leaving the agent conversation window.

**Custom Lightning Types (CLTs)** are the answer. They let you render Lightning Web Components (LWCs) directly inside the Agentforce experience for input collection and output display. As an SA, you should understand CLTs because:

- They are the bridge between a client's brand standards and agent conversations.
- They unlock complex enterprise workflows (multi-field forms, conditional inputs) that pure text cannot handle reliably.
- They are the foundation of the **Headless Experience Layer** (announced TDX 2026), which extends agentic UI to Slack, ChatGPT, and beyond under the principle "Define Once, Deploy Anywhere, Secure Everywhere." Building CLTs today positions clients for that future.
- They work in both supervised and handoff multi-agent orchestration modes (MOMA/SOMA).

---

## 2. Concept Overview: Standard vs. Custom Lightning Types

| | Standard Lightning Types | Custom Lightning Types (CLTs) |
|---|---|---|
| **Setup** | Zero config; Salesforce provides ready-to-use components | Requires Apex class, LWC, and a Lightning Type Bundle |
| **Use case** | Simple text, dates, numbers, lists | Complex forms, branded cards, conditional inputs |
| **Override scope** | Not overridable | Full override of input (editor) and/or output (renderer) |
| **Backed by** | Platform primitives (`lightning__textType`, `lightning__dateType`, etc.) | Apex class (`@apexClassType`) or JSON schema (object-based) |
| **Deployment** | N/A | `LightningTypeBundle` metadata type |

**When to recommend CLTs:**
- The agent action accepts a complex Apex class as input (e.g., a filter object with multiple fields).
- The action output is a complex data structure that benefits from visual formatting (cards, tables, status badges).
- The client has branding requirements that plain text cannot satisfy.
- The workflow requires validated user input before submission.

---

## 3. The Three-Layer Architecture

Understanding this stack is essential for scoping and troubleshooting.

```
┌──────────────────────────────────────────────────────────┐
│  LAYER 1: Agent Script                                   │
│  Declares which action parameters use custom UI          │
│  (complex_data_type_name: "c__myInputType")              │
├──────────────────────────────────────────────────────────┤
│  LAYER 2: Lightning Type Bundle                          │
│  schema.json  ->  maps Apex class to a Lightning type    │
│  editor.json  ->  which LWC to render for input          │
│  renderer.json -> which LWC to render for output         │
├──────────────────────────────────────────────────────────┤
│  LAYER 3: LWC Components                                 │
│  Editor LWC   ->  collects user input in the chat        │
│  Renderer LWC ->  displays action output in the chat     │
└──────────────────────────────────────────────────────────┘
```

Each layer has one job. Naming alignment across all three is what makes the system work (see Section 7).

---

## 4. Supported Channels and Surfaces

You must target the correct channel folder inside your `LightningTypeBundle` to override the UI for a specific Salesforce application.

| Salesforce Application | Channel Folder | Notes |
|---|---|---|
| Agentforce Employee Agent (Lightning Experience) | `lightningDesktopGenAi` | Desktop; generally the most reliable target for both input and output CLTs |
| Agentforce Service Agent (Enhanced Chat v2) | `enhancedWebChat` | Output CLTs render reliably. **Input CLTs on Enhanced Chat v2 have a known history of not rendering** -- verify current behavior in your org before committing to an input-CLT design for a Service Agent build |
| Agentforce Employee Agent (Mobile iOS/Android) | `lightningMobileGenAi` | Mobile rendering can differ from desktop -- record context and layout should be retested on-device, not assumed from desktop QA |
| Agentforce Service Agent (Enhanced Chat v2 Mobile) | `lightningMobileGenAi` | Same mobile caveats apply |
| Experience Builder | `experienceBuilder` | `renderer.json` is NOT supported here. CLT rendering for customer-facing/headless surfaces generally requires an active Enhanced Chat v2 connection -- it typically cannot be fully previewed inside Agentforce Builder alone |
| Prompt Builder | *(separate setup)* | CLTs can structure Prompt Template output |
| Flows via Structured Outputs | *(separate setup)* | CLTs can structure Flow output |

**SA tip -- preview before you build:** Recent Agentforce Builder releases have added the ability to preview Service Agent CLT rendering against a live Enhanced Chat v2 connection during design, not just after publish. Confirm what is available in your release and use it early.

**SA tip -- multi-agent reuse:** If a client plans to reuse a CLT-backed action across agents (e.g., exposing a Service Agent action as a connected sub-agent inside an Employee Agent), test rendering explicitly in that reused context. CLTs that work standalone have been observed to stop rendering once reused as part of a different agent's action set.

---

## 5. Build Path: Step-by-Step

### 5.1 Design the Apex Data Shape

Every CLT backed by an Apex class requires a class that defines the data structure. This is the single source of truth for the schema.

**Key requirements:**
- Define every class as a **top-level class** (no inner/nested classes for the CLT schema).
- Mark all classes as **`global`** (not `public`; this is critical for namespaced orgs and managed packages).
- Annotate every field with **`@AuraEnabled`** AND **`@InvocableVariable`**.
- Annotate every class with **`@JsonAccess(serializable='always' deserializable='always')`**.
- Use the `c` namespace prefix for local orgs; use the registered namespace for managed packages.

```apex
@JsonAccess(serializable='always' deserializable='always')
global class CaseInput {
    @AuraEnabled
    @InvocableVariable(label='Subject' required=true)
    public String subject;

    @AuraEnabled
    @InvocableVariable(label='Priority')
    public String priority;

    @AuraEnabled
    @InvocableVariable(label='Case Description')
    public String caseDescription; // NOTE: 'description' is a reserved @InvocableVariable keyword
}
```

> **Warning:** The words `model`, `description`, and `label` are **reserved** and cannot be used as `@InvocableVariable` field names. They pass Apex compilation cleanly and only cause a failure during agent compilation, which makes them easy to miss in code review. Use alternatives like `caseDescription`, `vehicle_model`, or `label_text`.

**Supported data types in Lightning Types:**
- Primitives: `Integer`, `Double`, `Long`, `Date`, `Datetime`, `Time`, `String`, `ID`, `Boolean`
- sObjects (generic or specific)
- Collections: `List` of primitives, sObjects, or user-defined classes; `Map<String, value>`
- User-defined Apex classes

---

### 5.2 Build the LWC Components

You need up to two LWC components per CLT: one **editor** (input) and one **renderer** (output).

#### Editor LWC (Input)

The editor collects user input inside the agent conversation. Two requirements make it work with Agentforce:

1. The `js-meta.xml` must target `lightning__AgentforceInput` with a `targetType` matching the CLT name.
2. The component must dispatch a `valuechange` event whenever the user modifies the form.

```xml
<!-- caseInputEditor.js-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>64.0</apiVersion>
    <isExposed>true</isExposed>
    <masterLabel>Case Input Editor</masterLabel>
    <targets>
        <target>lightning__AgentforceInput</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__AgentforceInput">
            <targetType name="c__caseInput"/>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

```javascript
// caseInputEditor.js
import { LightningElement, api } from 'lwc';

export default class CaseInputEditor extends LightningElement {
    // The @api value property does NOT support pre-population from the agent.
    // Use it ONLY to capture user input.
    @api value;

    handleChange(event) {
        this.dispatchEvent(
            new CustomEvent('valuechange', {
                detail: {
                    value: { subject: event.detail.value },
                    validity: event.target.checkValidity()
                }
            })
        );
    }
}
```

> **Important:** The `@api value` property on editor LWCs does **not** support data injection from agent context. The agent cannot pre-populate form fields. Data is returned to the agent action only when the user submits their response.

#### Renderer LWC (Output)

The renderer displays action results as a rich card. It targets `lightning__AgentforceOutput` with a `sourceType` (not `targetType`) matching the CLT name. The component receives the full result object via `@api value`.

```xml
<!-- caseResultRenderer.js-meta.xml -->
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>64.0</apiVersion>
    <isExposed>true</isExposed>
    <masterLabel>Case Result Renderer</masterLabel>
    <targets>
        <target>lightning__AgentforceOutput</target>
    </targets>
</LightningComponentBundle>
```

```javascript
// caseResultRenderer.js
import { LightningElement, api } from 'lwc';

export default class CaseResultRenderer extends LightningElement {
    @api value; // Receives the full output object: { caseNumber, status, ... }

    get caseNumber() { return this.value?.caseNumber; }
    get status() { return this.value?.status; }
}
```

---

### 5.3 Create the Lightning Type Bundle

The `LightningTypeBundle` is a folder in your DX project under `force-app/main/default/lightningTypes/`. It contains the configuration files that wire everything together.

**Folder structure:**
```
force-app/main/default/lightningTypes/
    caseInput/
        schema.json
        lightningDesktopGenAi/
            editor.json
    caseResult/
        schema.json
        lightningDesktopGenAi/
            renderer.json
```

**schema.json (Apex-backed):**
```json
{
    "title": "Case Input",
    "lightning:type": "@apexClassType/c__CaseInput"
}
```

**editor.json (top-level override):**
```json
{
    "editor": {
        "componentOverrides": {
            "$": { "definition": "c/caseInputEditor" }
        }
    }
}
```
> The `"$"` key means "override the entire type." Use a property name (e.g., `"subject"`) as the key to override only a specific field.

**renderer.json (top-level override):**
```json
{
    "renderer": {
        "componentOverrides": {
            "$": { "definition": "c/caseResultRenderer" }
        }
    }
}
```

**Attribute Mapping** - If your LWC property names differ from the Apex class field names, use `{!$attrs.PropertyName}` to map them:
```json
{
    "editor": {
        "componentOverrides": {
            "$": {
                "definition": "c/existingComponent",
                "attrs": {
                    "urgency": "{!$attrs.priorityLevel}"
                }
            }
        }
    }
}
```

---

### 5.4 Register the Agent Action (GenAiFunction)

The `GenAiFunction` metadata registers the action with Agentforce and is required for CLT bindings to resolve. Create a file in `genAiFunctions/`.

**GenAiFunction XML:**
```xml
<GenAiFunction xmlns="http://soap.sforce.com/2006/04/metadata">
    <developerName>Submit_Case</developerName>
    <invocationTarget>CaseSubmissionService</invocationTarget>
    <invocationTargetType>apex</invocationTargetType>
    <masterLabel>Submit Case</masterLabel>
</GenAiFunction>
```

**Input schema JSON** (alongside the XML, in `genAiFunctions/Submit_Case/`):
```json
{
    "properties": {
        "case_data": {
            "lightning:type": "c__caseInput",
            "copilotAction:isUserInput": true
        }
    }
}
```

**Output schema JSON:**
```json
{
    "properties": {
        "case_result": {
            "lightning:type": "c__caseResult",
            "copilotAction:isDisplayable": true
        }
    }
}
```

---

### 5.5 Wire the CLT in Agent Script

In your Agent Script, declare the action with `complex_data_type_name` pointing to your CLT.

```yaml
subagent case_submission:
    description: "Collects and submits a new support case"

    actions:
        submit_case:
            description: "Opens a case intake form and submits the case"
            target: "apex://CaseSubmissionService"
            inputs:
                case_data: object
                    complex_data_type_name: "c__caseInput"
                    is_user_input: true
            outputs:
                case_result: object
                    complex_data_type_name: "c__caseResult"
                    filter_from_agent: false

    reasoning:
        instructions: |
            Help the user submit a new support case.
        actions:
            collect_case: @actions.submit_case
                set @variables.result = @outputs.case_result
```

---

### 5.6 Connect the CLT to the Agent Action in Setup

After deployment, wire the CLT in the Agent Action UI:

1. Open **Agentforce Studio** > **Agent Actions**.
2. Open the target action (e.g., "Submit Case").
3. For the action's **input**, edit the **Input Rendering** parameter and select your CLT (`c__caseInput`).
4. For the action's **output**, edit the **Output Rendering** parameter and select your CLT (`c__caseResult`).
5. Save the action.

> **Note:** An "Unsupported Data Type" message may appear in the "Map to Variable" parameter when you select a CLT for the Output Rendering parameter. This is a known UI cosmetic issue and does not affect functionality. It can be safely ignored.

---

## 6. Object-Based vs. Apex-Based CLTs

You have two approaches to define the data structure for a CLT.

| | Apex-Based | Object-Based |
|---|---|---|
| **Schema source** | Apex class with `@AuraEnabled` fields | JSON schema defined entirely in `schema.json` |
| **Best for** | Actions already backed by Apex; complex business logic | Lightweight UI overrides; no Apex required |
| **Schema maintenance** | Schema auto-projects from the Apex class | Managed manually in JSON |
| **Modification risk** | Class renames/deletions break the CLT | Governed by the object-based modification rules |
| **Recommended when** | You control the Apex class | Prompt Builder, Flow structured outputs, Experience Builder overrides |

**Object-based schema example:**
```json
{
    "title": "Flight Filter",
    "description": "Filter criteria for available flights",
    "lightning:type": "lightning__objectType",
    "properties": {
        "maxPrice": {
            "title": "Maximum Price",
            "lightning:type": "lightning__numberType",
            "minimum": 100,
            "maximum": 20000
        },
        "allowPets": {
            "title": "Allow Pets",
            "lightning:type": "lightning__booleanType"
        }
    },
    "required": ["maxPrice"]
}
```

---

## 7. Naming Alignment: The Critical Rule

**The #1 cause of CLT failures is naming misalignment across layers.** A mismatch causes a silent fallback to the default text UI with no error message. Always verify these four alignment points:

| What | Where It Lives | Must Match |
|---|---|---|
| Apex field names | `@AuraEnabled @InvocableVariable` fields | Agent Script `inputs:` / `outputs:` parameter names (case-sensitive) |
| CLT name in `schema.json` | `lightning:type` value (e.g., `@apexClassType/c__CaseInput`) | Class name with `c__` prefix |
| CLT name in `editor.json` / `renderer.json` | `"definition": "c/myComponent"` | LWC component name |
| CLT name in Agent Script | `complex_data_type_name: "c__caseInput"` | Schema folder name and `targetType` in LWC meta XML |

### A second alignment point: `complex_data_type_name` must resolve to a real, specific type

A common source of commit/publish failures is leaving `complex_data_type_name` set to the generic placeholder `lightning__objectType` instead of a concrete type. Salesforce's validation increasingly rejects the generic placeholder and expects a specific standard or Apex-based type.

**Common patterns observed in the field, with the typical fix:**

| Scenario | Placeholder used | Typical correct value |
|---|---|---|
| Output is a record reference (e.g., a booking, case, or session record) | `lightning__objectType` | `lightning__recordInfoType` |
| Input is a plain Salesforce record ID field | `lightning__recordInfoType` | `lightning__recordIdType` |
| Output references a custom Apex wrapper (inner) class | LWC/type-bundle name (e.g., `c__myRenderer`) | `@apexClassType/<OuterClass>$<InnerClass>` -- reference the **Apex class**, not the rendering component |
| Output is rich/long text from a prompt or generation action | plain `object` | `object` type with `complex_data_type_name: "lightning__richTextType"` |
| Simple string / boolean values (baseline, for contrast) | -- | `lightning__textType` (strings), `lightning__booleanType` (booleans) |
| Apex-based custom output/input types (general case) | `lightning__objectType` | `@apexClassType/<YourApexClassName>` |

**Rule of thumb for SAs:** don't try to memorize every mapping. When a commit or publish fails, Salesforce's validation error typically names the exact replacement type to use. Read it and apply that value rather than guessing from the field's apparent purpose. Record ID vs. record info types, for example, sound similar but are not interchangeable, and the platform's suggestion is usually correct.

---

## 8. Deployment

### Package Manifest

Deploy `LightningTypeBundle` using Salesforce CLI or Metadata API.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>caseInput</members>
        <members>caseResult</members>
        <name>LightningTypeBundle</name>
    </types>
    <types>
        <members>CaseSubmissionService</members>
        <name>ApexClass</name>
    </types>
    <types>
        <members>caseInputEditor</members>
        <members>caseResultRenderer</members>
        <name>LightningComponentBundle</name>
    </types>
    <version>64.0</version>
</Package>
```

### CLI Commands

```bash
# Deploy the full CLT stack
sf project deploy start --manifest package.xml -o <org-alias>

# Verify Lightning Type Bundle registered in Setup
# From Setup: Quick Find > Lightning Types
# Check the "Source" column to distinguish Custom from Standard types

# Publish the agent after wiring
sf agent publish authoring-bundle --json --api-name MyAgent -o <org-alias>
```

### Deployment Order

Follow this order to avoid dependency failures:

1. Deploy Apex classes (data shape + invocable service)
2. Deploy LWC components (editor and renderer)
3. Deploy LightningTypeBundle (schema + UI config)
4. Deploy GenAiFunction (agent action registration)
5. Deploy Agent Script (references CLT via `complex_data_type_name`)
6. Wire CLT to Agent Action in Setup UI (Input/Output Rendering)
7. Publish the agent

> **Note:** VS Code "Push/Pull" source tracking does NOT support `AiAuthoringBundle`. Always use `sf project deploy start` and `sf agent publish authoring-bundle` directly.

---

## 9. Iteration and Live Preview

For rapid iteration on editor and renderer LWC components without deploying to an org, use the **Salesforce Live Preview** VS Code extension.

**Three ways to open a component in Live Preview:**

1. **IDE Context Menu:** In VS Code Explorer, right-click the `editor.json` or `renderer.json` file and select **SFDX: Open in Lightning Preview**.
2. **Command Palette:** Open Command Palette, search for `SFDX: Open in Lightning Preview`.
3. **Agentforce Vibes (AI Assistant):** Instruct Agentforce Vibes to preview a component; it opens the Lightning Preview panel automatically after updating code.

Live Preview refreshes automatically on file save, allowing fast design iteration without leaving VS Code.

---

## 10. Modification Rules (After Go-Live)

Once a CLT is referenced by a live agent action, changes are governed. Communicate these rules to clients before they make post-launch modifications.

### Apex-Based CLTs

| Change Type | Allowed? | Impact |
|---|---|---|
| Add new `@AuraEnabled` fields | Yes | Schema projection picks up changes automatically |
| Rename or delete the Apex class | **No** | Causes runtime failures |
| Change a field's data type (e.g., Integer to String) | **No** | Breaking change |
| Remove an `@AuraEnabled` field used by an action | **No** | Causes invocation errors |
| Downgrade class visibility (global to public in managed package) | **No** | Breaks external references |

### Object-Based CLTs

| Keyword | Allowed? |
|---|---|
| `title`, `description` | Yes, freely |
| `lightning:type` | **No** |
| Adding new optional properties | Yes |
| Removing or renaming existing properties | **No** |
| Adding a new required property | **No** |
| Making a required property optional | Yes |
| Increasing `maximum` / `maxLength` | Yes |
| Decreasing `maximum` / `maxLength` | **No** |

---

## 11. Known Issues and Workarounds

| Issue | Status | Details |
|---|---|---|
| **CLT rendering can break during Agentforce runtime/planner upgrades** | Active area, evolving with releases | Salesforce's agent reasoning and planning runtime has gone through active architectural changes. During these transitions, CLTs have been observed to stop rendering because the runtime did not correctly trigger the UI display step. If a previously-working CLT stops rendering after a platform release, check whether a runtime/planner upgrade coincided with the change, and re-verify the naming-alignment checklist and rendering wiring rather than assuming a config regression on your side. |
| **Generic `lightning__objectType` placeholder rejected at commit** | Common / by design | Validation increasingly requires a concrete type rather than the generic placeholder. See the type-mapping table in Section 7. |
| **Input CLTs on Service Agent + Enhanced Chat v2** | Documented limitation, evolving | Input CLTs have a history of not rendering on Enhanced Chat v2, while output CLTs render reliably. Confirm current-release behavior and use in-Builder preview against a live connection before committing to design. |
| **"Unsupported Data Type" message in Setup** | Cosmetic | Can appear when selecting a CLT for Output Rendering on an action. Does not affect saved configuration and is safe to ignore. |
| **Silent fallback to text UI** | By design | Any naming misalignment between Apex fields, CLT schema, and Agent Script causes a silent fallback with no error thrown. Always verify the four alignment points in Section 7 first. |
| **`renderer.json` not supported in Experience Builder** | By design | Output rendering overrides are not available in the `experienceBuilder` channel; input overrides (`editor.json`) are supported. |
| **`@api value` on editor LWC cannot be pre-populated** | By design | The agent cannot inject conversational context or default values into editor LWC inputs; data flows one direction, from user input back to the agent. |
| **Input captured in UI but not received by the action** | Can occur; worth ruling out platform-side | If an input CLT visibly captures data correctly but the bound action receives empty parameters, this can be a platform-side deserialization issue rather than a component or Apex mistake -- especially if the naming-alignment checklist and `valuechange` event wiring both check out. Worth an official support case rather than extended self-debugging. |
| **CLT reuse breaks across sub-agent boundaries** | Observed pattern | Reusing a CLT-backed action as a connected sub-agent inside a different parent agent can cause the CLT to stop rendering, even when it works standalone. Retest explicitly after any agent restructuring. |

---

## 12. Detailed Troubleshooting Guide

### Step 1 -- CLT not rendering at all (falls back to plain text)

1. Check the four naming-alignment points in Section 7 first. This is the most common cause and produces no error message.
2. Check whether this is a Service Agent + Enhanced Chat v2 **input** CLT. This combination has a known rendering gap. Use an in-Builder preview against a live connection to confirm current behavior rather than assuming parity with Employee Agent/desktop.
3. Check for a recent platform release or runtime upgrade around the time rendering broke. If so, re-verify the display/render trigger and CLT wiring rather than assuming your configuration regressed.
4. If it is on mobile specifically, retest record context and layout directly on-device. Do not assume desktop-verified behavior carries over.

### Step 2 -- Commit/publish fails with a `complex_data_type_name` validation error

1. **Read the exact error text.** Salesforce's validation errors for this issue are typically formatted as: *"...update the 'complex_data_type_name' attribute value for the [input/output] parameter '\<name\>' from '\<current type\>' to '\<suggested type\>'."*
2. **Apply the suggested type as given.** Don't guess based on the field's apparent purpose. Record ID vs. record info types sound similar but are not interchangeable, and the platform's suggestion is usually correct.
3. **Watch for a misleading identical-looking suggestion.** For Apex-backed list outputs (`list[object]`), the error can appear to suggest the same type on both sides. In that case, the real fix is often changing the **declared field type** from `object` to `list[object]` while keeping `complex_data_type_name` unchanged. Read carefully rather than pattern-matching the string alone.
4. If the type references an Apex inner/wrapper class, use `@apexClassType/<OuterClass>$<InnerClass>` syntax. Referencing the LWC or type-bundle name directly instead of the Apex class will fail validation.
5. For `list[object]` outputs, ensure the generated schema defines `items.properties` with concrete fields. A bare generic type with no defined shape can cause a hard failure at commit or publish time (field-observed pattern; validate against your release).

### Step 3 -- Apex compiles successfully but agent compilation fails

- Check reserved `@InvocableVariable` field names first: `model`, `description`, `label`. These pass Apex compilation cleanly and only fail during agent compilation, making them easy to miss during code review.

### Step 4 -- Input CLT renders and captures data, but the action receives empty parameters

- If the naming-alignment checklist and the `valuechange` event wiring both look correct, this can indicate a platform-side deserialization issue rather than a build mistake. Log an official support case with reproduction steps rather than extensively re-debugging the component code.

### Step 5 -- CLT worked standalone, breaks after being reused in a different agent context

- Re-verify CLT rendering after any change that moves a CLT-backed action into a different agent's context (for example, exposing it as a connected sub-agent). This is a recurring field-observed pattern, not a one-off. Build explicit CLT rendering verification into your test plan whenever multi-agent reuse is part of the design.

### General Troubleshooting Principles

- Prefer reading exact platform error/validation messages over guessing at type mappings.
- Re-test on every target channel (desktop, Service Agent chat, mobile) independently. Parity across channels should never be assumed.
- Treat "renders standalone but breaks on reuse" and "captures input but action gets nothing" as platform-level patterns worth escalating through official support, not purely local debugging problems.
- Revisit known-issue status periodically. Agentforce's runtime and Builder tooling are under active development, and behavior in this space changes across releases.

---

## 13. SA Decision Checklist

Use this checklist during client discovery and design sessions.

### Discovery
- [ ] Does the client's agent action accept a complex Apex class as input? If yes, CLT is likely needed.
- [ ] Does the action output a complex data structure that benefits from visual formatting? If yes, renderer CLT adds value.
- [ ] Does the client have brand standards that require custom UI in the agent window?
- [ ] Which channels does the agent serve (Lightning Experience, Enhanced Chat v2, Mobile, Experience Builder)?
- [ ] Is this a Service Agent on Enhanced Chat v2? If yes, flag the input CLT rendering limitation early and confirm current behavior in a target org before designing around input CLTs.
- [ ] Does the client plan to reuse CLT-backed actions across agents (e.g., as connected sub-agents)? If yes, add explicit CLT rendering verification to the test plan for each reuse context.
- [ ] Is the client planning to extend to Slack or third-party surfaces in the future? If yes, start with CLTs now for Headless Experience Layer readiness.

### Architecture
- [ ] Is the Apex class structured with `global` visibility, `@AuraEnabled`, `@InvocableVariable`, and `@JsonAccess`?
- [ ] Are reserved field names (`model`, `description`, `label`) avoided in `@InvocableVariable` declarations?
- [ ] Is the CLT approach Apex-based or object-based? (See Section 6 for guidance.)
- [ ] Has the naming alignment checklist (Section 7) been reviewed across all four layers?
- [ ] Is `complex_data_type_name` set to a concrete, specific type (not the generic `lightning__objectType` placeholder)?
- [ ] Is there a separate editor and renderer LWC planned for each CLT?

### Deployment
- [ ] Is the `LightningTypeBundle` included in the package manifest?
- [ ] Is deployment order documented (Apex -> LWC -> LightningTypeBundle -> GenAiFunction -> Agent Script -> Setup wiring -> Publish)?
- [ ] Has the client been briefed on post-go-live modification restrictions?
- [ ] Is Live Preview set up in the developer's VS Code environment for rapid iteration?

### Known Issues
- [ ] Has the client been informed about input CLT rendering limitations on Enhanced Chat v2?
- [ ] Has the client been informed that platform/runtime upgrades can temporarily affect CLT rendering, and that the naming-alignment checklist is the first place to look when this happens?
- [ ] Is there a fallback plan (text-based responses) if CLT rendering is unavailable in a given context?

---

## 14. Quick Reference

### LWC Target Summary

| Use Case | LWC `js-meta.xml` Target | JSON Config File |
|---|---|---|
| Custom input editor (full override) | `lightning__AgentforceInput` | `editor.json` with `"$"` key |
| Custom input editor (property-level) | `lightning__PropertyEditor` | `editor.json` with property name key |
| Custom output renderer | `lightning__AgentforceOutput` | `renderer.json` |

### Standard Lightning Types Reference

| Lightning Type | Use For | Supports Mobile? |
|---|---|---|
| `lightning__textType` | Short text (up to 255 chars) | Yes |
| `lightning__multilineTextType` | Long text inputs | Yes |
| `lightning__richTextType` | Rich text (up to 100k chars) | Yes |
| `lightning__numberType` | Numeric input | Yes |
| `lightning__dateType` | Date picker | Yes |
| `lightning__booleanType` | Checkbox | Yes |
| `lightning__listType` | Lists / arrays | Yes |
| `lightning__objectType` | Complex grouped objects | Yes |
| `lightning__recordInfoType` | Salesforce record references | Yes |

### Key CLI Commands

```bash
# Deploy LightningTypeBundle
sf project deploy start --manifest package.xml -o <org-alias>

# Verify deployment
sf project deploy report

# Retrieve agent metadata
sf project retrieve start --json -m AiAuthoringBundle:MyAgent -o <org-alias>

# Publish agent
sf agent publish authoring-bundle --json --api-name MyAgent -o <org-alias>

# Check Lightning Types in Setup
# Setup > Quick Find > "Lightning Types"
```

### Apex Class Checklist

```apex
@JsonAccess(serializable='always' deserializable='always')
global class MyInputType {
    @AuraEnabled
    @InvocableVariable(label='Field Label' required=true)
    public String myField; // NOT: description, label, model (reserved)
}
```

---

