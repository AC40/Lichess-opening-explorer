//
//  Arbiter.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 01.12.22.
//

import Foundation

struct Arbiter {
    
    //MARK: Public functions
    func legalMoves(for piece: Piece, at square: Tile, in backupBoard: Board, turn: Bool) -> [Move] {
        
        // copy position
        var board = backupBoard
        
        let pseudoLegalMoves = pseudoLegalMoves(for: piece, at: square, in: board, turn: turn)
        var moves: [Move] = []
        
        // for each move
        for move in pseudoLegalMoves {
            makeMove(move, in: &board)
            
            if !positionHasCheck(board, color: turn ? .black : .white) {
                moves.append(move)
            }
            
            // Reset board
            board = backupBoard
        }
        
        if piece.isKing() {
            if turn {
                if canCastleShort(color: .white, in: board, moves: moves) {
                    let move = Move(from: square, to: Tile(7, 6), flag: .shortCastle)
                    makeMove(move, in: &board)
                    if !positionHasCheck(board, color: turn ? .black : .white) {
                        moves.append(move)
                    }
                    board = backupBoard
                }
                if canCastleLong(color: .white, in: board, moves: moves) {
                    let move = Move(from: square, to: Tile(7, 2), flag: .shortCastle)
                    makeMove(move, in: &board)
                    if !positionHasCheck(board, color: turn ? .black : .white) {
                        moves.append(move)
                    }
                    board = backupBoard
                }
            } else {
                if canCastleShort(color: .black, in: board, moves: moves) {
                    let move = Move(from: square, to: Tile(0, 6), flag: .shortCastle)
                    makeMove(move, in: &board)
                    if !positionHasCheck(board, color: turn ? .black : .white) {
                        moves.append(move)
                    }
                    board = backupBoard
                }
                if canCastleLong(color: .black, in: board, moves: moves) {
                    let move = Move(from: square, to: Tile(0, 2), flag: .shortCastle)
                    makeMove(move, in: &board)
                    if !positionHasCheck(board, color: turn ? .black : .white) {
                        moves.append(move)
                    }
                    board = backupBoard

                }
            }
        }
        
        return moves
        
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
            let pseudoLegalMoves = pseudoLegalMoves(for: piece, at: piece.square!, in: board, turn: color == .white ? true : false)
            
            // for each move that does not capture
            for move in pseudoLegalMoves where move.flag == .capture || move.flag == .enPassant {
                
                // Check, if the moves takes the color's king
                if board.squares[move.end].piece.type == .king && board.squares[move.end].piece.color != color {
                    
                    // if it does, return true
                    return true
                }
            }
        }
        
