//
//  EpisodeMapper.swift
//  netflix-clone
//

import Foundation

// MARK: - TMDB DTO

/// TMDB Episode DTO — matches TMDB season detail response.
struct TMDBEpisodeDTO: Codable {
    let id: Int
    let name: String
    let overview: String
    let episodeNumber: Int
    let seasonNumber: Int
    let airDate: String?
    let runtime: Int?
    let stillPath: String?

    enum CodingKeys: String, CodingKey {
        case id, name, overview, runtime
        case episodeNumber = "episode_number"
        case seasonNumber = "season_number"
        case airDate = "air_date"
        case stillPath = "still_path"
    }
}

// MARK: - Mapper

enum EpisodeMapper {

    // MARK: - TMDB

    /// Map TMDB episode DTO → Domain Model.
    static func fromTMDB(_ dto: TMDBEpisodeDTO) -> Episode {
        let durationText: String
        if let runtime = dto.runtime {
            durationText = "\(runtime)m" // ← format durasi dari menit
        } else {
            durationText = "" // ← durasi tidak tersedia
        }

        return Episode(
            id: "ep-\(dto.id)",                             // ← prefix TMDB ID
            tmdbId: dto.id,                                 // ← TMDB ID
            title: "\(dto.episodeNumber). \(dto.name)",     // ← nomor + judul episode
            duration: durationText,                          // ← durasi formatted
            synopsis: dto.overview,                          // ← sinopsis
            stillPath: dto.stillPath,                        // ← path gambar still
            airDate: dto.airDate,                            // ← tanggal tayang
            episodeNumber: dto.episodeNumber,                 // ← nomor episode
            seasonNumber: dto.seasonNumber                    // ← nomor season
        )
    }

    static func fromTMDB(_ dtos: [TMDBEpisodeDTO]) -> [Episode] {
        dtos.map(fromTMDB) // ← map array
    }
}
