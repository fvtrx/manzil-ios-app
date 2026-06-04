import SwiftUI

/// Displays one verse: an ayah-number badge, the Arabic (RTL), an optional
/// translation, and a play button. Highlights itself while being recited.
struct AyahCardView: View {
    let ayah: Ayah
    let isPlaying: Bool
    let showTranslation: Bool
    let arabicFontSize: Double
    let onPlay: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ayahBadge
                Spacer()
                Button(action: onPlay) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.emerald)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isPlaying ? "Pause" : "Play recitation")
            }

            Text(ayah.arabic)
                .font(.custom(Theme.arabicFontName, size: arabicFontSize))
                .lineSpacing(arabicFontSize * 0.45)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .multilineTextAlignment(.trailing)
                .environment(\.layoutDirection, .rightToLeft)
                .foregroundStyle(.primary)

            if showTranslation, !ayah.translation.isEmpty {
                Text(ayah.translation)
                    .font(.system(.callout, design: .serif))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(isPlaying ? Theme.emerald.opacity(scheme == .dark ? 0.18 : 0.07)
                                : Theme.card(scheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isPlaying ? Theme.emerald.opacity(0.6) : Theme.gold.opacity(0.22),
                        lineWidth: isPlaying ? 1.5 : 1)
        )
        .shadow(color: .black.opacity(scheme == .dark ? 0.35 : 0.05), radius: 6, y: 3)
        .animation(.easeInOut(duration: 0.2), value: isPlaying)
    }

    private var ayahBadge: some View {
        Text("\(ayah.surahNumber):\(ayah.numberInSurah)")
            .font(.system(.caption, design: .rounded).weight(.semibold))
            .foregroundStyle(Theme.emerald)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(Theme.emerald.opacity(scheme == .dark ? 0.22 : 0.1))
            )
    }
}
