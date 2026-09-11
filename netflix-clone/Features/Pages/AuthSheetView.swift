//
//  AuthSheetView.swift
//  netflix-clone
//

import SwiftUI

/// Modal sign-in yang muncul saat fitur ber-lock (butuh login) diklik
/// dalam kondisi guest. Google pakai Firebase Auth + GoogleSignIn SDK.
struct AuthSheetView: View {

    @Environment(\.dismiss) private var dismiss // ← custom dismiss sheet

    var onGoogleSignIn: () async -> Bool = { true } // ← real Google sign-in; true=sukses
    var onAppleSignIn: () -> Void = {}  // ← placeholder Apple sign-in

    @State private var isGoogleLoading = false // ← loading state Google
    @State private var errorMessage: String?   // ← error message

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) { // ← ubah gap antar elemen
                Spacer()

                Image.Brand.wordmark
                    .resizable()
                    .scaledToFit()
                    .frame(height: 32) // ← ubah tinggi logo

                Text("Masuk untuk melanjutkan")
                    .font(.Typography.Bold.label1) // ← ubah font judul
                    .foregroundStyle(Color.Semantic.textPrimary)

                Text("Fitur ini butuh akun. Browsing Home & Search tetap bisa tanpa login.")
                    .font(.Typography.Medium.caption1) // ← ubah font deskripsi
                    .foregroundStyle(Color.Semantic.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                if let error = errorMessage {
                    Text(error)
                        .font(.Typography.Medium.caption2)
                        .foregroundStyle(Color.Primary.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                VStack(spacing: 12) { // ← ubah gap antar tombol
                    // ← Google Sign-In button
                    Button {
                        Task {
                            guard !isGoogleLoading else { return }
                            isGoogleLoading = true
                            errorMessage = nil
                            let success = await onGoogleSignIn() // ← tunggu hasil real flow
                            isGoogleLoading = false // ← re-enable tombol selalu
                            if !success {
                                errorMessage = "Gagal masuk. Coba lagi." // ← kasih tahu error
                            }
                        }
                    } label: {
                        HStack(spacing: 12) { // ← ubah gap icon-to-text
                            if isGoogleLoading {
                                ProgressView()
                                    .tint(Color.Semantic.textPrimary)
                            } else {
                                googleIcon
                            }
                            Text("Continue with Google")
                                .font(.Typography.Medium.label3) // ← ubah font tombol
                                .foregroundStyle(Color.Semantic.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14) // ← ubah padding vertical
                        .background(Color.Neutral.greyDark2) // ← ubah warna background tombol
                        .clipShape(RoundedRectangle(cornerRadius: 4)) // ← ubah corner radius
                    }
                    .disabled(isGoogleLoading)

                    // ← Apple Sign-In button (placeholder)
                    signInButton(
                        appleIcon,
                        label: "Continue with Apple",
                        background: Color.Neutral.black // ← ubah warna tombol
                    )
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color.Semantic.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() } // ← ubah aksi close
                        .foregroundStyle(Color.Semantic.textPrimary)
                }
            }
        }
    }

    // MARK: - Google Icon (official "G" mark via SF Symbol alternative)

    private var googleIcon: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
            Text("G")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(red: 0.26, green: 0.52, blue: 0.96))
        }
    }

    // MARK: - Apple Icon (SF Symbol-like via shape)

    private var appleIcon: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
            Text("")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.black)
        }
    }

    // MARK: - Generic Button

    private func signInButton(_ icon: some View, label: String, background: Color) -> some View {
        Button {
            // ← Apple sign-in placeholder (tanpa Firebase Apple SDK)
            errorMessage = "Apple Sign-In belum tersedia"
        } label: {
            HStack(spacing: 12) { // ← ubah gap icon-to-text
                icon
                Text(label)
                    .font(.Typography.Medium.label3) // ← ubah font tombol
                    .foregroundStyle(Color.Semantic.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14) // ← ubah padding vertical
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 4)) // ← ubah corner radius
        }
    }
}

#Preview {
    AuthSheetView()
}
