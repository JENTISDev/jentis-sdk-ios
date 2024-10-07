//
//  TrackingService.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 07/10/2024.
//


import Foundation

public class TrackingService {
    
    private static let service = Service()
    
    /// Saves a string to the server via the provided API.
    /// - Parameter string: The string to be saved.
    public static func saveString(_ string: String) async throws {
        try await service.sendString(string)
    }
}
