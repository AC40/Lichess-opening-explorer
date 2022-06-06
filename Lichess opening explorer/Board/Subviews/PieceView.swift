//
//  PieceView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

struct PieceView: View {
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    var i: Int
    
    @State private var offset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        VStack {
            
            if chessboardVM.squares[i].piece.color != .none {
                let piece = chessboardVM.squares[i].piece
                Image(piece.type.rawValue + piece.color.rawValue)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .offset(offset)
                    .gesture(DragGesture(coordinateSpace: .global)
                        .onChanged({ value in
                            
                            if !isDragging {
                                chessboardVM.select(i)
                            }
                            
                            isDragging = true
                            
                            withAnimation(.linear.speed(4)) {
                                offset = value.translation
                            }
                        })
                        .onEnded({ value in
                            
                            
//                            withAnimation {
                                chessboardVM.onDrop(location: value.location, i: i)
                                offset = .zero
//                            }
                            
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
            chessboardVM.select(i)
        }
    }
}

