//
//  Service.swift
//  
//
//  Created by Alexandre Oliveira on 07/10/2024.
//

import Foundation

final class Service {

    private let urlString: String
    private let session: URLSession
    
    public init(urlString: String = "https://us-central1-mobilesdklogging.cloudfunctions.net/saveString", session: URLSession = .shared) {
        self.urlString = urlString
        self.session = session
    }
    
    public func sendString(_ myString: String) async throws {
        guard let url = URL(string: urlString) else {
            throw ServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["myString": myString]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            throw ServiceError.invalidRequestBody
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ServiceError.invalidResponse
        }
        
        // Handle response data if needed, currently it's unused.
    }
    
    public enum ServiceError: Error {
        case invalidURL
        case invalidRequestBody
        case invalidResponse
    }
}
