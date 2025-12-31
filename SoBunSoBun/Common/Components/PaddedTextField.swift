//
//  PaddedTextField.swift
//  SoBunSoBun
//
//  Created by 허성필 on 12/12/25.
//

import UIKit

class PaddedTextField: UITextField {
    var padding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    func configurePadding(width: Int) {
        padding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: CGFloat(24 + width))
        
        layoutSubviews()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
}
