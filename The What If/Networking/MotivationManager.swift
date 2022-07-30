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

enum GoalRequest {
    case create(goal: Goal)
    case update(goal: Goal)
    case remove
    case getAll
    case getById(id: String)
    
    var baseURL: String {
        "http://127.0.0.1:8080/goals"
    }
    
    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.customDateFormatter)
        return encoder
    }
    
    var httpBody: Data? {
        switch self {
        case .create(let goal), .update(let goal):
            return try? encoder.encode(goal)
        default:
            return nil
        }
    }
    
    var urlPath: String {
        switch self {
        case .create:
            return "/create"
        case .update:
            return "/update"
        case .remove:
            return "/remove"
        case .getAll:
            return "/all"
        case .getById(let id):
            return "/\(id)"
        }
    }
    
    var method: String {
        switch self {
        case .create:
            return "post"
        case .update:
            return "post"
        case .remove:
            return "delete"
        case .getAll:
            return "get"
        case .getById:
            return "get"
        }
    }
}

extension GoalRequest {
    var fullURL: URL? {
        return URL(string: baseURL + urlPath)
    }
}

class GoalNetworkManager {
    func getAllGoals() async throws -> [Goal] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.customDateFormatter)
        return try decoder.decode([Goal].self, from: try await performRequest(for: .getAll))
    }
    
    func createGoal(_ goal: Goal) async throws -> Bool {
        try await performRequest(for: .create(goal: goal))
        return true
    }
    
    func updateGoal(_ goal: Goal) async throws -> Goal {
        let data = try await performRequest(for: .update(goal: goal))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.customDateFormatter)
        return try decoder.decode(Goal.self, from: data)
    }
    
    @discardableResult
    func performRequest(for request: GoalRequest) async throws -> Data {
        guard let url = request.fullURL else {
            throw NetworkError.urlInvalid
        }
        var req = URLRequest(url: url)
        req.httpBody = request.httpBody
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = request.method
        dump(req)
        let (data, response) = try await URLSession.shared.data(for: req)
        if let code = (response as? HTTPURLResponse)?.statusCode, !(200...300).contains(code) {
            throw NetworkError.responseInvalid(code: code)
        }
        return data
    }
}
