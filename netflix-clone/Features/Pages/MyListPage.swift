//
//  MyListPage.swift
//  netflix-clone
//

import SwiftUI

/// My List page — grid of saved titles (from backend `/v1/profiles/{id}/mylist`).
/// Butuh login: guest melihat prompt sign-in.
struct MyListPage: View {

    var items: [WatchlistItemModel] = [] // ← daftar my list profil aktif
    var onTitleTap: (WatchlistItemModel) -> Void = { _ in } // ← navigasi ke detail
    var onRemove: (WatchlistItemModel) -> Void = { _ in } // ← hapus dari my list
    var onRefresh: () async -> Void = {} // ← pull-to-refresh

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("My List")
                    .font(.Typography.Bold.header1) // ← ubah font judul
                    .foregroundStyle(Color.Semantic.textPrimary)
                    .padding(.horizontal, 16)

                if items.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 106), spacing: 8)], // ← ubah ukuran grid
                        spacing: 8
                    ) {
                        ForEach(items) { item in
                            myListCard(item)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color.Semantic.background.ignoresSafeArea())
        .refreshable { await onRefresh() } // ← pull-to-refresh
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            TemplateIcon(image: Image.Icon.add, size: 40, tint: Color.Semantic.textTertiary)
            Text("Belum ada judul di My List")
                .font(.Typography.Medium.caption1)
                .foregroundStyle(Color.Semantic.textSecondary)
            Text("Tekan tombol My List di judul untuk menyimpannya.")
                .font(.Typography.Light.caption2)
                .foregroundStyle(Color.Semantic.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    // MARK: - Card

    private func myListCard(_ item: WatchlistItemModel) -> some View {
        Button { onTitleTap(item) } label: {
            ZStack(alignment: .topTrailing) {
                TitleCard(kind: .standard, hasImage: !item.posterPath.isEmpty) {
                    PosterImage(url: ImageURLBuilder.posterURL(from: item.posterPath))
                }

                // ← tombol hapus (small)
                Button {
                    onRemove(item)
                } label: {
                    Image.Icon.close
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(6)
                        .background(Color.Neutral.black.opacity(0.7))
                        .clipShape(Capsule())
                }
                .padding(6)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    MyListPage(items: [
        WatchlistItemModel(
            mediaId: 1, mediaType: "movie", title: "Interstellar",
            posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg", addedAt: .now
        )
    ])
}

#Preview("Empty") {
    MyListPage()
}