//
//  Array + loadDefaultFEN.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import Foundation

extension Board {
    
    mutating func loadDefaultFEN() {
        self.loadFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    }
}
