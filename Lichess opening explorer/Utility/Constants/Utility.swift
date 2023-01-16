//
//  Utility.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 15.01.23.
//

import Foundation

struct Utility {
    
    static func distanceBetweenTwoSquares(_ a: Tile, _ b: Tile) -> Int? {
        
        guard a.rank.isOnBoard() && a.file.isOnBoard() else {
            return nil
        }
        
        guard b.rank.isOnBoard() && b.file.isOnBoard() else {
            return nil
        }
        
        let rankDistance = a.rank - b.rank
        let fileDistance = a.file - b.file
        
        let distance = abs(rankDistance) + abs(fileDistance)
        
        return distance
    }
}
