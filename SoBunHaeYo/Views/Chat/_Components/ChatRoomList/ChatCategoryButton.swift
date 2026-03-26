//
//  ChatCategoryButton.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/10/26.
//

import UIKit

class ChatCategoryButton: UIButton {
    var title: String = "" {
        didSet {
            configureUI()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            configureUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 레이아웃 설정
    private var config: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.contentInsets = .init(top: 12.5, leading: 16, bottom: 12.5, trailing: 16)
        config.cornerStyle = .fixed
        config.background.cornerRadius = 14
        
        return config
    }()
    
    private func configureUI() {
        config.background.backgroundColor = isSelected ? .primary400 : .primary75
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        // 디자인 상 폰트의 기본 행간을 사용하고 있습니다.
        var attributes: [NSAttributedString.Key: Any] = [
            .font: title16.font,
            .paragraphStyle: paragraphStyle
        ]
        
        attributes[.foregroundColor] = isSelected ? UIColor.backgroundWhite : UIColor.neutral900
        config.attributedTitle = AttributedString(NSAttributedString(string: title, attributes: attributes))
        
        self.configuration = config
    }
}
