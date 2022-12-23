//
//  CloudAnalysis.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 22.12.22.
//

import Foundation

class CacheCloudAnalysis {
    let analysis: CloudAnalysis
    
    init(analysis: CloudAnalysis) {
        self.analysis = analysis
    }
}

struct CloudAnalysis: Decodable {
    let fen: String
    let knodes, depth: Int
    let pvs: [PV]
}

// MARK: - PV
struct PV: Decodable {
    let moves: String
    let cp: Int
}
