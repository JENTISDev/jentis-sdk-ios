//
//  Service.swift
//  
//
//  Created by Alexandre Oliveira on 07/10/2024.
//

import Foundation

class Service {

    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
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
        let trackConfig = TrackConfig.shared  // Direct access to TrackConfig.shared
        let urlString = "https://\(trackConfig.trackDomain)/"  // Dynamic track domain
        
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
