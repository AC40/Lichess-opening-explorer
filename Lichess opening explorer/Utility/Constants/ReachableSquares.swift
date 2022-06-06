//
//  ReachableSquares.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 06.06.22.
//

import Foundation

struct ReachableSquares {
    
    static func forPiece(_ type: PieceType) -> [Int] {
        
        switch type {
        case .none:
            return []
        case .king:
            return [1, 7, 8, 9, -1, -7, -8, -9]
        case .queen:
            return [1, 7, 8, 9, -1, -7, -8, -9, 1, 2, 3, 4, 5, 6, 7, 8, 16, 24, 32, 40, 48, 56, -1, -2, -3, -4, -5, -6, -7, -8, -16, -24, -32, -40, -48, -56]
        case .rook:
            return [1, 2, 3, 4, 5, 6, 7, 8, 16, 24, 32, 40, 48, 56, -1, -2, -3, -4, -5, -6, -7, -8, -16, -24, -32, -40, -48, -56, 9, 18, 27, 36, 45, 54, 63, -9, -18, -27, -36, -45, -54, -63]
        case .bishop:
            return [9, 18, 27, 36, 45, 54, 63, -9, -18, -27, -36, -45, -54, -63]
        case .knight:
            return [6, 10, 15, 17, -6, -10, -15, -17]
        case .pawn:
            return [8]
        }
    }
}
