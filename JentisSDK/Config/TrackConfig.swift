//
//  TrackConfig.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 22/10/2024.
//

import Foundation

public class TrackConfig: Codable {
    public enum Environment: String, CaseIterable, Codable {
        case live, stage
    }

    // Singleton instance
    private static var sharedConfig: TrackConfig?

    /// The trackDomain for the HTTP request destination
    public let trackDomain: String
    /// The container value provided by JENTIS DCP
    public let container: String
    /// The environment (live or stage)
    public let environment: Environment
    /// Optional version for debug mode
    public let version: String?
    /// Optional debug code for debug mode
    public let debugCode: String?

    // UserDefaults key for persisting TrackConfig
    private static let configKey = "com.jentis.TrackConfig"

    // Public initializer to allow external instantiation if needed
    public init(trackDomain: String, container: String, environment: Environment, version: String?, debugCode: String?) {
        self.trackDomain = trackDomain
        self.container = container
        self.environment = environment
        self.version = version
        self.debugCode = debugCode
        LoggerUtility.shared.logInfo("TrackConfig initialized with trackDomain: \(trackDomain), container: \(container), environment: \(environment.rawValue)")
    }

    // Singleton configuration method
    public static func configure(trackDomain: String, container: String, environment: Environment, version: String? = nil, debugCode: String? = nil) {
        if sharedConfig == nil {
            sharedConfig = TrackConfig(trackDomain: trackDomain, container: container, environment: environment, version: version, debugCode: debugCode)
            saveConfigToUserDefaults()  // Save to UserDefaults via utility
            LoggerUtility.shared.logInfo("TrackConfig configured and saved to UserDefaults.")
        } else {
            LoggerUtility.shared.logWarning("TrackConfig is already configured.")
        }
    }

    // Access the singleton instance
    public static var shared: TrackConfig {
        guard let config = sharedConfig else {
            LoggerUtility.shared.logError("TrackConfig is not initialized. Call TrackConfig.configure(...) first.")
            fatalError("TrackConfig is not initialized. Call TrackConfig.configure(...) first.")
        }
        LoggerUtility.shared.logDebug("Accessing TrackConfig with trackDomain: \(config.trackDomain), container: \(config.container)")
        return config
    }

    // Store configuration in UserDefaults via UserDefaultsUtility
    private static func saveConfigToUserDefaults() {
        if let config = sharedConfig {
            UserDefaultsUtility.save(config, forKey: configKey)
            LoggerUtility.shared.logInfo("TrackConfig saved to UserDefaults.")
        }
    }

    // Load configuration from UserDefaults via UserDefaultsUtility
    public static func loadConfigFromUserDefaults() {
        if let loadedConfig: TrackConfig = UserDefaultsUtility.get(TrackConfig.self, forKey: configKey) {
            sharedConfig = loadedConfig
            LoggerUtility.shared.logInfo("TrackConfig loaded from UserDefaults.")
        } else {
            LoggerUtility.shared.logWarning("No TrackConfig found in UserDefaults.")
        }
    }

    // Method to clear UserDefaults if needed
    public static func clearConfigFromUserDefaults() {
        UserDefaultsUtility.remove(forKey: configKey)
        LoggerUtility.shared.logInfo("TrackConfig removed from UserDefaults.")
    }
}
