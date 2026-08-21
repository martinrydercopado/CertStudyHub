import SwiftUI

struct CertHomeView: View {
    let certConfig: CertConfig

    @State private var selectedTab: Int
    @State private var quizVM: QuizViewModel
    @State private var studyVM: StudyViewModel

    private var hasQuiz: Bool { !certConfig.questions.isEmpty }
    private var hasStudy: Bool { !certConfig.studySections.isEmpty }
    private var hasGuide: Bool { certConfig.guideFile != nil }

    /// Number of available content tabs
    private var tabCount: Int {
        (hasStudy ? 1 : 0) + (hasQuiz ? 1 : 0) + (hasGuide ? 1 : 0)
    }

    init(certConfig: CertConfig) {
        self.certConfig = certConfig
        self._quizVM = State(initialValue: QuizViewModel(certConfig: certConfig))
        self._studyVM = State(initialValue: StudyViewModel(certConfig: certConfig))
        // Default tab: study if available, else quiz, else reference
        if !certConfig.studySections.isEmpty {
            self._selectedTab = State(initialValue: 0)
        } else if !certConfig.questions.isEmpty {
            self._selectedTab = State(initialValue: 0)
        } else {
            self._selectedTab = State(initialValue: 0)
        }
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if tabCount == 1 {
                // Single-content mode — no tab bar
                if hasStudy {
                    StudyGuideView(viewModel: studyVM, certConfig: certConfig)
                } else if hasQuiz {
                    QuizView(viewModel: quizVM, certConfig: certConfig)
                } else if let guideFile = certConfig.guideFile {
                    ReferenceGuideView(guideFile: guideFile, certConfig: certConfig)
                }
            } else {
                TabView(selection: $selectedTab) {
                    if hasStudy {
                        StudyGuideView(viewModel: studyVM, certConfig: certConfig)
                            .tabItem {
                                Label("Study Guide", systemImage: "book.fill")
                            }
                            .tag(0)
                    }

                    if hasQuiz {
                        QuizView(viewModel: quizVM, certConfig: certConfig)
                            .tabItem {
                                Label("Quiz", systemImage: "questionmark.circle.fill")
                            }
                            .tag(hasStudy ? 1 : 0)
                    }

                    if let guideFile = certConfig.guideFile {
                        ReferenceGuideView(guideFile: guideFile, certConfig: certConfig)
                            .tabItem {
                                Label("Reference", systemImage: "doc.richtext")
                            }
                            .tag(tabCount - 1)
                    }
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
