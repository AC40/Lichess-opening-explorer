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
        
        // For every piece, see if it remains on the board
        for org in orginal {
            var potentialNeighbours = [Piece]()
            var org = org
            
            for new in newPieces {
                if new == org {
                    potentialNeighbours.append(new)
                }
            }
            
            var diffs: [Int] = []
            
            for neighbour in potentialNeighbours {
                if neighbour.type == .pawn {
                    if neighbour.square.file == org.square.file {
                        org.square = neighbour.square
                        pieces.append(org)
                        break
                    }
                } else {
                    let nRank = neighbour.square.rank
                    let nFile = neighbour.square.file
                    let oRank = org.square.rank
                    let oFile = org.square.file
                    
                    var rankDiff = 0
                    var fileDiff = 0
                    
                    if nRank > oRank {
                        rankDiff = nRank - oRank
                    } else {
                        rankDiff = oRank - nRank
                    }
                    
                    if nFile > oFile {
                        fileDiff = nFile - oFile
                    } else {
                        fileDiff = oFile - nFile
                    }
                    
                    diffs.append(rankDiff + fileDiff)
                }
            }
            
            guard potentialNeighbours.count < 0 else {
                break
            }
            
            org.square = potentialNeighbours[diffs.firstIndex(where: { $0 == diffs.max() }) ?? 0].square
//            if let i = new.firstIndex(where: {
//                if $0.type == org.type && $0.color == org.color {
//                    if $0.type == .pawn {
//                        return ($0.square == org.square ||
//                                $0.square.file == org.square.file)
//                    } else {
//                        return ($0.square == org.square ||
//                                $0.square.file == org.square.file ||
//                                $0.square.rank == org.square.rank)
//                    }
//                }
//                return false
//
//            }) {
//                var piece = org
//                piece.square = new[i].square
//                pieces.append(piece)
//
//                new.remove(at: i)
//            }
        }
        
        // Add all remaining pieces to the board
        pieces += newPieces
        
        return pieces
    }
}
