import Foundation
import SwiftUI

// MARK: - Topic Status

enum TopicStatus: String, Codable, CaseIterable {
    case notStarted = "not_started"
    case needsReview = "needs_review"
    case confident = "confident"

    var label: String {
        switch self {
        case .notStarted: return "Not Started"
        case .needsReview: return "Needs Review"
        case .confident: return "Confident"
        }
    }

    var icon: String {
        switch self {
        case .notStarted: return "circle"
        case .needsReview: return "exclamationmark.triangle.fill"
        case .confident: return "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .notStarted: return .gray
        case .needsReview: return .orange
        case .confident: return .green
        }
    }
}

// MARK: - Study Topic

struct StudyTopic: Identifiable, Codable, Hashable {
    let id: String
    let number: Int
    let question: String
    let answer: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: StudyTopic, rhs: StudyTopic) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Study Objective

struct StudyObjective: Identifiable {
    let id: String
    let title: String
    let topics: [StudyTopic]
}

// MARK: - Study Section

struct StudySection: Identifiable {
    let id: String
    let title: String
    let color: Color
    let lightColor: Color
    let icon: String
    let objectives: [StudyObjective]

    var totalTopics: Int {
        objectives.reduce(0) { $0 + $1.topics.count }
    }
}
