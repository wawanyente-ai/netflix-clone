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

    let variant: Variant
    let action: () -> Void

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