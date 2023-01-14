//
//  LichessMove.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 12.01.23.
//

import Foundation

struct LichessMove: Decodable, Identifiable {
    internal let id = UUID()
    
    let uci, san: String
    let white, draws, black: Int
    let averageRating: Int?
    let averageOpponentRating: Int?
    let performace: Int?
    let game: LichessOpening?
    
}
