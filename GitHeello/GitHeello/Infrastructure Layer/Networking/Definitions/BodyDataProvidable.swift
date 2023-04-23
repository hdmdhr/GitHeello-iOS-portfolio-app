//
//  BodyDataProvidable.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation

/// Conforming to this protocol means it can provide body data for an `URLRequest`.
/// Dictionary conforms to this protocol by default.
/// Encodable models are also good candidates for this protocol.
protocol BodyDataProvidable {
    
    func bodyData() throws -> Data
    /// Optional implementation
    var customBodyJsonEncoder: JSONEncoder { get }
    
}


extension BodyDataProvidable {
    var customBodyJsonEncoder: JSONEncoder { .init() }
}


// MARK: - Default Conformation (Encodable & Dictionary)


extension Encodable where Self: BodyDataProvidable {
    
    func bodyData() throws -> Data {
        try customBodyJsonEncoder.encode(self)
    }
    
}


extension Dictionary: BodyDataProvidable {
    
    func bodyData() throws -> Data {
        try JSONSerialization.data(withJSONObject: self, options: [])
    }
    
}
