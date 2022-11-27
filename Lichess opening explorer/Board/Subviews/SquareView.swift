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
                Group {
                    if chessboardVM.squares[rank][file].canBeTaken {
                        Rectangle()
                            .strokeBorder(lineWidth: 2.5)
                            .foregroundColor(.teal)
                    } else if chessboardVM.squares[rank][file].canBeMovedTo {
                        Circle()
                            .foregroundColor(.teal.opacity(0.8))
                            .padding()
                    }
                    #if (DEBUG)
                    Text("\(rank), \(file)")
                        .font(.caption2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    #endif
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
        if chessboardVM.whiteKingSquare == (rank, file) {
            return .white
        } else if chessboardVM.blackKingSquare == (rank, file) {
            return .black
        }
        
        return .none
    }
    
    func kingIsInCheck() -> Bool {
        switch squareHasKing() {
            case .none:
                return false
            case .white:
                return chessboardVM.whiteIsInCheck
            case .black:
                return chessboardVM.blackisInCheck
            
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
