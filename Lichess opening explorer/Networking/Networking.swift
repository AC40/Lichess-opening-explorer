//
//  Networking.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 28.05.22.
//

import Foundation

struct Networking {
    
    static func fetchMasterDB(from fen: String = "fen=rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", moves: String = "", since start: Int = 1952, movesToReturn: Int = 12) async throws -> LichessDBResponse {
        
        let fen = fen.replacingOccurrences(of: " ", with: "%20")
        
        let url = URL(string: "https://explorer.lichess.ovh/masters?fen=\(fen)")
        
        guard url != nil else {
            throw NetworkingError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url!)
        
        let mastersDB = try JSONDecoder().decode(LichessDBResponse.self, from: data)
        
        return mastersDB
    }
    
    static func fetchLichessDB(
        from fen: String = "fen=rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
        moves: String = "",
        speeds: [LichessSpeed] = LichessSpeed.allCases,
        since start: Int = 1952,
        movesToReturn: Int = 12) async throws -> LichessDBResponse {
        
        let fen = fen.replacingOccurrences(of: " ", with: "%20")
        
        let url = URL(string: "https://explorer.lichess.ovh/lichess?fen=\(fen)&speeds=\(speeds.formattedString())")
        
        guard url != nil else {
            throw NetworkingError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url!)
        
        let db = try JSONDecoder().decode(LichessDBResponse.self, from: data)
        
        return db
    }
    
    static func fetchPlayerDB(
        for player: String,
        with color: String,
        from fen: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
        moves: String = "",
        speeds: [LichessSpeed] = LichessSpeed.allCases,
        since start: Int = 1952,
        movesToReturn: Int = 12) async throws -> LichessDBResponse {
            
            let fen = fen.replacingOccurrences(of: " ", with: "%20")
            
            let url = URL(string: "https://explorer.lichess.ovh/player?player=\(player)&color=\(color)&fen=\(fen)&speeds=\(speeds.formattedString())")
            
            guard url != nil else {
                throw NetworkingError.invalidURL
            }
            
            let jsonString = try await Networking.fetchNDJSON(url: url!)
            
            let db = try JSONDecoder().decode(LichessDBResponse.self, from: Data(jsonString.utf8))
            
            return db
        }
    
    static func fetchCachedAnalysis(for fen: String, variations: Int = 1) async throws -> CloudAnalysis {
        var fen = fen
        
        fen = fen.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: "https://lichess.org/api/cloud-eval?fen=\(fen)")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let analysis = try JSONDecoder().decode(CloudAnalysis.self, from: data)
        
        return analysis
    }
    
    //MARK: Utility functions
    static func fetchNDJSON(url: URL) async throws -> String {
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard var jsonString = String(data: data, encoding: .utf8) else {
            throw NetworkingError.unknownError
        }
        
        jsonString = jsonString.filter { !" \n\t\r".contains($0) }
        
        return jsonString
    
    }
}
