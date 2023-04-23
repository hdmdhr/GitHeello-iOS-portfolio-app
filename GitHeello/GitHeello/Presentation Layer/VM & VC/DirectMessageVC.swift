//
//  DirectMessageVC.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit

class DirectMessageVC: BaseVC, BindableVC {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var messageInput: MessageInput = .init(placeholder: .Placeholder.messageInput.localized,
                                                        buttonTitle: .Verb.send.localized)
    
    private lazy var constraint_stackViewBottom: NSLayoutConstraint = {
        let constraint = stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        constraint.isActive = true
        return constraint
    }()
    
    // MARK: - Definitions
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, GitHub.Message>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionKind, GitHub.Message>
    typealias MessageCellRegistration = UICollectionView.CellRegistration<MessageCollectionViewCell, GitHub.Message>
    
    enum SectionKind {
        case main
    }
    
    // MARK: - Vars
    
    var vm: ViewModel!
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMessageInput()
        setupCollectionView()
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        messageInput.textField.layer.cornerRadius = messageInput.textField.bounds.height / 2
    }
    
    private func setupMessageInput() {
        stackView.insertArrangedSubview(messageInput, at: 1)
        
        // activate lazy constraint
        _ = constraint_stackViewBottom
    }
    
    private func setupCollectionView() {
        collectionView.setCollectionViewLayout(makeLayout(), animated: false)
        
        collectionView.allowsSelection = false
        
        collectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }

    // MARK: - Binding
    
    func bindViewModel() {
        bindPreLoadingToCenterSpinner()
        
        // listen to keyboard expand notification
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                else { return }
                
                let keyboardHeight = keyboardFrame.height
                self?.constraint_stackViewBottom.constant = -keyboardHeight
                self?.view.layoutIfNeeded()
            }
            .store(in: &bag)
        
        // listen to keyboard collapse notification
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.constraint_stackViewBottom.constant = 0
            }
            .store(in: &bag)
        
        // bind snapshot to collection view dataSource
        vm.$snapshot
            .compactMap{ $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.collectionView.toggleEmptyMessage(isEmpty: snapshot.itemIdentifiers.isEmpty,
                                                        message: .Placeholder.noMessage.localized)?
                    .transform = CGAffineTransform(scaleX: 1, y: -1)
                
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &bag)
        
        // disable sending empty message
        messageInput.textField.textPublisher
            .removeDuplicates()
            .map{ !($0 ?? "").isEmpty }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: messageInput.sendButton)
            .store(in: &bag)
        
        // tap send button will send and clear message
        messageInput.sendButton
            .publisher(for: .touchUpInside)
            .throttle(for: 1, scheduler: DispatchQueue.main, latest: true)
            .merge(with: messageInput.textField.publisher(for: .primaryActionTriggered)
                .throttle(for: 1, scheduler: DispatchQueue.main, latest: true))
            .sink { [weak self] _ in
                guard let text = self?.messageInput.textField.text else { return }
                
                self?.vm.sendMessage(text: text)
                self?.messageInput.textField.text = nil
                self?.messageInput.sendButton.isEnabled = false
//                self?.view.endEditing(true)
            }
            .store(in: &bag)
        
        Task {
            await vm.loadHistoryMessages()
        }
    }

    // MARK: - Layout
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(250))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return .init(section: section)
    }
    
    // MARK: - Cell Register
    
    private func makeMessageCellRegistration() -> MessageCellRegistration {
        .init(cellNib: MessageCollectionViewCell.nib) { [unowned self] cell, indexPath, message in
            cell.configure(text: message.content, isMine: vm.myUserName == message.senderUserName)
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
    }
    
    // MARK: - DataSource
    
    private func makeDataSource() -> DataSource {
        let cellRegistration = makeMessageCellRegistration()
        
        return .init(collectionView: collectionView) { collectionView, indexPath, message in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: message)
        }
    }

}
