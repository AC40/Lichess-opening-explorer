//
//  ContentView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 28.05.22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm = ContentViewModel()
    
    var body: some View {
        Color.white
            .padding()
            .overlay(VStack {
                if vm.currentResponse != nil {
                    Text("White:  \(vm.currentResponse!.white)")
                    Text("Black: \(vm.currentResponse!.black)")
                    Text("Draw: \(vm.currentResponse!.draws)")
                }
            })
            .task {
                await vm.getPlayerGames()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
