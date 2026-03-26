//
//  ChatBottomMenuButton.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/16/26.
//

import UIKit
import SnapKit

class ChatBottomMenuButton: UIButton {
    init(frame: CGRect = .zero, image: UIImage, text: String) {
        super.init(frame: frame)
        
        configureUI(image: image, text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI(image: UIImage, text: String) {
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = .primary50
        config.background.cornerRadius = 16
        config.background.strokeWidth = 1
        config.background.strokeColor = .primary100
        config.image = image.resize(.init(width: 24, height: 24))
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        var attributes: [NSAttributedString.Key: Any] = title16.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.primary400
        
        config.attributedTitle = AttributedString(NSAttributedString(string: text, attributes: attributes))
        
        self.configuration = config
    }
}
