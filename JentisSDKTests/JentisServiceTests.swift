//
//  JentisServiceTests.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 24/10/2024.
//

import XCTest
@testable import JentisSDK
import UIKit

class JentisServiceTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Reset configuration before each test to ensure a clean state
        TrackConfig.clearConfigFromUserDefaults()
    }

    override func tearDownWithError() throws {
        // Clean up after each test
        TrackConfig.clearConfigFromUserDefaults()
        try super.tearDownWithError()
    }

    func testSendConsentModel() async throws {
        // Given
        let config = TrackConfig(
            trackDomain: "test-domain.com",
            container: "test-container",
            environment: .stage,
            version: "1.0.0",
            debugCode: "test-debug-code"
        )
        JentisService.configure(with: config)
        TrackingService.initialize()

        // Mock the sendConsent method
        let serviceMock = MockService()
        let trackingService = TrackingService.shared
        trackingService.setService(serviceMock)

        // When
        try await trackingService.sendConsentModel()

        // Then
        XCTAssertTrue(serviceMock.sendConsentCalled, "Expected sendConsent to be called")
    }

    func testSendDataSubmissionModel() async throws {
        // Given
        let config = TrackConfig(
            trackDomain: "test-domain.com",
            container: "test-container",
            environment: .stage,
            version: "1.0.0",
            debugCode: "test-debug-code"
        )
        JentisService.configure(with: config)
        TrackingService.initialize()

        // Mock the sendDataSubmission method
        let serviceMock = MockService()
        let trackingService = TrackingService.shared
        trackingService.setService(serviceMock)

        // When
        try await trackingService.sendDataSubmissionModel()

        // Then
        XCTAssertTrue(serviceMock.sendDataSubmissionCalled, "Expected sendDataSubmission to be called")
    }
}

// Mock Service class to simulate network operations
class MockService: Service {
    var sendConsentCalled = false
    var sendDataSubmissionCalled = false

    override func sendConsent(_ consentModel: ConsentModel) async throws {
        sendConsentCalled = true
    }

    override func sendDataSubmission(_ dataSubmissionModel: DataSubmissionModel) async throws {
        sendDataSubmissionCalled = true
    }
}
