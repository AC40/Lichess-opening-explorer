//
//  VariationView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.12.22.
//

import SwiftUI

struct VariationView: View {
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                WrappingHStack {
                    ForEach(0..<chessboardVM.board.moves.count, id:\.self) { i in
                        Button() {
                            chessboardVM.board.moveI = i+1
                            chessboardVM.loadMove(chessboardVM.board.moves[i])
                        } label: {
                            MoveView(move: chessboardVM.board.moves[i], i: i)
                                .variationStyle(isSelected: i == chessboardVM.board.moveI-1)
                        }
                            .padding(.trailing, ((i % 2) == 0) ? 4 : 8)
                    }
                }
                .padding(.horizontal, 5)
            }
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        
    }
    
    
    
    
}
