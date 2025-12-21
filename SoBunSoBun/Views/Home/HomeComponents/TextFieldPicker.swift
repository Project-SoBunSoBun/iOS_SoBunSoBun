//
//  TextFieldPicker.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/16/25.
//

import UIKit
import SnapKit

class TextFieldPicker: UITextField {
    init(frame: CGRect = .zero, icon: UIImage) {
        super.init(frame: frame)
        configureUI(icon: icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let rightDecoView: UIImageView = {
        let iv = UIImageView(frame: .init(x: 0, y: 0, width: 24, height: 24))
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    private lazy var rightPadding: CGFloat = 10 + rightDecoView.frame.width + 10
    
    private lazy var leftContainer: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: rightDecoView.frame.height))
    private lazy var rightContainer: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10 + rightDecoView.frame.width, height: rightDecoView.frame.height))
    
    private func configureUI(icon: UIImage) {
        self.backgroundColor = .backgroundWhite
        
        // 모서리
        self.layer.cornerRadius = 16
        
        // 테두리
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.primary100.cgColor
        self.frame = CGRectInset(self.frame, -self.layer.borderWidth, -self.layer.borderWidth)
        
        // 폰트 설정
        self.font = body16.font
        
        // 아이콘 설정
        rightDecoView.image = icon
        rightContainer.addSubview(rightDecoView)
        
        self.leftView = leftContainer
        self.leftViewMode = .always
        self.rightView = rightContainer
        self.rightViewMode = .always
        
        // 입력 방지
        self.inputView = UIView()
        self.tintColor = .clear
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 16, left: 10, bottom: 16, right: rightPadding))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rightDecoView.center = CGPoint(
            x: rightDecoView.frame.width / 2,
            y: rightContainer.bounds.height / 2
        )
    }
    
    // 입력 방지
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
}
