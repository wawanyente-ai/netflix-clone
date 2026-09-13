//
//  OnboardingPage+SignIn.swift
//  netflix-clone
//

import SwiftUI

extension OnboardingPage {

    // MARK: - Sign In Sheet

    var signInSheet: some View {
        NavigationStack {
            VStack(spacing: 24) { // ← ubah gap antar elemen
                Spacer()

                Image.Brand.wordmark
                    .resizable()
                    .scaledToFit()
                    .frame(height: 32) // ← ubah tinggi logo di sheet

                Text("Sign In")
                    .font(.Typography.Bold.label1)
                    .foregroundStyle(Color.Semantic.textPrimary)

                if let signInError {
                    Text(signInError)
                        .font(.Typography.Medium.caption2)
                        .foregroundStyle(Color.Primary.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                VStack(spacing: 12) { // ← ubah gap antar tombol sign-in
                    googleSignInButton
                    appleSignInButton
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color.Semantic.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { viewModel.showSignInSheet = false } // ← ubah aksi close
                        .foregroundStyle(Color.Semantic.textPrimary)
                }
            }
        }
    }

    var googleSignInButton: some View {
        Button {
            Task {
                viewModel.showSignInSheet = false // ← tutup sheet
                let success = await onGoogleSignIn() // ← real Google sign-in (Firebase)
                if success {
                    onComplete() // ← sukses: lanjut masuk ke app
                } else {
                    signInError = "Gagal masuk. Coba lagi." // ← kasih tahu user
                    viewModel.showSignInSheet = true // ← buka lagi buat retry
                }
            }
        } label: {
            HStack(spacing: 12) { // ← ubah gap icon-to-text
                TemplateIcon(image: Image.Icon.info, size: 20, tint: Color.Semantic.textPrimary) // ← stand-in Google icon
                Text("Continue with Google")
                    .font(.Typography.Medium.label3)
                    .foregroundStyle(Color.Semantic.textPrimary)
            }
            .frame(maxWidth: .infinity) // ← full width button
            .padding(.vertical, 14) // ← ubah padding vertical tombol
            .background(Color.Neutral.greyDark2) // ← ubah warna background tombol
            .clipShape(RoundedRectangle(cornerRadius: 4)) // ← ubah corner radius tombol
        }
    }

    var appleSignInButton: some View {
        Button {
            viewModel.showSignInSheet = false // ← ubah aksi Apple sign-in
            onComplete()
        } label: {
            HStack(spacing: 12) { // ← ubah gap icon-to-text
                TemplateIcon(image: Image.Icon.user, size: 20, tint: Color.Semantic.textPrimary) // ← stand-in Apple icon
                Text("Continue with Apple")
                    .font(.Typography.Medium.label3)
                    .foregroundStyle(Color.Semantic.textPrimary)
            }
            .frame(maxWidth: .infinity) // ← full width button
            .padding(.vertical, 14) // ← ubah padding vertical tombol
            .background(Color.Neutral.black) // ← ubah warna background tombol
            .clipShape(RoundedRectangle(cornerRadius: 4)) // ← ubah corner radius tombol
            .overlay(
                RoundedRectangle(cornerRadius: 4) // ← ubah corner radius border
                    .stroke(Color.Neutral.white, lineWidth: 1) // ← ubah warna/ketebalan border
            )
        }
    }
}