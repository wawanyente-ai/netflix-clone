//
//  TitleCardMetrics.swift
//  netflix-clone
//

import SwiftUI

// MARK: - Metrics

enum TitleCardMetrics {
    case standard
    case continueWatching
    case topSearch

    var size: CGSize {
        switch self {
        case .standard: CGSize(width: 106, height: 152)
        case .continueWatching: CGSize(width: 106, height: 188)
        case .topSearch: CGSize(width: 96, height: 54)
        }
    }

    static let posterImageHeight: CGFloat = 152
    static let cornerRadius: CGFloat = 4
    static let topSearchBadgeScale: CGFloat = 0.53
}