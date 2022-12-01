//
//  PieceView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

struct PieceView: View {
    
    var rank: Int
    var file: Int
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    
    @State private var offset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        let square = (rank, file)
        return VStack {
            if chessboardVM.board[rank, file].piece.color != .none {
                let piece = chessboardVM.board[rank, file].piece
                Image(piece.type.rawValue + piece.color.rawValue)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .scaleEffect(isDragging ? 1.3 : 1, anchor: .center)
                    .offset(offset)
                    .gesture(DragGesture(coordinateSpace: .global)
                        .onChanged {
                            onDragChanged($0, piece: piece, square: square)
                        }
                        .onEnded {
                            onDragEnded($0, piece: piece, square: square)
                        })
            } else {
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .onTapGesture {
            if chessboardVM.pauseGame {
                chessboardVM.cancelPromotion()
            } else {
                chessboardVM.handleTap(at: square)
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
            chessboardVM.handleTap(at: square)
        }
        
        withAnimation(.linear.speed(10)) {
            isDragging = true
            offset = value.translation
        }
    }
    
    func onDragEnded(_ value: DragGesture.Value, piece: Piece, square: Tile) {
        
        chessboardVM.onDrop(location: value.location, square: square)
        
        withAnimation(.default.speed(4)) {
            offset = .zero
        }
        
        isDragging = false
    }
}

