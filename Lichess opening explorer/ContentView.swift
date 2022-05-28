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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
