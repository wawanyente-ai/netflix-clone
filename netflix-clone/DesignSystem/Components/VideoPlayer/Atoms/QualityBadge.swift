//
//  QualityBadge.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// **Atom** — bordered badge wrapping a fixed brand mark (Dolby Vision,
/// HD, Audio Description).
///
/// > These marks aren't in the current `Icons.swift` catalog — they're
/// > logotype shapes, not tintable glyphs. Recommend adding a `Badge`
/// > namespace (e.g. `Image.Badge.dolbyVision`, `.hd`, `.audioDescription`)
/// > mirroring `Image.Brand.*`, then passing the real asset in as `mark`.
/// > Previews below use `Image.Icon.info` as a stand-in only.
struct QualityBadge: View {
    let mark: Image
    var width: CGFloat = Metrics.defaultWidth

    var body: some View {
        mark
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .foregroundStyle(Color.Neutral.greyLight2)
            .padding(.horizontal, Metrics.horizontalInset)
            .frame(width: width, height: Metrics.height)
            .overlay(
                RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                    .stroke(Color.Neutral.greyDark1, lineWidth: 1)
            )
    }
}

private extension QualityBadge {
    enum Metrics {
        static let defaultWidth: CGFloat = 50
        static let height: CGFloat = 14
        static let horizontalInset: CGFloat = 3
        static let cornerRadius: CGFloat = 2
    }
}

#Preview {
    HStack(spacing: 8) {
        QualityBadge(mark: Image.Icon.info, width: 50) // stand-in for Dolby Vision mark
        QualityBadge(mark: Image.Icon.info, width: 17) // stand-in for HD mark
    }
    .padding()
    .background(Color.Neutral.black)
}