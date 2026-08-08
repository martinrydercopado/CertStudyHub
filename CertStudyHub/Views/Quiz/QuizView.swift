import SwiftUI

struct QuizView: View {
    @Bindable var viewModel: QuizViewModel
    let certConfig: CertConfig

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(certConfig.name)
                            #if os(macOS)
                            .font(.title3)
                            #else
                            .font(.title2)
                            #endif
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)

                        HStack(spacing: 8) {
                            Text(headerSubtitle)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                                .fontWeight(.medium)

                            // For Review badge in header
                            if viewModel.reviewCount > 0 && viewModel.currentScreen != .forReview {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        viewModel.openForReview()
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "flag.fill")
                                            .font(.caption2)
                                        Text("\(viewModel.reviewCount)")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(.white.opacity(0.2))
                                    )
                                }
                            }
                        }
                    }

                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            #if os(iOS)
            .padding(.top, 8)
            #endif
            .background(
                LinearGradient(
                    colors: certConfig.headerGradient,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

            // Body
            Group {
                switch viewModel.currentScreen {
                case .start:
                    StartView(viewModel: viewModel, certConfig: certConfig)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                case .quiz:
                    VStack(spacing: 16) {
                        ProgressBarView(
                            progress: viewModel.progress,
                            currentQuestion: viewModel.currentIndex + 1,
                            totalQuestions: viewModel.totalQuestions,
                            score: viewModel.score,
                            answered: viewModel.answered,
                            primaryColor: certConfig.primaryColor
                        )
                        .padding(.horizontal, 16)

                        QuestionView(viewModel: viewModel, certConfig: certConfig)
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 16)
                case .results:
                    ResultsView(viewModel: viewModel, certConfig: certConfig)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                case .forReview:
                    ForReviewView(viewModel: viewModel, certConfig: certConfig)
                        .transition(.opacity)
                }
            }

            Spacer(minLength: 0)
        }
        .background(PlatformColor.groupedBackground)
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentScreen == .start)
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentScreen == .quiz)
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentScreen == .results)
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentScreen == .forReview)
    }

    private var headerSubtitle: String {
        switch viewModel.currentScreen {
        case .start:
            return "Certification Practice Quiz"
        case .quiz:
            return "Quiz \u{2014} \(viewModel.totalQuestions) Questions"
        case .results:
            return "Quiz Complete"
        case .forReview:
            return "For Review \u{2014} \(viewModel.reviewCount) Questions"
        }
    }
}
