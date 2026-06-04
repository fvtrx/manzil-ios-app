import Foundation

enum APIError: LocalizedError {
    case badURL
    case badResponse(Int)
    case missingArabic

    var errorDescription: String? {
        switch self {
        case .badURL:              return "Could not build the request URL."
        case .badResponse(let c):  return "The server responded with status \(c)."
        case .missingArabic:       return "The Arabic text was missing from the response."
        }
    }
}

/// Talks to the free AlQuran Cloud API (https://alquran.cloud).
/// One call fetches the Arabic, a translation, and an audio edition for a
/// single ayah. Results are cached in memory per (reference, translation,
/// reciter) so re-opening a section or changing back is instant.
actor QuranAPIService {
    static let shared = QuranAPIService()

    private let base = "https://api.alquran.cloud/v1"
    private var cache: [String: Ayah] = [:]

    private func cacheKey(_ ref: String, _ translation: String, _ reciter: String) -> String {
        "\(ref)|\(translation)|\(reciter)"
    }

    func ayah(reference: String,
              translationEdition: String,
              reciterEdition: String) async throws -> Ayah {

        let key = cacheKey(reference, translationEdition, reciterEdition)
        if let cached = cache[key] { return cached }

        // Always request the Uthmani Arabic text + the chosen audio edition,
        // plus a translation when the user has one selected.
        var editions = ["quran-uthmani", reciterEdition]
        if translationEdition != Editions.none {
            editions.insert(translationEdition, at: 1)
        }
        let joined = editions.joined(separator: ",")

        guard let url = URL(string: "\(base)/ayah/\(reference)/editions/\(joined)") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse else { throw APIError.badResponse(-1) }
        guard http.statusCode == 200 else { throw APIError.badResponse(http.statusCode) }

        let decoded = try JSONDecoder().decode(EditionsResponse.self, from: data)
        let items = decoded.data

        guard let arabicItem = items.first(where: { $0.edition.identifier == "quran-uthmani" }) else {
            throw APIError.missingArabic
        }
        let translationItem = items.first { $0.edition.identifier == translationEdition }
        let audioItem = items.first { $0.edition.identifier == reciterEdition }

        let cleanedArabic = Self.strippingLeadingBasmala(
            from: arabicItem.text,
            surah: arabicItem.surah.number,
            ayahInSurah: arabicItem.numberInSurah
        )

        let ayah = Ayah(
            reference: reference,
            surahNumber: arabicItem.surah.number,
            numberInSurah: arabicItem.numberInSurah,
            arabic: cleanedArabic,
            translation: translationItem?.text ?? "",
            audioURL: audioItem?.audio.flatMap(URL.init(string:))
        )

        cache[key] = ayah
        return ayah
    }

    // MARK: - Basmala handling

    /// The Uthmani Arabic edition prepends the Basmala to the first ayah of
    /// every surah except Al-Fatihah (where it *is* ayah 1) and At-Tawbah
    /// (which has none). Because the reader shows a decorative Bismillah
    /// header separately, that prepended copy is a duplicate — so strip it
    /// from the first ayah of every other surah.
    ///
    /// The match is diacritic-insensitive: it compares the first four words
    /// against the Basmala after removing harakat and normalising alef forms,
    /// so it works regardless of minor encoding differences and only ever
    /// removes a genuine leading Basmala.
    static func strippingLeadingBasmala(from text: String,
                                        surah: Int,
                                        ayahInSurah: Int) -> String {
        guard ayahInSurah == 1, surah != 1, surah != 9 else { return text }

        let words = text.split(whereSeparator: { $0 == " " || $0 == "\u{00A0}" })
                        .map(String.init)
        guard words.count > 4 else { return text }

        let firstFour = words.prefix(4).joined()
        let basmala = "بسم الله الرحمن الرحيم".replacingOccurrences(of: " ", with: "")

        guard normalisedArabic(firstFour) == normalisedArabic(basmala) else { return text }
        return words.dropFirst(4).joined(separator: " ")
    }

    /// Removes Arabic diacritics/tatweel and normalises alef variants so two
    /// spellings of the same word compare equal.
    private static func normalisedArabic(_ s: String) -> String {
        var scalars = String.UnicodeScalarView()
        for scalar in s.unicodeScalars {
            let v = scalar.value
            let isMark = (0x064B...0x065F).contains(v)   // harakat / tanwin
                || v == 0x0670                            // superscript alef
                || (0x06D6...0x06ED).contains(v)          // small Quranic marks
                || v == 0x0640                            // tatweel
            if !isMark { scalars.append(scalar) }
        }
        return String(scalars)
            .replacingOccurrences(of: "ٱ", with: "ا")
            .replacingOccurrences(of: "أ", with: "ا")
            .replacingOccurrences(of: "إ", with: "ا")
            .replacingOccurrences(of: "آ", with: "ا")
    }
}

// MARK: - Wire format

private struct EditionsResponse: Decodable {
    let code: Int
    let data: [AyahDTO]
}

private struct AyahDTO: Decodable {
    let numberInSurah: Int
    let text: String
    let audio: String?
    let edition: EditionDTO
    let surah: SurahDTO
}

private struct EditionDTO: Decodable {
    let identifier: String
    let format: String
    let type: String
}

private struct SurahDTO: Decodable {
    let number: Int
}
