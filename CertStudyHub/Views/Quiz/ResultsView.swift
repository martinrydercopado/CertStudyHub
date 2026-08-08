import SwiftUI

struct ResultsView: View {
    let viewModel: QuizViewModel
    let certConfig: CertConfig

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 20)

                // Score circle
                ZStack {
                    Circle()
                        .stroke(viewModel.gradeColor.opacity(0.2), lineWidth: 8)
                        .frame(width: 160, height: 160)

                    Circle()
                        .trim(from: 0, to: Double(viewModel.percentage) / 100)
                        .stroke(
                            viewModel.gradeColor,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(viewModel.percentage)%")
                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                            .foregroundStyle(viewModel.gradeColor)
                        Text("Score")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Passing indicator
                if viewModel.percentage >= certConfig.passingScore {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("Above \(certConfig.passingScore)% passing score")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .fontWeight(.semibold)
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Below \(certConfig.passingScore)% passing score")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .fontWeight(.semibold)
                    }
                }

                // Grade
                Text(viewModel.grade)
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundStyle(viewModel.gradeColor)

                // Summary
                Text("You scored \(viewModel.score) out of \(viewModel.totalQuestions) questions correctly.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                CopyButton(markdown: CopyHelper.markdownForResults(
                    score: viewModel.score,
                    total: viewModel.totalQuestions,
                    percentage: viewModel.percentage,
                    grade: viewModel.grade,
                    flaggedCount: viewModel.reviewCount,
                    certName: certConfig.name,
                    passingScore: certConfig.passingScore
                ))

                // Breakdown
                HStack(spacing: 24) {
                    StatBadge(value: "\(viewModel.score)", label: "Correct", color: .green)
                    StatBadge(value: "\(viewModel.totalQuestions - viewModel.score)", label: "Incorrect", color: .red)
                    StatBadge(value: "\(viewModel.totalQuestions)", label: "Total", color: .blue)

                    if viewModel.reviewCount > 0 {
                        StatBadge(value: "\(viewModel.reviewCount)", label: "Flagged", color: .orange)
                    }
                }

                // Buttons
                VStack(spacing: 14) {
                    if viewModel.reviewCount > 0 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.openForReview()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "flag.fill")
                                    .font(.caption)
                                Text("Review \(viewModel.reviewCount) Flagged Questions")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 13)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .red.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                        }
                    }

                    if let length = viewModel.selectedLength {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.startQuiz(length: length)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.subheadline)
                                Text("Retry \(length.id) Questions")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: [certConfig.primaryColor, certConfig.secondaryColor],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: certConfig.primaryColor.opacity(0.3), radius: 8, y: 4)
                        }
                        .padding(.top, 4)
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.returnToStart()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "house.fill")
                                .font(.caption)
                            Text("Change Quiz Length")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(certConfig.primaryColor)
                    }
                }
                .padding(.top, 4)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(PlatformColor.background)
                .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        )
    }
}

// MARK: – Stat Badge
private struct StatBadge: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
        }
        .frame(width: 70)
    }
}
