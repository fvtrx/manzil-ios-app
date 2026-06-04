import SwiftUI

@main
struct ManzilApp: App {
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(settings)
                .preferredColorScheme(settings.appearance.colorScheme)
                .tint(Theme.emerald)
        }
    }
}
