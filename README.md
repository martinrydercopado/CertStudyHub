# Cert Study Hub

A native SwiftUI app (iPhone + Mac) and a companion web app for studying Salesforce certifications. Includes quiz mode with multiple-choice questions, a topic-by-topic study guide, and hosted reference guides for bonus certifications.

**Live web app:** [martinrydercopado.github.io/CertStudyHub](https://martinrydercopado.github.io/CertStudyHub/)

## Certifications

| Certification | Questions | Study Topics | Passing | Guide |
|---|:---:|:---:|:---:|:---:|
| Agentforce Specialist | 135 | 218 | 72% | |
| Data 360 Consultant | 427 | 167 | 62% | |
| Business Analyst | 138 | 141 | 72% | |
| Platform Developer I | 100 | 198 | 65% | |
| Platform App Builder | 100 | 361 | 63% | |
| Dev Lifecycle & Deployment Architect | 100 | 133 | 65% | |
| Platform Integration Architect | 154 | 170 | 62% | |
| Agentforce Sales Consultant | — | 154 | 65% | |
| Agentforce Service Consultant | — | 302 | 65% | |
| Platform Administrator II | — | 201 | 60% | |
| Platform Data Architect | — | 129 | 58% | |
| Platform Sharing & Visibility Architect | — | 186 | 62% | |
| Platform UX Designer | — | 151 | 65% | |
| **Bonus** | | | | |
| Inside Daisy: Reasoning Engine | 39 | 56 | 70% | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=reasoningengine) |
| RAG, Agentforce & Data 360 | 72 | 100 | 70% | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=rag) |
| AgentOps: Agentforce Lifecycle | 50 | 191 | 70% | [View](https://martinrydercopado.github.io/CertStudyHub/guides/viewer.html?guide=agentops) |
| Success Architect Scenarios | — | — | 70% | |

**Totals:** 1,406 questions and 2,858 study topics across 17 tracks.

## Features

- **Quiz Mode** — Configurable quiz lengths (10, 25, 50, or full), instant feedback with explanations, score tracking, and a "For Review" list of flagged questions
- **Study Guide** — Browse topics grouped by exam section and objective, track which you've studied, and filter to "Needs Review" items
- **Reference Guides** — In-depth markdown study guides for bonus certs, rendered client-side with a persistent sidebar TOC on desktop
- **Progress Tracking** — Per-certification progress saved locally (UserDefaults on native, localStorage on web)
- **Cross-Platform** — One SwiftUI codebase targets both iPhone and Mac; the web app works in any browser

## Repo Structure

```
CertStudyHub/              SwiftUI app source
  Data/                    Question banks and study banks (Swift enums)
  Models/                  Question, StudySection, StudyTopic, CertConfig
  ViewModels/              QuizViewModel, StudyViewModel
  Views/                   Quiz views, Study views, navigation
  CertStudyHubApp.swift    App entry point

CertStudyHub.xcodeproj/    Xcode project

docs/                      GitHub Pages web app
  index.html               SPA shell
  js/app.js                App logic (vanilla JS, no framework)
  data/
    certs.json             Certification catalog
    questions.json         All question banks
    study.json             All study topic banks
  guides/
    viewer.html            Markdown guide viewer (marked.js)
    reasoningengine.md     Reasoning Engine study guide
    rag.md                 RAG study guide
    agentops.md            AgentOps study guide
    marked.min.js          Vendored marked.js v15.0.4
```

## Building

**Native app (Xcode 16+, iOS 17+ / macOS 14+):**

Open `CertStudyHub.xcodeproj` and build for your target device.

**Web app:**

No build step — open `docs/index.html` locally or deploy the `docs/` folder to any static host. GitHub Pages serves it automatically from the `main` branch.

## Changelog

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
- Add Success Architect Scenarios bonus track (Agentforce + Data 360 scenario questions)
- Add AgentOps cert content: 19 new quiz questions and Section 5 study topics

### 2025-08-01
- Initial commit — Agentforce Specialist and Data 360 Consultant with quiz + study guide
