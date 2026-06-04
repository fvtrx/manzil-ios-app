import Foundation

/// One contiguous ayah range within a section. A range may carry its own
/// note (e.g. "Ayat al-Kursi") shown as a heading inside the reader.
struct AyahGroup: Hashable {
    let range: ClosedRange<Int>
    let note: String?

    init(_ lower: Int, _ upper: Int, note: String? = nil) {
        self.range = lower...upper
        self.note = note
    }
}

/// A passage of the traditional Manzil. A section may gather several
/// non-contiguous ranges from the same surah (e.g. Al-Baqarah) so they read
/// together on one screen.
struct ManzilSection: Identifiable, Hashable {
    let id: Int                 // running order, 1-based
    let surahNumber: Int
    let surahNameArabic: String
    let titleEnglish: String
    let titleMalay: String
    /// One or more ayah ranges, in reading order.
    let groups: [AyahGroup]
    /// Section-level highlight shown in lists and the reader header.
    let note: String?

    /// Every "surah:ayah" reference covered by this passage, in order.
    var ayahReferences: [String] {
        groups.flatMap { group in group.range.map { "\(surahNumber):\($0)" } }
    }

    /// True when the passage begins at the first ayah of a surah
    /// (used to decide whether to show a Bismillah header).
    var beginsSurah: Bool { groups.first?.range.lowerBound == 1 }

    var ayahCount: Int { groups.reduce(0) { $0 + $1.range.count } }

    /// Compact label for lists: "2:255–257" for one range, "4 passages" for
    /// a section that gathers several ranges.
    var rangeLabel: String {
        if groups.count == 1 {
            return "\(surahNumber):\(partLabel(groups[0].range))"
        }
        return "\(groups.count) passages"
    }

    /// When `reference` is the first ayah of a group — and the section spans
    /// more than one group — returns a heading for that group; else nil.
    func groupHeading(for reference: String) -> String? {
        guard groups.count > 1 else { return nil }
        for group in groups where "\(surahNumber):\(group.range.lowerBound)" == reference {
            let part = "Ayah \(partLabel(group.range))"
            if let note = group.note { return "\(note) · \(part)" }
            return part
        }
        return nil
    }

    private func partLabel(_ r: ClosedRange<Int>) -> String {
        r.lowerBound == r.upperBound ? "\(r.lowerBound)" : "\(r.lowerBound)–\(r.upperBound)"
    }
}
