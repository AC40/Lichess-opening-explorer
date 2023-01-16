//
//  PieceView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

struct PieceView: View {
    @EnvironmentObject var settings: Settings
    
    var tile: Tile
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    
    @State private var offsetX: CGFloat = .zero
    @State private var offsetY: CGFloat = .zero
    @State private var isDragging = false
    
    var body: some View {
        return VStack {
            if chessboardVM.board[tile.rank, tile.file].piece.color != .none {
                let piece = chessboardVM.board[tile.rank, tile.file].piece
                let frame = chessboardVM.squareFrames[tile.rank][tile.file]
                
                Image(piece.type.rawValue + piece.color.rawValue)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .scaleEffect(isDragging ? 1.3 : 1, anchor: .center)
                    .frame(width: frame.width, height: frame.height)
                    .position(x: frame.midX  + offsetX, y: frame.midY + offsetY)
                    .rotationEffect(chessboardVM.whitePerspective ? .degrees(0) : .degrees(180))
                    .animation(settings.movePieceAnimation(), value: piece.square)
                    .highPriorityGesture(DragGesture(coordinateSpace: .named("chessboard"))
                        .onChanged {
                            onDragChanged($0, piece: piece, square: tile)
                        }
                        .onEnded {
                            chessboardVM.lastInteractionWasDrag = true
                            onDragEnded($0, piece: piece, square: tile)
                        })
            } else {
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .onTapGesture {
            chessboardVM.lastInteractionWasDrag = false
            if chessboardVM.pauseGame {
                chessboardVM.cancelPromotion()
            } else {
                chessboardVM.handleTap(at: tile)
            }
        }
        .onChange(of: chessboardVM.board[tile].piece) { newValue in
                     if newValue != .none && !chessboardVM.lastInteractionWasDrag {

                         guard chessboardVM.board.currentMove >= chessboardVM.board.moves.count else {
                             return
                         }

                         let prevMove = chessboardVM.board.moves[chessboardVM.board.currentMove-1]

                         if prevMove.end == tile {
                             let startX = chessboardVM.squareFrames[prevMove.start.rank][prevMove.start.file].midX
                             let startY = chessboardVM.squareFrames[prevMove.start.rank][prevMove.start.file].midY

                             let selfX = chessboardVM.squareFrames[tile.rank][tile.file].midX
                             let selfY = chessboardVM.squareFrames[tile.rank][tile.file].midY

                             let offX = -(selfX - startX)
                             let offY = -(selfY - startY)

                             // Set piece to start square
                             offsetX = offX
                             offsetY = offY

                         }

                         // Animate to current square
                         animatePieceToSelf()
                     }
                 }
    }
    
    //MARK: Internal functions
    func onDragChanged(_ value: DragGesture.Value, piece: Piece, square: Tile) {
        guard !chessboardVM.pauseGame else {
            chessboardVM.cancelPromotion()
            return
        }
        
        guard chessboardVM.board.whiteTurn == (piece.color == .white) else {
            return
        }
        
        if !isDragging {
            chessboardVM.handleTap(at: tile)
        }
        
        withAnimation(.linear.speed(10)) {
            isDragging = true
            offsetX = value.translation.width
            offsetY = value.translation.height
        }
    }
    
    func onDragEnded(_ value: DragGesture.Value, piece: Piece, square: Tile) {
        
        chessboardVM.onDrop(location: value.location, square: square)
        
        withAnimation(.default.speed(4)) {
            offsetX = .zero
            offsetY = .zero
        }
        
        isDragging = false
    }
    
    func animatePieceToSelf() {
        withAnimation(settings.movePieceAnimation())  {
            offsetX = .zero
            offsetY = .zero
        }
        
    }
}

