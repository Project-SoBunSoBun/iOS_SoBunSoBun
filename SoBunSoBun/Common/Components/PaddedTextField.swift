//
//  PaddedTextField.swift
//  SoBunSoBun
//
//  Created by 허성필 on 12/12/25.
//

import UIKit

final class PaddedTextField: UITextField {
    private let padding = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    
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
