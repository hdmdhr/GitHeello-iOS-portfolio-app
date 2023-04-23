//
//  CaseIterable+DefaultLast.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-27.
//

import Foundation

/// Decodable enums conforming to this protocol will fall back on the last case if decoding failed.
public protocol CaseIterableDefaultsLast: Decodable & CaseIterable & RawRepresentable
where RawValue: Decodable, AllCases: BidirectionalCollection { }

public extension CaseIterableDefaultsLast {
    init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
