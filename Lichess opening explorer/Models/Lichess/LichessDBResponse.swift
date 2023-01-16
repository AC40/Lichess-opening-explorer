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
    let id: String
    
    let uci: String?
    let winner: Winner?
    let speed: Speed?
    let mode: String?
    let black, white: LichessPlayer
    let year: Int
    let month: String?
    
    enum Winner: String, CodingKey, Decodable {
        case white = "white"
        case black = "black"
    }
    
    enum Speed: String, CodingKey, Decodable, CaseIterable {
        case ultraBullet = "ultraBullet"
        case bullet = "bullet"
        case blitz = "blitz"
        case rapid = "rapid"
        case classical = "classical"
        case correspondence = "correspondence"
        
        func icon() -> String {
            switch self {
            case .ultraBullet:
                return "alarm.waves.left.and.right"
            case .bullet:
                return "bolt"
            case .blitz:
                return "flame"
            case .rapid:
                return "hare"
            case .classical:
                return "tortoise"
            case .correspondence:
                return "paperplane"
            }
        }
    }
}

// MARK: - LichessPlayer
struct LichessPlayer: Decodable {
    let name: String
    let rating: Int
}
