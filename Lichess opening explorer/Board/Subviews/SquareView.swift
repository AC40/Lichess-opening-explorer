//
//  SquareView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 06.06.22.
//

import SwiftUI

typealias Tile = (Int, Int)

struct SquareView: View {
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    var file: Int
    var rank: Int
    
    
    var body: some View {
        Rectangle()
            .foregroundColor(foregroundColor())
            .aspectRatio(1, contentMode: .fill)
            .overlay(
                Group {
                    if chessboardVM.squares[file][rank].canBeTaken {
                        Rectangle()
                            .strokeBorder(lineWidth: 2.5)
                            .foregroundColor(.teal)
                    } else if chessboardVM.squares[file][rank].canBeMovedTo {
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
                            chessboardVM.squareFrames[file][rank] = geo.frame(in: .global)
                        }
                }
            )
            .onTapGesture {
                chessboardVM.handleTap(at: (file, rank))
            }
    }
    
    func foregroundColor() -> Color {
        
        if chessboardVM.selectedSquare != nil {
            if chessboardVM.selectedSquare! == (file, rank) {
                return .teal
            }
        }
        
        if isLight() {
            return chessboardVM.colorLight
        } else {
            return chessboardVM.colorDark
        }
    }
    
    func isLight() -> Bool {
        return (file + rank) % 2 == 0
        
    }
}
