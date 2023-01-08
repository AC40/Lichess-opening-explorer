//
//  OpeningExplorerViewModel.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 04.01.23.
//

import SwiftUI

class OpeningExplorerViewModel: ObservableObject {
    
    @Published var dbType: Int = 0
    
    @Published var currentOpening: LichessOpening = LichessOpening(eco: nil, name: nil)
}
