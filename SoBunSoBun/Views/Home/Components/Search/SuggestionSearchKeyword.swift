//
//  SuggestionSearchKeyword.swift
//  SoBunSoBun
//
//  Created by 김태은 on 1/13/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class SuggestionSearchKeyword: UILabel {
    private let disposeBag = DisposeBag()
    
    // 외부 이벤트 전달
    let didTap = PublishRelay<String>()
    
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
        self.textColor = .primary400
        self.backgroundColor = .primary100
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor.primary400.cgColor
        self.clipsToBounds = true
        
        self.textColor = .primary400
        self.backgroundColor = .primary100
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .horizontal)
        
        self.rx
            .tapGesture()
            .when(.recognized)
            .compactMap { [weak self] _ in
                guard let self = self else { return nil }
                
                return self.text
            }
            .bind(to: didTap)
            .disposed(by: disposeBag)
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
