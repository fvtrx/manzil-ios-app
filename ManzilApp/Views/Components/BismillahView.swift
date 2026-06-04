import SwiftUI

/// Decorative "In the name of Allah…" header shown above passages that
/// begin a surah.
struct BismillahView: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(spacing: 4) {
            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(.custom(Theme.arabicFontName, size: 24))
                .environment(\.layoutDirection, .rightToLeft)
                .foregroundStyle(Theme.emerald)
            Rectangle()
                .fill(Theme.gold.opacity(0.4))
                .frame(width: 60, height: 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }
}
