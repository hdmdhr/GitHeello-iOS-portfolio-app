//
//  PersistenceServiceProtocol.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-03-01.
//

import Foundation
import CoreData

public protocol PersistenceServiceProtocol {
    
    func fetchMessagesBetween(senderUserName: String, receiverUserName: String) async throws -> [GitHub.Message]
    func saveMessages(_ gitHubMessages: [GitHub.Message]) throws

}

class PersistenceService: PersistenceServiceProtocol {
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private let context: NSManagedObjectContext
    
    func fetchMessagesBetween(senderUserName: String, receiverUserName: String) async throws -> [GitHub.Message] {
        let fetchRequest: NSFetchRequest<CDGitHubMessage> = CDGitHubMessage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(senderUserName == %@ AND receiverUserName == %@) OR (senderUserName == %@ AND receiverUserName == %@)", senderUserName, receiverUserName, receiverUserName, senderUserName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        return try await context.perform {
            try self.context.fetch(fetchRequest).compactMap{ $0.toDomain() }
        }
    }

    func saveMessages(_ gitHubMessages: [GitHub.Message]) throws {
        _ = gitHubMessages.map{ CDGitHubMessage(context: context, domain: $0) }
        
        guard context.hasChanges else { return }
        
        try self.context.save()
    }

    
}
