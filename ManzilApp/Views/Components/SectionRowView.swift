import SwiftUI

/// A single tappable row in the Manzil list.
struct SectionRowView: View {
    let section: ManzilSection
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 14) {
            // Ornamented index badge
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Theme.emerald.opacity(scheme == .dark ? 0.25 : 0.12))
                Text("\(section.id)")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(Theme.emerald)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(section.titleEnglish)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(.primary)
                HStack(spacing: 6) {
                    Text(section.rangeLabel)
                    Text("•")
                    Text("\(section.ayahCount) ayah\(section.ayahCount == 1 ? "" : "s")")
                    if let note = section.note {
                        Text("•")
                        Text(note).foregroundStyle(Theme.gold)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }

            Spacer()

            Text(section.surahNameArabic)
                .font(.custom(Theme.arabicFontName, size: 20))
                .foregroundStyle(.secondary)
                .environment(\.layoutDirection, .rightToLeft)
        }
        .padding(14)
        .cardStyle(scheme)
    }
}
