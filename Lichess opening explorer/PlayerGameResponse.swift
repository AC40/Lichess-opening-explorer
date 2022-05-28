//
//  PlayerGameResponse.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 28.05.22.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let playerGameResponse = try? newJSONDecoder().decode(PlayerGameResponse.self, from: jsonData)

import Foundation

// MARK: - PlayerGameResponse
struct PlayerGameResponse: Codable {
    let white, draws, black: Int
    let moves: [Move]
    let recentGames: [Game]
    let opening: Opening
}

// MARK: - Move
struct Move: Codable {
    let uci, san: String
    let averageOpponentRating, performance, white, draws: Int
    let black: Int
    let game: Game?
}

// MARK: - Game
struct Game: Codable {
    let id: String
    let winner: String?
    let speed, mode: String
    let black, white: Black
    let year: Int
    let month: String
    let uci: String?
}

// MARK: - Black
struct Black: Codable {
    let name: String
    let rating: Int
}

// MARK: - Opening
struct Opening: Codable {
    let eco, name: String
}
