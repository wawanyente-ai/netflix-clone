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
    private let size: Size
    private let action: () -> Void

    // MARK: - Initialization

    init(
        _ title: String,
        icon: Image? = nil,
        variant: Variant = .primary,
        size: Size = .large,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.size = size
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            label
        }
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
            if let icon {
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

// MARK: - Metrics

private extension AppButton {

    struct Metrics {
        let iconSize: CGFloat
        let iconSpacing: CGFloat
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        let font: Font
    }

    var metrics: Metrics {
        switch size {
        case .large:
            Metrics(
                iconSize: 18,
                iconSpacing: 8,
                horizontalPadding: 8,
                verticalPadding: 8,
                font: .Typography.Medium.label3
            )
            
        case .small:
            Metrics(
                iconSize: 18,
                iconSpacing: 8,
                horizontalPadding: 8,
                verticalPadding: 6,
                font: .Typography.Medium.label3
            )
            
        case .primaryOnboarding:
            Metrics(
                iconSize: 24,
                iconSpacing: 8,
                horizontalPadding: 8,
                verticalPadding: 12,
                font: .Typography.Medium.label2
            )
            
        }
    }
}

// MARK: - Button Style

private struct AppButtonStyle: ButtonStyle {

    @Environment(\.isEnabled)
    private var isEnabled

    let variant: AppButton.Variant
    let size: AppButton.Size

    func makeBody(
        configuration: Configuration
    ) -> some View {
        configuration.label
            .frame(
                maxWidth: size != .small
                    ? .infinity
                    : nil
            )
            .foregroundStyle(
                foregroundColor
            )
            .background(
                backgroundColor
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 4
                )
            )
            .opacity(
                isEnabled && configuration.isPressed
                    ? 0.8
                    : 1
            )
            .animation(
                .easeOut(duration: 0.1),
                value: configuration.isPressed
            )
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        if !isEnabled {
            return disabledBackgroundColor
        }

        switch variant {
        case .primaryOnboarding:
            return Color.Primary.red

        case .primary:
            return Color.Neutral.white

        case .secondary:
            return Color.Neutral.greyDark2
        }
    }

    private var foregroundColor: Color {
        if !isEnabled {
            return disabledForegroundColor
        }

        switch variant {
        case .primaryOnboarding:
            return Color.Neutral.white

        case .primary:
            return Color.Neutral.black

        case .secondary:
            return Color.Neutral.white
        }
    }

    private var disabledBackgroundColor: Color {
        switch variant {
        case .primaryOnboarding:
            return Color.Primary.redDark1

        case .primary:
            return Color.Neutral.white

        case .secondary:
            return Color.Neutral.greyDark2
        }
    }

    private var disabledForegroundColor: Color {
        switch variant {
        case .primaryOnboarding:
            return Color.Neutral.grey

        case .primary:
            return Color.Neutral.greyLight2

        case .secondary:
            return Color.Neutral.grey
        }
    }
}
