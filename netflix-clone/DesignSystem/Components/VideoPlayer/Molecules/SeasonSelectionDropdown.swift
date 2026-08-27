//
//  SeasonSelectionDropdown.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// The "Season N" trigger that opens a season picker.
///
/// Built on SwiftUI's native `Menu`, so this is a real picker, not just a
/// static trigger — selecting an option updates `selection`.
///
/// > The down-chevron isn't in the current `Icons.swift` catalog (no
/// > directional glyphs are cataloged yet). Drawn here as a small custom
/// > `Shape` rather than inventing a non-existent `Image.Icon.*` accessor
/// > or reaching for an SF Symbol — recommend adding a real chevron asset
/// > to the catalog and swapping this out.
///
/// ```swift
/// @State private var season = 1
/// SeasonSelectionDropdown(selection: $season, availableSeasons: 1...5)
/// ```
struct SeasonSelectionDropdown: View {

    // MARK: Properties

    @Binding var selection: Int
    let availableSeasons: ClosedRange<Int>

    // MARK: Body

    var body: some View {
        Menu {
            ForEach(Array(availableSeasons), id: \.self) { season in
                Button("Season \(season)") { selection = season }
            }
        } label: {
            HStack(spacing: Metrics.spacing) {
                Text("Season \(selection)")
                    .font(.Typography.Light.caption1)
                    .foregroundStyle(Color.Neutral.greyLight3)

                ChevronDownMark()
                    .stroke(Color.Neutral.white, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: Metrics.chevronSize, height: Metrics.chevronSize)
            }
        }
    }
}

// MARK: - Chevron

private extension SeasonSelectionDropdown {
    /// A minimal chevron mark — two strokes forming a "v" — standing in
    /// for a not-yet-cataloged directional glyph.
    struct ChevronDownMark: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.25))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.25))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.25))
            return path
        }
    }
}

// MARK: - Metrics

private extension SeasonSelectionDropdown {
    enum Metrics {
        static let spacing: CGFloat = 6
        static let chevronSize: CGFloat = 16
    }
}

// MARK: - Preview

#Preview {
    struct PreviewHost: View {
        @State private var season = 1
        var body: some View {
            SeasonSelectionDropdown(selection: $season, availableSeasons: 1...5)
                .padding()
                .background(Color.Neutral.black)
        }
    }
    return PreviewHost()
}