//
//  Board.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 01.12.22.
//

import Foundation

struct Board {
    
    var squares: [[Square]] = []
    
    var promotionSquare: Tile? = nil
    var promotingPawnSquare: Tile? = nil
    
    var whiteKingSquare: Tile = (7, 4)
    var blackKingSquare: Tile = (0, 4)
    
    var whiteEnPassants: [Tile] = []
    var blackEnPassants: [Tile] = []
    
    var whiteKingHasMoved: Bool = false
    var blackKingHasMoved: Bool = false
    
    var whiteQueensRookHasMoved = false
    var whiteKingsRookHasMoved = false
    var blackQueensRookHasMoved = false
    var blackKingsRookHasMoved = false
    
    var whiteTurn = true
    
    //MARK: Functions
    init() {
        loadDefaultFEN()
        
        let whiteKingRank: Int = squares.firstIndex(where: { $0.contains(where: { $0.piece == .kingW})}) ?? 7
        let whiteKingFile: Int = squares[whiteKingRank].firstIndex(where: {$0.piece == .kingW }) ?? 4
        
        let blackKingRank: Int = squares.firstIndex(where: { $0.contains(where: { $0.piece == .kingB})}) ?? 0
        let blackKingFile: Int = squares[blackKingRank].firstIndex(where: {$0.piece == .kingB }) ?? 4
        
        whiteKingSquare = (whiteKingRank, whiteKingFile)
        blackKingSquare = (blackKingRank, blackKingFile)
    }
    
     mutating func reset() {
        promotionSquare = nil
        promotingPawnSquare = nil
        
        whiteEnPassants = []
        blackEnPassants = []
        
        whiteKingHasMoved = false
        blackKingHasMoved = false
        
        whiteQueensRookHasMoved = false
        whiteKingsRookHasMoved = false
        blackQueensRookHasMoved = false
        blackKingsRookHasMoved = false
    }
    
    subscript(square: Tile) -> Square {
        get {
            squares[square.0][square.1]
        }
        set {
            squares[square.0][square.1] = newValue
        }
    }
    
    subscript(rank: Int, file: Int) -> Square {
        get {
            squares[rank][file]
        }
        set {
            squares[rank][file] = newValue
        }
    }
}
