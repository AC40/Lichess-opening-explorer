//
//  ChessboardViewModel.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

class ChessboardViewModel: ObservableObject {
    
    //MARK: Variables
    @Published var squares = Array(repeating: Array(repeating: Square(), count: 8), count: 8)
    @Published var selectedSquare: (Int, Int)? = nil
    @Published var promotionSquare: Tile? = nil
    @Published var promotingPawnSquare: Tile? = nil
    @Published var whiteKingSquare: Tile = (7, 4)
    @Published var blackKingSquare: Tile = (0, 4)
    @Published var whiteIsInCheck = false
    @Published var blackisInCheck = false
    
    @Published var whiteTurn = true
    @Published var pauseGame = false
    
    @Published var squareFrames = Array(repeating: Array(repeating: CGRect.zero, count: 8), count: 8)
    
    @Published var whiteEnPassants: [Tile] = []
    @Published var blackEnPassants: [Tile] = []
    
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
    
    init() {
        squares.loadDefaultFEN()
        
        let whiteKingRank: Int = squares.firstIndex(where: { $0.contains(where: { $0.piece == .kingW})}) ?? 7
        let whiteKingFile: Int = squares[whiteKingRank].firstIndex(where: {$0.piece == .kingW }) ?? 4
        
        let blackKingRank: Int = squares.firstIndex(where: { $0.contains(where: { $0.piece == .kingB})}) ?? 0
        let blackKingFile: Int = squares[blackKingRank].firstIndex(where: {$0.piece == .kingB }) ?? 4
        
        whiteKingSquare = (whiteKingRank, whiteKingFile)
        blackKingSquare = (blackKingRank, blackKingFile)
    }
    
