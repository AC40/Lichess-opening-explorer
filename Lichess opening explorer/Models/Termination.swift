//
//  Termination.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.12.22.
//

import Foundation

enum Termination: Equatable {
    case checkmate
    case stalemate
    case fiftyMoveRule
    case resignation(color: ChessColor)
    
    case none
    
}
