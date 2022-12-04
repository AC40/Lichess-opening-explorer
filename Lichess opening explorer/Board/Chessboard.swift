//
//  Chessboard.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

struct Chessboard: View {
    
    @ObservedObject var vm: ChessboardViewModel
    @ObservedObject var themeMg: ThemeManager
    
    var body: some View {
        
        ZStack {
            
//            Color.teal
//                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                LazyVGrid(columns: vm.layout, spacing: 0) {
                    ForEach(0..<8) { rank in
                        ForEach(0..<8) { file in
                            SquareView(tile: Tile(rank, file), chessboardVM: vm, theme: themeMg.current)
                        }
                        
                    }
                }
                
                LazyVGrid(columns: vm.layout, spacing: 0) {
                    ForEach(0..<8) { rank in
                        ForEach(0..<8) { file in
                            PieceView(tile: Tile(rank, file), chessboardVM: vm)
                                .zIndex(isSelected(at: Tile(rank, file)) ? 100 : 90)
                        }
                    }
                }
            }
            .rotationEffect(vm.whitePerspective ? .degrees(0) : .degrees(180))
        }
        .overlay(
            pieceList()
        )
    }
    
    //MARK: View-related functions
    @ViewBuilder func pieceList() -> some View {
        HStack {
            if vm.board.promotionSquare != nil {
                HStack {
                    Image("queen\(vm.board.whiteTurn ? "W" : "B")")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            vm.promotePawn(to: .queen)
                        }
                    Image("rook\(vm.board.whiteTurn ? "W" : "B")")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            vm.promotePawn(to: .rook)
                        }
                    Image("bishop\(vm.board.whiteTurn ? "W" : "B")")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            vm.promotePawn(to: .bishop)
                        }
                    Image("knight\(vm.board.whiteTurn ? "W" : "B")")
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
    }
    
    //MARK: Internal functions
    func isSelected(at square: Tile) -> Bool {
        guard vm.selectedSquare != nil else {
            return false
        }
        
        return vm.selectedSquare! == square
    }
}

