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
    
    var theme: Theme
    
    var body: some View {
        Rectangle()
            .foregroundColor(foregroundColor())
            .aspectRatio(1, contentMode: .fill)
            .overlay(
                Group {
                    if !kingIsInCheck() {
                        if chessboardVM.board[rank, file].canBeTaken {
                            Rectangle()
                                .strokeBorder(lineWidth: 2.5)
                                .foregroundColor(theme.highlight)
                        } else if chessboardVM.board[rank, file].canBeMovedTo {
                            Circle()
                                .foregroundColor(theme.highlight)
                                .padding()
                        }
                    }
                    
                    if chessboardVM.showCoordinates {
                        Text("\(rank), \(file)")
                            .font(.caption2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .foregroundColor(.black)
                    }
                }
            )
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            chessboardVM.squareFrames[rank][file] = geo.frame(in: .global)
                        }
                        .onChange(of: chessboardVM.whitePerspective, perform: { _ in
                            chessboardVM.squareFrames[rank][file] = geo.frame(in: .global)
                        })
                }
            )
            .rotationEffect(chessboardVM.whitePerspective ? .degrees(0) : .degrees(180))
            .onTapGesture {
                if chessboardVM.pauseGame {
                    chessboardVM.cancelPromotion()
                } else {
                    chessboardVM.handleTap(at: (rank, file))
                }
            }
    }
    
    func squareHasKing() -> ChessColor {
        if chessboardVM.board.whiteKingSquare == (rank, file) {
            return .white
        } else if chessboardVM.board.blackKingSquare == (rank, file) {
            return .black
        }
        
        return .none
    }
    
    func kingIsInCheck() -> Bool {
        switch squareHasKing() {
        case .white:
            return (chessboardVM.hasCheck() && chessboardVM.board.whiteTurn)
        case .black:
            return (chessboardVM.hasCheck() && !chessboardVM.board.whiteTurn)
        case .none:
            return false
        }
    }
    
    func foregroundColor() -> Color {
        
        if kingIsInCheck() {
            return theme.check
        }
        
        if chessboardVM.selectedSquare != nil {
            if chessboardVM.selectedSquare! == (rank, file) {
                return theme.highlight
            }
        }
        
        if isLight() {
            return theme.lightSquare
        } else {
            return theme.darkSquare
        }
    }
    
    func isLight() -> Bool {
        return (rank + file) % 2 == 0
        
    }
}
