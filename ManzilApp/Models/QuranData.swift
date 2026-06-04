import Foundation

/// The traditional Manzil — a sequence of Qur'anic passages compiled for
/// protection (ruqyah) and healing. The actual Arabic text, translation and
/// audio are fetched at runtime; this file only describes *which* verses
/// make up the Manzil and in what order.
enum QuranData {

    static let manzil: [ManzilSection] = [
        ManzilSection(id: 1, surahNumber: 1, surahNameArabic: "الفاتحة",
                      titleEnglish: "Al-Fatihah", titleMalay: "Al-Fatihah",
                      groups: [AyahGroup(1, 7)], note: nil),

        ManzilSection(id: 2, surahNumber: 2, surahNameArabic: "البقرة",
                      titleEnglish: "Al-Baqarah", titleMalay: "Al-Baqarah",
                      groups: [
                          AyahGroup(1, 5),
                          AyahGroup(163, 163),
                          AyahGroup(255, 255, note: "Ayat al-Kursi"),
                          AyahGroup(256, 257),
                          AyahGroup(284, 286)
                      ],
                      note: "incl. Ayat al-Kursi"),

        ManzilSection(id: 3, surahNumber: 3, surahNameArabic: "آل عمران",
                      titleEnglish: "Ali 'Imran", titleMalay: "Ali 'Imran",
                      groups: [AyahGroup(18, 18), AyahGroup(26, 27)], note: nil),

        ManzilSection(id: 5, surahNumber: 7, surahNameArabic: "الأعراف",
                      titleEnglish: "Al-A'raf", titleMalay: "Al-A'raf",
                      groups: [AyahGroup(54, 56)], note: nil),

        ManzilSection(id: 6, surahNumber: 17, surahNameArabic: "الإسراء",
                      titleEnglish: "Al-Isra", titleMalay: "Al-Isra'",
                      groups: [AyahGroup(110, 111)], note: nil),

        ManzilSection(id: 7, surahNumber: 23, surahNameArabic: "المؤمنون",
                      titleEnglish: "Al-Mu'minun", titleMalay: "Al-Mu'minun",
                      groups: [AyahGroup(115, 118)], note: nil),

        ManzilSection(id: 8, surahNumber: 37, surahNameArabic: "الصافات",
                      titleEnglish: "As-Saffat", titleMalay: "As-Saffat",
                      groups: [AyahGroup(1, 10)], note: nil),

        ManzilSection(id: 9, surahNumber: 55, surahNameArabic: "الرحمن",
                      titleEnglish: "Ar-Rahman", titleMalay: "Ar-Rahman",
                      groups: [AyahGroup(33, 40)], note: nil),

        ManzilSection(id: 10, surahNumber: 59, surahNameArabic: "الحشر",
                      titleEnglish: "Al-Hashr", titleMalay: "Al-Hasyr",
                      groups: [AyahGroup(21, 24)], note: nil),

        ManzilSection(id: 11, surahNumber: 72, surahNameArabic: "الجن",
                      titleEnglish: "Al-Jinn", titleMalay: "Al-Jinn",
                      groups: [AyahGroup(1, 4)], note: nil),

        ManzilSection(id: 12, surahNumber: 109, surahNameArabic: "الكافرون",
                      titleEnglish: "Al-Kafirun", titleMalay: "Al-Kafirun",
                      groups: [AyahGroup(1, 6)], note: nil),

        ManzilSection(id: 13, surahNumber: 112, surahNameArabic: "الإخلاص",
                      titleEnglish: "Al-Ikhlas", titleMalay: "Al-Ikhlas",
                      groups: [AyahGroup(1, 4)], note: nil),

        ManzilSection(id: 14, surahNumber: 113, surahNameArabic: "الفلق",
                      titleEnglish: "Al-Falaq", titleMalay: "Al-Falaq",
                      groups: [AyahGroup(1, 5)], note: nil),

        ManzilSection(id: 15, surahNumber: 114, surahNameArabic: "الناس",
                      titleEnglish: "An-Nas", titleMalay: "An-Nas",
                      groups: [AyahGroup(1, 6)], note: nil)
    ]

    /// All ayah references across the whole Manzil, in order, for the
    /// continuous "read everything" mode.
    static var allReferences: [String] {
        manzil.flatMap { $0.ayahReferences }
    }
}
