//
//  KlipPage.swift
//  netflix-clone
//

import SwiftUI

/// Klip tab — vertical scroll with TikTok-like paging.
/// Full-screen vertical paging, each clip shows poster image with overlay info.
/// Content positioned above bottom bar (padding accounts for bar height).
struct KlipPage: View {

    @State private var currentClipIndex: Int = 0

    // ← dummy clip data (replace with real data later)
    let clips: [KlipItem] = [
        KlipItem(
            id: 1, mediaId: 66732, mediaType: "tv",
            title: "Stranger Things",
            subtitle: "Season 4",
            category: "Sci-Fi",
            posterPath: "/49WJfeKV0VVR5fCj2W8cFBfuMum.jpg" // ← TMDB poster path
        ),
        KlipItem(
            id: 2, mediaId: 71912, mediaType: "tv",
            title: "The Witcher",
            subtitle: "Season 3",
            category: "Fantasy",
            posterPath: "/7vjaCdMw15FEbXyLQTVa04URsPm.jpg"
        ),
        KlipItem(
            id: 3, mediaId: 93405, mediaType: "tv",
            title: "Squid Game",
            subtitle: "Season 2",
            category: "Thriller",
            posterPath: "/dDlEmu3EZ0Pgg93K2SVNLCjCSvE.jpg"
        ),
        KlipItem(
            id: 4, mediaId: 119051, mediaType: "tv",
            title: "Wednesday",
            subtitle: "Season 1",
            category: "Comedy",
            posterPath: "/9PFonBhy4cQy7Jz20NpMygczyXY.jpg"
        ),
        KlipItem(
            id: 5, mediaId: 119742, mediaType: "tv",
            title: "One Piece",
            subtitle: "Live Action",
            category: "Adventure",
            posterPath: "/cMD9Ygz11zjJzAovURpO75Qg7rT.jpg"
        )
    ]

    var onPlayTap: (KlipItem) -> Void = { _ in } // ← play (navigasi player)
    var onInfoTap: (KlipItem) -> Void = { _ in } // ← info (navigasi detail)
    var onMyListTap: (KlipItem) -> Void = { _ in } // ← toggle my list (di-gate oleh app root)
    var isInMyList: (KlipItem) -> Bool = { _ in false } // ← status my list
    var isSavingMyList: (KlipItem) -> Bool = { _ in false } // ← loading state toggle my list

    var body: some View {
        ZStack {
            Color.Neutral.black

            // ← vertical paging scroll
            GeometryReader { fullGeo in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(clips.enumerated()), id: \.element.id) { index, clip in
                            clipCard(clip: clip, index: index, screenWidth: fullGeo.size.width, screenHeight: fullGeo.size.height)
                                .frame(height: fullGeo.size.height)
                        }
                    }
                }
                .scrollTargetLayout()
                .scrollTargetBehavior(.paging)
                .refreshable { // ← pull-to-refresh: tarik ke bawah buat reload clips
                    try? await Task.sleep(for: .milliseconds(500)) // ← delay singkat biar visual feedback
                }
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Clip Card

    private func clipCard(clip: KlipItem, index: Int, screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            // ← poster image sebagai background (full screen)
            AsyncImage(url: clip.posterURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill() // ← isi frame penuh, crop overflow biar ga zoom berlebih
                        .frame(width: screenWidth, height: screenHeight) // ← frame eksplisit (width + height)
                        .clipped()
                case .failure:
                    gradientPlaceholder
                case .empty:
                    shimmerPlaceholder
                @unknown default:
                    gradientPlaceholder
                }
            }
            .frame(height: screenHeight) // ← full width di-handle oleh parent
            .clipped()

            // ← gradient overlay gelap di bawah (full width)
            LinearGradient(
                colors: [                         // ← ubah gradient stops
                    .clear,                        // ← atas transparan
                    Color.Neutral.black.opacity(0.3), // ← tengah sedikit gelap
                    Color.Neutral.black.opacity(0.7), // ← bawah lebih gelap
                    Color.Neutral.black.opacity(0.9)  // ← paling bawah hampir hitam
                ],
                startPoint: .top,                 // ← gradient dari atas
                endPoint: .bottom                  // ← ke bawah
            )

            // ← content overlay (full width, naikkan posisi Y)
            VStack(alignment: .leading, spacing: 8) {
                // ← kategori badge
                Text(clip.category)
                    .font(.Typography.Medium.caption2)
                    .foregroundStyle(Color.Primary.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.Primary.red.opacity(0.2))
                    )

                // ← judul (full width)
                Text(clip.title)
                    .font(.Typography.Bold.header1)
                    .foregroundStyle(Color.Semantic.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading) // ← full width, align leading

                // ← subtitle (full width)
                Text(clip.subtitle)
                    .font(.Typography.Medium.label3)
                    .foregroundStyle(Color.Semantic.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading) // ← full width, align leading

                // ← action buttons
                HStack(spacing: 16) {
                    actionButton(
                        icon: isInMyList(clip) && !isSavingMyList(clip) ? Image.Icon.check : Image.Icon.add, // ← centang kalau tersimpan
                        label: isSavingMyList(clip)
                            ? (isInMyList(clip) ? "Menghapus..." : "Menyimpan...") // ← label ikut arah toggle
                            : (isInMyList(clip) ? "Tersimpan" : "My List"), // ← status my list
                        isLoading: isSavingMyList(clip) // ← spinner saat proses toggle
                    ) {
                        onMyListTap(clip) // ← toggle my list
                    }
                    actionButton(icon: Image.Icon.play, label: "Play") {
                        onPlayTap(clip) // ← play
                    }
                    actionButton(icon: Image.Icon.info, label: "Info") {
                        onInfoTap(clip) // ← detail
                    }
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading) // ← full width container
            .padding(.horizontal, 0) // ← full width, tanpa horizontal padding
            .padding(.leading, 24) // ← padding kiri aja
            .padding(.trailing, 24) // ← padding kanan aja
            .padding(.bottom, 140) // ← offset ke atas biar ga ketutup bottom bar
        }
    }

    // MARK: - Placeholders

    private var gradientPlaceholder: some View {
        LinearGradient(
            colors: [Color.Neutral.greyDark1, Color.Neutral.greyDark2, Color.Neutral.black],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var shimmerPlaceholder: some View {
        ShimmerView()
    }

    // MARK: - Action Button

    private func actionButton(icon: Image, label: String, isLoading: Bool = false, action: @escaping () -> Void) -> some View {
        Button {
            if !isLoading { action() } // ← blok tap saat loading
        } label: {
            HStack(spacing: 6) {
                if isLoading {
                    ProgressView() // ← spinner saat proses toggle
                        .frame(width: 16, height: 16) // ← sama besar dengan icon
                } else {
                    TemplateIcon(image: icon, size: 16, tint: Color.Semantic.textPrimary)
                }
                Text(label)
                    .font(.Typography.Medium.caption2)
                    .foregroundStyle(Color.Semantic.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.Neutral.greyDark2.opacity(0.8))
            )
        }
        .disabled(isLoading)
    }

}

// MARK: - Preview

#Preview {
    KlipPage()
}
