//
//  SearchTextField.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 11/12/25.
//

import UIKit
import SnapKit

class SearchTextField: BaseTextField {
    init(frame: CGRect = .zero) {
        super.init(frame: frame, fontStyle: body16)
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
    
    private lazy var leftContainer: UIView = UIView(frame: CGRect(x: edgesPadding, y: 0, width: leftPadding, height: searchIconImageView.frame.height))
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
        
        // 키보드 타입
        self.returnKeyType = .search
        
        // Placeholder
        self.placeholder = String(localized: "SearchSomething", table: "Home")
        self.placeholderColor = .primary200
        
        // 아이콘 설정
        leftContainer.addSubview(searchIconImageView)
        
        self.leftView = leftContainer
        self.leftViewMode = .always
        self.rightView = rightContainer
        self.rightViewMode = .always
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: edgesPadding, left: leftPadding, bottom: edgesPadding, right: edgesPadding))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    // MARK: - 생명주기
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 16).cgPath
    }
}
