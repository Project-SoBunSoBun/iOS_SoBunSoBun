//
//  BaseTextField.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/23/25.
//

import UIKit

class BaseTextField: UITextField {
    let fontStyle: FontStyle
    let showCursor: Bool
    
    init(frame: CGRect, fontStyle: FontStyle, showCursor: Bool = true) {
        self.fontStyle = fontStyle
        self.showCursor = showCursor
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var placeholder: String? {
        didSet {
            guard let text = placeholder else {
                super.placeholder = nil
                super.attributedPlaceholder = nil
                return
            }
            
            var attributes: [NSAttributedString.Key: Any] = fontStyle.attributes()
            attributes[.foregroundColor] = UIColor.neutral400
            
            self.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
        }
    }
    
    private func configureUI() {
        // 폰트 설정
        self.font = fontStyle.font
        
        // 텍스트 색
        self.textColor = .neutral900
        
        // 커서 숨김
        self.tintColor = .clear
    }
    
    // 커서 설정
    private var cursorLayer: CAShapeLayer?
    private let cursorLineWidth: CGFloat = 1.5
    
    private func updateCursorLayer() {
        // 기존 레이어 제거
        cursorLayer?.removeFromSuperlayer()
        cursorLayer = nil
        
        // 커스텀 레이어 추가
        guard showCursor, isFirstResponder else { return }
        
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
        updateCursorLayer()
    }
}
