//
//  TrackingService.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 07/10/2024.
//

import Foundation

public class JentisService {

    // Configure method similar to FirebaseApp.configure()
    public static func configure(with config: TrackConfig) {
        // Initialize the TrackingService with the provided config
        TrackingService.initialize(with: config)
    }
}

public class TrackingService {

    // The shared instance of the singleton
    private static var instance: TrackingService?

    // Public method to initialize the service, but prevents direct instantiation from outside
    public static func initialize(with config: TrackConfig) {
        guard instance == nil else {
            print("TrackingService is already initialized")
            return
        }
        instance = TrackingService(config: config)
    }

    // Access the singleton instance, after initialization
    public static var shared: TrackingService {
        guard let instance = instance else {
            fatalError("TrackingService is not initialized. Call JentisService.configure(with:) first.")
        }
        return instance
    }

    // Private properties and dependencies
    private let trackConfig: TrackConfig
    private let service = Service()
    private let userAgent = UserAgentUtility.userAgent
    private let consentUtility = ConsentIDUtility()
    private let userIDUtility = UserIDUtility()

    // Private initializer with TrackConfig to prevent external instantiation
    private init(config: TrackConfig) {
        self.trackConfig = config
    }

    /// Saves a string to the server via the provided API.
    public func saveString(_ string: String) async throws {
        try await service.sendString(string)
    }

    /// Sends ConsentModel to the server via the provided API.
    public func sendConsentModel() async throws {
        let consentID = consentUtility.getConsentID()
        let userID = userIDUtility.getUserID()

        let consentModel = ConsentModel(
            system: ConsentModel.System(
                type: "app",
                timestamp: TimestampUtility.currentTimestampInMillis(),
                navigatorUserAgent: userAgent,
                initiator: "jts_push_submit"
            ),
            configuration: ConsentModel.Configuration(
                container: trackConfig.trackDomain,
                environment: trackConfig.environment.rawValue,
                version: "3",
                debugcode: "a675b5f1-48d2-43bf-b314-ba4830cda52d"
            ),
            data: ConsentModel.DataClass(
                identifier: ConsentModel.DataClass.Identifier(
                    user: ConsentModel.DataClass.Identifier.User(
                        id: userID,
                        action: "new"
                    ),
                    consent: ConsentModel.DataClass.Identifier.ConsentID(
                        id: consentID,
                        action: "new"
                    )
                ),
                consent: ConsentModel.DataClass.Consent(
                    lastupdate: TimestampUtility.currentTimestampInMillis(),
                    data: [:],
                    vendors: ConsentModel.DataClass.Consent.Vendors(
                        googleAnalytics: true,
                        facebook: "ncm",
                        awin: false
                    ),
                    vendorsChanged: ConsentModel.DataClass.Consent.VendorsChanged(
                        facebook: "ncm"
                    )
                )
            )
        )
        
        try await service.sendConsent(consentModel)
    }

    /// Sends DataSubmissionModel to the server via the provided API.
    public func sendDataSubmissionModel() async throws {
        let userID = userIDUtility.getUserID()

        let dataSubmissionModel = DataSubmissionModel(
            system: DataSubmissionModel.System(
                type: "app",
                timestamp: TimestampUtility.currentTimestampInMillis(),
                navigatorUserAgent: userAgent,
                initiator: "jts_push_submit"
            ),
            consent: DataSubmissionModel.Consent(
                googleAnalytics: DataSubmissionModel.Consent.Vendor(status: .string("ncm")),
                facebook: DataSubmissionModel.Consent.Vendor(status: .bool(true)),
                awin: DataSubmissionModel.Consent.Vendor(status: .bool(false))
            ),
            configuration: DataSubmissionModel.Configuration(
                container: trackConfig.trackDomain,
                environment: trackConfig.environment.rawValue,
                version: "3",
                debugcode: "a675b5f1-48d2-43bf-b314-ba4830cda52d"
            ),
            data: DataSubmissionModel.DataClass(
                identifier: DataSubmissionModel.DataClass.Identifier(
                    user: DataSubmissionModel.DataClass.Identifier.User(
                        id: userID,
                        action: "new"
                    ),
                    session: DataSubmissionModel.DataClass.Identifier.Session(
                        id: "56797172855234403526020",
                        action: "new"
                    )
                ),
                variables: DataSubmissionModel.DataClass.Variables(
                    documentLocationHref: "https://ckion-dev.jtm-demo.com/?",
                    fbBrowserId: "fb.1.1711009849625.5246926883",
                    jtspushedcommands: ["pageview", "submit"],
                    productId: ["1111", "2222222"]
                ),
                enrichment: DataSubmissionModel.DataClass.Enrichment(
                    enrichmentXxxlprodfeed: DataSubmissionModel.DataClass.Enrichment.EnrichmentXxxlprodfeed(
                        arguments: DataSubmissionModel.DataClass.Enrichment.EnrichmentXxxlprodfeed.Arguments(
                            account: "xxxlutz-de",
                            productId: ["12345"],
                            baseProductId: ["1"]
                        ),
                        variables: ["enrich_product_price", "enrich_product_brand", "enrich_product_name"]
                    )
                )
            )
        )
        try await service.sendDataSubmission(dataSubmissionModel)
    }
}
