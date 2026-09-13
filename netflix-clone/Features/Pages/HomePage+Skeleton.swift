//
//  HomePage+Skeleton.swift
//  netflix-clone
//

import SwiftUI

extension HomePage {

    // MARK: - Loading Skeleton

    var loadingSkeleton: some View {
        VStack(alignment: .leading, spacing: 24) {
            // ← hero skeleton
            ShimmerView()
                .frame(height: 480)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // ← rail skeleton (3 shimmer cards)
            VStack(alignment: .leading, spacing: 8) {
                ShimmerView()
                    .frame(width: 150, height: 20) // ← judul rail placeholder
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { _ in // ← 6 poster skeleton
                        ShimmerView()
                            .frame(width: 106, height: 152) // ← ukuran poster
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}