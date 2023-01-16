//
//  MoveList.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import SwiftUI
import Charts

struct MoveList: View {
    
    @State private var rowHeight: CGFloat  = 30
    
    var moves: [LichessMove]
    var didClick: (Int) -> Void
    
    var body: some View {
        Group {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading) {
                    ForEach(Array(moves.enumerated()), id:\.offset) { i, move in
                        Text(move.san)
                            .onTapGesture {
                                didClick(i)
                            }
                    }
                    .frame(height: rowHeight)
                }
                
                VStack(alignment: .leading) {
                    ForEach(Array(moves.enumerated()), id:\.offset) { i, move in
                        Text("\(move.white + move.black + move.draws)")
                            .onTapGesture {
                                didClick(i)
                            }
                    }
                    .frame(height: rowHeight)
                }
                
                VStack {
                    ForEach(Array(moves.enumerated()), id:\.offset) { i, move in
                        HStack {
                            GeometryReader { geo in
                                ZStack {
                                    Color.clear
                                    
                                    HStack(spacing: 0) {
                                        let whiteShare = shareOfWins(of: move.white, for: move)
                                        let drawShare = shareOfWins(of: move.draws, for: move)
                                        let blackShare = shareOfWins(of: move.black, for: move)
                                        
                                        //                                    Color(red: 230/255, green: 230/255, blue: 230/255)
                                        Color.white
                                            .frame(width: geo.size.width*whiteShare)
                                            .overlay(
                                                properlyFormattedText(whiteShare)
                                                    .foregroundColor(.black)
                                            )
                                        Color.gray
                                            .frame(width: geo.size.width*drawShare)
                                            .overlay(properlyFormattedText(drawShare))
                                        Color.black
                                            .frame(width: geo.size.width*blackShare)
                                            .overlay(
                                                properlyFormattedText(blackShare)
                                                    .foregroundColor(.white)
                                            )
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                                
                            }
                        }
                        .frame(height: rowHeight)
                        .onTapGesture {
                            didClick(i)
                        }
                    }
                }
            }
            
            if moves.isEmpty {
                Text("Sorry. This we couldn't find moves in this position.")
            }
        }
    }
    
    func properlyFormattedText(_ input: CGFloat) -> some View {
        ViewThatFits {
            Text(String(format: "%.02f", input*100))
                .padding(.horizontal, 4)
            
            Text(String(format: "%.01f", input*100))
                .padding(.horizontal, 4)
            
            Text(String(format: "%.00f", input*100))
                .padding(.horizontal, 4)
            
            EmptyView()
        }
        
    }
    
    func shareOfWins(of int: Int, for move: LichessMove) -> CGFloat {
        let total = move.white + move.black + move.draws
        
        let result = Double(int)/Double(total)
        return CGFloat(result)
        
    }
}
