//
//  Array + loadFEN.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 06.06.22.
//

import Foundation

extension Array where Element == Square {
    
    mutating func loadFEN(_ fen: String) {
        // Store incase FEN is invalid
        let backup = self
        // Clear board
        self = Array(repeating: Square(), count: 64)
        
        let pieceTypeForSymbol: [String: PieceType] = ["k": .king, "q": .queen, "r": .rook, "b": .bishop, "p": .pawn]
        
        let parts = fen.split(separator: " ")
        let fenBoard = [Character](String(parts[0].description).replacingOccurrences(of: "/", with: ""))
        var i = 0
        
        for char in fenBoard {
            
            if let pieceType = pieceTypeForSymbol[char.lowercased()] {
                let pieceColor = char.isUppercase ? ChessColor.white : ChessColor.black
                
                guard i < self.count else {
                    //TODO: Potentially notify about invalid FEN
                    self = backup
                    return
                }
                
                self[i].piece = Piece(color: pieceColor, type: pieceType)
                
            }
            
            if char.isNumber {
                i += char.wholeNumberValue!
            } else {
                i += 1
            }
        }
    }
}
