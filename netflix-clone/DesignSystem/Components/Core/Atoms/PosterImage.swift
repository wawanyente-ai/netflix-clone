//
//  PosterImage.swift
//  netflix-clone
//

import SwiftUI

/// Reusable poster image component with proper AsyncImage layout.
/// Handles loading, error, and placeholder states with shimmer.
struct PosterImage: View {

    let url: URL?
    var width: CGFloat = 106   // ← ubah lebar poster
    var height: CGFloat = 152  // ← ubah tinggi poster
    var cornerRadius: CGFloat = 4 // ← ubah corner radius

    var body: some View {
        CachedAsyncImage(url: url) { phase in // ← pakai cache (memory + disk), shimmer cuma sekali
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill) // ← fill frame, maintain aspect ratio
            case .failure:
                errorPlaceholder
            case .empty:
                shimmerPlaceholder // ← shimmer saat loading
            @unknown default:
                shimmerPlaceholder
            }
        }
        .frame(width: width, height: height) // ← constrain frame DULU
        .clipped() // ← clip ke frame
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius)) // ← clip shape
        .background(Color.Neutral.greyDark2) // ← background placeholder
    }

    // MARK: - Error Placeholder

    private var errorPlaceholder: some View {
        ZStack {
            Color.Neutral.greyDark2 // ← ubah warna placeholder error
            Image.Icon.error // ← pakai asset catalog (bukan SF Symbol)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.Neutral.greyDark1) // ← ubah warna icon
        }
        .frame(width: width, height: height)
    }

    // MARK: - Shimmer Placeholder

    private var shimmerPlaceholder: some View {
        ShimmerView()
            .frame(width: width, height: height)
    }
}

// MARK: - Backdrop Image

/// Reusable backdrop/hero image component.
/// Uses fixed frame + overlay to prevent AsyncImage layout explosion.
struct BackdropImage: View {

    let url: URL?
    var height: CGFloat = 480 // ← ubah tinggi backdrop
    var cornerRadius: CGFloat = 0 // ← ubah corner radius

    var body: some View {
        GeometryReader { geo in
            CachedAsyncImage(url: url) { phase in // ← pakai cache (memory + disk), shimmer cuma sekali
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill() // ← fill the geometry frame
                        .frame(width: geo.size.width, height: geo.size.height) // ← force frame
                        .clipped() // ← clip to exact size
                case .failure:
                    errorPlaceholder
                case .empty:
                    shimmerPlaceholder
                @unknown default:
                    shimmerPlaceholder
                }
            }
            .frame(width: geo.size.width, height: geo.size.height) // ← constrain AsyncImage
        }
        .frame(height: height) // ← outer height constraint
        .frame(maxWidth: .infinity) // ← full width
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .background(Color.Neutral.greyDark1) // ← background placeholder
    }

    private var errorPlaceholder: some View {
        ZStack {
            Color.Neutral.greyDark1
            Image.Icon.error // ← pakai asset catalog
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundStyle(Color.Neutral.greyDark2)
        }
        .frame(height: height)
    }

    private var shimmerPlaceholder: some View {
        ShimmerView()
            .frame(height: height)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile Image

/// Small circular profile image for cast members.
struct ProfileImage: View {

    let url: URL?
    var size: CGFloat = 60 // ← ubah ukuran

    var body: some View {
        CachedAsyncImage(url: url) { phase in // ← pakai cache (memory + disk), shimmer cuma sekali
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                errorPlaceholder
            case .empty:
                shimmerPlaceholder
            @unknown default:
                shimmerPlaceholder
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .clipShape(Circle())
        .background(Color.Neutral.greyDark2)
    }

    private var errorPlaceholder: some View {
        ZStack {
            Color.Neutral.greyDark2
            Image.Icon.user // ← pakai asset catalog
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.4, height: size * 0.4)
                .foregroundStyle(Color.Neutral.greyDark1)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var shimmerPlaceholder: some View {
        ShimmerView()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        PosterImage(url: nil)
        BackdropImage(url: nil, height: 200)
        ProfileImage(url: nil)
    }
    .padding()
    .background(Color.Neutral.black)
}
