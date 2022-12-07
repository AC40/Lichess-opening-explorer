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
                ForEach(0..<chessboardVM.board.moves.count, id:\.self) { i in
                    
                    WrappingHStack(items: stringsFromMoves(chessboardVM.board.moves[i]))
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .padding(5)
        
    }
    
    func readableMove(_ move: Move, i: Int) -> AttributedString {
        
        // If move is divisible by 2 (white): Show move number + '.' + small space
        let moveNumber = "\(((i % 2) == 0) ? String(abs((i/2))+1) + ". ": "")"
        
        let moveNumberAttr = AttributedString(moveNumber, attributes: .init([NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        let move = AttributedString(Convert.moveToShortAlgebra(move))
        
        return moveNumberAttr + move
    }
    
    func stringsFromMoves(_ moves: [Move]) -> [AttributedString] {
        var strings: [AttributedString] = []
        
        for i in 0..<moves.count {
            strings.append(readableMove(moves[i], i: i))
        }
        
        return strings
    }
    
}
