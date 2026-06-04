import SwiftUI

/// What the reader screen should display.
enum ReaderTarget: Hashable {
    case section(ManzilSection)
    case full
}

struct HomeView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.colorScheme) private var scheme
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    sectionList
                    footer
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(Theme.background(scheme).ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Theme.emerald)
                    }
                }
            }
            .navigationDestination(for: ReaderTarget.self) { target in
                switch target {
                case .section(let s): ReaderView(target: .section(s))
                case .full:           ReaderView(target: .full)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("منزل")
                .font(.custom(Theme.arabicFontName, size: 56))
                .foregroundStyle(.white)
                .environment(\.layoutDirection, .rightToLeft)
            Text("Manzil")
                .font(.system(.title2, design: .serif).weight(.semibold))
                .foregroundStyle(.white)
            Text("Verses of the Qur'an for protection and healing")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .background(EmeraldHeader())
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Theme.gold.opacity(0.5), lineWidth: 1)
        )
        .padding(.top, 8)
    }

    private var sectionList: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Verses")
                    .font(.system(.title3, design: .serif).weight(.semibold))
                Spacer()
                Text("\(QuranData.manzil.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 6)

            ForEach(QuranData.manzil) { section in
                NavigationLink(value: ReaderTarget.section(section)) {
                    SectionRowView(section: section)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var footer: some View {
        VStack() {
            Text("Recitation & text courtesy of AlQuran Cloud")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.top, 10)
            
            Text("Developed by FVTRX.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        
    }
}

#Preview {
    HomeView().environmentObject(AppSettings())
}
