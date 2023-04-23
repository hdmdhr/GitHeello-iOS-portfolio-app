//
//  QueryItemsProvidable.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation

/// Conforming to this protocol means it can provide query parameters for an URL
/// Dictionaries with `String` type key conform to this protocol by default.
/// Encodable models are also good candidates for this protocol.
protocol QueryItemsProvidable {
    
    func queryItems() throws -> [URLQueryItem]
    /// Optional implementation
    var customQueryJsonEncoder: JSONEncoder { get }
    
}


extension QueryItemsProvidable {
    var customQueryJsonEncoder: JSONEncoder { .init() }
}



// MARK: - Default Conformation (Dictionary & Encodable)

extension Dictionary: QueryItemsProvidable where Key == String {
    
    func queryItems() -> [URLQueryItem] {
        reduce(into: [URLQueryItem]()) { queryItems, kv in
            queryItems.append(URLQueryItem(name: kv.key, value: "\(kv.value)"))
        }
    }
    
}


extension Encodable where Self: QueryItemsProvidable {
    
    func queryItems() throws -> [URLQueryItem] {
        let data = try customQueryJsonEncoder.encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        
        guard let dictionary = jsonObject as? [String: Any] else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not string keyed dictionary"])
        }
        
        return dictionary.queryItems()
    }
    
}
