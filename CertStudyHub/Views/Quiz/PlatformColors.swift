import SwiftUI

// Cross-platform color helpers
struct PlatformColor {
    static var background: Color {
        #if os(iOS)
        Color(.systemBackground)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }

    static var groupedBackground: Color {
        #if os(iOS)
        Color(.systemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    static var secondaryBackground: Color {
        #if os(iOS)
        Color(.systemGray6)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }

    static var tertiaryBackground: Color {
        #if os(iOS)
        Color(.systemGray5)
        #else
        Color(nsColor: .separatorColor).opacity(0.3)
        #endif
    }

    static var separator: Color {
        #if os(iOS)
        Color(.systemGray4)
        #else
        Color(nsColor: .separatorColor)
        #endif
    }

    static var lightSeparator: Color {
        #if os(iOS)
        Color(.systemGray5)
        #else
        Color(nsColor: .separatorColor).opacity(0.5)
        #endif
    }
}
