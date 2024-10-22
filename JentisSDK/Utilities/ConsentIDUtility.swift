//
//  ConsentIDUtility.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 15/10/2024.
//

import Foundation
import Security

class ConsentIDUtility {

    private let consentIDKey: String  // Key is now passed via initialization
    
    // Initializer to accept the key as a parameter
    init(consentIDKey: String) {
        self.consentIDKey = consentIDKey
    }

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
        
        if status == errSecSuccess {
            LoggerUtility.shared.logInfo("Consent ID successfully stored in Keychain with key: \(consentIDKey).")
        } else {
            LoggerUtility.shared.logError("Error saving Consent ID to Keychain with key \(consentIDKey): \(status)")
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
            LoggerUtility.shared.logInfo("Consent ID successfully retrieved from Keychain with key: \(consentIDKey).")
            return consentID
        } else {
            LoggerUtility.shared.logWarning("No Consent ID found in Keychain with key \(consentIDKey) or error retrieving it: \(status)")
        }
        
        return nil
    }
    
    // Function to retrieve or generate the Consent ID
    func getConsentID() -> String {
        // Try to retrieve the Consent ID from Keychain
        if let storedConsentID = retrieveConsentIDFromKeychain() {
            LoggerUtility.shared.logDebug("Consent ID retrieved with key \(consentIDKey): \(storedConsentID)")
            return storedConsentID
        }
        
        // If Consent ID does not exist, generate a new one
        let newConsentID = generateUUID()
        LoggerUtility.shared.logInfo("Generated new Consent ID: \(newConsentID)")
        
        // Store the new Consent ID in Keychain
        storeConsentIDInKeychain(newConsentID)
        
        return newConsentID
    }
    
    // Function to set consent, which will automatically manage the Consent ID generation
    func setConsent() {
        let consentID = getConsentID()
        // Additional logic for handling consent can be added here
        LoggerUtility.shared.logInfo("Consent set with ID: \(consentID) and key: \(consentIDKey)")
    }
}
