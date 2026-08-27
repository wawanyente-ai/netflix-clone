//
//  TitleDetailViewModel.swift
//  netflix-clone
//

import Foundation

/// Manages Title Detail screen state: title info, episodes, cast, trailer.
/// Loads from TMDB API using media type (movie/TV) and ID.
@Observable
final class TitleDetailViewModel {

    // MARK: - Published State

    var titleDetail: TitleDetail?                 // ← data detail film/TV
    var selectedTab: TitleDetailsTabBar.Tab = .episodes // ← tab aktif
    var selectedSeason: Int = 1                   // ← season aktif
    var episodes: [Episode] = []                  // ← daftar episode (untuk TV)
    var recommendations: [MediaItem] = []         // ← rekomendasi "More Like This"
    var isLoading = false                         // ← loading state
    var errorMessage: String?                     // ← error message

    // MARK: - Properties

    private let mediaType: String                 // ← "movie" atau "tv"
    private let mediaId: Int                      // ← TMDB ID

    // MARK: - Init

    /// Initialize with TMDB media type and ID.
    /// - Parameters:
    ///   - mediaType: "movie" or "tv"
    ///   - mediaId: TMDB movie/TV ID
    init(mediaType: String = "movie", mediaId: Int = 0) {
        self.mediaType = mediaType
        self.mediaId = mediaId
        Task { await loadData() }
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            let service = TMDBService.shared

            if mediaType == "movie" {
                // ← load movie detail
                let detailDTO = try await service.fetchMovieDetail(id: mediaId)
                titleDetail = TitleDetailMapper.fromMovieDetail(detailDTO)

                // ← load recommendations
                if let recs = try? await service.fetchMovieRecommendations(id: mediaId) {
                    recommendations = MediaItemMapper.fromMovies(recs)
                }
            } else {
                // ← load TV detail
                let detailDTO = try await service.fetchTVDetail(id: mediaId)
                titleDetail = TitleDetailMapper.fromTVDetail(detailDTO)

                // ← load first season episodes
                if let firstSeason = detailDTO.seasons?.first {
                    let seasonDTO = try await service.fetchTVSeason(
                        seriesId: mediaId,
                        seasonNumber: firstSeason.seasonNumber
                    )
                    episodes = EpisodeMapper.fromTMDB(seasonDTO.episodes)
                }

                // ← load recommendations
                if let recs = try? await service.fetchTVRecommendations(id: mediaId) {
                    recommendations = MediaItemMapper.fromTVShows(recs)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            // ← fallback ke dummy data
            titleDetail = TitleDetailMapper.loadDummy()
        }

        isLoading = false
    }

    /// Load episodes for a specific season (when user changes season picker).
    func loadSeason(_ seasonNumber: Int) async {
        guard mediaType == "tv" else { return }
        selectedSeason = seasonNumber

        do {
            let seasonDTO = try await TMDBService.shared.fetchTVSeason(
                seriesId: mediaId,
                seasonNumber: seasonNumber
            )
            episodes = EpisodeMapper.fromTMDB(seasonDTO.episodes) // ← map episodes
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
