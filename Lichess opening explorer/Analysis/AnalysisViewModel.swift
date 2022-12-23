//
//  AnalysisViewModel.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 23.12.22.
//

import Foundation
import SwiftUI

class AnalysisViewModel: ObservableObject {
    
    @Published var analyze = false
    @Published var eval: CloudAnalysis? = nil
    @Published var noCache = false
    @Published var startTimer = false
    @Published var stopTimer = false
    
    @Published var idealViewHeight: CGFloat = .zero
    var cache = NSCache<NSString, CacheCloudAnalysis>()
}
