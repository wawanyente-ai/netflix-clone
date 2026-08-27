//
//  MediaItemMapper.swift
//  netflix-clone
//

import Foundation

/// Mapper for converting TMDB DTOs → MediaItem (unified movie/TV model).
enum MediaItemMapper {

    // MARK: - Movie → MediaItem

    static func fromMovie(_ dto: MovieDTO) -> MediaItem {
        MediaItem(
            id: dto.id,                                  // ← TMDB movie ID
            title: dto.title,                             // ← judul film
            overview: dto.overview,                       // ← sinopsis
            posterPath: dto.posterPath,                   // ← path poster
            backdropPath: dto.backdropPath,               // ← path backdrop
            voteAverage: dto.voteAverage,                 // ← rating
            releaseDate: dto.releaseDate ?? "",           // ← tanggal rilis
            mediaType: .movie,                            // ← tipe movie
            genreIds: dto.genreIds ?? [],                 // ← genre IDs
            runtime: nil                                  // ← movie detail punya runtime
        )
    }

    static func fromMovies(_ dtos: [MovieDTO]) -> [MediaItem] {
        dtos.map(fromMovie) // ← map array
    }

    // MARK: - TV Show → MediaItem

    static func fromTVShow(_ dto: TVShowDTO) -> MediaItem {
        MediaItem(
            id: dto.id,                                  // ← TMDB TV ID
            title: dto.name,                              // ← judul TV (name, bukan title)
            overview: dto.overview,                       // ← sinopsis
            posterPath: dto.posterPath,                   // ← path poster
            backdropPath: dto.backdropPath,               // ← path backdrop
            voteAverage: dto.voteAverage,                 // ← rating
            releaseDate: dto.firstAirDate ?? "",          // ← tanggal tayang pertama
            mediaType: .tv,                               // ← tipe TV
            genreIds: dto.genreIds ?? [],                 // ← genre IDs
            runtime: nil                                  // ← TV detail punya episode runtime
        )
    }

    static func fromTVShows(_ dtos: [TVShowDTO]) -> [MediaItem] {
        dtos.map(fromTVShow) // ← map array
    }

    // MARK: - Multi-Search Result → MediaItem

    static func fromSearchResult(_ dto: MultiSearchResultDTO) -> MediaItem? {
        guard dto.mediaType == "movie" || dto.mediaType == "tv" else {
            return nil // ← skip person results
        }

        let isMovie = dto.mediaType == "movie"

        return MediaItem(
            id: dto.id,                                  // ← TMDB ID
            title: dto.displayName,                       // ← judul (title atau name)
            overview: dto.overview ?? "",                 // ← sinopsis (bisa kosong)
            posterPath: dto.posterPath,                   // ← path poster
            backdropPath: dto.backdropPath,               // ← path backdrop
            voteAverage: dto.voteAverage ?? 0,            // ← rating
            releaseDate: (isMovie ? dto.releaseDate : dto.firstAirDate) ?? "", // ← tanggal
            mediaType: isMovie ? .movie : .tv,            // ← tipe media
            genreIds: [],                                 // ← search result nggak punya genre IDs
            runtime: nil                                  // ← search result nggak punya runtime
        )
    }

    static func fromSearchResults(_ dtos: [MultiSearchResultDTO]) -> [MediaItem] {
        dtos.compactMap(fromSearchResult) // ← map array, skip person
    }

    // MARK: - Movie Detail → MediaItem

    static func fromMovieDetail(_ dto: MovieDetailDTO) -> MediaItem {
        MediaItem(
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            posterPath: dto.posterPath,
            backdropPath: dto.backdropPath,
            voteAverage: dto.voteAverage,
            releaseDate: dto.releaseDate ?? "",
            mediaType: .movie,
            genreIds: dto.genres?.map(\.id) ?? [],
            runtime: dto.runtime
        )
    }

    // MARK: - TV Detail → MediaItem

    static func fromTVDetail(_ dto: TVShowDetailDTO) -> MediaItem {
        MediaItem(
            id: dto.id,
            title: dto.name,
            overview: dto.overview,
            posterPath: dto.posterPath,
            backdropPath: dto.backdropPath,
            voteAverage: dto.voteAverage,
            releaseDate: dto.firstAirDate ?? "",
            mediaType: .tv,
            genreIds: dto.genres?.map(\.id) ?? [],
            runtime: nil
        )
    }
}
