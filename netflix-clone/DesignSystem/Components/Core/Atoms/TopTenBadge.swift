//
//  TopTenBadge.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//

import SwiftUI

/// **Atom** — the "TOP 10" ribbon badge shown on trending titles.
///
/// Shape: trapezium — rusuk kiri lebih panjang, rusuk kanan lebih pendek.
/// "TOP" 6pt bold, angka 10pt bold, warna teks #FDFDFD (≈ white).
/// `scale` parameter: 1.0 = full size (17×24), 0.53 = mini (≈9×13 for top search cards).
struct TopTenBadge: View {

    var scale: CGFloat = 1.0 // ← ubah skala badge (1.0 = full, 0.53 = mini)
    var cornerRadius: CGFloat = 0 // ← ubah radius corner (0 = tanpa, 4 = clip ke title card)

    var body: some View {
        VStack(spacing: 0) {
            Text("TOP")
                .font(.system(size: TopTenMetrics.topFontSize * scale, weight: .bold)) // ← ubah ukuran font "TOP"
                .tracking(0.5)

            Text("10")
                .font(.system(size: TopTenMetrics.numberFontSize * scale, weight: .bold)) // ← ubah ukuran font angka
        }
        .foregroundStyle(
            Color.Neutral.white // ← pakai token white (sudah cukup mirip #FDFDFD)
        )
        .frame(
            width: TopTenMetrics.width * scale,   // ← ubah lebar badge
            height: TopTenMetrics.height * scale  // ← ubah tinggi badge
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .background(
            TrapeziumShape()
                .fill(Color.Primary.red) // ← ubah warna background
        )
    }
}

// MARK: - Shape

private struct TrapeziumShape: Shape {
    /// Rusuk kiri lebih panjang (87.5%), rusuk kanan lebih pendek.
    /// Proporsional — menyesuaikan ukuran frame.
    func path(in rect: CGRect) -> Path {
        let leftEdgeY = rect.height * 0.875 // ← ubah proporsi rusuk kiri (0.875 = 21/24)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))         // top-left
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))      // top-right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))      // bottom-right (full height)
        path.addLine(to: CGPoint(x: rect.minX, y: leftEdgeY))      // bottom-left (rusuk kiri)
        path.closeSubpath()
        return path
    }
}

// MARK: - Metrics

private enum TopTenMetrics {
    static let width: CGFloat = 17          // ← ubah lebar badge
    static let height: CGFloat = 24         // ← ubah tinggi badge
    static let topFontSize: CGFloat = 6     // ← ubah ukuran font "TOP"
    static let numberFontSize: CGFloat = 10 // ← ubah ukuran font angka
}

// MARK: - Preview

#Preview {
    HStack(spacing: 16) {
        VStack {
            TopTenBadge()
            Text("Full (17×24)")
        }
        VStack {
            TopTenBadge(scale: 0.53, cornerRadius: 4)
            Text("Mini + clip (9×13)")
        }
    }
    .padding()
    .background(Color.Neutral.black)
}
