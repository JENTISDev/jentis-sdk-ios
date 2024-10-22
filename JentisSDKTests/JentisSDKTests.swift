//
//  JentisSDKTests.swift
//  JentisSDKTests
//
//  Created by Alexandre Oliveira on 07/10/2024.
//

import XCTest
@testable import JentisSDK

class JentisSDKTests: XCTestCase {

    // MARK: - Properties
    private var sut: TrackingService!

    // MARK: - Setup and Teardown
    override func setUpWithError() throws {
        try super.setUpWithError()

        // Initialize TrackConfig
        let config = TrackConfig(trackDomain: "testDomain", trackID: "testID", environment: .live)

        // Configure the JentisSDK (which initializes TrackingService)
        JentisService.configure(with: config)

        // Access the shared instance of TrackingService
        sut = TrackingService.shared
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func testSendConsentModelSuccess() async throws {
        // Expectation: sendConsentModel should succeed without throwing an error
        do {
            try await sut.sendConsentModel()
            // Success path, no error thrown
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }
    }
    
    func testSendDataSubmissionModelSuccess() async throws {
        // Expectation: sendDataSubmissionModel should succeed without throwing an error
        do {
            try await sut.sendDataSubmissionModel()
            // Success path, no error thrown
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }
    }
    
    func testSessionManagement() {
        // Test if the session is properly managed
        let sessionID = SessionManager.startOrResumeSession()
        
        XCTAssertNotNil(sessionID, "Expected a session ID but got nil")
        XCTAssertEqual(sessionID.count, 36, "Expected session ID to be a UUID of 36 characters")
        
        // Ensure the session is resumed if timeout hasn't occurred
        let resumedSessionID = SessionManager.startOrResumeSession()
        XCTAssertEqual(sessionID, resumedSessionID, "Expected the session to be resumed with the same ID")
    }
}
