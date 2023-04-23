//
//  Data+PrettyString.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation

extension Data {
    
    var prettyJsonString: String? {
        guard let jsonObj = try? JSONSerialization.jsonObject(with: self, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObj, options: [.prettyPrinted]),
              let jsonString = String(data: prettyData, encoding: .utf8)
        else { return nil }
        
        return jsonString
    }
    
}

extension Encodable {
    
    var prettyJsonString: String? {
        guard let data = try? JSONEncoder().encode(self), let string = data.prettyJsonString else { return nil }
        
        return string
    }
    
}
