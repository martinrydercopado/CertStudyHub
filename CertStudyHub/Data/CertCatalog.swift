import SwiftUI

enum CertCatalog {
    // ── Deep Dives ──
    static let deepDives: [CertConfig] = [
        agentSurfaces,
        agentforceCoworker,
        consultBestPractices,
        agentforceDiscovery,
        agentforceHelpAgent,
        tracinganalytics,
        agentOps,
        agentOpsCopado,
        customLWC,
        determinism,
        dc360DevOps,
        dc360GroundUp,
        humanInTheLoop,
        reasoningEngine,
        multiagent,
        rag,
        salesforceKnowledge,
        agentforceArchitect,
        hybridReasoning,
        adlcIDE
    ]

    // ── Certifications ──
    static let certifications: [CertConfig] = [
        agentforce,
        dataCloud360,
        agentforceSales,
        agentforceService,
        businessAnalyst,
        pdlda,
        admin2,
        platformAppBuilder,
        dataArchitect,
        platformDev1,
        platformIntegrationArchitect,
        sharingVisibility,
        uxDesigner
    ]

    static let all: [CertConfig] = deepDives + certifications

    // ── Deep Dive Definitions ──

    static let agentSurfaces = CertConfig(
        id: "agentsurfaces",
        name: "Agentforce Agent Surfaces",
        shortName: "Agent Surfaces",
        icon: "rectangle.stack.fill",
        primaryColor: Color(red: 0.15, green: 0.55, blue: 0.82),
        secondaryColor: Color(red: 0.25, green: 0.70, blue: 0.95),
        headerGradient: [
            Color(red: 0.08, green: 0.32, blue: 0.52),
            Color(red: 0.10, green: 0.38, blue: 0.62),
            Color(red: 0.15, green: 0.55, blue: 0.82)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "agentsurfaces",
        isBonusTopic: true,
        subtitle: "A complete guide to every deployment channel where Agentforce agents can live. Covers web, mobile, Slack, APIs, and portal surfaces with setup details and trade-offs.",
        guideFile: "agentsurfaces"
    )

    static let agentforceHelpAgent = CertConfig(
        id: "agentforcehelpagent",
        name: "Agentforce Help Agent: Outcome-Based Pricing",
        shortName: "Help Agent",
        icon: "questionmark.circle.fill",
        primaryColor: Color(red: 0.20, green: 0.60, blue: 0.40),
        secondaryColor: Color(red: 0.30, green: 0.78, blue: 0.55),
        headerGradient: [
            Color(red: 0.10, green: 0.36, blue: 0.24),
            Color(red: 0.14, green: 0.44, blue: 0.30),
            Color(red: 0.20, green: 0.60, blue: 0.40)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "agentforcehelpagent",
        isBonusTopic: true,
        subtitle: "Covers the prepackaged Help Agent's fast setup, outcome-based pricing model, and reimagined Customer Service Portal. Honest assessment of where it delivers and where current limitations apply.",
        guideFile: "agentforcehelpagent"
    )

    static let determinism = CertConfig(
        id: "determinism",
        name: "Determining the Right Level of Determinism for Agentforce",
        shortName: "Determinism",
        icon: "slider.horizontal.3",
        primaryColor: Color(red: 0.55, green: 0.25, blue: 0.60),
        secondaryColor: Color(red: 0.72, green: 0.40, blue: 0.78),
        headerGradient: [
            Color(red: 0.33, green: 0.13, blue: 0.36),
            Color(red: 0.40, green: 0.17, blue: 0.44),
            Color(red: 0.55, green: 0.25, blue: 0.60)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "determinism",
        isBonusTopic: true,
        subtitle: "Navigate the spectrum from fully autonomous to fully deterministic agents. Covers the six official determinism levels, Agent Script controls, and diagnosing unreliable behavior.",
        guideFile: "determinism"
    )

    static let dc360GroundUp = CertConfig(
        id: "dc360groundup",
        name: "Data 360 from the Ground Up: The NTO Story",
        shortName: "NTO Story",
        icon: "globe.americas.fill",
        primaryColor: Color(red: 0.02, green: 0.53, blue: 0.62),
        secondaryColor: Color(red: 0.13, green: 0.73, blue: 0.83),
        headerGradient: [
            Color(red: 0.01, green: 0.30, blue: 0.36),
            Color(red: 0.02, green: 0.36, blue: 0.43),
            Color(red: 0.02, green: 0.53, blue: 0.62)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "dc360groundup",
        isBonusTopic: true,
        subtitle: "Follow NTO's enterprise architect through a complete Data 360 implementation — from data profiling and harmonization through identity resolution, segmentation, and activation.",
        guideFile: "dc360groundup"
    )

    static let hybridReasoning = CertConfig(
        id: "hybridreasoning",
        name: "The Hybrid Reasoning Chronicles (an Agent Script Story)",
        shortName: "Hybrid Reasoning",
        icon: "book.fill",
        primaryColor: Color(red: 0.49, green: 0.23, blue: 0.93),
        secondaryColor: Color(red: 0.55, green: 0.36, blue: 0.96),
        headerGradient: [
            Color(red: 0.30, green: 0.11, blue: 0.58),
            Color(red: 0.36, green: 0.13, blue: 0.71),
            Color(red: 0.49, green: 0.23, blue: 0.93)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "hybridreasoning",
        isBonusTopic: true,
        subtitle: "A Phoenix Project-style story about building Agentforce agents with Agent Script. Follow an architect team as they decompose a failing monolithic agent into a reliable multi-agent system.",
        guideFile: "hybridreasoning"
    )

    static let adlcIDE = CertConfig(
        id: "adlcide",
        name: "The ADLC in an IDE: An Educational CLI Guide",
        shortName: "ADLC in an IDE",
        icon: "desktopcomputer",
        primaryColor: Color(red: 0.23, green: 0.51, blue: 0.96),
        secondaryColor: Color(red: 0.38, green: 0.65, blue: 0.98),
        headerGradient: [
            Color(red: 0.12, green: 0.23, blue: 0.37),
            Color(red: 0.12, green: 0.29, blue: 0.46),
            Color(red: 0.12, green: 0.35, blue: 0.55)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "adlcide",
        isBonusTopic: true,
        subtitle: "A guided walkthrough of the entire Agent Development Lifecycle using only the CLI. Covers every ADLC phase from agent spec generation through deployment, activation, and production monitoring.",
        guideFile: "adlcide"
    )

    static let consultBestPractices = CertConfig(
        id: "consultbestpractices",
        name: "Consultation Best Practices for the Agentforce Success Architect",
        shortName: "Consultation Best Practices",
        icon: "person.2.fill",
        primaryColor: Color(red: 0.96, green: 0.62, blue: 0.04),
        secondaryColor: Color(red: 0.98, green: 0.75, blue: 0.14),
        headerGradient: [
            Color(red: 0.57, green: 0.25, blue: 0.05),
            Color(red: 0.63, green: 0.38, blue: 0.03),
            Color(red: 0.71, green: 0.33, blue: 0.04)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "consultbestpractices",
        isBonusTopic: true,
        subtitle: "A field-tested playbook for Success Architects covering the trusted advisor mindset, strategic discovery, stakeholder management, executive communication, and consultative authority in Agentforce engagements.",
        guideFile: "consultbestpractices"
    )

    static let agentOpsCopado = CertConfig(
        id: "agentopscopado",
        name: "AgentOps with Copado: A Success Architect's Guide",
        shortName: "AgentOps with Copado",
        icon: "arrow.triangle.2.circlepath",
        primaryColor: Color(red: 0.06, green: 0.73, blue: 0.51),
        secondaryColor: Color(red: 0.20, green: 0.83, blue: 0.60),
        headerGradient: [
            Color(red: 0.02, green: 0.31, blue: 0.23),
            Color(red: 0.02, green: 0.37, blue: 0.27),
            Color(red: 0.02, green: 0.47, blue: 0.34)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "agentopscopado",
        isBonusTopic: true,
        subtitle: "A comprehensive guide to running AgentOps through Copado's Agentia Pro pipeline. Covers metadata tracking, source control, AI-assisted development, Agent Script in the pipeline, and multi-agent orchestration (SOMA).",
        guideFile: "agentopscopado"
    )

    static let agentforceArchitect = CertConfig(
        id: "agentforcearchitect",
        name: "The Agentforce Architect: A Design and Planning Guide",
        shortName: "Agentforce Architect",
        icon: "building.columns.fill",
        primaryColor: Color(red: 0.15, green: 0.39, blue: 0.92),
        secondaryColor: Color(red: 0.23, green: 0.51, blue: 0.96),
        headerGradient: [
            Color(red: 0.12, green: 0.23, blue: 0.54),
            Color(red: 0.12, green: 0.25, blue: 0.69),
            Color(red: 0.15, green: 0.39, blue: 0.92)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "agentforcearchitect",
        isBonusTopic: true,
        subtitle: "The complete agent development lifecycle — from ideation and design through deployment, monitoring, and tuning. Covers the architect's role, hybrid reasoning boundaries, and human-in-the-loop design.",
        guideFile: "agentforcearchitect"
    )

    static let customLWC = CertConfig(
        id: "customlwc",
        name: "Custom Lightning Components in Agentforce Agents",
        shortName: "Custom LWC",
        icon: "bolt.fill",
        primaryColor: Color(red: 0.49, green: 0.23, blue: 0.93),
        secondaryColor: Color(red: 0.55, green: 0.36, blue: 0.96),
        headerGradient: [
            Color(red: 0.30, green: 0.11, blue: 0.58),
            Color(red: 0.36, green: 0.13, blue: 0.71),
            Color(red: 0.49, green: 0.23, blue: 0.93)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "customlwc",
        isBonusTopic: true,
        subtitle: "Build rich, branded agent experiences with Custom Lightning Types. Covers the three-layer architecture, LWC component design, and wiring custom UI into Agent Script actions.",
        guideFile: "customlwc"
    )

    static let agentforceCoworker = CertConfig(
        id: "agentforcecoworker",
        name: "Agentforce Coworker: A Success Architect's Guide",
        shortName: "Agentforce Coworker",
        icon: "person.2.fill",
        primaryColor: Color(red: 0.03, green: 0.57, blue: 0.70),
        secondaryColor: Color(red: 0.13, green: 0.83, blue: 0.93),
        headerGradient: [
            Color(red: 0.09, green: 0.31, blue: 0.39),
            Color(red: 0.08, green: 0.37, blue: 0.46),
            Color(red: 0.03, green: 0.57, blue: 0.70)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "agentforcecoworker",
        isBonusTopic: true,
        subtitle: "Understand Agentforce Coworker's three usage modes, multi-surface reach, and how it differs from bespoke custom agents. Covers eligibility, governance, and real-world scenarios.",
        guideFile: "agentforcecoworker"
    )

    static let agentforceDiscovery = CertConfig(
        id: "agentforcediscovery",
        name: "Agentforce Discovery & Requirements Gathering Guide",
        shortName: "Discovery & Reqs",
        icon: "magnifyingglass.circle.fill",
        primaryColor: Color(red: 0.80, green: 0.45, blue: 0.10),
        secondaryColor: Color(red: 0.95, green: 0.60, blue: 0.25),
        headerGradient: [
            Color(red: 0.48, green: 0.27, blue: 0.06),
            Color(red: 0.58, green: 0.33, blue: 0.08),
            Color(red: 0.80, green: 0.45, blue: 0.10)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "agentforcediscovery",
        isBonusTopic: true,
        subtitle: "A field guide for running structured discovery workshops with Agentforce customers. Covers the consultative mindset shift, question frameworks, and translating business pain into buildable agent specs.",
        guideFile: "agentforcediscovery"
    )

    static let dc360DevOps = CertConfig(
        id: "dc360devops",
        name: "Data 360 DevOps",
        shortName: "Data 360 DevOps",
        icon: "wrench.and.screwdriver",
        primaryColor: Color(red: 0.05, green: 0.58, blue: 0.53),
        secondaryColor: Color(red: 0.18, green: 0.83, blue: 0.75),
        headerGradient: [
            Color(red: 0.07, green: 0.31, blue: 0.29),
            Color(red: 0.07, green: 0.37, blue: 0.35),
            Color(red: 0.05, green: 0.58, blue: 0.53)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "dc360devops",
        isBonusTopic: true,
        subtitle: "Where traditional Salesforce DevOps breaks down for Data 360. Covers change management challenges, platform-managed components, and a practical ALM strategy for data cloud projects.",
        guideFile: "dc360devops"
    )

    static let salesforceKnowledge = CertConfig(
        id: "salesforceknowledge",
        name: "Salesforce Knowledge: The Architect's Guide to Knowledge-Grounded Agents",
        shortName: "SF Knowledge",
        icon: "books.vertical.fill",
        primaryColor: Color(red: 0.60, green: 0.35, blue: 0.15),
        secondaryColor: Color(red: 0.78, green: 0.50, blue: 0.25),
        headerGradient: [
            Color(red: 0.36, green: 0.20, blue: 0.08),
            Color(red: 0.44, green: 0.25, blue: 0.10),
            Color(red: 0.60, green: 0.35, blue: 0.15)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "salesforceknowledge",
        isBonusTopic: true,
        subtitle: "Set up Lightning Knowledge as the default grounding source for Agentforce agents. Covers data categories, data libraries, citations, multimodal grounding, and governance for vector stores.",
        guideFile: "salesforceknowledge"
    )

    static let humanInTheLoop = CertConfig(
        id: "humanintheloop",
        name: "Human-in-the-Loop Patterns for Agentforce Agents",
        shortName: "Human-in-the-Loop",
        icon: "person.crop.circle.badge.checkmark",
        primaryColor: Color(red: 0.70, green: 0.30, blue: 0.55),
        secondaryColor: Color(red: 0.85, green: 0.45, blue: 0.70),
        headerGradient: [
            Color(red: 0.42, green: 0.15, blue: 0.33),
            Color(red: 0.50, green: 0.20, blue: 0.40),
            Color(red: 0.70, green: 0.30, blue: 0.55)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "humanintheloop",
        isBonusTopic: true,
        subtitle: "Design trustworthy agent autonomy with deliberate human checkpoints. Covers approval, input, and escalation patterns with implementation guidance for each Agentforce building block.",
        guideFile: "humanintheloop"
    )

    // ── Certification Definitions ──

    static let agentforce = CertConfig(
        id: "agentforce",
        name: "Agentforce Specialist",
        shortName: "Agentforce",
        icon: "brain.head.profile.fill",
        primaryColor: .indigo,
        secondaryColor: .blue,
        headerGradient: [
            Color(red: 0.24, green: 0.20, blue: 0.56),
            Color(red: 0.22, green: 0.27, blue: 0.58),
            Color(red: 0.18, green: 0.32, blue: 0.60)
        ],
        passingScore: 72,
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Full Exam Simulation", duration: "~30 min"),
            QuizLength(id: 72, label: "Flashcards", icon: "rectangle.on.rectangle.angled.fill", subtitle: "Exam Prep — Likely on Exam", duration: "72 Qs", questionIDRange: 1...72)
        ],
        questions: AgentforceQuestionBank.all,
        studySections: AgentforceStudyBank.sections,
        storageKeyPrefix: "agentforce"
    )

    static let agentOps = CertConfig(
        id: "agentops",
        name: "AgentOps: Agentforce Lifecycle",
        shortName: "AgentOps",
        icon: "gearshape.arrow.triangle.2.circlepath",
        primaryColor: Color(red: 0.85, green: 0.45, blue: 0.20),
        secondaryColor: .orange,
        headerGradient: [
            Color(red: 0.58, green: 0.26, blue: 0.08),
            Color(red: 0.54, green: 0.28, blue: 0.12),
            Color(red: 0.50, green: 0.30, blue: 0.16)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "agentops",
        isBonusTopic: true,
        subtitle: "The complete Agentforce lifecycle for consultants — from Agent Script and execution phases to multi-agent orchestration, security, and the Einstein Trust Layer.",
        guideFile: "agentops"
    )

    static let dataCloud360 = CertConfig(
        id: "dc360",
        name: "Data 360 Consultant",
        shortName: "Data 360",
        icon: "cloud.fill",
        primaryColor: .teal,
        secondaryColor: .cyan,
        headerGradient: [
            Color(red: 0.0, green: 0.30, blue: 0.42),
            Color(red: 0.0, green: 0.35, blue: 0.48),
            Color(red: 0.02, green: 0.40, blue: 0.52)
        ],
        passingScore: 62,
        quizLengths: [
            QuizLength(id: 10, label: "10 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~5 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Exam Simulation", duration: "~30 min"),
            QuizLength(id: 427, label: "All 427 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~214 min")
        ],
        questions: DataCloud360QuestionBank.all,
        studySections: DataCloud360StudyBank.sections,
        storageKeyPrefix: "dc360"
    )

    static let reasoningEngine = CertConfig(
        id: "reasoningengine",
        name: "Inside the Atlas Reasoning Engine",
        shortName: "Atlas",
        icon: "cpu.fill",
        primaryColor: Color(red: 0.40, green: 0.20, blue: 0.60),
        secondaryColor: .purple,
        headerGradient: [
            Color(red: 0.28, green: 0.10, blue: 0.48),
            Color(red: 0.32, green: 0.14, blue: 0.52),
            Color(red: 0.36, green: 0.18, blue: 0.56)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "reasoningengine",
        isBonusTopic: true,
        subtitle: "Deep dive into how Atlas works — the two-phase execution engine, deterministic resolution vs. LLM reasoning, and the Agent Graph. Covers Agentforce Builder authoring and runtime configuration.",
        guideFile: "reasoningengine"
    )

    static let rag = CertConfig(
        id: "rag",
        name: "RAG, Agentforce & Data 360",
        shortName: "RAG",
        icon: "doc.text.magnifyingglass",
        primaryColor: Color(red: 0.20, green: 0.45, blue: 0.70),
        secondaryColor: .blue,
        headerGradient: [
            Color(red: 0.12, green: 0.30, blue: 0.52),
            Color(red: 0.16, green: 0.34, blue: 0.56),
            Color(red: 0.20, green: 0.38, blue: 0.60)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "rag",
        isBonusTopic: true,
        subtitle: "How Agentforce thinks, retrieves, and grounds answers using RAG and Data 360. Covers the Atlas hybrid engine, data libraries, retrieval tuning, and governing grounded agents in production.",
        guideFile: "rag"
    )

    static let agentforceSales = CertConfig(
        id: "agentforcesales",
        name: "Agentforce Sales Consultant",
        shortName: "Sales Consultant",
        icon: "briefcase.fill",
        primaryColor: Color(red: 0.18, green: 0.53, blue: 0.67),
        secondaryColor: .cyan,
        headerGradient: [
            Color(red: 0.10, green: 0.36, blue: 0.48),
            Color(red: 0.12, green: 0.40, blue: 0.53),
            Color(red: 0.14, green: 0.44, blue: 0.56)
        ],
        passingScore: 65,
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Exam Simulation", duration: "~30 min"),
            QuizLength(id: 126, label: "All 126 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~63 min")
        ],
        questions: AgentforceSalesQuestionBank.all,
        studySections: AgentforceSalesStudyBank.sections,
        storageKeyPrefix: "agentforcesales"
    )

    static let agentforceService = CertConfig(
        id: "agentforceservice",
        name: "Agentforce Service Consultant",
        shortName: "Service Consultant",
        icon: "headphones.circle.fill",
        primaryColor: Color(red: 0.35, green: 0.62, blue: 0.44),
        secondaryColor: .green,
        headerGradient: [
            Color(red: 0.18, green: 0.42, blue: 0.26),
            Color(red: 0.20, green: 0.46, blue: 0.30),
            Color(red: 0.22, green: 0.50, blue: 0.34)
        ],
        passingScore: 65,
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Exam Simulation", duration: "~30 min"),
            QuizLength(id: 125, label: "All 125 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~63 min")
        ],
        questions: AgentforceServiceQuestionBank.all,
        studySections: AgentforceServiceStudyBank.sections,
        storageKeyPrefix: "agentforceservice"
    )

    static let businessAnalyst = CertConfig(
        id: "ba",
        name: "Business Analyst",
        shortName: "BA",
        icon: "chart.bar.doc.horizontal.fill",
        primaryColor: Color(red: 0.20, green: 0.60, blue: 0.86),
        secondaryColor: .cyan,
        headerGradient: [
            Color(red: 0.10, green: 0.35, blue: 0.58),
            Color(red: 0.12, green: 0.40, blue: 0.62),
            Color(red: 0.14, green: 0.45, blue: 0.66)
        ],
        passingScore: 72,
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Exam Simulation", duration: "~30 min"),
            QuizLength(id: 148, label: "All 148 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~74 min")
        ],
        questions: BAQuestionBank.all,
        studySections: BAStudyBank.sections,
        storageKeyPrefix: "ba"
    )

    static let pdlda = CertConfig(
        id: "pdlda",
        name: "Development Lifecycle & Deployment Architect",
        shortName: "PDLDA",
        icon: "shippingbox.fill",
        primaryColor: .purple,
        secondaryColor: .pink,
        headerGradient: [
            Color(red: 0.30, green: 0.10, blue: 0.40),
            Color(red: 0.34, green: 0.14, blue: 0.36),
            Color(red: 0.38, green: 0.18, blue: 0.32)
        ],
        passingScore: 65,
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Exam Simulation", duration: "~30 min"),
            QuizLength(id: 100, label: "All 100 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~50 min")
        ],
        questions: PDLDAQuestionBank.all,
        studySections: PDLDAStudyBank.sections,
        storageKeyPrefix: "pdlda"
    )

    static let admin2 = CertConfig(
        id: "admin2",
        name: "Platform Administrator II",
        shortName: "Admin II",
        icon: "wrench.and.screwdriver.fill",
        primaryColor: Color(red: 0.55, green: 0.36, blue: 0.96),
        secondaryColor: Color(red: 0.66, green: 0.55, blue: 0.98),
        headerGradient: [
            Color(red: 0.36, green: 0.23, blue: 0.60),
            Color(red: 0.40, green: 0.27, blue: 0.60),
            Color(red: 0.44, green: 0.31, blue: 0.60)
        ],
        passingScore: 60,
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Exam Simulation", duration: "~30 min"),
            QuizLength(id: 122, label: "All 122 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~61 min")
        ],
        questions: Admin2QuestionBank.all,
        studySections: Admin2StudyBank.sections,
        storageKeyPrefix: "admin2"
    )

    static let platformAppBuilder = CertConfig(
        id: "appbuilder",
        name: "Platform App Builder",
        shortName: "App Builder",
        icon: "hammer.fill",
        primaryColor: .green,
        secondaryColor: .mint,
        headerGradient: [
            Color(red: 0.08, green: 0.38, blue: 0.18),
            Color(red: 0.06, green: 0.34, blue: 0.26),
            Color(red: 0.04, green: 0.30, blue: 0.34)
        ],
        passingScore: 63,
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Exam Simulation", duration: "~30 min"),
            QuizLength(id: 100, label: "All 100 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~50 min")
        ],
        questions: AppBuilderQuestionBank.all,
        studySections: AppBuilderStudyBank.sections,
        storageKeyPrefix: "appbuilder"
    )

    static let dataArchitect = CertConfig(
        id: "dataarchitect",
        name: "Platform Data Architect",
        shortName: "Data Architect",
        icon: "cylinder.split.1x2.fill",
        primaryColor: Color(red: 0.03, green: 0.57, blue: 0.70),
        secondaryColor: .cyan,
        headerGradient: [
            Color(red: 0.02, green: 0.37, blue: 0.46),
            Color(red: 0.03, green: 0.41, blue: 0.54),
            Color(red: 0.04, green: 0.45, blue: 0.62)
        ],
        passingScore: 58,
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Exam Simulation", duration: "~30 min"),
            QuizLength(id: 120, label: "All 120 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~60 min")
        ],
        questions: DataArchitectQuestionBank.all,
        studySections: DataArchitectStudyBank.sections,
        storageKeyPrefix: "dataarchitect"
    )

    static let platformDev1 = CertConfig(
        id: "pd1",
        name: "Platform Developer I",
        shortName: "PD1",
        icon: "chevron.left.forwardslash.chevron.right",
        primaryColor: .orange,
        secondaryColor: .red,
        headerGradient: [
            Color(red: 0.55, green: 0.22, blue: 0.05),
            Color(red: 0.50, green: 0.18, blue: 0.10),
            Color(red: 0.45, green: 0.15, blue: 0.15)
        ],
        passingScore: 65,
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Exam Simulation", duration: "~30 min"),
            QuizLength(id: 100, label: "All 100 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~50 min")
        ],
        questions: PD1QuestionBank.all,
        studySections: PD1StudyBank.sections,
        storageKeyPrefix: "pd1"
    )

    static let platformIntegrationArchitect = CertConfig(
        id: "pia",
        name: "Platform Integration Architect",
        shortName: "PIA",
        icon: "point.3.connected.trianglepath.dotted",
        primaryColor: Color(red: 0.17, green: 0.63, blue: 0.45),
        secondaryColor: .mint,
        headerGradient: [
            Color(red: 0.08, green: 0.38, blue: 0.28),
            Color(red: 0.10, green: 0.42, blue: 0.32),
            Color(red: 0.12, green: 0.46, blue: 0.36)
        ],
        passingScore: 62,
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Exam Simulation", duration: "~30 min"),
            QuizLength(id: 154, label: "All 154 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~77 min")
        ],
        questions: PIAQuestionBank.all,
        studySections: PIAStudyBank.sections,
        storageKeyPrefix: "pia"
    )

    static let sharingVisibility = CertConfig(
        id: "sharingvisibility",
        name: "Platform Sharing and Visibility Architect",
        shortName: "Sharing & Visibility",
        icon: "lock.shield.fill",
        primaryColor: Color(red: 0.86, green: 0.15, blue: 0.15),
        secondaryColor: Color(red: 0.97, green: 0.44, blue: 0.44),
        headerGradient: [
            Color(red: 0.55, green: 0.10, blue: 0.10),
            Color(red: 0.58, green: 0.14, blue: 0.14),
            Color(red: 0.62, green: 0.18, blue: 0.18)
        ],
        passingScore: 62,
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Exam Simulation", duration: "~30 min"),
            QuizLength(id: 120, label: "All 120 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~60 min")
        ],
        questions: SharingVisibilityQuestionBank.all,
        studySections: SharingVisibilityStudyBank.sections,
        storageKeyPrefix: "sharingvisibility"
    )

    static let multiagent = CertConfig(
        id: "multiagent",
        name: "Multi-Agent Architecture in Agentforce",
        shortName: "Multi-Agent",
        icon: "square.3.layers.3d.top.filled",
        primaryColor: Color(red: 0.20, green: 0.40, blue: 0.70),
        secondaryColor: .blue,
        headerGradient: [
            Color(red: 0.12, green: 0.28, blue: 0.52),
            Color(red: 0.15, green: 0.32, blue: 0.56),
            Color(red: 0.18, green: 0.36, blue: 0.60)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "multiagent",
        isBonusTopic: true,
        subtitle: "Architect multi-agent systems across SOMA, MOMA, and third-party streams. Covers the Supervisor pattern, deterministic routing with Agent Script, and building superagent networks.",
        guideFile: "multiagent"
    )

    static let tracinganalytics = CertConfig(
        id: "tracinganalytics",
        name: "Agentforce Tracing and Analytics",
        shortName: "Tracing & Analytics",
        icon: "chart.bar.doc.horizontal.fill",
        primaryColor: Color(red: 0.10, green: 0.50, blue: 0.55),
        secondaryColor: .teal,
        headerGradient: [
            Color(red: 0.06, green: 0.34, blue: 0.38),
            Color(red: 0.08, green: 0.38, blue: 0.42),
            Color(red: 0.10, green: 0.42, blue: 0.46)
        ],
        passingScore: 70,
        quizLengths: [],
        questions: [],
        studySections: [],
        storageKeyPrefix: "tracinganalytics",
        isBonusTopic: true,
        subtitle: "Master Agentforce observability — session tracing, agent platform tracing, and dashboards. Covers common diagnostic patterns and the triage-before-you-trace methodology.",
        guideFile: "tracinganalytics"
    )

    static let uxDesigner = CertConfig(
        id: "uxdesigner",
        name: "Platform User Experience Designer",
        shortName: "UX Designer",
        icon: "paintbrush.fill",
        primaryColor: Color(red: 0.85, green: 0.28, blue: 0.94),
        secondaryColor: Color(red: 0.91, green: 0.47, blue: 0.98),
        headerGradient: [
            Color(red: 0.55, green: 0.18, blue: 0.60),
            Color(red: 0.58, green: 0.22, blue: 0.62),
            Color(red: 0.62, green: 0.26, blue: 0.64)
        ],
        passingScore: 65,
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Exam Simulation", duration: "~30 min"),
            QuizLength(id: 121, label: "All 121 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~61 min")
        ],
        questions: UXDesignerQuestionBank.all,
        studySections: UXDesignerStudyBank.sections,
        storageKeyPrefix: "uxdesigner"
    )
}
