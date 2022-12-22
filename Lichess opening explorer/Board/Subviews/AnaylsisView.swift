//
//  AnaylsisView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 22.12.22.
//

import SwiftUI

struct AnaylsisView: View {
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    
    @State private var analyze = false
    @State private var eval: Double = 4
    @State private var noCache = false
    
    var body: some View {
        HStack {
            
            if noCache {
                Text("No eval available")
            } else {
                Text(String(format: "%.02f", eval))
                    .font(.title3)
            }
            
            Spacer()
//            Toggle("", isOn: $analyze)
//                .onTapGesture {
//                    fetchContinuesly()
//                }
            
            Button("Analyze") {
                Task {
                    eval = await fetchAnalysis()
                }
            }
            .tint(.purple)
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
        }
        .task {
            eval = await fetchAnalysis()
        }
    }
    
    func fetchAnalysis() async -> Double {
        do {
            let cp = try await Networking.fetchCachesAnalysis(for: chessboardVM.board.asFEN()).pvs[0].cp
            noCache = false
            return Double(cp) / 100
        } catch {
            print(error)
            noCache = true
            return 0
        }
    }
    
    func fetchContinuesly() {
        let timer = Timer(timeInterval: 1, repeats: analyze) { _ in
            Task {
                print("a")
                do {
                    print("b")
                    let cp = try await Networking.fetchCachesAnalysis(for: chessboardVM.board.asFEN()).pvs[0].cp
                    noCache = false
                    eval = Double(cp) / 100
                    print("Did in timer")
                } catch {
                    print(error)
                    return
                }
            }
            
        }
        
        timer.fire()
    }
}

