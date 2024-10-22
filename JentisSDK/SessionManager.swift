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
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }

    // MARK: - Handle App Lifecycle Events

    @objc private static func appDidEnterBackground() {
        print("App entered background")
        // Save the last active timestamp when the app goes to the background
        lastActiveTimestamp = Date().timeIntervalSince1970
    }

    @objc private static func appWillEnterForeground() {
        print("App will enter foreground")
        // Check if the session should be resumed or a new session started
        let currentTime = Date().timeIntervalSince1970
        if (currentTime - lastActiveTimestamp) > sessionTimeoutInSeconds {
            startNewSession()
        } else {
            print("Resuming existing session with ID: \(currentSessionID ?? "unknown")")
        }
    }

    @objc private static func appWillTerminate() {
        print("App will terminate")
        // End the current session if the app is being closed
        endSession()
    }

    // MARK: - Session Management

    /// Starts a new session or resumes the current one if within the timeout period
    public static func startOrResumeSession() -> String {
        let currentTime = Date().timeIntervalSince1970
        
        // If the last activity was more than the configured session timeout, start a new session
        if (currentTime - lastActiveTimestamp) > sessionTimeoutInSeconds || currentSessionID == nil {
            startNewSession()
        } else {
            print("Session resumed with ID: \(currentSessionID!)")
        }

        // Update the last active timestamp
        lastActiveTimestamp = currentTime
        
        return currentSessionID!
    }
    
    /// Starts a new session by generating a new session ID
    private static func startNewSession() {
        currentSessionID = generateSessionID()
        print("New session started with ID: \(currentSessionID!)")
        lastActiveTimestamp = Date().timeIntervalSince1970
    }

    /// Generates a unique session ID (e.g., using UUID)
    private static func generateSessionID() -> String {
        return UUID().uuidString
    }
    
    /// Manually end the current session (optional)
    public static func endSession() {
        print("Session ended with ID: \(currentSessionID ?? "unknown")")
        currentSessionID = nil
    }
    
    /// Updates the last activity timestamp to prevent session timeout
    public static func updateLastActiveTimestamp() {
        lastActiveTimestamp = Date().timeIntervalSince1970
    }
}
