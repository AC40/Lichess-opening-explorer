//
//  Field.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 01.06.22.
//

import Foundation

struct Square {
    
    var piece = Piece.none
    
    var isLegal = false
    
    init(_ piece: Piece = Piece.none, isLegal: Bool = false) {
        self.piece = piece
        self.isLegal = isLegal
    }
}
