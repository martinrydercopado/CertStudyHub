import SwiftUI

struct CertHomeView: View {
    let certConfig: CertConfig

    @State private var selectedTab = 0
    @State private var quizVM: QuizViewModel
    @State private var studyVM: StudyViewModel

    init(certConfig: CertConfig) {
        self.certConfig = certConfig
        self._quizVM = State(initialValue: QuizViewModel(certConfig: certConfig))
        self._studyVM = State(initialValue: StudyViewModel(certConfig: certConfig))
    }

    var body: some View {
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
        .tint(certConfig.primaryColor)
        #if os(iOS)
        .navigationBarBackButtonHidden(false)
        #endif
    }
}
