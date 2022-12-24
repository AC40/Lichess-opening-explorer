//
//  Board + toFEN.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 11.12.22.
//

import Foundation

extension Board {
    func asFEN() -> String {
        
        var fen = ""
        
        // Get board structure
        var pieces = ""
        var squaresWithoutPiece = 0
        
        for rank in 0..<squares.count {
            for file in 0..<squares[rank].count {
                let piece = squares[rank, file].piece
                
                if piece == .none {
                    squaresWithoutPiece += 1
                    
                    if file == 7 {
                        pieces.append("\(squaresWithoutPiece)/")
                        squaresWithoutPiece = 0
                    }
                    continue
                } else {
                    // Append empty squares (e.g.: 5)
                    if squaresWithoutPiece > 0 {
                        pieces.append(String(squaresWithoutPiece))
                        squaresWithoutPiece = 0
                    }
                    
                    pieces.append(Convert.pieceToFEN(piece))
                    
                    if file == 7 && rank != 7 {
                        pieces.append("/")
                    }
                }
            }
        }
        
        fen.append(pieces + " ")
        
        // Get current move
        if whiteTurn {
            fen.append("w ")
        } else {
            fen.append("b ")
        }
        
        // Get castling rights
        var rights = "KQkq"
        
        if whiteKingHasMoved {
            let KIndex = rights.firstIndex(of: "K")
            if KIndex != nil {
                rights.remove(at: KIndex!)
            }
            
            let QIndex = rights.firstIndex(of: "Q")
            if QIndex != nil {
                rights.remove(at: QIndex!)
            }
        } else {
            if whiteKingsRookHasMoved {
                let KIndex = rights.firstIndex(of: "K")
                if KIndex != nil {
                    rights.remove(at: KIndex!)
                }
            }
            
            if whiteQueensRookHasMoved {
                let QIndex = rights.firstIndex(of: "Q")
                if QIndex != nil {
                    rights.remove(at: QIndex!)
                }
            }
        }
        
        if blackKingHasMoved {
            let KIndex = rights.firstIndex(of: "k")
            if KIndex != nil {
                rights.remove(at: KIndex!)
            }
            
            let QIndex = rights.firstIndex(of: "q")
            if QIndex != nil {
                rights.remove(at: QIndex!)
            }
        } else {
            if blackKingsRookHasMoved {
                let KIndex = rights.firstIndex(of: "k")
                if KIndex != nil {
                    rights.remove(at: KIndex!)
                }
            }
            
            if blackQueensRookHasMoved {
                let QIndex = rights.firstIndex(of: "q")
                if QIndex != nil {
                    rights.remove(at: QIndex!)
                }
            }
        }
        
        if rights == "" {
            rights = "-"
        }
        
        fen.append(rights + " ")
        
        // Get en passant
        var enPassantTile: Tile? = nil
        if whiteTurn && blackEnPassant != nil {
            
            if (blackEnPassant!.rank+1).isOnBoard() && (blackEnPassant!.file-1).isOnBoard() {
                // Only add as e.p. square, if at least one neighboring square is occupied by a pawn
                if squares[blackEnPassant!.rank+1][blackEnPassant!.file-1].piece == .pawnW {
                    let legalMoves = Arbiter().legalMoves(for: .pawnW, at: Tile(blackEnPassant!.rank+1, blackEnPassant!.file-1), in: self, turn: whiteTurn)
                    
                    // Check, if white pawn can legally take on square
                    if legalMoves.contains(where: { $0.end == blackEnPassant! }) {
                        
                        enPassantTile = blackEnPassant
                    }
                }
            }
            
            if (blackEnPassant!.rank+1).isOnBoard() && (blackEnPassant!.file+1).isOnBoard() {
                // Check if relevant square is occupied by pawn
                if  squares[blackEnPassant!.rank+1][blackEnPassant!.file+1].piece == .pawnW {
                    
                    let legalMoves = Arbiter().legalMoves(for: .pawnW, at: Tile(blackEnPassant!.rank+1, blackEnPassant!.file+1), in: self, turn: whiteTurn)
                    
                    // Check, if white pawn can legally take on square
                    if legalMoves.contains(where: { $0.end == blackEnPassant! }) {
                        
                        enPassantTile = blackEnPassant
                    }
                }
            }
            
        } else if whiteEnPassant != nil {
            
            if (whiteEnPassant!.rank-1).isOnBoard() && (whiteEnPassant!.file-1).isOnBoard() {
                // Only add as e.p. square, if at least one neighboring square is occupied by a pawn
                if squares[whiteEnPassant!.rank-1][whiteEnPassant!.file-1].piece == .pawnB {
                    let legalMoves = Arbiter().legalMoves(for: .pawnB, at: Tile(whiteEnPassant!.rank-1, whiteEnPassant!.file-1), in: self, turn: whiteTurn)
                    
                    // Check, if white pawn can legally take on square
                    if legalMoves.contains(where: { $0.end == whiteEnPassant! }) {
                        
                        enPassantTile = whiteEnPassant
                    }
                }
            }
            
            if (whiteEnPassant!.rank-1).isOnBoard() && (whiteEnPassant!.file+1).isOnBoard() {
                // Check if relevant square is occupied by pawn
                if  squares[whiteEnPassant!.rank-1][whiteEnPassant!.file+1].piece == .pawnB {
                    
                    let legalMoves = Arbiter().legalMoves(for: .pawnB, at: Tile(whiteEnPassant!.rank-1, whiteEnPassant!.file+1), in: self, turn: whiteTurn)
                    
                    // Check, if white pawn can legally take on square
                    if legalMoves.contains(where: { $0.end == whiteEnPassant! }) {
                        
                        enPassantTile = whiteEnPassant
                    }
                }
            }
            
        }

        if let tile = enPassantTile {
            fen.append(Convert.tileToLongAlgebra(tile) + " ")
        } else {
            fen.append("- ")
        }
        
        //TODO: Get half moves
        fen.append("0 ")
        
        //TODO: Get move number
        // starting move number + additional moves (moves.count/2)
        let totalMoveNumber = moveNumber + moves.count/2
        
        fen.append("\(totalMoveNumber) ")
        
        return fen
    }
}
