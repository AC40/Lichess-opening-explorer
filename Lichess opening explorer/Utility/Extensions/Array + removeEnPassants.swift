//
//  Array + removeEnPassants.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 03.12.22.
//

import Foundation

extension Array where Element == Array<Square> {
    
    mutating func removeEnPassants() {
        for i in 0..<self.count {
            for j in 0..<self[i].count {
                self[i][j].canBeTakenWithEnPassant = false
            }
        }
    }
}
