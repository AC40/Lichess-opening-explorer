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
    
    var body: some View {
        HStack(alignment: .center) {
            
            if vm.eval == nil {
                Text("No eval available")
            } else {
                Text(String(format: "%.02f", (Double(vm.eval!.pvs[0].cp) / 100)))
                    .font(.title3)
                
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 2, height: vm.idealViewHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Array(vm.playableMoves.enumerated()), id:\.offset) { i, move in
                            MoveView(move: move, i: chessboardVM.board.currentMove + i, onClick: onClickMove)
                                .variationStyle(isSelected: false)
                        }
                    }
                }
                
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 2, height: vm.idealViewHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            Spacer()
            
            analysisButton()
                    
        }
        // Request analysis when
        // ... a move is made
        .onChange(of: chessboardVM.board.moves, perform: { _ in
            fetchAnalysis()
        })
        // ... the user scrolls through the position
        .onChange(of: chessboardVM.board.currentMove, perform: { _ in
            fetchAnalysis()
        })
        // ... on intial load
        .task {
            fetchAnalysis()
        }
    }
    
    @ViewBuilder func analysisButton() -> some View {
        Group {
            Button {
                vm.analyze.toggle()
                fetchAnalysis()
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
        
        guard vm.analyze else {
            return
        }
        
        // check if data is available in cache
        let fen = NSString(string: chessboardVM.board.asFEN())
        
        if let cached = vm.cache.object(forKey: fen) {
            // Add to view
            vm.noCache = false
            vm.eval = cached.analysis
            vm.playableMoves = Convert.lichessMovesToMoves(cached.analysis.pvs[0].moves, on: chessboardVM.board)
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
                vm.playableMoves = Convert.lichessMovesToMoves(analysis.pvs[0].moves, on: chessboardVM.board)
                
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
    
    func onClickMove(at i: Int) {
        var startI = 0
        var moves = [Move]()
        
        while startI <= i-chessboardVM.board.currentMove {
            
            guard startI < vm.playableMoves.count else {
                return
            }
            
            moves.append(vm.playableMoves[startI])
            
            startI += 1
        }
        
        moves.forEach { move in
            chessboardVM.makeMove(move, strict: false)
        }
        fetchAnalysis()
    }
}

