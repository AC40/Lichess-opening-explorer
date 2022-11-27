//
//  Piece.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import Foundation

struct Piece: Equatable {
    
    //MARK: Variables
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
    
    var square: Tile?
    
    //MARK: Functions
    
    static func == (lhs: Piece, rhs: Piece) -> Bool {
        return lhs.color == rhs.color && lhs.type == rhs.type
    }
    
    func isSlidingPiece() -> Bool {
        return type == .rook || type == .bishop || type == .queen
    }
    
    func isKing() -> Bool {
        return type == .king
    }
    
    func isBishop() -> Bool {
        return type == .bishop
    }
    
    func isRook() -> Bool {
        return type == .rook
    }
    
    func isQueen() -> Bool {
        return type == .queen
    }
    
    func isKnight() -> Bool {
        return type == .knight
    }
    
    func isPawn() -> Bool {
        return type == .pawn
    }
    
    func isWhite() -> Bool {
        return color == .white
    }
    
    func isBlack() -> Bool {
        return color == .black
    }
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
