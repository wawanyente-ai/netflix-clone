//
//  VideoReactionButton.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 24/08/26.
//


import SwiftUI

struct VideoReactionButton: View {

    // MARK: - Types

    enum Style {
        case standard
        case prominent
    }

    // MARK: - Properties

    private let title: String
    private let icon: Image
    private let isSelected: Bool
    private let style: Style
    private let action: () -> Void

    // MARK: - Initialization

    init(
        title: String,
        icon: Image,
        isSelected: Bool = false,
        style: Style = .standard,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.style = style
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            VStack(spacing: metrics.spacing) {
                icon
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(
                        width: metrics.iconSize,
                        height: metrics.iconSize
                    )

                Text(title)
                    .font(metrics.font)
                    .lineLimit(1)
            }
            .foregroundStyle(
                isSelected
                    ? Color.Primary.red
                    : Color.Neutral.white
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Metrics

private extension VideoReactionButton {

    struct Metrics {
        let iconSize: CGFloat
        let spacing: CGFloat
        let font: Font
    }

    var metrics: Metrics {
        switch style {
        case .standard:
            Metrics(
                iconSize: 32,
                spacing: 8,
                font: .Typography.Light.label3
            )

        case .prominent:
            Metrics(
                iconSize: 32,
                spacing: 8,
                font: .Typography.Medium.label3
            )
        }
    }
}