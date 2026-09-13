//
//  HomePage+Hero.swift
//  netflix-clone
//

import SwiftUI

extension HomePage {

    // MARK: - Hero

    var hero: some View {
        ZStack(alignment: .bottomLeading) {
            // ← BackdropImage component (handles AsyncImage + shimmer)
            BackdropImage(
                url: viewModel.heroItem?.backdropURL,
                height: 480 // ← ubah tinggi hero
            )

            LinearGradient(
                colors: [.clear, Color.Semantic.background.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 480)

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.heroItem?.title ?? "Loading...") // ← judul dari trending
                    .font(.Typography.Bold.header1)
                    .foregroundStyle(Color.Semantic.textPrimary)

                Text(viewModel.heroItem?.overview ?? "") // ← overview dari trending
                    .font(.Typography.Medium.caption1)
                    .foregroundStyle(Color.Semantic.textSecondary)
                    .lineLimit(3) // ← limit 3 baris

                HStack(spacing: 8) {
                    AppButton("Play", icon: Image.Icon.play, variant: .primary, size: .small) {
                        if let item = viewModel.heroItem { onTitleTap(item) } // ← navigasi ke detail
                    }
                    AppButton("Info", icon: Image.Icon.info, variant: .secondary, size: .small) {
                        if let item = viewModel.heroItem { onTitleTap(item) } // ← navigasi ke detail
                    }
                    if let item = viewModel.heroItem {
                        AppButton(
                            isSavingMyList(item)
                                ? (isInMyList(item) ? "Menghapus..." : "Menyimpan...") // ← label ikut arah toggle
                                : (isInMyList(item) ? "Tersimpan" : "My List"), // ← status my list
                            icon: isInMyList(item) && !isSavingMyList(item) ? Image.Icon.check : Image.Icon.add, // ← centang kalau tersimpan
                            variant: .secondary, size: .small,
                            isLoading: isSavingMyList(item) // ← spinner saat proses toggle
                        ) { onMyListTap(item) } // ← toggle my list
                    }
                }
            }
            .padding(16)
        }
    }
}