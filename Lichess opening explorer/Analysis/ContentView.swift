//
//  ContentView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 28.05.22.
//

import SwiftUI
import Inject

struct ContentView: View {
    @ObserveInjection var inject
    
    @StateObject private var vm = ContentViewModel()
    @StateObject private var chessboardVM = ChessboardViewModel()
    
    @State private var databaseType = DatabaseType.player
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
            Chessboard(vm: chessboardVM)
                .zIndex(10)
            
            Picker("", selection: $databaseType) {
                Text("OTB")
                    .tag(DatabaseType.otb)
                Text("Lichess")
                    .tag(DatabaseType.lichess)
                Text("Player")
                    .tag(DatabaseType.player)
            }
            .pickerStyle(.segmented)
            .zIndex(9)
            
            ScrollView {
                buttonList()
                    .padding()
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)
                    .tint(.pink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .zIndex(8)
        }
        .task {
            await vm.getPlayerGames()
        }
        .enableInjection()
    }
    
    //MARK: View-related functions
    @ViewBuilder func buttonList() -> some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading) {
                Text("Load Position:")
                    .font(.headline)
                
                Button("with Bishops") {
                    loadPosition(for: .bishop)
                }
                
                Button("with Rooks") {
                    loadPosition(for: .rook)
                }
                
                Button("with Knights") {
                    loadPosition(for: .knight)
                }
                
                Button("with Pawns") {
                    loadPosition(for: .pawn)
                }
                
                Button("with Kings") {
                    loadPosition(for: .king)
                }
                
                Button("with Queens") {
                    loadPosition(for: .queen)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 10) {
                Button("Load default FEN") {
                    chessboardVM.squares.loadDefaultFEN()
                }
                
                Button("Load mid-game FEN") {
                    chessboardVM.squares.loadFEN("r1bq3r/4bppp/p1npkB2/1p1Np3/4P3/N3K3/PPP2PPP/R2Q1B1R b - - 4 1")
                }
                Button("Switch turn") {
                    chessboardVM.whiteTurn.toggle()
                }
                Button("Promote Pawns") {
                    chessboardVM.squares.loadFEN("8/PPPPPPPP/8/8/8/8/pppppppp/8 w - - 0 1")
                }
            }
        }
    }
    
    //MARK: Internal functions
    func loadPosition(for piece: PieceType) {
        switch piece {
        case .none:
            break
        case .king:
            chessboardVM.squares.loadFEN("8/8/8/5k2/8/2K5/8/8 w - - 0 1")
        case .queen:
            chessboardVM.squares.loadFEN("8/8/8/5q2/8/2Q5/8/8 w - - 0 1")
        case .rook:
            chessboardVM.squares.loadFEN("8/8/8/5r2/8/2R5/8/8 w - - 0 1")
        case .bishop:
            chessboardVM.squares.loadFEN("8/8/8/5b2/8/2B5/8/8 w - - 0 1")
        case .knight:
            chessboardVM.squares.loadFEN("8/8/8/5n2/8/2N5/8/8 w - - 0 1")
        case .pawn:
            chessboardVM.squares.loadFEN("8/8/8/5p2/8/2P5/8/8 w - - 0 1")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
