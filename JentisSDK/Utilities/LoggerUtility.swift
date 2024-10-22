//
//  LoggerUtility.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 22/10/2024.
//

import Foundation
import os

final class LoggerUtility {

    // Singleton instance for shared logging across the app
    static let shared = LoggerUtility()
    
    // Define a base logger instance
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.jentis.JentisSDK", category: "default")

    private init() {}
    
    // Log a debug message
    func logDebug(_ message: String) {
        logger.debug("\(message, privacy: .public)")  // Debug level logs
    }

    // Log an info message
    func logInfo(_ message: String) {
        logger.info("\(message, privacy: .public)")   // Info level logs
    }

    // Log a warning message
    func logWarning(_ message: String) {
        logger.warning("\(message, privacy: .public)")  // Warning level logs
    }

    // Log an error message
    func logError(_ message: String) {
        logger.error("\(message, privacy: .public)")   // Error level logs
    }

    // Log a critical message
    func logCritical(_ message: String) {
        logger.critical("\(message, privacy: .public)")  // Critical level logs
    }
}
