//
//  ConsentIDUtilityTests.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 23/10/2024.
//

import XCTest
@testable import JentisSDK

class ConsentIDUtilityTests: XCTestCase {
    
    var sut: ConsentIDUtility!
    let consentIDKey = "com.yourapp.testConsentID"

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ConsentIDUtility(consentIDKey: consentIDKey)
        
        // Clear the stored ConsentID from UserDefaults before each test
        clearTestConsentIDFromUserDefaults()
    }

    override func tearDownWithError() throws {
        // Clear the stored ConsentID from UserDefaults after each test
        clearTestConsentIDFromUserDefaults()
        sut = nil
        try super.tearDownWithError()
    }

    // Helper method to clear ConsentID from UserDefaults for testing
    private func clearTestConsentIDFromUserDefaults() {
        UserDefaultsUtility.remove(forKey: consentIDKey)
    }

    // Test generating a new ConsentID
    func testGetConsentIDWithAction_GeneratesNewConsentID() throws {
        // When no ConsentID exists in UserDefaults
        let (consentID, action) = sut.getConsentIDWithAction()

        // Then a new ConsentID is generated and action should be .new
        XCTAssertEqual(action, .new, "Expected action to be .new for a newly generated ConsentID")
        XCTAssertNotNil(consentID, "Expected non-nil ConsentID")
        XCTAssertFalse(consentID.isEmpty, "Expected a non-empty ConsentID")
        
        // Check if the generated ConsentID is stored in UserDefaults
        let storedConsentID = retrieveTestConsentIDFromUserDefaults()
        XCTAssertEqual(storedConsentID, consentID, "Expected the stored ConsentID to match the generated one")
    }

    // Test retrieving an existing ConsentID
    func testGetConsentIDWithAction_RetrievesExistingConsentID() throws {
        // Given an existing ConsentID in UserDefaults
        let expectedConsentID = "test-existing-consent-id"
        storeTestConsentIDInUserDefaults(expectedConsentID)
        
        // When ConsentID is retrieved
        let (consentID, action) = sut.getConsentIDWithAction()

        // Then it should return the stored ConsentID and action should be .update
        XCTAssertEqual(action, .update, "Expected action to be .update for an existing ConsentID")
        XCTAssertEqual(consentID, expectedConsentID, "Expected to retrieve the existing ConsentID")
    }

    // Helper method to store a ConsentID in UserDefaults for testing
    private func storeTestConsentIDInUserDefaults(_ consentID: String) {
        UserDefaultsUtility.saveSimple(consentID, forKey: consentIDKey)
    }

    // Helper method to retrieve a ConsentID from UserDefaults
    private func retrieveTestConsentIDFromUserDefaults() -> String? {
        return UserDefaultsUtility.getSimple(String.self, forKey: consentIDKey)
    }
}
