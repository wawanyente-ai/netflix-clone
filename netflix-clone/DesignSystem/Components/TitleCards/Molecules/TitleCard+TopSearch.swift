//
//  TitleCard+TopSearch.swift
//  netflix-clone
//

import SwiftUI

// MARK: - Top Search

extension TitleCard {

    var topSearchBody: some View {
        ZStack {
            imageLayer
                .frame(width: TitleCardMetrics.topSearch.size.width, height: TitleCardMetrics.topSearch.size.height)
                .clipShape(RoundedRectangle(cornerRadius: TitleCardMetrics.cornerRadius))

            // ← Netflix logo di pojok kiri atas
            if hasImage {
                TemplateIcon(
                    image: Image.Brand.logoSingleBadge,
                    size: 6,
                    tint: Color.Primary.red
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(4)
            }

            // ← TopTen badge di pojok kanan atas
            if badge.showTopTen {
                TopTenBadge(scale: TitleCardMetrics.topSearchBadgeScale, cornerRadius: TitleCardMetrics.cornerRadius)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .frame(width: TitleCardMetrics.topSearch.size.width, height: TitleCardMetrics.topSearch.size.height)
    }
}