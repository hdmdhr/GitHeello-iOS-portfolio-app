//
//  GitHub+Message.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation

public extension GitHub {
    
    struct Message: Decodable, Hashable {
        
        var id: UUID = .init()
        var createdAt: Date = .init()
        let content: String
        let senderUserName, receiverUserName: String
        
    }
    
}
