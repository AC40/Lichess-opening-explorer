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
            self[i] = self[i].map { square in
                var transformed = square
                transformed.isLegal = false
                return transformed
            }
        }
    }
}
