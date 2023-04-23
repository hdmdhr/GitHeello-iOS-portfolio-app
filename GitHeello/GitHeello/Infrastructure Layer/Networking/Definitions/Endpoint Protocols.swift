//
//  Endpoint Protocols.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation

// MARK: - ApiProtocol

protocol ApiProtocol {
    static var baseUrl: URL { get }
}

extension ApiProtocol {
    static var lowercaseName: String { String(describing: Self.self).lowercased() }
}

// MARK: - UrlConvertible

protocol UrlConvertible {
    var url: URL { get }
}

extension URL: UrlConvertible {
    var url: URL { self }
}

// MARK: - EndpointProtocol

protocol EndpointProtocol: ApiProtocol, UrlConvertible { }

/// When a enum has `String` type raw value and conforms to `EndpointProtocol`, use it's raw value as the path to build the endpoint url.
extension RawRepresentable where RawValue == String, Self: EndpointProtocol {
    
    var url: URL { Self.baseUrl.appendingPathComponent(rawValue) }
    var caseName: String { String(describing: self).components(separatedBy: "(")[0] }
    
    init?(rawValue: String) { nil }

}
