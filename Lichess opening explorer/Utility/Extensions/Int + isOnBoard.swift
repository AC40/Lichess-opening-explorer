//
//  Int + isOnBoard.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 18.06.22.
//

import Foundation

extension Int {
    func isOnBoard() -> Bool {
        return (self <= 7) && (self >= 0)
    }
}
