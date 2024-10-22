//
//  TrackingService.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 07/10/2024.
//

import Foundation

public class JentisService {
    public static func configure(with config: TrackConfig) {
        TrackingService.initialize(with: config)
        SessionManager.startObservingAppLifecycle()
    }
}

public class TrackingService {
    private static var instance: TrackingService?
    
    public static func initialize(with config: TrackConfig) {
        guard instance == nil else {
            print("TrackingService is already initialized")
            return
        }
        instance = TrackingService(config: config)
    }
    
    public static var shared: TrackingService {
        guard let instance = instance else {
            fatalError("TrackingService is not initialized. Call JentisService.configure(with:) first.")
        }
        return instance
    }
    
    private let trackConfig: TrackConfig
    private let service = Service()
    private let userAgent = UserAgentUtility.userAgent
    private let consentUtility = ConsentIDUtility()
    private let userIDUtility = UserIDUtility()
    
    private init(config: TrackConfig) {
        self.trackConfig = config
    }
    
    public func sendConsentModel() async throws {
        let consentID = consentUtility.getConsentID()
        let userID = userIDUtility.getUserID()
        let sessionID = SessionManager.startOrResumeSession()
        
        let consentModel = ConsentModel(
            system: ConsentModel.System(
                type: Config.Tracking.systemEnvironment,
                timestamp: TimestampUtility.currentTimestampInMillis(),
                navigatorUserAgent: userAgent,
                initiator: Config.Tracking.pluginId,
                sessionID: sessionID
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
                        action: Config.Action.new.rawValue
                    ),
                    consent: ConsentModel.DataClass.Identifier.ConsentID(
                        id: consentID,
                        action: Config.Action.new.rawValue
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
    
    public func sendDataSubmissionModel() async throws {
        let userID = userIDUtility.getUserID()
        let sessionID = SessionManager.startOrResumeSession()
        
        let dataSubmissionModel = DataSubmissionModel(
            system: DataSubmissionModel.System(
                type: Config.Tracking.systemEnvironment,
                timestamp: TimestampUtility.currentTimestampInMillis(),
                navigatorUserAgent: userAgent,
                initiator: Config.Tracking.pluginId,
                sessionID: sessionID
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
                        action: Config.Action.new.rawValue
                    ),
                    session: DataSubmissionModel.DataClass.Identifier.Session(
                        id: sessionID,
                        action: Config.Action.new.rawValue
                    )
                ),
                variables: DataSubmissionModel.DataClass.Variables(
                    documentLocationHref: "https://ckion-dev.jtm-demo.com/?",
                    fbBrowserId: "fb.1.1711009849625.5246926883",
                    jtspushedcommands: [Config.Tracking.Track.pageview.rawValue, Config.Tracking.Track.submit.rawValue],
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
