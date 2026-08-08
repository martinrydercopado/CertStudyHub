import SwiftUI

struct StudyHomeView: View {
    let viewModel: StudyViewModel
    let certConfig: CertConfig

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall progress header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "graduationcap.fill")
                            .font(.title2)
                            .foregroundStyle(certConfig.primaryColor)
                        Text("Study Guide")
                            .font(.title2)
                            .fontWeight(.heavy)
                    }

                    Text("\(viewModel.totalConfident) of \(viewModel.totalTopics) topics confident")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    StudyProgressBar(
                        progress: viewModel.overallProgress,
                        color: certConfig.primaryColor,
                        height: 8
                    )
                    .padding(.horizontal, 40)
                }
                .padding(.top, 8)

                // Section cards
                LazyVStack(spacing: 14) {
                    ForEach(Array(viewModel.sections.enumerated()), id: \.element.id) { index, section in
                        SectionCard(
                            section: section,
                            confidentCount: viewModel.confidentCount(for: section),
                            progress: viewModel.progress(for: section)
                        ) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.navigateToObjectives(sectionIndex: index)
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }
}

// MARK: - Section Card

private struct SectionCard: View {
    let section: StudySection
    let confidentCount: Int
    let progress: Double
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 14) {
                    Image(systemName: section.icon)
                        .font(.title2)
                        .foregroundStyle(section.color)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? section.color.opacity(0.15) : section.lightColor)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(section.title)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("\(section.objectives.count) objectives · \(section.totalTopics) topics")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(confidentCount)/\(section.totalTopics)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(section.color)

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                StudyProgressBar(
                    progress: progress,
                    color: section.color,
                    height: 6
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(PlatformColor.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(PlatformColor.separator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Progress Bar

struct StudyProgressBar: View {
    let progress: Double
    let color: Color
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color.opacity(0.15))
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: max(0, geo.size.width * CGFloat(progress)), height: height)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}
