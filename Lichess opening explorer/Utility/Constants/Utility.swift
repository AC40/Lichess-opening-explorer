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
    
    /// Returns a string containing the fens information about castling legality (from "kqKQ" to "")
    static func castlingRightFromFen(_ fen: String) -> String {
        
        let parts = fen.split(separator: " ")
        
        guard parts.count == 6 else {
            return ""
        }
        
        return String(parts[2])
    }
    
    static func enPassantSquareFromFen(_ fen: String) -> String {
        let parts = fen.split(separator: " ")
        
        guard parts.count == 6 else {
            return ""
        }
        
        return String(parts[3])
    }
}
