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
//        squares.loadDefaultFEN()
        squares.loadFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
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
        
    }
    
    func squareIsEmpty(_ square: Tile) -> Bool {
        let (file, rank) = square
        
        return squares[file][rank].piece == Piece.none
    }
    
    func pieceIsOppositeColor(at square: Tile) -> Bool {
        let (file, rank) = square
        
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
//        squares.makeAllIllegal()
    }
    
    func onDrop(location: CGPoint, square: Tile) {
        for subArray in squareFrames {
            for rect in subArray {
                if rect.contains(location) {
                    movePiece(from: selectedSquare!, to: square)
                }
            }
        }
    }
    
    func prepareNewTurn() {
        //TODO: Remove previous en passants
        
        // Switch turn
        whiteTurn.toggle()
    }
}
