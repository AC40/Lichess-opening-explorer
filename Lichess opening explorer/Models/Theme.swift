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
    var prevMove: Color
    var check: Color
    
    init(title: String, lightSquare: Color, darkSquare: Color, highlight: Color, prevMove: Color? = nil, check: Color = .red) {
        self.title = title
        self.lightSquare = lightSquare
        self.darkSquare = darkSquare
        self.highlight = highlight
        self.check = check
        
        if prevMove == nil {
            self.prevMove = highlight
        } else {
            self.prevMove = prevMove!
        }
    }
    
    static func == (lhs: Theme, rhs: Theme) -> Bool {
        return (lhs.title == rhs.title)
    }
}
