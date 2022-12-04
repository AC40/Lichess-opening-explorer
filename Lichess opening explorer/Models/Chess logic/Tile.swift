//
//  Tile.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 20.06.22.
//

struct Tile: Equatable {
    var rank: Int
    var file: Int
    
    init(_ rank: Int, _ file: Int) {
        self.rank = rank
        self.file = file
    }
    
    init(_ tuple: (Int, Int)) {
        self.rank = tuple.0
        self.file = tuple.1
    }
    
    static func == (lhs: Tile, rhs: Tile) -> Bool {
        return (lhs.rank == rhs.rank && lhs.file == rhs.file)
    }
    
    static func == (lhs: Tile, rhs: (Int, Int)) -> Bool {
        return (lhs.rank == rhs.0 && lhs.file == rhs.1)
    }
}

//typealias Tile = (Int, Int)
