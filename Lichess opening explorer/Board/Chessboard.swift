//
//  Chessboard.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

struct Chessboard: View {
    
    @ObservedObject var vm: ChessboardViewModel
    
    var body: some View {
        
        ZStack {
            
            Color.teal
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                LazyVGrid(columns: vm.layout, spacing: 0) {
                    ForEach(0..<8) { file in
                        ForEach(0..<8) { rank in
                            
//                            let sum = file + rank
//                            Rectangle()
//                                .foregroundColor(sum % 2 == 0 ? .brown : .black)
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                .aspectRatio(1, contentMode: .fill)
                            SquareView(chessboardVM: vm, file: file, rank: rank)
                        }
                        
                    }
                }
                .background(Group {GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            vm.boardRect = geo.frame(in: .global)
                        }
                }})
                LazyVGrid(columns: vm.layout, spacing: 0) {
                    ForEach(0..<8) { file in
                        ForEach(0..<8) { rank in
                            PieceView(chessboardVM: vm, file: file, rank: rank)
                                .zIndex(isSelected(at: (file, rank)) ? 100 : 90)
                        }
                    }
                }
            }
        }
        .overlay(
            Group {
                if vm.promotionSquare != nil {
                    HStack {
                        Image("queen\(vm.whiteTurn ? "B" : "W")")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .onTapGesture {
                                vm.promotePawn(to: .queen)
                            }
                        Image("rook\(vm.whiteTurn ? "B" : "W")")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .onTapGesture {
                                vm.promotePawn(to: .rook)
                            }
                        Image("bishop\(vm.whiteTurn ? "B" : "W")")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .onTapGesture {
                                vm.promotePawn(to: .bishop)
                            }
                        Image("knight\(vm.whiteTurn ? "B" : "W")")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .onTapGesture {
                                vm.promotePawn(to: .knight)
                            }
                    }
                        .padding()
                        .background(Color.black.opacity(0.5))
                }
            }
        )
    }
    
    func isSelected(at square: Tile) -> Bool {
        guard vm.selectedSquare != nil else {
            return false
        }
        
        return vm.selectedSquare! == square
    }
}

