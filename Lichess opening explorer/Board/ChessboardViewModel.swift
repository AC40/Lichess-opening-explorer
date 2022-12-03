//
//  ChessboardViewModel.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

class ChessboardViewModel: ObservableObject {
    
    //MARK: Variables
    @Published var selectedSquare: (Int, Int)? = nil
    @Published var board = Board()
    @Published var pauseGame = false
    @Published var whitePerspective = true
    @Published var showCoordinates = true
    
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
    
    func handleTap(at tile: (Int, Int)) {
        let (rank, file) = tile
        
        if board.whiteTurn {
            if board[tile].piece.color == .white {
                select(tile)
            } else if selectedSquare != nil {
                movePiece(from: selectedSquare!, to: tile)
            } else {
                resetSelection()
            }
        } else {
            if board[rank, file].piece.color == .black {
                select(tile)
            } else if selectedSquare != nil {
                movePiece(from: selectedSquare!, to: tile)
            } else {
                resetSelection()
            }
        }
    }
    
    func hasCheck() -> Bool {
        return arbiter.positionHasCheck(board, color: board.whiteTurn ? .black : .white)
    }
    
    func movePiece(from start: Tile, to end: Tile) {
        let (startRank, startFile) = start
        let (endRank, endFile) = end
        
        guard endRank.isOnBoard() && endFile.isOnBoard() else {
            resetSelection()
            return
        }
        
        let piece = board[startRank, startFile].piece
        
        guard piece.type != .none else {
            resetSelection()
            return
        }
        
        guard board[endRank, endFile].canBeMovedTo else {
            resetSelection()
            return
        }
        
        // Check, if pawns moves two squares (initial double step)
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
            pauseGame = true
            return
            //TODO: Pause game while player selects piece
        }
        
        // King Move
        if piece == .kingW {
            board.whiteKingSquare = end
            
            // Move rook in castling
            if end == (7, 2) && !board.whiteKingHasMoved {
                board[7, 0].piece = Piece.none
                board[7, 3].piece = .rookW
                board.whiteQueensRookHasMoved = true
                
            } else if end == (7, 6) && !board.whiteKingHasMoved {
                board[7, 7].piece = Piece.none
                board[7, 5].piece = .rookW
                board.whiteKingsRookHasMoved = true
            }
            
            board.whiteKingHasMoved = true
            
        } else if piece == .kingB {
            board.blackKingSquare = end
            
            // Move rook in castling
            if end == (0, 2) && !board.blackKingHasMoved {
                board[0, 0].piece = Piece.none
                board[0, 3].piece = .rookB
                board.blackQueensRookHasMoved = true
                
            } else if end == (0, 6) && !board.blackKingHasMoved {
                movePiece(from: (0, 7), to: (0, 5))
                board[0, 7].piece = .none
                board[0, 5].piece = .rookB
                board.whiteKingsRookHasMoved = true
            }
            
            // Set last, so rooks can check if it has moved
            board.blackKingHasMoved = true
        }
        
        
        // Rook move
        if piece == .rookW {
            if start == (7, 0) {
                board.whiteQueensRookHasMoved = true
            } else if start == (7, 7) {
                board.whiteKingsRookHasMoved = true
            }
        } else if piece == .rookB {
            if start == (0, 0) {
                board.blackQueensRookHasMoved = true
            } else if start == (0, 7) {
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
        
        print("Check: \(arbiter.positionHasCheck(board, color: board.whiteTurn ? .white : .black))")
        
        endTurn()
        
        
    }
    
    func endTurn() {
        resetSelection()
        
        // Switch turn
        board.whiteTurn.toggle()
        
        //TODO: Remove previous en passants
        if board.whiteTurn {
            for (rank, file) in board.whiteEnPassants {
                board[rank, file].canBeTakenWithEnPassant = false
            }
           board.whiteEnPassants = []
        } else {
            for (rank, file) in board.blackEnPassants {
                board[rank, file].canBeTakenWithEnPassant = false
            }
            board.blackEnPassants = []
        }
        
        // Check for check
        board.check = arbiter.positionHasCheck(board, color: board.whiteTurn ? .black : .white)
        
        // Check for checkmate
        if board.check {
            board.checkmate = arbiter.positionHasCheckmate(board, color: board.whiteTurn ? .white : .black)
        }
        
        // check for stalemate
    }
    
    func select(_ square: Tile) {
        let (rank, file) = square
        // Check if square was already selected
        if selectedSquare != nil {
            if selectedSquare! == square {
                return
            }
        }
        
        // Check player is allowed to select
        if board.whiteTurn {
            guard board[rank, file].piece.color == .white else {
                resetSelection()
                return
            }
        } else {
            guard board[rank, file].piece.color == .black else {
                resetSelection()
                return
            }
        }
        
        // Reset all board legality status
        board.squares.makeAllIllegal()
        
        // Select square
        selectedSquare = square
        
        // Display legal moves
        let (canBeMovedTo, canBeTaken) = arbiter.legalSquares(for: board[rank, file].piece, at: square, in: board, turn: board.whiteTurn)
        displayLegalMoves(move: canBeMovedTo, take: canBeTaken)
        
    }
    
    
    func promotePawn(to pieceType: PieceType) {
        guard let promotionSquare = board.promotionSquare else {
            return
        }
        
        guard let startSquare = board.promotingPawnSquare else {
            return
        }
        
        let (endRank, endFile) = promotionSquare
        let (startRank, startFile) = startSquare
        
        board[startRank, startFile].piece = .none
        board[endRank, endFile].piece = Piece(color: board.whiteTurn ? .white : .black, type: pieceType)
        
        self.board.promotionSquare = nil
        pauseGame = false
        endTurn()
    }
    
    
    
    func displayLegalMoves(move canBeMovedTo: [Tile], take canBeTaken: [Tile]) {
        for square in canBeMovedTo {
            let (rank, file) = square
            board[rank, file].canBeMovedTo = true
        }
        
        for square in canBeTaken {
            let (rank, file) = square
            board[rank, file].canBeTaken = true
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
                movePiece(from: square, to: (i, i2))
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
