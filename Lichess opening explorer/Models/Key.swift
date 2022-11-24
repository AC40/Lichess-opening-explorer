//
//  Key.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 21.06.22.
//

import Foundation

struct Key: Hashable {
    
    var key: Tile
    
    init(_ key: Tile) {
        self.key = key
    }
    
    // Protocol functions
    static func == (lhs: Key, rhs: Key) -> Bool {
        
        let (leftFile, leftRank) = lhs.key
        let (rightFile, rightRank) = rhs.key
        
        return leftFile == rightFile && leftRank == rightRank
    }
    
    func hash(into hasher: inout Hasher) {
        
        let (file, rank) = key
        hasher.combine(file)
        hasher.combine(rank)
    }
}
