//
//  Chessboard.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

struct Chessboard: View {
    
    @ObservedObject var vm: ChessboardViewModel
//    @StateObject private var vm = ChessboardViewModel()
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
        }
    }
}

