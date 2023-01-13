//
//  MoveStatistics.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import SwiftUI
import Charts

struct MoveStatistics: View {
    
    var move: LichessMove
    
    @State private var widthTenth: CGFloat = .zero
    
    var body: some View {
        Group {
                SpacingHStack(distribution: [0.15, 0.3, 0.55], spacing: 5) {
                    Text(move.san)
                    
                    Text("\(move.white + move.black + move.draws)")
                    
                    HStack {
                        GeometryReader { geo in
                            ZStack {
                                Color.clear

                                HStack(spacing: 0) {
                                    let whiteShare = shareOfWins(for: move.white)
                                    let drawShare = shareOfWins(for: move.draws)
                                    let blackShare = shareOfWins(for: move.black)

                                    Color.white
                                        .frame(width: geo.size.width*whiteShare)
                                        .overlay(properlyFormattedText(whiteShare))
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
                    .frame(height: 30)
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
    
    func shareOfWins(for int: Int) -> CGFloat {
        let total = move.white + move.black + move.draws
        
        let result = Double(int)/Double(total)
        return CGFloat(result)
        
    }
}
