//
//  MarqueeView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 08.01.23.
//

import SwiftUI
import MarqueeLabel

//TODO: Allow user to drag label (Currently the encapsulating UIView is blocking it)
struct Marquee: UIViewRepresentable {
    
    var text: String
        
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let marquee = MarqueeLabel(frame: view.frame, duration: 3.0, fadeLength: 50.0)

        view.addSubview(marquee)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
        let marquee = uiView.subviews[0] as! MarqueeLabel
        
        marquee.frame = uiView.frame
        marquee.textAlignment = .natural
        marquee.text = text
        marquee.trailingBuffer = 50
        marquee.fadeLength = 20.0
        marquee.animationDelay = 1.5
        marquee.restartLabel()
        
        // uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
}
