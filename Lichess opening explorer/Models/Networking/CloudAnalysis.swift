//
//  CloudAnalysis.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 22.12.22.
//

import Foundation

struct CloudAnalyis: Decodable {
    let fen: String
    let knodes, depth: Int
    let pvs: [PV]
}

// MARK: - PV
struct PV: Decodable {
    let moves: String
    let cp: Int
}
