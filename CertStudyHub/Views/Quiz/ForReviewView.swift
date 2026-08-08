import SwiftUI

struct ForReviewView: View {
    @Bindable var viewModel: QuizViewModel
    let certConfig: CertConfig

    var body: some View {
        VStack(spacing: 0) {
            // Review header bar
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.closeForReview()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("Back")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(certConfig.primaryColor)
                }

                Spacer()

                if !viewModel.flaggedQuestions.isEmpty {
                    Text("\(viewModel.reviewIndex + 1) of \(viewModel.reviewCount)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Copy + Remove
                if let rq = viewModel.currentReviewQuestion {
                    CopyButton(markdown: CopyHelper.markdownForFlaggedQuestion(
                        question: rq,
                        index: viewModel.reviewIndex,
                        total: viewModel.reviewCount
                    ))
                }

                if viewModel.currentReviewQuestion != nil {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.removeFromReview()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                            Text("Remove")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.red.opacity(0.08))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(PlatformColor.secondaryBackground.opacity(0.5))

            Divider()

            // Question content
            if let question = viewModel.currentReviewQuestion {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Question badge
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "flag.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                Text("FLAGGED QUESTION")
                                    .font(.caption)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(.orange)
                                    .tracking(1.2)
                            }

                            if question.isMultiSelect {
                                HStack(spacing: 4) {
                                    Image(systemName: "checklist")
                                        .font(.caption2)
                                    Text("Select \(question.requiredSelections)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(certConfig.primaryColor))
                            }
                        }

                        // Question text
                        Text(question.question)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(3)
                            .textSelection(.enabled)

                        // Options with correct answer highlighted
                        VStack(spacing: 10) {
                            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                                ReviewOptionRow(
                                    letter: option.letter,
                                    text: option.text,
                                    isCorrect: question.correctIndices.contains(index)
                                )
                            }
                        }

                        // Explanation
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.yellow)

                                Text("Explanation")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                            }

                            Text(question.explanation)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(3)
                                .textSelection(.enabled)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blue.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.blue.opacity(0.15), lineWidth: 1)
                        )

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                }
                .id(viewModel.reviewIndex)

                Divider()

                // Navigation buttons
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.previousReviewQuestion()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.subheadline)
                            Text("Previous")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(viewModel.reviewIndex > 0 ? certConfig.primaryColor : .gray)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(PlatformColor.secondaryBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.reviewIndex > 0 ? certConfig.primaryColor.opacity(0.3) : PlatformColor.separator, lineWidth: 1)
                        )
                    }
                    .disabled(viewModel.reviewIndex <= 0)

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.nextReviewQuestion()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Next")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.right")
                                .font(.subheadline)
                        }
                        .foregroundStyle(viewModel.reviewIndex < viewModel.reviewCount - 1 ? certConfig.primaryColor : .gray)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(PlatformColor.secondaryBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.reviewIndex < viewModel.reviewCount - 1 ? certConfig.primaryColor.opacity(0.3) : PlatformColor.separator, lineWidth: 1)
                        )
                    }
                    .disabled(viewModel.reviewIndex >= viewModel.reviewCount - 1)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

            } else {
                // Empty state
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "flag.slash")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text("No Flagged Questions")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Text("Flag questions during a quiz to add them here for review.")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            }
        }
    }
}

// MARK: – Review Option Row
private struct ReviewOptionRow: View {
    let letter: String
    let text: String
    let isCorrect: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(letter)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(isCorrect ? .white : .secondary)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(isCorrect ? Color.green : PlatformColor.tertiaryBackground)
                )

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)

            Spacer(minLength: 4)

            if isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isCorrect ? Color.green.opacity(0.1) : PlatformColor.secondaryBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isCorrect ? Color.green.opacity(0.4) : PlatformColor.separator, lineWidth: isCorrect ? 2 : 1)
        )
    }
}
