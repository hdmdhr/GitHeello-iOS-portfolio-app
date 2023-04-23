//
//  BaseVC.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit
import Combine

/// Base class that all custom `UIViewController` should inherit from
class BaseVC: UIViewController {
    
    /// A dispose bag for all Combine subscriptions
    var bag: Set<AnyCancellable> = []
    
    /// An activity indicator (spinner) in the center of the view.
    private(set) lazy var centerSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        view.bringSubviewToFront(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
            
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    deinit {
        print(Self.identifier, " deinited")
    }
    
}
