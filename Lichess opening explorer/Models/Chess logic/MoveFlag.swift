//
//  MoveFlag.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.12.22.
//

import Foundation

enum MoveFlag: Equatable {
    case move
    case capture
    case shortCastle
    case longCastle
    case promotion(piece: PieceType)
    case enPassant
    case doubleStep
    
    func isCapture() -> Bool {
        return (self == .capture || self == .enPassant)
    }
}
