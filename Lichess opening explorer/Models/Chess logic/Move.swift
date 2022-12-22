//
//  Move.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.12.22.
//

import Foundation

/// Represents a single move made by a piece on the chessboard
struct Move: Identifiable, Equatable {
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
    
    // A FEN string describing the position `Before` the move was made
    var position: String
    
    // If a move has an alternative, than an array containing that move is added to variations: variations.append([move])
    // Any move, after said move is appended: variations[0].append(move)
    // Additional alternative moves create a seperate variation: variations.append([move2])
    /// Array of variations, each being an array of moves
    var variations: [[Move]]?
    
    /// An Int that hold the selected move in the current variation
    var varI: Int
    
    /// An Int that hold the number of the current variation. -1 if no variation
    var varNum: Int
    
    init(from start: Tile, to end: Tile, piece: Piece? = nil, capture: Piece? = nil, flag: MoveFlag = .move, termination: Termination = .none, check: Bool = false, position: String = "", variations: [[Move]]? = nil, variationIndex: Int = -1, variationNumber: Int = -1) {
        self.start = start
        self.end = end
        self.piece = piece
        self.capture = capture
        self.flag = flag
        self.termination = termination
        self.check = check
        self.position = position
        self.variations = variations
        self.varI = variationIndex
        self.varNum = variationNumber
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        return (
            lhs.start == rhs.start &&
            lhs.end == rhs.end &&
            lhs.piece == rhs.piece &&
            lhs.capture == rhs.capture &&
            lhs.flag == rhs.flag &&
            lhs.check == rhs.check &&
            lhs.position == rhs.position &&
            lhs.termination == rhs.termination
        )
    }
}
