//
//  WrappingHStack.swift
//  WrappingHStack
//
//  Created by AC Richter on 08.12.22.
//

import SwiftUI

struct WrappingHStack: Layout {
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero}
        
        let size = CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0)
        
        return size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        
//        let spacings = horizontalSpacing(subviews: subviews)
        
        var x = bounds.minX
        var y = bounds.minY
        
        for i in subviews.indices {
            
            let prop = ProposedViewSize(subviews[i].sizeThatFits(.unspecified))
            
            if (x + (prop.width ?? 0)) > bounds.maxX {
                // With current item, row would be too long, *so skip to next row*
                y += prop.height ?? 0
                x = bounds.minX
            }
            
            subviews[i].place(at: CGPoint(x: x, y: y), proposal: prop)
            
            // Currently hard-coded spacing, bc 'horizontalSpacing' func for some reason did not work
            x += prop.width ?? 0 + 5
        }
    }

    /// Gets an array of preferred spacing sizes between subviews in the
    /// horizontal dimension.
    private func horizontalSpacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }
            return subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .horizontal)
        }
    }
}
