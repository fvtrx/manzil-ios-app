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

        let ayah = Ayah(
            reference: reference,
            surahNumber: arabicItem.surah.number,
            numberInSurah: arabicItem.numberInSurah,
            arabic: arabicItem.text,
            translation: translationItem?.text ?? "",
            audioURL: audioItem?.audio.flatMap(URL.init(string:))
        )

        cache[key] = ayah
        return ayah
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
