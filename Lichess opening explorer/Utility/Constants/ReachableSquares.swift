//
//  ReachableSquares.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 06.06.22.
//

import Foundation

struct ReachableSquares {
    
    static func forPiece(_ piece: Piece) -> [Int] {
        
        switch piece.type {
        case .none:
            return []
        case .king:
            return [1, 7, 8, 9, -1, -7, -8, -9]
        case .queen:
            return [1, -1, 8, -8, 7, -7, 9, -9]
        case .rook:
            return [1, -1, 8, -8]
        case .bishop:
            return [7, -7, 9, -9]
        case .knight:
            return [6, 10, 15, 17, -6, -10, -15, -17]
        case .pawn:
            if piece.color == .white {
                return [8]
            } else {
                return [-8]
            }
        }
    }
}
