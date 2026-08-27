//
//  TitleDetailsTabBar.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// The tab row on a title-details page: Episodes / Collection / More Like
/// This / Trailers & More.
///
/// Composed entirely from the existing `VideoTabButton` molecule
/// (`Button_And_Tabs/Molecules`) — no new tab styling needed here.
///
/// ```swift
/// @State private var tab: TitleDetailsTabBar.Tab = .episodes
/// TitleDetailsTabBar(selection: $tab)
/// ```
struct TitleDetailsTabBar: View {

    // MARK: Types

    enum Tab: CaseIterable {
        case episodes, collection, moreLikeThis, trailersAndMore

        var title: String {
            switch self {
            case .episodes: "Episodes"
            case .collection: "Collection"
            case .moreLikeThis: "More Like This"
            case .trailersAndMore: "Trailers & More"
            }
        }
    }

    // MARK: Properties

    @Binding var selection: Tab

    // MARK: Body

    var body: some View {
        HStack(spacing: Metrics.spacing) {
            ForEach(Tab.allCases, id: \.self) { tab in
                VideoTabButton(title: tab.title, isSelected: tab == selection) {
                    selection = tab
                }
            }
        }
    }
}

// MARK: - Metrics

private extension TitleDetailsTabBar {
    enum Metrics {
        static let spacing: CGFloat = 16
    }
}

// MARK: - Preview

#Preview {
    struct PreviewHost: View {
        @State private var tab: TitleDetailsTabBar.Tab = .episodes
        var body: some View {
            TitleDetailsTabBar(selection: $tab)
                .padding()
                .background(Color.Neutral.black)
        }
    }
    return PreviewHost()
}