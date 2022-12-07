//
//  Move.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.12.22.
//

import Foundation

/// Represents a single move made by a piece on the chessboard
struct Move: Identifiable {
    var id = UUID()
    
    /// Tile the move starts at:  (6,4), representing e2
    var start: Tile
    
    /// Tile the move ends at: (4, 4), representing e4
    var end: Tile
    
    //TODO: Decide, wether piece is really necessary
    var piece: Piece?
    
    /// Remembers captured piece, to enable backwards tracking
    var capture: Piece?
    
    /// Flags special moves for easy handling
    var flag: MoveFlag
    
    /// A bool describing wether a move induced a check or not
    var check: Bool
    
    // The type of termination (if any) invoked by the move
    var termination: Termination
    
    // If a move has an alternative, than an array containing that move is added to variations: variations.append([move])
    // Any move, after said move is appended: variations[0].append(move)
    // Additional alternative moves create a seperate variation: variations.append([move2])
    /// Array of variations, each being an array of moves
    var variations: [[Move]]?
    
    init(from start: Tile, to end: Tile, piece: Piece? = nil, capture: Piece? = nil, flag: MoveFlag = .move, termination: Termination = .none, check: Bool = false, variations: [[Move]]? = nil) {
        self.start = start
        self.end = end
        self.piece = piece
        self.capture = capture
        self.flag = flag
        self.termination = termination
        self.check = check
        self.variations = variations
    }
}
