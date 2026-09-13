//
//  TitleDetailPage+Sections.swift
//  netflix-clone
//

import SwiftUI

extension TitleDetailPage {

    // MARK: - Hero Backdrop

    var heroBackdrop: some View {
        ZStack(alignment: .bottomLeading) {
            // ← BackdropImage component (handles shimmer + layout)
            BackdropImage(
                url: viewModel.titleDetail?.backdropURL,
                height: 220 // ← ubah tinggi hero backdrop
            )

            LinearGradient(
                colors: [.clear, Color.Semantic.background.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)
        }
    }

    // MARK: - Title Info

    var titleInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.titleDetail?.rating ?? "Loading...") // ← genre/rating
                .font(.Typography.Medium.caption2)
                .tracking(3)
                .foregroundStyle(Color.Neutral.greyLight1)

            Text(viewModel.titleDetail?.title ?? "") // ← judul
                .font(.Typography.Bold.header1)
                .foregroundStyle(Color.Semantic.textPrimary)

            HStack(spacing: 8) {
                Text(viewModel.titleDetail?.year ?? "") // ← tahun
                Text("•")
                Text(viewModel.titleDetail?.seasonCount ?? "") // ← season/durasi
                Text("•")
                Text(viewModel.titleDetail?.voteAverageString ?? "") // ← rating TMDB
            }
            .font(.Typography.Medium.caption1)
            .foregroundStyle(Color.Semantic.textSecondary)
        }
    }

    // MARK: - Actions

    var actions: some View {
        VStack(spacing: 8) {
            AppButton(
                isSavingMyList()
                    ? (isInMyList() ? "Menghapus..." : "Menyimpan...") // ← label ikut arah toggle
                    : (isInMyList() ? "Tersimpan" : "My List"), // ← status my list
                icon: isInMyList() && !isSavingMyList() ? Image.Icon.check : Image.Icon.add, // ← centang kalau tersimpan
                variant: .secondary,
                isLoading: isSavingMyList() // ← spinner saat proses toggle
            ) { onMyListTap() } // ← toggle my list
            AppButton("Play", icon: Image.Icon.play, variant: .primary) { onPlayTap() }
            AppButton("Download", icon: Image.Icon.downloadAction, variant: .secondary) {
                // ← TODO: fitur download offline (belum ada)
            }
        }
    }

    // MARK: - Synopsis

    var synopsis: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.titleDetail?.synopsis ?? "") // ← sinopsis
                .font(.Typography.Medium.caption1)
                .foregroundStyle(Color.Semantic.textSecondary)
        }
    }

    // MARK: - Cast

    var castSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cast")
                .font(.Typography.Bold.label3)
                .foregroundStyle(Color.Semantic.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.titleDetail?.cast ?? []) { member in
                        castMemberView(member)
                    }
                }
            }
        }
    }

    func castMemberView(_ member: CastMember) -> some View {
        VStack(spacing: 4) {
            // ← ProfileImage component (handles shimmer + circle clip)
            ProfileImage(url: member.profileURL, size: 60) // ← ubah ukuran foto

            Text(member.name)
                .font(.Typography.Light.caption2)
                .foregroundStyle(Color.Semantic.textSecondary)
                .lineLimit(1)
        }
        .frame(width: 70) // ← lebar card cast
    }

    // MARK: - Tab Bar

    var tabBar: some View {
        TitleDetailsTabBar(selection: $viewModel.selectedTab)
    }

    // MARK: - Season Picker

    var seasonPicker: some View {
        SeasonSelectionDropdown(selection: $viewModel.selectedSeason, availableSeasons: 1...5)
    }

    // MARK: - Episode List

    var episodeList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(viewModel.episodes.enumerated()), id: \.element.id) { index, episode in
                EpisodeSummaryRow(
                    title: episode.title,
                    duration: episode.duration,
                    synopsis: episode.synopsis,
                    onPlayTap: {}
                ) {
                    PosterImage(url: episode.stillURL, width: 124, height: 69, cornerRadius: 4)
                }

                if index < viewModel.episodes.count - 1 {
                    Rectangle()
                        .fill(Color.Neutral.greyDark1) // ← warna separator antar episode
                        .frame(height: 1)
                        .padding(.vertical, 14) // ← jarak vertical separator
                }
            }
        }
    }

    // MARK: - More Like This

    var moreLikeThisRail: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("More Like This")
                .font(.Typography.Bold.label3)
                .foregroundStyle(Color.Semantic.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.recommendations) { item in
                        Button { onTitleTap(item) } label: {
                            PosterImage(url: item.posterURL) // ← poster component
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
