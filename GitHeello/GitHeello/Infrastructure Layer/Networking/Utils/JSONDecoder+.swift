//
//  JSONDecoder+.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-27.
//

import Foundation

extension JSONDecoder {
    
    /// A static `JSONDecoder` to decode data returned from GitHub API.
    static let gitHubApi: JSONDecoder = {
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        return decoder
    }()
    
}
