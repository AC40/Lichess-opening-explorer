//
//  MoveView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 23.12.22.
//

import SwiftUI

struct MoveView: View {
    
    var move: Move
    var i: Int
    var onClick: (Int) -> Void
    
    var body: some View {
        Button {
            onClick(i)
        } label: {
            Text(readableMove(move, i: i))
        }
    }
    
    
    func readableMove(_ move: Move, i: Int) -> AttributedString {
        
        // If move is divisible by 2 (white): Show move number + '.' + small space
        let moveNumber = "\(((i % 2) == 0) ? String(abs((i/2))+1) + ". ": "")"
        
        let moveNumberAttr = AttributedString(moveNumber, attributes: .init([NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        let move = AttributedString(Convert.moveToShortAlgebra(move))
        
        return moveNumberAttr + move
    }
}
