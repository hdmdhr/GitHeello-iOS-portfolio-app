//
//  AppCoordinator.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit
import CoreData

/// Scene base coordinator, Singleton.
class AppCoordinator: CoordinatorProtocol {
    
    var childCoordinators = [CoordinatorProtocol]()
    let navigationController: UINavigationController = {
        let nv = UINavigationController()
        nv.navigationBar.prefersLargeTitles = true
        return nv
    }()

    static let shared: AppCoordinator = .init()
    
    private init() { }

    func start() {
        // offset back button title away to match the mockup
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000.0, vertical: 0.0), for: .default)
        
        transition(to: .followersList(userName: "hmlongco"), type: .push, animated: false)
    }
    
    func transition(to scene: Scene, type: TransitionType, animated: Bool) {
        switch type {
        case .push:
            navigationController.pushViewController(scene.viewController(), animated: animated)
            
        case .modal:
            navigationController.present(scene.viewController(), animated: animated)
        }
    }
    
    enum Scene {
        case followersList(userName: String)
        case directMessage(myUserName: String, theirUserName: String)
        
        func viewController() -> UIViewController {
            switch self {
            case .followersList(let userName):
                let useCase = GetFollowersUseCase(httpService: gitHubApiService)
                let vc = FollowersListVC(vm: .init(getFollowersUseCase: useCase, startUserName: userName))
                vc.title = .Phrase.appName.localized
                
                return vc
                
            case let .directMessage(myUserName, theirUserName):
                let service = PersistenceService(context: AppCoordinator.shared.persistentContainer.viewContext)
                let useCase = DummyMessageUseCase(persistenceService: service)
                let vc = DirectMessageVC(vm: .init(messageUseCase: useCase,
                                                   myUserName: myUserName,
                                                   theirUserName: theirUserName))
                vc.title = "@" + theirUserName
                
                return vc
            }
        }
    }
    
    
    // MARK: - Core Data stack

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GitHeello")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
