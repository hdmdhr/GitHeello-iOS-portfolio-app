//
//  CDGitHubMessage+CoreDataProperties.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-03-01.
//
//

import Foundation
import CoreData


extension CDGitHubMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDGitHubMessage> {
        return NSFetchRequest<CDGitHubMessage>(entityName: "CDGitHubMessage")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var content: String?
    @NSManaged public var senderUserName: String?
    @NSManaged public var receiverUserName: String?

}

extension CDGitHubMessage : Identifiable {
    
    convenience init(context: NSManagedObjectContext, domain: GitHub.Message) {
        self.init(context: context)
        
        self.createdAt = domain.createdAt
        self.id = domain.id
        self.content = domain.content
        self.senderUserName = domain.senderUserName
        self.receiverUserName = domain.receiverUserName
    }
    
    func toDomain() -> GitHub.Message? {
        guard let id, let createdAt, let content, let senderUserName, let receiverUserName else { return nil }
        
        return .init(id: id,
                     createdAt: createdAt,
                     content: content,
                     senderUserName: senderUserName,
                     receiverUserName: receiverUserName)
    }
    
}
