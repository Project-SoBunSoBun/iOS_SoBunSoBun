//
//  SettingDropDownCell.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 2/11/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class SettingDropDownCell: UIView {
    let localizableKey: String
    let tableName: String
    let textAlignment: NSTextAlignment
    
    private let disposeBag = DisposeBag()
    
    init(
        frame: CGRect = .zero,
        localizableKey: String,
        tableName: String,
        textAlignment: NSTextAlignment
    ) {
        self.localizableKey = localizableKey
        self.tableName = tableName
        self.textAlignment = textAlignment
        
        super.init(frame: frame)
        
        configureUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let didTap = PublishRelay<String>()
    
    private let label: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        lb.isUserInteractionEnabled = false
        
        return lb
    }()
    
    private func configureUI() {
        var attributes: [NSAttributedString.Key: Any] = body16.attributes(alignment: textAlignment)
        attributes[.foregroundColor] = UIColor.primary400
        
        label.attributedText = NSAttributedString(string: NSLocalizedString(localizableKey, tableName: tableName, comment: ""), attributes: attributes)
        
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.centerY.equalToSuperview()
        }
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
