//
//  ClearButton.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// **Atom** — the round "x" clear control from the Figma
/// "Search / Clear (styled using Global Icon Set)" atom.
///
/// Purely presentational plus a tap action — the parent molecule decides
/// *when* to show it and *what* the tap should do (e.g. clear text vs.
/// resign focus), keeping this atom dumb and reusable.
struct ClearButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            TemplateIcon(
                image: Image.Icon.close,
                size: Metrics.glyphSize,
                tint: Color.Neutral.greyDark2
            )
            .padding(Metrics.padding)
            .background(Color.Neutral.grey)
            .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Metrics

private extension ClearButton {
    enum Metrics {
        /// 16pt control per the Figma spec: an 8pt glyph inset by 4pt on
        /// each side inside the circular tap target.
        static let glyphSize: CGFloat = 8
        static let padding: CGFloat = 4
    }
}

#Preview {
    ClearButton {}
        .padding()
        .background(Color.Neutral.black)
}