//
//  Array + loadDefaultFEN.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import Foundation

extension Array where Element == Square {
    
    mutating func loadDefaultFEN() {
        guard self.count == 64 else {
            print("ERROR: array does not have a count of 64... cannot inject default FEN")
            return
        }
        
        self = Array(repeating: Square(), count: 64)
        
        // Black pieces
        self[0].piece = Piece.rookB
        self[1].piece = Piece.knightB
        self[2].piece = Piece.bishopB
        self[3].piece = Piece.queenB
        self[4].piece = Piece.kingB
        self[5].piece = Piece.bishopB
        self[6].piece = Piece.knightB
        self[7].piece = Piece.rookB
        self[8].piece = Piece.pawnB
        self[9].piece = Piece.pawnB
        self[10].piece = Piece.pawnB
        self[11].piece = Piece.pawnB
        self[12].piece = Piece.pawnB
        self[13].piece = Piece.pawnB
        self[14].piece = Piece.pawnB
        self[15].piece = Piece.pawnB
        
        // White pieces
        self[48].piece = Piece.pawnW
        self[49].piece = Piece.pawnW
        self[50].piece = Piece.pawnW
        self[51].piece = Piece.pawnW
        self[52].piece = Piece.pawnW
        self[53].piece = Piece.pawnW
        self[54].piece = Piece.pawnW
        self[55].piece = Piece.pawnW
        self[56].piece = Piece.rookW
        self[57].piece = Piece.knightW
        self[58].piece = Piece.bishopW
        self[59].piece = Piece.queenW
        self[60].piece = Piece.kingW
        self[61].piece = Piece.bishopW
        self[62].piece = Piece.knightW
        self[63].piece = Piece.rookW
    }
}
