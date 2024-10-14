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
    
    public init(urlString: String = "https://qc3ipx.ckion-dev.jtm-demo.com/", session: URLSession = .shared) {
        self.urlString = urlString
        self.session = session
    }

    // Method to send a string
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
    
    // Method to send ConsentModel
    public func sendConsent(_ consentModel: ConsentModel) async throws {
        try await sendObject(consentModel)
    }
    
    // Method to send DataSubmissionModel
    public func sendDataSubmission(_ dataSubmissionModel: DataSubmissionModel) async throws {
        try await sendObject(dataSubmissionModel)
    }
    
    // Private generic method to send any Codable object
    private func sendObject<T: Codable>(_ object: T) async throws {
        guard let url = URL(string: urlString) else {
            throw ServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(object)
            request.httpBody = jsonData
        } catch {
            throw ServiceError.invalidRequestBody
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ServiceError.invalidResponse
        }

        // Optionally handle the response data if needed.
    }
    
    // Enum for handling errors
    public enum ServiceError: Error {
        case invalidURL
        case invalidRequestBody
        case invalidResponse
    }
}

