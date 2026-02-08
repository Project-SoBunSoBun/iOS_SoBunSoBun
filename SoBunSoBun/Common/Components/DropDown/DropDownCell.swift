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
    let tableName: String
    
    private let disposeBag = DisposeBag()
    
    init(frame: CGRect = .zero, localizableKey: String, tableName: String) {
        self.localizableKey = localizableKey
        self.tableName = tableName
        
        super.init(frame: frame)
        
        configureUI()
        bind()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let didTap = PublishRelay<String>()
    
    private let label: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        lb.isUserInteractionEnabled = false
        
        return lb
    }()
    
    private let icon: UIImageView = {
        let iv = UIImageView()
        iv.image = .greyCheck
        iv.contentMode = .scaleAspectFit
        iv.preferredSymbolConfiguration = .init(pointSize: 24)
        iv.isHidden = true
        iv.isUserInteractionEnabled = false
        
        return iv
    }()
    
    private func configureUI() {
        self.axis = .horizontal
        self.spacing = 8
        self.alignment = .center
        self.isLayoutMarginsRelativeArrangement = true
        self.layoutMargins = .init(top: 0, left: 8, bottom: 0, right: 8)
        
        var attributes: [NSAttributedString.Key: Any] = title14.attributes()
        attributes[.foregroundColor] = UIColor.neutral600
        
        label.attributedText = NSAttributedString(string: NSLocalizedString(localizableKey, tableName: tableName, comment: ""), attributes: attributes)
        
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
        
        label.attributedText = NSAttributedString(string: NSLocalizedString(localizableKey, tableName: tableName, comment: ""), attributes: attributes)
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
