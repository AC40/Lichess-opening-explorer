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
        VStack {
            HStack {
                ForEach(0..<chessboardVM.board.moves.count, id:\.self) { i in
                    ForEach(0..<chessboardVM.board.moves[i].count, id:\.self) { j in
                        var move = chessboardVM.board.moves[i][j]
                        Text("\(move.start.rank),\(move.start.file) - \(move.end.rank),\(move.end.file) ")
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

//struct VariationView_Previews: PreviewProvider {
//    static var previews: some View {
//        VariationView()
//    }
//}
