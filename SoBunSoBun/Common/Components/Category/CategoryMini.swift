//
//  CategoryMini.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/6/25.
//

import UIKit
import SnapKit

class CategoryMini: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var text: String? {
        didSet {
            guard let text = text else {
                self.attributedText = nil
                
                return
            }
            
            var attributes: [NSAttributedString.Key: Any] = title12.attributes(alignment: .center)
            attributes[.foregroundColor] = UIColor.primary400
            self.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
    }
    
    private let insets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    private func configure() {
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
