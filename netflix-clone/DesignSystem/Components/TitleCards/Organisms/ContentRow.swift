//
//  ContentRow.swift
//  netflix-clone
//

import SwiftUI

/// Horizontally-scrolling rail of `TitleCard`s with a section header.
/// Generic over `Item` + `Background` so callers can drive it from any model and
/// plug in `AsyncImage`, a local asset, or a placeholder color per item.
struct ContentRow<Item: Identifiable, Background: View>: View {

    // MARK: Properties

    let title: String
    let items: [Item]
    let kind: (Item) -> TitleCard<Background>.Kind
    let badge: (Item) -> BadgeConfig
    let hasImage: (Item) -> Bool
    let onPlayTap: (Item) -> Void
    let onInfoTap: (Item) -> Void
    let background: (Item) -> Background

    // MARK: Initialization

    init(
        title: String,
        items: [Item],
        kind: @escaping (Item) -> TitleCard<Background>.Kind,
        badge: @escaping (Item) -> BadgeConfig = { _ in BadgeConfig() },
        hasImage: @escaping (Item) -> Bool = { _ in true },
        onPlayTap: @escaping (Item) -> Void = { _ in },
        onInfoTap: @escaping (Item) -> Void = { _ in },
        @ViewBuilder background: @escaping (Item) -> Background
    ) {
        self.title = title
        self.items = items
        self.kind = kind
        self.badge = badge
        self.hasImage = hasImage
        self.onPlayTap = onPlayTap
        self.onInfoTap = onInfoTap
        self.background = background
    }

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.Typography.Bold.label1)
                .foregroundStyle(Color.Semantic.textPrimary)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(items) { item in
                        TitleCard(
                            kind: kind(item),
                            badge: badge(item),
                            hasImage: hasImage(item),
                            onInfoTap: { onInfoTap(item) },
                            onPlayTap: { onPlayTap(item) }
                        ) {
                            background(item)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.Semantic.background)
    }
}

// MARK: - Preview

private struct PreviewItem: Identifiable {
    let id: String
    let title: String
}

#Preview {
    ContentRow(
        title: "Continue Watching",
        items: [
            PreviewItem(id: "1", title: "Stranger Things"),
            PreviewItem(id: "2", title: "Peaky Blinders"),
            PreviewItem(id: "3", title: "Iron Chef")
        ],
        kind: { _ in .continueWatching(progress: 0.3, episodeLabel: "S0:E00") },
        badge: { _ in BadgeConfig(showTopTen: true) }
    ) { _ in
        Color.Neutral.greyDark1
    }
    .padding(.vertical)
    .background(Color.Neutral.black)
}
