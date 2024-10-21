//
//  UserIDUtility.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 15/10/2024.
//

import Foundation
import Security

class UserIDUtility {

    private let userIDKey = "com.yourapp.userID"
    
    // Function to generate UUID similar to the uuidv4 function
    private func generateUUID() -> String {
        return UUID().uuidString.lowercased()
    }

    // Function to store User ID in Keychain
    private func storeUserIDInKeychain(_ userID: String) {
        let data = Data(userID.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: userIDKey,
            kSecValueData as String: data
        ]
        
        // Add the new User ID to the Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Error saving User ID to Keychain: \(status)")
        }
    }
    
    // Function to retrieve User ID from Keychain
    private func retrieveUserIDFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: userIDKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data, let userID = String(data: data, encoding: .utf8) {
            return userID
        }
        
        return nil
    }
    
    // Function to retrieve or generate the User ID
    func getUserID() -> String {
        // Try to retrieve the User ID from Keychain
        if let storedUserID = retrieveUserIDFromKeychain() {
            return storedUserID
        }
        
        // If User ID does not exist, generate a new one
        let newUserID = generateUUID()
        
        // Store the new User ID in Keychain
        storeUserIDInKeychain(newUserID)
        
        return newUserID
    }
    
    // Function to set User ID, which will automatically manage the User ID generation
    func setUserID() {
        let userID = getUserID()
        // Additional logic for handling user identification can be added here
        print("User ID: \(userID)") // Example usage
    }
}

