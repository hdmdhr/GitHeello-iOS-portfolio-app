//
//  GitHub+SimpleUser.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-27.
//

import Foundation

/// A public namespace for all GitHub API related models.
/// Accessible from the presentation layer.
/// Prefer enum over struct and class to avoid accidental initialization.
public enum GitHub { }


public extension GitHub {
    
    struct SimpleUser: Decodable, Hashable {
        
        let id: Int
        /// Renamed from "login" field
        let username: String
        let avatarUrl: URL?
        let url, followersUrl: URL
        let type: UserType
        
        // omit the rest of the properties as not needed now
        
        // let followingUrl, gists_url: URL
        // let site_admin: Bool
        // ...
        
        enum CodingKeys: String, CodingKey {
            case id, avatarUrl, url, followersUrl, type
            case username = "login"
        }
        
    }
    
    enum UserType: String, Decodable, CaseIterableDefaultsLast {
        case user = "User"
        case other
    }
    
}
