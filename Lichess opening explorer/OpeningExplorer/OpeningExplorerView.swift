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
    
    //    init(chessboardVM: ChessboardViewModel) {
    //        UITableView.appearance().backgroundColor = .red
    //        UITableViewCell.appearance().backgroundColor = .green
    //
    //        self.chessboardVM = chessboardVM
    //    }
    
    var body: some View {
        List {
            Section {
                if vm.db != nil {
                    // Moves played
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(vm.db!.moves.enumerated()), id:\.offset) { i, move in
                            MoveStatistics(move: move)
                                .frame(maxWidth: .infinity, idealHeight: 30, alignment: .leading)
                                .onTapGesture {
                                    onClickMove(at: i)
                                }
                        }
                    }
                    .padding(.bottom, 10)
                } else {
                    Text("Sorry. This we couldn't find moves in this position.")
                }
            } header: {
                HStack(alignment: .center) {
                    Marquee(text: vm.openingName())
                    // For some reason, the marquee's frame is ignored, so frame has to be set here. 20 is just an eyeball estimate, and it is not good that this is hardcoded. Ideally, it would calculate the text of a Text("Nq") with the background geo-reader "hack"
                    //                            .frame(height: 20)
                    
                    Picker("", selection: $vm.dbType) {
                        Text("Masters")
                            .tag(LichessDBType.masters)
                        Text("Lichess")
                            .tag(LichessDBType.lichess)
                        Text("Player")
                            .tag(LichessDBType.player)
                    }
                }
            }
            .listRowBackground(Color.clear)
            
            if let games = vm.db?.topGames {
                Section {
                    GameList(games: games)
                } header: {
                    Text("Top Games")
                }
                .listRowBackground(Color.clear)
            }
            
            if let games = vm.db?.recentGames {
                Section {
                    GameList(games: games)
                } header: {
                    Text("Recent Games")
                }
                .listRowBackground(Color.clear)
            }
            
        }
        .listStyle(.plain)
        .task {
            UITableView.appearance().backgroundColor = .red
            UITableViewCell.appearance().backgroundColor = .green
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
                    vm.db = try await Networking.fetchPlayerDB(for: "ac40", with: "white", from: chessboardVM.board.asFEN())
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
