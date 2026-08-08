import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Clipboard Helper

enum CopyHelper {
    /// Copies the given string to the system pasteboard
    static func copyToClipboard(_ text: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }
}

// MARK: - Study Guide Markdown Formatters

extension CopyHelper {
    /// Formats a single study topic as markdown
    static func markdownForTopic(
        topic: StudyTopic,
        sectionTitle: String,
        objectiveTitle: String,
        status: TopicStatus
    ) -> String {
        """
        ## \(sectionTitle)
        ### \(objectiveTitle)

        **Q\(topic.number): \(topic.question)**

        \(topic.answer)

        ---
        _Status: \(status.label)_
        """
    }

    /// Formats all "Needs Review" topics as markdown
    static func markdownForNeedsReview(
        items: [StudyViewModel.ReviewItem]
    ) -> String {
        if items.isEmpty {
            return "# Needs Review\n\n_No topics marked for review._\n"
        }

        var md = "# Topics Marked for Review (\(items.count))\n\n"
        for item in items {
            md += """
            ## \(item.sectionTitle) › \(item.objectiveTitle)

            **Q\(item.topic.number): \(item.topic.question)**

            \(item.topic.answer)

            ---

            """
        }
        return md
    }
}

// MARK: - Quiz Markdown Formatters

extension CopyHelper {
    /// Formats a quiz question with its answer as markdown
    static func markdownForQuestion(
        question: Question,
        questionNumber: Int,
        selectedOptions: Set<Int>,
        isCorrect: Bool?
    ) -> String {
        var md = "## Question \(questionNumber)\n\n"
        if question.isMultiSelect {
            md += "_Multi-select: Choose \(question.requiredSelections)_\n\n"
        } else if question.isTrueFalse {
            md += "_True or False_\n\n"
        }
        md += "**\(question.question)**\n\n"

        for (i, option) in question.options.enumerated() {
            let correct = question.correctIndices.contains(i) ? " ✅" : ""
            let selected = selectedOptions.contains(i) ? " ← your answer" : ""
            md += "\(option.letter). \(option.text)\(correct)\(selected)\n"
        }

        let correctLetters = question.correctIndices.sorted().map { question.options[$0].letter }.joined(separator: ", ")
        md += "\n**Correct Answer\(question.isMultiSelect ? "s" : ""):** \(correctLetters)\n\n"
        md += "**Explanation:** \(question.explanation)\n"
        return md
    }

    /// Formats quiz results as markdown
    static func markdownForResults(
        score: Int,
        total: Int,
        percentage: Int,
        grade: String,
        flaggedCount: Int,
        certName: String,
        passingScore: Int
    ) -> String {
        """
        # Quiz Results — \(certName)

        **Score:** \(score)/\(total) (\(percentage)%)
        **Grade:** \(grade)
        **Passing Score:** \(passingScore)%
        **Flagged for Review:** \(flaggedCount)

        ---
        """
    }

    /// Formats a flagged quiz question as markdown
    static func markdownForFlaggedQuestion(
        question: Question,
        index: Int,
        total: Int
    ) -> String {
        var md = "## Flagged Question \(index + 1) of \(total)\n\n"
        if question.isMultiSelect {
            md += "_Multi-select: Choose \(question.requiredSelections)_\n\n"
        }
        md += "**\(question.question)**\n\n"

        for (i, option) in question.options.enumerated() {
            let correct = question.correctIndices.contains(i) ? " ✅" : ""
            md += "\(option.letter). \(option.text)\(correct)\n"
        }

        let correctLetters = question.correctIndices.sorted().map { question.options[$0].letter }.joined(separator: ", ")
        md += "\n**Correct Answer\(question.isMultiSelect ? "s" : ""):** \(correctLetters)\n\n"
        md += "**Explanation:** \(question.explanation)\n"
        return md
    }
}

// MARK: - Copy Button View

struct CopyButton: View {
    let markdown: String
    @State private var copied = false

    var body: some View {
        Button {
            CopyHelper.copyToClipboard(markdown)
            withAnimation(.easeInOut(duration: 0.2)) {
                copied = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    copied = false
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .font(.caption2)
                Text(copied ? "Copied!" : "Copy")
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundStyle(copied ? .green : .secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(copied ? Color.green.opacity(0.12) : PlatformColor.secondaryBackground)
            )
            .overlay(
                Capsule()
                    .stroke(copied ? Color.green.opacity(0.4) : PlatformColor.separator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
