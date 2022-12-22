//
//  MoveView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 22.12.22.
//

import SwiftUI

struct MoveView: View {
    
    var move: Move
    let i: Int
    
    var body: some View {
        Group {
            Text(readableMove(move, i: i))
            if move.variations != nil {
                ForEach(0..<move.variations!.count) { j in
                    Text("(")
                    ForEach(move.variations![j]) { varMove in
                        Text(readableMove(varMove, i: i+j))
                    }
                    Text(")")
                }
            }
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

struct MoveView_Previews: PreviewProvider {
    static var previews: some View {
        MoveView(move: Move(from: Tile(6, 4), to: Tile(4, 4), piece: .pawnW, capture: nil, flag: .move, termination: .none, check: false, position: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 1", variations: [[Move(from: Tile(6, 3), to: Tile(4, 3), flag: .move), Move(from: Tile(1, 3), to: Tile(3, 3), flag: .move), Move(from: Tile(6, 2), to: Tile(4, 2), flag: .move)], [Move(from: Tile(6, 3), to: Tile(4, 3), flag: .move), Move(from: Tile(1, 3), to: Tile(3, 3), flag: .move), Move(from: Tile(6, 2), to: Tile(4, 2), flag: .move)]]), i: 0)
    }
}
