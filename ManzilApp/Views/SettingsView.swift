import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Translation") {
                    Toggle("Show translation", isOn: $settings.showTranslation)

                    if settings.showTranslation {
                        Picker("Language", selection: $settings.translationEdition) {
                            ForEach(Editions.translations) { t in
                                Text("\(t.language) — \(t.name)")
                                    .tag(t.identifier)
                            }
                        }
                    }
                }

                Section("Recitation") {
                    Picker("Reciter", selection: $settings.reciterEdition) {
                        ForEach(Editions.reciters) { r in
                            Text(r.name).tag(r.identifier)
                        }
                    }
                    Toggle("Auto-play next ayah", isOn: $settings.autoPlayNext)
                }

                Section("Arabic text") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Font size")
                            Spacer()
                            Text("\(Int(settings.arabicFontSize)) pt")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $settings.arabicFontSize, in: 22...46, step: 1)
                            .tint(Theme.emerald)
                        Text("ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ")
                            .font(.custom(Theme.arabicFontName, size: settings.arabicFontSize))
                            .environment(\.layoutDirection, .rightToLeft)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 4)
                    }
                }

                Section("Appearance") {
                    Picker("Theme", selection: $settings.appearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("About") {
                    LabeledContent("App", value: "Manzil")
                    LabeledContent("Purpose", value: "Protection & healing")
                    Text("Qur'anic text, translations and audio are provided by the AlQuran Cloud API. Inspired by quran-manzil.com.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    SettingsView().environmentObject(AppSettings())
}
