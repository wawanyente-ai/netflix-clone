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
}

// MARK: - Preview

#Preview {
    NetflixSayaPage(isSignedIn: true)
}

#Preview("Guest") {
    NetflixSayaPage(isSignedIn: false)
}
