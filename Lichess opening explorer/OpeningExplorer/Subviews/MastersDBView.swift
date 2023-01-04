//
//  MastersDBView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import SwiftUI

struct MastersDBView: View {
    
    @ObservedObject var chessboardVM: ChessboardViewModel
    
    @State private var db: MastersDBResponse? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                if db != nil {
                    Text(db?.opening?.eco ?? "No opening found")
                    ForEach(Array(db!.moves.enumerated()), id:\.offset) { i, move in
                        MoveStatistics(masterMove: move)
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
        // Request analysis when
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
    
    func fetchDBData() {
        Task {
            do {
                db = try await Networking.fetchMasterDB(from: chessboardVM.board.asFEN())
            } catch {
                print(error)
                db = nil
            }
        }

    }
    
    func onClickMove(at i: Int) {
        
        guard db != nil else {
            return
        }
        
        let san = db!.moves[i].uci
        let move = Convert.sanToMove(san)
        
        guard move != nil else {
            return
        }
        
        chessboardVM.makeMove(move!, strict: false)
    }
}

