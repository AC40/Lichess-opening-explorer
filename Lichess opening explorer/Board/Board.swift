//
//  Board.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 01.12.22.
//

import Foundation

struct Board {
    
    var squares: [[Square]] = []
    var moves: [[Move]] = []
    var currentLine: Int = 0
    
    var promotionSquare: Tile? = nil
    var promotingPawnSquare: Tile? = nil
    
    var whiteKingSquare: Tile = Tile(7, 4)
    var blackKingSquare: Tile = Tile(0, 4)
    
    var whiteEnPassants: [Tile] = []
    var blackEnPassants: [Tile] = []
    
    var whiteKingHasMoved: Bool = false
    var blackKingHasMoved: Bool = false
    
    var whiteQueensRookHasMoved = false
    var whiteKingsRookHasMoved = false
    var blackQueensRookHasMoved = false
    var blackKingsRookHasMoved = false
    
    var whiteTurn = true
    var check = false
    var checkmate = false
    var termination: Termination = .none
    
    //MARK: Functions
    init() {
        loadDefaultFEN()
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
        
        whiteTurn = true
        check = false
        checkmate = false
        termination = .none
    }
    
    mutating func getKingPosition() {
        let whiteKingRank: Int = squares.firstIndex(where: { $0.contains(where: { $0.piece == .kingW})}) ?? 7
        let whiteKingFile: Int = squares[whiteKingRank].firstIndex(where: {$0.piece == .kingW }) ?? 4
        
        let blackKingRank: Int = squares.firstIndex(where: { $0.contains(where: { $0.piece == .kingB})}) ?? 0
        let blackKingFile: Int = squares[blackKingRank].firstIndex(where: {$0.piece == .kingB }) ?? 4
        
        whiteKingSquare = Tile(whiteKingRank, whiteKingFile)
        blackKingSquare = Tile(blackKingRank, blackKingFile)
    }
    
    mutating func checkRookStatus() {
        if squares[7, 0].piece != .rookW {
            whiteQueensRookHasMoved = true
        }
        
        if squares[7, 7].piece != .rookW {
            whiteKingsRookHasMoved = true
        }
        
        if squares[0, 0].piece != .rookB {
            blackQueensRookHasMoved = true
        }
        
        if squares[0, 7].piece != .rookB {
            blackKingsRookHasMoved = true
        }
    }
    
    subscript(square: Tile) -> Square {
        get {
            squares[square.rank][square.file]
        }
        set {
            squares[square.rank][square.file] = newValue
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
