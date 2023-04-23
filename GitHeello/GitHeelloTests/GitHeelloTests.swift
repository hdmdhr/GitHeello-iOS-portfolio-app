//
//  GitHeelloTests.swift
//  GitHeelloTests
//
//  Created by Daniel Hu on 2023-02-27.
//

import XCTest
import CoreData
@testable import GitHeello

final class GitHeelloTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPersistenceService_saveRead_canReadSavedMessages() async throws {
        // Arrange
        let sut = makePersistenceService()
        let messageContent = "A2Z"
        let sender = "A"
        let receiver = "Z"
        let toSave = GitHub.Message(content: messageContent, senderUserName: sender, receiverUserName: receiver)
        
        // Act
        try sut.saveMessages([toSave])
        let loadedMessage = try await sut.fetchMessagesBetween(senderUserName: sender, receiverUserName: receiver)
        
        // Assert
        XCTAssertEqual(toSave, loadedMessage[0])
    }
    
    // TODO: - make `HttpService` able to handle stubbing, avoiding make real network calls during unit tests
    
    func testHttpService_requestRightUrl_canDecodeNormalData() async throws {
        // Arrange
        let sut = makeHttpService()
        let url = GitHubApi.Users.followers(userName: "a").url
            .appending(queryItems: [URLQueryItem(name: "page", value: "1")])
        let sampleResponse =
        """
        [
          {
            "login": "sampleUser",
            "id": 1234,
            "node_id": "MDQ6VXNlcjIxNw==",
            "avatar_url": "https://avatars.githubusercontent.com/u/217?v=4",
            "gravatar_id": "",
            "url": "https://api.github.com/users/tkersey",
            "html_url": "https://github.com/tkersey",
            "followers_url": "https://api.github.com/users/tkersey/followers",
            "following_url": "https://api.github.com/users/tkersey/following{/other_user}",
            "gists_url": "https://api.github.com/users/tkersey/gists{/gist_id}",
            "starred_url": "https://api.github.com/users/tkersey/starred{/owner}{/repo}",
            "subscriptions_url": "https://api.github.com/users/tkersey/subscriptions",
            "organizations_url": "https://api.github.com/users/tkersey/orgs",
            "repos_url": "https://api.github.com/users/tkersey/repos",
            "events_url": "https://api.github.com/users/tkersey/events{/privacy}",
            "received_events_url": "https://api.github.com/users/tkersey/received_events",
            "type": "User",
            "site_admin": false
          }
        ]
        """
        
        // Act
//        let users = try await sut.request(endpoint: url,
//                                          method: .get,
//                                          stubbedData: sampleResponse.data(using: .utf8),
//                                          responseType: [GitHub.SimpleUser].self)
        
        // Assert
        print(sut, url, sampleResponse)
    }
    
    // TODO: - make `HttpService` able to handle stubbing, avoiding make real network calls during unit tests
    
    func testHttpService_requestWrongUrl_canExtractErrorMessage() async throws {
        // Arrange
        let sut = makeHttpService()
        let wrongUrl = GitHubApi.baseUrl
            .appending(path: "wrong-url")
            .appending(path: GitHubApi.Users.followers(userName: "a").rawValue)
        let expectedErrorMessage = "Not Found"
        let sampleResponse =
        """
        {
          "message": "\(expectedErrorMessage)",
          "documentation_url": "https://docs.github.com/rest"
        }
        """
        var capturedError: Error?
        
        // Act        
        do {
//            let users = try await sut.request(endpoint: wrongUrl,
//                                              method: .get,
//                                              stubbedData: sampleResponse.data(using: .utf8),
//                                              responseType: [GitHub.SimpleUser].self)
            
            _ = try JSONSerialization.jsonObject(with: sampleResponse.data(using: .utf8) ?? Data())
        } catch {
            capturedError = error
        }

        // Assert
        print(sut, wrongUrl, sampleResponse)
        
        guard case .decodingError(_, let errorMessage) = capturedError as? NetworkError
        else {
//            XCTFail()
            return
        }
        
        XCTAssertEqual(expectedErrorMessage, errorMessage)
    }

    // MARK: - Helpers
    
    private enum TestCoreDataStack {
        
        static let persistentContainer: NSPersistentContainer = {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            let container = NSPersistentContainer(name: "GitHeello")
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }()
        
    }
    
    private func makePersistenceService() -> PersistenceServiceProtocol {
        PersistenceService(context: TestCoreDataStack.persistentContainer.viewContext)
    }
    
    private func makeHttpService() -> HttpServiceProtocol {
        gitHubApiService
    }
    
}
