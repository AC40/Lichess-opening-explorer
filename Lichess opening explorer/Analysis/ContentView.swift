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
    @StateObject private var themeMg = ThemeManager()
    
    @State private var subView: Int = 0
    
    @State private var databaseType = DatabaseType.player
    
    var body: some View {
        AdaptiveStack(content: {
            
            Chessboard(vm: chessboardVM, themeMg: themeMg)
                .zIndex(10)
                .overlay(
                    Group {
                        if chessboardVM.board.termination != .none {
                            gameTerminationOverlay()
                        }
                    }
                )
            
            VStack {
                
                Picker("View", selection: $subView) {
                    Text("Variations")
                        .tag(0)
                    Text("Dev tools")
                        .tag(1)
                    
                }
                .pickerStyle(.segmented)
                
                switch subView {
                case 0:
                    VariationView(chessboardVM: chessboardVM)
                case 1:
                    ScrollView {
                        buttonList()
                            .padding()
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.roundedRectangle)
                            .tint(.pink)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .zIndex(8)
                default:
                    VariationView(chessboardVM: chessboardVM)
                }
                
                
                
            }
            
        })
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
                Button("Toggle Coordinates") {
                    chessboardVM.showCoordinates.toggle()
                }
                Button("Swap Theme") {
                    if themeMg.current == Themes.standard {
                        themeMg.current = Themes.chessCom
                    } else {
                        themeMg.current = Themes.standard
                    }
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
                    chessboardVM.board.squares.removeEnPassants()
                }
                Button("Promote Pawns") {
                    chessboardVM.board.loadFEN("8/PPPPPPPP/8/8/8/8/pppppppp/8 w - - 0 1")
                }
                Button("Castling") {
                    chessboardVM.board.loadFEN("r3k2r/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/R3K2R b KQkq - 0 1")
                }
                Button("Stalemate") {
                    chessboardVM.board.loadFEN("8/7k/7p/p6P/P7/8/4K1R1/8 w - - 0 1")
                }
            }
        }
    }
    
    
    @ViewBuilder func gameTerminationOverlay() -> some View {
        
        VStack {
            Group {
                switch chessboardVM.board.termination {
                case .checkmate:
                    Text("You Won! ... or lost :(")
                    
                case .stalemate:
                    Text("Draw. Are you both GMs or what?")
                case .fiftyMoveRule:
                    Text("Draw. Did you forget how to mate w/Knight + Bishop?")
                case .none:
                    Text("Error. Something went wrong")
                default:
                    Text("The game ended")
                }
            
            }
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
