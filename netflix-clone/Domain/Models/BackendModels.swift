//
//  BackendModels.swift
//  netflix-clone
//

import Foundation

/// User backend (`POST /v1/auth/signin` response). Mirrors Go `models.User`.
/// Codable supaya bisa di-cache lokal (UserDefaults) buat restore cepat + offline.
struct BackendUser: Codable {
    let uid: String
    let email: String
    let displayName: String
    let provider: String
    let createdAt: Date
}

/// Netflix-style profile. Mirrors Go `models.Profile`.
/// Codable supaya bisa di-cache lokal (UserDefaults) buat restore cepat + offline.
struct UserProfile: Identifiable, Codable {
    let profileId: String
    let name: String
    let avatarColor: String
    let isKid: Bool
    let createdAt: Date

    var id: String { profileId } // ← Identifiable dari profileId

    /// Placeholder untuk preview/guest saat belum ada data dari backend.
    static func placeholder(_ index: Int) -> UserProfile {
        UserProfile(
            profileId: "placeholder-\(index)",
            name: "User \(index + 1)",
            avatarColor: "blue",
            isKid: false,
            createdAt: .distantPast
        )
    }
}

/// Saved title (My List). Mirrors Go `models.WatchlistItem`.
struct WatchlistItemModel: Identifiable, Decodable {
    let mediaId: Int
    let mediaType: String
    let title: String
    let posterPath: String
    let addedAt: Date

    var id: String { "\(mediaType)-\(mediaId)" } // ← Identifiable komposit
}

/// Playback progress (Continue Watching). Mirrors Go `models.WatchProgress`.
struct WatchProgressModel: Identifiable, Decodable {
    let mediaId: Int
    let mediaType: String
    let title: String
    let posterPath: String
    let position: Double
    let duration: Double
    let completion: Double
    let updatedAt: Date

    var id: String { "\(mediaType)-\(mediaId)" } // ← Identifiable komposit
}

/// Watch history entry. Mirrors Go `models.HistoryEntry`.
struct HistoryEntryModel: Identifiable, Decodable {
    let mediaId: Int
    let mediaType: String
    let title: String
    let posterPath: String
    let completed: Bool
    let watchedAt: Date

    var id: String { "\(mediaType)-\(mediaId)" } // ← Identifiable komposit
}