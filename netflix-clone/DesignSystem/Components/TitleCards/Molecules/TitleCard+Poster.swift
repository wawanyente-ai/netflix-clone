//
//  TitleCard+Poster.swift
//  netflix-clone
//

import SwiftUI

// MARK: - Poster (Standard / Continue Watching)

extension TitleCard {

    var size: CGSize {
        switch kind {
        case .standard: TitleCardMetrics.standard.size
        case .continueWatching: TitleCardMetrics.continueWatching.size
        case .topSearch: TitleCardMetrics.topSearch.size
        }
    }

    func posterBody(
        showsPlayOverlay: Bool,
        progress: Double?,
        episodeLabel: String?,
        showsFooter: Bool
    ) -> some View {
        VStack(spacing: 0) {
            ZStack {
                clippedImage(showsFooter: showsFooter)

                // ← Netflix logo di pojok kiri atas
                if hasImage {
                    TemplateIcon(
                        image: Image.Brand.logoSingleBadge,
                        size: 10,
                        tint: Color.Primary.red
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(6)
                }

                // ← Play button overlay (untuk continue watching)
                if showsPlayOverlay {
                    VideoControlButton(variant: .play(.thumbnailLarge)) { onPlayTap?() }
                }

                // ← TopTen badge di pojok kanan atas
                if hasImage, badge.showTopTen {
                    TopTenBadge()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }

                // ← Episode label
                if let episodeLabel {
                    Text(episodeLabel)
                        .font(.Typography.Medium.caption2)
                        .foregroundStyle(Color.Neutral.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, showsFooter ? 15 : 3)
                }

                // ← Stacked bottom badges (max 2)
                if hasImage, !badge.bottomBadges.isEmpty {
                    bottomBadgesOverlay
                }
            }

            // ← Continue Watching footer
            if showsFooter, let progress {
                progressTrack(progress: progress)
                iconRow
            }
        }
        .frame(width: size.width, height: size.height, alignment: .top)
    }

    // MARK: - Bottom Badges Overlay

    private var bottomBadgesOverlay: some View {
        VStack(spacing: 0) { // ← ubah gap antar badge (0 = rapat)
            // ← badge pertama (atas) — white bg black fg (dibalik)
            if let first = badge.bottomBadges.first {
                Text(first.text.uppercased())
                    .font(.system(size: 7, weight: .bold)) // ← ubah font size badge atas
                    .foregroundStyle(Color.Neutral.black) // ← ubah warna teks badge atas (hitam)
                    .padding(.horizontal, 6) // ← ubah padding horizontal badge atas
                    .padding(.vertical, 2) // ← ubah padding vertical badge atas
                    .background(Color.Neutral.white) // ← ubah warna background badge atas (putih)
                    .cornerRadius(2) // ← ubah corner radius badge atas
            }

            // ← badge kedua (bawah) — red bg white fg (dibalik)
            if badge.bottomBadges.count > 1 {
                let second = badge.bottomBadges[1]
                Text(second.text.uppercased())
                    .font(.system(size: 7, weight: .bold)) // ← ubah font size badge bawah
                    .foregroundStyle(Color.Neutral.white) // ← ubah warna teks badge bawah (putih)
                    .padding(.horizontal, 6) // ← ubah padding horizontal badge bawah
                    .padding(.vertical, 2) // ← ubah padding vertical badge bawah
                    .background(Color.Primary.red) // ← ubah warna background badge bawah (merah)
                    .cornerRadius(2) // ← ubah corner radius badge bawah
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, episodeLabelForBadge != nil ? 16 : 0) // ← ubah offset jika ada episode label
    }

    private var episodeLabelForBadge: String? {
        if case .continueWatching(_, let label) = kind { return label }
        return nil
    }

    @ViewBuilder
    func clippedImage(showsFooter: Bool) -> some View {
        if showsFooter {
            imageLayer
                .frame(width: size.width, height: TitleCardMetrics.posterImageHeight)
                .clipShape(
                    .rect(
                        topLeadingRadius: TitleCardMetrics.cornerRadius,
                        topTrailingRadius: TitleCardMetrics.cornerRadius
                    )
                )
        } else {
            imageLayer
                .frame(width: size.width, height: TitleCardMetrics.posterImageHeight)
                .clipShape(RoundedRectangle(cornerRadius: TitleCardMetrics.cornerRadius))
        }
    }

    func progressTrack(progress: Double) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Color.Neutral.greyLight2
                Color.Primary.red
                    .frame(width: geometry.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(width: size.width, height: 3)
    }

    var iconRow: some View {
        HStack(spacing: 52) {
            Button { onInfoTap?() } label: {
                TemplateIcon(image: Image.Icon.info, size: 20, tint: footerIconTint)
            }
            Button { onMoreTap?() } label: {
                KebabDots()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(footerIconTint)
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 6)
        .padding(.horizontal, 7)
        .frame(width: size.width)
        .background(hasImage ? Color.Neutral.greyDark2 : .clear)
    }

    var footerIconTint: Color {
        hasImage ? Color.Neutral.greyLight1 : Color.Neutral.white
    }
}