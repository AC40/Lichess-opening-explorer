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
            .background(isLight() ? theme.lightSquare : theme.darkSquare)
            .clipped()
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
        // Check special cases
        
        // king is on square AND king is in check
        if kingIsInCheck() {
            return theme.check
        }
        
        // Square was selected
        if chessboardVM.selectedSquare != nil {
            if chessboardVM.selectedSquare! == tile {
                return theme.highlight
            }
        }
        
        // Square was part of previous move
        if chessboardVM.board.currentMove > 0 {
            let prevMove = chessboardVM.board.moves[chessboardVM.board.currentMove-1]
            
            if prevMove.start == tile || prevMove.end == tile {
                return theme.prevMove.opacity(0.5)
            }
        }
        
        // No special cases apply
        return .clear
        
    }
    
    func isLight() -> Bool {
        return (tile.rank + tile.file) % 2 == 0
        
    }
}
