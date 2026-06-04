import SwiftUI

/// Loads and holds the ayahs for one set of references (a section, or the
/// whole Manzil). Fetches concurrently while preserving order.
@MainActor
final class SectionLoader: ObservableObject {

    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var ayahs: [Ayah] = []
    @Published private(set) var state: LoadState = .idle

    private var loadedSignature: String?

    /// Fetch `references` for the given editions. Skips work if the same
    /// data is already loaded.
    func load(references: [String], translation: String, reciter: String) async {
        let signature = "\(references.joined(separator: ",")):\(translation):\(reciter)"
        if signature == loadedSignature, state == .loaded { return }

        state = .loading
        loadedSignature = signature

        do {
            // Fetch concurrently, then re-order to match `references`.
            let fetched = try await withThrowingTaskGroup(of: (Int, Ayah).self) { group -> [Ayah] in
                for (offset, ref) in references.enumerated() {
                    group.addTask {
                        let ayah = try await QuranAPIService.shared.ayah(
                            reference: ref,
                            translationEdition: translation,
                            reciterEdition: reciter
                        )
                        return (offset, ayah)
                    }
                }
                var byIndex: [Int: Ayah] = [:]
                for try await (offset, ayah) in group {
                    byIndex[offset] = ayah
                }
                return references.indices.compactMap { byIndex[$0] }
            }

            ayahs = fetched
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
            loadedSignature = nil
        }
    }
}
