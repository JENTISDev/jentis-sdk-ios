//
//  UserDefaultsUtilityTests.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 23/10/2024.
//

import XCTest
@testable import JentisSDK

class UserDefaultsUtilityTests: XCTestCase {
    
    let testKey = "com.yourapp.testKey"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Clear any previously stored data
        UserDefaultsUtility.remove(forKey: testKey)
    }

    override func tearDownWithError() throws {
        // Clear test data after each test
        UserDefaultsUtility.remove(forKey: testKey)
        try super.tearDownWithError()
    }
    
    // Test saving and retrieving a Codable object
    func testSaveAndGetCodable() throws {
        let testObject = TestCodable(name: "Test Name", value: 42)
        
        // When saving the object
        UserDefaultsUtility.save(testObject, forKey: testKey)
        
        // Then it should be retrievable
        let retrievedObject: TestCodable? = UserDefaultsUtility.get(TestCodable.self, forKey: testKey)
        
        XCTAssertNotNil(retrievedObject, "Expected non-nil object retrieved from UserDefaults")
        XCTAssertEqual(retrievedObject?.name, testObject.name, "Expected the name to match the saved value")
        XCTAssertEqual(retrievedObject?.value, testObject.value, "Expected the value to match the saved value")
    }
    
    // Test saving and retrieving a simple value (String)
    func testSaveAndGetSimpleString() throws {
        let testValue = "Test String"
        
        // When saving the simple value
        UserDefaultsUtility.saveSimple(testValue, forKey: testKey)
        
        // Then it should be retrievable
        let retrievedValue: String? = UserDefaultsUtility.getSimple(String.self, forKey: testKey)
        
        XCTAssertNotNil(retrievedValue, "Expected non-nil value retrieved from UserDefaults")
        XCTAssertEqual(retrievedValue, testValue, "Expected the value to match the saved value")
    }
    
    // Test saving and retrieving a simple value (Int)
    func testSaveAndGetSimpleInt() throws {
        let testValue = 12345
        
        // When saving the simple value
        UserDefaultsUtility.saveSimple(testValue, forKey: testKey)
        
        // Then it should be retrievable
        let retrievedValue: Int? = UserDefaultsUtility.getSimple(Int.self, forKey: testKey)
        
        XCTAssertNotNil(retrievedValue, "Expected non-nil value retrieved from UserDefaults")
        XCTAssertEqual(retrievedValue, testValue, "Expected the value to match the saved value")
    }
    
    // Test saving and retrieving a simple value (Bool)
    func testSaveAndGetSimpleBool() throws {
        let testValue = true
        
        // When saving the simple value
        UserDefaultsUtility.saveSimple(testValue, forKey: testKey)
        
        // Then it should be retrievable
        let retrievedValue: Bool? = UserDefaultsUtility.getSimple(Bool.self, forKey: testKey)
        
        XCTAssertNotNil(retrievedValue, "Expected non-nil value retrieved from UserDefaults")
        XCTAssertEqual(retrievedValue, testValue, "Expected the value to match the saved value")
    }
    
    // Test removing a value from UserDefaults
    func testRemoveValue() throws {
        let testValue = "Test Value"
        
        // When saving the value
        UserDefaultsUtility.saveSimple(testValue, forKey: testKey)
        
        // Then remove it
        UserDefaultsUtility.remove(forKey: testKey)
        
        // The value should no longer exist
        let retrievedValue: String? = UserDefaultsUtility.getSimple(String.self, forKey: testKey)
        
        XCTAssertNil(retrievedValue, "Expected nil after removing the value from UserDefaults")
    }
    
    // Test checking existence of a key
    func testExistsForKey() throws {
        let testValue = "Test Value"
        
        // Initially, the key should not exist
        XCTAssertFalse(UserDefaultsUtility.exists(forKey: testKey), "Expected false since the key doesn't exist yet")
        
        // When saving the value
        UserDefaultsUtility.saveSimple(testValue, forKey: testKey)
        
        // Then the key should exist
        XCTAssertTrue(UserDefaultsUtility.exists(forKey: testKey), "Expected true since the key exists")
    }
}

// A simple Codable struct for testing saving and retrieving Codable objects
struct TestCodable: Codable {
    let name: String
    let value: Int
}
