//
//  SquareView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 06.06.22.
//

import SwiftUI

struct SquareView: View {
    
    var tile: Tile
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    
    var theme: Theme
    
    var body: some View {
        Rectangle()
            .foregroundColor(foregroundColor())
            .aspectRatio(1, contentMode: .fill)
            .overlay(
                Group {
                    if !kingIsInCheck() {
                        if chessboardVM.board[tile].canBeTaken {
                            Rectangle()
                                .strokeBorder(lineWidth: 2.5)
                                .foregroundColor(theme.highlight)
                        } else if chessboardVM.board[tile].canBeMovedTo {
                            Circle()
                                .foregroundColor(theme.highlight)
                                .padding()
                        }
                    }
                    
                    if chessboardVM.showCoordinates {
                        Text("\(tile.rank), \(tile.file)")
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
                            chessboardVM.squareFrames[tile.rank][tile.file] = geo.frame(in: .global)
                        }
                        .onChange(of: chessboardVM.whitePerspective, perform: { _ in
                            chessboardVM.squareFrames[tile.rank][tile.file] = geo.frame(in: .global)
                        })
                }
            )
            .rotationEffect(chessboardVM.whitePerspective ? .degrees(0) : .degrees(180))
            .onTapGesture {
                if chessboardVM.pauseGame {
                    chessboardVM.cancelPromotion()
                } else {
                    chessboardVM.handleTap(at: tile)
                }
            }
    }
    
    func squareHasKing() -> ChessColor {
        if chessboardVM.board.whiteKingSquare == tile {
            return .white
        } else if chessboardVM.board.blackKingSquare == tile {
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
            if chessboardVM.selectedSquare! == tile {
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
        return (tile.rank + tile.file) % 2 == 0
        
    }
}
