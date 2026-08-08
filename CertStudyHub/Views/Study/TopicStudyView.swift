import SwiftUI

struct TopicStudyView: View {
    @Bindable var viewModel: StudyViewModel
    let sectionIndex: Int
    let objectiveIndex: Int
    let topicIndex: Int
    let certConfig: CertConfig

    private var section: StudySection {
        viewModel.section(at: sectionIndex)
    }

    private var objective: StudyObjective {
        section.objectives[objectiveIndex]
    }

    private var topic: StudyTopic {
        objective.topics[topicIndex]
    }

    private var status: TopicStatus {
        viewModel.statusFor(topic)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.goBack()
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

                // Copy button
                CopyButton(markdown: CopyHelper.markdownForTopic(
                    topic: topic,
                    sectionTitle: section.title,
                    objectiveTitle: objective.title,
                    status: status
                ))

                // Topic counter
                Text("\(topicIndex + 1) of \(objective.topics.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Topic number and objective
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Q\(topic.number)")
                            .font(.caption)
                            .fontWeight(.heavy)
                            .foregroundStyle(section.color)
                            .tracking(1.2)

                        Text(objective.title)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    // Question
                    Text(topic.question)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                        .textSelection(.enabled)

                    // Answer (reveal/hide)
                    if viewModel.isAnswerRevealed {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.yellow)
                                Text("Answer")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                            }

                            Text(topic.answer)
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
                                .fill(section.color.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(section.color.opacity(0.15), lineWidth: 1)
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Reveal/Hide button
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if viewModel.isAnswerRevealed {
                                    viewModel.hideAnswer()
                                } else {
                                    viewModel.revealAnswer()
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: viewModel.isAnswerRevealed ? "eye.slash" : "eye")
                                    .font(.caption)
                                Text(viewModel.isAnswerRevealed ? "Hide Answer" : "Show Answer")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(certConfig.primaryColor)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(certConfig.primaryColor.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(certConfig.primaryColor.opacity(0.3), lineWidth: 1)
                            )
                        }
                        Spacer()
                    }

                    // Status buttons
                    VStack(spacing: 8) {
                        Text("How confident are you?")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fontWeight(.medium)

                        HStack(spacing: 12) {
                            ForEach(TopicStatus.allCases, id: \.self) { s in
                                Button {
                                    viewModel.setStatus(s, for: topic)
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: s.icon)
                                            .font(.caption2)
                                        Text(s.label)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundStyle(status == s ? .white : s.color)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(status == s ? s.color : s.color.opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(s.color.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Topic dots navigation
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(0..<objective.topics.count, id: \.self) { idx in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.jumpToTopic(index: idx)
                                    }
                                } label: {
                                    let t = objective.topics[idx]
                                    let tStatus = viewModel.statusFor(t)
                                    Circle()
                                        .fill(idx == topicIndex ? section.color : tStatus.color.opacity(0.5))
                                        .frame(width: idx == topicIndex ? 12 : 8, height: idx == topicIndex ? 12 : 8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .frame(maxWidth: .infinity)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
            .id("\(sectionIndex)-\(objectiveIndex)-\(topicIndex)")

            Divider()

            // Navigation buttons
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.previousTopic()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline)
                        Text("Previous")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(topicIndex > 0 ? certConfig.primaryColor : .gray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(PlatformColor.secondaryBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(topicIndex > 0 ? certConfig.primaryColor.opacity(0.3) : PlatformColor.separator, lineWidth: 1)
                    )
                }
                .disabled(topicIndex <= 0)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.nextTopic()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text("Next")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                    }
                    .foregroundStyle(topicIndex < objective.topics.count - 1 ? certConfig.primaryColor : .gray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(PlatformColor.secondaryBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(topicIndex < objective.topics.count - 1 ? certConfig.primaryColor.opacity(0.3) : PlatformColor.separator, lineWidth: 1)
                    )
                }
                .disabled(topicIndex >= objective.topics.count - 1)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}
