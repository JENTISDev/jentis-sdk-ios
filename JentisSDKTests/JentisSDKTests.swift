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
    private var sut: TrackingService.Type!

    // MARK: - Setup and Teardown
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = TrackingService.self
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func testSaveStringSuccess() async throws {
        let mockString = "Test string"
        
        do {
            try await sut.saveString(mockString)
            // Success path
        } catch {
            XCTFail("Expected success but got failure with error: \(error)")
        }
    }
    
    func testSaveStringFailsWithEmptyInput() async throws {
        let invalidString = "" // Invalid input for testing

        do {
            try await sut.saveString(invalidString)
            XCTFail("Expected failure but got success.")
        } catch {
            // Ensure error is received
            XCTAssertNotNil(error, "Expected an error but got nil.")
        }
    }
}