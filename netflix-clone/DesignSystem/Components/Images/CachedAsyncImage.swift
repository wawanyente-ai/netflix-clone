//
//  CachedAsyncImage.swift
//  netflix-clone
//
//  SwiftUI wrapper for AsyncImage with ImageCacheManager integration.
//  Automatically selects appropriate TMDB image size based on context.
//
import SwiftUI

// MARK: - Cached Async Image

struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content
    @State private var phase: AsyncImagePhase = .empty

    init(
        url: URL?,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.content = content
    }

    var body: some View {
        content(phase)
            .task(id: url) {
                guard let url else {
                    phase = .failure(CacheError.noURL)
                    return
                }

                do {
                    if let image = try await ImageCacheManager.shared.loadImage(from: url) {
                        phase = .success(Image(uiImage: image))
                    } else {
                        phase = .failure(CacheError.decodingFailed)
                    }
                } catch {
                    phase = .failure(error)
                }
            }
    }
}

// MARK: - Error Type

enum CacheError: LocalizedError {
    case noURL
    case decodingFailed
    case networkError

    var errorDescription: String? {
        switch self {
        case .noURL: return "No URL provided"
        case .decodingFailed: return "Failed to decode image"
        case .networkError: return "Network error"
        }
    }
}

// MARK: - TMDB Image URL Builder (optimized)

extension ImageURLBuilder {
    /// Build poster URL with appropriate size
    static func posterURL(
        from path: String?,
        size: String = TMDBImageSize.posterMedium
    ) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        let baseURL = "https://image.tmdb.org/t/p/"
        return URL(string: "\(baseURL)\(size)\(path)")
    }

    /// Build backdrop URL with appropriate size
    static func backdropURL(
        from path: String?,
        size: String = TMDBImageSize.backdropMedium
    ) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        let baseURL = "https://image.tmdb.org/t/p/"
        return URL(string: "\(baseURL)\(size)\(path)")
    }

    /// Build profile URL with appropriate size
    static func profileURL(
        from path: String?,
        size: String = TMDBImageSize.profileSmall
    ) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        let baseURL = "https://image.tmdb.org/t/p/"
        return URL(string: "\(baseURL)\(size)\(path)")
    }
}