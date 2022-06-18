//
//  Array + allIllegal.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 06.06.22.
//

import Foundation

extension Array where Element == Array<Square> {
    
    mutating func makeAllIllegal() {
        
        for i in 0..<self.count {
            for i2 in 0..<self[i].count {
                self[i][i2].canBeMovedTo = false
            }
        }
    }
}
