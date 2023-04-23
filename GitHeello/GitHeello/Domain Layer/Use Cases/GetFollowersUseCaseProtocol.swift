//
//  GetFollowersUseCase.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation

public protocol GetFollowersUseCaseProtocol {
    func getFollowers(of userName: String,
                      page: Int,
                      pageSize: Int) async throws -> (followers: [GitHub.SimpleUser], isLastPage: Bool)
}

// FIXME: - This implementation class should not be in Domain Layer but in presentation or composition layer, as domain layer is the core layer and should not depend on any layers. But I am leaving it here to make the app structure easier to follow.
class GetFollowersUseCase: GetFollowersUseCaseProtocol {
    
    init(httpService: HttpServiceProtocol) {
        self.httpService = httpService
    }
    
    
    private let httpService: HttpServiceProtocol
    
    func getFollowers(of userName: String,
                      page: Int,
                      pageSize: Int) async throws -> (followers: [GitHub.SimpleUser], isLastPage: Bool)
    {
        let query = ["page": page, "per_page": pageSize]
        
        let followers = try await
        httpService.request(endpoint: GitHubApi.Users.followers(userName: userName),
                            method: .get(queryItemsProvider: query),
                            responseType: [GitHub.SimpleUser].self)
        
        return (followers, followers.count < pageSize)
    }
    
}
