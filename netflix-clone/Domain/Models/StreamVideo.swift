//
//  StreamVideo.swift
//  netflix-clone
//

import Foundation

/// Playable video from the backend streaming catalog (`GET /v1/videos`).
/// Mirrors Go model `internal/models/video.go`.
struct StreamVideo: Identifiable, Decodable {
    var id: String { videoId } // ← Identifiable dari videoId
    let videoId: String
    let title: String
    let description: String
    let posterUrl: String
    let streamUrl: String
    let duration: Int
    let qualities: [String]
    let categories: [String]
}