//
//  BaseTextField.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 12/23/25.
//

import UIKit

class BaseTextField: UITextField {
    let fontStyle: FontStyle
    let showCursor: Bool
    private var editMenuInteraction: UIEditMenuInteraction?
    
    init(frame: CGRect, fontStyle: FontStyle, showCursor: Bool = true) {
        self.fontStyle = fontStyle
        self.showCursor = showCursor
        super.init(frame: frame)
        
        configureUI()
        setupEmptyTextMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var placeholder: String? {
        didSet {
            setPlaceholder()
        }
    }
    
    var placeholderColor: UIColor = .neutral400 {
        didSet {
            setPlaceholder()
        }
    }
    
    private func setPlaceholder() {
        guard let text = placeholder else {
            super.placeholder = nil
            super.attributedPlaceholder = nil
            return
        }
        
        var attributes: [NSAttributedString.Key: Any] = fontStyle.attributes()
        attributes[.foregroundColor] = placeholderColor
        
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
    }
    
    private func configureUI() {
        self.font = fontStyle.font
        self.textColor = .neutral900
    }
    
    // 빈 텍스트일 때 롱프레스 시 컨텍스트 메뉴를 수동으로 표시
    // iOS 내부 UITextInteraction은 선택할 텍스트가 없으면 메뉴를 트리거하지 않으므로 직접 처리
    private func setupEmptyTextMenu() {
        let interaction = UIEditMenuInteraction(delegate: self)
        addInteraction(interaction)
        editMenuInteraction = interaction

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleEmptyTextLongPress(_:)))
        longPress.delegate = self
        
        addGestureRecognizer(longPress)
    }

    @objc private func handleEmptyTextLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, (text ?? "").isEmpty else { return }

        if !isFirstResponder {
            _ = becomeFirstResponder()
        }

        let location = gesture.location(in: self)

        guard let interaction = editMenuInteraction else { return }

        let config = UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
        interaction.presentEditMenu(with: config)
    }
    
    // 시스템 커서 숨김 (tintColor를 clear로 하면 스페이스바 트랙패드 모드가 비활성화되므로 caretRect로 처리)
    // origin은 유지하여 context menu가 올바른 위치에 앵커되도록 함
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size = .zero
        
        return rect
    }
    
    // 커서 설정
    private var cursorLayer: CAShapeLayer?
    private let cursorLineWidth: CGFloat = 1.5
    
    private func updateCursorLayer() {
        cursorLayer?.removeFromSuperlayer()
        cursorLayer = nil
        
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
    
    override var selectedTextRange: UITextRange? {
        didSet {
            updateCursorLayer()
        }
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

extension BaseTextField: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}

extension BaseTextField: UIEditMenuInteractionDelegate {}
