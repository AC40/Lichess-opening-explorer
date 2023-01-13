//
//  DB.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 12.01.23.
//

import Foundation

struct LichessDBResponse: Decodable {
    let white, draws, black: Int
    let moves: [LichessMove]
    let recentGames: [LichessGame]?
    let topGames: [LichessGame]?
    let opening: LichessOpening?
}


// MARK: - Lichessgame
struct LichessGame: Decodable {
    let uci: String?
    let id: String
    let winner: String?
    let black, white: LichessPlayer
    let year: Int
    let month: String?
}

// MARK: - LichessPlayer
struct LichessPlayer: Decodable {
    let name: String
    let rating: Int
}
