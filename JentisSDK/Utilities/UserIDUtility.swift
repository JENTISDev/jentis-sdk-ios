//
//  UserIDUtility.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 15/10/2024.
//

import Foundation

class UserIDUtility {
    private let userIDKey: String
    
    init(userIDKey: String) {
        self.userIDKey = userIDKey
    }
    
    // Function to generate UUID
    private func generateUUID() -> String {
        return UUID().uuidString.lowercased()
    }
    
    // Function to store User ID in UserDefaults
    private func storeUserIDInUserDefaults(_ userID: String) {
        UserDefaultsUtility.saveSimple(userID, forKey: userIDKey)
        LoggerUtility.shared.logInfo("User ID successfully stored in UserDefaults with key: \(userIDKey).")
    }
    
    // Function to retrieve User ID from UserDefaults
    private func retrieveUserIDFromUserDefaults() -> String? {
        if let userID = UserDefaultsUtility.getSimple(String.self, forKey: userIDKey) {
            LoggerUtility.shared.logInfo("User ID successfully retrieved from UserDefaults with key: \(userIDKey).")
            return userID
        } else {
            LoggerUtility.shared.logWarning("No User ID found in UserDefaults with key \(userIDKey).")
            return nil
        }
    }
    
    // Function to retrieve or generate the User ID
    func getUserIDWithAction() -> (String, Action) {
        // Try to retrieve the User ID from UserDefaults
        if let storedUserID = retrieveUserIDFromUserDefaults() {
            return (storedUserID, .update)
        }
        
        // If User ID does not exist, generate a new one
        let newUserID = generateUUID()
        storeUserIDInUserDefaults(newUserID)
        return (newUserID, .new)
    }
}

