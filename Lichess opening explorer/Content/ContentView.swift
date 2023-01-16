//
//  ContentView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 28.05.22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: Settings
    
    @StateObject private var vm = ContentViewModel()
    @StateObject private var chessboardVM = ChessboardViewModel()
    @StateObject private var themeMg = ThemeManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color(uiColor: .systemGray6)
                    .edgesIgnoringSafeArea(.all)
                
                AdaptiveStack(spacing: 0, content: {
                    
                    Chessboard(vm: chessboardVM, themeMg: themeMg)
                        .zIndex(10)
                        .overlay(
                            Group {
                                if chessboardVM.board.termination != .none {
                                    gameTerminationOverlay()
                                }
                            }
                        )
                    
                    ZStack(alignment: .topLeading) {
                        
                        switch vm.subView {
                        case 0:
                            VariationView(chessboardVM: chessboardVM, pickerHeight: vm.pickerHeight)
                        case 1:
                            ScrollView {
                                buttonList()
                                    .padding()
                                    .buttonStyle(.bordered)
                                    .buttonBorderShape(.roundedRectangle)
                                    .tint(.pink)
                                    .padding(.top, vm.pickerHeight)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        case 2:
                            OpeningExplorerView(chessboardVM: chessboardVM, pickerHeight: vm.pickerHeight)
                            
                        default:
                            VariationView(chessboardVM: chessboardVM, pickerHeight: vm.pickerHeight)
                        }
                        
//                        AnaylsisView(chessboardVM: chessboardVM)
                        HStack {
                            
                            Picker("View", selection: $vm.subView) {
                                Text("Openings")
                                    .tag(2)
                                Text("Variations")
                                    .tag(0)
                                Text("Dev tools")
                                    .tag(1)
                                
                            }
                            .pickerStyle(.segmented)
                            moveControls()
                        }
                        .padding(10)
                        .background(Group {
                            if vm.subView == 2 {
                                EmptyView()
                            } else {
                                Rectangle()
                                    .fill(.regularMaterial)
                            }
                        })
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        vm.pickerHeight = geo.size.height
                                    }
                            }
                        )
                    }
                    .alert(isPresented: $vm.showFENAlert) {
                        Alert(title: Text("Current FEN String"), message: Text(chessboardVM.board.asFEN()), dismissButton: .default(Text("Okay")))
                    }
                })
            }
            
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
                
                Button("Load mid-game FEN") {
                    chessboardVM.board.loadFEN("r4rk1/pp1qppbp/3p2p1/2pP4/4P3/P2P2P1/1P1B1PKP/1R1Q1R2 b - - 0 19")
                    chessboardVM.resetSelection()
                }
                Button("Switch turn") {
                    chessboardVM.board.whiteTurn.toggle()
                    chessboardVM.board.squares.removeEnPassants()
                }
                Button("FEN w/ e.p.") {
                    chessboardVM.board.loadFEN("rnbqkbnr/ppp1p1pp/8/3pPp2/8/8/PPPP1PPP/RNBQKBNR w KQkq f6 0 3")
                    chessboardVM.resetSelection()
                }
                Button("Castling") {
                    chessboardVM.board.loadFEN("r3k2r/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/R3K2R b KQkq - 0 1")
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
                    
                    withAnimation(settings.movePieceAnimation()) {
                        if chessboardVM.board.currentMove == 1 {
                            chessboardVM.board.loadDefaultFEN()
                            chessboardVM.board.currentMove = 0
                            return
                        }
                        chessboardVM.unmakeMove(chessboardVM.board.moves[chessboardVM.board.currentMove-1])
                    }
                }
            } label: {
                Image(systemName: "chevron.backward")
            }
            .disabled(!(chessboardVM.board.currentMove > 0))
            
            Button {
                // progress one move forward in move history
                if chessboardVM.board.moves.count > chessboardVM.board.currentMove {
                    withAnimation(settings.movePieceAnimation()) {
                        chessboardVM.makeMove(chessboardVM.board.moves[chessboardVM.board.currentMove], strict: false)
                    }
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