    func handleTap(at tile: (Int, Int)) {
        let (rank, file) = tile
        
        if whiteTurn {
            if squares[rank][file].piece.color == .white {
                select(tile)
            } else if selectedSquare != nil {
                movePiece(from: selectedSquare!, to: tile)
            } else {
                resetSelection()
            }
        } else {
            if squares[rank][file].piece.color == .black {
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
        
        let piece = squares[startRank][startFile].piece
        
        guard piece.type != .none else {
            resetSelection()
            return
        }
        
        guard squares[endRank][endFile].canBeMovedTo else {
            resetSelection()
            return
        }
        
        // Check, if pawns moves two squares
        if piece.type == .pawn && abs(endRank-startRank) == 2 {
            if piece.color == .white {
                squares[endRank+1][endFile].canBeTakenWithEnPassant = true
                whiteEnPassants.append((endRank+1, endFile))
            } else {
                squares[endRank-1][endFile].canBeTakenWithEnPassant = true
                blackEnPassants.append((endRank-1, endFile))
            }
        }
        
        // Promote pawn
        if (whiteTurn ? (endRank == 0) : (endRank == 7)) && piece.type == .pawn {
            promotionSquare = end
            promotingPawnSquare = start
            pauseGame = true
            return
            //TODO: Pause game while player selects piece
        }
        
        // King Move
        if piece == .kingW {
            whiteKingSquare = end
        } else if piece == .kingB {
            blackKingSquare = end
        }
        
        // Move piece from start to end square
        squares[startRank][startFile].piece = Piece.none
        squares[endRank][endFile].piece = piece
        
        // Take pawn when taken with en passant
        if squares[endRank][endFile].canBeTakenWithEnPassant {
            if whiteTurn {
                squares[endRank+1][endFile].piece = Piece.none
            } else {
                squares[endRank-1][endFile].piece = Piece.none
            }
        }
        
        print("Turn: \(whiteTurn)")
        print("Check: \(positionHasCheck(squares, color: whiteTurn ? .white : .black))")
        
        endTurn()
        
        
    }
    
    func endTurn() {
        resetSelection()
        
        // Switch turn
        whiteTurn.toggle()
        
        // Remove checks
        whiteIsInCheck = false
        blackisInCheck = false
        
        //TODO: Remove previous en passants
        if whiteTurn {
            for (rank, file) in whiteEnPassants {
                squares[rank][file].canBeTakenWithEnPassant = false
            }
            whiteEnPassants = []
        } else {
            for (rank, file) in blackEnPassants {
                squares[rank][file].canBeTakenWithEnPassant = false
            }
            blackEnPassants = []
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
        if whiteTurn {
            guard squares[rank][file].piece.color == .white else {
                resetSelection()
                return
            }
        } else {
            guard squares[rank][file].piece.color == .black else {
                resetSelection()
                return
            }
        }
        
        // Reset all squares legality status
        squares.makeAllIllegal()
        
        // Select square
        selectedSquare = square
        
        // Display legal moves
        let (canBeMovedTo, canBeTaken) = legalSquares(for: squares[rank][file].piece, at: square)
        displayLegalMoves(move: canBeMovedTo, take: canBeTaken)
        
    }
    
    func legalSquares(for piece: Piece, at square: Tile) -> ([Tile], [Tile]) {
        let (rank, file) = square
        
        var canBeMovedTo: [Tile] = []
        var canBeTaken: [Tile] = []
        
        // Long range sliding pieces
        if piece.isSlidingPiece() {
            for legalMove in Moves.forPiece(piece) {
                let (rankMove, fileMove) = legalMove
                
                var endRank = rank - rankMove
                var endFile = file - fileMove
                
                guard endRank.isOnBoard() && endFile.isOnBoard() else {
                    continue
                }
                
                while squareIsEmpty((endRank, endFile)) {
                    canBeMovedTo.append((endRank, endFile))
                    
                    endRank -= rankMove
                    endFile -= fileMove
                }
                
                if pieceIsOppositeColor(at: (endRank, endFile)) {
                    canBeTaken.append((endRank, endFile))
                }
            }
        } else if piece.type == .pawn {
            
            if piece.color == .white {
                let endRank = rank - 1
                
                // Single step
                if endRank.isOnBoard() && squareIsEmpty((endRank, file)) {
                    canBeMovedTo.append((endRank, file))
                }
                
                // Initial double step
                if rank == 6 && squareIsEmpty((4, file)) {
                    canBeMovedTo.append((4, file))
                }
            } else if piece.color == .black {
                let endRank = rank + 1
                
                // Single step
                if endRank.isOnBoard() && squareIsEmpty((endRank, file)) {
                    canBeMovedTo.append((endRank, file))
                }
                
                // Initial double step
                if rank == 1 && squareIsEmpty((3, file)) {
                    canBeMovedTo.append((3, file))
                }
            }
            
            // Take diagonally
            for diagonalMove in Moves.pawnDiagonals(for: piece.color) {
                let (rankMove, fileMove) = diagonalMove
                
                let endRank = rank - rankMove
                let endFile = file - fileMove
                
                guard endRank.isOnBoard() && endFile.isOnBoard() else {
                    continue
                }
                
                if pieceIsOppositeColor(at: (endRank, endFile)) {
                    canBeTaken.append((endRank, endFile))
                    
                    // En passant
                } else if squares[endRank][endFile].canBeTakenWithEnPassant {
                    canBeTaken.append((endRank, endFile))
                }
                
            }
        } else {
            for legalMove in Moves.forPiece(piece) {
                let (rankMove, fileMove) = legalMove
                
                let endRank = rank - rankMove
                let endFile = file - fileMove
                
                guard endRank.isOnBoard() && endFile.isOnBoard() else {
                    continue
                }
                
                if pieceIsOppositeColor(at: (endRank, endFile)) {
                    canBeTaken.append((endRank, endFile))
                } else if squareIsEmpty((endRank, endFile)) {
                    canBeMovedTo.append((endRank, endFile))
                }
            }
            
            //TODO: Castling
        }
        
        return (canBeMovedTo, canBeTaken)
    }
    
    // Working implementation (woop woo)
    func positionHasCheck(_ position: [[Square]], color: ChessColor) -> Bool {
        
        // In explation, it is assumed white just made a move, thus color = .white
        // Generate pieces from side
        var pieces = [Piece]()
        
        for rank in 0..<position.count {
            for file in 0..<position[rank].count {
                
                var piece = position[rank][file].piece
                
                if piece != .none && piece.color == color {
                    piece.square = (rank, file)
                    pieces.append(piece)
                }
            }
        }
        print(pieces)
        
        // For each piece:
        for piece in pieces {
            
            guard piece.square != nil else {
                continue
            }
            
            // generate all moves
            let (_, pseudoCanBeTaken) = legalSquares(for: piece, at: piece.square!)
            
            // for each move
            for move in pseudoCanBeTaken {
                
                // Check, if the moves takes the color's king
                if position[move.0][move.1].piece.type == .king && position[move.0][move.1].piece.color != color {
                    
                    // if it does, return true
                    return true
                }
            }
        }
                    
        return false
    }
    
    func promotePawn(to pieceType: PieceType) {
        guard let promotionSquare = promotionSquare else {
            return
        }
        
        guard let startSquare = promotingPawnSquare else {
            return
        }
        
        let (endRank, endFile) = promotionSquare
        let (startRank, startFile) = startSquare
        
        squares[startRank][startFile].piece = .none
        squares[endRank][endFile].piece = Piece(color: whiteTurn ? .white : .black, type: pieceType)
        
        self.promotionSquare = nil
        pauseGame = false
        endTurn()
    }
    
    //MARK: Utility functions
    func squareIsEmpty(_ square: Tile) -> Bool {
        let (rank, file) = square
        
        guard rank.isOnBoard() && file.isOnBoard() else {
            return false
        }
        
        return squares[rank][file].piece == Piece.none
    }
    
    func displayLegalMoves(move canBeMovedTo: [Tile], take canBeTaken: [Tile]) {
        for square in canBeMovedTo {
            let (rank, file) = square
            squares[rank][file].canBeMovedTo = true
        }
        
        for square in canBeTaken {
            let (rank, file) = square
            squares[rank][file].canBeTaken = true
        }
    }
    
    func pieceIsOppositeColor(at square: Tile) -> Bool {
        let (rank, file) = square
        
        guard rank.isOnBoard() && file.isOnBoard() else {
            return false
        }
        
        if whiteTurn {
            return squares[rank][file].piece.color == .black
        } else {
            return squares[rank][file].piece.color == .white
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
    
    func cancelPromotion() {
        pauseGame = false
        promotionSquare = nil
        resetSelection()
    }
    
    
}
