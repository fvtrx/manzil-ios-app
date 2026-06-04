import Foundation

/// A selectable translation edition (identifier matches AlQuran Cloud API).
struct TranslationEdition: Identifiable, Hashable {
    let identifier: String
    let language: String
    let name: String
    var id: String { identifier }
}

/// A selectable reciter (audio edition).
struct ReciterEdition: Identifiable, Hashable {
    let identifier: String
    let name: String
    var id: String { identifier }
}

enum Editions {
    /// Special sentinel meaning "do not show a translation".
    static let none = "none"

    static let translations: [TranslationEdition] = [
        TranslationEdition(identifier: "ms.basmeih",  language: "Bahasa Melayu",     name: "Abdullah Muhammad Basmeih"),
        TranslationEdition(identifier: "id.indonesian", language: "Bahasa Indonesia", name: "Kementerian Agama RI"),
        TranslationEdition(identifier: "en.sahih",    language: "English",           name: "Saheeh International"),
        TranslationEdition(identifier: "en.pickthall", language: "English",          name: "Mohammed Pickthall")
    ]

    static let reciters: [ReciterEdition] = [
        ReciterEdition(identifier: "ar.alafasy",           name: "Mishary Rashid Alafasy"),
        ReciterEdition(identifier: "ar.abdulbasitmurattal", name: "Abdul Basit (Murattal)"),
        ReciterEdition(identifier: "ar.husary",            name: "Mahmoud Khalil Al-Husary"),
        ReciterEdition(identifier: "ar.minshawi",          name: "Mohamed Siddiq Al-Minshawi"),
        ReciterEdition(identifier: "ar.abdurrahmaansudais", name: "Abdurrahman As-Sudais")
    ]

    static func translationName(for id: String) -> String {
        translations.first { $0.identifier == id }?.language ?? "None"
    }

    static func reciterName(for id: String) -> String {
        reciters.first { $0.identifier == id }?.name ?? id
    }
}
