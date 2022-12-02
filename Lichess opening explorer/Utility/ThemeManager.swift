//
//  ThemeManager.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 02.12.22.
//

import Foundation

class ThemeManager: ObservableObject {
    
    @Published var current: Theme
    
    init() {
        self.current = Themes.standard
    }
}
