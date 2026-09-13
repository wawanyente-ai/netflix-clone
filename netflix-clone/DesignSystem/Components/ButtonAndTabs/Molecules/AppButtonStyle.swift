//
//  AppButtonStyle.swift
//  netflix-clone
//

import SwiftUI

// MARK: - Button Style

struct AppButtonStyle: ButtonStyle {

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