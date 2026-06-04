import Foundation
import AVFoundation
import Combine

/// Plays per-ayah recitation. Can play a single ayah or queue a whole
/// section and advance automatically. Publishes the currently-sounding
/// reference so views can highlight the active verse.
@MainActor
final class AudioPlayer: NSObject, ObservableObject {

    @Published private(set) var isPlaying = false
    @Published private(set) var currentReference: String?

    /// Mirror of the user setting; the view model keeps this in sync.
    var autoPlayNext = true

    private var player: AVPlayer?
    private var queue: [Ayah] = []
    private var index = 0
    private var endObserver: NSObjectProtocol?

    override init() {
        super.init()
        configureSession()
    }

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    // MARK: - Public controls

    func playSingle(_ ayah: Ayah) {
        queue = [ayah]
        index = 0
        startCurrent()
    }

    func playSection(_ ayahs: [Ayah], startingAt start: Int = 0) {
        guard !ayahs.isEmpty else { return }
        queue = ayahs
        index = min(max(0, start), ayahs.count - 1)
        startCurrent()
    }

    func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }

    func next() { advance(by: 1) }
    func previous() { advance(by: -1) }

    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        currentReference = nil
        queue = []
        index = 0
        removeEndObserver()
    }

    // MARK: - Internal

    private func startCurrent() {
        guard queue.indices.contains(index),
              let url = queue[index].audioURL else {
            // Skip ayahs without audio; keep advancing if possible.
            if autoPlayNext, queue.indices.contains(index + 1) {
                index += 1
                startCurrent()
            } else {
                stop()
            }
            return
        }

        removeEndObserver()

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        currentReference = queue[index].reference

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.handleItemEnded() }
        }

        player?.play()
        isPlaying = true
    }

    private func handleItemEnded() {
        if autoPlayNext, queue.indices.contains(index + 1) {
            index += 1
            startCurrent()
        } else {
            stop()
        }
    }

    private func advance(by offset: Int) {
        let newIndex = index + offset
        guard queue.indices.contains(newIndex) else { return }
        index = newIndex
        startCurrent()
    }

    private func removeEndObserver() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
    }
}
