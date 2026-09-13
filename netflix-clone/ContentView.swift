//
//  ContentView.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 21/08/26.
//

import SwiftUI

struct ContentView: View {

    // MARK: - State

    @State private var isStandardLikeActive = false
    @State private var isSmileActive = false
    @State private var isProminentLikeActive = false
    @State private var selectedTabIndex = 0

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    appButtonSection

                    videoControlButtonSection

                    videoReactionButtonSection

                    videoTabButtonSection
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.Neutral.black)
            .navigationTitle("Components")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - AppButton Section

private extension ContentView {

    var appButtonSection: some View {
        section("AppButton") {
            Group {
                AppButton("Primary", action: {})
                AppButton("Primary Onboarding", variant: .primaryOnboarding, size: .primaryOnboarding, action: {})
                AppButton("Secondary", variant: .secondary, action: {})

                HStack(spacing: 8) {
                    AppButton("Primary", size: .small, action: {})
                    AppButton("Onboarding", icon: Image.Icon.add, variant: .secondary, size: .small, action: {})
                }

                AppButton("Download", icon: Image.Icon.downloadAction, action: {})
                AppButton("Play", icon: Image.Icon.play, action: {})
                AppButton("Info", icon: Image.Icon.info, variant: .secondary, action: {})

                AppButton("Menyimpan...", icon: Image.Icon.add, variant: .secondary, isLoading: true, action: {})

                AppButton("Disabled Primary", action: {})
                    .disabled(true)

                AppButton("Disabled Onboarding", variant: .primaryOnboarding, size: .primaryOnboarding, action: {})
                    .disabled(true)

                AppButton("Disabled Secondary", variant: .secondary, action: {})
                    .disabled(true)
            }
        }
    }
}

// MARK: - VideoControlButton Section

private extension ContentView {

    var videoControlButtonSection: some View {
        section("VideoControlButton", hint: "Semua ukuran & style") {
            VStack(alignment: .leading, spacing: 20) {

                // ── Play ──────────────────────────────────────
                labeledRow("Play") {
                    HStack(spacing: 16) {
                        labeled("thumbSmall") { VideoControlButton(variant: .play(.thumbnailSmall), action: {}) }
                        labeled("thumbLarge") { VideoControlButton(variant: .play(.thumbnailLarge), action: {}) }
                        labeled("videoLarge") { VideoControlButton(variant: .play(.videoLarge), action: {}) }
                        labeled("videoSmall") { VideoControlButton(variant: .play(.videoSmall), action: {}) }
                    }
                }

                // ── Pause ─────────────────────────────────────
                labeledRow("Pause") {
                    HStack(spacing: 16) {
                        labeled("small") { VideoControlButton(variant: .pause(.small), action: {}) }
                        labeled("large") { VideoControlButton(variant: .pause(.large), action: {}) }
                    }
                }

                // ── Skip ──────────────────────────────────────
                labeledRow("Skip") {
                    HStack(spacing: 16) {
                        labeled("backS") { VideoControlButton(variant: .skipBackward(.small), action: {}) }
                        labeled("backL") { VideoControlButton(variant: .skipBackward(.large), action: {}) }
                        labeled("fwdS")  { VideoControlButton(variant: .skipForward(.small), action: {}) }
                        labeled("fwdL")  { VideoControlButton(variant: .skipForward(.large), action: {}) }
                    }
                }

                // ── Utility ───────────────────────────────────
                labeledRow("Utility") {
                    HStack(spacing: 16) {
                        labeled("mirror") { VideoControlButton(variant: .mirror, action: {}) }
                        labeled("close")  { VideoControlButton(variant: .close, action: {}) }
                    }
                }
            }
        }
    }
}

// MARK: - VideoReactionButton Section

private extension ContentView {

    var videoReactionButtonSection: some View {
        section("VideoReactionButton", hint: "Tap buat toggle active") {
            HStack(spacing: 24) {
                VideoReactionButton(
                    title: isStandardLikeActive ? "Liked" : "Like",
                    icon: Image.Icon.like,
                    isSelected: isStandardLikeActive,
                    action: { isStandardLikeActive.toggle() }
                )

                VideoReactionButton(
                    title: "Smile",
                    icon: Image.Icon.smile,
                    isSelected: isSmileActive,
                    style: .standard,
                    action: { isSmileActive.toggle() }
                )

                VideoReactionButton(
                    title: "Like",
                    icon: Image.Icon.like,
                    isSelected: isProminentLikeActive,
                    style: .prominent,
                    action: { isProminentLikeActive.toggle() }
                )
            }
        }
    }
}

// MARK: - VideoTabButton Section

private extension ContentView {

    var videoTabButtonSection: some View {
        section("VideoTabButton", hint: "Tap buat ganti tab") {
            HStack(alignment: .bottom, spacing: 24) {
                VideoTabButton(
                    title: "Episodes",
                    isSelected: selectedTabIndex == 0,
                    action: { selectedTabIndex = 0 }
                )

                VideoTabButton(
                    title: "Trailers",
                    isSelected: selectedTabIndex == 1,
                    action: { selectedTabIndex = 1 }
                )

                VideoTabButton(
                    title: "More Like This",
                    isSelected: selectedTabIndex == 2,
                    action: { selectedTabIndex = 2 }
                )
            }
        }
    }
}

// MARK: - Helpers

private extension ContentView {

    @ViewBuilder
    func section<Content: View>(
        _ title: String,
        hint: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.Typography.Medium.label2)
                .foregroundStyle(Color.Neutral.white)

            if let hint {
                Text(hint)
                    .font(.Typography.Light.caption1)
                    .foregroundStyle(Color.Neutral.greyLight3)
            }

            content()
        }
    }

    func labeled<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 8) {
            content()

            Text(title)
                .font(.Typography.Light.caption2)
                .foregroundStyle(Color.Neutral.greyLight3)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }

    func labeledRow<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.Typography.Medium.caption1)
                .foregroundStyle(Color.Neutral.greyLight2)
            content()
        }
    }
}

#Preview {
    ContentView()
}
