//
//  Moves.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 06.06.22.
//

import Foundation

struct Moves {
    
    static func forPiece(_ piece: Piece) -> [Tile] {
        
        switch piece.type {
        case .none:
            return []
        case .king:
            return [Tile(1, 0), Tile(0, 1), Tile(-1, 0), Tile(0, -1), Tile(1, 1), Tile(1, -1), Tile(-1, 1), Tile(-1, -1)]
        case .queen:
            return [Tile(1, 0), Tile(0, 1), Tile(-1, 0), Tile(0, -1), Tile(1, 1), Tile(1, -1), Tile(-1, 1), Tile(-1, -1)]
        case .rook:
            return [Tile(1, 0), Tile(0, 1), Tile(-1, 0), Tile(0, -1)]
        case .bishop:
            return [Tile(1, 1), Tile(1, -1), Tile(-1, 1), Tile(-1, -1)]
        case .knight:
            return [Tile(1, 2), Tile(2, 1), Tile(-1, 2), Tile(-2, 1), Tile(1, -2), Tile(2, -1), Tile(-1, -2), Tile(-2, -1)]
        case .pawn:
            if piece.color == .white {
                return [Tile(1, 0)]
            } else {
                return [Tile(-1, 0)]
            }
        }
    }
    
    static func pawnDiagonals(for color: ChessColor) -> [Tile] {
        switch color {
        case .white:
            return [Tile(1, 1), Tile(1, -1)]
        case .black:
            return [Tile(-1, 1), Tile(-1, -1)]
        case .none:
            return []
        }
    }
}
