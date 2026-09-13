//
//  BackendService.swift
//  netflix-clone
//

import Foundation

/// Typed client untuk semua endpoint backend (`docs/backend.md`).
/// Semua method async; panggil via `Task { ... }` di ViewModel/Page.
enum BackendService {

    private static let client = BackendClient.shared

    // MARK: - Auth

    /// POST /v1/auth/signin — verifikasi token (dev bypass backend aktif:
    /// tanpa token dianggap user `dev-user`).
    struct SignInResponse: Decodable {
        let user: BackendUser
        let profiles: [UserProfile]
    }

    /// `displayName` opsional: fallback nama user kalau token Firebase tidak
    /// punya klaim `name` (endpoint `/v1/auth/signin`).
    static func signIn(displayName: String? = nil) async throws -> SignInResponse {
        struct Body: Encodable {
            let displayName: String
        }
        if let name = displayName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            return try await client.request("POST", "/v1/auth/signin", body: Body(displayName: name))
        }
        return try await client.request("POST", "/v1/auth/signin")
    }

    // MARK: - Profiles

    struct ProfileListResponse: Decodable {
        let profiles: [UserProfile]
    }

    static func profiles() async throws -> [UserProfile] {
        let res: ProfileListResponse = try await client.request("GET", "/v1/profiles")
        return res.profiles
    }

    static func createProfile(name: String, avatarColor: String = "blue") async throws -> UserProfile {
        struct Body: Encodable {
            let name: String
            let avatarColor: String
            let isKid: Bool
        }
        return try await client.request("POST", "/v1/profiles", body: Body(name: name, avatarColor: avatarColor, isKid: false))
    }

    // MARK: - My List

    struct WatchlistResponse: Decodable {
        let items: [WatchlistItemModel]
    }

    static func watchlist(profileId: String) async throws -> [WatchlistItemModel] {
        let res: WatchlistResponse = try await client.request("GET", "/v1/profiles/\(profileId)/mylist")
        return res.items
    }

    struct ToggleResponse: Decodable {
        let saved: Bool
    }

    static func toggleMyList(profileId: String, mediaType: String, mediaId: Int, title: String, posterPath: String) async throws -> Bool {
        struct Body: Encodable {
            let title: String
            let posterPath: String
        }
        let res: ToggleResponse = try await client.request(
            "PUT",
            "/v1/profiles/\(profileId)/mylist/\(mediaType)/\(mediaId)",
            body: Body(title: title, posterPath: posterPath)
        )
        return res.saved
    }

    // MARK: - Continue Watching

    struct ProgressResponse: Decodable {
        let items: [WatchProgressModel]
    }

    static func progress(profileId: String) async throws -> [WatchProgressModel] {
        let res: ProgressResponse = try await client.request("GET", "/v1/profiles/\(profileId)/progress")
        return res.items
    }

    static func saveProgress(profileId: String, mediaType: String, mediaId: Int, position: Double, duration: Double, title: String, posterPath: String = "") async throws {
        struct Body: Encodable {
            let position: Double
            let duration: Double
            let title: String
            let posterPath: String
        }
        try await client.requestNoBody(
            "PUT",
            "/v1/profiles/\(profileId)/progress/\(mediaType)/\(mediaId)",
            body: Body(position: position, duration: duration, title: title, posterPath: posterPath)
        )
    }

    // MARK: - Watch History

    struct HistoryResponse: Decodable {
        let items: [HistoryEntryModel]
        let nextCursor: String?
    }

    static func history(profileId: String, limit: Int = 20) async throws -> [HistoryEntryModel] {
        let res: HistoryResponse = try await client.request(
            "GET",
            "/v1/profiles/\(profileId)/history",
            query: ["limit": "\(limit)"]
        )
        return res.items
    }

    /// POST /v1/profiles/{id}/history — catat tontonan.
    static func logHistory(profileId: String, mediaType: String, mediaId: Int, title: String, posterPath: String = "", completed: Bool = false) async throws {
        struct Body: Encodable {
            let mediaId: Int
            let mediaType: String
            let title: String
            let posterPath: String
            let completed: Bool
        }
        try await client.requestNoBody(
            "POST",
            "/v1/profiles/\(profileId)/history",
            body: Body(
                mediaId: mediaId,
                mediaType: mediaType,
                title: title,
                posterPath: posterPath,
                completed: completed
            )
        )
    }

    // MARK: - Stream Catalog

    struct VideoCatalog: Decodable {
        let videos: [StreamVideo]
    }

    static func streamVideos() async throws -> [StreamVideo] {
        let res: VideoCatalog = try await client.request("GET", "/v1/videos")
        return res.videos
    }
}