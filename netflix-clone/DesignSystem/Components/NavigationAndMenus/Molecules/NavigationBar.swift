//
//  NavigationBar.swift
//  netflix-clone
//

import SwiftUI

/// Floating pill bottom tab bar with glassmorphism effect.
/// Active tab shows a pill-shaped selection indicator.
///
/// ```swift
/// @State private var tab: NavigationBar.Tab = .home
/// NavigationBar(selection: $tab)
/// ```
struct NavigationBar: View {

    @Binding var selection: Tab // ← tab aktif

    // MARK: - Types

    enum Tab: CaseIterable {
        case home
        case klip
        case search
        case downloads

        var icon: Image {
            switch self {
            case .home: Image.Icon.home           // ← ubah icon home
            case .klip: Image.Icon.playStacked    // ← ubah icon klip
            case .search: Image.Icon.search       // ← ubah icon search
            case .downloads: Image.UserVariant.blue // ← ubah icon downloads ke user blue
            }
        }

        var title: String {
            switch self {
            case .home: "Home"                     // ← ubah label home
            case .klip: "Klip"                     // ← ubah label klip
            case .search: "Cari"                   // ← ubah label search
            case .downloads: "Netflix Saya"        // ← ubah label downloads
            }
        }
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: Metrics.itemSpacing) { // ← ubah gap antar item
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, Metrics.horizontalPadding) // ← ubah inset horizontal
        .padding(.vertical, Metrics.verticalPadding) // ← ubah inset vertical
        .background(
            // ← glassmorphism effect (lebih gelap)
            Capsule()
                .fill(.ultraThinMaterial) // ← material transparan
                .overlay(
                    Capsule()
                        .fill(Color.Neutral.black.opacity(0.6)) // ← overlay gelap tambahan
                )
                .overlay(
                    Capsule()
                        .stroke(
                            Color.Neutral.white.opacity(0.1), // ← ubah warna border glass
                            lineWidth: 0.5 // ← ubah ketebalan border glass
                        )
                )
        )
        .padding(.horizontal, Metrics.containerHorizontalPadding) // ← ubah inset container
        .padding(.bottom, Metrics.containerBottomPadding) // ← ubah inset bawah (floating)
    }

    // MARK: - Tab Button

    private func tabButton(for tab: Tab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { // ← ubah animasi selection
                selection = tab
            }
        } label: {
            tabLabel(for: tab)
        }
        .buttonStyle(TabButtonStyle())
    }

    // MARK: - Tab Label

    @ViewBuilder
    private func tabLabel(for tab: Tab) -> some View {
        let isActive = tab == selection

        VStack(spacing: Metrics.iconLabelSpacing) { // ← stack vertical: icon atas, teks bawah
            // ← icon (UserVariant.blue ga pakai template, icon lain pakai template)
            if tab == .downloads {
                Image.UserVariant.blue
                    .resizable()
                    .scaledToFit()
                    .frame(width: Metrics.iconSize, height: Metrics.iconSize) // ← ubah ukuran icon
                    .clipShape(RoundedRectangle(cornerRadius: 4)) // ← ubah corner radius
            } else {
                TemplateIcon(
                    image: tab.icon,
                    size: Metrics.iconSize, // ← ubah ukuran icon
                    tint: isActive
                        ? Color.Neutral.white // ← ubah warna icon aktif (putih)
                        : Color.Neutral.greyLight1 // ← ubah warna icon inactive (lebih terang)
                )
            }

            Text(tab.title)
                .font(.Typography.Light.caption2) // ← ubah font label (selalu tampil)
                .foregroundStyle(
                    isActive
                        ? Color.Neutral.white // ← ubah warna label aktif (putih)
                        : Color.Neutral.greyLight1 // ← ubah warna label inactive (lebih terang)
                )
        }
        .padding(.horizontal, isActive ? Metrics.activeHorizontalPadding : Metrics.inactiveHorizontalPadding) // ← ubah padding horizontal
        .padding(.vertical, Metrics.verticalPadding) // ← ubah padding vertical
        .background(
            // ← pill selection indicator
            isActive
                ? AnyView(
                    Capsule()
                        .fill(Color.Neutral.white.opacity(0.15)) // ← ubah warna pill aktif (putih transparan)
                        .overlay(
                            Capsule()
                                .stroke(Color.Neutral.white.opacity(0.2), lineWidth: 0.5) // ← ubah warna border pill
                        )
                  )
                : AnyView(EmptyView())
        )
    }
}

// MARK: - Style

private extension NavigationBar {
    /// Per DS convention: pressed feedback = opacity 0.8 + easeOut(0.1).
    struct TabButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 0.7 : 1) // ← ubah opacity pressed
                .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
        }
    }
}

// MARK: - Metrics

private extension NavigationBar {
    enum Metrics {
        static let horizontalPadding: CGFloat = 8      // ← ubah padding horizontal items
        static let verticalPadding: CGFloat = 8         // ← ubah padding vertical items
        static let itemSpacing: CGFloat = 4             // ← ubah gap antar item
        static let containerHorizontalPadding: CGFloat = 16 // ← ubah inset container kiri-kanan
        static let containerBottomPadding: CGFloat = 12 // ← ubah inset container bawah (lebih ke bawah)
        static let iconSize: CGFloat = 20               // ← ubah ukuran icon
        static let iconLabelSpacing: CGFloat = 4        // ← ubah gap icon-to-label
        static let activeHorizontalPadding: CGFloat = 16 // ← ubah padding horizontal aktif (lebih panjang)
        static let inactiveHorizontalPadding: CGFloat = 8 // ← ubah padding horizontal inactive
    }
}

// MARK: - Preview

#Preview("Floating Pill NavigationBar") {
    struct PreviewHost: View {
        @State private var tab: NavigationBar.Tab = .home

        var body: some View {
            VStack {
                Spacer()
                NavigationBar(selection: $tab)
            }
            .background(Color.Neutral.black)
        }
    }
    return PreviewHost()
}
