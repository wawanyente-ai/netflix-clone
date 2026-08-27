//
//  TemplateIcon.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// **Atom** — a catalog icon rendered with the design system's standard
/// icon pattern (resizable, template rendering, tinted via
/// `foregroundStyle`).
///
/// Wraps the pattern documented in the DS README:
/// ```swift
/// icon
///     .resizable()
///     .renderingMode(.template)
///     .scaledToFit()
///     .frame(width: size, height: size)
/// ```
///
/// Shared by `SearchBar` (search glyph), `InputField` (error glyph), and
/// `ClearButton` (its inner "x") — the one piece of visual logic that's
/// genuinely identical across every icon usage in this component group.
struct TemplateIcon: View {
    let image: Image
    var size: CGFloat
    var tint: Color

    var body: some View {
        image
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(tint)
    }
}

#Preview {
    HStack(spacing: 16) {
        TemplateIcon(image: Image.Icon.search, size: 16, tint: Color.Semantic.textTertiary)
        TemplateIcon(image: Image.Icon.error, size: 24, tint: Color.Semantic.error)
    }
    .padding()
    .background(Color.Neutral.black)
}