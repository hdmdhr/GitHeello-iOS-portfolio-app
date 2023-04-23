//
//  BaseVM.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import Foundation
import Combine

/// A simple base class which all view model classes should inherit from.
class BaseVM: ObservableObject {
    
    /// Usually bind this to spinner
    @MainActor @Published var isLoading = false
    /// Usually use this to show/hide pre-loading skeleton views
    @MainActor @Published var isPreLoading = false
    @MainActor @Published var error: Error?
    
    /// A dispose bag for all Combine subscriptions
    var bag: Set<AnyCancellable> = []
    
    deinit {
        print(String(describing: Self.self), " deinited")
    }
    
}
