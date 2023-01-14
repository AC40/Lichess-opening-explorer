//
//  Networking.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 28.05.22.
//

import Foundation

struct Networking {
    
    static func fetchPlayerGames(for moves: String) async throws -> PlayerDBResponse {
        
        let url =  URL(string: "https://explorer.lichess.ovh/player?player=ac40&color=white&play=\(moves)&recentGames=10")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        print(response)
        
        let playerGameResponse = try JSONDecoder().decode(PlayerDBResponse.self, from: data)
        
        return playerGameResponse
    }
    
    static func fetchMasterDB(from fen: String = "fen=rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", moves: String = "", since start: Int = 1952, movesToReturn: Int = 12) async throws -> LichessDBResponse {
        
        let fen = fen.replacingOccurrences(of: " ", with: "%20")
        
        let url = URL(string: "https://explorer.lichess.ovh/masters?fen=\(fen)")
        
        guard url != nil else {
            throw NetworkingError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url!)
        
        print(response)
        
        
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
        
        let (data, response) = try await URLSession.shared.data(from: url!)
        
        print(response)
        
        
        let db = try JSONDecoder().decode(LichessDBResponse.self, from: data)
        
        return db
    }
    
    // Currently does not work
    // Lichess (for some dumb reason) returns nd-json instead of json and i dont know how to read or convert it
    static func fetchPlayerDB(
        for player: String,
        with color: String,
        from fen: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
        moves: String = "",
        speeds: [LichessSpeed] = LichessSpeed.allCases,
        since start: Int = 1952,
        movesToReturn: Int = 12) async throws -> PlayerDBResponse {
            
            let fen = fen.replacingOccurrences(of: " ", with: "%20")
            
            let url = URL(string: "https://explorer.lichess.ovh/player?player=\(player)&color=\(color)&fen=\(fen)&speeds=\(speeds.formattedString())")
            
            guard url != nil else {
                throw NetworkingError.invalidURL
            }
            
            var jsonString = try await Networking.fetchNDJSON(url: url!)
            
            let db = try JSONDecoder().decode(PlayerDBResponse.self, from: Data(jsonString.utf8))
            
            return db
        }
    
    static func fetchCachedAnalysis(for fen: String, variations: Int = 1) async throws -> CloudAnalysis {
        var fen = fen
        
        fen = fen.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: "https://lichess.org/api/cloud-eval?fen=\(fen)")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        print((response as! HTTPURLResponse).statusCode)
        
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
//        jsonString.removeAll(where: { $0 == "\\" })
//        jsonString = "[" + jsonString
//        jsonString.append("]")
        
        return jsonString
    
    }
}
