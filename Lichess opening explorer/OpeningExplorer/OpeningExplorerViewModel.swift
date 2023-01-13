//
//  OpeningExplorerViewModel.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import SwiftUI

class OpeningExplorerViewModel: ObservableObject {
    
    @Published var dbType: LichessDBType = LichessDBType.stringToType(UserDefaults.standard.string(forKey: "selectedDBType") ?? "lichess") {
        didSet {
            saveDBType()
        }
    }
    
    @Published var currOpening: LichessOpening = .none {
        willSet {
            if currOpening != .none {
                prevOpening = currOpening
            }
        }
    }
    
    @Published var prevOpening: LichessOpening = .none
    
    func saveDBType() {
        UserDefaults.standard.set(dbType.rawValue, forKey: "selectedDBType")
    }
}
