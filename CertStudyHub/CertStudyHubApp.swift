import SwiftUI

@main
struct CertStudyHubApp: App {
    var body: some Scene {
        WindowGroup {
            CertPickerView()
        }
        #if os(macOS)
        .defaultSize(width: 1000, height: 750)
        #endif
    }
}
