# Cert Study Hub

A native SwiftUI app (iPhone + Mac) and a companion web app for studying Salesforce certifications. Includes quiz mode with multiple-choice questions, topic-by-topic study guides, and in-depth reference guides for deep dive topics.

**Live web app:** [martinrydercopado.github.io/CertStudyHub](https://martinrydercopado.github.io/CertStudyHub/)

## Certifications

| Certification | Questions | Study Topics | Passing |
|---|:---:|:---:|:---:|
| Agentforce Specialist | 135 | 218 | 72% |
| Data 360 Consultant | 427 | 167 | 62% |
| Agentforce Sales Consultant | 126 | 154 | 65% |
| Agentforce Service Consultant | 125 | 302 | 65% |
| Business Analyst | 148 | 141 | 72% |
| Dev Lifecycle & Deployment Architect | 100 | 133 | 65% |
| Platform Administrator II | 122 | 201 | 60% |
| Platform App Builder | 100 | 361 | 63% |
| Platform Data Architect | 120 | 129 | 58% |
| Platform Developer I | 100 | 198 | 65% |
| Platform Integration Architect | 154 | 170 | 62% |
| Platform Sharing & Visibility Architect | 120 | 186 | 62% |
| Platform UX Designer | 121 | 151 | 65% |

## Deep Dives

Reference-guide-only tracks — no quizzes, no study topics. Each links to a full markdown study guide rendered in-app and on the web.

| Deep Dive | Quiz | Guide |
|---|:---:|:---:|
| Agentforce Agent Surfaces | — | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=agentsurfaces) |
| Agentforce Coworker | — | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=agentforcecoworker) |
| Agentforce Discovery & Requirements Gathering | — | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=agentforcediscovery) |
| Agentforce Help Agent: Outcome-Based Pricing | — | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=agentforcehelpagent) |
| AgentOps: Agentforce Lifecycle | 50 | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=agentops) |
| Custom Lightning Components in Agentforce | — | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=customlwc) |
| Data 360 DevOps | — | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=dc360devops) |
| Data 360 from the Ground Up: The NTO Story | — | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=dc360groundup) |
| Determining the Right Level of Determinism | — | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=determinism) |
| Human-in-the-Loop Patterns | — | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=humanintheloop) |
| Inside the Atlas Reasoning Engine | 44 | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=reasoningengine) |
| Multi-Agent Architecture in Agentforce | 70 | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=multiagent) |
| RAG, Agentforce & Data 360 | 77 | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=rag) |
| Salesforce Knowledge: Knowledge-Grounded Agents | — | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=salesforceknowledge) |
| The Agentforce Architect | — | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=agentforcearchitect) |
| The Hybrid Reasoning Chronicles | — | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=hybridreasoning) |
| Tracing and Analytics in Agentforce | 77 | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=tracinganalytics) |

**Totals:** 2,206 questions and 2,511 study topics across 30 tracks (13 certifications + 17 deep dives).

## Features

- **Quiz Mode** — Configurable quiz lengths (10, 15, 25, 30, 50, 60, or full bank), instant feedback with explanations, score tracking, and a "For Review" list of flagged questions
- **Study Guide** — Browse topics grouped by exam section and objective, track which you've studied, and filter to "Needs Review" items
- **Reference Guides** — In-depth markdown study guides for all 17 deep dive topics, rendered client-side with a persistent sidebar TOC on desktop and bundled offline in the native app
- **Progress Tracking** — Per-certification progress saved locally (UserDefaults on native, localStorage on web)
- **Cross-Platform** — One SwiftUI codebase targets both iPhone and Mac; the web app works in any browser

## Repo Structure

```
CertStudyHub/              SwiftUI app source
  Data/                    Question banks, study banks, CertCatalog (Swift)
  Models/                  Question, StudySection, StudyTopic, CertConfig
  ViewModels/              QuizViewModel, StudyViewModel
  Views/                   Quiz views, Study views, ReferenceGuideView
  Guides/                  17 bundled .md reference guides + marked.min.js
  CertStudyHubApp.swift    App entry point

CertStudyHub.xcodeproj/    Xcode project (iOS + macOS targets)

docs/                      GitHub Pages web app
  index.html               SPA shell
  js/app.js                App logic (vanilla JS, no framework)
  data/
    certs.json             Certification + deep dive catalog
    questions.json         All question banks
    study.json             All study topic banks
  guides/
    viewer.html            Markdown guide viewer (marked.js)
    *.md                   17 reference guide markdown files
    marked.min.js          Vendored marked.js v15.0.4
```

