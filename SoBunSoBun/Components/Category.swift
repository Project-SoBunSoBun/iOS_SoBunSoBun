//
//  Category.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/9/25.
//

import UIKit
import RxSwift
import RxGesture

class Category: UILabel {
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
        self.textColor = .primary300
        self.backgroundColor = .primary50
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
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

class CategorySelectable: UILabel {
    private let disposeBag = DisposeBag()
    
    var number: Int = -1
    
    var isChecked: Bool = false {
        didSet {
            toggleStyle()
        }
    }
    
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
        self.textColor = .primary300
        self.backgroundColor = .primary50
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.primary400.cgColor
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .horizontal)
        
        self.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                isChecked.toggle()
            })
            .disposed(by: disposeBag)
    }
    
    private func toggleStyle() {
        if isChecked {
            self.textColor = .primary400
            self.backgroundColor = .primary100
            self.frame = CGRectInset(self.frame, -2, -2)
            self.layer.borderWidth = 2
        } else {
            self.textColor = .primary300
            self.backgroundColor = .primary50
            self.frame = CGRectInset(self.frame, 2, 2)
            self.layer.borderWidth = 0
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
