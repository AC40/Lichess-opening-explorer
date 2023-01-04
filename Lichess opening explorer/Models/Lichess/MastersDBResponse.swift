//
//  MastersDatabaseResponse.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import Foundation

// MARK: - MastersDBResponse
struct MastersDBResponse: Decodable {
    let white, draws, black: Int
    let moves: [MasterMove]
    let topGames: [TopGame]
    let opening: LichessOpening?
}

// MARK: - Move
struct MasterMove: Decodable, Identifiable {
    internal let id = UUID()
    
    let uci, san: String
    let averageRating, white, draws, black: Int
    let game: LichessOpening?
    
}

// MARK: - TopGame
struct TopGame: Decodable {
    let uci, id: String
    let winner: String?
    let black, white: MasterPlayer
    let year: Int
    let month: String
}

// MARK: - Black
struct MasterPlayer: Decodable {
    let name: String
    let rating: Int
}
