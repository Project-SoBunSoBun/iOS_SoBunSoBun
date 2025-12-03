//
//  SearchTextField.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/12/25.
//

import UIKit
import SnapKit

class SearchTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let edgesPadding: CGFloat = 16
    
    private lazy var searchIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.frame = CGRect(x: edgesPadding, y: 0, width: 24, height: 24)
        iv.image = .lightblueMagnifyingGlass
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    private lazy var leftPadding: CGFloat = edgesPadding + searchIconImageView.frame.width + 8
    
    private lazy var leftContainer: UIView = UIView(frame: CGRect(x: edgesPadding, y: 0, width: edgesPadding + searchIconImageView.frame.width, height: searchIconImageView.frame.height))
    private lazy var rightContainer: UIView = UIView(frame: CGRect(x: 0, y: 0, width: edgesPadding, height: searchIconImageView.frame.height))
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        self.backgroundColor = .backgroundWhite
        
        // 그림자
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.primary300.cgColor
        self.layer.shadowOpacity = 0.16
        self.layer.shadowRadius = 24
        self.clipsToBounds = false
        
        // 모서리
        self.layer.cornerRadius = 16
        
        // 테두리
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.primary100.cgColor
        self.frame = CGRectInset(self.frame, -self.layer.borderWidth, -self.layer.borderWidth)
        
        // 폰트 설정
        self.font = body16.font
        
        // Placeholder
        var attributes: [NSAttributedString.Key: Any] = body16.attributes()
        attributes[.foregroundColor] = UIColor.primary200
        
        self.attributedPlaceholder = NSAttributedString(
            string: String(localized: "SearchSomething"),
            attributes: attributes
        )
        
        // 아이콘 설정
        leftContainer.addSubview(searchIconImageView)
        
        self.leftView = leftContainer
        self.leftViewMode = .always
        self.rightView = rightContainer
        self.rightViewMode = .always
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: edgesPadding, left: leftPadding, bottom: edgesPadding, right: 0))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    // MARK: - 커서 설정
    private var cursorLayer: CAShapeLayer?
    private let cursorLineWidth: CGFloat = 1.5
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        
        // 폰트 높이에 맞춤
        let fontHeight = self.font?.lineHeight ?? 20
        rect.size.height = fontHeight
        rect.size.width = cursorLineWidth
        
        // 수직 중앙 정렬
        rect.origin.y = (bounds.height - fontHeight) / 2
        
        return rect
    }
    
    private func updateCursorLayer() {
        // 기존 레이어 제거
        cursorLayer?.removeFromSuperlayer()
        
        // 실제 커서는 투명하게
        self.tintColor = .clear
        
        // 커스텀 레이어 추가
        guard isFirstResponder else { return }
        
        let position = self.position(from: self.beginningOfDocument, offset: (self.text?.count ?? 0))
        guard let position = position else { return }
        
        let rect = caretRect(for: position)
        
        let layer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: CGRect(x: rect.origin.x + leftPadding + 1, y: rect.origin.y, width: rect.width, height: rect.height), cornerRadius: cursorLineWidth / 2)
        
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
    
    // MARK: - 생명주기
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCursorLayer()
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 16).cgPath
    }
}
