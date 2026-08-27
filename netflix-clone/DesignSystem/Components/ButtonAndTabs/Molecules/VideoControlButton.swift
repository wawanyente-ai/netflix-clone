//
//  VideoControlButton.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 24/08/26.
//

import SwiftUI

struct VideoControlButton: View {

    // MARK: - Types

    enum PlayStyle {
        case thumbnailSmall   // stroke putih dalam 3pt, container 32×32
        case thumbnailLarge   // stroke merah solid 1pt, container 54×54
        case videoLarge       // tanpa stroke, icon 42×42
        case videoSmall       // tanpa stroke, icon 28×28
    }

    enum PauseStyle {
        case small            // icon 24×24, tanpa stroke
        case large            // icon 42×42, tanpa stroke
    }

    enum SkipStyle {
        case small            // icon 22×22
        case large            // icon 40×40
    }

    enum Variant {
        case play(PlayStyle)
        case pause(PauseStyle)
        case mirror           // bg greyDark2, radius 100%, icon 18
        case close            // sama dengan mirror
        case skipForward(SkipStyle)
        case skipBackward(SkipStyle)
    }

    // MARK: - Properties

    private let variant: Variant
    private let action: () -> Void

    // MARK: - Initialization

    init(
        variant: Variant,
        action: @escaping () -> Void
    ) {
        self.variant = variant
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            icon
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(
                    width: metrics.iconSize,    // ← ubah ukuran icon
                    height: metrics.iconSize
                )
                .foregroundStyle(metrics.iconColor) // ← ubah warna tint icon
                .frame(
                    width: metrics.containerSize,  // ← ubah ukuran tap-target
                    height: metrics.containerSize
                )
                .background(metrics.backgroundColor) // ← ubah warna latar
                .clipShape(Circle())
                .overlay(strokeOverlay)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stroke Overlay

private extension VideoControlButton {

    @ViewBuilder
    var strokeOverlay: some View {
        // ← ketebalan / warna border: ubah di metrics.strokeWidth & metrics.strokeColor
        if metrics.strokeWidth > 0 {
            Circle()
                .strokeBorder(
                    metrics.strokeColor,       // ← ubah warna border
                    lineWidth: metrics.strokeWidth // ← ubah ketebalan border (0 = tanpa border)
                )
        }
    }
}

// MARK: - Icon

private extension VideoControlButton {

    var icon: Image {
        switch variant {
        case .play:
            Image.Icon.play

        case .pause:
            Image.Icon.pause

        case .mirror:
            Image.Icon.mirror

        case .close:
            Image.Icon.close

        case .skipForward:
            Image.Icon.skipForward

        case .skipBackward:
            Image.Icon.skipBackward
        }
    }
}

// MARK: - Metrics

private extension VideoControlButton {

    struct Metrics {
        let iconSize: CGFloat        // ← ubah ukuran icon
        let containerSize: CGFloat   // ← ubah ukuran tap-target / keseluruhan
        let strokeWidth: CGFloat     // ← ubah ketebalan border (0 = tanpa border)
        let strokeColor: Color       // ← ubah warna border
        let backgroundColor: Color   // ← ubah warna latar belakang
        let iconColor: Color         // ← ubah warna tint icon
    }

    var metrics: Metrics {
        switch variant {
        // ── Play ────────────────────────────────────────────────
        case let .play(style):
            switch style {
            case .thumbnailSmall:
                Metrics(
                    iconSize: 20,
                    containerSize: 32,
                    strokeWidth: 3,           // ← ketebalan border putih dalam
                    strokeColor: Color.Neutral.white,
                    backgroundColor: Color.clear,
                    iconColor: Color.Neutral.white
                )

            case .thumbnailLarge:
                Metrics(
                    iconSize: 32,
                    containerSize: 54,
                    strokeWidth: 1,           // ← ketebalan border merah
                    strokeColor: Color.Primary.red,
                    backgroundColor: Color.clear,
                    iconColor: Color.Neutral.white
                )

            case .videoLarge:
                Metrics(
                    iconSize: 42,
                    containerSize: 42,
                    strokeWidth: 0,           // ← tanpa border
                    strokeColor: Color.clear,
                    backgroundColor: Color.clear,
                    iconColor: Color.Neutral.white
                )

            case .videoSmall:
                Metrics(
                    iconSize: 28,
                    containerSize: 28,
                    strokeWidth: 0,
                    strokeColor: Color.clear,
                    backgroundColor: Color.clear,
                    iconColor: Color.Neutral.white
                )
            }

        // ── Pause ───────────────────────────────────────────────
        case let .pause(style):
            switch style {
            case .small:
                Metrics(
                    iconSize: 24,
                    containerSize: 24,
                    strokeWidth: 0,
                    strokeColor: Color.clear,
                    backgroundColor: Color.clear,
                    iconColor: Color.Neutral.white
                )

            case .large:
                Metrics(
                    iconSize: 42,
                    containerSize: 42,
                    strokeWidth: 0,
                    strokeColor: Color.clear,
                    backgroundColor: Color.clear,
                    iconColor: Color.Neutral.white
                )
            }

        // ── Mirror / Close ──────────────────────────────────────
        case .mirror, .close:
            Metrics(
                iconSize: 18,
                containerSize: 28,
                strokeWidth: 0,
                strokeColor: Color.clear,
                backgroundColor: Color.Neutral.greyDark2, // ← ubah warna latar mirror/close
                iconColor: Color.Neutral.white
            )

        // ── Skip ────────────────────────────────────────────────
        case let .skipForward(style),
             let .skipBackward(style):
            switch style {
            case .small:
                Metrics(
                    iconSize: 22,
                    containerSize: 22,
                    strokeWidth: 0,
                    strokeColor: Color.clear,
                    backgroundColor: Color.clear,
                    iconColor: Color.Neutral.white
                )

            case .large:
                Metrics(
                    iconSize: 40,
                    containerSize: 40,
                    strokeWidth: 0,
                    strokeColor: Color.clear,
                    backgroundColor: Color.clear,
                    iconColor: Color.Neutral.white
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("Video Control Button") {
    ScrollView {
        VStack(alignment: .leading, spacing: 32) {
            previewSection(title: "Play") {
                HStack(spacing: 24) {
                    VideoControlButton(variant: .play(.thumbnailSmall)) {}
                    VideoControlButton(variant: .play(.thumbnailLarge)) {}
                    VideoControlButton(variant: .play(.videoLarge)) {}
                    VideoControlButton(variant: .play(.videoSmall)) {}
                }
            }

            previewSection(title: "Pause") {
                HStack(spacing: 24) {
                    VideoControlButton(variant: .pause(.small)) {}
                    VideoControlButton(variant: .pause(.large)) {}
                }
            }

            previewSection(title: "Skip") {
                HStack(spacing: 24) {
                    VideoControlButton(variant: .skipBackward(.small)) {}
                    VideoControlButton(variant: .skipBackward(.large)) {}
                    VideoControlButton(variant: .skipForward(.small)) {}
                    VideoControlButton(variant: .skipForward(.large)) {}
                }
            }

            previewSection(title: "Utility") {
                HStack(spacing: 24) {
                    VideoControlButton(variant: .mirror) {}
                    VideoControlButton(variant: .close) {}
                }
            }
        }
        .padding(24)
    }
    .background(Color.black)
}

private func previewSection<Content: View>(
    title: String,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack(alignment: .leading, spacing: 16) {
        Text(title)
            .font(.headline)
            .foregroundStyle(Color.Neutral.white)
        content()
    }
}
