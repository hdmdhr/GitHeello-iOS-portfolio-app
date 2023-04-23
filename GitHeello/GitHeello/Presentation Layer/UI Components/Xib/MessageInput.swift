//
//  MessageInput.swift
//  GitHeello
//
//  Created by Daniel Hu on 2023-02-28.
//

import UIKit

class MessageInput: UIView {

    @IBOutlet weak var textField: PaddedTextField!
    @IBOutlet weak var sendButton: UIButton!
    
    init(placeholder: String?, buttonTitle: String) {
        super.init(frame: .zero)
        
        xibSetup()
        
        textField.placeholder = placeholder
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        textField.autocapitalizationType = .sentences
        // set corner radius after moved into super view
        
        sendButton.setTitle(buttonTitle, for: [])
        sendButton.isEnabled = !textField.text!.isEmpty
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
