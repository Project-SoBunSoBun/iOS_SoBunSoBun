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
    private let disposeBag = DisposeBag()
    
    // 외부 이벤트 전달
    let didTap = PublishRelay<String>()
    
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
        self.textColor = .primary300
        self.backgroundColor = .primary50
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor.primary400.cgColor
        self.clipsToBounds = true
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .horizontal)
        
        self.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                isChecked.toggle()
                
                didTap.accept(String(format: "%04d", tag))
            })
            .disposed(by: disposeBag)
    }
    
    private func toggleStyle() {
        if isChecked {
            self.textColor = .primary400
            self.backgroundColor = .primary100
            self.layer.borderWidth = 2
        } else {
            self.textColor = .primary300
            self.backgroundColor = .primary50
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
