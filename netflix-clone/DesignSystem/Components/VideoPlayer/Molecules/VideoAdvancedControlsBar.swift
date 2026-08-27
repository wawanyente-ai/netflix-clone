//
//  VideoAdvancedControlsBar.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// The secondary control row shown alongside the scrubber: playback
/// speed, screen lock, and audio & subtitles.
///
/// ```swift
/// VideoAdvancedControlsBar(
///     speedLabel: "Speed (1x)",
///     onSpeedTap: { ... },
///     onLockTap: { ... },
///     onSubtitlesTap: { ... }
/// )
/// ```
struct VideoAdvancedControlsBar: View {

    // MARK: Properties

    var speedLabel: String = "Speed (1x)"
    var isLocked: Bool = false
    var onSpeedTap: () -> Void
    var onLockTap: () -> Void
    var onSubtitlesTap: () -> Void

    // MARK: Body

    var body: some View {
        HStack {
            control(icon: Image.Icon.speed, label: speedLabel, action: onSpeedTap)
            Spacer()
            control(
                icon: isLocked ? Image.Icon.lockClosed : Image.Icon.lockOpen,
                label: "Lock",
                action: onLockTap
            )
            Spacer()
            control(icon: Image.Icon.subtitles, label: "Audio & Subtitles", action: onSubtitlesTap)
        }
    }
}

// MARK: - Control

private extension VideoAdvancedControlsBar {
    func control(icon: Image, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Metrics.spacing) {
                TemplateIcon(image: icon, size: Metrics.iconSize, tint: Color.Neutral.white)
                Text(label)
                    .font(.Typography.Medium.caption1)
                    .foregroundStyle(Color.Neutral.white)
            }
        }
        .buttonStyle(RowButtonStyle())
    }
}

// MARK: - Style

private extension VideoAdvancedControlsBar {
    /// Per DS convention #4: pressed feedback = opacity 0.8 + easeOut(0.1).
    struct RowButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 0.8 : 1)
                .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
        }
    }
}

// MARK: - Metrics

private extension VideoAdvancedControlsBar {
    enum Metrics {
        static let spacing: CGFloat = 6
        static let iconSize: CGFloat = 21
    }
}

// MARK: - Preview

#Preview {
    VideoAdvancedControlsBar(onSpeedTap: {}, onLockTap: {}, onSubtitlesTap: {})
        .padding()
        .background(Color.Neutral.black)
}