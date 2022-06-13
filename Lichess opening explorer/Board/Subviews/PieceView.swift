//
//  PieceView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

struct CenterPreferenceKey: PreferenceKey {
    typealias Value = Anchor<CGPoint>?
    
    static var defaultValue: Value = nil
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

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
                    .scaleEffect(isDragging ? 1.3 : 1, anchor: .center)
//                    .allowsHitTesting(chessboardVM.whiteTurn == (piece.color == .white) ? true : false)
                    .offset(offset)
                    .gesture(DragGesture(coordinateSpace: .global)
                        .onChanged({ value in
                            
                            if !isDragging {
//                                chessboardVM.select(i)
                                chessboardVM.handleTap(at: i)
                            }
                            
                            guard chessboardVM.whiteTurn == (piece.color == .white) else {
                                return
                            }
                            
                            withAnimation(.linear.speed(10)) {
                                isDragging = true
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
//            chessboardVM.select(i)
            chessboardVM.handleTap(at: i)
        }
    }
}

