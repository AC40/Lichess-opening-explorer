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
                HStack(spacing: 10) {
                    
                    if let speed = game.speed {
                        Image(systemName: speed.icon())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(String(game.white.rating))
                        Text(String(game.black.rating))
                    }
                    .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading) {
                        Text(game.white.name)
                            .foregroundColor(game.winner == .white ? .gold : .primary)
                        Text(game.black.name)
                            .foregroundColor(game.winner == .black ? .gold : .primary)
                    }
                }
                
                Spacer()
                
                switch game.winner {
                case .white:
                    Text("1 - 0")
                case .black:
                    Text("0 - 1")
                case .none:
                    Text("1/2 - 1/2")
                }
                
            }
        }
    }
}

