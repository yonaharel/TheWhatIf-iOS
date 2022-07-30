//
//  MotivationManager.swift
//  The What If
//
//  Created by Yona Harel on 24/07/2022.
//

import Foundation
import Shared

enum NetworkError: Error {
    case responseInvalid(code: Int)
    case urlInvalid
}

class MotivationNetworkManager {
    
    private let endpoint = "http://127.0.0.1:8080"
    
    func getAllMotivations() async throws -> [Motivation] {
        guard let url = URL(string: endpoint + "/motivations/all") else {
            throw NetworkError.urlInvalid
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let code = (response as? HTTPURLResponse)?.statusCode, !(200...300).contains(code) {
            throw NetworkError.responseInvalid(code: code)
            
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.customDateFormatter)
        return try decoder.decode([Motivation].self, from: data)
    }
    
    func addMotivation(_ motivation: Motivation) async throws {
        guard let url = URL(string: endpoint + "/motivations/create") else {
            throw NetworkError.urlInvalid
        }
        var req = URLRequest(url: url)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.customDateFormatter)
        req.httpBody = try encoder.encode(motivation)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "post"
        let (_, response) = try await URLSession.shared.data(for: req)
        if let code = (response as? HTTPURLResponse)?.statusCode, !(200...300).contains(code) {
            throw NetworkError.responseInvalid(code: code)
        }
    }
}
