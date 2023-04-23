//
//  MessageUseCase.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation
import Combine

public protocol MessageUseCaseProtocol {
    
    /// Retrieve history chatting messages.
    /// - Parameter after: An optional date, pass `nil` if want to fetch all history messages
    /// - Returns: History messages after the passed in date, will return `[]` if there is none.
    func retrieveHistoryMessagesBetween(userName1: String, userName2: String, after: Date?) async throws -> [GitHub.Message]
    
    /// Send a new message to another user.
    /// - Parameters:
    ///   - userName: The target user
    ///   - content: The text content of the message
    /// - Returns: A publisher that represents the delayed reply. In a real messaging app this probably should be achieve by listening to WebSocket events.
    func sendNewMessage(to receiverUserName: String,
                        from senderUserName: String,
                        content: String) -> AnyPublisher<GitHub.Message, Never>
}

// FIXME: - This implementation class should not be in Domain Layer but in presentation or composition layer.

class DummyMessageUseCase: MessageUseCaseProtocol {
    
    init(persistenceService: PersistenceServiceProtocol) {
        self.persistenceService = persistenceService
    }
    
    private let persistenceService: PersistenceServiceProtocol
    
    func retrieveHistoryMessagesBetween(userName1: String, userName2: String, after: Date?) async throws -> [GitHub.Message] {
        try await persistenceService.fetchMessagesBetween(senderUserName: userName1, receiverUserName: userName2)
    }
    
    func sendNewMessage(to receiverUserName: String,
                        from senderUserName: String,
                        content: String) -> AnyPublisher<GitHub.Message, Never> {
        let sendingMessage = GitHub.Message(content: content,
                                            senderUserName: senderUserName,
                                            receiverUserName: receiverUserName)
        
        let responseContent = [content, content].joined(separator: " ")
        let responseMessage = GitHub.Message(createdAt: .now + 1,
                                             content: responseContent,
                                             senderUserName: receiverUserName,
                                             receiverUserName: senderUserName)
        
        try? persistenceService.saveMessages([sendingMessage, responseMessage])
        
        return Just(responseMessage)
            .delay(for: 1.0, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}
