//
//  SquareView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 06.06.22.
//

import SwiftUI

struct SquareView: View {
    
    var rank: Int
    var file: Int
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    
    var body: some View {
        Rectangle()
            .foregroundColor(foregroundColor())
            .aspectRatio(1, contentMode: .fill)
            .overlay(
                VStack {
                    if !kingIsInCheck() {
                        if chessboardVM.board[rank, file].canBeTaken {
                            Rectangle()
                                .strokeBorder(lineWidth: 2.5)
                                .foregroundColor(.teal)
                        } else if chessboardVM.board[rank, file].canBeMovedTo {
                            Circle()
                                .foregroundColor(.teal.opacity(0.8))
                                .padding()
                        }
                    }
                }
            )
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            chessboardVM.squareFrames[rank][file] = geo.frame(in: .global)
                        }
                }
            )
            .onTapGesture {
                if chessboardVM.pauseGame {
                    chessboardVM.cancelPromotion()
                } else {
                    chessboardVM.handleTap(at: (rank, file))
                }
            }
    }
    
    func squareHasKing() -> ChessColor {
        if chessboardVM.board.whiteKingSquare == (file, rank) {
            return .white
        } else if chessboardVM.board.blackKingSquare == (file, rank) {
            return .black
        }
        
        return .none
    }
    
    #warning("This needs to be fixed")
    func kingIsInCheck() -> Bool {
        switch squareHasKing() {
        case .white:
            return false
        case .black:
            return false
        case .none:
            return false
        }
    }
    
    func foregroundColor() -> Color {
        
        if kingIsInCheck() {
            return .red
        }
        
        if chessboardVM.selectedSquare != nil {
            if chessboardVM.selectedSquare! == (rank, file) {
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
        return (rank + file) % 2 == 0
        
    }
}
