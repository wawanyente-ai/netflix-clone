//
//  VideoControlButton+Metrics.swift
//  netflix-clone
//

import SwiftUI

// MARK: - Metrics

extension VideoControlButton {

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