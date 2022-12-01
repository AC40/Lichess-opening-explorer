//
//  Arbiter.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 01.12.22.
//

import Foundation

struct Arbiter {
    
    //MARK: Public functions
    func legalSquares(for piece: Piece, at square: Tile, in backupBoard: Board, turn: Bool) -> ([Tile], [Tile]) {
        
        // copy position
        var board = backupBoard
        
        let (pseudoCanBeMovedTo, pseudoCanBeTaken) = pseudoLegalSquares(for: piece, at: square, in: board.squares, turn: turn)
        var canBeMovedTo = [Tile]()
        var canBeTaken = [Tile]()
        
        // for each move
        for move in pseudoCanBeMovedTo {
            movePiece(from: square, to: move, in: &board)
            
            if !positionHasCheck(board.squares, color: turn ? .black : .white) {
                canBeMovedTo.append(move)
            }
            
            // Reset board
            board = backupBoard
        }
        
        // for each capture
        for capture in pseudoCanBeTaken {
            movePiece(from: square, to: capture, in: &board)
            
            if !positionHasCheck(board.squares, color: turn ? .black : .white) {
                canBeTaken.append(capture)
            }
            
            // Reset board
            board = backupBoard
        }
        
        return (canBeMovedTo, canBeTaken)
        
    }
    
    // Working implementation (woop woo)
    func positionHasCheck(_ position: [[Square]], color: ChessColor) -> Bool {
        
        // In explation, it is assumed white just made a move, thus color = .white
        // Generate pieces from side
        var pieces = [Piece]()
        
        for rank in 0..<position.count {
            for file in 0..<position[rank].count {
                
                var piece = position[rank][file].piece
                
                if piece != .none && piece.color == color {
                    piece.square = (rank, file)
                    pieces.append(piece)
                }
            }
        }
        
        // For each piece:
        for piece in pieces {
            
            guard piece.square != nil else {
                continue
            }
            
            // generate all moves
            let (_, pseudoCanBeTaken) = pseudoLegalSquares(for: piece, at: piece.square!, in: position, turn: color == .white ? true : false)
            
            // for each move
            for move in pseudoCanBeTaken {
                
                // Check, if the moves takes the color's king
                if position[move.0][move.1].piece.type == .king && position[move.0][move.1].piece.color != color {
                    
                    // if it does, return true
                    return true
                }
            }
        }
        
        return false
    }
    
    //MARK: Private functions
    func pseudoLegalSquares(for piece: Piece, at square: Tile, in position: [[Square]], turn: Bool) -> ([Tile], [Tile]) {
        let (rank, file) = square
        
        var canBeMovedTo: [Tile] = []
        var canBeTaken: [Tile] = []
        
        // Long range sliding pieces
        if piece.isSlidingPiece() {
            for legalMove in Moves.forPiece(piece) {
                let (rankMove, fileMove) = legalMove
                
                var endRank = rank - rankMove
                var endFile = file - fileMove
                
                guard endRank.isOnBoard() && endFile.isOnBoard() else {
                    continue
                }
                
                while squareIsEmpty((endRank, endFile), in: position) {
                    canBeMovedTo.append((endRank, endFile))
                    
                    endRank -= rankMove
                    endFile -= fileMove
                }
                
                if pieceIsOppositeColor(at: (endRank, endFile), in: position, turn: turn) {
                    canBeTaken.append((endRank, endFile))
                }
            }
        } else if piece.type == .pawn {
            
            if piece.color == .white {
                let endRank = rank - 1
                
                // Single step
                if endRank.isOnBoard() && squareIsEmpty((endRank, file), in: position) {
                    canBeMovedTo.append((endRank, file))
                }
                
                // Initial double step
                if rank == 6 && squareIsEmpty((4, file), in: position) {
                    canBeMovedTo.append((4, file))
                }
            } else if piece.color == .black {
                let endRank = rank + 1
                
                // Single step
                if endRank.isOnBoard() && squareIsEmpty((endRank, file), in: position) {
                    canBeMovedTo.append((endRank, file))
                }
                
                // Initial double step
                if rank == 1 && squareIsEmpty((3, file), in: position) {
                    canBeMovedTo.append((3, file))
                }
            }
            
            // Take diagonally
            for diagonalMove in Moves.pawnDiagonals(for: piece.color) {
                let (rankMove, fileMove) = diagonalMove
                
                let endRank = rank - rankMove
                let endFile = file - fileMove
                
                guard endRank.isOnBoard() && endFile.isOnBoard() else {
                    continue
                }
                
                if pieceIsOppositeColor(at: (endRank, endFile), in: position, turn: turn) {
                    canBeTaken.append((endRank, endFile))
                    
                    // En passant
                } else if position[endRank][endFile].canBeTakenWithEnPassant {
                    canBeTaken.append((endRank, endFile))
                }
                
            }
        } else {
            for legalMove in Moves.forPiece(piece) {
                let (rankMove, fileMove) = legalMove
                
                let endRank = rank - rankMove
                let endFile = file - fileMove
                
                guard endRank.isOnBoard() && endFile.isOnBoard() else {
                    continue
                }
                
                if pieceIsOppositeColor(at: (endRank, endFile), in: position, turn: turn) {
                    canBeTaken.append((endRank, endFile))
                } else if squareIsEmpty((endRank, endFile), in: position) {
                    canBeMovedTo.append((endRank, endFile))
                }
            }
            
            //TODO: Castling
        }
        
        return (canBeMovedTo, canBeTaken)
    }
    
    
    
