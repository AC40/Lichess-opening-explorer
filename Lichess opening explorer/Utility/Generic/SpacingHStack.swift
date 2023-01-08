//
//  SpacingHStack.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import SwiftUI

struct SpacingHStack: Layout {
    
    var distribution: [Double]
    
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
        
        let distributableSpace = bounds.width - CGFloat(gaps * 5)
        
        for i in subviews.indices {
            
            let prop = ProposedViewSize(width: distributableSpace*distribution[i], height: subviews[i].sizeThatFits(.unspecified).height)
            
            subviews[i].place(at: CGPoint(x: x, y: y), proposal: prop)
            
            // Currently hard-coded spacing, bc 'horizontalSpacing' func for some reason did not work
            x += prop.width ?? 0
        }
    }
}
