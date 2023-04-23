//
//  BindableVC.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit

/// A view controller has an associated ViewModel.
protocol BindableVC: UIViewController {
    associatedtype ViewModelType
    
    var vm: ViewModelType! { get set }
    
    init(vm: ViewModelType)
    func bindViewModel()
}

// MARK: - Default Init

extension BindableVC {
    
    init(vm: ViewModelType) {
        self.init(nibName: Self.identifier, bundle: nil)
        
        self.vm = vm
        loadViewIfNeeded()
        bindViewModel()
    }
    
}

// MARK: - Default Bindings

extension BindableVC where ViewModelType: BaseVM, Self: BaseVC {
    
    /// Present an iOS default alert for the emitted error.
    func bindErrorsToAlert() {
        vm.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                let alert = UIAlertController(
                    title: .Phrase.errorOccurred.localized,
                    message: error.localizedDescription,
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self?.present(alert, animated: true)
            }
            .store(in: &bag)
    }
    
    func bindLoadingToCenterSpinner() {
        vm.$isLoading
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.centerSpinner.startAnimating()
                } else {
                    self?.centerSpinner.stopAnimating()
                }
            }
            .store(in: &bag)
    }
    
    func bindPreLoadingToCenterSpinner() {
        vm.$isPreLoading
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.centerSpinner.startAnimating()
                } else {
                    self?.centerSpinner.stopAnimating()
                }
            }
            .store(in: &bag)
    }
}
