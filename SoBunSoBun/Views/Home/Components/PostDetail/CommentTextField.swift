//
//  CommentTextField.swift
//  SoBunSoBun
//
//  Created by 김태은 on 1/27/26.
//

import UIKit

class CommentTextField: BaseTextField {
    init(frame: CGRect = .zero) {
        super.init(frame: frame, fontStyle: body16)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let edgesPadding: CGFloat = 16
    
    let sendButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .greySend
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let btn = UIButton(configuration: config)
        btn.frame = CGRect(x: 8, y: 0, width: 48, height: 48)
        
        return btn
    }()
    
    private lazy var rightPadding: CGFloat = 4 + sendButton.frame.width + 8
    
    private lazy var leftContainer: UIView = UIView(frame: CGRect(x: edgesPadding, y: 0, width: edgesPadding, height: sendButton.frame.height))
    private lazy var rightContainer: UIView = UIView(frame: CGRect(x: 0, y: 0, width: rightPadding, height: sendButton.frame.height))
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        self.backgroundColor = .neutral50
        
        // 모서리
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        
        // Placeholder
        self.placeholder = String(localized: "InsertYourComment", table: "Home")
        
        // 아이콘 설정
        rightContainer.addSubview(sendButton)
        
        self.leftView = leftContainer
        self.leftViewMode = .always
        self.rightView = rightContainer
        self.rightViewMode = .always
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: edgesPadding, left: edgesPadding, bottom: edgesPadding, right: rightPadding))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
