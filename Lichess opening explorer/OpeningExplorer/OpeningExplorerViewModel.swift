//
//  OpeningExplorerViewModel.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import SwiftUI

class OpeningExplorerViewModel: ObservableObject {
    
    @Published var db: LichessDBResponse? = nil {
        willSet {
            if let opening = db?.opening {
                prevOpening = opening
            }
        }
    }
    
    @Published var dbType: LichessDBType = LichessDBType.stringToType(UserDefaults.standard.string(forKey: "selectedDBType") ?? "lichess") {
        didSet {
            saveDBType()
        }
    }
    
    @Published var prevOpening: LichessOpening = .none
    @Published var unavailabe = false
    @Published var loading = false 
    
    //MARK: Functions
    
    func saveDBType() {
        UserDefaults.standard.set(dbType.rawValue, forKey: "selectedDBType")
    }
    
    func openingName() -> String {
        var name = ""
        
        // Check if an opening is recognized for the current position
        if db != nil {
            
            if db!.opening != nil {
                
                if db!.opening!.name != nil {
                    name = db!.opening!.name!
                }
                
                if db!.opening!.eco != nil {
                    name.append(" (\(db!.opening!.eco!))")
                }
            }
        }
            
        // If current opening is nil, check if an opening was recognized before
        if name == "" {
            if prevOpening.name != nil {
                name = prevOpening.name!
                
                if prevOpening.eco != nil {
                    name.append(" (\(prevOpening.eco!))")
                }
            }
        }
        
        return name
    }
}
