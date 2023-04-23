//
//  PaddedTextField.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit


/// An `UITextField` subclass which has some inner padding.
class PaddedTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
