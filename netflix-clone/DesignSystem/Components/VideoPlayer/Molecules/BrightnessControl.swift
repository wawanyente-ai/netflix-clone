//
//  BrightnessControl.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// A vertical brightness slider: a sun glyph above a bar that fills from
/// the bottom to show the current level. Drag anywhere on the bar to
/// change the value.
///
/// ```swift
/// @State private var brightness = 0.65
/// BrightnessControl(level: $brightness, size: .large)
/// ```
struct BrightnessControl: View {

    // MARK: Types

    enum Size { case large, small }

    // MARK: Properties

    @Binding var level: Double
    var size: Size = .large

    // MARK: Body

    var body: some View {
        let metrics = Metrics.metrics(for: size)

        VStack(spacing: metrics.spacing) {
            TemplateIcon(image: Image.Icon.brightness, size: metrics.iconSize, tint: Color.Neutral.greyLight3)

            GeometryReader { proxy in
                ZStack(alignment: .bottom) {
                    Capsule().fill(Color.Neutral.grey)
                    Capsule()
                        .fill(Color.Neutral.white)
                        .frame(height: proxy.size.height * CGFloat(level))
                }
                .contentShape(Rectangle())
                .gesture(dragGesture(in: proxy.size.height))
            }
            .frame(width: metrics.barWidth, height: metrics.barHeight)
        }
        // Figma's drop shadow (rgba(0,16,61,0.48)) isn't a catalog token;
        // approximated with a translucent `Neutral.black` instead of a
        // raw color.
        .shadow(color: Color.Neutral.black.opacity(0.4), radius: 24, x: 0, y: 16)
    }
}

// MARK: - Gesture

private extension BrightnessControl {
    func dragGesture(in height: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let ratio = 1 - Double(value.location.y / height)
                level = min(max(ratio, 0), 1)
            }
    }
}

// MARK: - Metrics

private extension BrightnessControl {
    struct Metrics {
        let iconSize: CGFloat
        let barWidth: CGFloat
        let barHeight: CGFloat
        let spacing: CGFloat

        static func metrics(for size: Size) -> Metrics {
            switch size {
            case .large:
                Metrics(iconSize: 24, barWidth: 6, barHeight: 124, spacing: 8)
            case .small:
                Metrics(iconSize: 12, barWidth: 3, barHeight: 64, spacing: 4)
            }
        }
    }
}

// MARK: - Preview

#Preview("BrightnessControl") {
    struct PreviewHost: View {
        @State private var level = 0.65
        var body: some View {
            HStack(spacing: 40) {
                BrightnessControl(level: $level, size: .large)
                BrightnessControl(level: $level, size: .small)
            }
            .padding()
            .background(Color.Neutral.black)
        }
    }
    return PreviewHost()
}