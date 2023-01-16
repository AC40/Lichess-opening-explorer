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
        
        // Store incase FEN is invalid
        let backup = self
        
        // Reset board (castling right, etc.)
        self.reset()
        
        // Clear board
        self.squares = Array(repeating: Array<Square>(repeating: Square(), count: 8), count: 8)
        
        let pieceTypeForSymbol: [String: PieceType] = ["k": .king, "q": .queen, "r": .rook, "b": .bishop, "p": .pawn, "n": .knight]
        
        let parts = fen.split(separator: " ")
        
        var newPieces = [Piece]()
        
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
                    newPieces.append(Piece(color: pieceColor, type: pieceType, square: Tile(file, rank)))
                    
                    if pieceType == .king {
                        if pieceColor == .white {
                            whiteKingSquare = Tile(file, rank)
                        } else if pieceColor == .black {
                            blackKingSquare = Tile(file, rank)
                        }
                    }
                    
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
        
        // Animate changes
        pieces = animateFenChange(orginal: backup.pieces, new: newPieces)
    }
    
    /// Restore board to backup instance and display error
    mutating func abortLoadingFEN(backup: Self) {
        self = backup
        //TODO: Indicate, that error has occured (Show alert)
    }
    
    mutating func animateFenChange(orginal: [Piece], new: [Piece]) -> [Piece] {
        var newPieces = new
        var pieces = [Piece]()
        
        // for every piece in current piece array:
        for var piece in orginal where piece.type != .pawn {
            
            // get all pieces of same color and type from new array
            let samePieces = newPieces.filter({ $0 == piece })
            
            // calculate distance between each new piece and the current piece
            let distances = samePieces.map({ Utility.distanceBetweenTwoSquares(piece.square, $0.square) ?? 0 })
            
            // get new piece with lowest distance to org piece
            guard let lowestI = distances.firstIndex(of: distances.min() ?? 0) else {
                continue
            }
            
            let closestPiece = samePieces[lowestI]
            
            // set org piece.square to new piece.square
            piece.square = closestPiece.square
            
            // remove said new piece from new array
            newPieces.remove(at: newPieces.firstIndex(where: { $0 == closestPiece && $0.square == closestPiece.square })!)
            
            // add org piece to all array
            pieces.append(piece)
        }

        
        // for every pawn in current piece array:
        for var pawn in orginal where pawn.type == .pawn {
            
            // get all pawns on same file
            let sameFile = newPieces.filter({ $0 == pawn && $0.square.file == pawn.square.file })
            let rankDistance = sameFile.map({ samePawn in
                let relDistance = pawn.square.rank - samePawn.square.rank
                return abs(relDistance)
            })
            
            // get all pawns in capture distance
            let undoCaptures = newPieces.filter({ newPawn in
                let isPawn = newPawn == pawn
                let isOnAdjaconedFile = newPawn.square.file == pawn.square.file-1 || newPawn.square.file == pawn.square.file+1
                var isOnNextRank = false
                
                /// Indicates, wether a opposite-colored-piece is on the square the pawn in question was orginally at
                let didCaputure = new.contains(where: { $0.square == pawn.square && $0.color != pawn.color })
                
                if pawn.color == .white {
                    isOnNextRank = newPawn.square.rank == pawn.square.rank+1
                } else {
                    isOnNextRank = newPawn.square.rank == pawn.square.rank-1
                }
                
                return (isPawn && isOnAdjaconedFile && isOnNextRank && didCaputure)
            })
            
            // If available, get pawn in capture distance
            if let closest = undoCaptures.first {
                // set org pawn.square = new pawn.square
                pawn.square = closest.square
                
                // remove newPawn from new array
                newPieces.remove(at: newPieces.firstIndex(where: { $0 == closest && $0.square == closest.square })!)
                
                // add org pawn to all array
                pieces.append(pawn)
                
            } else {
                // get pawn with nearest rank to org pawn
                guard let lowestI = rankDistance.firstIndex(of: rankDistance.min() ?? 0) else {
                    continue
                }
                
                let closest = sameFile[lowestI]
                
                // set org pawn.square = new pawn.square
                pawn.square = closest.square
                
                // remove newPawn from new array
                newPieces.remove(at: newPieces.firstIndex(where: { $0 == closest && $0.square == closest.square })!)
                
                // add org pawn to all array
                pieces.append(pawn)
            }
            
            
        }
        
        //Add all remaining pieces to the board
        pieces += newPieces
        
        return pieces
    }
}
