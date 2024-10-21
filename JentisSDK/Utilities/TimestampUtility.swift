//
//  TimestampUtility.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 22/10/2024.
//

import Foundation

public class TimestampUtility {

    /// Returns the current timestamp in milliseconds since 1970 as an Int.
    public static func currentTimestampInMillis() -> Int {
        return Int(Date().timeIntervalSince1970 * 1000)
    }
}
