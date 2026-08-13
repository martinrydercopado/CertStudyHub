import SwiftUI

enum CertCatalog {
    static let all: [CertConfig] = [
        agentforce,
        agentOps,
        dataCloud360,
        reasoningEngine,
        rag,
        successArchitect,
        businessAnalyst,
        pdlda,
        platformAppBuilder,
        platformDev1,
        platformIntegrationArchitect
    ]

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
            QuizLength(id: 212, label: "All 212 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~106 min")
        ],
        questions: DataCloud360QuestionBank.all,
        studySections: DataCloud360StudyBank.sections,
        storageKeyPrefix: "dc360"
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
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 25, label: "25 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 50, label: "All 50 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~30 min")
        ],
        questions: AgentOpsQuestionBank.all,
        studySections: AgentOpsStudyBank.sections,
        storageKeyPrefix: "agentops",
        isBonusTopic: true,
        subtitle: "Bonus Topic — Not an official Salesforce certification"
    )

    static let reasoningEngine = CertConfig(
        id: "reasoningengine",
        name: "Inside Daisy: The Agentforce Reasoning Engine",
        shortName: "Daisy",
        icon: "cpu.fill",
        primaryColor: Color(red: 0.40, green: 0.20, blue: 0.60),
        secondaryColor: .purple,
        headerGradient: [
            Color(red: 0.28, green: 0.10, blue: 0.48),
            Color(red: 0.32, green: 0.14, blue: 0.52),
            Color(red: 0.36, green: 0.18, blue: 0.56)
        ],
        passingScore: 70,
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 39, label: "All 39 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~20 min")
        ],
        questions: ReasoningEngineQuestionBank.all,
        studySections: ReasoningEngineStudyBank.sections,
        storageKeyPrefix: "reasoningengine",
        isBonusTopic: true,
        subtitle: "Bonus Topic — Not an official Salesforce certification"
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
        quizLengths: [
            QuizLength(id: 15, label: "15 Questions", icon: "bolt.fill", subtitle: "Quick Review", duration: "~8 min"),
            QuizLength(id: 30, label: "30 Questions", icon: "flame.fill", subtitle: "Standard Practice", duration: "~15 min"),
            QuizLength(id: 60, label: "60 Questions", icon: "trophy.fill", subtitle: "Exam Simulation", duration: "~30 min"),
            QuizLength(id: 72, label: "All 72 Questions", icon: "star.fill", subtitle: "Full Question Bank", duration: "~36 min")
        ],
        questions: RAGQuestionBank.all,
        studySections: RAGStudyBank.sections,
        storageKeyPrefix: "rag",
        isBonusTopic: true,
        subtitle: "Bonus Topic — Not an official Salesforce certification"
    )

    static let successArchitect = CertConfig(
        id: "successarchitect",
        name: "Success Architect Scenarios",
        shortName: "SA Scenarios",
        icon: "person.badge.shield.checkmark.fill",
        primaryColor: Color(red: 0.60, green: 0.20, blue: 0.20),
        secondaryColor: Color(red: 0.80, green: 0.30, blue: 0.30),
        headerGradient: [
            Color(red: 0.45, green: 0.12, blue: 0.12),
            Color(red: 0.50, green: 0.16, blue: 0.14),
            Color(red: 0.55, green: 0.20, blue: 0.16)
        ],
        passingScore: 70,
        quizLengths: [
            QuizLength(id: 45, label: "Agentforce", icon: "brain.head.profile.fill", subtitle: "45 Scenario Questions", duration: "~25 min", questionIDRange: 1...45),
            QuizLength(id: 91, label: "Data 360", icon: "cloud.fill", subtitle: "46 Scenario Questions", duration: "~25 min", questionIDRange: 46...91)
        ],
        questions: SuccessArchitectAgentforceQuestionBank.all + SuccessArchitectData360QuestionBank.all,
        studySections: [],
        storageKeyPrefix: "successarchitect",
        isBonusTopic: true,
        subtitle: "Bonus Track — Real-world scenario practice"
    )
}