        return false
    }
    
    func positionHasMate(_ board: Board, color: ChessColor, check: Bool) -> Termination {
        
        var allMoves: [Move] = []
        
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
            
            let moves = legalMoves(for: piece, at: piece.square!, in: board, turn: color == .white)
            
            allMoves += moves
        }
    
        if allMoves.isEmpty {
            if check {
                return .checkmate
            } else {
                return .stalemate
            }
        }
        
        return .none
    }
    
    //MARK: Private functions
    func pseudoLegalMoves(for piece: Piece, at square: Tile, in board: Board, turn: Bool) -> [Move] {
        
        var moves: [Move] = []
        
        // Long range sliding pieces
        if piece.isSlidingPiece() {
            for legalMove in Moves.forPiece(piece) {
                
                var end = Tile(square.rank - legalMove.rank, square.file - legalMove.file)
                
                guard end.rank.isOnBoard() && end.file.isOnBoard() else {
                    continue
                }
                
                while squareIsEmpty((end), in: board.squares) {
                    moves.append((Move(from: square, to: end)))
                    
                    end.rank -= legalMove.rank
                    end.file -= legalMove.file
                }
                
                if pieceIsOppositeColor(at: (end), in: board.squares, turn: turn) {
                    moves.append(Move(from: square, to: end, flag: .capture))
                }
            }
        } else if piece.type == .pawn {
            
            if piece.color == .white {
                let endRank = square.rank - 1
                
                // Single step
                if endRank.isOnBoard() && squareIsEmpty(Tile(endRank, square.file), in: board.squares) {
                    moves.append(Move(from: square, to: Tile(endRank, square.file)))
                    
                    // Initial double step
                    // Nested, bc is only possible if single step is also possible
                     if square.rank == 6 && squareIsEmpty(Tile(4, square.file), in: board.squares) {
                         moves.append(Move(from: square, to: Tile(4, square.file), flag: .doubleStep))
                     }
                }
                
            } else if piece.color == .black {
                let endRank = square.rank + 1
                
                // Single step
                if endRank.isOnBoard() && squareIsEmpty(Tile(endRank, square.file), in: board.squares) {
                    moves.append(Move(from: square, to: Tile(endRank, square.file)))
                    
                    
                    // Initial double step
                    // Nested, bc is only possible if single step is also possible
                    if square.rank == 1 && squareIsEmpty(Tile(3, square.file), in: board.squares) {
                        moves.append(Move(from: square, to: Tile(3, square.file), flag: .doubleStep))
                    }
                }
            }
            
            // Take diagonally
            for diagonalMove in Moves.pawnDiagonals(for: piece.color) {
                
                let end = Tile(square.rank - diagonalMove.rank, square.file - diagonalMove.file)
                
                guard end.rank.isOnBoard() && end.file.isOnBoard() else {
                    continue
                }
                
                if pieceIsOppositeColor(at: (end), in: board.squares, turn: turn) {
                    moves.append(Move(from: square, to: end, flag: .capture))
                    
                // En passant
                } else {
                    if turn && board.blackEnPassant == end {
                        moves.append(Move(from: square, to: end, capture: board.squares[end].piece, flag: .enPassant))
                    } else if board.whiteEnPassant == end {
                        moves.append(Move(from: square, to: end, capture: board.squares[end].piece, flag: .enPassant))
                    }
                    
                }
                
            }
        } else {
            for legalMove in Moves.forPiece(piece) {
                
                let end = Tile(square.rank - legalMove.rank, square.file - legalMove.file)
                
                guard end.rank.isOnBoard() && end.file.isOnBoard() else {
                    continue
                }
                
                if pieceIsOppositeColor(at: (end), in: board.squares, turn: turn) {
                    moves.append(Move(from: square, to: end, flag: .capture))
                } else if squareIsEmpty((end), in: board.squares) {
                    moves.append(Move(from: square, to: end))
                }
            }
        }
        
        return moves
    }
    
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
                board.whiteEnPassant = Tile(endRank+1, endFile)
            } else {
                board[endRank-1, endFile].canBeTakenWithEnPassant = true
                board.blackEnPassant = Tile(endRank-1, endFile)
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

    private func canCastleLong(color: ChessColor, in board: Board, moves: [Move]) -> Bool {

        if color == .white {
            let haveNotMoved = (!board.whiteKingHasMoved && !board.whiteQueensRookHasMoved)
            let spaceIsEmpty = (board[7, 1].isEmpty() && board[7, 2].isEmpty() && board[7,3].isEmpty())
            let noChecksInBetween = moves.contains(where: { $0.end == (7, 3) })
            let noChecksBefore = !board.check

            return (haveNotMoved && spaceIsEmpty && noChecksInBetween && noChecksBefore)

        } else if color == .black {
            let haveNotMoved = (!board.blackKingHasMoved && !board.blackQueensRookHasMoved)
            let spaceIsEmpty = (board[0, 1].isEmpty() && board[0, 2].isEmpty() && board[0,3].isEmpty())
            let noChecksInBetween = moves.contains(where: { $0.end == (0, 3) })
            let noChecksBefore = !board.check
            

            return (haveNotMoved && spaceIsEmpty && noChecksInBetween && noChecksBefore)

        } else {
            return false
        }
    }

    private func canCastleShort(color: ChessColor, in board: Board, moves: [Move]) -> Bool {

        if color == .white {
            let haveNotMoved = (!board.whiteKingHasMoved && !board.whiteKingsRookHasMoved)
            let spaceIsEmpty = (board[7, 5].isEmpty() && board[7, 6].isEmpty())
            let noChecksInBetween = moves.contains(where: { $0.end == (7, 5) })
            let noChecksBefore = !board.check

            return (haveNotMoved && spaceIsEmpty && noChecksInBetween && noChecksBefore )

        } else if color == .black {
            let haveNotMoved = (!board.blackKingHasMoved && !board.blackKingsRookHasMoved)
            let spaceIsEmpty = (board[0, 5].isEmpty() && board[0, 6].isEmpty())
            let noChecksInBetween = moves.contains(where: { $0.end == (0, 5) })
            let noChecksBefore = !board.check

            return (haveNotMoved && spaceIsEmpty && noChecksInBetween && noChecksBefore)

        } else {
            return false
        }
        
        
    }
}
