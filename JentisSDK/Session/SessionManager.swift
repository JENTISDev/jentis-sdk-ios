//
//  SessionManager.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 22/10/2024.
//

import Foundation
import UIKit

public class SessionManager {

    // Use session duration from Config
    private static let sessionTimeoutInSeconds: TimeInterval = TimeInterval(Config.Tracking.sessionDuration * 60) // Configurable timeout
    private static var lastActiveTimestamp: TimeInterval = Date().timeIntervalSince1970
    private static var currentSessionID: String?

    // MARK: - Setup for observing app lifecycle events
    public static func startObservingAppLifecycle() {
        LoggerUtility.shared.logInfo("Started observing app lifecycle events")
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }

    // MARK: - Handle App Lifecycle Events
    @objc private static func appDidEnterBackground() {
        LoggerUtility.shared.logInfo("App entered background")
        // Save the last active timestamp when the app goes to the background
        lastActiveTimestamp = Date().timeIntervalSince1970
    }

    @objc private static func appWillEnterForeground() {
        LoggerUtility.shared.logInfo("App will enter foreground")
        // Check if the session should be resumed or a new session started
        let currentTime = Date().timeIntervalSince1970
        if (currentTime - lastActiveTimestamp) > sessionTimeoutInSeconds {
            startNewSession()
        } else {
            LoggerUtility.shared.logDebug("Resuming existing session with ID: \(currentSessionID ?? "unknown")")
        }
    }

    @objc private static func appWillTerminate() {
        LoggerUtility.shared.logInfo("App will terminate")
        // End the current session if the app is being closed
        endSession()
    }

    // MARK: - Session Management

    public static func startOrResumeSession() -> (String, Action) {
        let currentTime = Date().timeIntervalSince1970
        
        if (currentTime - lastActiveTimestamp) > sessionTimeoutInSeconds || currentSessionID == nil {
            startNewSession()
            return (currentSessionID!, .new)
        } else {
            lastActiveTimestamp = currentTime
            return (currentSessionID!, .update)
        }
    }

    private static func startNewSession() {
        currentSessionID = generateSessionID()
        LoggerUtility.shared.logInfo("New session started with ID: \(currentSessionID!)")
        lastActiveTimestamp = Date().timeIntervalSince1970
    }

    private static func generateSessionID() -> String {
        return UUID().uuidString
    }

    public static func endSession() {
        LoggerUtility.shared.logInfo("Session ended with ID: \(currentSessionID ?? "unknown")")
        currentSessionID = nil
    }

    // MARK: - Accessors for Testing
    public static func setLastActiveTimestamp(_ timestamp: TimeInterval) {
        lastActiveTimestamp = timestamp
    }

    public static func getLastActiveTimestamp() -> TimeInterval {
        return lastActiveTimestamp
    }

    public static func setCurrentSessionID(_ sessionID: String?) {
        currentSessionID = sessionID
    }

    public static func getCurrentSessionID() -> String? {
        return currentSessionID
    }
}
