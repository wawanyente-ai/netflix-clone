//
//  OnboardingViewModel.swift
//  netflix-clone
//

import SwiftUI

/// Manages onboarding state: current slide, navigation, and presentation of modals.
@Observable
final class OnboardingViewModel {

    // MARK: - Published State

    var currentPage: Int = 0       // ← ubah slide awal
    var showPrivacySheet = false   // ← toggle privacy modal
    var showSignInSheet = false    // ← toggle sign-in modal

    // MARK: - Constants

    let slides: [(title: String, description: String)] = [
        (
            title: "Unlimited movies, TV shows, and more.",
            description: "Watch anywhere. Cancel anytime."
        ),
        (
            title: "Download and watch offline.",
            description: "Save your favorites easily and always have something to watch."
        ),
        (
            title: "Watch everywhere.",
            description: "Stream on your phone, tablet, or laptop without paying more."
        ),
        (
            title: "Create profiles for kids.",
            description: "Send kids on adventures with their favorite characters in a space made just for them — free with your membership."
        )
    ]

    var totalPages: Int { slides.count }
    var isLastPage: Bool { currentPage == totalPages - 1 }

    // MARK: - Actions

    func nextPage() {
        guard currentPage < totalPages - 1 else { return }
        withAnimation { currentPage += 1 }
    }

    func previousPage() {
        guard currentPage > 0 else { return }
        withAnimation { currentPage -= 1 }
    }

    func goToPage(_ index: Int) {
        guard index >= 0, index < totalPages else { return }
        withAnimation { currentPage = index }
    }
}
