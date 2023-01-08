//
//  MoveStatistics.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import SwiftUI

struct MoveStatistics: View {
    
    var masterMove: MasterMove?
    var playerMove: PlayerMove?
    
    @State private var widthTenth: CGFloat = .zero
    
    init(masterMove: MasterMove? = nil, playerMove: PlayerMove? = nil) {
        self.masterMove = masterMove
        self.playerMove = playerMove
    }
    
    var body: some View {
        Group {
            if let masterMove = masterMove {
                SpacingHStack(distribution: [0.1, 0.25, 0.65]) {
                    Text(masterMove.san)
                    
                    Text("\(masterMove.white + masterMove.black + masterMove.draws)")
                    
                    HStack {
                        GeometryReader { geo in
                            ZStack {
                                Color.clear
                                
                                HStack(spacing: 0) {
                                    let whiteShare = shareOfWins(for: masterMove.white)
                                    let drawShare = shareOfWins(for: masterMove.draws)
                                    let blackShare = shareOfWins(for: masterMove.black)
                                    
                                    Color.green
                                        .frame(width: geo.size.width*whiteShare)
                                        .overlay(Text(String(format: "%.02f", whiteShare*100)))
                                    Color.gray
                                        .frame(width: geo.size.width*drawShare)
                                        .overlay(Text(String(format: "%.02f", drawShare*100)))
                                    Color.black
                                        .frame(width: geo.size.width*blackShare)
                                        .overlay(
                                            Text(String(format: "%.02f", blackShare*100))
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
    }
    
    func shareOfWins(for int: Int) -> CGFloat {
        if let masterMove = masterMove {
            let total = masterMove.white + masterMove.black + masterMove.draws
            
            let result = Double(int)/Double(total)
            return CGFloat(result)
        } else if let playerMove = playerMove {
            let total = playerMove.white + playerMove.black + playerMove.draws
            
            let result = Double(int)/Double(total)
            return CGFloat(result)
        } else {
            return .zero
        }
        
    }
}

struct MoveStatistics_Previews: PreviewProvider {
    static var previews: some View {
        MoveStatistics()
    }
}
