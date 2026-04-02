//
//  AppVersion.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 4/1/26.
//

import Foundation

enum AppVersion {
    static var current: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? String(localized: "Unknown", table: "Common")
    }
    
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? String(localized: "Unknown", table: "Common")
    }
}