## Building

**Native app (Xcode 16+, iOS 17+ / macOS 14+):**

Open `CertStudyHub.xcodeproj` and build for your target device.

**Web app:**

No build step — open `docs/index.html` locally or deploy the `docs/` folder to any static host. GitHub Pages serves it automatically from the `main` branch.

## Changelog

### 2025-08-24
- Add Agentforce Discovery & Requirements Gathering deep dive (17th deep dive)
- Add Determining the Right Level of Determinism deep dive
- Add Salesforce Knowledge and Agentforce Help Agent deep dives
- Add Agentforce Agent Surfaces and Human-in-the-Loop Patterns deep dives
- Add Agentforce Coworker, Custom LWC, Data 360 DevOps, Data 360 NTO Story, Agentforce Architect, and Hybrid Reasoning deep dives
- Remove quizzes from 5 deep dives (now reference-guide-only)
- Add Multi-Agent Architecture and Tracing & Analytics deep dives with 70 and 77 practice questions
- Restructure app: certifications and deep dives are now separate sections

### 2025-08-17
- Add 120 practice questions for Platform Sharing & Visibility Architect (quiz mode now available)
- Add 126 practice questions for Agentforce Sales Consultant (quiz mode now available)

### 2025-08-16
- Add 125 practice questions for Agentforce Service Consultant certification (quiz mode now available)
- Fix remaining invalid escape sequences in Swift question banks
- Fix TOC anchor navigation in reference guide viewer for all three guides

### 2025-08-15
- Add 122 practice questions for Platform Administrator II certification (quiz mode now available)
- Add 120 practice questions for Platform Data Architect certification (quiz mode now available)
- Add 5 new practice questions for RAG, Agentforce & Data 360 bonus cert (72 → 77)
- Add 5 new practice questions for Inside Daisy: Reasoning Engine bonus cert (39 → 44)
- Add 121 practice questions for Platform UX Designer certification (quiz mode now available)

### 2025-08-14
- Add 6 new study-only certifications: Agentforce Sales Consultant, Agentforce Service Consultant, Platform Administrator II, Platform Data Architect, Platform Sharing & Visibility Architect, Platform UX Designer
- Reorder front page to user-specified 17-cert sequence
- Support study-only certs (no quiz tab) in both web and native apps
- Update all three bonus cert reference guides (AgentOps v2, Reasoning Engine Enhanced v2, RAG v5)
- Add 200 Data 360 Consultant questions from co-ti question bank (227 → 427 total)
- Remove mobile TOC from reference guide viewer (content-only on small screens; desktop sidebar persists)

### 2025-08-13
- Redesign guide viewer with persistent left sidebar TOC and scroll-spy on desktop
- Add hosted reference guides for Reasoning Engine, RAG, and AgentOps bonus certs
- Fix 345 build errors in ReasoningEngineStudyBank and RAGStudyBank (wrong constructor signatures)
- Replace Reasoning Engine quiz and study guide with revised v2/v4 content
- Add Reasoning Engine and RAG bonus certifications; rename Agentforce AI Specialist to Agentforce Specialist

### 2025-08-11
- Fix expiration banner: iOS-only, correct countdown, handle expired state

### 2025-08-10
- Fix PD1 Q23 correct answer and explanation letter references
- Fix SA Data 360 Q4, Q15, Q23, Q26, Q28 answer keys and explanations
- Replace 8 quiz banks with rebalanced answer-distribution versions
- Fix BA Q48 correct answer and Q66/Q48 explanation references

### 2025-08-09
- Add Business Analyst and Platform Integration Architect certifications (native + web)
- Reorder certification list to user-specified sequence

### 2025-08-06
- Add GitHub Pages web app — full quiz and study guide in the browser

### 2025-08-05
- Add AgentOps cert content: 19 new quiz questions and Section 5 study topics

### 2025-08-01
- Initial commit — Agentforce Specialist and Data 360 Consultant with quiz + study guide
