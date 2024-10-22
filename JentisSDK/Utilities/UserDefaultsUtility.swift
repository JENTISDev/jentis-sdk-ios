//
//  UserDefaultsUtility.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 22/10/2024.
//

import Foundation

class UserDefaultsUtility {

    // MARK: - Save Data
    
    /// Save a value to UserDefaults for a given key
    static func save<T>(_ value: T, forKey key: String) where T: Codable {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    /// Save a simple value like String, Int, Bool
    static func saveSimple<T>(_ value: T, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    // MARK: - Retrieve Data

    /// Retrieve a Codable object from UserDefaults for a given key
    static func get<T>(_ type: T.Type, forKey key: String) -> T? where T: Codable {
        if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let loadedObject = try? decoder.decode(T.self, from: savedData) {
                return loadedObject
            }
        }
        return nil
    }

    /// Retrieve a simple value like String, Int, Bool
    static func getSimple<T>(_ type: T.Type, forKey key: String) -> T? {
        return UserDefaults.standard.value(forKey: key) as? T
    }

    // MARK: - Remove Data
    
    /// Remove a value from UserDefaults for a given key
    static func remove(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - Check if a key exists
    
    /// Check if a value exists for a given key
    static func exists(forKey key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
