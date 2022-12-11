//
//  variationStyle.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 11.12.22.
//

import SwiftUI

struct VariationStyle: ViewModifier {
    var isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.primary)
            .padding(2)
            .background(isSelected ? Color.purple.opacity(0.4) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: isSelected ? 4 : 0))
    }
}

extension View {
    func variationStyle(isSelected: Bool) -> some View {
        self.modifier(VariationStyle(isSelected: isSelected))
    }
}
