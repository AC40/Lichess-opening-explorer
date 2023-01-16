//
//  ChessboardViewModel.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

class ChessboardViewModel: ObservableObject {
    
    //MARK: Variables
    @Published var selectedSquare: Tile? = nil
    @Published var board = Board()
    @Published var pauseGame = false
    @Published var whitePerspective = true
    @Published var showCoordinates = false
    
    @Published var lastInteractionWasDrag = true
    
    @Published var squareFrames = Array(repeating: Array(repeating: CGRect.zero, count: 8), count: 8)
    
    let arbiter = Arbiter()
    
    let layout = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    //MARK: Functions
    
    func handleTap(at tile: Tile) {
        
        if board.whiteTurn {
            if board[tile].piece.color == .white {
                select(tile)
            } else if selectedSquare != nil {
                makeMove(Move(from: selectedSquare!, to: tile))
            } else {
                resetSelection()
            }
        } else {
            if board[tile].piece.color == .black {
                select(tile)
            } else if selectedSquare != nil {
                makeMove(Move(from: selectedSquare!, to: tile))
            } else {
                resetSelection()
            }
        }
    }
    
    func hasCheck() -> Bool {
        return arbiter.positionHasCheck(board, color: board.whiteTurn ? .black : .white)
    }
    
    func makeMove(_ move: Move, strict: Bool = true) {
        var move = move
        
        let startRank = move.start.rank
        let endRank = move.end.rank
        let endFile = move.end.file
        
        guard endRank.isOnBoard() && endFile.isOnBoard() else {
            resetSelection()
            return
        }
        
        guard let pieceI = board.pieces.firstIndex(where: { $0.square == move.start }) else {
            resetSelection()
            return
        }
        
        guard board.pieces[pieceI].type != .none else {
            resetSelection()
            return
        }
        
        if strict {
            guard board[endRank, endFile].canBeMovedTo else {
                resetSelection()
                return
            }
        }
        
        move.position = board.asFEN()
        
        // Check, if pawns moves two squares (initial double step)
        if board.pieces[pieceI].type == .pawn && abs(endRank-startRank) == 2 {
            if board.pieces[pieceI].color == .white {
                board[endRank+1, endFile].canBeTakenWithEnPassant = true
                board.whiteEnPassant = Tile(endRank+1, endFile)
            } else {
                board[endRank-1, endFile].canBeTakenWithEnPassant = true
                board.blackEnPassant = Tile(endRank-1, endFile)
            }
        }
        
        // Promote pawn
        if (board.whiteTurn ? (endRank == 0) : (endRank == 7)) && board.pieces[pieceI].type == .pawn {
            board.promotionSquare = move.end
            board.promotingPawnSquare = move.start
            pauseGame = true
            return
        }
        
        // King Move
        if board.pieces[pieceI] == .kingW {
            board.whiteKingSquare = move.end
            
            // Move rook in castling
            if move.end == (7, 2) && !board.whiteKingHasMoved {
                board[7, 0].piece = Piece.none
                board[7, 3].piece = .rookW
                
                if let rookI = board.pieces.firstIndex(where: { $0.square == (7, 0) }) {
                    board.pieces[rookI].square = Tile(7, 3)
                }
                
                board.whiteQueensRookHasMoved = true
                move.flag = .longCastle
                
            } else if move.end == (7, 6) && !board.whiteKingHasMoved {
                board[7, 7].piece = Piece.none
                board[7, 5].piece = .rookW
                
                if let rookI = board.pieces.firstIndex(where: { $0.square == (7, 7) }) {
                    board.pieces[rookI].square = Tile(7, 5)
                }
                
                board.whiteKingsRookHasMoved = true
                move.flag = .shortCastle
            }
            
            // Set last, so rooks can check if it has moved
            board.whiteKingHasMoved = true
            
        } else if board.pieces[pieceI] == .kingB {
            board.blackKingSquare = move.end
            
            // Move rook in castling
            if move.end == (0, 2) && !board.blackKingHasMoved {
                board[0, 0].piece = Piece.none
                board[0, 3].piece = .rookB
                
                if let rookI = board.pieces.firstIndex(where: { $0.square == (0, 0) }) {
                    board.pieces[rookI].square = Tile(0, 3)
                }
                
                board.blackQueensRookHasMoved = true
                move.flag = .longCastle
                
            } else if move.end == (0, 6) && !board.blackKingHasMoved {
                board[0, 7].piece = .none
                board[0, 5].piece = .rookB
                
                if let rookI = board.pieces.firstIndex(where: { $0.square == (0, 7) }) {
                    board.pieces[rookI].square = Tile(0, 5)
                }
                
                board.blackKingsRookHasMoved = true
                move.flag = .shortCastle
            }
            
            // Set last, so rooks can check if it has moved
            board.blackKingHasMoved = true
        }
        
        
        // Rook move
        if board.pieces[pieceI] == .rookW {
            if move.start == (7, 0) {
                board.whiteQueensRookHasMoved = true
            } else if move.start == (7, 7) {
                board.whiteKingsRookHasMoved = true
            }
        } else if board.pieces[pieceI] == .rookB {
            if move.start == (0, 0) {
                board.blackQueensRookHasMoved = true
            } else if move.start == (0, 7) {
                board.blackKingsRookHasMoved = true
            }
        }
        
        // Add capture to move before is removed
        if board[move.end].piece != .none {
            move.capture = board[move.end].piece
            if move.flag == .move {
                move.flag = .capture
            }
        }
        
        // Remove captured piece
        if let captureI = board.pieces.firstIndex(where: { $0.square == move.end }) {
            board.pieces.remove(at: captureI)
        }
        
        // Take pawn when taken with en passant
        if board[move.end].canBeTakenWithEnPassant {
            if board.whiteTurn {
                board[endRank+1, endFile].piece = Piece.none
                if let epI = board.pieces.firstIndex(where: { $0.square == (endRank+1, endFile)}) {
                    board.pieces.remove(at: epI)
                }
            } else {
                board[endRank-1, endFile].piece = Piece.none
                if let epI = board.pieces.firstIndex(where: { $0.square == (endRank-1, endFile)}) {
                    board.pieces.remove(at: epI)
                }
            }
        }
        
        
        // Add meta info to piece
        if let newPieceI = board.pieces.firstIndex(where: { $0.square == move.start }) {
            board.pieces[newPieceI].square = move.end
            
            // Move piece from start to end square
            board[move.start].piece = Piece.none
            board[move.end].piece = board.pieces[newPieceI]
            
            move.piece = board.pieces[newPieceI]
        } else {
            print("Huston we got a problem")
        }
        
        endTurn(with: move)
        
    }
    
