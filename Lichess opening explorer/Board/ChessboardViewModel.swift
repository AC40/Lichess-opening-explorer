//
//  ChessboardViewModel.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

class ChessboardViewModel: ObservableObject {
    
    @Published var squares = Array(repeating: Array(repeating: Square(), count: 8), count: 8)
    @Published var selectedSquare: (Int, Int)? = nil
    @Published var whiteTurn = true
    
    @Published var squareFrames = Array(repeating: Array(repeating: CGRect.zero, count: 8), count: 8)
    @Published var boardRect = CGRect.zero
    
    let colorLight = Color(red: 235/255, green: 217/255, blue: 184/255)
    let colorDark = Color(red: 172/255, green: 136/255, blue: 104/255)
    let foo = Color.green
    
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
    
    init() {
        squares.loadDefaultFEN()
    }
    
    func handleTap(at tile: (Int, Int)) {
        let (file, rank) = tile
        
        if whiteTurn {
            if squares[file][rank].piece.color == .white {
                select(tile)
            } else if selectedSquare != nil {
                movePiece(from: selectedSquare!, to: tile)
            } else {
                resetSelection()
            }
        } else {
            if squares[file][rank].piece.color == .black {
                select(tile)
            } else if selectedSquare != nil {
                movePiece(from: selectedSquare!, to: tile)
            } else {
                resetSelection()
            }
        }
    }
    
    func movePiece(from start: Tile, to end: Tile) {
        let (startFile, startRank) = start
        let (endFile, endRank) = end
        
        guard endFile.isOnBoard() && endRank.isOnBoard() else {
            resetSelection()
            return
        }
        
        let piece = squares[startFile][startRank].piece
        
        guard piece.type != .none else {
            resetSelection()
            return
        }
        
        guard squares[endFile][endRank].canBeMovedTo else {
            resetSelection()
            return
        }
        
        squares[startFile][startRank].piece = Piece.none
        squares[endFile][endRank].piece = piece
        
        endTurn()
    }
    
    func endTurn() {
        resetSelection()
        whiteTurn.toggle()
    }
    
    func select(_ square: Tile) {
        let (file, rank) = square
        // Check if square was already selected
        if selectedSquare != nil {
            if selectedSquare! == square {
                return
            }
        }
        
        // Check player is allowed to select
        if whiteTurn {
            guard squares[file][rank].piece.color == .white else {
                resetSelection()
                return
            }
        } else {
            guard squares[file][rank].piece.color == .black else {
                resetSelection()
                return
            }
        }
        
        // Reset all squares legality status
        squares.makeAllIllegal()
        
        // Select square
        selectedSquare = square
        
        // Display legal moves
        legalSquares(for: squares[file][rank].piece, at: square)
    }
    
    func legalSquares(for piece: Piece, at square: Tile) {
        let (file, rank) = square
        
        // Long range sliding pieces
        if piece.isSlidingPiece() {
            for legalMove in ReachableSquares.forPiece(piece) {
                let (fileMove, rankMove) = legalMove
                
                var endFile = file - fileMove
                var endRank = rank - rankMove
                
                guard endFile.isOnBoard() && endRank.isOnBoard() else {
                    continue
                }
                
                while squareIsEmpty((endFile, endRank)) {
                    squares[endFile][endRank].canBeMovedTo = true
                    
                    endFile -= fileMove
                    endRank -= rankMove
                }
                
                if pieceIsOppositeColor(at: (endFile, endRank)) {
                    squares[endFile][endRank].canBeTaken = true
                }
            }
        } else if piece.type == .pawn {
            
            if piece.color == .white {
                let endFile = file - 1
                
                // Single step
                guard endFile.isOnBoard() && squareIsEmpty((endFile, rank)) else {
                    return
                }
                
                squares[endFile][rank].canBeMovedTo = true
                
                // Initial double step
                if file == 6 && squareIsEmpty((4, rank)) {
                    squares[4][rank].canBeMovedTo = true
                }
            } else if piece.color == .black {
                let endFile = file + 1
                
                // Single step
                guard endFile.isOnBoard() && squareIsEmpty((endFile, rank)) else {
                    return
                }
                
                squares[endFile][rank].canBeMovedTo = true
                
                // Initial double step
                if file == 1 && squareIsEmpty((3, rank)) {
                    squares[3][rank].canBeMovedTo = true
                }
            }
            
            //TODO: En passant
            //TODO: Take diagonally
            
        } else {
            for legalMove in ReachableSquares.forPiece(piece) {
                let (fileMove, rankMove) = legalMove
                
                let endFile = file - fileMove
                let endRank = rank - rankMove
                
                guard endFile.isOnBoard() && endRank.isOnBoard() else {
                    continue
                }
                
                if pieceIsOppositeColor(at: (endFile, endRank)) {
                    squares[endFile][endRank].canBeTaken = true
                }
                
                squares[endFile][endRank].canBeMovedTo = true
            }
        }
        
        
    }
    
    func squareIsEmpty(_ square: Tile) -> Bool {
        let (file, rank) = square
        
        guard file.isOnBoard() && rank.isOnBoard() else {
            return false
        }
        
        return squares[file][rank].piece == Piece.none
    }
    
    func pieceIsOppositeColor(at square: Tile) -> Bool {
        let (file, rank) = square
        
        guard file.isOnBoard() && rank.isOnBoard() else {
            return false
        }
        
        if whiteTurn {
            return squares[file][rank].piece.color == .black
        } else {
            return squares[file][rank].piece.color == .white
        }
    }
    
    func resetSelection() {
        // unselect square
        selectedSquare = nil
        
        // Reset all squares legality status
        squares.makeAllIllegal()
    }
    
    func onDrop(location: CGPoint, square: Tile) {
        for i in 0..<squareFrames.count {
            if let i2 = squareFrames[i].firstIndex(where: { $0.contains(location)}) {
                movePiece(from: square, to: (i, i2))
                break
            }
        }
    }
    
    func prepareNewTurn() {
        //TODO: Remove previous en passants
        
        // Switch turn
        whiteTurn.toggle()
    }
}
