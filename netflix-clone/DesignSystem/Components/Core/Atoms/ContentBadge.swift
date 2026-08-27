//
//  ContentBadge.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//

import SwiftUI

/// **Atom** — a solid-color content label badge (e.g. "NEW EPISODES").
///
/// Background `redDark1`, font size 8 bold all caps, white text.
/// Horizontal padding 8, vertical padding 2.
struct ContentBadge: View {
    let text: String
    var backgroundColor: Color = Color.Primary.redDark1 // ← ubah warna background
    var foregroundColor: Color = Color.Neutral.white    // ← ubah warna font

    var body: some View {
        Text(text.uppercased()) // ← ubah ke kapital semua
            .font(.system(size: ContentMetrics.fontSize, weight: .bold)) // ← ubah ukuran font
            .tracking(0.5)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, ContentMetrics.horizontalPadding) // ← ubah padding horizontal
            .padding(.vertical, ContentMetrics.verticalPadding)     // ← ubah padding vertical
            .background(backgroundColor)
            .cornerRadius(ContentMetrics.cornerRadius)
    }
}

// MARK: - Metrics

private enum ContentMetrics {
    static let fontSize: CGFloat = 8            // ← ubah ukuran font
    static let horizontalPadding: CGFloat = 8   // ← ubah padding horizontal
    static let verticalPadding: CGFloat = 2     // ← ubah padding vertical
    static let cornerRadius: CGFloat = 2        // ← ubah sudut rounded
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {
        TopTenBadge()
        ContentBadge(text: "New Episodes")
        ContentBadge(text: "Leaving Soon")
    }
    .padding()
    .background(Color.Neutral.black)
}