    func unmakeMove(_ move: Move) {
        //MARK: Pseudo code
        
        // move piece from end square to start square
        let piece = board[move.end].piece
        board[move.end].piece = .none
        board[move.start].piece = piece
        
        if let i = board.pieces.firstIndex(where: { $0 == piece && $0.square == move.end }) {
            board.pieces[i].square = move.start
        }
        
        // check move.flag
        switch move.flag {
        case .capture:
            // Add captured piece back to end
            if var capture = move.capture {
                capture.square = move.end
                board[move.end].piece = capture
                board.pieces.append(capture)
            }
        case .longCastle:
            // move rook back
            if piece.color == .white, let i = board.pieces.firstIndex(where: { $0 == .rookW && $0.square == (7, 3) }) {
                board.pieces[i].square = Tile(7, 0)
                board[7, 3].piece = .none
                board[7, 0].piece = board.pieces[i]
            } else if let i = board.pieces.firstIndex(where: { $0 == .rookB && $0.square == (0, 3) }) {
                board.pieces[i].square = Tile(0, 0)
                board[0, 3].piece = .none
                board[0, 0].piece = board.pieces[i]
            }
        case .shortCastle:
            // move rook back
            if piece.color == .white, let i = board.pieces.firstIndex(where: { $0 == .rookW && $0.square == (7, 5) }) {
                board.pieces[i].square = Tile(7, 7)
                board[7, 5].piece = .none
                board[7, 7].piece = board.pieces[i]
            } else if let i = board.pieces.firstIndex(where: { $0 == .rookB && $0.square == (0, 5) }) {
                board.pieces[i].square = Tile(0, 7)
                board[0, 5].piece = .none
                board[0, 7].piece = board.pieces[i]
            }
        case .promotion(piece: _):
            // set piece.type to pawn
            board[move.start].piece.type = .pawn
            if let i = board.pieces.firstIndex(where: { $0 == piece && $0.square == move.start }) {
                board.pieces[i].type = .pawn
            }
        default:
            break
        }
        
        // Restore king- and rookHasMoved flags (from FEN)
        let rights = Utility.castlingRightFromFen(move.position)
        
        if rights.contains("K") {
            board.whiteKingsRookHasMoved = false
            board.whiteKingHasMoved = false
        }
        if rights.contains("Q") {
            board.whiteQueensRookHasMoved = false
            board.whiteKingHasMoved = false
        }
        
        if rights.contains("k") {
            board.blackKingsRookHasMoved = false
            board.blackKingHasMoved = false
        }
        if rights.contains("q") {
            board.blackQueensRookHasMoved = false
            board.blackKingHasMoved = false
        }
        
        //TODO: Restore en-passant (from FEN)
        let enPassantSquare = Utility.enPassantSquareFromFen(move.position)
        let enPassantTile = Convert.shortAlgebraToTile(enPassantSquare)
        
        if enPassantTile != nil {
            if piece.color == .white {
                board.blackEnPassant = enPassantTile
                board[enPassantTile!].canBeTakenWithEnPassant = true
            } else {
                board.whiteEnPassant = enPassantTile
                board[enPassantTile!].canBeTakenWithEnPassant = true
            }
        }
        
        // Note: Make every change in board.squares and in board.pieces
        endTurn(with: move, undo: true)
    }
    
