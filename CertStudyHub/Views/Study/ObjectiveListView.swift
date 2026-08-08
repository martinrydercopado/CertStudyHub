import SwiftUI

struct ObjectiveListView: View {
    let viewModel: StudyViewModel
    let sectionIndex: Int
    let certConfig: CertConfig
    @Environment(\.colorScheme) private var colorScheme

    private var section: StudySection {
        viewModel.section(at: sectionIndex)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Back bar
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

                Text("\(viewModel.confidentCount(for: section))/\(section.totalTopics) confident")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()

            ScrollView {
                VStack(spacing: 16) {
                    // Section header card
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: section.icon)
                                .font(.title)
                                .foregroundStyle(section.color)

                            Text(section.title)
                                .font(.title3)
                                .fontWeight(.heavy)
                                .foregroundStyle(.primary)

                            Spacer()
                        }

                        StudyProgressBar(
                            progress: viewModel.progress(for: section),
                            color: section.color,
                            height: 6
                        )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? section.color.opacity(0.15) : section.lightColor)
                    )

                    // Objectives
                    ForEach(Array(section.objectives.enumerated()), id: \.element.id) { objIndex, objective in
                        ObjectiveCard(
                            objective: objective,
                            color: section.color,
                            confidentCount: viewModel.confidentCount(for: objective),
                            reviewCount: viewModel.reviewCount(for: objective),
                            progress: viewModel.progress(for: objective)
                        ) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.navigateToTopic(
                                    sectionIndex: sectionIndex,
                                    objectiveIndex: objIndex
                                )
                            }
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
    }
}

// MARK: - Objective Card

private struct ObjectiveCard: View {
    let objective: StudyObjective
    let color: Color
    let confidentCount: Int
    let reviewCount: Int
    let progress: Double
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    Text(objective.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                HStack(spacing: 12) {
                    Text("\(objective.topics.count) topics")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if confidentCount > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                            Text("\(confidentCount)")
                                .font(.caption2)
                                .foregroundStyle(.green)
                                .fontWeight(.semibold)
                        }
                    }

                    if reviewCount > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text("\(reviewCount)")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                                .fontWeight(.semibold)
                        }
                    }

                    Spacer()
                }

                StudyProgressBar(
                    progress: progress,
                    color: color,
                    height: 4
                )
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(PlatformColor.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(PlatformColor.separator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
