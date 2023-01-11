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
        VStack(spacing: 0) {
                HStack(alignment: .center) {
            
                    Marquee(text: openingName())
                    // For some reason, the marquee's frame is ignored, so frame has to be set here. 20 is just an eyeball estimate, and it is not good that this is hardcoded. Ideally, it would calculate the text of a Text("Nq") with the background geo-reader "hack"
                        .frame(height: 25)
                    
                    Picker("", selection: $vm.dbType) {
                        Text("Masters")
                            .tag(0)
                        Text("Lichess")
                            .tag(1)
                        Text("Player")
                            .tag(2)
                    }
                }
            
            MastersDBView(chessboardVM: chessboardVM, opening: $vm.currentOpening)
        }
    }
    
    func openingName() -> String {
        var name = ""
        
        if vm.currentOpening.name != nil {
            name = vm.currentOpening.name!
            
            if vm.currentOpening.eco != nil {
                name.append(" (\(vm.currentOpening.eco!))")
            }
        }
        
        return name
    }
}
