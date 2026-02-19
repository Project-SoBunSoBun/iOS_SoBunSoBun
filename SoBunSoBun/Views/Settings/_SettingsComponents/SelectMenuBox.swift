//
//  SelectMenuBox.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/19/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class SelectMenuBox: UIView {
    init(placeholder: String) {
        super.init(frame: .zero)
        
        configureUI()
        setUpPlaceholder(text: placeholder)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let didTap = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    private let reasonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 0, bottom: 16, right: 0)
        sv.isUserInteractionEnabled = true
        
        return sv
    }()
    
    private let selectedReasonLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        
        return lb
    }()
    
    private let dropDownIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = .blackDown.resize(.init(width: 24, height: 24))
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = .neutral200
        
        return v
    }()
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        [reasonStackView, divider].forEach {
            self.addSubview($0)
        }
        
        [selectedReasonLabel, dropDownIcon].forEach {
            reasonStackView.addArrangedSubview($0)
        }
        
        reasonStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        
        divider.snp.makeConstraints { make in
            make.top.equalTo(reasonStackView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        
        selectedReasonLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        selectedReasonLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        dropDownIcon.setContentHuggingPriority(.required, for: .horizontal)
        dropDownIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func setUpPlaceholder(text: String) {
        var attributes = body16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral400
        
        selectedReasonLabel.attributedText = NSAttributedString(
            string: text,
            attributes: attributes
        )
    }
    
    func updateSelectedText(text: String) {
        var attributes = body16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        selectedReasonLabel.attributedText = NSAttributedString(
            string: text,
            attributes: attributes
        )
    }
}

extension SelectMenuBox {
    private func bind() {
        reasonStackView.rx.tapGesture()
            .when(.recognized)
            .map { _ in Void() }
            .bind(to: didTap)
            .disposed(by: disposeBag)
    }
}
