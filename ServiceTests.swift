//
//  ServiceTests.swift
//  JentisSDKTests
//
//  Created by Alexandre Oliveira on 07/10/2024.
//

import XCTest
@testable import JentisSDK

class ServiceTests: XCTestCase {

    // MARK: - Properties
    var sut: Service!
    var session: URLSession!

    // MARK: - Setup and Teardown
    override func setUp() {
        super.setUp()
        session = createMockSession()
        sut = createService(session: session)
    }

    override func tearDown() {
        sut = nil
        session = nil
        MockURLProtocol.mockResponse = nil
        super.tearDown()
    }

    // MARK: - Helper Methods
    private func createMockSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    private func createService(session: URLSession) -> Service {
        return Service(session: session)
    }

    private func validURL() -> URL {
        guard let url = URL(string: "https://us-central1-mobilesdklogging.cloudfunctions.net/saveString") else {
            fatalError("Valid URL could not be created.")
        }
        return url
    }

    private func createMockResponse(statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: validURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    // MARK: - Tests

    func testSendStringSuccess() async throws {
        // Given
        let mockResponseData = "{\"message\":\"String stored successfully!\"}".data(using: .utf8)
        let mockURLResponse = createMockResponse(statusCode: 200)
        MockURLProtocol.mockResponse = (mockResponseData, mockURLResponse, nil)

        // When / Then
        do {
            try await sut.sendString("Test string")
            // Success path
        } catch {
            XCTFail("Expected success but got failure with error: \(error)")
        }
    }

    func testSendStringFailsWithServerError() async throws {
        // Given
        let mockURLResponse = createMockResponse(statusCode: 400)
        MockURLProtocol.mockResponse = (nil, mockURLResponse, nil)

        // When / Then
        do {
            try await sut.sendString("Test string")
            XCTFail("Expected failure but got success.")
        } catch {
            XCTAssertNotNil(error, "Expected an error but got nil.")
        }
    }

    func testServiceFailsWithInvalidURL() async throws {
        // Given
        let invalidURLString = "https :// invalid-url"
        sut = Service(urlString: invalidURLString, session: session)

        // When / Then
        do {
            try await sut.sendString("Test")
            XCTFail("Expected failure due to invalid URL, but got success.")
        } catch {
            XCTAssertEqual(error as? Service.ServiceError, .invalidURL, "Expected invalidURL error but got: \(error)")
        }
    }
}
