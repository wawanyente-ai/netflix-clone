//
//  VideoService.swift
//  netflix-clone
//

import Foundation

/// Demo video URLs for AVPlayer testing.
/// Sources: Google's sample video CDN (Blender Open Movies, legal for testing).
enum VideoService {

    // MARK: - Demo Videos

    struct DemoVideo: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let url: URL
        let posterURL: URL?
    }

    /// Available demo videos for testing AVPlayer.
    static let demoVideos: [DemoVideo] = [
        DemoVideo(
            title: "Big Buck Bunny",                              // ← ubah judul video
            description: "A giant rabbit deals with three bullying rodents.", // ← ubah deskripsi
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, // ← direct MP4 URL
            posterURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/220px-Big_buck_bunny_poster_big.jpg") // ← poster thumbnail
        ),
        DemoVideo(
            title: "Sintel",                                      // ← ubah judul video
            description: "A lonely young woman searches for her lost dragon companion.", // ← ubah deskripsi
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!, // ← direct MP4 URL
            posterURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/Sintel_poster.jpg/220px-Sintel_poster.jpg") // ← poster thumbnail
        ),
        DemoVideo(
            title: "Tears of Steel",                              // ← ubah judul video
            description: "A group of warriors travel to the future to save humanity.", // ← ubah deskripsi
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4")!, // ← direct MP4 URL
            posterURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Tears_of_Steel_poster.jpg/220px-Tears_of_Steel_poster.jpg") // ← poster thumbnail
        ),
        DemoVideo(
            title: "Elephants Dream",                             // ← ubah judul video
            description: "Two characters explore a strange mechanical world.", // ← ubah deskripsi
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, // ← direct MP4 URL
            posterURL: nil // ← tidak ada poster
        )
    ]
}
