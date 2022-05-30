//
//  PieceView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

struct PieceView: View {
    
    var piece: Piece
    
    @State private var offset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        Group {
            
            if piece != .none {
                Image(piece.rawValue)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .offset(offset)
                    .gesture(DragGesture()
                        .onChanged({ value in
                            
                            isDragging = true
                            
                            withAnimation(.linear.speed(4)) {
                                offset = value.translation
                            }
                        })
                        .onEnded({ value in
                            
                            isDragging = false
                            
                            withAnimation {
                                offset = .zero
                            }
                        })
                    )
                    .zIndex(isDragging ? 100 : 1)
            } else {
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }
}

struct PieceView_Previews: PreviewProvider {
    static var previews: some View {
        PieceView(piece: .kingW)
    }
}
