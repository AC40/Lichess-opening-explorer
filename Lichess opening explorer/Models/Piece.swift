//
//  Piece.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import Foundation

struct Piece {
    
    static let none = Piece(color: .none, type: .none)
    
    static let kingW = Piece(color: .white, type: .king)
    static let queenW = Piece(color: .white, type: .queen)
    static let bishopW = Piece(color: .white, type: .bishop)
    static let knightW = Piece(color: .white, type: .knight)
    static let rookW = Piece(color: .white, type: .rook)
    static let pawnW = Piece(color: .white, type: .pawn)
    
    static let kingB = Piece(color: .black, type: .king)
    static let queenB = Piece(color: .black, type: .queen)
    static let bishopB = Piece(color: .black, type: .bishop)
    static let knightB = Piece(color: .black, type: .knight)
    static let rookB = Piece(color: .black, type: .rook)
    static let pawnB = Piece(color: .black, type: .pawn)
    
    var color: ChessColor
    var type: PieceType
}

enum PieceType: String {
    
    case none = ""
    case king = "king"
    case queen = "queen"
    case rook = "rook"
    case bishop = "bishop"
    case knight = "knight"
    case pawn = "pawn"
}

enum ChessColor: String {
    case white = "W"
    case black = "B"
    case none = ""
}
