//
//  FollowersListVM.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation
import Combine

extension FollowersListVC {
    
    class ViewModel: BaseVM {
        
        init(getFollowersUseCase: GetFollowersUseCaseProtocol, startUserName: String) {
            self.getFollowersUseCase = getFollowersUseCase
            self.userName = startUserName
            
            super.init()
            
            // setup search pipeline
            $searchKeyword.combineLatest($followers.dropFirst()) { keyword, followers in
                guard !keyword.isEmpty else { return followers }
                
                return followers.filter{ $0.username.lowercased().contains(keyword.lowercased()) }
            }
            .map{ [unowned self] in makeSnapshot(followers: $0) }
            .assign(to: \.snapshot, on: self)
            .store(in: &bag)
        }
        
        private let getFollowersUseCase: GetFollowersUseCaseProtocol

        private let pageSize = 30
        private var page = 0
        private(set) var isLastPage = false
        private(set) var userName: String
        
        /// Keeps track of already displayed followers, avoid potentially duplicated followers.
        private var displayedFollowersSet = Set<GitHub.SimpleUser>()
        
        @Published var searchKeyword = ""
        @Published private var followers: [GitHub.SimpleUser] = []
        @Published private(set) var snapshot: Snapshot?
        
        // MARK: - Interface Func
        
        @MainActor
        func fetchNextPageFollowers() async throws {
            guard !isLastPage, !isLoading else { return }
            
            page += 1
            isLoading = true
            defer { isLoading = false }
            
            do {
                let (users, lastPage) = try await getFollowersUseCase.getFollowers(of: userName,
                                                                                   page: page,
                                                                                   pageSize: pageSize)
                self.isLastPage = lastPage
                let newUsers = users.filter{ displayedFollowersSet.insert($0).inserted }
                if page == 1 {
                    self.followers = newUsers
                } else {
                    self.followers.append(contentsOf: newUsers)
                }
            } catch {
                page -= 1
                self.error = error
                throw error
            }
        }
        
        func refetchFirstPage() async throws {
            page = 0
            isLastPage = false
            displayedFollowersSet.removeAll()
            
            try await fetchNextPageFollowers()
            // wait at least (0.8) seconds before return, otherwise the UI refreshes too fast and appears broken
            try? await Task.sleep(nanoseconds: 800_000_000)
        }
        
        func changeUserName(new: String) {
            let old = userName
            userName = new
            
            Task {
                do {
                    try await refetchFirstPage()
                } catch {
                    userName = old
                }
            }
        }
        
        // MARK: - Snapshot Builder
        
        private func makeSnapshot(followers: [GitHub.SimpleUser]) -> Snapshot {
            var snap = Snapshot()
            
            snap.appendSections(SectionKind.allCases)
            
            snap.appendItems(followers, toSection: .followers)
            
            return snap
        }
        
    }
    
}
