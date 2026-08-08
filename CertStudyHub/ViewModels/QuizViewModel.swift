import Foundation
import SwiftUI

enum QuizScreen {
    case start
    case quiz
    case results
    case forReview
}

@Observable
final class QuizViewModel {
    // MARK: – Configuration
    let certConfig: CertConfig

    // MARK: – Navigation
    private(set) var currentScreen: QuizScreen = .start

    // MARK: – Quiz State
    private(set) var shuffledQuestions: [Question] = []
    private(set) var currentIndex: Int = 0
    private(set) var score: Int = 0
    private(set) var answered: Int = 0
    var selectedOptions: Set<Int> = []
    private(set) var hasSubmitted: Bool = false
    private(set) var selectedLength: QuizLength? = nil

    // MARK: – For Review
    private(set) var flaggedQuestions: [Question] = []
    private(set) var reviewIndex: Int = 0

    // MARK: – Init
    init(certConfig: CertConfig) {
        self.certConfig = certConfig
    }

    // MARK: – Computed – Quiz
    var currentQuestion: Question? {
        guard currentIndex < shuffledQuestions.count else { return nil }
        return shuffledQuestions[currentIndex]
    }

    var progress: Double {
        guard !shuffledQuestions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(shuffledQuestions.count)
    }

    var totalQuestions: Int { shuffledQuestions.count }
    var totalAvailableQuestions: Int { certConfig.questions.count }

    var canSubmit: Bool {
        guard let q = currentQuestion else { return false }
        if q.isMultiSelect {
            return selectedOptions.count == q.requiredSelections
        } else {
            return selectedOptions.count == 1
        }
    }

    var isCorrect: Bool? {
        guard hasSubmitted else { return nil }
        return selectedOptions == currentQuestion?.correctIndices
    }

    var isFinished: Bool {
        currentIndex >= shuffledQuestions.count && !shuffledQuestions.isEmpty
    }

    var percentage: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int(round(Double(score) / Double(totalQuestions) * 100))
    }

    var grade: String {
        let passing = certConfig.passingScore
        switch percentage {
        case 90...100: return "Outstanding!"
        case 80..<90:  return "Great Job!"
        case 70..<80:  return "Good Effort!"
        case passing..<70: return "Passing!"
        case max(0, passing - 2)..<passing: return "Keep Studying"
        default:       return "Needs Improvement"
        }
    }

    var gradeColor: Color {
        let passing = certConfig.passingScore
        switch percentage {
        case 90...100: return .green
        case 80..<90:  return .blue
        case 70..<80:  return .indigo
        case passing..<70: return certConfig.primaryColor
        case max(0, passing - 2)..<passing: return .orange
        default:       return .red
        }
    }

    // MARK: – Computed – Flagged
    var isCurrentQuestionFlagged: Bool {
        guard let q = currentQuestion else { return false }
        return flaggedQuestions.contains(where: { $0.id == q.id })
    }

    var currentReviewQuestion: Question? {
        guard reviewIndex < flaggedQuestions.count else { return nil }
        return flaggedQuestions[reviewIndex]
    }

    var reviewCount: Int { flaggedQuestions.count }

    // MARK: – Actions – Quiz
    func startQuiz(length: QuizLength) {
        selectedLength = length

        // If this quiz length specifies a question ID range, filter to that subset
        let pool: [Question]
        if let range = length.questionIDRange {
            pool = certConfig.questions.filter { q in
                if let qID = Int(q.id) {
                    return range.contains(qID)
                }
                return false
            }
        } else {
            pool = certConfig.questions
        }

        let count = min(length.id, pool.count)
        shuffledQuestions = Array(pool.shuffled().prefix(count))
        currentIndex = 0
        score = 0
        answered = 0
        selectedOptions = []
        hasSubmitted = false
        currentScreen = .quiz
    }

    func submit() {
        guard canSubmit, !hasSubmitted else { return }
        hasSubmitted = true
        answered += 1
        if selectedOptions == currentQuestion?.correctIndices {
            score += 1
        }
    }

    func nextQuestion() {
        currentIndex += 1
        selectedOptions = []
        hasSubmitted = false
        if isFinished {
            currentScreen = .results
        }
    }

    func selectOption(_ index: Int) {
        guard !hasSubmitted else { return }
        guard let q = currentQuestion else { return }

        if q.isSingleChoice {
            // Radio behavior: replace selection
            selectedOptions = [index]
        } else {
            // Checkbox behavior: toggle
            if selectedOptions.contains(index) {
                selectedOptions.remove(index)
            } else {
                // Don't allow more than required
                if selectedOptions.count < q.requiredSelections {
                    selectedOptions.insert(index)
                }
            }
        }
    }

    func returnToStart() {
        currentScreen = .start
        selectedLength = nil
        shuffledQuestions = []
        currentIndex = 0
        score = 0
        answered = 0
        selectedOptions = []
        hasSubmitted = false
    }

    // MARK: – Actions – Flagging
    func toggleFlag() {
        guard let q = currentQuestion else { return }
        if let idx = flaggedQuestions.firstIndex(where: { $0.id == q.id }) {
            flaggedQuestions.remove(at: idx)
        } else {
            flaggedQuestions.append(q)
        }
    }

    // MARK: – Actions – For Review
    func openForReview() {
        reviewIndex = 0
        currentScreen = .forReview
    }

    func closeForReview() {
        if isFinished {
            currentScreen = .results
        } else if shuffledQuestions.isEmpty {
            currentScreen = .start
        } else {
            currentScreen = .quiz
        }
    }

    func nextReviewQuestion() {
        if reviewIndex < flaggedQuestions.count - 1 {
            reviewIndex += 1
        }
    }

    func previousReviewQuestion() {
        if reviewIndex > 0 {
            reviewIndex -= 1
        }
    }

    func removeFromReview() {
        guard reviewIndex < flaggedQuestions.count else { return }
        flaggedQuestions.remove(at: reviewIndex)
        if flaggedQuestions.isEmpty {
            closeForReview()
        } else if reviewIndex >= flaggedQuestions.count {
            reviewIndex = flaggedQuestions.count - 1
        }
    }
}
