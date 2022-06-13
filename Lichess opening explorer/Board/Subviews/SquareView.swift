//
//  SquareView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 06.06.22.
//

import SwiftUI

struct SquareView: View {
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    var i: Int
    
    var body: some View {
        
        Rectangle()
            .foregroundColor(chessboardVM.selectedSquare == i ? .teal : isLight() ? chessboardVM.colorLight : chessboardVM.colorDark)
            .aspectRatio(1, contentMode: .fill)
            .overlay(
                Group {
                    if chessboardVM.squares[i].isLegal && chessboardVM.pieceIsOppositeColor(at: i) {
                        Rectangle()
                            .strokeBorder(lineWidth: 2.5)
                            .foregroundColor(.teal)
                    } else if chessboardVM.squares[i].isLegal {
                        Circle()
                            .foregroundColor(.teal.opacity(0.8))
                            .padding()
                    }
                }
            )
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            chessboardVM.squareFrames[i] = geo.frame(in: .global)
                        }
                }
            )
            .onTapGesture {
                chessboardVM.handleTap(at: i)
            }
    }
    
    func isLight() -> Bool {
        return ((((i / 8) + (i % 8)) % 2) == 0)
    }
}
