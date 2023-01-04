//
//  OpeningExplorerView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import SwiftUI

struct OpeningExplorerView: View {
    
    @StateObject var vm = OpeningExplorerViewModel()
    @ObservedObject var chessboardVM: ChessboardViewModel
    
    var body: some View {
        VStack {
            Picker("", selection: $vm.dbType) {
                Text("Masters")
                    .tag(0)
                Text("Lichess")
                    .tag(1)
                Text("Player")
                    .tag(2)
            }
            
            MastersDBView(chessboardVM: chessboardVM)
        }
    }
}
