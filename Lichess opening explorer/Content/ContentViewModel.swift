//
//  ContentViewModel.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 28.05.22.
//

import Foundation

@MainActor
class ContentViewModel: ObservableObject {
    
    @Published var subView: Int = 0
    @Published var showFENAlert = false
    @Published var showSettings = false

    @Published var databaseType = DatabaseType.player
    
    @Published var pickerHeight: CGFloat = .zero
    
    /* For later implementation:
        @Published var currentResponse: PlayerDBResponse?
        
        func getPlayerGames() async {
            
            do {
                currentResponse = try await Networking.fetchPlayerGames(for: "e2e4,e7e5,b1c3")
            } catch {
                print(error)
            }
        }
     */
}
