//
//  AnaylsisView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 22.12.22.
//

import SwiftUI

struct AnaylsisView: View {
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    @StateObject var vm = AnalysisViewModel()
    
    var timer = Timer.publish(every: 1, tolerance: 0.25,on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(alignment: .center) {
            
            if vm.noCache || vm.eval == nil {
                Text("No eval available")
            } else {
                Text(String(format: "%.02f", (Double(vm.eval!.pvs[0].cp) / 100)))
                    .font(.title3)
                
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 2, height: vm.idealViewHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                let moves = Convert.lichessMovesToMoves(vm.eval!.pvs[0].moves, on: chessboardVM.board)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(0..<moves.count) { i in
                            MoveView(move: moves[i], i: chessboardVM.board.currentMove + i, onClick: onClickMove)
                                .variationStyle(isSelected: false)
                        }
                    }
                }
                
            }
            
            
            analysisButton()
                    
        }
        .onReceive(timer, perform: { output in
            print("Running timer: \(output)")
//            if stopTimer {
//                timer.upstream.connect().cancel()
//                stopTimer = false
//                return
//            }
            
            if vm.analyze {
                fetchAnalysis()
            }
        })
    }
    
    @ViewBuilder func analysisButton() -> some View {
        Group {
            Button {
                vm.analyze.toggle()
            } label: {
                Image(systemName: vm.analyze ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                    .font(.title)
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            vm.idealViewHeight = geo.size.height-10
                        }
                        .onChange(of: geo.size.height) { newValue in
                            vm.idealViewHeight = geo.size.height-10
                        }
                }
            )
        }
    }
    
    /// Fetches the (potentially) cached analysis of the position from the lichess server
    func fetchAnalysis() {
        // check if data is available in cache
        let fen = NSString(string: chessboardVM.board.asFEN())
        
        if let cached = vm.cache.object(forKey: fen) {
            // Add to view
            vm.noCache = false
            vm.eval = cached.analysis
            print("Grabbed from cache")
            
            return
        }
        
        Task {
            
            do {
                // Fetch data
                let analysis = try await Networking.fetchCachedAnalysis(for: fen as String)
                print("Grabbed from Lichess cache")
                
                // Add to view
                vm.noCache = false
                vm.eval = analysis
                
                // Add to cache
                vm.cache.setObject(CacheCloudAnalysis(analysis: analysis), forKey: fen)
            } catch {
                print(error)
                vm.noCache = true
                vm.eval = nil
                return
            }
        }
        
    }
    
    /// This function starts or stops the timer, depending on what it's current state is
    func toggleTimer(with newValue: Bool) {
        if !newValue {
            vm.stopTimer = true
        }
//        else {
//            timer.upstream.connect()
//        }
    }
    
    func onClickMove(at i: Int) {
        //TODO: Make move at board (at end of current position
    }
}

