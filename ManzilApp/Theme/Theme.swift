import SwiftUI

/// Visual language for the app: a calm emerald-and-gold Islamic palette
/// that adapts to light and dark mode.
enum Theme {
    static let emerald     = Color(red: 0.04, green: 0.42, blue: 0.34)
    static let emeraldDark = Color(red: 0.02, green: 0.26, blue: 0.21)
    static let gold        = Color(red: 0.78, green: 0.63, blue: 0.36)
    static let goldSoft    = Color(red: 0.86, green: 0.74, blue: 0.52)

    /// Page background that responds to color scheme.
    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.06, green: 0.08, blue: 0.07)
                        : Color(red: 0.97, green: 0.96, blue: 0.93)
    }

    /// Card surface color.
    static func card(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.11, green: 0.14, blue: 0.12)
                        : .white
    }

    static let arabicFontName = "Geeza Pro"   // a clean Arabic face shipped with iOS
}

/// Decorative gradient header used at the top of the home and reader screens.
struct EmeraldHeader: View {
    var body: some View {
        LinearGradient(
            colors: [Theme.emerald, Theme.emeraldDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func cardStyle(_ scheme: ColorScheme) -> some View {
        self
            .background(Theme.card(scheme))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.gold.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(scheme == .dark ? 0.4 : 0.06), radius: 8, y: 4)
    }
}
