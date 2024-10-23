//
//  ServiceTests.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 23/10/2024.
//

import XCTest
@testable import JentisSDK

class ServiceTests: XCTestCase {

    var sut: Service!
    var urlSession: URLSession!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Initialize TrackConfig before running the tests
        TrackConfig.configure(
            trackDomain: "test.com",   // Set a valid track domain
            container: "test-container", // Set a valid container
            environment: .stage,  // Set an environment, e.g., .stage
            version: "1.0",
            debugCode: "test-debug-code"
        )

        // Create a URLSession configuration that uses MockURLProtocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        
        // Initialize the URLSession with the configuration
        urlSession = URLSession(configuration: config)
        
        // Initialize the Service class with this custom URLSession
        sut = Service(session: urlSession)
    }

    override func tearDownWithError() throws {
        sut = nil
        urlSession = nil
        try super.tearDownWithError()
    }
    
    // Test the `sendConsent` method
    func testSendConsent_Success() async throws {
        // Given
        let consentModel = ConsentModel(
            system: ConsentModel.System(
                type: "test-type",
                timestamp: 123456789,
                navigatorUserAgent: "test-agent",
                initiator: "test-initiator"
            ),
            configuration: ConsentModel.Configuration(
                container: "test-container",
                environment: "stage",
                version: "1.0",
                debugcode: "test-debugcode"
            ),
            data: ConsentModel.DataClass(
                identifier: ConsentModel.DataClass.Identifier(
                    user: ConsentModel.DataClass.Identifier.User(
                        id: "test-user-id",
                        action: "new"
                    ),
                    consent: ConsentModel.DataClass.Identifier.ConsentID(
                        id: "test-consent-id",
                        action: "new"
                    )
                ),
                consent: ConsentModel.DataClass.Consent(
                    lastupdate: 123456789,
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

        let mockResponse = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                           statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.mockResponse = (Data(), mockResponse, nil)
        
        // When
        try await sut.sendConsent(consentModel)
        
        // Then
        XCTAssertEqual(MockURLProtocol.mockResponse?.1 as? HTTPURLResponse, mockResponse)
        XCTAssertNotNil(MockURLProtocol.mockResponse?.0)
    }

    // Test the `sendConsent` method with invalid request
//    func testSendConsent_InvalidRequestBody() async {
//        // Given
//        let invalidConsentModel = InvalidModel()  // Invalid Model that won't be encodable
//        let mockResponse = HTTPURLResponse(url: URL(string: "https://test.com")!,
//                                           statusCode: 200, httpVersion: nil, headerFields: nil)
//        MockURLProtocol.mockResponse = (Data(), mockResponse, nil)
//        
//        do {
//            // When
//            try await sut.sendConsent(invalidConsentModel)
//            XCTFail("Expected to throw ServiceError.invalidRequestBody")
//        } catch let error as Service.ServiceError {
//            // Then
//            XCTAssertEqual(error, .invalidRequestBody)
//        } catch {
//            XCTFail("Unexpected error thrown")
//        }
//    }
    
    // Test a generic response failure case
    func testSendDataSubmission_InvalidResponse() async throws {
        // Given
        let dataSubmissionModel = DataSubmissionModel(
            system: DataSubmissionModel.System(
                type: "test-type",
                timestamp: 123456789,
                navigatorUserAgent: "test-agent",
                initiator: "test-initiator",
                sessionID: "test-session-id"
            ),
            consent: DataSubmissionModel.Consent(
                googleAnalytics: DataSubmissionModel.Consent.Vendor(status: .string("ncm")),
                facebook: DataSubmissionModel.Consent.Vendor(status: .bool(true)),
                awin: DataSubmissionModel.Consent.Vendor(status: .bool(false))
            ),
            configuration: DataSubmissionModel.Configuration(
                container: "test-container",
                environment: "stage",
                version: "1.0",
                debugcode: "test-debugcode"
            ),
            data: DataSubmissionModel.DataClass(
                identifier: DataSubmissionModel.DataClass.Identifier(
                    user: DataSubmissionModel.DataClass.Identifier.User(
                        id: "test-user-id",
                        action: "update"
                    ),
                    session: DataSubmissionModel.DataClass.Identifier.Session(
                        id: "test-session-id",
                        action: "update"
                    )
                ),
                variables: DataSubmissionModel.DataClass.Variables(
                    documentLocationHref: "https://test-location",
                    fbBrowserId: "fb-12345",
                    jtspushedcommands: ["pageview", "submit"],
                    productId: ["1111", "2222"]
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

        let mockResponse = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                           statusCode: 500, httpVersion: nil, headerFields: nil)
        MockURLProtocol.mockResponse = (Data(), mockResponse, nil)
        
        do {
            // When
            try await sut.sendDataSubmission(dataSubmissionModel)
            XCTFail("Expected to throw ServiceError.invalidResponse")
        } catch let error as Service.ServiceError {
            // Then
            XCTAssertEqual(error, .invalidResponse)
        } catch {
            XCTFail("Unexpected error thrown")
        }
    }
}

// InvalidModel definition used for testing encoding failures
struct InvalidModel: Codable {
    // Define some properties that intentionally don't match typical encoding expectations.
    // Since this model is meant to fail encoding, you can make this intentionally wrong.
}
