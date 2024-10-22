//
//  TrackingService.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 07/10/2024.
//

import Foundation

public class JentisService {
    public static func configure(with config: TrackConfig) {
        LoggerUtility.shared.logInfo("JentisService is configuring with trackDomain: \(config.trackDomain), container: \(config.container), environment: \(config.environment.rawValue)")

        TrackConfig.configure(
            trackDomain: config.trackDomain,
            container: config.container,
            environment: config.environment,
            version: config.version,
            debugCode: config.debugCode
        )
        TrackingService.initialize()
        SessionManager.startObservingAppLifecycle()
    }
}

public class TrackingService {
    private static var instance: TrackingService?
    
    public static func initialize() {
        guard instance == nil else {
            LoggerUtility.shared.logWarning("TrackingService is already initialized")
            return
        }

        // Pass the container from TrackConfig as the key for UserIDUtility
        let trackConfig = TrackConfig.shared
        let userIDUtility = UserIDUtility(userIDKey: trackConfig.container)
        let consentIDUtility = ConsentIDUtility(consentIDKey: trackConfig.container)

        instance = TrackingService(userIDUtility: userIDUtility, consentIDUtility: consentIDUtility)
        LoggerUtility.shared.logInfo("TrackingService initialized successfully with container: \(trackConfig.container)")
    }
    
    public static var shared: TrackingService {
        guard let instance = instance else {
            LoggerUtility.shared.logError("TrackingService is not initialized. Call JentisService.configure(with:) first.")
            fatalError("TrackingService is not initialized. Call JentisService.configure(with:) first.")
        }
        return instance
    }
    
    private let trackConfig = TrackConfig.shared
    private let service = Service()
    private let userAgent = UserAgentUtility.userAgent
    private let consentUtility: ConsentIDUtility
    private let userIDUtility: UserIDUtility

    private init(userIDUtility: UserIDUtility, consentIDUtility: ConsentIDUtility) {
        self.userIDUtility = userIDUtility
        self.consentUtility = consentIDUtility
    }

    public func sendConsentModel() async throws {
        LoggerUtility.shared.logInfo("Preparing to send consent model")
        
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
                container: trackConfig.container,
                environment: trackConfig.environment.rawValue,
                version: trackConfig.version ?? "",
                debugcode: trackConfig.debugCode ?? ""
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

        LoggerUtility.shared.logDebug("Sending consent model: \(consentModel)")
        try await service.sendConsent(consentModel)
        LoggerUtility.shared.logInfo("Consent model sent successfully")
    }

    // Send Data Submission Model with Logging
    public func sendDataSubmissionModel() async throws {
        LoggerUtility.shared.logInfo("Preparing to send data submission model")

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
                container: trackConfig.container,
                environment: trackConfig.environment.rawValue,
                version: trackConfig.version ?? "",
                debugcode: trackConfig.debugCode ?? ""
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
        
        LoggerUtility.shared.logDebug("Sending data submission model: \(dataSubmissionModel)")
        try await service.sendDataSubmission(dataSubmissionModel)
        LoggerUtility.shared.logInfo("Data submission model sent successfully")
    }
}
