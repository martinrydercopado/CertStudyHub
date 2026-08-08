import SwiftUI

// MARK: - Quiz Length

struct QuizLength: Identifiable {
    let id: Int
    let label: String
    let icon: String
    let subtitle: String
    let duration: String
    /// Optional range of question IDs (Int) to pull from. When nil, pulls from all questions.
    let questionIDRange: ClosedRange<Int>?

    init(id: Int, label: String, icon: String, subtitle: String, duration: String, questionIDRange: ClosedRange<Int>? = nil) {
        self.id = id
        self.label = label
        self.icon = icon
        self.subtitle = subtitle
        self.duration = duration
        self.questionIDRange = questionIDRange
    }
}

// MARK: - Certification Configuration

struct CertConfig: Identifiable {
    let id: String
    let name: String
    let shortName: String
    let icon: String
    let primaryColor: Color
    let secondaryColor: Color
    let headerGradient: [Color]
    let passingScore: Int
    let quizLengths: [QuizLength]
    let questions: [Question]
    let studySections: [StudySection]
    let storageKeyPrefix: String
    /// When true, this is a bonus study topic — not an official Salesforce certification.
    let isBonusTopic: Bool
    /// Optional subtitle shown on the cert card (e.g. "Bonus Topic").
    let subtitle: String?

    init(id: String, name: String, shortName: String, icon: String,
         primaryColor: Color, secondaryColor: Color, headerGradient: [Color],
         passingScore: Int, quizLengths: [QuizLength], questions: [Question],
         studySections: [StudySection], storageKeyPrefix: String,
         isBonusTopic: Bool = false, subtitle: String? = nil) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.icon = icon
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.headerGradient = headerGradient
        self.passingScore = passingScore
        self.quizLengths = quizLengths
        self.questions = questions
        self.studySections = studySections
        self.storageKeyPrefix = storageKeyPrefix
        self.isBonusTopic = isBonusTopic
        self.subtitle = subtitle
    }

    var questionCount: Int { questions.count }

    var topicCount: Int {
        studySections.reduce(0) { $0 + $1.totalTopics }
    }
}
