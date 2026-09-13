//
//  AppButton.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 23/08/26.
//

import SwiftUI

struct AppButton: View {

    // MARK: - Types

    enum Variant {
        case primary
        case primaryOnboarding
        case secondary
    }

    enum Size {
        case large
        case small
        case primaryOnboarding
    }

    // MARK: - Properties

    private let title: String
    private let icon: Image?
    private let variant: Variant
    let size: Size
    private let isLoading: Bool
    private let action: () -> Void

    // MARK: - Initialization

    init(
        _ title: String,
        icon: Image? = nil,
        variant: Variant = .primary,
        size: Size = .large,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            label
        }
        .disabled(isLoading)
        .buttonStyle(
            AppButtonStyle(
                variant: variant,
                size: size
            )
        )
    }
}

// MARK: - Label

private extension AppButton {

    var label: some View {
        HStack(spacing: metrics.iconSpacing) {
            if isLoading {
                ProgressView() // ← spinner ganti icon saat loading (warna ikut varian via foregroundStyle)
                    .frame(
                        width: metrics.iconSize,
                        height: metrics.iconSize
                    )
            } else if let icon {
                icon
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(
                        width: metrics.iconSize,
                        height: metrics.iconSize
                    )
            }

            Text(title)
                .font(metrics.font)
                .lineLimit(1)
        }
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.vertical, metrics.verticalPadding)
    }
}