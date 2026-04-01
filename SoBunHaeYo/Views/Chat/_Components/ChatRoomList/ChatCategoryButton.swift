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
            setNeedsUpdateConfiguration()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.tintColor = .clear
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 12.5, leading: 16, bottom: 12.5, trailing: 16)
        config.cornerStyle = .fixed
        config.background.cornerRadius = 14
        
        self.configuration = config
        self.configurationUpdateHandler = { [weak self] button in
            guard let self = self,
                  var config = button.configuration else {
                return
            }
            
            let selected = button.state.contains(.selected)
            
            config.background.backgroundColor = selected ? .primary400 : .primary75
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            // 디자인 상 폰트의 기본 행간을 사용하고 있습니다.
            let attributes: [NSAttributedString.Key: Any] = [
                .font: title16.font,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: selected ? UIColor.backgroundWhite : UIColor.neutral900
            ]
            
            config.attributedTitle = AttributedString(
                NSAttributedString(string: self.title, attributes: attributes)
            )
            
            button.configuration = config
        }
    }
}
