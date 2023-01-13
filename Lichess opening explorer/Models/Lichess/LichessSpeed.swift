//
//  LichessSpeed.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 12.01.23.
//

import Foundation

enum LichessSpeed: String, CaseIterable {
    case ultraBullet = "ultraBullet"
    case bullet = "bullet"
    case blitz = "blitz"
    case rapid = "rapid"
    case classical = "classical"
    case correspondence = "correspondence"
}

extension Array where Element == LichessSpeed {
    func formattedString() -> String {
        var str = ""
        
        for i in self.indices {
            str.append(self[i].rawValue)
            
            if i < self.count-1 {
                str.append(",")
            }
        }
        
        return str
    }
}
