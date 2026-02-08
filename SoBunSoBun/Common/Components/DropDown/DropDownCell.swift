//
//  DropDownCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 1/17/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class DropDownCell: UIView {
    let localizableKey: String
    let tableName: String
    let selectionMode: DropDownView.SelectionMode
    
    private let disposeBag = DisposeBag()
    
    init(frame: CGRect = .zero, localizableKey: String, tableName: String, selectionMode: DropDownView.SelectionMode) {
        self.localizableKey = localizableKey
        self.tableName = tableName
        self.selectionMode = selectionMode
        
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
        iv.image = .greyCheck.resize(.init(width: 24, height: 24))
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        iv.isUserInteractionEnabled = false
        
        iv.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        return iv
    }()
    
    private func configureUI() {
        var attributes: [NSAttributedString.Key: Any] = title14.attributes()
        attributes[.foregroundColor] = UIColor.neutral600
        
        label.attributedText = NSAttributedString(string: NSLocalizedString(localizableKey, tableName: tableName, comment: ""), attributes: attributes)
        
        switch selectionMode {
        case .plain:
            addSubview(label)
            
            label.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(8)
                make.verticalEdges.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            
        case .check:
            [icon, label].forEach {
                addSubview($0)
            }
            
            icon.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(8)
                make.verticalEdges.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            
            label.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(8)
                make.trailing.equalTo(icon.snp.leading).inset(8)
                make.verticalEdges.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }
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
