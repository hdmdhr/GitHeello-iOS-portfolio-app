//
//  FollowersListVC.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit

class FollowersListVC: BaseVC, BindableVC {

    @IBOutlet weak var collectionView: UIRefreshableCollectionView!
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = .Placeholder.typeToSearchUsers.localized
        bar.searchTextField.autocapitalizationType = .none
        return bar
    }()
    
    // MARK: - Definitions
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, GitHub.SimpleUser>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionKind, GitHub.SimpleUser>
    typealias FollowerCellRegistration = UICollectionView.CellRegistration<ImageLabelCollectionViewCell, GitHub.SimpleUser>
    
    enum SectionKind: CaseIterable {
        case followers
    }
    
    // MARK: - Vars
    
    private lazy var dataSource = makeDataSource()
    
    var vm: ViewModel!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        navigationItem.titleView = searchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: .Verb.change.localized,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(changeUserName))
    }
    
    private func setupCollectionView() {
        collectionView.setupRefresh(tintColor: .secondaryLabel, onRefresh: vm.refetchFirstPage)
        
        collectionView.setCollectionViewLayout(makeLayout(), animated: false)
        
        collectionView.prefetchDataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.keyboardDismissMode = .onDrag
    }

    // MARK: - Helpers
    
    @objc private func changeUserName() {
        let alertController = UIAlertController(title: .Phrase.changeAccount.localized,
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = .Placeholder.enterNewUsername.localized
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self, weak alertController] _ in
            guard let newUserName = alertController?.textFields?.first?.text else {
                return
            }
            
            self?.vm.changeUserName(new: newUserName)
        }
        
        let cancelAction = UIAlertAction(title: .Verb.cancel.localized, style: .cancel)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    // MARK: - Binding
    
    func bindViewModel() {
        bindErrorsToAlert()
        bindLoadingToCenterSpinner()
        
        // bind search keyword input
        searchBar.searchTextField.textPublisher
            .replaceNil(with: "")
            .removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .assign(to: \.searchKeyword, on: vm)
            .store(in: &bag)
        
        // bind snapshot to dataSource
        vm.$snapshot
            .compactMap{ $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.collectionView.toggleEmptyMessage(isEmpty: snapshot.itemIdentifiers.isEmpty,
                                                        message: .Placeholder.noFollower.localized)
                
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &bag)
        
        // update layout when device rotates
        NotificationCenter
            .default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.collectionViewLayout.invalidateLayout()
            }
            .store(in: &bag)
        
        // fetch the 1st page after setting up Combine pipeline
        Task {
            try? await vm.refetchFirstPage()
        }
    }
    
    // MARK: - Layout
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        .init { sectionIndex, environment in
            switch UIDevice.current.orientation {
                // portrait mode and other, use single column layout
            case .portrait, .portraitUpsideDown, .unknown:
                // list `NSCollectionLayoutSection` has a small background view issue, hence build a custom section
//                return .list(using: .init(appearance: .plain), layoutEnvironment: environment)
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, repeatingSubitem: item, count: 1)
                
                return .init(group: group)
                
                // landscape mode, use dual columns layout
            default:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(150))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: itemSize.heightDimension)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
                
                return .init(group: group)
            }
        }
    }
    
    // MARK: - Cell Register
    
    private func makeFollowerCellRegistration() -> FollowerCellRegistration {
        .init(cellNib: ImageLabelCollectionViewCell.nib) { cell, indexPath, user in
            cell.configure(imageUrl: user.avatarUrl, handle: user.username)
            cell.accessories = [.disclosureIndicator()]
        }
    }
    
    // MARK: - DataSource

    private func makeDataSource() -> DataSource {
        let followerCellRegistration = makeFollowerCellRegistration()
        
        return .init(collectionView: collectionView) { cv, indexPath, user in
            cv.dequeueConfiguredReusableCell(using: followerCellRegistration, for: indexPath, item: user)
        }
    }
    
}

// MARK: - Collection Delegate & Prefetch

extension FollowersListVC: UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let user = vm.snapshot?.itemIdentifiers(inSection: .followers)[indexPath.item] else { return }
        
        AppCoordinator.shared.transition(to: .directMessage(myUserName: vm.userName, theirUserName: user.username),
                                         type: .push,
                                         animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard !vm.isLoading,
              !vm.isLastPage,
              let maxIndexPathToLoad = indexPaths.max(),
              let maxIndexPathInView = collectionView.maxIndexPath,
              maxIndexPathToLoad >= maxIndexPathInView
        else { return }
        
        Task {
            try? await vm.fetchNextPageFollowers()
        }
    }
    
}
