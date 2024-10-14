//
//  ConsentModel.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 11/10/2024.
//

import Foundation

// MARK: - Main Model
struct ConsentModel: Codable {
    let system: System
    let configuration: Configuration
    let data: DataClass
    
    // MARK: - System
    struct System: Codable {
        let type: String
        let timestamp: Int
        let navigatorUserAgent: String
        let initiator: String
        
        enum CodingKeys: String, CodingKey {
            case type, timestamp
            case navigatorUserAgent = "navigator-userAgent"
            case initiator
        }
    }
    
    // MARK: - Configuration
    struct Configuration: Codable {
        let container: String
        let environment: String
        let version: String
        let debugcode: String
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let identifier: Identifier
        let consent: Consent
        
        // MARK: - Identifier
        struct Identifier: Codable {
            let user: User
            let consent: ConsentID
            
            // MARK: - User
            struct User: Codable {
                let id: String
                let action: String
            }
            
            // MARK: - ConsentID
            struct ConsentID: Codable {
                let id: String
                let action: String
            }
        }
        
        // MARK: - Consent
        struct Consent: Codable {
            let lastupdate: Int
            let data: [String: String]
            let vendors: Vendors
            let vendorsChanged: VendorsChanged
            
            // MARK: - Vendors
            struct Vendors: Codable {
                let googleAnalytics: Bool
                let facebook: String
                let awin: Bool
                
                enum CodingKeys: String, CodingKey {
                    case googleAnalytics = "googleanalytics"
                    case facebook
                    case awin
                }
            }
            
            // MARK: - VendorsChanged
            struct VendorsChanged: Codable {
                let facebook: String
            }
        }
    }
}
