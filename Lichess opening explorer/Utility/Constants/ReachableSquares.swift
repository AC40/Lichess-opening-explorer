//
//  ReachableSquares.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 06.06.22.
//

import Foundation

struct ReachableSquares {
    
    static func forPiece(_ piece: Piece) -> [Tile] {
        
        switch piece.type {
        case .none:
            return []
        case .king:
            return [(1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)]
        case .queen:
            return [(1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)]
        case .rook:
            return [(1, 0), (0, 1), (-1, 0), (0, -1)]
        case .bishop:
            return [(1, 1), (1, -1), (-1, 1), (-1, -1)]
        case .knight:
            return [(1, 2), (2, 1), (-1, 2), (-2, 1), (1, -2), (2, -1), (-1, -2), (-2, -1)]
        case .pawn:
            if piece.color == .white {
                return [(1, 0)]
            } else {
                return [(-1, 0)]
            }
        }
    }
}
