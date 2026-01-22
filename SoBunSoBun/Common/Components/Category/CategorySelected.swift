//
//  CategorySelected.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/9/25.
//

import UIKit
import SnapKit

class CategorySelected: UILabel {
    let title: String
    
    init(frame: CGRect = .zero, title: String) {
        self.title = title
        
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let insets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    
    private func configure() {
        var attributes: [NSAttributedString.Key: Any] = title14.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.backgroundWhite
        self.attributedText = NSAttributedString(string: title, attributes: attributes)
        
        self.backgroundColor = .primary300
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += insets.top + insets.bottom
        contentSize.width += insets.left + insets.right
        
        return contentSize
    }
}
