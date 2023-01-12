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
            
            switch vm.dbType {
            case 0:
                MastersDBView(chessboardVM: chessboardVM, opening: $vm.currOpening)
            case 1:
                LichessDBView(chessboardVM: chessboardVM, opening: $vm.currOpening)
            default:
                Text("Currently not supported")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
    
    func openingName() -> String {
        var name = ""
        
        // Check if an opening is recognized for the current position
        if vm.currOpening.name != nil {
            name = vm.currOpening.name!
            
            if vm.currOpening.eco != nil {
                name.append(" (\(vm.currOpening.eco!))")
            }
        }
        
        // If current opening is nil, check if an opening was recognized before
        if name == "" {
            if vm.prevOpening.name != nil {
                name = vm.prevOpening.name!
                
                if vm.prevOpening.eco != nil {
                    name.append(" (\(vm.prevOpening.eco!))")
                }
            }
        }
        
        return name
    }
}
