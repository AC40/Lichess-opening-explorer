//
//  PlayerDBResponse.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 28.05.22.
//
// This rank was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this rank to your project and do:
//
//   let playerGameResponse = try? newJSONDecoder().decode(PlayerDBResponse.self, from: jsonData)

import Foundation

// MARK: - PlayerDBResponse
struct PlayerDBResponse: Decodable {
    let white, draws, black: Int
    let moves: [LichessMove]
    let recentGames: [PlayerGame]
    let opening: LichessOpening
}

// MARK: - Move
struct PlayerMove:  Decodable {
    let uci, san: String
    let averageOpponentRating, performance, white, draws: Int
    let black: Int
    let game: PlayerGame?
}

// MARK: - Game
struct PlayerGame:  Decodable, Identifiable {
    let id: String
    let winner: String?
    let speed, mode: String
    let black, white: Player
    let year: Int
    let month: String?
    let uci: String?
}

// MARK: - Black
struct Player: Decodable {
    let name: String
    let rating: Int
}
