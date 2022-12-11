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
                    
                    if file == 7 {
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
        if whiteTurn {
             enPassantTile = blackEnPassant
        } else {
            enPassantTile = whiteEnPassant
        }
        
        if let tile = enPassantTile {
            fen.append(Convert.tileToLongAlgebra(tile) + " ")
        } else {
            fen.append("- ")
        }
        
        //TODO: Get half moves
        fen.append("0 ")
        
        //TODO: Get move number
        fen.append("0")
        
        return fen
    }
}
