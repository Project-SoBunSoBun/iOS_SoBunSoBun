//
//  CalculationGuestLabel.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/14/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class CalculationGuestLabel: UILabel {
    private let disposeBag = DisposeBag()
    
    var tapped: Observable<String> {
        tapSubject.asObserver()
    }
    
    private let tapSubject = PublishSubject<String>()
    private let sidePadding: CGFloat = 16
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        self.backgroundColor = .backgroundWhite
        self.layer.cornerRadius = 14
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.primary100.cgColor
        self.isUserInteractionEnabled = true
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .horizontal)
        
        self.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let text = self.text else { return }
                tapSubject.onNext(text)
            })
            .disposed(by: disposeBag)
    }
    
    override func drawText(in rect: CGRect) {
        let paddingRect = rect.insetBy(dx: sidePadding, dy: 0)
        super.drawText(in: paddingRect)
    }
    
    override var intrinsicContentSize: CGSize {
        let textSize = super.intrinsicContentSize
        return CGSize(
            width: textSize.width + (sidePadding * 2),
            height: 44
        )
    }
}
