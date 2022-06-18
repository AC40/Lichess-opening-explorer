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
        
        if piece.type == .pawn {
            if piece.color == .white && Constants.pawnRankW.contains(start) && Constants.enPassantRankW.contains(end) {
                
            }
        }
        
        guard piece != .none else {
            resetSelection()
            return
        }
        
        squares[start].piece = Piece.none
        squares[end].piece = piece
        
        resetSelection()
        
        // Prepare new Turn
        prepareNewTurn()
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
        legalSquares(for: squares[i].piece, at: i)
    }
    
    func legalSquares(for piece: Piece, at i: Int) {
//        var legalSquares: [Int] = []
        
        // Check sliding pieces with looping method
        if piece.isSlidingPiece() {
            
            //TODO: Fix Queen/Rook error (Q/R on board outside)
            
            for move in ReachableSquares.forPiece(piece) {
                
                var newI = i - move
                
                let file = Int(Double(i%8))
                
                while squareIsEmpty(newI) {
                    
                    
                    // Check, if bishop is on outside and eliminate corresponding moves
                    if piece.type != .rook {
                        if file == 0 && (move == 9 || move == -7 ) {
                            break
                        }
                        
                        if file == 7 && (move == -9 || move == 7) {
                            break
                        }
                    }
                    
                    squares[newI].canBeMovedTo = true
                    
                    // Check, if side of board was reached
                    let newRank = Int(Double(newI/8).rounded())
                    let newFile = newI % 8
                    if newRank == 0 || newRank == 7 || newFile == 0 || newFile == 7 {
                        break
                    }
                    
                    newI -= move
                }
                
                if pieceIsOppositeColor(at: newI) {
                    squares[newI].canBeTaken = true
                }
                
            }
            
            // Check for knight
        } else if piece.type == .knight {
            
            //TODO: Fix Knight error
            
            for move in ReachableSquares.forPiece(piece) {
                
                let newI = i - move
                
                if squareIsEmpty(newI) {
                    squares[newI].canBeMovedTo = true
                } else if pieceIsOppositeColor(at: newI) {
                    squares[newI].canBeTaken = true
                }
            }
            // Check for pawns
        } else {
            
            let moves = ReachableSquares.forPiece(piece)
            for move in moves {
                
                let newI = i - move
                
                if squareIsEmpty(newI) {
                    squares[newI].canBeMovedTo = true
                }
            }
            
            //MARK: Special rules
            // Initial "double-step"
            if piece.type == .pawn {
                if piece.color == .white && Constants.pawnRankW.contains(i) {
                    squares[i-16].canBeMovedTo = true
                } else if piece.color == .black && Constants.pawnRankB.contains(i) {
                    squares[i+16].canBeMovedTo = true
                }
            }
            
            // Allow pawns to take diagonally
            let diagonalLeft = i - moves[0] - 1
            let diagonalRight = i - moves[0] + 1
            if pieceIsOppositeColor(at: diagonalLeft) {
                squares[diagonalLeft].canBeTaken = true
            }
            
            if pieceIsOppositeColor(at: diagonalRight) {
                squares[diagonalRight].canBeTaken = true
            }
            
            // Allow En passant
//            if piece.color == .white {
//                if Constants.enPassantRankW.contains(i) {
//                    if squares[i-1].piece.type == .pawn && i != 31{
//                        squares[i-9].canBeTakenWithEnPassant = true
//                    }
//                    if squares[i+1].piece.type == .pawn && i != 31 {
//                        squares[i-7].canBeTakenWithEnPassant = true
//                    }
//                }
//            } else if piece.color == .black {
//                if Constants.enPassantRankB.contains(i) {
//                    if squares[i-1].piece.type == .pawn && i != 32 {
//                        squares[i+7].canBeTakenWithEnPassant = true
//                    }
//                    if squares[i+1].piece.type == .pawn && i != 39 {
//                        squares[i+9].canBeTakenWithEnPassant = true
//                    }
//                }
//            }
        }
        
    }
    
    func moveChangesBoardSize(start: Int, end: Int) -> Bool {
        
        guard end >= 0 && end <= 63 else {
            return false
        }
        
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
    
    func prepareNewTurn() {
        // Remove previous en passants
        for i in 0..<squares.count {
            if squares[i].canBeTakenWithEnPassant {
                squares[i].canBeTakenWithEnPassant = false
            }
        }
        
        // Switch turn
        whiteTurn.toggle()
    }
}
