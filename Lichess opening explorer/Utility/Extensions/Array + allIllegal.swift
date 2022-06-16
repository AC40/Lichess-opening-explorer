//
//  Array + allIllegal.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 06.06.22.
//

import Foundation

extension Array where Element == Square {
    
    mutating func makeAllIllegal() {
        
        for i in 0..<self.count {
            self[i].isLegal = false
            self[i].canBeMovedTo = false
            self[i].canBeTaken = false
        }
    }
}
