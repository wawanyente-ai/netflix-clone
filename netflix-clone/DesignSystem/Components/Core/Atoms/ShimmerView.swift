//
//  ShimmerView.swift
//  netflix-clone
//

import SwiftUI

/// Animated shimmer loading placeholder.
/// Displays a gradient animation that simulates content loading.
struct ShimmerView: View {

    @State private var phase: CGFloat = 0 // ← animasi phase

    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                colors: [
                    Color.Neutral.greyDark2,           // ← ubah warna awal shimmer
                    Color.Neutral.greyDark3.opacity(0.5), // ← ubah warna tengah shimmer
                    Color.Neutral.greyDark2            // ← ubah warna akhir shimmer
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: phase * geometry.size.width) // ← geser gradient
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5) // ← ubah kecepatan shimmer
                    .repeatForever(autoreverses: false) // ← loop terus
                ) {
                    phase = 1 // ← animasi dari kiri ke kanan
                }
            }
        }
        .clipped()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        ShimmerView()
            .frame(width: 106, height: 152) // ← ukuran poster
            .clipShape(RoundedRectangle(cornerRadius: 4))

        ShimmerView()
            .frame(width: 300, height: 20) // ← ukuran text line
            .clipShape(RoundedRectangle(cornerRadius: 4))

        ShimmerView()
            .frame(width: 60, height: 60) // ← ukuran avatar
            .clipShape(Circle())
    }
    .padding()
    .background(Color.Neutral.black)
}
