//
//  Networking.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 28.05.22.
//

import Foundation

struct Networking {
    
    static func fetchPlayerGames(for moves: String) async throws -> PlayerGameResponse {
        
        let url =  URL(string: "https://explorer.lichess.ovh/player?player=ac40&color=white&play=\(moves)&recentGames=10")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        print((response as! HTTPURLResponse).statusCode)
        
        let playerGameResponse = try JSONDecoder().decode(PlayerGameResponse.self, from: data)
        
        return playerGameResponse
    }
    
    static func fetchCachesAnalysis(for fen: String, variations: Int = 1) async throws -> CloudAnalyis {
        var fen = fen
        
        fen = fen.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: "https://lichess.org/api/cloud-eval?fen=\(fen)")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        print((response as! HTTPURLResponse).statusCode)
        
        let analysis = try JSONDecoder().decode(CloudAnalyis.self, from: data)
        
        return analysis
    }
}
