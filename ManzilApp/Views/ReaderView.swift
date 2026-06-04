import SwiftUI

struct ReaderView: View {
    let target: ReaderTarget

    @EnvironmentObject private var settings: AppSettings
    @Environment(\.colorScheme) private var scheme
    @StateObject private var loader = SectionLoader()
    @StateObject private var player = AudioPlayer()

    private var references: [String] {
        switch target {
        case .section(let s): return s.ayahReferences
        case .full:           return QuranData.allReferences
        }
    }

    private var title: String {
        switch target {
        case .section(let s): return s.titleEnglish
        case .full:           return "Full Manzil"
        }
    }

    private var subtitle: String {
        switch target {
        case .section(let s):
            let detail = s.note ?? s.rangeLabel
            return "\(s.surahNameArabic) • \(detail)"
        case .full:
            return "\(QuranData.manzil.count) passages"
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.background(scheme).ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 14) {
                        sectionHeader

                        switch loader.state {
                        case .idle, .loading:
                            loadingView
                        case .failed(let message):
                            errorView(message)
                        case .loaded:
                            ayahList
                            navFooter
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 110)   // clearance for the control bar
                }
                // Keep the verse being recited centred on screen.
                .onChange(of: player.currentReference) { ref in
                    guard let ref else { return }
                    withAnimation(.easeInOut(duration: 0.45)) {
                        proxy.scrollTo(ref, anchor: .center)
                    }
                }
            }

            if loader.state == .loaded, !loader.ayahs.isEmpty {
                AudioControlBar(player: player) {
                    player.playSection(loader.ayahs)
                }
                .padding(.bottom, 8)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { sectionNavToolbar }
        .task(id: editionSignature) { await reload() }
        .onChange(of: settings.autoPlayNext) { newValue in
            player.autoPlayNext = newValue
        }
        .onAppear { player.autoPlayNext = settings.autoPlayNext }
        .onDisappear { player.stop() }
    }

    // MARK: - Passage navigation

    private var currentSection: ManzilSection? {
        if case .section(let s) = target { return s }
        return nil
    }

    private var previousSection: ManzilSection? {
        guard let s = currentSection else { return nil }
        return QuranData.manzil.first { $0.id == s.id - 1 }
    }

    private var nextSection: ManzilSection? {
        guard let s = currentSection else { return nil }
        return QuranData.manzil.first { $0.id == s.id + 1 }
    }

    @ToolbarContentBuilder
    private var sectionNavToolbar: some ToolbarContent {
        if let next = nextSection {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: ReaderTarget.section(next)) {
                    Image(systemName: "chevron.forward")
                }
                .accessibilityLabel("Next passage: \(next.titleEnglish)")
            }
        }
    }

    private var editionSignature: String {
        "\(settings.effectiveTranslation)|\(settings.reciterEdition)"
    }

    private func reload() async {
        await loader.load(
            references: references,
            translation: settings.effectiveTranslation,
            reciter: settings.reciterEdition
        )
    }

    // MARK: - Pieces

    private var sectionHeader: some View {
        VStack(spacing: 6) {
            Text(subtitle)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(EmeraldHeader())
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.top, 8)
    }

    @ViewBuilder
    private var ayahList: some View {
        if case .section(let s) = target, s.beginsSurah {
            BismillahView()
        }

        ForEach(Array(loader.ayahs.enumerated()), id: \.element.id) { index, ayah in
            // In full mode, mark where a new surah starts.
            if case .full = target, isNewSurah(at: index) {
                surahDivider(for: ayah)
            }

            // In section mode, mark the start of each sub-passage
            // (e.g. Ayat al-Kursi within Al-Baqarah).
            if case .section(let s) = target,
               let heading = s.groupHeading(for: ayah.reference) {
                groupDivider(heading)
            }

            AyahCardView(
                ayah: ayah,
                isPlaying: player.currentReference == ayah.reference && player.isPlaying,
                showTranslation: settings.showTranslation,
                arabicFontSize: settings.arabicFontSize
            ) {
                handlePlay(ayah: ayah, index: index)
            }
            .id(ayah.reference)   // scroll anchor for audio focus
        }
    }

    private func isNewSurah(at index: Int) -> Bool {
        guard index > 0 else { return true }
        return loader.ayahs[index].surahNumber != loader.ayahs[index - 1].surahNumber
    }

    private func surahDivider(for ayah: Ayah) -> some View {
        let name = QuranData.manzil.first { $0.surahNumber == ayah.surahNumber }
        return HStack(spacing: 10) {
            Rectangle().fill(Theme.gold.opacity(0.35)).frame(height: 1)
            Text(name?.surahNameArabic ?? "Surah \(ayah.surahNumber)")
                .font(.custom(Theme.arabicFontName, size: 20))
                .foregroundStyle(Theme.emerald)
                .environment(\.layoutDirection, .rightToLeft)
            Rectangle().fill(Theme.gold.opacity(0.35)).frame(height: 1)
        }
        .padding(.top, 8)
    }

    private func groupDivider(_ label: String) -> some View {
        HStack(spacing: 10) {
            Rectangle().fill(Theme.gold.opacity(0.3)).frame(height: 1)
            Text(label)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(Theme.emerald)
                .lineLimit(1)
                .fixedSize()
            Rectangle().fill(Theme.gold.opacity(0.3)).frame(height: 1)
        }
        .padding(.top, 6)
    }

    private func handlePlay(ayah: Ayah, index: Int) {
        if player.currentReference == ayah.reference {
            player.togglePlayPause()
        } else {
            player.playSection(loader.ayahs, startingAt: index)
        }
    }

    // MARK: - Continue reading

    @ViewBuilder
    private var navFooter: some View {
        if currentSection != nil, previousSection != nil || nextSection != nil {
            VStack(spacing: 10) {
                Rectangle()
                    .fill(Theme.gold.opacity(0.25))
                    .frame(height: 1)
                    .padding(.vertical, 2)

                HStack(spacing: 10) {
                    if let prev = previousSection {
                        NavigationLink(value: ReaderTarget.section(prev)) {
                            navChip(caption: "Previous",
                                    section: prev,
                                    systemImage: "chevron.backward",
                                    leading: true)
                        }
                        .buttonStyle(.plain)
                    }
                    if let next = nextSection {
                        NavigationLink(value: ReaderTarget.section(next)) {
                            navChip(caption: "Next passage",
                                    section: next,
                                    systemImage: "chevron.forward",
                                    leading: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    private func navChip(caption: String,
                         section: ManzilSection,
                         systemImage: String,
                         leading: Bool) -> some View {
        HStack(spacing: 10) {
            if leading {
                Image(systemName: systemImage).foregroundStyle(Theme.emerald)
            }
            VStack(alignment: leading ? .leading : .trailing, spacing: 2) {
                Text(caption)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(section.titleEnglish)
                    .font(.system(.subheadline, design: .serif).weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: leading ? .leading : .trailing)
            if !leading {
                Image(systemName: systemImage).foregroundStyle(Theme.emerald)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .cardStyle(scheme)
    }

    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .controlSize(.large)
                .tint(Theme.emerald)
            Text("Loading verses…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(Theme.gold)
            Text("Couldn't load the verses")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try again") {
                Task { await reload() }
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.emerald)
        }
        .frame(maxWidth: .infinity, minHeight: 240)
        .padding()
    }
}
