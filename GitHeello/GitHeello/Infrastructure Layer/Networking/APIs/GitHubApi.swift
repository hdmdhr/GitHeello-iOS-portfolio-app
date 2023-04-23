//
//  GitHubApi.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation

/// Namespace for GitHub API
enum GitHubApi: ApiProtocol {
    
    /// FIXEME: if using a private API, consider hiding API url via environment variable
    static let baseUrl: URL = .init(string: "https://api.github.com/")!
    
    /// Include all /users endpoints
    enum Users: RawRepresentable, EndpointProtocol {
        static let baseUrl: URL = GitHubApi.baseUrl.appending(path: lowercaseName)
        
        case followers(userName: String)
        /// Dummy endpoint for messaging
        case chat(userName: String)
        
        var rawValue: String {
            switch self {
            case .followers(let userName), .chat(let userName):
                return [userName, caseName].joined(separator: "/")
            }
        }
    }
    
}
