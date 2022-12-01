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
    
    @Published var squareFrames = Array(repeating: Array(repeating: CGRect.zero, count: 8), count: 8)
    

    
    let arbiter = Arbiter()
    
    let colorLight = Color(red: 235/255, green: 217/255, blue: 184/255)
    let colorDark = Color(red: 172/255, green: 136/255, blue: 104/255)
    
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
        
        // Check, if pawns moves two board
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
        
        print("Turn: \(board.whiteTurn)")
        print("Check: \(arbiter.positionHasCheck(board.squares, color: board.whiteTurn ? .white : .black))")
        
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
