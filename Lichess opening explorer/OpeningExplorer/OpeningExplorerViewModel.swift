//
//  OpeningExplorerViewModel.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import SwiftUI

class OpeningExplorerViewModel: ObservableObject {
    
    @AppStorage("selectedDBType") var dbType: Int = 0
    
    @Published var currOpening: LichessOpening = .none {
        willSet {
            if currOpening != .none {
                prevOpening = currOpening
            }
        }
    }
    
    @Published var prevOpening: LichessOpening = .none
}
