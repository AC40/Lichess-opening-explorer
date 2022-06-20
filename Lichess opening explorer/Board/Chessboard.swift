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
                            SquareView(file: file, rank: rank, chessboardVM: vm)
                        }
                        
                    }
                }
                
                LazyVGrid(columns: vm.layout, spacing: 0) {
                    ForEach(0..<8) { file in
                        ForEach(0..<8) { rank in
                            PieceView(file: file, rank: rank, chessboardVM: vm)
                                .zIndex(isSelected(at: (file, rank)) ? 100 : 90)
                        }
                    }
                }
            }
        }
        .overlay(
            pieceList()
        )
    }
    
    //MARK: View-related functions
    @ViewBuilder func pieceList() -> some View {
        Group {
            if vm.promotionSquare != nil {
                HStack {
                    Image("queen\(vm.whiteTurn ? "W" : "B")")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            vm.promotePawn(to: .queen)
                        }
                    Image("rook\(vm.whiteTurn ? "W" : "B")")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            vm.promotePawn(to: .rook)
                        }
                    Image("bishop\(vm.whiteTurn ? "W" : "B")")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            vm.promotePawn(to: .bishop)
                        }
                    Image("knight\(vm.whiteTurn ? "W" : "B")")
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

