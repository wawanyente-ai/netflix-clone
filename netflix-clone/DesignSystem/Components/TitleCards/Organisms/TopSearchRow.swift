//
//  TopSearchRow.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 26/08/26.
//


// Components/TitleCard/Organisms/TopSearchRow.swift

import SwiftUI

// MARK: - TopSearchRow

/// Single row in the Top Searches list: a `TitleCard(.topSearch)` thumbnail + title.
/// The play affordance and mini Top 10 badge are drawn by `TitleCard` itself —
/// this view only adds the row title alongside it.
struct TopSearchRow<Thumbnail: View>: View {

    // MARK: Properties

    let title: String
    let hasTopTenBadge: Bool
    let hasImage: Bool
    let onPlayTap: () -> Void
    let thumbnail: () -> Thumbnail

    // MARK: Initialization

    init(
        title: String,
        hasTopTenBadge: Bool = false,
        hasImage: Bool = true,
        onPlayTap: @escaping () -> Void = {},
        @ViewBuilder thumbnail: @escaping () -> Thumbnail
    ) {
        self.title = title
        self.hasTopTenBadge = hasTopTenBadge
        self.hasImage = hasImage
        self.onPlayTap = onPlayTap
        self.thumbnail = thumbnail
    }

    // MARK: Body

    var body: some View {
        HStack(spacing: 16) { // ← "card + title" gap per Figma
            TitleCard(
                kind: .topSearch,
                badge: BadgeConfig(showTopTen: hasTopTenBadge),
                hasImage: hasImage,
                onPlayTap: onPlayTap
            ) {
                thumbnail()
            }

            Text(title)
                .font(.Typography.Bold.caption1)
                .foregroundStyle(Color.Neutral.grey)
                .lineLimit(1)

            Spacer(minLength: 0)

            VideoControlButton(variant: .play(.thumbnailSmall)) { onPlayTap() }
        }
        .padding(.trailing, 8) // ← row right inset per Figma "content row"
        .frame(height: 54)
    }
}

// MARK: - TopSearchList

/// Vertical list of `TopSearchRow`s, generic over `Item` + `Thumbnail`.
struct TopSearchList<Item: Identifiable, Thumbnail: View>: View {

    // MARK: Properties

    let items: [Item]
    let title: (Item) -> String
    let hasTopTenBadge: (Item) -> Bool
    let onPlayTap: (Item) -> Void
    let thumbnail: (Item) -> Thumbnail

    // MARK: Initialization

    init(
        items: [Item],
        title: @escaping (Item) -> String,
        hasTopTenBadge: @escaping (Item) -> Bool = { _ in false },
        onPlayTap: @escaping (Item) -> Void = { _ in },
        @ViewBuilder thumbnail: @escaping (Item) -> Thumbnail
    ) {
        self.items = items
        self.title = title
        self.hasTopTenBadge = hasTopTenBadge
        self.onPlayTap = onPlayTap
        self.thumbnail = thumbnail
    }

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // ← inter-row gap
            ForEach(items) { item in
                TopSearchRow(
                    title: title(item),
                    hasTopTenBadge: hasTopTenBadge(item),
                    onPlayTap: { onPlayTap(item) }
                ) {
                    thumbnail(item)
                }
            }
        }
    }
}

// MARK: - Preview

private struct PreviewItem: Identifiable {
    let id: String
    let title: String
}

#Preview {
    TopSearchList(
        items: [
            PreviewItem(id: "1", title: "The Sea Beast"),
            PreviewItem(id: "2", title: "Peaky Blinders"),
            PreviewItem(id: "3", title: "The Umbrella Academy")
        ],
        title: { $0.title },
        hasTopTenBadge: { _ in true }
    ) { _ in
        Color.Neutral.greyDark1
    }
    .padding()
    .background(Color.Neutral.black)
}