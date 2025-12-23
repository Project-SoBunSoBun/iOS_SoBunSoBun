//
//  TextFieldUnderline.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/11/25.
//

import UIKit

class TextFieldUnderline: BaseTextField {
    private let maxLength: Int
    
    init(frame: CGRect = .zero, maxLength: Int) {
        self.maxLength = maxLength
        
        super.init(frame: frame, fontStyle: body16)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let underlineLayer = CALayer()
    
    private func configureUI() {
        self.delegate = self
        
        self.borderStyle = .none
        self.textColor = .neutral900
        
        // underline
        underlineLayer.backgroundColor = UIColor.primary100.cgColor
        self.layer.addSublayer(underlineLayer)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(
            top: 16,
            left: 0,
            bottom: 16,
            right: 0
        ))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let underlineHeight: CGFloat = 1
        underlineLayer.frame = CGRect(x: 0, y: bounds.height - underlineHeight, width: bounds.width, height: underlineHeight)
    }
}

extension TextFieldUnderline: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // 글자 수 제한 체크
        return updatedText.count <= maxLength
    }
}
