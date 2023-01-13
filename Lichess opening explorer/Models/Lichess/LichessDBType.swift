//
//  DBType.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 13.01.23.
//

import Foundation

enum LichessDBType: String, Hashable {
    case lichess = "lichess"
    case masters = "masters"
    case player = "player"
    
    static func stringToType(_ string: String) -> LichessDBType {
        switch string {
        case "lichess":
            return .lichess
        case "masters":
            return .masters
        case "player":
            return .player
        default:
            return .lichess
        }
    }
}
