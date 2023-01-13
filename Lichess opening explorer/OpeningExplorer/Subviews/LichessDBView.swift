//
//  LichessDBView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 12.01.23.
//

import SwiftUI

struct LichessDBView: View {
    
    var dbType: LichessDBType
    @ObservedObject var chessboardVM: ChessboardViewModel
    @Binding var opening: LichessOpening
    
    @State private var db: LichessDBResponse? = nil {
        didSet {
            opening = db?.opening ?? LichessOpening(eco: nil, name: nil)
        }
    }
    @State private var unavailabe = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if unavailabe {
                    Text("This feature is currently unavailable. Sorry :(")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if db != nil {
                    ForEach(Array(db!.moves.enumerated()), id:\.offset) { i, move in
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
        // Request analysis when
        // ... the selected dbType changes
        .onChange(of: dbType, perform: { newValue in
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
            
            let type = newType ?? dbType
            
            do {
                unavailabe = false
                
                switch type {
                case .lichess:
                    db = try await Networking.fetchLichessDB(from: chessboardVM.board.asFEN())
                case .masters:
                    db = try await Networking.fetchMasterDB(from: chessboardVM.board.asFEN())
                case .player:
                    unavailabe = true
                    db = nil
                }
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
