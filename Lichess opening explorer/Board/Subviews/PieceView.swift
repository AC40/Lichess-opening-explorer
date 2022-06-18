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
                            
                            if !isDragging {
                                chessboardVM.handleTap(at: square)
                            }
                            
                            guard chessboardVM.whiteTurn == (piece.color == .white) else {
                                return
                            }
                            
//                            guard chessboardVM.boardRect.contains(value.location) else {
//                                offset.width = value.translation.width
//                                return
//                            }
                            
                            withAnimation(.linear.speed(10)) {
                                isDragging = true
                                offset = value.translation
                            }
                        })
                        .onEnded({ value in
                            
                            withAnimation(.default.speed(4)) {
                                chessboardVM.onDrop(location: value.location, square: square)
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
            chessboardVM.handleTap(at: square)
        }
    }
}

