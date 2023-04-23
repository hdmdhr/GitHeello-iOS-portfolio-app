//
//  DirectMessageVM.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation
import Combine

extension DirectMessageVC {
    
    class ViewModel: BaseVM {
        init(messageUseCase: MessageUseCaseProtocol, myUserName: String, theirUserName: String) {
            self.messageUseCase = messageUseCase
            self.myUserName = myUserName
            self.theirUserName = theirUserName
        }
        
        
        private let messageUseCase: MessageUseCaseProtocol
        
        let myUserName, theirUserName: String
        
        private var displayedMessagesSet = Set<GitHub.Message>()
        
        @Published private(set) var snapshot: Snapshot?
        
        // MARK: - Interface Func
        
        @MainActor
        func loadHistoryMessages() async {
            isPreLoading = true
            defer { isPreLoading = false }
            
            do {
                let messages = try await messageUseCase.retrieveHistoryMessagesBetween(userName1: myUserName, userName2: theirUserName, after: nil)
                snapshot = makeSnapshot(moreMessages: messages)
            } catch {
                self.error = error
            }
        }
        
        func sendMessage(text: String) {
            snapshot = makeSnapshot(moreMessages: [GitHub.Message(content: text,
                                                                  senderUserName: myUserName,
                                                                  receiverUserName: theirUserName)])
            
            messageUseCase.sendNewMessage(to: theirUserName, from: myUserName, content: text)
                .map{ [$0] }
                .map(makeSnapshot(moreMessages:))
                .assign(to: \.snapshot, on: self)
                .store(in: &bag)
        }
        
        // MARK: - Snapshot Builder
        
        private func makeSnapshot(moreMessages: [GitHub.Message]) -> Snapshot {
            var snap = Snapshot()
            
            snap.appendSections([.main])
            
            let newMessages = moreMessages.filter{ displayedMessagesSet.insert($0).inserted }
            
            // insert new messages before old ones, as the collection is reversed
            snap.appendItems(newMessages + (snapshot?.itemIdentifiers ?? []),
                             toSection: .main)
            
            return snap
        }
        
    }
    
}
