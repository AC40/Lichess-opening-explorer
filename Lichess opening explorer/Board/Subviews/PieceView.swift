//
//  PieceView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 30.05.22.
//

import SwiftUI

struct PieceView: View {
    
    var piece: Piece
    
    var body: some View {
        Image(piece.rawValue)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
    }
}

struct PieceView_Previews: PreviewProvider {
    static var previews: some View {
        PieceView(piece: .kingW)
    }
}
