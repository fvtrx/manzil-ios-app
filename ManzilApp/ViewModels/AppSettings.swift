import SwiftUI
import Combine

/// User preferences, persisted to UserDefaults. Shared app-wide as an
/// EnvironmentObject so any view can read or change them.
final class AppSettings: ObservableObject {

    @Published var translationEdition: String { didSet { defaults.set(translationEdition, forKey: Keys.translation) } }
    @Published var reciterEdition: String      { didSet { defaults.set(reciterEdition, forKey: Keys.reciter) } }
    @Published var arabicFontSize: Double      { didSet { defaults.set(arabicFontSize, forKey: Keys.fontSize) } }
    @Published var showTranslation: Bool       { didSet { defaults.set(showTranslation, forKey: Keys.showTranslation) } }
    @Published var autoPlayNext: Bool          { didSet { defaults.set(autoPlayNext, forKey: Keys.autoPlay) } }
    @Published var appearance: AppearanceMode  { didSet { defaults.set(appearance.rawValue, forKey: Keys.appearance) } }

    private let defaults = UserDefaults.standard

    init() {
        translationEdition = defaults.string(forKey: Keys.translation) ?? "ms.basmeih"
        reciterEdition     = defaults.string(forKey: Keys.reciter) ?? "ar.alafasy"
        arabicFontSize     = defaults.object(forKey: Keys.fontSize) as? Double ?? 30
        showTranslation    = defaults.object(forKey: Keys.showTranslation) as? Bool ?? true
        autoPlayNext       = defaults.object(forKey: Keys.autoPlay) as? Bool ?? true
        appearance         = AppearanceMode(rawValue: defaults.string(forKey: Keys.appearance) ?? "") ?? .system
    }

    /// The translation identifier actually passed to the API: `none`
    /// when the user has hidden translations.
    var effectiveTranslation: String {
        showTranslation ? translationEdition : Editions.none
    }

    private enum Keys {
        static let translation = "translationEdition"
        static let reciter = "reciterEdition"
        static let fontSize = "arabicFontSize"
        static let showTranslation = "showTranslation"
        static let autoPlay = "autoPlayNext"
        static let appearance = "appearance"
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}
