import SwiftUI

struct QuestionView: View {
    @Bindable var viewModel: QuizViewModel
    let certConfig: CertConfig

    var body: some View {
        if let question = viewModel.currentQuestion {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Question header with flag and type badge
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("QUESTION \(viewModel.currentIndex + 1)")
                                .font(.caption)
                                .fontWeight(.heavy)
                                .foregroundStyle(certConfig.primaryColor)
                                .tracking(1.2)

                            // Question type badge
                            if question.isMultiSelect {
                                HStack(spacing: 4) {
                                    Image(systemName: "checklist")
                                        .font(.caption2)
                                    Text("Select \(question.requiredSelections) answers")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(certConfig.primaryColor))
                            } else if question.isTrueFalse {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.caption2)
                                    Text("True or False")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(.blue))
                            }
                        }

                        Spacer()

                        // Flag button
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.toggleFlag()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: viewModel.isCurrentQuestionFlagged ? "flag.fill" : "flag")
                                    .font(.caption)
                                Text(viewModel.isCurrentQuestionFlagged ? "Flagged" : "Flag")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(viewModel.isCurrentQuestionFlagged ? .orange : .secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(viewModel.isCurrentQuestionFlagged ? Color.orange.opacity(0.12) : PlatformColor.secondaryBackground)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(viewModel.isCurrentQuestionFlagged ? Color.orange.opacity(0.4) : PlatformColor.separator, lineWidth: 1)
                            )
                        }
                    }

                    // Copy button
                    HStack {
                        Spacer()
                        CopyButton(markdown: CopyHelper.markdownForQuestion(
                            question: question,
                            questionNumber: viewModel.currentIndex + 1,
                            selectedOptions: viewModel.selectedOptions,
                            isCorrect: viewModel.isCorrect
                        ))
                    }

                    // Question text
                    Text(question.question)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                        .textSelection(.enabled)

                    // Options
                    VStack(spacing: 10) {
                        ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                            OptionButton(
                                letter: option.letter,
                                text: option.text,
                                isSelected: viewModel.selectedOptions.contains(index),
                                hasSubmitted: viewModel.hasSubmitted,
                                isCorrectAnswer: question.correctIndices.contains(index),
                                isMultiSelect: question.isMultiSelect,
                                primaryColor: certConfig.primaryColor,
                                action: { viewModel.selectOption(index) }
                            )
                        }
                    }

                    // Multi-select selection counter (before submit)
                    if question.isMultiSelect && !viewModel.hasSubmitted {
                        HStack {
                            Spacer()
                            Text("\(viewModel.selectedOptions.count) of \(question.requiredSelections) selected")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(viewModel.canSubmit ? certConfig.primaryColor : .secondary)
                            Spacer()
                        }
                    }

                    // Feedback
                    if viewModel.hasSubmitted, let isCorrect = viewModel.isCorrect {
                        FeedbackView(
                            isCorrect: isCorrect,
                            explanation: question.explanation
                        )
                    }

                    // Buttons
                    HStack(spacing: 12) {
                        Spacer()

                        if !viewModel.hasSubmitted {
                            Button {
                                var transaction = Transaction()
                                transaction.disablesAnimations = true
                                withTransaction(transaction) {
                                    viewModel.submit()
                                }
                            } label: {
                                Text("Submit")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(viewModel.canSubmit ? certConfig.primaryColor : Color.gray.opacity(0.4))
                                    )
                            }
                            .disabled(!viewModel.canSubmit)
                        } else {
                            Button {
                                viewModel.nextQuestion()
                            } label: {
                                HStack(spacing: 6) {
                                    Text(viewModel.currentIndex < viewModel.totalQuestions - 1 ? "Next Question" : "View Results")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    Image(systemName: viewModel.currentIndex < viewModel.totalQuestions - 1 ? "arrow.right" : "flag.checkered")
                                        .font(.subheadline)
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue)
                                )
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(PlatformColor.background)
                    .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
            )
            .id(viewModel.currentIndex)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        }
    }
}
