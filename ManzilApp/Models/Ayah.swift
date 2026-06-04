import Foundation

/// A single verse, assembled from the Arabic edition, a translation edition,
/// and an audio (reciter) edition returned by the AlQuran Cloud API.
struct Ayah: Identifiable, Hashable {
    /// Reference in "surah:ayah" form, e.g. "2:255".
    let reference: String
    let surahNumber: Int
    let numberInSurah: Int
    let arabic: String
    let translation: String
    let audioURL: URL?

    var id: String { reference }
}
