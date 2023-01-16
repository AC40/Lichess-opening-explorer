//
//  VariationView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.12.22.
//

import SwiftUI

struct VariationView: View {
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    
    var pickerHeight: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                WrappingHStack {
                    ForEach(0..<chessboardVM.board.moves.count, id:\.self) { i in
                        MoveView(move: chessboardVM.board.moves[i], i: i, onClick: didClickMove)
                            .variationStyle(isSelected: i == chessboardVM.board.currentMove-1)
                            .padding(.trailing, ((i % 2) == 0) ? 4 : 8)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, pickerHeight + 10)
            }
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        
    }
    
    func didClickMove(at i: Int) {
        chessboardVM.board.currentMove = i+1
        chessboardVM.loadMove(chessboardVM.board.moves[i])
    }
    
}
