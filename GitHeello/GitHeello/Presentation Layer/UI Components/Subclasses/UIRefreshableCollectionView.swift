//
//  UIRefreshableCollectionView.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit

class UIRefreshableCollectionView: UICollectionView {
    
    private var onRefresh: (() async throws -> Void)?
    
    func setupRefresh(tintColor: UIColor,
                      title: String? = .Phrase.reloading.localized,
                      onRefresh: @escaping () async throws -> Void)
    {
        alwaysBounceVertical = true
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = tintColor
        refreshControl?.backgroundColor = .clear
        if let title {
            refreshControl?.attributedTitle = .init(string: title, attributes: [.foregroundColor: tintColor])
        }
        refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.onRefresh = onRefresh
    }
    
    @objc
    private func didPullToRefresh(_ sender: UIRefreshControl) {
        Task {
            try? await onRefresh?()
            sender.endRefreshing()
        }
    }
    
}
