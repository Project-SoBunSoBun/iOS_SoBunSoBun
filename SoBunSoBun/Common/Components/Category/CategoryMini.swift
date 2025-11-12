//
//  CategoryMini.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/6/25.
//

import UIKit
import SnapKit

class CategoryMini: UILabel {
    /// 목록 내 보여질 카테코리 컴포넌트입니다.
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let insets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    private func configure() {
        self.font = title12.font
        self.textColor = .primary400
        self.backgroundColor = .neutral50
        self.layer.cornerRadius = 8
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
