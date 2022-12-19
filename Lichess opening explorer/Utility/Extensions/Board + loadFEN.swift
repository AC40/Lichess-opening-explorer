//
//  Array + loadFEN.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 06.06.22.
//

import Foundation

extension Board {
    
    /// Automatically converts a FEN string into a position
    /// Also updates logic variables, such as rookHasMoved, kingSquare, etc.
    mutating func loadFEN(_ fen: String) {
        
        // Reset board (castling right, etc.)
        self.reset()
        
        // Store incase FEN is invalid
        let backup = self
        // Clear board
        self.squares = Array(repeating: Array<Square>(repeating: Square(), count: 8), count: 8)
        
        let pieceTypeForSymbol: [String: PieceType] = ["k": .king, "q": .queen, "r": .rook, "b": .bishop, "p": .pawn, "n": .knight]
        
        let parts = fen.split(separator: " ")
        
        guard parts.count == 6 else {
            self = backup
            return
        }
        
        // Place pieces
        let files = parts[0].split(separator: "/")
        
        var file = 0
        
        for fileString in files {
            let chars = [Character](fileString)
            var rank = 0
            
            for char in chars {
                if char.isNumber {
                    rank += char.wholeNumberValue!
                } else if char.isLetter{
                    guard let pieceType = pieceTypeForSymbol[char.lowercased()] else {
                        self = backup
                        return
                    }
                    let pieceColor = char.isUppercase ? ChessColor.white : ChessColor.black
                    self[file, rank].piece = Piece(color: pieceColor, type: pieceType, square: Tile(file, rank))
                    rank += 1
                }
            }
            
            file += 1
        }
        
        // Set player to move
        let player = parts[1]
        
        switch player {
        case "w":
            self.whiteTurn = true
        case "b":
            self.whiteTurn = false
        default:
            abortLoadingFEN(backup: backup)
        }
        
        // Set castling rights
        let rights = parts[2]
        
        if rights == "-" {
            whiteKingsRookHasMoved = true
            whiteQueensRookHasMoved = true
            blackKingsRookHasMoved = true
            blackQueensRookHasMoved = true
            
        } else {
            if !rights.contains("K") {
                whiteKingsRookHasMoved = true
            }
            if !rights.contains("Q") {
                whiteQueensRookHasMoved = true
            }
            
            if !rights.contains("k") {
                blackKingsRookHasMoved = true
            }
            if !rights.contains("q") {
                blackQueensRookHasMoved = true
            }
            
        }
        
        // Set En passant
        let enPassantSquare = parts[3]
        
        let enPassantTile = Convert.shortAlgebraToTile(String(enPassantSquare))
        
        if enPassantTile != nil {
            if whiteTurn {
                blackEnPassant = enPassantTile
                squares[enPassantTile!].canBeTakenWithEnPassant = true
            } else {
                whiteEnPassant = enPassantTile
                squares[enPassantTile!].canBeTakenWithEnPassant = true
            }
        }
        
        
        //TODO: Set halfmoves:
        // to be implemented
        // = parts[4]
            
        //TODO: Set move number
        moveNumber = Int(parts[5]) ?? 0
    }
    
    /// Restore board to backup instance and display error
    mutating func abortLoadingFEN(backup: Self) {
        self = backup
        //TODO: Indicate, that error has occured (Show alerr)
    }
    
    /// Updates the relevant board variables after a FEN has been loaded into the board
    mutating fileprivate func processFEN() {
        // Get kings position
        getKingPosition()
        
        // See if rooks are on initial squares
        checkRookStatus()
    }
}
