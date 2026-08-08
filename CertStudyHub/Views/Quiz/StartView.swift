import SwiftUI

struct StartView: View {
    let viewModel: QuizViewModel
    let certConfig: CertConfig

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 12)

                // Icon
                Image(systemName: certConfig.icon)
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [certConfig.primaryColor, certConfig.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Title
                VStack(spacing: 6) {
                    Text("Choose Your Quiz")
                        .font(.title2)
                        .fontWeight(.heavy)

                    Text("\(viewModel.totalAvailableQuestions) questions available")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Quiz length options
                VStack(spacing: 14) {
                    ForEach(certConfig.quizLengths) { length in
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.startQuiz(length: length)
                            }
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: length.icon)
                                    .font(.title2)
                                    .foregroundStyle(certConfig.primaryColor)
                                    .frame(width: 40)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(length.label)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text(length.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(length.duration)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(certConfig.primaryColor)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(certConfig.primaryColor.opacity(0.1))
                                    )

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
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
                .padding(.horizontal, 4)

                // Info text
                Text("Questions are randomly selected from the full bank and shuffled each time. Includes single-choice, multi-select, and true/false questions.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(PlatformColor.groupedBackground)
        )
    }
}
