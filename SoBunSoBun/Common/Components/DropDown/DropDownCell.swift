//
//  DropDownCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 1/17/26.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class DropDownCell: UIStackView {
    let localizableKey: String
    
    private let disposeBag = DisposeBag()
    
    init(frame: CGRect = .zero, localizableKey: String) {
        self.localizableKey = localizableKey
        
        super.init(frame: frame)
        
        configureUI()
        bind()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let didTap = PublishRelay<String>()
    
    private let label = UILabel()
    
    private let icon: UIImageView = {
        let iv = UIImageView()
        iv.image = .greyCheck
        iv.contentMode = .scaleAspectFit
        iv.preferredSymbolConfiguration = .init(pointSize: 24)
        iv.isHidden = true
        
        return iv
    }()
    
    private func configureUI() {
        self.axis = .horizontal
        self.spacing = 8
        self.alignment = .center
        self.isLayoutMarginsRelativeArrangement = true
        self.directionalLayoutMargins = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        var attributes: [NSAttributedString.Key: Any] = title14.attributes()
        attributes[.foregroundColor] = UIColor.neutral600
        
        label.attributedText = NSAttributedString(string: NSLocalizedString(localizableKey, tableName: "Home", comment: ""), attributes: attributes)
        
        [label, icon].forEach {
            self.addArrangedSubview($0)
        }
        
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        icon.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func toggleSelect(isSelected: Bool) {
        icon.isHidden = !isSelected
        
        var attributes: [NSAttributedString.Key: Any] = title14.attributes()
        attributes[.foregroundColor] = isSelected ? UIColor.neutral900 : UIColor.neutral600
        
        label.attributedText = NSAttributedString(string: NSLocalizedString(localizableKey, tableName: "Home", comment: ""), attributes: attributes)
    }
    
    private func bind() {
        self.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in self.localizableKey }
            .bind(to: didTap)
            .disposed(by: disposeBag)
    }
}
