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
            makeMove(Move(from: square, to: move), in: &board)
            
            if !positionHasCheck(board, color: turn ? .black : .white) {
                canBeMovedTo.append(move)
            }
            
            // Reset board
            board = backupBoard
        }
        
        // for each capture
        for capture in pseudoCanBeTaken {
            makeMove(Move(from: square, to: capture), in: &board)
            
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
                    canBeMovedTo.append(Tile(7, 6))
                }
                if canCastleLong(color: .white, in: board, moves: canBeMovedTo) {
                    canBeMovedTo.append(Tile(7, 2))
                }
            } else {
                if canCastleShort(color: .black, in: board, moves: canBeMovedTo) {
                    canBeMovedTo.append(Tile(0, 6))
                }
                if canCastleLong(color: .black, in: board, moves: canBeMovedTo) {
                    canBeMovedTo.append(Tile(0, 2))
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
                
                var piece = board.squares[rank, file].piece
                
                if piece != .none && piece.color == color {
                    piece.square = Tile(rank, file)
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
                if board.squares[move].piece.type == .king && board.squares[move].piece.color != color {
                    
                    // if it does, return true
                    return true
                }
            }
        }
        
        return false
    }
    
    func positionHasMate(_ board: Board, color: ChessColor, check: Bool) -> Termination {
        
        var allCaptures: [Tile] = []
        var allMoves: [Tile] = []
        
        var pieces = [Piece]()
        
        for rank in 0..<board.squares.count {
            for file in 0..<board.squares[rank].count {
                
                var piece = board.squares[rank, file].piece
                
                if piece != .none && piece.color == color {
                    piece.square = Tile(rank, file)
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
    
        if (allMoves.isEmpty && allCaptures.isEmpty) {
            if check {
                return .checkmate
            } else {
                return .stalemate
            }
        }
        
        return .none
    }
    
    //MARK: Private functions
    func pseudoLegalSquares(for piece: Piece, at square: Tile, in board: Board, turn: Bool) -> ([Tile], [Tile]) {
        
        var canBeMovedTo: [Tile] = []
        var canBeTaken: [Tile] = []
        
        // Long range sliding pieces
        if piece.isSlidingPiece() {
            for legalMove in Moves.forPiece(piece) {
                
                var end = Tile(square.rank - legalMove.rank, square.file - legalMove.file)
                
                guard end.rank.isOnBoard() && end.file.isOnBoard() else {
                    continue
                }
                
                while squareIsEmpty((end), in: board.squares) {
                    canBeMovedTo.append((end))
                    
                    end.rank -= legalMove.rank
                    end.file -= legalMove.file
                }
                
                if pieceIsOppositeColor(at: (end), in: board.squares, turn: turn) {
                    canBeTaken.append((end))
                }
            }
        } else if piece.type == .pawn {
            
            if piece.color == .white {
                let endRank = square.rank - 1
                
                // Single step
                if endRank.isOnBoard() && squareIsEmpty(Tile(endRank, square.file), in: board.squares) {
                    canBeMovedTo.append(Tile(endRank, square.file))
                }
                
                // Initial double step
                if square.rank == 6 && squareIsEmpty(Tile(4, square.file), in: board.squares) {
                    canBeMovedTo.append(Tile(4, square.file))
                }
            } else if piece.color == .black {
                let endRank = square.rank + 1
                
                // Single step
                if endRank.isOnBoard() && squareIsEmpty(Tile(endRank, square.file), in: board.squares) {
                    canBeMovedTo.append(Tile(endRank, square.file))
                }
                
                // Initial double step
                if square.rank == 1 && squareIsEmpty(Tile(3, square.file), in: board.squares) {
                    canBeMovedTo.append(Tile(3, square.file))
                }
            }
            
            // Take diagonally
            for diagonalMove in Moves.pawnDiagonals(for: piece.color) {
                
                let end = Tile(square.rank - diagonalMove.rank, square.file - diagonalMove.file)
                
                guard end.rank.isOnBoard() && end.file.isOnBoard() else {
                    continue
                }
                
                if pieceIsOppositeColor(at: (end), in: board.squares, turn: turn) {
                    canBeTaken.append((end))
                    
                    // En passant
                } else if board.squares[end].canBeTakenWithEnPassant {
                    canBeTaken.append((end))
                }
                
            }
        } else {
            for legalMove in Moves.forPiece(piece) {
                
                let end = Tile(square.rank - legalMove.rank, square.file - legalMove.file)
                
                guard end.rank.isOnBoard() && end.file.isOnBoard() else {
                    continue
                }
                
                if pieceIsOppositeColor(at: (end), in: board.squares, turn: turn) {
                    canBeTaken.append((end))
                } else if squareIsEmpty((end), in: board.squares) {
                    canBeMovedTo.append((end))
                }
            }
        }
        
        return (canBeMovedTo, canBeTaken)
    }
    
//    func makeMove(_ move: Move, in board: inout Board) {
//        let startRank = move.start.rank
//        let startFile = move.start.file
//        let endRank = move.end.rank
//        let endFile = move.end.file
//
//        guard endRank.isOnBoard() && endFile.isOnBoard() else {
//            return
//        }
//
//        let piece = board[move.start].piece
//
//        guard piece.type != .none else {
//            return
//        }
//
//        guard board[endRank, endFile].canBeMovedTo else {
//            return
//        }
//
//        // Check, if pawns moves two squares (initial double step)
//        if piece.type == .pawn && abs(endRank-startRank) == 2 {
//            if piece.color == .white {
//                board[endRank+1, endFile].canBeTakenWithEnPassant = true
//                board.whiteEnPassants.append(Tile(endRank+1, endFile))
//            } else {
//                board[endRank-1, endFile].canBeTakenWithEnPassant = true
//                board.blackEnPassants.append(Tile(endRank-1, endFile))
//            }
//        }
//
//        // Promote pawn
//        if (board.whiteTurn ? (endRank == 0) : (endRank == 7)) && piece.type == .pawn {
//            board.promotionSquare = move.end
//            board.promotingPawnSquare = move.start
//            return
//        }
//
//        // King Move
//        if piece == .kingW {
//            board.whiteKingSquare = move.end
//
//            // Move rook in castling
//            if move.end == (7, 2) && !board.whiteKingHasMoved {
//                board[7, 0].piece = Piece.none
//                board[7, 3].piece = .rookW
//                board.whiteQueensRookHasMoved = true
//
//            } else if move.end == (7, 6) && !board.whiteKingHasMoved {
//                board[7, 7].piece = Piece.none
//                board[7, 5].piece = .rookW
//                board.whiteKingsRookHasMoved = true
//            }
//
//            board.whiteKingHasMoved = true
//
//        } else if piece == .kingB {
//            board.blackKingSquare = move.end
//
//            // Move rook in castling
//            if move.end == (0, 2) && !board.blackKingHasMoved {
//                board[0, 0].piece = Piece.none
//                board[0, 3].piece = .rookB
//                board.blackQueensRookHasMoved = true
//
//            } else if move.end == (0, 6) && !board.blackKingHasMoved {
//                makeMove(Move(from: Tile(0, 7), to: Tile(0, 5)), in: &board)
//                board[0, 7].piece = .none
//                board[0, 5].piece = .rookB
//                board.whiteKingsRookHasMoved = true
//            }
//
//            // Set last, so rooks can check if it has moved
//            board.blackKingHasMoved = true
//        }
//
//
//        // Rook move
//        if piece == .rookW {
//            if move.start == (7, 0) {
//                board.whiteQueensRookHasMoved = true
//            } else if move.start == (7, 7) {
//                board.whiteKingsRookHasMoved = true
//            }
//        } else if piece == .rookB {
//            if move.start == (0, 0) {
//                board.blackQueensRookHasMoved = true
//            } else if move.start == (0, 7) {
//                board.blackKingsRookHasMoved = true
//            }
//        }
//
//        // Move piece from start to end square
//        board[move.start].piece = Piece.none
//        board[move.end].piece = piece
//
//        // Take pawn when taken with en passant
//        if board[move.end].canBeTakenWithEnPassant {
//            if board.whiteTurn {
//                board[endRank+1, endFile].piece = Piece.none
//            } else {
//                board[endRank-1, endFile].piece = Piece.none
//            }
//        }
//    }
    
    private func makeMove(_ move: Move, in board: inout Board) {
        let startRank = move.start.rank
        let startFile = move.start.file
        let endRank = move.end.rank
        let endFile = move.end.file

        guard endRank.isOnBoard() && endFile.isOnBoard() else {
            return
        }

        let piece = board[startRank, startFile].piece

        guard piece.type != .none else {
            return
        }
        
        // board.canBeMovedTo
        // reset selection
        
        // Check, if pawns moves two squares
        if piece.type == .pawn && abs(endRank-startRank) == 2 {
            if piece.color == .white {
                board[endRank+1, endFile].canBeTakenWithEnPassant = true
                board.whiteEnPassants.append(Tile(endRank+1, endFile))
            } else {
                board[endRank-1, endFile].canBeTakenWithEnPassant = true
                board.blackEnPassants.append(Tile(endRank-1, endFile))
            }
        }

        // Promote pawn
        if (board.whiteTurn ? (endRank == 0) : (endRank == 7)) && piece.type == .pawn {
            board.promotionSquare = move.end
            board.promotingPawnSquare = move.start
            return
        }

        // King Move
        if piece == .kingW {
            board.whiteKingSquare = move.end
            board.whiteKingHasMoved = true
        } else if piece == .kingB {
            board.blackKingSquare = move.end
            board.blackKingHasMoved = true
        }

        if piece == .rookW {
            if move.start == (7, 0) {
                board.whiteQueensRookHasMoved = true
            } else if move.start == (7, 7) {
                board.whiteKingsRookHasMoved = true
            }
        } else if piece == .rookB {
            if move.start == (0, 0) {
                board.blackQueensRookHasMoved = true
            } else if move.start == (7, 0) {
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

        guard square.rank.isOnBoard() && square.file.isOnBoard() else {
            return false
        }

        return position[square].piece == Piece.none
    }

    private func pieceIsOppositeColor(at square: Tile, in position: [[Square]], turn: Bool) -> Bool {

        guard square.rank.isOnBoard() && square.file.isOnBoard() else {
            return false
        }

        if turn {
            return position[square].piece.color == .black
        } else {
            return position[square].piece.color == .white
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
