//
//  TitleCard+Shared.swift
//  netflix-clone
//

import SwiftUI

// MARK: - Shared

extension TitleCard {

    @ViewBuilder
    var imageLayer: some View {
        if hasImage {
            background()
        } else {
            ZStack(alignment: .topLeading) {
                Color.Neutral.grey.opacity(0.4)
                TemplateIcon(image: Image.Brand.logoSingleBadge, size: 8, tint: Color.Primary.red)
                    .rotationEffect(.degrees(180))
                    .padding(6)
            }
        }
    }
}