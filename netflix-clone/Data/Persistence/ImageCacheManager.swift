//
//  ImageCacheManager.swift
//  netflix-clone
//
//  Image caching using URLCache + in-memory cache.
//  Serves appropriately sized TMDB images based on component.
//
import Foundation
import SwiftUI

// MARK: - TMDB Image Sizes

struct TMDBImageSize {
    /// Small poster for cards (w185)
    static let posterSmall = "w185"

    /// Medium poster (w342)
    static let posterMedium = "w342"

    /// Backdrop/hero (w780)
    static let backdropMedium = "w780"

    /// Profile images (w185)
    static let profileSmall = "w185"
}

// MARK: - Image Cache Manager

actor ImageCacheManager {
    static let shared = ImageCacheManager()

    private let urlCache: URLCache
    private var memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 100 * 1024 * 1024  // 100 MB
        return cache
    }()

    init() {
        // Configure URLCache for disk persistence
        let config = URLSessionConfiguration.default
        let cache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,   // 50 MB memory
            diskCapacity: 200 * 1024 * 1024,    // 200 MB disk
            diskPath: "netflix_image_cache"
        )
        URLCache.shared = cache
        self.urlCache = cache
    }

    /// Load image with multi-tier caching: memory → disk → network
    func loadImage(from url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString

        // Tier 1: Memory cache
        if let cached = memoryCache.object(forKey: key) {
            return cached
        }

        // Tier 2: Disk cache + network
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let image = UIImage(data: data) else {
                return nil
            }

            // Store in memory cache
            memoryCache.setObject(image, forKey: key, cost: data.count)

            return image
        } catch {
            return nil
        }
    }

    /// Clear all caches
    func clearAllCaches() {
        memoryCache.removeAllObjects()
        urlCache.removeAllCachedResponses()
    }
}