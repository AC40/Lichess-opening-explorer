//
//  Chessboard.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

struct Chessboard: View {
    
    @StateObject private var vm = ChessboardViewModel()
    @StateObject private var foo = ChessboardViewModel()
    
    var body: some View {
        
        ZStack {
            
            Color.teal
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                LazyVGrid(columns: vm.layout, spacing: 0) {
                    ForEach(0..<64) { i in
                        
                        SquareView(chessboardVM: vm, i: i)
                    }
                }
                LazyVGrid(columns: vm.layout, spacing: 0) {
                    ForEach(0..<64) { i in
                        PieceView(chessboardVM: vm, i: i)
                            
                    }
                }
            }
            Button("Load") {
                vm.squares.loadFEN("r1bq3r/4bppp/p1npkB2/1p1Np3/4P3/N3K3/PPP2PPP/R2Q1B1R b - - 4 12")
            }
        }
    }
}

struct Chessboard_Previews: PreviewProvider {
    static var previews: some View {
        Chessboard()
            .previewInterfaceOrientation(.portrait)
    }
}
