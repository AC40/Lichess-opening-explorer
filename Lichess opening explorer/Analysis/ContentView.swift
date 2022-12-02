//
//  ContentView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 28.05.22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm = ContentViewModel()
    @StateObject private var chessboardVM = ChessboardViewModel()
    
    @State private var databaseType = DatabaseType.player
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
            Chessboard(vm: chessboardVM)
                .zIndex(10)
                .overlay(
                    Group {
                        if chessboardVM.board.checkmate {
                            gameEndScreen()
                        }
                    }
                )
            
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
    }
    
    //MARK: View-related functions
    @ViewBuilder func buttonList() -> some View {
        HStack(alignment: .center, spacing: 10) {
            
            VStack(alignment: .leading) {
                Text("Load Position:")
                    .font(.headline)
                
                Button("Checkmate") {
                    chessboardVM.board.loadFEN("r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 0 1")
                }
                Button("Swap perspective") {
                    chessboardVM.whitePerspective.toggle()
                }
            }
            Spacer()
            
            VStack(alignment: .trailing, spacing: 10) {
                Button("Load default FEN") {
                    chessboardVM.board.loadDefaultFEN()
                }
                
                Button("Load mid-game FEN") {
                    chessboardVM.board.loadFEN("r1bq3r/4bppp/p1npkB2/1p1Np3/4P3/N3K3/PPP2PPP/R2Q1B1R b - - 4 1")
                }
                Button("Switch turn") {
                    chessboardVM.board.whiteTurn.toggle()
                }
                Button("Promote Pawns") {
                    chessboardVM.board.loadFEN("8/PPPPPPPP/8/8/8/8/pppppppp/8 w - - 0 1")
                }
                Button("Castling") {
                    chessboardVM.board.loadFEN("r3k2r/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/R3K2R b KQkq - 0 1")
                }
                Button("Prevent Castling") {
                    chessboardVM.board.loadFEN("rn2k2r/pppp1ppp/8/1b2p3/1B2P3/8/PPPP1PPP/RN2K2R w KQkq - 0 1")
                }
            }
        }
    }
    
    
    @ViewBuilder func gameEndScreen() -> some View {
        VStack {
            Text("You Won! ... or lost :(")
                .font(.title2)
                .foregroundColor(.white)
                .padding(.bottom, 20)
            Button("Rematch") {
                chessboardVM.board.loadDefaultFEN()
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
            .tint(.teal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.black.opacity(0.75))
    }
    
    //MARK: Internal functions
    func loadPosition(for piece: PieceType) {
        switch piece {
        case .none:
            break
        case .king:
            chessboardVM.board.loadFEN("8/8/8/5k2/8/2K5/8/8 w - - 0 1")
        case .queen:
            chessboardVM.board.loadFEN("8/8/8/5q2/8/2Q5/8/8 w - - 0 1")
        case .rook:
            chessboardVM.board.loadFEN("8/8/8/5r2/8/2R5/8/8 w - - 0 1")
        case .bishop:
            chessboardVM.board.loadFEN("8/8/8/5b2/8/2B5/8/8 w - - 0 1")
        case .knight:
            chessboardVM.board.loadFEN("8/8/8/5n2/8/2N5/8/8 w - - 0 1")
        case .pawn:
            chessboardVM.board.loadFEN("8/8/8/5p2/8/2P5/8/8 w - - 0 1")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
