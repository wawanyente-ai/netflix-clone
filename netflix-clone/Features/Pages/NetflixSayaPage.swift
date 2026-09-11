//
//  NetflixSayaPage.swift
//  netflix-clone
//

import SwiftUI

/// "Netflix Saya" (My Netflix) page — profile, downloads, watch history.
/// Butuh login: guest melihat prompt sign-in + aksi contoh, bukan data pribadi.
struct NetflixSayaPage: View {

    var isSignedIn: Bool = false // ← status login (guest vs authed)
    var onSignInTap: () -> Void = {} // ← panggil saat guest tap tombol masuk
    var profiles: [UserProfile] = [] // ← daftar profil dari backend
    var selectedProfileId: String? = nil // ← profil aktif
    var history: [HistoryEntryModel] = [] // ← riwayat profil aktif
    var mylist: [WatchlistItemModel] = [] // ← my list profil aktif
    var onSelectProfile: (String) -> Void = { _ in } // ← ganti profil
    var onSignOut: () -> Void = {} // ← keluar
    var onMyListTap: (WatchlistItemModel) -> Void = { _ in } // ← tap judul my list → detail
    var onSeeAllMyList: () -> Void = {} // ← buka halaman My List penuh

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) { // ← ubah gap antar section
                header
                if isSignedIn {
                    profileSection
                    myListSection
                    downloadsSection
                    watchHistorySection
                } else {
                    guestSection
                }
            }
            .padding(.bottom, 24) // ← ubah inset bawah scroll
        }
        .background(Color.Semantic.background.ignoresSafeArea())
    }

    // MARK: - Guest Section (require login)

    private var guestSection: some View {
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

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Netflix Saya") // ← ubah judul
                .font(.Typography.Bold.header1)
                .foregroundStyle(Color.Semantic.textPrimary)

            Spacer()
        }
        .padding(.horizontal, 16) // ← ubah inset horizontal
        .padding(.top, 8) // ← ubah inset atas
    }

    // MARK: - Profile Section

    private var profileSection: some View {
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

    private func profileCard(profile: UserProfile, isSelected: Bool) -> some View {
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

    private func avatar(for colorName: String) -> Image {
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

    private var myListSection: some View {
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

    private var downloadsSection: some View {
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

    private var watchHistorySection: some View {
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

// MARK: - Preview

#Preview {
    NetflixSayaPage(isSignedIn: true)
}

#Preview("Guest") {
    NetflixSayaPage(isSignedIn: false)
}
