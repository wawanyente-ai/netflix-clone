//
//  OnboardingPage+Header.swift
//  netflix-clone
//

import SwiftUI

extension OnboardingPage {

    // MARK: - Header

    var header: some View {
        HStack {
            Image.Brand.wordmark
                .resizable()
                .scaledToFit()
                .frame(height: 24) // ← ubah tinggi logo

            Spacer()

            Button("Privacy") { viewModel.showPrivacySheet = true } // ← ubah aksi privacy
                .font(.Typography.Medium.label3)
                .foregroundStyle(Color.Semantic.textPrimary)

            Button("Sign In") { viewModel.showSignInSheet = true } // ← ubah aksi sign-in
                .font(.Typography.Medium.label3)
                .foregroundStyle(Color.Semantic.textPrimary)
        }
        .padding(.horizontal, 16) // ← ubah inset horizontal
        .padding(.top, 12) // ← ubah inset atas
    }

    // MARK: - Bottom Section

    var bottomSection: some View {
        VStack(spacing: 16) { // ← ubah gap indicator-to-button
            pageIndicators

            AppButton("Get Started", variant: .primaryOnboarding) { // ← ubah teks/aksi tombol
                viewModel.showSignInSheet = true
            }
            .padding(.horizontal, 16) // ← ubah inset tombol
            .padding(.bottom, 16) // ← ubah inset bawah tombol
        }
    }

    // MARK: - Page Indicators

    var pageIndicators: some View {
        HStack(spacing: 6) { // ← ubah gap antar dot
            ForEach(0..<viewModel.totalPages, id: \.self) { index in
                Circle()
                    .fill(
                        index == viewModel.currentPage
                            ? Color.Semantic.textPrimary   // ← ubah warna dot aktif
                            : Color.Neutral.greyDark1      // ← ubah warna dot inactive
                    )
                    .frame(
                        width: index == viewModel.currentPage ? 8 : 6, // ← ubah ukuran dot
                        height: index == viewModel.currentPage ? 8 : 6
                    )
                    .onTapGesture { viewModel.goToPage(index) } // ← tap dot pindah slide
            }
        }
    }
}