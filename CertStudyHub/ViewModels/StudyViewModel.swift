import Foundation
import SwiftUI

@Observable
final class StudyViewModel {
    // MARK: – Configuration
    let certConfig: CertConfig

    // MARK: – Data
    let sections: [StudySection]

    // MARK: – Persisted State
    private(set) var topicStatuses: [String: TopicStatus] = [:]

    // MARK: – Navigation State
    enum Screen: Equatable {
        case home
        case objectives(sectionIndex: Int)
        case topic(sectionIndex: Int, objectiveIndex: Int, topicIndex: Int)
        case needsReview
    }

    private(set) var screen: Screen = .home
    var isAnswerRevealed: Bool = false

    // MARK: – Persistence
    private let storageKey: String

    // MARK: – Init
    init(certConfig: CertConfig) {
        self.certConfig = certConfig
        self.sections = certConfig.studySections
        self.storageKey = "\(certConfig.storageKeyPrefix)StudyTopicStatuses"
        loadProgress()
    }

    // MARK: – Section Accessors
    func section(at index: Int) -> StudySection {
        sections[index]
    }

    var currentSection: StudySection? {
        switch screen {
        case .objectives(let si), .topic(let si, _, _):
            return sections[si]
        default:
            return nil
        }
    }

    var currentObjective: StudyObjective? {
        switch screen {
        case .topic(let si, let oi, _):
            return sections[si].objectives[oi]
        default:
            return nil
        }
    }

    var currentTopic: StudyTopic? {
        switch screen {
        case .topic(let si, let oi, let ti):
            let topics = sections[si].objectives[oi].topics
            guard ti < topics.count else { return nil }
            return topics[ti]
        default:
            return nil
        }
    }

    var currentTopicIndex: Int {
        switch screen {
        case .topic(_, _, let ti): return ti
        default: return 0
        }
    }

    var currentTopicCount: Int {
        switch screen {
        case .topic(let si, let oi, _):
            return sections[si].objectives[oi].topics.count
        default:
            return 0
        }
    }

    // MARK: – Status
    func statusFor(_ topic: StudyTopic) -> TopicStatus {
        topicStatuses[topic.id] ?? .notStarted
    }

    func setStatus(_ status: TopicStatus, for topic: StudyTopic) {
        topicStatuses[topic.id] = status
        saveProgress()
    }

    // MARK: – Progress
    func confidentCount(for section: StudySection) -> Int {
        section.objectives.flatMap(\.topics).filter { statusFor($0) == .confident }.count
    }

    func confidentCount(for objective: StudyObjective) -> Int {
        objective.topics.filter { statusFor($0) == .confident }.count
    }

    func reviewCount(for objective: StudyObjective) -> Int {
        objective.topics.filter { statusFor($0) == .needsReview }.count
    }

    func progress(for section: StudySection) -> Double {
        let total = section.totalTopics
        guard total > 0 else { return 0 }
        return Double(confidentCount(for: section)) / Double(total)
    }

    func progress(for objective: StudyObjective) -> Double {
        let total = objective.topics.count
        guard total > 0 else { return 0 }
        return Double(confidentCount(for: objective)) / Double(total)
    }

    var totalConfident: Int {
        sections.reduce(0) { $0 + confidentCount(for: $1) }
    }

    var totalTopics: Int {
        sections.reduce(0) { $0 + $1.totalTopics }
    }

    var overallProgress: Double {
        guard totalTopics > 0 else { return 0 }
        return Double(totalConfident) / Double(totalTopics)
    }

    // MARK: – Needs Review
    struct ReviewItem: Identifiable {
        let id: String
        let topic: StudyTopic
        let sectionTitle: String
        let sectionColor: Color
        let objectiveTitle: String
        let sectionIndex: Int
        let objectiveIndex: Int
        let topicIndex: Int
    }

    var needsReviewItems: [ReviewItem] {
        var items: [ReviewItem] = []
        for (si, section) in sections.enumerated() {
            for (oi, objective) in section.objectives.enumerated() {
                for (ti, topic) in objective.topics.enumerated() {
                    if statusFor(topic) == .needsReview {
                        items.append(ReviewItem(
                            id: topic.id,
                            topic: topic,
                            sectionTitle: section.title,
                            sectionColor: section.color,
                            objectiveTitle: objective.title,
                            sectionIndex: si,
                            objectiveIndex: oi,
                            topicIndex: ti
                        ))
                    }
                }
            }
        }
        return items
    }

    var needsReviewCount: Int {
        needsReviewItems.count
    }

    // MARK: – Navigation Actions
    func navigateToObjectives(sectionIndex: Int) {
        screen = .objectives(sectionIndex: sectionIndex)
    }

    func navigateToTopic(sectionIndex: Int, objectiveIndex: Int, topicIndex: Int = 0) {
        isAnswerRevealed = false
        screen = .topic(sectionIndex: sectionIndex, objectiveIndex: objectiveIndex, topicIndex: topicIndex)
    }

    func navigateHome() {
        screen = .home
    }

    func navigateToNeedsReview() {
        screen = .needsReview
    }

    func goBack() {
        switch screen {
        case .home:
            break
        case .objectives:
            screen = .home
        case .topic(let si, _, _):
            screen = .objectives(sectionIndex: si)
        case .needsReview:
            screen = .home
        }
    }

    func nextTopic() {
        guard case .topic(let si, let oi, let ti) = screen else { return }
        let count = sections[si].objectives[oi].topics.count
        if ti < count - 1 {
            isAnswerRevealed = false
            screen = .topic(sectionIndex: si, objectiveIndex: oi, topicIndex: ti + 1)
        }
    }

    func previousTopic() {
        guard case .topic(let si, let oi, let ti) = screen else { return }
        if ti > 0 {
            isAnswerRevealed = false
            screen = .topic(sectionIndex: si, objectiveIndex: oi, topicIndex: ti - 1)
        }
    }

    func jumpToTopic(index: Int) {
        guard case .topic(let si, let oi, _) = screen else { return }
        let count = sections[si].objectives[oi].topics.count
        if index >= 0 && index < count {
            isAnswerRevealed = false
            screen = .topic(sectionIndex: si, objectiveIndex: oi, topicIndex: index)
        }
    }

    func revealAnswer() {
        isAnswerRevealed = true
    }

    func hideAnswer() {
        isAnswerRevealed = false
    }

    // MARK: – Persistence
    func saveProgress() {
        if let data = try? JSONEncoder().encode(topicStatuses) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([String: TopicStatus].self, from: data) {
            topicStatuses = decoded
        }
    }

    func resetAllProgress() {
        topicStatuses.removeAll()
        saveProgress()
    }
}
