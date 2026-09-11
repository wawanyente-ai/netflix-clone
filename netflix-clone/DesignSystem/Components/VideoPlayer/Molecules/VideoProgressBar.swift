//
//  VideoProgressBar.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// The scrubber row: total-time track, red watched-progress fill, a
/// draggable thumb, and a trailing time label.
///
/// `progress` is normalized 0...1 and drives both the fill width and the
/// thumb position; dragging anywhere on the track updates it live.
///
/// ```swift
/// @State private var progress = 0.58
/// VideoProgressBar(progress: $progress, size: .large, timeLabel: "7:40")
/// ```
struct VideoProgressBar: View {

    // MARK: Types

    enum Size { case large, small }

    // MARK: Properties

    @Binding var progress: Double
    var size: Size = .large
    var timeLabel: String
    var onSeek: (Double) -> Void = { _ in } // ← panggil saat drag selesai (ratio 0...1)

    // MARK: Body

    var body: some View {
        let metrics = Metrics.metrics(for: size)

        HStack(spacing: metrics.spacing) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.Neutral.grey)
                        .frame(height: metrics.trackHeight)

                    Capsule()
                        .fill(Color.Primary.red)
                        .frame(width: proxy.size.width * CGFloat(progress), height: metrics.trackHeight)

                    Circle()
                        .fill(Color.Primary.red)
                        .frame(width: metrics.thumbSize, height: metrics.thumbSize)
                        .offset(x: (proxy.size.width - metrics.thumbSize) * CGFloat(progress))
                }
                .contentShape(Rectangle())
                .gesture(dragGesture(in: proxy.size.width))
            }
            .frame(height: metrics.thumbSize)

            Text(timeLabel)
                .font(.Typography.Light.label3)
                .foregroundStyle(Color.Neutral.white)
                .fixedSize()
        }
    }
}

// MARK: - Gesture

private extension VideoProgressBar {
    func dragGesture(in width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let ratio = Double(value.location.x / width)
                progress = min(max(ratio, 0), 1) // ← update preview progress
            }
            .onEnded { value in
                let ratio = Double(value.location.x / width)
                onSeek(min(max(ratio, 0), 1)) // ← seek ke posisi ini
            }
    }
}

// MARK: - Metrics

private extension VideoProgressBar {
    struct Metrics {
        let thumbSize: CGFloat
        let trackHeight: CGFloat
        let spacing: CGFloat

        static func metrics(for size: Size) -> Metrics {
            switch size {
            case .large:
                // NOTE: Figma's small-track background (#4B4B4B) isn't a
                // catalog token; both sizes use `Neutral.grey` here.
                Metrics(thumbSize: 24, trackHeight: 4, spacing: 12)
            case .small:
                Metrics(thumbSize: 16, trackHeight: 4, spacing: 12)
            }
        }
    }
}

// MARK: - Preview

#Preview("VideoProgressBar") {
    struct PreviewHost: View {
        @State private var progress = 0.58
        var body: some View {
            VStack(spacing: 24) {
                VideoProgressBar(progress: $progress, size: .large, timeLabel: "7:40")
                VideoProgressBar(progress: $progress, size: .small, timeLabel: "7:40")
            }
            .padding()
            .background(Color.Neutral.black)
        }
    }
    return PreviewHost()
}