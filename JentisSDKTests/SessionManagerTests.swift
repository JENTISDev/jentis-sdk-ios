//
//  SessionManagerTests.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 23/10/2024.
//

import XCTest
@testable import JentisSDK
import UIKit

class SessionManagerTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Clear any existing session before each test
        SessionManager.endSession()
    }

    override func tearDownWithError() throws {
        // Clean up after each test
        SessionManager.endSession()
        try super.tearDownWithError()
    }

    // Test starting a new session
    func testStartNewSession() throws {
        // When: Starting or resuming session for the first time
        let (sessionID, action) = SessionManager.startOrResumeSession()

        // Then: A new session should be created
        XCTAssertNotNil(sessionID, "Expected a non-nil session ID")
        XCTAssertEqual(action, .new, "Expected the session action to be 'new'")
    }

    // Test resuming an existing session
    func testResumeExistingSession() throws {
        // Given: A session has already been started
        let (sessionID, _) = SessionManager.startOrResumeSession()
        let originalSessionID = sessionID

        // When: Resuming session within timeout period
        let (resumedSessionID, action) = SessionManager.startOrResumeSession()

        // Then: The session should be resumed, and the session ID should be the same
        XCTAssertEqual(resumedSessionID, originalSessionID, "Expected the session ID to be the same")
        XCTAssertEqual(action, .update, "Expected the session action to be 'update'")
    }

    // Test starting a new session after timeout
    func testStartNewSessionAfterTimeout() throws {
        // Given: A session has already been started
        let (sessionID, _) = SessionManager.startOrResumeSession()

        // Simulate session timeout by advancing the last active timestamp
        let timeout = Config.Tracking.sessionDuration * 60 + 1
        SessionManager.setLastActiveTimestamp(SessionManager.getLastActiveTimestamp() - TimeInterval(timeout))

        // When: Starting or resuming session after the timeout
        let (newSessionID, action) = SessionManager.startOrResumeSession()

        // Then: A new session should be created
        XCTAssertNotEqual(newSessionID, sessionID, "Expected a new session ID after timeout")
        XCTAssertEqual(action, .new, "Expected the session action to be 'new' after timeout")
    }

    // Test app lifecycle event: App enters background
    func testAppDidEnterBackground() throws {
        // Given: A session has been started
        SessionManager.startOrResumeSession()

        // When: Simulating app entering background
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)

        // Then: The last active timestamp should be updated
        let currentTime = Date().timeIntervalSince1970
        XCTAssertEqual(SessionManager.getLastActiveTimestamp(), currentTime, accuracy: 1.0, "Expected the last active timestamp to be updated")
    }

    // Test app lifecycle event: App enters foreground
    func testAppWillEnterForeground_ResumeSession() throws {
        // Given: A session has already been started
        let (sessionID, _) = SessionManager.startOrResumeSession()
        let originalSessionID = sessionID

        // When: Simulating app entering foreground without timeout
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        // Then: The session should be resumed
        let (resumedSessionID, action) = SessionManager.startOrResumeSession()
        XCTAssertEqual(resumedSessionID, originalSessionID, "Expected the session ID to be the same when resuming from foreground")
        XCTAssertEqual(action, .update, "Expected the session action to be 'update'")
    }

    // Test app lifecycle event: App enters foreground after timeout
    func testAppWillEnterForeground_StartNewSession() throws {
        // Given: A session has been started
        let (sessionID, _) = SessionManager.startOrResumeSession()

        // Simulate session timeout by advancing the last active timestamp
        let timeout = Config.Tracking.sessionDuration * 60 + 1
        SessionManager.setLastActiveTimestamp(SessionManager.getLastActiveTimestamp() - TimeInterval(timeout))

        // When: Simulating app entering foreground after timeout
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        // Then: A new session should be created
        let (newSessionID, action) = SessionManager.startOrResumeSession()
        XCTAssertNotEqual(newSessionID, sessionID, "Expected a new session ID after timeout when app enters foreground")
        XCTAssertEqual(action, .new, "Expected the session action to be 'new' after timeout")
    }

    // Test manually ending a session
    func testEndSession() throws {
        // Given: A session has been started
        let (sessionID, _) = SessionManager.startOrResumeSession()
        XCTAssertNotNil(sessionID, "Expected a non-nil session ID before ending session")

        // When: Manually ending the session
        SessionManager.endSession()

        // Then: The session should be nil
        XCTAssertNil(SessionManager.getCurrentSessionID(), "Expected session ID to be nil after ending session")
    }
}
