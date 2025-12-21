//
//  TextFieldUnderline.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/11/25.
//

import UIKit

class TextFieldUnderline: UITextField {
    private let maxLength: Int
    
    init(frame: CGRect = .zero, maxLength: Int) {
        self.maxLength = maxLength
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let underlineLayer = CALayer()
    
    private func configureUI() {
        self.delegate = self
        
        self.borderStyle = .none
        self.font = body16.font
        self.textColor = .neutral900
        
        // 커서 숨기기
        self.tintColor = .clear
        
        // underline
        underlineLayer.backgroundColor = UIColor.primary100.cgColor
        self.layer.addSublayer(underlineLayer)
    }
    
    func setPlaceholder(_ text: String) {
        var attributes: [NSAttributedString.Key: Any] = body16.attributes()
        attributes[.foregroundColor] = UIColor.neutral300
        
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: body16.attributes())
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
    
    // 커서 설정
    private var cursorLayer: CAShapeLayer?
    private let cursorLineWidth: CGFloat = 1.5
    
    private func updateCursorLayer() {
        // 기존 레이어 제거
        cursorLayer?.removeFromSuperlayer()
        cursorLayer = nil
        
        // 커스텀 레이어 추가
        guard isFirstResponder else { return }
        
        guard let selectedRange = selectedTextRange else { return }
        
        var caretRect = self.firstRect(for: selectedRange)
        caretRect = self.convert(caretRect, from: self.textInputView)
        
        let fontHeight = self.font?.lineHeight ?? 20
        
        let layer = CAShapeLayer()
        let path = UIBezierPath(
            roundedRect: CGRect(
                x: caretRect.origin.x + 1,
                y: caretRect.origin.y,
                width: cursorLineWidth,
                height: fontHeight
            ), cornerRadius: cursorLineWidth / 2
        )
        
        layer.path = path.cgPath
        layer.strokeColor = UIColor.primary400.cgColor
        layer.fillColor = UIColor.primary400.cgColor
        layer.lineWidth = cursorLineWidth
        
        // 깜빡이는 애니메이션
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        layer.add(animation, forKey: "blink")
        
        self.layer.addSublayer(layer)
        cursorLayer = layer
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        updateCursorLayer()
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        cursorLayer?.removeFromSuperlayer()
        cursorLayer = nil
        return result
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let underlineHeight: CGFloat = 1
        underlineLayer.frame = CGRect(x: 0, y: bounds.height - underlineHeight, width: bounds.width, height: underlineHeight)
        
        updateCursorLayer()
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
