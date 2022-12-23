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
    @State private var eval: Double = 0
    @State private var noCache = false
    @State private var startTimer = false
    @State private var stopTimer = false
    
    var timer = Timer.publish(every: 1, tolerance: 0.25,on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            
            if noCache {
                Text("No eval available")
            } else {
                Text(String(format: "%.02f", eval))
                    .font(.title3)
            }
            
            Spacer()
            Toggle("", isOn: $analyze)
                .onChange(of: analyze, perform: { newValue in
                    toggleTimer(with: newValue)
                })
                    
                
            
            Button("Analyze") {
                Task {
                    fetchAnalysis()
                }
            }
            .tint(.purple)
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
        }
        .onReceive(timer, perform: { output in
            print("Running timer: \(output)")
//            if stopTimer {
//                timer.upstream.connect().cancel()
//                stopTimer = false
//                return
//            }
            
            if analyze {
                fetchAnalysis()
            }
        })
        .task {
            fetchAnalysis()
        }
    }
    
    /// Fetches the (potentially) cached analysis of the position from the lichess server
    func fetchAnalysis() {
        Task {
            do {
                let cp = try await Networking.fetchCachesAnalysis(for: chessboardVM.board.asFEN()).pvs[0].cp
                noCache = false
                let res = Double(cp) / 100
                eval = res
            } catch {
                print(error)
                noCache = true
                return
            }
        }
        
    }
    
    /// This function starts or stops the timer, depending on what it's current state is
    func toggleTimer(with newValue: Bool) {
        if !newValue {
            stopTimer = true
        }
//        else {
//            timer.upstream.connect()
//        }
    }
}

