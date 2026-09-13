//
//  AppButton+Metrics.swift
//  netflix-clone
//

import SwiftUI

// MARK: - Metrics

extension AppButton {

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