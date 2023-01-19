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
    
    var pickerHeight: CGFloat
    
    var body: some View {
        List {
            Section {
                Group {
                    if vm.db != nil {
                        // Moves played
                        MoveList(moves: vm.db!.moves, didClick: onClickMove)
                            .padding(.bottom, 10)
                        
                        if let games = vm.db?.topGames {
                            if !games.isEmpty {
                                Text("Top Games")
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                GameList(games: games)
                            }
                        }
                        if let games = vm.db?.recentGames {
                            if !games.isEmpty {
                                Text("Recent Games")
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                GameList(games: games)
                            }
                        }
                    } else {
                        Text("Sorry. This we couldn't find moves in this position.")
                    }
                    
                   
                }
                .disabled(vm.loading)
                
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
                    .padding(.top, pickerHeight-10)
            }
            .listRowBackground(Color.clear)
            
        }
        .overlay(loadingOverlay())
        .listStyle(.plain)
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
    
    @ViewBuilder func loadingOverlay() -> some View {
        Group {
            //TODO: Fix weir bug where multiple overlays appear
            if vm.loading {
                ProgressView()
                    .padding(30)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            }
        }
    }
    func fetchDBData(for newType: LichessDBType? = nil) {
        
        vm.loading = true
        //Potential: Delay showing overlay slightly (0.3 seconds) incase load time is very fast. That way there would be no flashing. Disadvantage: Inconsitency and seeming delay
        
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
                
                vm.loading = false
            } catch {
                print(error)
                vm.db = nil
                vm.loading = false
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
