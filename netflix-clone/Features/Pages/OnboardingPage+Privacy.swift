//
//  OnboardingPage+Privacy.swift
//  netflix-clone
//

import SwiftUI

extension OnboardingPage {

    // MARK: - Privacy Sheet

    var privacySheet: some View {
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

    var privacyText: some View {
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
}