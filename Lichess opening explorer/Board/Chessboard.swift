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
                        
                        let rank = i / 8
                        let file = i % 8
                        
                        Rectangle()
                            .foregroundColor((((rank + file) % 2) == 0) ? vm.colorLight : vm.colorDark)
                            .aspectRatio(1, contentMode: .fill)
                            .overlay(
                                Group {
                                    if vm.squares[i].isLegal {
                                        Circle()
                                            .foregroundColor(.teal.opacity(0.8))
                                            .padding()
                                    }
                                }
                            )
                            .onTapGesture {
                                vm.select(i)
                            }
                        
                    }
                }
                LazyVGrid(columns: vm.layout, spacing: 0) {
                    ForEach(0..<64) { i in
                        PieceView(chessboardVM: vm, i: i)
                            .onTapGesture {
                                vm.select(i)
                            }
                    }
                }
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
