//
//  NetflixSayaPage+Sections.swift
//  netflix-clone
//

import SwiftUI

extension NetflixSayaPage {

    // MARK: - Guest Section (require login)

    var guestSection: some View {
        VStack(spacing: 20) { // ← ubah gap
            TemplateIcon(image: Image.Icon.user, size: 48, tint: Color.Semantic.textTertiary)
            Text("Masuk untuk lihat profil,\ndownload & riwayat tontonanmu")
                .font(.Typography.Medium.label2) // ← ubah font
                .foregroundStyle(Color.Semantic.textSecondary)
                .multilineTextAlignment(.center)

            AppButton("Masuk", variant: .primary) { onSignInTap() } // ← ubah aksi sign-in
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48) // ← ubah padding vertical
    }

    // MARK: - Profile Section

    var profileSection: some View {
        VStack(alignment: .leading, spacing: 12) { // ← ubah gap
            HStack {
                Text("Profil")
                    .font(.Typography.Bold.label3)
                    .foregroundStyle(Color.Semantic.textPrimary)

                Spacer()

                Button("Keluar") { onSignOut() } // ← ubah aksi sign-out
                    .font(.Typography.Medium.caption1)
                    .foregroundStyle(Color.Semantic.textTertiary)
            }
            .padding(.horizontal, 16)

            HStack(spacing: 12) { // ← ubah gap antar profil
                ForEach(profiles.isEmpty ? Array(0..<1).map { UserProfile.placeholder($0) } : profiles) { profile in
                    profileCard(profile: profile, isSelected: profile.profileId == selectedProfileId)
                        .onTapGesture { onSelectProfile(profile.profileId) } // ← pilih profil
                }
            }
            .padding(.horizontal, 16)
        }
    }

    func profileCard(profile: UserProfile, isSelected: Bool) -> some View {
        VStack(spacing: 6) { // ← ubah gap icon-to-name
            avatar(for: profile.avatarColor)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48) // ← ubah ukuran avatar
                .clipShape(RoundedRectangle(cornerRadius: 4)) // ← ubah corner radius
                .overlay(
                    RoundedRectangle(cornerRadius: 4) // ← border profil aktif
                        .stroke(isSelected ? Color.Primary.red : .clear, lineWidth: 2)
                )

            Text(profile.name)
                .font(.Typography.Light.caption2) // ← ubah font nama
                .foregroundStyle(Color.Semantic.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity) // ← full width per card
    }

    func avatar(for colorName: String) -> Image {
        switch colorName {
        case "pink":
            return Image.UserVariant.pink
        case "turquoise":
            return Image.UserVariant.turquoise
        case "turquoise1":
            return Image.UserVariant.turquoise1
        default:
            return Image.UserVariant.blue // ← default avatar
        }
    }

    // MARK: - My List Section

    var myListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My List")
                    .font(.Typography.Bold.label3)
                    .foregroundStyle(Color.Semantic.textPrimary)

                Spacer()

                // ← buka halaman My List penuh
                Button("Lihat Semua") { onSeeAllMyList() }
                    .font(.Typography.Medium.caption1)
                    .foregroundStyle(Color.Semantic.textTertiary)
            }
            .padding(.horizontal, 16)

            if mylist.isEmpty {
                // ← placeholder kosong
                VStack(spacing: 16) {
                    TemplateIcon(image: Image.Icon.add, size: 40, tint: Color.Semantic.textTertiary)
                    Text("Belum ada judul di My List")
                        .font(.Typography.Medium.caption1)
                        .foregroundStyle(Color.Semantic.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(mylist) { item in
                            Button { onMyListTap(item) } label: {
                                PosterImage(
                                    url: ImageURLBuilder.posterURL(from: item.posterPath),
                                    width: 106, height: 152, cornerRadius: 4
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    // MARK: - Downloads Section

    var downloadsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Download")
                .font(.Typography.Bold.label3)
                .foregroundStyle(Color.Semantic.textPrimary)
                .padding(.horizontal, 16)

            // ← placeholder kosong
            VStack(spacing: 16) { // ← ubah gap
                TemplateIcon(image: Image.Icon.downloadNavigation, size: 40, tint: Color.Semantic.textTertiary)
                Text("Belum ada download")
                    .font(.Typography.Medium.caption1)
                    .foregroundStyle(Color.Semantic.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32) // ← ubah padding vertical placeholder
        }
    }

    // MARK: - Watch History Section

    var watchHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Riwayat Tontonan")
                .font(.Typography.Bold.label3)
                .foregroundStyle(Color.Semantic.textPrimary)
                .padding(.horizontal, 16)

            if history.isEmpty {
                // ← placeholder kosong
                VStack(spacing: 16) {
                    TemplateIcon(image: Image.Icon.play, size: 40, tint: Color.Semantic.textTertiary)
                    Text("Belum ada riwayat")
                        .font(.Typography.Medium.caption1)
                        .foregroundStyle(Color.Semantic.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                VStack(alignment: .leading, spacing: 8) { // ← daftar riwayat real
                    ForEach(history.prefix(10)) { entry in
                        HStack(spacing: 12) {
                            PosterImage(
                                url: ImageURLBuilder.posterURL(from: entry.posterPath),
                                width: 40, height: 60, cornerRadius: 4 // ← thumbnail kecil
                            )
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.title)
                                    .font(.Typography.Medium.label3)
                                    .foregroundStyle(Color.Semantic.textPrimary)
                                Text(entry.mediaType == "tv" ? "Series" : "Film")
                                    .font(.Typography.Light.caption2)
                                    .foregroundStyle(Color.Semantic.textTertiary)
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
