//
//  OnboardingPage.swift
//  netflix-clone
//

import SwiftUI

/// Onboarding flow: 4 swipeable slides with page indicators, Get Started button,
/// Privacy modal, and Sign In modal (Google + Apple).
struct OnboardingPage: View {

    @State var viewModel = OnboardingViewModel()
    @State var signInError: String? // ← error Google sign-in
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
}

// MARK: - Preview

#Preview {
    OnboardingPage()
}