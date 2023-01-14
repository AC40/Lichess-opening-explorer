//
//  GameList.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 14.01.23.
//

import SwiftUI

struct GameList: View {
    
    var games: [LichessGame]
    
    var body: some View {
        ForEach(games, id:\.id) { game in
            HStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(String(game.white.rating))
                        Text(String(game.black.rating))
                    }
                            .foregroundColor(.secondary)
                    VStack(alignment: .leading) {
                        Text(game.white.name)
                        Text(game.black.name)
                    }
                }
                
                Spacer()
                
            }
        }
    }
}