    func loadMove(_ move: Move) {
        board.loadFEN(move.position)
        resetSelection()
    }
    
    func endTurn(with move: Move, undo: Bool = false) {
        var move = move
        resetSelection()
        
        // Switch turn
        board.whiteTurn.toggle()
        
        // Remove previous en passants
        if board.whiteTurn {
            if let tile = board.whiteEnPassant {
                board[tile].canBeTakenWithEnPassant = false
            }
           board.whiteEnPassant = nil
        } else {
            if let tile = board.blackEnPassant {
                board[tile].canBeTakenWithEnPassant = false
            }
            board.blackEnPassant = nil
        }
        
        // Check for check
        board.check = arbiter.positionHasCheck(board, color: board.whiteTurn ? .black : .white)
        
        // Check for checkmate or stalemate
        board.termination = arbiter.positionHasMate(board, color: board.whiteTurn ? .white : .black, check: board.check)
     
        // Set move variables
        move.check = board.check
        move.termination = board.termination
//        move.position = board.asFEN()
        
        // If turn unmakes a move
        guard !undo else {
            board.currentMove -= 1
            
            return
        }
        
        // Add move to history
        if (board.moves.isEmpty) {
            board.moves = [move]
            board.currentMove += 1
        } else {
            if board.currentMove < board.moves.count {
                
                if move == board.moves[board.currentMove] {
                    board.currentMove += 1
                    return
                }
                
                board.moves.removeSubrange(board.currentMove..<board.moves.count)
            }
            board.moves.insert(move, at: board.currentMove)
            board.currentMove += 1
        }
    }
    
    func select(_ square: Tile) {
        // Check if square was already selected
        if selectedSquare != nil {
            if selectedSquare! == square {
                return
            }
        }
        
        // Check player is allowed to select
        if board.whiteTurn {
            guard board[square].piece.color == .white else {
                resetSelection()
                return
            }
        } else {
            guard board[square].piece.color == .black else {
                resetSelection()
                return
            }
        }
        
        // Reset all board legality status
        board.squares.makeAllIllegal()
        
        // Select square
        selectedSquare = square
        
        // Display legal moves
        let moves = arbiter.legalMoves(for: board[square].piece, at: square, in: board, turn: board.whiteTurn)
        
        displayLegalMoves(moves: moves)
        
    }
    
    
    func promotePawn(to pieceType: PieceType) {
        guard let promotionSquare = board.promotionSquare else {
            return
        }
        
        guard let startSquare = board.promotingPawnSquare else {
            return
        }
        
        board[startSquare].piece = .none
        board[promotionSquare].piece = Piece(color: board.whiteTurn ? .white : .black, type: pieceType)
        
        if let i = board.pieces.firstIndex(where: { $0.square == startSquare }) {
            board.pieces[i].square = promotionSquare
            board.pieces[i].type = pieceType
        }
        
        self.board.promotionSquare = nil
        pauseGame = false
        
        let move = Move(from: startSquare, to: promotionSquare, piece: board[promotionSquare].piece, flag: .promotion(piece: pieceType))
        endTurn(with: move)
    }
    
    
    
    func displayLegalMoves(moves: [Move]) {
        
        for move in moves  {
            switch move.flag {
            case .enPassant:
                board[move.end].canBeTakenWithEnPassant = true
            case .capture:
                board[move.end].canBeTaken = true
            default:
                board[move.end].canBeMovedTo = true
            }
        }
    }
    
    func resetSelection() {
        // unselect square
        selectedSquare = nil
        
        // Reset all board legality status
        board.squares.makeAllIllegal()
    }
    
    func onDrop(location: CGPoint, square: Tile) {
        for i in 0..<squareFrames.count {
            if let i2 = squareFrames[i].firstIndex(where: { $0.contains(location)}) {
                makeMove(Move(from: square, to: Tile(i, i2)))
                break
            }
        }
    }
    
    func cancelPromotion() {
        pauseGame = false
        board.promotionSquare = nil
        resetSelection()
    }
    
    
}
