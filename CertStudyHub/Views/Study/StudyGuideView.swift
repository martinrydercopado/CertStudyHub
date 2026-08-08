import SwiftUI

struct StudyGuideView: View {
    @Bindable var viewModel: StudyViewModel
    let certConfig: CertConfig

    var body: some View {
        VStack(spacing: 0) {
            // Header
            studyHeader

            // Body
            Group {
                switch viewModel.screen {
                case .home:
                    StudyHomeView(viewModel: viewModel, certConfig: certConfig)
                        .transition(.opacity)

                case .objectives(let sectionIndex):
                    ObjectiveListView(
                        viewModel: viewModel,
                        sectionIndex: sectionIndex,
                        certConfig: certConfig
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))

                case .topic(let si, let oi, let ti):
                    TopicStudyView(
                        viewModel: viewModel,
                        sectionIndex: si,
                        objectiveIndex: oi,
                        topicIndex: ti,
                        certConfig: certConfig
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))

                case .needsReview:
                    NeedsReviewView(viewModel: viewModel, certConfig: certConfig)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: screenKey)

            Spacer(minLength: 0)
        }
        .background(PlatformColor.groupedBackground)
    }

    // MARK: - Header

    private var studyHeader: some View {
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

                    Text(headerSubtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                        .fontWeight(.medium)
                }

                Spacer()

                // Needs Review badge
                if viewModel.needsReviewCount > 0 && viewModel.screen != .needsReview {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.navigateToNeedsReview()
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                            Text("Review (\(viewModel.needsReviewCount))")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.2))
                        )
                    }
                    .buttonStyle(.plain)
                }
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
    }

    private var headerSubtitle: String {
        switch viewModel.screen {
        case .home:
            return "Interactive Study Guide"
        case .objectives(let si):
            return viewModel.section(at: si).title
        case .topic(let si, _, _):
            return viewModel.section(at: si).title + " \u{2014} Study Mode"
        case .needsReview:
            return "Needs Review \u{2014} \(viewModel.needsReviewCount) Topics"
        }
    }

    // Used for animation trigger
    private var screenKey: String {
        switch viewModel.screen {
        case .home: return "home"
        case .objectives(let si): return "obj-\(si)"
        case .topic(let si, let oi, let ti): return "topic-\(si)-\(oi)-\(ti)"
        case .needsReview: return "review"
        }
    }
}
