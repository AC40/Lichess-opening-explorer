//
//  Field.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 01.06.22.
//

import Foundation

struct Square {
    
    var piece = Piece.none
    
    var canBeMovedTo = false {
        didSet {
            if !canBeMovedTo {
                canBeTaken = false
            }
        }
    }
    
    var canBeTaken = false {
        didSet {
            if canBeTaken {
                canBeMovedTo = canBeTaken
            }
        }
    }
    
    var canBeTakenWithEnPassant = false {
        didSet {
            if canBeTakenWithEnPassant {
                canBeMovedTo = canBeTakenWithEnPassant
            }
        }
    }
    
    init(_ piece: Piece = Piece.none) {
        self.piece = piece
    }
}
