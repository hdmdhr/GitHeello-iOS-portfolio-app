//
//  ImageLabelCollectionViewCell.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit

class ImageLabelCollectionViewCell: UICollectionViewListCell {

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    func configure(imageUrl: URL?, handle: String?, font: UIFont? = nil) {
        if let font {
            label.font = font
        }
        
        Task { @MainActor in
            imageView.isShimmering = true
            do {
                let image = try await ImageCacher.shared.image(for: imageUrl)
                imageView.image = image
            } catch {
                imageView.image = .init(systemName: "person.fill")
            }
            imageView.isShimmering = false
        }
        
        label.text = ["@", handle].compactMap{$0}.joined()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        imageView.isShimmering = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.image = nil
    }
    
}
