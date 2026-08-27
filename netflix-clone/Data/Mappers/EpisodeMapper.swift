//
//  EpisodeMapper.swift
//  netflix-clone
//

import Foundation

// MARK: - Dummy DTO

/// Data Transfer Object — matches `episodes.json` structure (dummy fallback).
struct EpisodeDTO: Codable {
    let id: String
    let title: String
    let duration: String
    let synopsis: String
}

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

    // MARK: - Dummy

    /// Map dummy DTO → Domain Model.
    static func map(from dto: EpisodeDTO) -> Episode {
        Episode(
            id: dto.id,
            tmdbId: nil,
            title: dto.title,
            duration: dto.duration,
            synopsis: dto.synopsis,
            stillPath: nil,
            airDate: nil,
            episodeNumber: nil,
            seasonNumber: nil
        )
    }

    static func map(from dtos: [EpisodeDTO]) -> [Episode] {
        dtos.map(map(from:)) // ← map array
    }

    static func loadDummy() -> [Episode] {
        loadJSON(filename: "episodes") // ← load dari dummy JSON
    }

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

    // MARK: - Private

    private static func loadJSON(filename: String) -> [Episode] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dtos = try? JSONDecoder().decode([EpisodeDTO].self, from: data)
        else { return [] }
        return map(from: dtos)
    }
}
