//
//  DataSubmissionModel.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 11/10/2024.
//

import Foundation

// MARK: - DataSubmissionModel
struct DataSubmissionModel: Codable {
    let system: System
    let consent: Consent
    let configuration: Configuration
    let data: DataClass

    // MARK: - System
    struct System: Codable {
        let type: String
        let timestamp: Int
        let navigatorUserAgent: String
        let initiator: String
        let sessionID: String
        
        enum CodingKeys: String, CodingKey {
            case type, timestamp
            case navigatorUserAgent = "navigator-userAgent"
            case initiator
            case sessionID
        }
    }

    // MARK: - Consent
    struct Consent: Codable {
        let googleAnalytics: Vendor
        let facebook: Vendor
        let awin: Vendor
        
        enum CodingKeys: String, CodingKey {
            case googleAnalytics = "googleanalytics"
            case facebook, awin
        }

        // MARK: - Vendor
        struct Vendor: Codable {
            let status: StatusValue
        }
        
        // Handles both String and Boolean types for "status"
        enum StatusValue: Codable {
            case string(String)
            case bool(Bool)

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let boolValue = try? container.decode(Bool.self) {
                    self = .bool(boolValue)
                } else if let stringValue = try? container.decode(String.self) {
                    self = .string(stringValue)
                } else {
                    throw DecodingError.typeMismatch(StatusValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Failed to decode StatusValue"))
                }
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .bool(let boolValue):
                    try container.encode(boolValue)
                case .string(let stringValue):
                    try container.encode(stringValue)
                }
            }
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
        let variables: Variables
        let enrichment: Enrichment

        // MARK: - Identifier
        struct Identifier: Codable {
            let user: User
            let session: Session
            
            // MARK: - User
            struct User: Codable {
                let id: String
                let action: String
            }
            
            // MARK: - Session
            struct Session: Codable {
                let id: String
                let action: String
            }
        }

        // MARK: - Variables
        struct Variables: Codable {
            let documentLocationHref: String
            let fbBrowserId: String
            let jtspushedcommands: [String]
            let productId: [String]
            
            enum CodingKeys: String, CodingKey {
                case documentLocationHref = "document_location_href"
                case fbBrowserId = "fb_browser_id"
                case jtspushedcommands
                case productId = "product_id"
            }
        }

        // MARK: - Enrichment
        struct Enrichment: Codable {
            let enrichmentXxxlprodfeed: EnrichmentXxxlprodfeed
            
            enum CodingKeys: String, CodingKey {
                case enrichmentXxxlprodfeed = "enrichment_xxxlprodfeed"
            }
            
            // MARK: - EnrichmentXxxlprodfeed
            struct EnrichmentXxxlprodfeed: Codable {
                let arguments: Arguments
                let variables: [String]
                
                // MARK: - Arguments
                struct Arguments: Codable {
                    let account: String
                    let productId: [String]
                    let baseProductId: [String]
                }
            }
        }
    }
}
