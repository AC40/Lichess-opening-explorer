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
    let averageRating, white, draws, black: Int
    let game: LichessOpening?
    
}