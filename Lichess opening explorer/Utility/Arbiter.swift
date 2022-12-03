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
        
        let (pseudoCanBeMovedTo, pseudoCanBeTaken) = pseudoLegalSquares(for: piece, at: square, in: board, turn: turn)
        var canBeMovedTo = [Tile]()
        var canBeTaken = [Tile]()
        
        // for each move
        for move in pseudoCanBeMovedTo {
            mockMovePiece(from: square, to: move, in: &board)
            
            if !positionHasCheck(board, color: turn ? .black : .white) {
                canBeMovedTo.append(move)
            }
            
            // Reset board
            board = backupBoard
        }
        
        // for each capture
        for capture in pseudoCanBeTaken {
            mockMovePiece(from: square, to: capture, in: &board)
            
            if !positionHasCheck(board, color: turn ? .black : .white) {
                canBeTaken.append(capture)
            }
            
            // Reset board
            board = backupBoard
        }
        
        // Remove castling rights if necessary
        if piece.isKing() {
            if turn {
                if canCastleShort(color: .white, in: board, moves: canBeMovedTo) {
                    canBeMovedTo.append((7, 6))
                }
                if canCastleLong(color: .white, in: board, moves: canBeMovedTo) {
                    canBeMovedTo.append((7, 2))
                }
            } else {
                if canCastleShort(color: .black, in: board, moves: canBeMovedTo) {
                    canBeMovedTo.append((0, 6))
                }
                if canCastleLong(color: .black, in: board, moves: canBeMovedTo) {
                    canBeMovedTo.append((0, 2))
                }
            }
        }
        
        return (canBeMovedTo, canBeTaken)
        
    }
    
    // Working implementation (woop woo)
    func positionHasCheck(_ board: Board, color: ChessColor) -> Bool {
        
        // In explation, it is assumed white just made a move, thus color = .white
        // Generate pieces from side
        var pieces = [Piece]()
        
        for rank in 0..<board.squares.count {
            for file in 0..<board.squares[rank].count {
                
                var piece = board.squares[rank][file].piece
                
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
            let (_, pseudoCanBeTaken) = pseudoLegalSquares(for: piece, at: piece.square!, in: board, turn: color == .white ? true : false)
            
            // for each move
            for move in pseudoCanBeTaken {
                
                // Check, if the moves takes the color's king
                if board.squares[move.0][move.1].piece.type == .king && board.squares[move.0][move.1].piece.color != color {
                    
                    // if it does, return true
                    return true
                }
            }
        }
        
        return false
    }
    
    func positionHasCheckmate(_ board: Board, color: ChessColor) -> Bool {
        
        var allCaptures: [Tile] = []
        var allMoves: [Tile] = []
        
        var pieces = [Piece]()
        
        for rank in 0..<board.squares.count {
            for file in 0..<board.squares[rank].count {
                
                var piece = board.squares[rank][file].piece
                
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
            
            let (canBeMovedTo, canBeTaken) = legalSquares(for: piece, at: piece.square!, in: board, turn: color == .white)
            
            allMoves += canBeMovedTo
            allCaptures += canBeTaken
        }
    
        return (allMoves.isEmpty && allCaptures.isEmpty)
    }
    
    //MARK: Private functions
    func pseudoLegalSquares(for piece: Piece, at square: Tile, in board: Board, turn: Bool) -> ([Tile], [Tile]) {
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
                
                while squareIsEmpty((endRank, endFile), in: board.squares) {
                    canBeMovedTo.append((endRank, endFile))
                    
                    endRank -= rankMove
                    endFile -= fileMove
                }
                
                if pieceIsOppositeColor(at: (endRank, endFile), in: board.squares, turn: turn) {
                    canBeTaken.append((endRank, endFile))
                }
            }
        } else if piece.type == .pawn {
            
            if piece.color == .white {
                let endRank = rank - 1
                
                // Single step
                if endRank.isOnBoard() && squareIsEmpty((endRank, file), in: board.squares) {
                    canBeMovedTo.append((endRank, file))
                }
                
                // Initial double step
                if rank == 6 && squareIsEmpty((4, file), in: board.squares) {
                    canBeMovedTo.append((4, file))
                }
            } else if piece.color == .black {
                let endRank = rank + 1
                
                // Single step
                if endRank.isOnBoard() && squareIsEmpty((endRank, file), in: board.squares) {
                    canBeMovedTo.append((endRank, file))
                }
                
                // Initial double step
                if rank == 1 && squareIsEmpty((3, file), in: board.squares) {
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
                
                if pieceIsOppositeColor(at: (endRank, endFile), in: board.squares, turn: turn) {
                    canBeTaken.append((endRank, endFile))
                    
                    // En passant
                } else if board.squares[endRank][endFile].canBeTakenWithEnPassant {
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
                
                if pieceIsOppositeColor(at: (endRank, endFile), in: board.squares, turn: turn) {
                    canBeTaken.append((endRank, endFile))
                } else if squareIsEmpty((endRank, endFile), in: board.squares) {
                    canBeMovedTo.append((endRank, endFile))
                }
            }
        }
        
        return (canBeMovedTo, canBeTaken)
    }
    
    
    
    private func mockMovePiece(from start: Tile, to end: Tile, in board: inout Board) {
        let (startRank, startFile) = start
        let (endRank, endFile) = end
        
        guard endRank.isOnBoard() && endFile.isOnBoard() else {
            return
        }
        
        let piece = board[startRank, startFile].piece
        
        guard piece.type != .none else {
            return
        }
        
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
            return
            //TODO: Pause game while player selects piece
        }
        
        // King Move
        if piece == .kingW {
            board.whiteKingSquare = end
            board.whiteKingHasMoved = true
        } else if piece == .kingB {
            board.blackKingSquare = end
            board.blackKingHasMoved = true
        }
        
        if piece == .rookW {
            if start == (7, 0) {
                board.whiteQueensRookHasMoved = true
            } else if start == (7, 7) {
                board.whiteKingsRookHasMoved = true
            }
        } else if piece == .rookB {
            if start == (0, 0) {
                board.blackQueensRookHasMoved = true
            } else if start == (7, 0) {
                board.blackKingsRookHasMoved = true
            }
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
    
    private func canCastleLong(color: ChessColor, in board: Board, moves: [Tile]) -> Bool {
        
        if color == .white {
            let haveNotMoved = (!board.whiteKingHasMoved && !board.whiteQueensRookHasMoved)
            let spaceIsEmpty = (board[7, 1].isEmpty() && board[7, 2].isEmpty() && board[7,3].isEmpty())
            let noChecks = moves.contains(where: { $0 == (7, 3) })
            
            return (haveNotMoved && spaceIsEmpty && noChecks)
            
        } else if color == .black {
            let haveNotMoved = (!board.blackKingHasMoved && !board.blackQueensRookHasMoved)
            let spaceIsEmpty = (board[0, 1].isEmpty() && board[0, 2].isEmpty() && board[0,3].isEmpty())
            let noChecks = moves.contains(where: { $0 == (0, 3) })
            
            return (haveNotMoved && spaceIsEmpty && noChecks)
            
        } else {
            return false
        }
    }
    
    private func canCastleShort(color: ChessColor, in board: Board, moves: [Tile]) -> Bool {
        
        if color == .white {
            let haveNotMoved = (!board.whiteKingHasMoved && !board.whiteKingsRookHasMoved)
            let spaceIsEmpty = (board[7, 5].isEmpty() && board[7, 6].isEmpty())
            let noChecks = moves.contains(where: { $0 == (7, 5) })
            
            return (haveNotMoved && spaceIsEmpty && noChecks)
            
        } else if color == .black {
            let haveNotMoved = (!board.blackKingHasMoved && !board.blackKingsRookHasMoved)
            let spaceIsEmpty = (board[0, 5].isEmpty() && board[0, 6].isEmpty())
            let noChecks = moves.contains(where: { $0 == (0, 5) })
            
            return (haveNotMoved && spaceIsEmpty && noChecks)
            
        } else {
            return false
        }
    }
}
