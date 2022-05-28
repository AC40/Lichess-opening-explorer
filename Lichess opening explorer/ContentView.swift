//
//  ContentView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 28.05.22.
//

import SwiftUI
import Inject

struct ContentView: View {
    @ObserveInjection var inject
    
    @StateObject private var vm = ContentViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            
            Image("chessboard")
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            if vm.currentResponse != nil {
                List {
                    ForEach(0..<vm.currentResponse!.recentGames.count) { i in
                        
                        let game = vm.currentResponse!.recentGames[i]
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(game.white.name)
                                Text(String(game.white.rating))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text(" vs. ")
                            VStack(alignment: .leading) {
                                Text(game.black.name)
                                Text(String(game.black.rating))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(game.winner ?? "Draw")
                                .foregroundColor(foreColor(with: game.winner, at: i))
                                .padding(10)
                                .background(backColor(with: game.winner, at: i))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .listRowBackground((((i % 2) != 0)) ? Color.secondary : Color(uiColor: .tertiaryLabel))
                    }
                }
                .listStyle(.plain)
            } else {
                Text("No recent games could be found")
            }
        }
//        .background(Color.gray.edgesIgnoringSafeArea(.all))
        .task {
            await vm.getPlayerGames()
        }
        .enableInjection()
    }
    
    func foreColor(with winner: String?, at i: Int) -> Color {
        
        if let winner = winner {
            if winner == "white" {
                return Color.black
            } else {
                return Color.white
            }
        }
        
        return Color.white
        if (i % 2) != 0 {
            return Color(uiColor: .tertiaryLabel)
        } else {
            return Color(uiColor: .secondaryLabel)
        }
    }
    
    func backColor(with winner: String?, at i: Int) -> Color {
        
        if let winner = winner {
            if winner == "white" {
                return Color.white
            } else {
                return Color.black
            }
        }
        
        if (i % 2) != 0 {
            return Color(uiColor: .secondaryLabel)
        } else {
            return Color(uiColor: .tertiaryLabel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
