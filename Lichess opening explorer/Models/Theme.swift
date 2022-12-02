//
//  Theme.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 02.12.22.
//

import SwiftUI

struct Theme: Equatable {
    var title: String
    
    var lightSquare: Color
    var darkSquare: Color
    
    var highlight: Color
    var check: Color
    
    init(title: String, lightSquare: Color, darkSquare: Color, highlight: Color, check: Color = .red) {
        self.title = title
        self.lightSquare = lightSquare
        self.darkSquare = darkSquare
        self.highlight = highlight
        self.check = check
    }
    
    static func == (lhs: Theme, rhs: Theme) -> Bool {
        return (lhs.title == rhs.title)
    }
}
