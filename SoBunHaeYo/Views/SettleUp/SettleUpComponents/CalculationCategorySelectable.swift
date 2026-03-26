//
//  CalculationCategorySelectable.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 11/12/25.
//

import UIKit
import SnapKit
import RxSwift

class CalculationCategorySelectable: UILabel {
    private let disposeBag = DisposeBag()
    
    var isChecked: Bool = false {
        didSet {
            toggleStyle()
        }
    }
    
    /// Tabable 카테고리 컴포넌트입니다.
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let insets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    
    private func configure() {
        self.font = title14.font
        self.textColor = .neutral900
        self.backgroundColor = .primary50
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private func toggleStyle() {
        if isChecked {
            self.textColor = .backgroundWhite
            self.backgroundColor = .primary400
        } else {
            self.textColor = .neutral900
            self.backgroundColor = .primary50
        }
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
