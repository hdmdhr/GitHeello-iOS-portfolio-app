//
//  CoordinatorProtocol.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit

protocol CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController { get }

    func start()
}

enum TransitionType {
    case push
    case modal
}
