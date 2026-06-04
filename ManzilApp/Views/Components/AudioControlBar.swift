import SwiftUI

/// Floating transport bar: previous / play-pause / next plus the current
/// ayah reference. Appears while a section is queued.
struct AudioControlBar: View {
    @ObservedObject var player: AudioPlayer
    let onPlayAll: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 22) {
            if player.currentReference == nil {
                Button(action: onPlayAll) {
                    Label("Play section", systemImage: "play.fill")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
            } else {
                Button { player.previous() } label: {
                    Image(systemName: "backward.fill")
                }
                Button { player.togglePlayPause() } label: {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                Button { player.next() } label: {
                    Image(systemName: "forward.fill")
                }

                Spacer()

                if let ref = player.currentReference {
                    Text(ref)
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                }

                Button { player.stop() } label: {
                    Image(systemName: "stop.fill")
                }
            }
        }
        .foregroundStyle(.white)
        .font(.title3)
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            Capsule().fill(
                LinearGradient(colors: [Theme.emerald, Theme.emeraldDark],
                               startPoint: .leading, endPoint: .trailing)
            )
        )
        .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
        .padding(.horizontal, 16)
    }
}
