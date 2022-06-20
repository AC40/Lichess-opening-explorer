//
//  PieceView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

struct PieceView: View {
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    
    @State private var offset: CGSize = .zero
    @State private var isDragging = false
    
    var file: Int
    var rank: Int
    
    var body: some View {
        let square = (file, rank)
        return VStack {
            
            if chessboardVM.squares[file][rank].piece.color != .none {
                let piece = chessboardVM.squares[file][rank].piece
                Image(piece.type.rawValue + piece.color.rawValue)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .scaleEffect(isDragging ? 1.3 : 1, anchor: .center)
//                    .allowsHitTesting(chessboardVM.whiteTurn == (piece.color == .white) ? true : false)
                    .offset(offset)
                    .gesture(DragGesture(coordinateSpace: .global)
                        .onChanged({ value in
                            
                            guard !chessboardVM.pauseGame else {
                                chessboardVM.cancelPromotion()
                                return
                            }
                            
                            guard chessboardVM.whiteTurn == (piece.color == .white) else {
                                return
                            }
                            
                            if !isDragging {
                                chessboardVM.handleTap(at: square)
                            }
                            
                            withAnimation(.linear.speed(10)) {
                                isDragging = true
                                offset = value.translation
                            }
                        })
                        .onEnded({ value in
                            
                            chessboardVM.onDrop(location: value.location, square: square)
                            
                            withAnimation(.default.speed(4)) {
                                offset = .zero
                            }
                            
                            isDragging = false
                        })
                    )
                    .zIndex(isDragging ? 100 : 1)
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
}

