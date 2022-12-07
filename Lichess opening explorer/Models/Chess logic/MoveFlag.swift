//
//  MoveFlag.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.12.22.
//

import Foundation

enum MoveFlag {
    case move
    case capture
    case shortCastle
    case longCastle
    case promotion(piece: PieceType)
    case enPassant
    case doubleStep
}
