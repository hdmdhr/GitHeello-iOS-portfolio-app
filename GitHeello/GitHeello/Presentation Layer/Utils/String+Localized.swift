//
//  String+Localized.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation

protocol Localizable: RawRepresentable where RawValue == String {
    var key: String { get }
    var localized: String { get }
}

extension Localizable {
    
    var key: String {
        [
            String(describing: Self.self).lowercased(),
            rawValue
        ].joined(separator: ".")
    }
    
    var localized: String { key.localized() }
    
}

extension String {
    
    func localized(comment: String = "") -> String {
        NSLocalizedString(self, comment: comment)
    }
    
    /// Namespace for "phrase." localized strings
    enum Phrase: String, Localizable {
        case reloading = "reloadingEllipsis"
        case errorOccurred
        case changeAccount
        case appName
    }
    
    /// Namespace for "placeholder." localized strings
    enum Placeholder: String, Localizable {
        case typeToSearchUsers
        case messageInput
        case noFollower
        case noMessage
        case enterNewUsername
    }
    
    /// Namespace for "verb." localized strings
    enum Verb: String, Localizable {
        case send
        case change
        case cancel
    }
    
}
