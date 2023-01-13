//
//  Opening.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import Foundation

struct LichessOpening: Decodable, Equatable {
    static let none = LichessOpening(eco: nil, name: nil)
    
    let eco, name: String?
    
    static func == (lhs: LichessOpening, rhs: LichessOpening) -> Bool {
        return (lhs.eco == rhs.eco && lhs.name == rhs.name)
    }
}
