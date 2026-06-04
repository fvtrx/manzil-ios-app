# Manzil — SwiftUI iOS App

A SwiftUI Quran reader for the traditional **Manzil**: a sequence of Qur'anic
passages compiled for protection (*ruqyah*) and healing. Inspired by the
features of [quran-manzil.com](https://www.quran-manzil.com/) — Arabic text,
translations, and audio recitation.

|  Home   | Reader View |
| -------- | ------- |
| <img width="540" height="1240" alt="Simulator Screenshot - iPhone 17 Pro - 2026-06-04 at 13 34 19" src="https://github.com/user-attachments/assets/643ad189-9d71-4c8d-ad5c-fa00e16764f6" /> | <img width="540" height="1240" alt="Simulator Screenshot - iPhone 17 Pro - 2026-06-04 at 13 34 25" src="https://github.com/user-attachments/assets/067cb53f-f78d-4b70-bde8-8ff6ed20daf8" /> |

## Features

- **The full Manzil** — all 18 passages (Al-Fatihah, Ayat al-Kursi, Surah
  Ar-Rahman, the last three surahs, and more) in their traditional order.
- **Beautiful reader** — large Uthmani Arabic (right-to-left), with an
  adjustable font size and a Bismillah header for passages that open a surah.
- **Translations** — Bahasa Melayu (default, like the original site), Bahasa
  Indonesia, and English. Toggle translations on/off.
- **Audio recitation** — per-ayah playback with a floating transport bar,
  five reciters, and auto-advance to the next verse. The currently-reciting
  ayah is highlighted.
- **Continuous mode** — "Read the full Manzil" plays/scrolls every passage in
  sequence with surah dividers.
- **Settings** — reciter, translation language, Arabic font size, auto-play,
  and light/dark/system appearance. All preferences persist.

## Requirements

- **Xcode 16** or later (the project uses the file-system-synchronized group
  format, `objectVersion = 77`).
- iOS 16.0+ deployment target.
- An internet connection — verse text, translations, and audio are fetched
  live from the free [AlQuran Cloud API](https://alquran.cloud).

## Run it

1. Open `ManzilApp.xcodeproj` in Xcode.
2. Select an iPhone simulator (or your device).
3. Press **⌘R**.

Because the project uses a synchronized folder group, every Swift file in the
`ManzilApp/` folder is compiled automatically — no need to add files manually.

## Project structure

```
ManzilApp/
├── ManzilApp.swift            App entry point
├── Models/
│   ├── Ayah.swift             A single assembled verse
│   ├── ManzilSection.swift    One Manzil passage (surah + ayah range)
│   ├── QuranData.swift        The Manzil structure (which verses, in order)
│   └── Editions.swift         Translation & reciter catalog
├── Services/
│   ├── QuranAPIService.swift  Fetches + caches verses from AlQuran Cloud
│   └── AudioPlayer.swift      AVPlayer queue with auto-advance
├── ViewModels/
│   ├── AppSettings.swift      Persisted user preferences
│   └── SectionLoader.swift    Concurrent loading of a section's verses
├── Theme/
│   └── Theme.swift            Emerald/gold palette + card styling
├── Views/
│   ├── HomeView.swift         Manzil list + header
│   ├── ReaderView.swift       Verse reader + audio
│   ├── SettingsView.swift     Preferences
│   └── Components/            AyahCard, SectionRow, Bismillah, AudioControlBar
└── Assets.xcassets/           App icon + accent color
```

## Notes & next steps

- **Offline mode**: verses are cached in memory for the session. To fully
  support offline use, persist the fetched `Ayah` values (e.g. to disk or
  SwiftData) in `QuranAPIService`.
- **Custom Quran font**: the app uses iOS's built-in *Geeza Pro* Arabic face.
  For a more traditional mushaf look, drop a licensed font (e.g. an Uthmanic
  Hafs face) into the project, register it in Info.plist (`UIAppFonts`), and
  update `Theme.arabicFontName`.
- **Background audio**: playback currently runs in the foreground. To keep
  reciting when the app is backgrounded, add the `audio` UIBackgroundMode and
  wire up `MPNowPlayingInfoCenter` / remote commands.

Qur'anic text, translations, and audio are provided by AlQuran Cloud.
