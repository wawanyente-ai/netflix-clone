//
//  NetflixSayaPage.swift
//  netflix-clone
//

import SwiftUI

/// "Netflix Saya" (My Netflix) page — profile, downloads, watch history.
/// Placeholder for now, will be filled with real data later.
struct NetflixSayaPage: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) { // ← ubah gap antar section
                header
                profileSection
                downloadsSection
                watchHistorySection
            }
            .padding(.bottom, 24) // ← ubah inset bawah scroll
        }
        .background(Color.Semantic.background.ignoresSafeArea())
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
            Text("Profil")
                .font(.Typography.Bold.label3)
                .foregroundStyle(Color.Semantic.textPrimary)
                .padding(.horizontal, 16)

            HStack(spacing: 12) { // ← ubah gap antar profil
                ForEach(0..<4, id: \.self) { index in
                    profileCard(name: "User \(index + 1)", index: index)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func profileCard(name: String, index: Int) -> some View {
        VStack(spacing: 6) { // ← ubah gap icon-to-name
            Image.UserVariant.blue // ← placeholder avatar (ganti ke profil asli)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48) // ← ubah ukuran avatar
                .clipShape(RoundedRectangle(cornerRadius: 4)) // ← ubah corner radius

            Text(name)
                .font(.Typography.Light.caption2) // ← ubah font nama
                .foregroundStyle(Color.Semantic.textSecondary)
        }
        .frame(maxWidth: .infinity) // ← full width per card
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

            // ← placeholder kosong
            VStack(spacing: 16) {
                TemplateIcon(image: Image.Icon.play, size: 40, tint: Color.Semantic.textTertiary)
                Text("Belum ada riwayat")
                    .font(.Typography.Medium.caption1)
                    .foregroundStyle(Color.Semantic.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        }
    }
}

// MARK: - Preview

#Preview {
    NetflixSayaPage()
}
