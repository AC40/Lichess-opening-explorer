//
//  Array + loadDefaultFEN.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import Foundation

extension Array where Element == Piece {
    
    mutating func loadDefaultFEN() {
        guard self.count == 64 else {
            print("ERROR: array does not have a count of 64... cannot inject default FEN")
            return
        }
        
        self[0] = Piece.rookB
        self[1] = Piece.knightB
        self[2] = Piece.bishopB
        self[3] = Piece.queenB
        self[4] = Piece.kingB
        self[5] = Piece.bishopB
        self[6] = Piece.knightB
        self[7] = Piece.rookB
        self[8] = Piece.pawnB
        self[9] = Piece.pawnB
        self[10] = Piece.pawnB
        self[11] = Piece.pawnB
        self[12] = Piece.pawnB
        self[13] = Piece.pawnB
        self[14] = Piece.pawnB
        self[15] = Piece.pawnB
        
        self[48] = Piece.pawnW
        self[49] = Piece.pawnW
        self[50] = Piece.pawnW
        self[51] = Piece.pawnW
        self[52] = Piece.pawnW
        self[53] = Piece.pawnW
        self[54] = Piece.pawnW
        self[55] = Piece.pawnW
        self[56] = Piece.rookW
        self[57] = Piece.knightW
        self[58] = Piece.bishopW
        self[59] = Piece.queenW
        self[60] = Piece.kingW
        self[61] = Piece.bishopW
        self[62] = Piece.knightW
        self[63] = Piece.rookW
    }
}
