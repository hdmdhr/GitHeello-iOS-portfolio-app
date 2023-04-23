//
//  NetworkError.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation

enum NetworkError: LocalizedError {
    
    /// Inner error is very likely to be an `EncodingError`
    case invalidRequest(innerError: Error)
    case decodingError(innerError: DecodingError, message: String?)
    case urlError(URLError)
    case unknown(innerError: Error)
    
    var errorDescription: String? {
        switch self {
        case .urlError(let urlError):
            return urlError.localizedDescription
            
        case .invalidRequest(let innerError), .unknown(let innerError):
            return innerError.localizedDescription
            
        case let .decodingError(decodingError, message):
            return message ?? decodingError.failureReason
        }
    }
    
}
