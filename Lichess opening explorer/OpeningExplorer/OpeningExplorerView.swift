//
//  OpeningExplorerView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import SwiftUI

struct OpeningExplorerView: View {
    
    @StateObject var vm = OpeningExplorerViewModel()
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Marquee(text: vm.openingName())
                    // For some reason, the marquee's frame is ignored, so frame has to be set here. 20 is just an eyeball estimate, and it is not good that this is hardcoded. Ideally, it would calculate the text of a Text("Nq") with the background geo-reader "hack"
                        .frame(height: 20)
                    
                    Picker("", selection: $vm.dbType) {
                        Text("Masters")
                            .tag(LichessDBType.masters)
                        Text("Lichess")
                            .tag(LichessDBType.lichess)
                        Text("Player")
                            .tag(LichessDBType.player)
                    }
                }
                
                if vm.dbType == .player {
                    if vm.playerDB != nil {
                        ForEach(Array(vm.playerDB!.moves.enumerated()), id:\.offset) { i, move in
                            Text(String(move.averageOpponentRating))
                                .frame(maxWidth: .infinity, idealHeight: 30, alignment: .leading)
                                .onTapGesture {
                                    onClickMove(at: i)
                                }
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        if vm.db != nil {
                            ForEach(Array(vm.db!.moves.enumerated()), id:\.offset) { i, move in
                                MoveStatistics(move: move)
                                    .frame(maxWidth: .infinity, idealHeight: 30, alignment: .leading)
                                    .onTapGesture {
                                        onClickMove(at: i)
                                    }
                            }
                        } else {
                            Text("Sorry. This we couldn't find moves in this position.")
                        }
                        
                    }
                }
                
            }
            .padding(.horizontal, 20)
        }
        // Request analysis when
        // ... the selected dbType changes
        .onChange(of: vm.dbType, perform: { newValue in
            fetchDBData(for: newValue)
        })
        // ... a move is made
        .onChange(of: chessboardVM.board.moves, perform: { _ in
            fetchDBData()
        })
        // ... the user scrolls through the position
        .onChange(of: chessboardVM.board.currentMove, perform: { _ in
            fetchDBData()
        })
        // ... on intial load
        .task {
            fetchDBData()
        }
    }
    
    func fetchDBData(for newType: LichessDBType? = nil) {
        Task {
            
            let type = newType ?? vm.dbType
            
            do {
                vm.unavailabe = false
                
                switch type {
                case .lichess:
                    vm.db = try await Networking.fetchLichessDB(from: chessboardVM.board.asFEN())
                case .masters:
                    vm.db = try await Networking.fetchMasterDB(from: chessboardVM.board.asFEN())
                case .player:
                    vm.playerDB = try await Networking.fetchPlayerDB(for: "ac40", with: "white", from: chessboardVM.board.asFEN())
                }
            } catch {
                print(error)
                vm.db = nil
            }
        }

    }
    
    func onClickMove(at i: Int) {
        
        guard vm.db != nil else {
            return
        }
        
        let san = vm.db!.moves[i].uci
        let move = Convert.sanToMove(san)
        
        guard move != nil else {
            return
        }
        
        chessboardVM.makeMove(move!, strict: false)
    }
}
