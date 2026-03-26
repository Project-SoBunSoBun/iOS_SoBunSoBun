//
//  PaddingLabel.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 11/13/25.
//

import UIKit

class PaddingLabel: UILabel {
    var padding = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.width += padding.left + padding.right
        contentSize.height += padding.top + padding.bottom
        return contentSize
    }
}
