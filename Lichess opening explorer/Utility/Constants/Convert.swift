//
//  Converter.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.12.22.
//

import Foundation

struct Convert {
    
    static let files = ["a", "b", "c", "d", "e", "f", "g", "h"]
    static let pieces: [PieceType: String] = [PieceType.pawn: "", .rook: "R", .knight: "N", .bishop: "B", .queen: "Q", .king: "K", .none: ""]
    
    static func moveToLongAlgebra(_ move: Move) -> String {
        return "\(tileToLongAlgebra(move.start))-\(tileToLongAlgebra(move.end))"
    }
    
    static func moveToShortAlgebra(_ move: Move) -> String {
        
        var str = ""
        
        guard move.start.rank.isOnBoard() && move.start.file.isOnBoard() && move.end.rank.isOnBoard() && move.end.file.isOnBoard() else {
            return ""
        }
        
        guard move.flag != .shortCastle else {
            return "O-O"
        }
        
        guard move.flag != .longCastle else {
            return "O-O-O"
        }
        
        guard move.piece != nil && move.piece != Piece.none else {
            return moveToLongAlgebra(move)
        }
        
        if move.piece!.type != .pawn {
            str += "\(pieces[move.piece!.type]!)\(move.capture != nil ? "x" : "")\(tileToLongAlgebra(move.end))"
        } else {
            str += "\(move.capture != nil ? files[move.start.file] + "x" : "")\(tileToLongAlgebra(move.end))"
        }
        
        str += moveAppendix(for: move)
        
        return str
    }
    
    static func tileToLongAlgebra(_ tile: Tile) -> String {
        
        
        guard tile.rank.isOnBoard() && tile.file.isOnBoard() else {
            return ""
        }
        
        return "\(files[tile.file])\(8 - tile.rank)"
    }
    
    static func moveAppendix(for move: Move) -> String {
        switch move.termination {
        case .checkmate:
            return "#"
        case .stalemate:
            return "="
        case .fiftyMoveRule:
            return "="
        case .resignation(color: _):
            if move.check {
                return "+"
            } else {
                return ""
            }
        case .none:
            if move.check {
                return "+"
            } else {
                return ""
            }
        }
    }
    
    static func shortAlgebraToTile(_ square: String) -> Tile? {
        
        let file = "\(square.first ?? Character.init(""))"
        let rank = square.last?.wholeNumberValue
        
        guard (file != "" && files.contains(file)) else {
            return nil
        }
        
        
        
        guard rank != nil else {
            return nil
        }
        
        guard rank! >= 1 && rank! <= 8  else {
            return nil
        }
                
        return Tile(8 - rank!, files.firstIndex(of: file)!)
    }
    
    static func pieceToFEN(_ piece: Piece) -> String {
        switch piece {
        case .rookW:
            return "R"
        case .rookB:
            return "r"
        case .knightW:
            return "N"
        case .knightB:
            return "n"
        case .bishopW:
            return "B"
        case .bishopB:
            return "b"
        case .queenW:
            return "Q"
        case .queenB:
            return "q"
        case .kingW:
            return "K"
        case .kingB:
            return "k"
        case .pawnW:
            return "P"
        case .pawnB:
            return "p"
        default:
            return ""
        }
    }
}
