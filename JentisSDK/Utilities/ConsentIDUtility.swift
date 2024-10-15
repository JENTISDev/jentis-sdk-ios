//
//  ConsentIDUtility.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 15/10/2024.
//

import Foundation
import Security

class ConsentIDUtility {

    private let consentIDKey = "com.yourapp.consentID"
    
    // Function to generate UUID similar to the uuidv4 function
    private func generateUUID() -> String {
        return UUID().uuidString.lowercased()
    }

    // Function to store Consent ID in Keychain
    private func storeConsentIDInKeychain(_ consentID: String) {
        let data = Data(consentID.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: consentIDKey,
            kSecValueData as String: data
        ]
        
        // Add the new Consent ID to the Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Error saving Consent ID to Keychain: \(status)")
        }
    }
    
    // Function to retrieve Consent ID from Keychain
    private func retrieveConsentIDFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: consentIDKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data, let consentID = String(data: data, encoding: .utf8) {
            return consentID
        }
        
        return nil
    }
    
    // Function to retrieve or generate the Consent ID
    func getConsentID() -> String {
        // Try to retrieve the Consent ID from Keychain
        if let storedConsentID = retrieveConsentIDFromKeychain() {
            return storedConsentID
        }
        
        // If Consent ID does not exist, generate a new one
        let newConsentID = generateUUID()
        
        // Store the new Consent ID in Keychain
        storeConsentIDInKeychain(newConsentID)
        
        return newConsentID
    }
    
    // Function to set consent, which will automatically manage the Consent ID generation
    func setConsent() {
        let consentID = getConsentID()
        // Additional logic for handling consent can be added here
        print("Consent ID: \(consentID)") // Example usage
    }
}
