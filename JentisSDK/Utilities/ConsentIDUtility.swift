//
//  ConsentIDUtility.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 15/10/2024.
//

import Foundation

class ConsentIDUtility {
    private let consentIDKey: String

    init(consentIDKey: String) {
        self.consentIDKey = consentIDKey
    }
    
    private func generateUUID() -> String {
        return UUID().uuidString.lowercased()
    }
    
    // Function to store Consent ID in UserDefaults
    private func storeConsentIDInUserDefaults(_ consentID: String) {
        UserDefaultsUtility.saveSimple(consentID, forKey: consentIDKey)
        LoggerUtility.shared.logInfo("Consent ID successfully stored in UserDefaults with key: \(consentIDKey).")
    }
    
    // Function to retrieve Consent ID from UserDefaults
    private func retrieveConsentIDFromUserDefaults() -> String? {
        if let consentID = UserDefaultsUtility.getSimple(String.self, forKey: consentIDKey) {
            LoggerUtility.shared.logInfo("Consent ID successfully retrieved from UserDefaults with key: \(consentIDKey).")
            return consentID
        } else {
            LoggerUtility.shared.logWarning("No Consent ID found in UserDefaults with key \(consentIDKey).")
        }
        return nil
    }
    
    // Function to retrieve or generate the Consent ID with action
    func getConsentIDWithAction() -> (String, Action) {
        if let storedConsentID = retrieveConsentIDFromUserDefaults() {
            return (storedConsentID, .update)
        }
        
        let newConsentID = generateUUID()
        storeConsentIDInUserDefaults(newConsentID)
        return (newConsentID, .new)
    }
}
