//
//  Array + loadFEN.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 06.06.22.
//

import Foundation

extension Board {
    
    mutating func loadFEN(_ fen: String) {
        
        // Reset board (castling right, etc.)
        self.reset()
        
        // Store incase FEN is invalid
        let backup = self
        // Clear board
        self.squares = Array(repeating: Array<Square>(repeating: Square(), count: 8), count: 8)
        
        let pieceTypeForSymbol: [String: PieceType] = ["k": .king, "q": .queen, "r": .rook, "b": .bishop, "p": .pawn, "n": .knight]
        
        let parts = fen.split(separator: " ")
        let files = parts[0].split(separator: "/")
        
        var file = 0
        
        for fileString in files {
            let chars = [Character](fileString)
            var rank = 0
            
            for char in chars {
                if char.isNumber {
                    rank += char.wholeNumberValue!
                } else if char.isLetter{
                    guard let pieceType = pieceTypeForSymbol[char.lowercased()] else {
                        self = backup
                        return
                    }
                    let pieceColor = char.isUppercase ? ChessColor.white : ChessColor.black
                    self[file, rank].piece = Piece(color: pieceColor, type: pieceType)
                    rank += 1
                }
            }
            
            file += 1
        }
    }
}
