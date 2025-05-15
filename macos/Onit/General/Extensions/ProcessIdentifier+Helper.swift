//
//  ProcessIdentifier+Helper.swift
//  Onit
//
//  Created by Kévin Naudin on 13/05/2025.
//

import AppKit

extension pid_t {
    func getAppName() -> String? {
        NSRunningApplication(processIdentifier: self)?.localizedName
    }
    
    var bundleIdentifier: String? {
        NSRunningApplication(processIdentifier: self)?.bundleIdentifier
    }
}
