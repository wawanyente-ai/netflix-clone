//
//  OnboardingPage.swift
//  netflix-clone
//

import SwiftUI

/// Onboarding flow: 4 swipeable slides with page indicators, Get Started button,
/// Privacy modal, and Sign In modal (Google + Apple).
struct OnboardingPage: View {

    @State private var viewModel = OnboardingViewModel()
    @State private var signInError: String? // ← error Google sign-in
    var onComplete: () -> Void = {} // ← panggil setelah get-started (guest)
    var onGoogleSignIn: () async -> Bool = { true } // ← real Google Sign-In flow

    var body: some View {
        VStack(spacing: 0) {
            header
            slideContent
            bottomSection
        }
        .background(Color.Semantic.background.ignoresSafeArea())
        .sheet(isPresented: $viewModel.showPrivacySheet) {
            privacySheet
        }
        .sheet(isPresented: $viewModel.showSignInSheet) {
            signInSheet
        }
    }

    // MARK: - Header

    private var header: some View {
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

    // MARK: - Slide Content

    private var slideContent: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(0..<viewModel.totalPages, id: \.self) { index in
                slideView(index: index)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // ← sembunyikan default indicator
        .animation(.easeInOut, value: viewModel.currentPage) // ← ubah animasi transisi
    }

    private func slideView(index: Int) -> some View {
        let slide = viewModel.slides[index]

        return VStack(spacing: 16) { // ← ubah gap title-to-description
            Spacer()

            Text(slide.title)
                .font(.Typography.Bold.header1) // ← ubah font judul slide
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.Semantic.textPrimary)

            Text(slide.description)
                .font(.Typography.Medium.label2) // ← ubah font deskripsi slide
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.Semantic.textSecondary)

            Spacer()
        }
        .padding(.horizontal, 32) // ← ubah inset horizontal slide
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
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

    private var pageIndicators: some View {
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

    // MARK: - Privacy Sheet

    private var privacySheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.Typography.Bold.label1)
                        .foregroundStyle(Color.Semantic.textPrimary)

                    Text("Last updated: August 26, 2026")
                        .font(.Typography.Medium.caption1)
                        .foregroundStyle(Color.Semantic.textTertiary)

                    privacyText
                }
                .padding(16)
            }
            .background(Color.Semantic.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { viewModel.showPrivacySheet = false } // ← ubah aksi close
                        .foregroundStyle(Color.Semantic.textPrimary)
                }
            }
        }
    }

    private var privacyText: some View {
        VStack(alignment: .leading, spacing: 12) {
            Group {
                Text("Information We Collect")
                    .font(.Typography.Medium.label3)
                    .foregroundStyle(Color.Semantic.textPrimary)
                Text("We collect information you provide directly, such as your account details, payment information, and preferences. We also collect usage data including viewing history, search queries, and device information.")
                    .font(.Typography.Medium.caption1)
                    .foregroundStyle(Color.Semantic.textSecondary)
            }

            Group {
                Text("How We Use Your Information")
                    .font(.Typography.Medium.label3)
                    .foregroundStyle(Color.Semantic.textPrimary)
                Text("We use your information to provide, personalize, and improve our services. This includes recommending content, processing transactions, and communicating with you about updates and offers.")
                    .font(.Typography.Medium.caption1)
                    .foregroundStyle(Color.Semantic.textSecondary)
            }

            Group {
                Text("Information Sharing")
                    .font(.Typography.Medium.label3)
                    .foregroundStyle(Color.Semantic.textPrimary)
                Text("We do not sell your personal information. We may share data with service providers who assist in operating our platform, and as required by law.")
                    .font(.Typography.Medium.caption1)
                    .foregroundStyle(Color.Semantic.textSecondary)
            }

            Group {
                Text("Your Choices")
                    .font(.Typography.Medium.label3)
                    .foregroundStyle(Color.Semantic.textPrimary)
                Text("You can access, update, or delete your account information at any time. You may also opt out of certain data collection and marketing communications.")
                    .font(.Typography.Medium.caption1)
                    .foregroundStyle(Color.Semantic.textSecondary)
            }
        }
    }

    // MARK: - Sign In Sheet

    private var signInSheet: some View {
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

    private var googleSignInButton: some View {
        Button {
            Task {
                viewModel.showSignInSheet = false // ← tutup sheet
                let success = await onGoogleSignIn() // ← real Google sign-in (Firebase)
                if !success {
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

    private var appleSignInButton: some View {
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

// MARK: - Preview

#Preview {
    OnboardingPage()
}
