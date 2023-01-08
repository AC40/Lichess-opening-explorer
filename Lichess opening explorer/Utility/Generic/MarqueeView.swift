//
//  MarqueeView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 08.01.23.
//

import SwiftUI
import MarqueeLabel

struct Marquee: UIViewRepresentable {
    
    var text: String
        
    func makeUIView(context: Context) -> MarqueeLabel {
        MarqueeLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 00), duration: 3.0, fadeLength: 50.0)
    }
    
    func updateUIView(_ uiView: MarqueeLabel, context: Context) {
        uiView.textAlignment = .natural
        uiView.text = text
//        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        uiView.restartLabel()
    }
}
