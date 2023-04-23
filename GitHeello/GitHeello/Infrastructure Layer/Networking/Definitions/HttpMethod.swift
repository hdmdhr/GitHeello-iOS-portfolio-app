//
//  HttpMethod.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation

enum HttpMutableMethod: String {
    case POST, PUT, PATCH, DELETE
}

/// Represent common HTTP methods such as GET, POST, PUT, etc.
/// Follows Query & Command pattern, divided into a `.get` case and a `.mutable` case.
enum HttpMethod {
    case get(queryItemsProvider: QueryItemsProvidable?)
    case mutable(method: HttpMutableMethod, bodyDataProvider: BodyDataProvidable?)
    
    static let get: HttpMethod = .get(queryItemsProvider: nil)
    
    static func post(bodyDataProvider: BodyDataProvidable) -> HttpMethod {
        .mutable(method: .POST, bodyDataProvider: bodyDataProvider)
    }
    
    var method: String {
        switch self {
        case .get:
            return "GET"
            
        case let .mutable(method, _):
            return method.rawValue
        }
    }
}
