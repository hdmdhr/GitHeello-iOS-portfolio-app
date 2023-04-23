//
//  UIView+XibSetup.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//


import UIKit

extension UIView {
    
    /// Helper method to init and setup the view from the Nib.
    func xibSetup(useConstraints: Bool = true) {
        let view = loadFromNib()
        backgroundColor = .clear
        addSubview(view)
        
        if useConstraints {
            translatesAutoresizingMaskIntoConstraints = !useConstraints
            stretch(view: view)
        } else {
            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    /// Method to init the view from a Nib.
    /// - Returns: UIView initialized from the Nib of the same class name.
    func loadFromNib<T: UIView>() -> T {
        let nibName = String(describing: Self.self)
        let nib = UINib(nibName: nibName, bundle: .init(for: Self.self))
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? T else {
            fatalError("Error loading nib with name \(nibName)")
        }
        return view
    }
    
    /// Stretches the input view to the UIView frame using Auto-layout
    func stretch(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
