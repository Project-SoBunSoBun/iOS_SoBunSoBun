//
//  CategorySelectable.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/6/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class CategorySelectable: UILabel {
    let title: String
    
    private let disposeBag = DisposeBag()
    
    init(frame: CGRect = .zero, title: String) {
        self.title = title
        
        super.init(frame: frame)
        configure()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let didTap = PublishRelay<String>()
    
    var isChecked: Bool = false {
        didSet {
            toggleStyle()
        }
    }
    
    private let insets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    
    private func configure() {
        var attributes = title14.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.primary300
        
        self.attributedText = NSAttributedString(string: NSLocalizedString("Category\(title)", comment: ""), attributes: attributes)
        
        self.backgroundColor = .primary50
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor.primary400.cgColor
        self.clipsToBounds = true
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private func bind() {
        self.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in self.title}
            .bind(to: didTap)
            .disposed(by: disposeBag)
    }
    
    private func toggleStyle() {
        var attributes = title14.attributes(alignment: .center)
        attributes[.foregroundColor] = isChecked ? UIColor.primary400 : UIColor.primary300
        
        self.attributedText = NSAttributedString(string: NSLocalizedString("Category\(title)", comment: ""), attributes: attributes)
        
        self.backgroundColor = isChecked ? .primary100 : .primary50
        self.layer.borderWidth = isChecked ? 2 : 0
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
