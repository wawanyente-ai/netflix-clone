//
//  OnboardingPage+Slides.swift
//  netflix-clone
//

import SwiftUI

extension OnboardingPage {

    // MARK: - Slide Content

    var slideContent: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(0..<viewModel.totalPages, id: \.self) { index in
                slideView(index: index)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // ← sembunyikan default indicator
        .animation(.easeInOut, value: viewModel.currentPage) // ← ubah animasi transisi
    }

    func slideView(index: Int) -> some View {
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
}