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
    
    var body: some View {
        NavigationStack {
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
                
                VStack(alignment: .leading) {
                    
                    HStack {
                        
                        Picker("View", selection: $vm.subView) {
                            Text("Variations")
                                .tag(0)
                            Text("Dev tools")
                                .tag(1)
                            
                        }
                        .pickerStyle(.segmented)
                        moveControls()
                    }
                    .padding(.horizontal, 5)
                    
                    switch vm.subView {
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
                .alert(isPresented: $vm.showFENAlert) {
                    Alert(title: Text("Current FEN String"), message: Text(chessboardVM.board.asFEN()), dismissButton: .default(Text("Okay")))
                }
            })
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(id: "settingsBtn", placement: .navigationBarTrailing) {
                    Button {
                        vm.showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .task {
            // Fetch player games
        }
        .sheet(isPresented: $vm.showSettings) {
            SettingsView()
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
                Button("Swap turn") {
                    chessboardVM.board.whiteTurn.toggle()
                    chessboardVM.board.squares.removeEnPassants()
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
                    chessboardVM.resetSelection()
                }
                
                Button("Promotion situation") {
                    chessboardVM.board.loadFEN("8/k1r1P2K/8/8/8/8/8/8 w - - 0 1")
                    chessboardVM.resetSelection()
                }
                Button("En passant into check") {
                    chessboardVM.board.loadFEN("r5nr/pppK1p1p/3p4/k3pPp1/8/6Pb/PPPPP2P/RNBQN2R w - g6 0 2")
                    chessboardVM.resetSelection()
                    
                }
                Button("Show FEN") {
                    vm.showFENAlert = true
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
    
    @ViewBuilder func moveControls() -> some View {
        HStack(spacing: 0) {
            Button {
                // unmake the most recent move in history
                if chessboardVM.board.moves.count > 0 {
                    
                    if chessboardVM.board.currentMove == 1 {
                        chessboardVM.board.loadDefaultFEN()
                        chessboardVM.board.currentMove = 0
                        return
                    }
                    chessboardVM.board.currentMove -= 1
                    chessboardVM.loadMove(chessboardVM.board.moves[chessboardVM.board.currentMove-1])
                }
            } label: {
                Image(systemName: "chevron.backward")
            }
            .disabled(!(chessboardVM.board.currentMove > 0))
            
            Button {
                // progress one move forward in move history
                if chessboardVM.board.moves.count > chessboardVM.board.currentMove {
                    chessboardVM.loadMove(chessboardVM.board.moves[chessboardVM.board.currentMove])
                    chessboardVM.board.currentMove += 1
                }
                
            } label: {
                Image(systemName: "chevron.forward")
            }
            .disabled(!(chessboardVM.board.moves.count > chessboardVM.board.currentMove))
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 0))
        .tint(.purple)
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
