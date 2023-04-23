//
//  MessageCollectionViewCell.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit

class MessageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var rightBubbleImageView: UIImageView!
    @IBOutlet weak var leftBubbleImageView: UIImageView!
    
    @IBOutlet var constraint_textContainerTrailing: NSLayoutConstraint!
    @IBOutlet var constraint_textContainerLeading: NSLayoutConstraint!
    
    func configure(text: String, isMine: Bool) {
        textView.text = text
        
        textContainer.backgroundColor = .init(named: isMine ? "bubble.blue" : "bubble.gray")
        rightBubbleImageView.isHidden = !isMine
        leftBubbleImageView.isHidden = isMine
        
        // disable and remove old constraints
        constraint_textContainerLeading.isActive = false
        constraint_textContainerTrailing.isActive = false
        
        if isMine {
            constraint_textContainerLeading = textContainer.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 45)
            constraint_textContainerTrailing = textContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        } else {
            constraint_textContainerTrailing = textContainer.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -45)
            constraint_textContainerLeading = textContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15)
        }
        
        // enable new constraints
        constraint_textContainerLeading.isActive = true
        constraint_textContainerTrailing.isActive = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textContainer.layer.cornerRadius = 15
    }
    
}
