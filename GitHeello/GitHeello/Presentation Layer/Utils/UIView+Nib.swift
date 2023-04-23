//
//  UIView+Nib.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit

extension NSObject {
    
    class var identifier: String {
        return String(describing: self)
    }
    
}

extension UIView {
   
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
}