    private func movePiece(from start: Tile, to end: Tile, in board: inout Board) -> Bool {
        let (startRank, startFile) = start
        let (endRank, endFile) = end
        
        guard endRank.isOnBoard() && endFile.isOnBoard() else {
            return false
        }
        
        let piece = board[startRank, startFile].piece
        
        guard piece.type != .none else {
            return false
        }
        
//        guard board[endRank, endFile].canBeMovedTo else {
//            return false
//        }
        
        // Check, if pawns moves two squares
        if piece.type == .pawn && abs(endRank-startRank) == 2 {
            if piece.color == .white {
                board[endRank+1, endFile].canBeTakenWithEnPassant = true
                board.whiteEnPassants.append((endRank+1, endFile))
            } else {
                board[endRank-1, endFile].canBeTakenWithEnPassant = true
                board.blackEnPassants.append((endRank-1, endFile))
            }
        }
        
        // Promote pawn
        if (board.whiteTurn ? (endRank == 0) : (endRank == 7)) && piece.type == .pawn {
            board.promotionSquare = end
            board.promotingPawnSquare = start
            return true
            //TODO: Pause game while player selects piece
        }
        
        // King Move
        if piece == .kingW {
            board.whiteKingSquare = end
        } else if piece == .kingB {
            board.blackKingSquare = end
        }
        
        // Move piece from start to end square
        board[startRank, startFile].piece = Piece.none
        board[endRank, endFile].piece = piece
        
        // Take pawn when taken with en passant
        if board[endRank, endFile].canBeTakenWithEnPassant {
            if board.whiteTurn {
                board[endRank+1, endFile].piece = Piece.none
            } else {
                board[endRank-1, endFile].piece = Piece.none
            }
        }
        
        return true
    }
    
    
    private func squareIsEmpty(_ square: Tile, in position: [[Square]]) -> Bool {
        let (rank, file) = square
        
        guard rank.isOnBoard() && file.isOnBoard() else {
            return false
        }
        
        return position[rank][file].piece == Piece.none
    }
    
    private func pieceIsOppositeColor(at square: Tile, in position: [[Square]], turn: Bool) -> Bool {
        let (rank, file) = square
        
        guard rank.isOnBoard() && file.isOnBoard() else {
            return false
        }
        
        if turn {
            return position[rank][file].piece.color == .black
        } else {
            return position[rank][file].piece.color == .white
        }
    }
}
