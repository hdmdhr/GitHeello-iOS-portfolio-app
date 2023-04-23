//
//  UICollectionView+SetEmptyMessage.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit

extension UICollectionView {
    
    @discardableResult
    func toggleEmptyMessage(isEmpty: Bool, message: String) -> UILabel? {
        if isEmpty {
            let label = UILabel()
            label.font = .preferredFont(forTextStyle: .title3)
            label.textAlignment = .center
            label.text = message
            backgroundView = label
            return label
        } else {
            backgroundView = nil
            return nil
        }
    }
    
}
