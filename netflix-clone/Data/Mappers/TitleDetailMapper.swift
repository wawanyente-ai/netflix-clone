//
//  TitleDetailMapper.swift
//  netflix-clone
//

import Foundation

// MARK: - Mapper

enum TitleDetailMapper {

    // MARK: - TMDB Movie Detail → Domain

    /// Map TMDB movie detail → TitleDetail.
    static func fromMovieDetail(_ dto: MovieDetailDTO, seasonCount: String = "Movie") -> TitleDetail {
        TitleDetail(
            id: "movie-\(dto.id)",                         // ← prefix untuk membedakan movie/TV
            tmdbId: dto.id,                                // ← TMDB ID untuk API calls
            title: dto.title,                               // ← judul
            year: String(dto.releaseDate?.prefix(4) ?? ""), // ← tahun
            rating: dto.genres?.first?.name ?? "N/A",      // ← genre pertama sebagai rating
            seasonCount: seasonCount,                       // ← "Movie" atau runtime
            synopsis: dto.overview,                         // ← sinopsis
            episodes: [],                                   // ← movie nggak punya episodes
            posterPath: dto.posterPath,                     // ← path poster
            backdropPath: dto.backdropPath,                 // ← path backdrop
            voteAverage: dto.voteAverage,                   // ← rating
            genres: dto.genres?.map { Genre(id: $0.id, name: $0.name) } ?? [], // ← genres
            cast: dto.credits?.cast?.prefix(10).map {      // ← top 10 cast
                CastMember(id: $0.id, name: $0.name, character: $0.character, profilePath: $0.profilePath)
            } ?? [],
            trailerKey: dto.videos?.results.first(where: { $0.type == "Trailer" })?.key // ← trailer pertama
        )
    }

    // MARK: - TMDB TV Detail → Domain

    /// Map TMDB TV show detail → TitleDetail.
    static func fromTVDetail(_ dto: TVShowDetailDTO) -> TitleDetail {
        TitleDetail(
            id: "tv-\(dto.id)",                             // ← prefix untuk membedakan movie/TV
            tmdbId: dto.id,                                 // ← TMDB ID
            title: dto.name,                                 // ← judul (name, bukan title)
            year: String(dto.firstAirDate?.prefix(4) ?? ""), // ← tahun
            rating: dto.genres?.first?.name ?? "N/A",       // ← genre pertama
            seasonCount: "\(dto.numberOfSeasons ?? 0) Seasons", // ← jumlah season
            synopsis: dto.overview,                          // ← sinopsis
            episodes: [],                                    // ← episodes di-load terpisah
            posterPath: dto.posterPath,                      // ← path poster
            backdropPath: dto.backdropPath,                  // ← path backdrop
            voteAverage: dto.voteAverage,                    // ← rating
            genres: dto.genres?.map { Genre(id: $0.id, name: $0.name) } ?? [], // ← genres
            cast: dto.credits?.cast?.prefix(10).map {       // ← top 10 cast
                CastMember(id: $0.id, name: $0.name, character: $0.character, profilePath: $0.profilePath)
            } ?? [],
            trailerKey: dto.videos?.results.first(where: { $0.type == "Trailer" })?.key // ← trailer
        )
    }
}
