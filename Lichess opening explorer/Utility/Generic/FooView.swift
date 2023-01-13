//
//  FooView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 11.01.23.
//

import SwiftUI
import MarqueeLabel

struct FooView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIStackView()
        let marquee = MarqueeLabel(frame: CGRect(x: 0, y: 0, width: 350, height: 100), duration: 3.0, fadeLength: 50.0)
        
        marquee.text = "This is a text which should definetly be too large for the screen"
        marquee.textAlignment = .natural
        view.addSubview(marquee)
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Update view
    }
}
