//
//  UICollectionView+MaxIndexPath.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit

extension UICollectionView {
    
    var maxIndexPath: IndexPath? {
        guard numberOfSections >= 1 else { return nil }
        
        let section = numberOfSections - 1
        let items = numberOfItems(inSection: section)
        let item = max(0, items - 1)
        
        return .init(item: item, section: section)
    }
    
}
