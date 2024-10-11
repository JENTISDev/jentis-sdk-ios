//
//  UserAgentUtility.swift
//  JentisSDK
//
//  Created by Alexandre Oliveira on 11/10/2024.
//

import Foundation
import UIKit

final class UserAgentUtility {
    
    static var userAgent: String {
        return buildUserAgent(sdkName: "JentisSDK", sdkVersion: "1.0", buildNumber: "100")
    }
    
    static func buildUserAgent(sdkName: String, sdkVersion: String, buildNumber: String) -> String {
        
        // Get OS version and device information
        let systemName = UIDevice.current.systemName // e.g., "iOS"
        let systemVersion = UIDevice.current.systemVersion // e.g., "16.4"
        let deviceModel = UIDevice.current.model // e.g., "iPhone"
        let architecture = getArchitecture() // e.g., "x86_64" (simulator) or "arm64" (real device)

        // Example app-specific values (you can change these)
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "UnknownApp"
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        
        // Construct the User-Agent string
        let userAgent = "\(sdkName)/\(sdkVersion)(Build: \(buildNumber)) \(systemName)/\(systemVersion) \(deviceModel)/\(architecture) \(appName)/\(appVersion)"
        
        return userAgent
    }
    
    // Helper method to get the device's architecture (arm64, x86_64, etc.)
    private static func getArchitecture() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        let machine = withUnsafePointer(to: &sysinfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        return machine ?? "unknown"
    }
}
