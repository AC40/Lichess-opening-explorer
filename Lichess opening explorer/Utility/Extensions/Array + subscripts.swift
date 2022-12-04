//
//  Array + subscripts.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.12.22.
//

import Foundation

extension Array where Element == Array<Square> {
    
    subscript(square: Tile) -> Square {
        get {
            self[square.0][square.1]
        }
        set {
            self[square.0][square.1] = newValue
        }
    }
    
    subscript(rank: Int, file: Int) -> Square {
        get {
            self[rank][file]
        }
        set {
            self[rank][file] = newValue
        }
    }
}
