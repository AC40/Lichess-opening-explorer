//
//  WrappingHStack.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 07.12.22.
//

import SwiftUI

struct WrappingHStack: View {
    
    let items: [AttributedString]
    
    var body: some View {
        TagsView(items: items)
    }
}

struct TagsView: View {
    
    let items: [AttributedString]
    var groupedItems: [[AttributedString]] = [[AttributedString]]()
    let screenWidth = UIScreen.main.bounds.width
    
    init(items: [AttributedString]) {
        self.items = items
        self.groupedItems = createGroupedItems(items)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(groupedItems, id: \.self) { subItems in
                    HStack {
                        ForEach(subItems, id: \.self) { word in
                            Text(word)
                                .fixedSize()
                        }
                    }
                }
                Spacer()
            }
        }
    }
    
    private func createGroupedItems(_ items: [AttributedString]) -> [[AttributedString]] {
        var groupedItems: [[AttributedString]] = [[AttributedString]]()
        var tempItems: [AttributedString] =  [AttributedString]()
        var width: CGFloat = 0
        for word in items {
            let label = UILabel()
            label.attributedText = NSAttributedString(word)
            label.sizeToFit()
            let labelWidth = label.frame.size.width + 32
            if (width + labelWidth + 55) < screenWidth {
                width += labelWidth
                tempItems.append(word)
            } else {
                width = labelWidth
                groupedItems.append(tempItems)
                tempItems.removeAll()
                tempItems.append(word)
            }
        }
        groupedItems.append(tempItems)
        return groupedItems
    }
}
