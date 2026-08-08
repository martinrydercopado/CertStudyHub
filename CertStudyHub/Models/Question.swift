import Foundation

enum QuestionType: String, Codable {
    case singleSelect = "single-select"
    case multiSelect = "multi-select"
    case trueFalse = "true-false"
}

struct Question: Identifiable, Hashable {
    let id: String
    let question: String
    let options: [(letter: String, text: String)]
    let questionType: QuestionType
    let correctIndices: Set<Int>
    let explanation: String

    var requiredSelections: Int { correctIndices.count }
    var isMultiSelect: Bool { questionType == .multiSelect }
    var isTrueFalse: Bool { questionType == .trueFalse }
    var isSingleChoice: Bool { questionType == .singleSelect || questionType == .trueFalse }

    // MARK: – Hashable / Equatable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Question, rhs: Question) -> Bool {
        lhs.id == rhs.id
    }
}
