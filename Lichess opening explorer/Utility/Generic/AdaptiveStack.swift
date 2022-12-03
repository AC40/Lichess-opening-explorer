//
//  AdaptiveStack.swift
//  
//
//  Created by AC Richter on 17.01.22.
//

import SwiftUI

#if os(iOS)

/// An H- or VStack that changes its direction when the sizeClass changes
/// Only content is a required parameter
/// - Parameters:
///    - direction: A *StackDirection* that indicates the stacks default direction
///    - vSpacing: A *CGFloat* that controlls the spacing between items when stacked vertically
///    - hSpacing:A *CGFloat* that controlls the spacing between items when stacked horizontally
///    - vAlignment: A *HorizontalAlignment* that changes how the content aligns inside the Stack when stacked vertically
///    - hAlignment: A *VerticalAlignment* that changes how the content aligns inside the Stack when stacked vertically
///    - content: A *@ViewBuilder* result that represents the content that will be wrapped in the stacks
/// - Note:
///   - This can be used just like a regular H- or VStack
///   - For a more elaborate explanation of all Parameters, please visit [this project's repo](github.com/ac40/AdaptiveStack)
public struct AdaptiveStack<Content: View>: View {
    
    @Environment(\.verticalSizeClass) var sizeClass
    
    private var standardDirection: StackDirection
    private var vSpacing: CGFloat?
    private var hSpacing: CGFloat?
    private var vAlignment: HorizontalAlignment
    private var hAlignment: VerticalAlignment
    private var content: Content
    
    public init(_ standardDirection: StackDirection = .vertical, spacing: CGFloat? = nil, hAlignment:  VerticalAlignment = .center, vAlignment: HorizontalAlignment = .center, @ViewBuilder content: () -> Content) {
        self.standardDirection = standardDirection
        self.vSpacing = spacing
        self.hSpacing = spacing
        self.hAlignment = hAlignment
        self.vAlignment = vAlignment
        self.content = content()
    }
    
    public init(_ standartDirection: StackDirection = .vertical, vSpacing: CGFloat? = nil, hSpacing: CGFloat? = nil, hAlignment: VerticalAlignment = .center, vAlignment: HorizontalAlignment = .center, @ViewBuilder content: () -> Content) {
        self.standardDirection = standartDirection
        self.vSpacing = vSpacing
        self.hSpacing = hSpacing
        self.hAlignment = hAlignment
        self.vAlignment = vAlignment
        self.content = content()
    }
    
    public var body: some View {
        if standardDirection == .vertical {
            if sizeClass == .regular {
                VStack(alignment: vAlignment, spacing: vSpacing) {
                    content
                }
            } else {
                HStack(alignment: hAlignment, spacing: hSpacing) {
                    content
                }
            }
        } else {
            if sizeClass == .compact {
                VStack(alignment: vAlignment, spacing: vSpacing) {
                    content
                }
            } else {
                HStack(alignment: hAlignment, spacing: hSpacing) {
                    content
                }
            }
        }
        
    }
}

#endif
