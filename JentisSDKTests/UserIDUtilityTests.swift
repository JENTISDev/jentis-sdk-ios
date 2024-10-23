//
//  UserIDUtilityTests.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 23/10/2024.
//

import XCTest
@testable import JentisSDK

class UserIDUtilityTests: XCTestCase {

    var sut: UserIDUtility!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = UserIDUtility(userIDKey: "com.yourapp.testUserID")
        clearTestUserIDFromUserDefaults()
    }

    override func tearDownWithError() throws {
        clearTestUserIDFromUserDefaults()
        sut = nil
        try super.tearDownWithError()
    }
    
    // Helper method to clear UserID from UserDefaults for testing
    private func clearTestUserIDFromUserDefaults() {
        UserDefaultsUtility.remove(forKey: "com.yourapp.testUserID")
    }
    
    // Test generating a new UserID
    func testGetUserIDWithAction_GeneratesNewUserID() throws {
        let (userID, action) = sut.getUserIDWithAction()
        
        XCTAssertEqual(action, .new, "Expected action to be .new for a newly generated UserID")
        XCTAssertNotNil(userID, "Expected non-nil UserID")
        XCTAssertFalse(userID.isEmpty, "Expected a non-empty UserID")
        
        let storedUserID = retrieveTestUserIDFromUserDefaults()
        XCTAssertEqual(storedUserID, userID, "Expected the stored UserID to match the generated one")
    }
    
    // Test retrieving an existing UserID
    func testGetUserIDWithAction_RetrievesExistingUserID() throws {
        let expectedUserID = "test-existing-user-id"
        storeTestUserIDInUserDefaults(expectedUserID)
        
        let (userID, action) = sut.getUserIDWithAction()
        
        XCTAssertEqual(action, .update, "Expected action to be .update for an existing UserID")
        XCTAssertEqual(userID, expectedUserID, "Expected to retrieve the existing UserID")
    }
    
    // Helper method to store a UserID in UserDefaults for testing
    private func storeTestUserIDInUserDefaults(_ userID: String) {
        UserDefaultsUtility.saveSimple(userID, forKey: "com.yourapp.testUserID")
    }
    
    // Helper method to retrieve a UserID from UserDefaults
    private func retrieveTestUserIDFromUserDefaults() -> String? {
        return UserDefaultsUtility.getSimple(String.self, forKey: "com.yourapp.testUserID")
    }
}
