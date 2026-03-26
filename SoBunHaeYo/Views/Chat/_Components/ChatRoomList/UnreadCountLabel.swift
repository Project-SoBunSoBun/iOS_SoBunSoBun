//
//  UnreadCountLabel.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/10/26.
//

import UIKit

class UnreadCountLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var text: String? {
        didSet {
            changeText()
        }
    }
    
    private let insets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
    
    private func configureUI() {
        self.backgroundColor = .primary200
        self.layer.cornerRadius = 11
        self.clipsToBounds = true
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private func changeText() {
        guard let text = text else {
            self.attributedText = nil
            
            return
        }
        
        var attributes: [NSAttributedString.Key: Any] = body12.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.backgroundWhite
        
        let number = Int(text) ?? 0
        self.isHidden = number < 1
        self.attributedText = NSAttributedString(string: number > 999 ? "999+" : "\(number)", attributes: attributes)
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
