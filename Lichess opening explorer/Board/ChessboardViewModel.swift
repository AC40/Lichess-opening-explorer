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
            } else if selectedSquare != nil {
                movePiece(from: selectedSquare!, to: i)
            } else {
                resetSelection()
            }
        } else {
            if squares[i].piece.color == .black {
                select(i)
            } else if selectedSquare != nil {
                movePiece(from: selectedSquare!, to: i)
            } else {
                resetSelection()
            }
        }
    }
    
    func movePiece(from start: Int, to end: Int) {
        
        guard squares[end].isLegal else {
            resetSelection()
            return
        }
        
        let piece = squares[start].piece
        
        guard piece != .none else {
            resetSelection()
            return
        }
        
        squares[start].piece = Piece.none
        squares[end].piece = piece
        
        resetSelection()
        
        // Switch turn
        whiteTurn.toggle()
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
        
        // Check sliding pieces with looping method
        if piece.isSlidingPiece() {
            
            for move in ReachableSquares.forPiece(piece) {
                
                var newI = i - move
                
                let rank = Int(Double(i/8).rounded())
                let file = Int(Double(i%8))
                
                while squareIsEmpty(newI) {
                    
                    
                    // Check, if bishop is on outside and eliminate corresponding moves
                    if piece.type == .bishop {
                        if file == 0 && (move == 9 || move == -7 ) {
                            break
                        }
                        
                        if file == 7 && (move == -9 || move == 7) {
                            break
                        }
                    }
                    
                    legalSquares.append(newI)
                    
                    // Check, if side of board was reached
                    let newRank = Int(Double(newI/8).rounded())
                    let newFile = newI % 8
                    if newRank == 0 || newRank == 7 || newFile == 0 || newFile == 7 {
                        break
                    }
                    
                    newI -= move
                }
                
                if pieceIsOppositeColor(at: newI) {
                    legalSquares.append(newI)
                }
                
            }
        
        // Check other pieces (and pawns)
        } else {
        
            for move in ReachableSquares.forPiece(piece) {
                
                let newI = i - move
                
                if squareIsEmpty(newI) || pieceIsOppositeColor(at: newI) {
                    legalSquares.append(newI)
                }
            }
        }
        
        //MARK: Special rules
        // Check Pawns initial "double-step"
        if piece.type == .pawn {
            if piece.color == .white && Constants.pawnRankW().contains(i) {
                legalSquares.append(i-16)
            } else if piece.color == .black && Constants.pawnRankB().contains(i) {
                legalSquares.append(i+16)
            }
        }
        
        //TODO: Check for En passant
        
        //TODO: Allow pawns to take diagonally
        
        //TODO: Allow pawns to promote
        
        return legalSquares
    }
    
    func moveChangesBoardSize(start: Int, end: Int) -> Bool {
        
        guard end >= 0 && end <= 63 else {
            return false
        }
        
        let rank = Int(Double(start/8).rounded())
        let file = Int(Double(start%8))
        
        return (start/8 != end/8) && (start%8 != end%8)
    }
    
    func squareIsEmpty(_ i: Int) -> Bool {
        
        guard i >= 0 && i <= 63 else {
            return false
        }
        
        return squares[i].piece == Piece.none
    }
    
    func pieceIsOppositeColor(at i: Int) -> Bool {
        
        guard i >= 0 && i <= 63 else {
            return false
        }
        
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
