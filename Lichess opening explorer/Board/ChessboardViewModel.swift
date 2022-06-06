//
//  ChessboardViewModel.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

class ChessboardViewModel: ObservableObject {
    
    @Published var squares = Array(repeating: Square(), count: 64)
    @Published var squareFrames = Array(repeating: CGRect.zero, count: 64)
    
    @Published var selectedSquare: Int? = nil
    @Published var whiteTurn = true
    
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
    
    func handleTap(at i: Int) {
        
        if whiteTurn {
            if squares[i].piece.color == .white {
                select(i)
            } else {
                guard selectedSquare != nil else { return }
                movePiece(from: selectedSquare!, to: i)
            }
        }
    }
    
    func movePiece(from start: Int, to end: Int) {
        
        guard squares[end].isLegal else {
            return
        }
        
        let piece = squares[start].piece
        squares[start].piece = Piece.none
        squares[end].piece = piece
        
        resetSelection()
    }
    
    func select(_ i: Int) {
        
        // Check if square was already selected
        guard selectedSquare != i else {
            return
        }
        

        
        // Check player is allowed to select
        if whiteTurn {
            guard squares[i].piece.color == .white else {
                resetSelection()
                return
            }
        } else {
            guard squares[i].piece.color == .black else {
                resetSelection()
                return
            }
        }
        
        // Reset all squares legality status
        squares.makeAllIllegal()
        
        // Select square
        selectedSquare = i
        
        // Display legal moves
        for legalSquare in legalSquares(for: squares[i].piece, at: i) {
            squares[legalSquare].isLegal = true
        }
    }
    
    func legalSquares(for piece: Piece, at i: Int) -> [Int] {
        var legalSquares: [Int] = []
        
        for move in ReachableSquares.forPiece(piece.type) {
            
            let newI = i - move
            
            guard newI >= 0 && newI <= 63 else {
                break
            }
            
            if squareIsEmpty(newI) || pieceIsOppositeColor(at: newI) {
                legalSquares.append(newI)
            }
            
            
        }
        
        //TODO: Pawn initial "double-step"
        if piece.type == .pawn {
            if whiteTurn && Constants.pawnRankW().contains(i) {
                legalSquares.append(i-16)
            } else if Constants.pawnRankB().contains(i) {
                legalSquares.append(i+16)
            }
        }
        
        //TODO: En passant
        
        //TODO: Pawn taking diagonally
        
        return legalSquares
    }
    
    func squareIsEmpty(_ i: Int) -> Bool {
        return squares[i].piece == Piece.none
    }
    
    func pieceIsOppositeColor(at i: Int) -> Bool {
        if whiteTurn {
            return squares[i].piece.color == .black
        } else {
            return squares[i].piece.color == .white
        }
    }
    
    func resetSelection() {
        // unselect square
        selectedSquare = nil
        
        // Reset all squares legality status
        squares.makeAllIllegal()
    }
    
    func onDrop(location: CGPoint, i: Int) {
        if let end = squareFrames.firstIndex(where: { $0.contains(location) }) {
            movePiece(from: i, to: end)
        }
    }
}
