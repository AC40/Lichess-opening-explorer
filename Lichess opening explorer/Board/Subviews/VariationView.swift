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
                            chessboardVM.board.currentMove = i+1
                            chessboardVM.undoMove(chessboardVM.board.moves[i])
                        } label: {
                            Text(readableMove(chessboardVM.board.moves[i], i: i))
                                .variationStyle(isSelected: i == chessboardVM.board.currentMove-1)
                        }
                            .padding(.trailing, ((i % 2) == 0) ? 4 : 8)
                    }
                }
                .padding(.horizontal, 5)
            }
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        
    }
    
    func readableMove(_ move: Move, i: Int) -> AttributedString {
        
        // If move is divisible by 2 (white): Show move number + '.' + small space
        let moveNumber = "\(((i % 2) == 0) ? String(abs((i/2))+1) + ". ": "")"
        
        let moveNumberAttr = AttributedString(moveNumber, attributes: .init([NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        let move = AttributedString(Convert.moveToShortAlgebra(move))
        
        return moveNumberAttr + move
    }
    
    
}
