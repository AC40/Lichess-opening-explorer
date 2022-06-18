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
    var canBeMovedTo = false {
        didSet {
            isLegal = canBeMovedTo
        }
    }
    var canBeTaken = false {
        didSet {
            canBeMovedTo = canBeTaken
            isLegal = canBeTaken
        }
    }
    var canBeTakenWithEnPassant = false {
        didSet {
            canBeMovedTo = canBeTakenWithEnPassant
            canBeTaken = canBeTakenWithEnPassant
            isLegal = canBeTakenWithEnPassant
        }
    }
    
    init(_ piece: Piece = Piece.none, isLegal: Bool = false) {
        self.piece = piece
        self.isLegal = isLegal
    }
}
