//
//  ChessboardViewModel.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

class ChessboardViewModel: ObservableObject {
    
    @Published var squares = Array(repeating: Square(), count: 64)
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
    
    func movePiece(from start: Int, to end: Int) {
        
        let piece = squares[start].piece
        squares[start].piece = Piece.none
        squares[end].piece = piece
    }
    
    func select(_ i: Int) {
        guard selectedSquare != i else {
            return
        }
        
        // Select square
        selectedSquare = i
        
        // Reset all squares
        squares.makeAllIllegal()
        
        // Check if field is empty
        if whiteTurn {
            guard squares[i].piece.color == .white else {
                return
            }
            
            // Display legal moves
            for legalSquare in legalSquares(for: squares[i].piece, at: i) {
                squares[legalSquare].isLegal = true
            }
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
        
        //TODO: En passant
        //TODO: Pawn initial "double-jump"
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
}
