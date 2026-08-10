import SwiftUI

struct CertHomeView: View {
    let certConfig: CertConfig

    @State private var selectedTab: Int
    @State private var quizVM: QuizViewModel
    @State private var studyVM: StudyViewModel

    private var isQuizOnly: Bool {
        certConfig.studySections.isEmpty
    }

    init(certConfig: CertConfig) {
        self.certConfig = certConfig
        self._quizVM = State(initialValue: QuizViewModel(certConfig: certConfig))
        self._studyVM = State(initialValue: StudyViewModel(certConfig: certConfig))
        // Default to quiz tab when there are no study sections
        self._selectedTab = State(initialValue: certConfig.studySections.isEmpty ? 1 : 0)
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if isQuizOnly {
                // Quiz-only mode — no tab bar, just the quiz view
                QuizView(viewModel: quizVM, certConfig: certConfig)
            } else {
                TabView(selection: $selectedTab) {
                    StudyGuideView(viewModel: studyVM, certConfig: certConfig)
                        .tabItem {
                            Label("Study Guide", systemImage: "book.fill")
                        }
                        .tag(0)

                    QuizView(viewModel: quizVM, certConfig: certConfig)
                        .tabItem {
                            Label("Quiz", systemImage: "questionmark.circle.fill")
                        }
                        .tag(1)
                }
            }
        }
        .tint(certConfig.primaryColor)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                    }
                }
            }
        }
        #endif
    }
}
