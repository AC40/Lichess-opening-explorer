//
//  SpacingHStack.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import SwiftUI

struct SpacingHStack: Layout {
    
    var distribution: [Double]
    var spacing: Int = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero}
        
        let size = CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0)
        
        return size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        
        var x = bounds.minX
        let y = bounds.midY
        
        var gaps = subviews.count - 2
        
        if gaps < 0 {
            gaps = 0
        }
        
        let distributableSpace = bounds.width - CGFloat(gaps * spacing)
        
        for i in subviews.indices {
            
            let prop = ProposedViewSize(width: distributableSpace*distribution[i], height: subviews[i].sizeThatFits(.unspecified).height)
            
            subviews[i].place(at: CGPoint(x: x, y: y), proposal: prop)
            
            x += prop.width ?? 0
            
            if i != subviews.count-1 {
                x += CGFloat(spacing)
            }
        }
    }
}
