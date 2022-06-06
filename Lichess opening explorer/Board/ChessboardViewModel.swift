//
//  ChessboardViewModel.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

class ChessboardViewModel: ObservableObject {
    
    @Published var squares = Array(repeating: Square(), count: 64)
    @Published var selectedSquare: Int? = nil
    
    @Published var whiteTurn = true
    
    let colorLight = Color(red: 235/255, green: 217/255, blue: 184/255)
    let colorDark = Color(red: 172/255, green: 136/255, blue: 104/255)
    let foo = Color.green
    
    let layout = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    init() {
        squares.loadDefaultFEN()
    }
    
    func movePiece(from start: Int, to end: Int) {
        
        let piece = squares[start].piece
        squares[start].piece = Piece.none
        squares[end].piece = piece
    }
    
    func select(_ i: Int) {
        
        if whiteTurn {
            guard squares[i].piece.color == .white else {
                return
            }
            
            
        }
    }
}
