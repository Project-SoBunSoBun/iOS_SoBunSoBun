//
//  CalculationGuestItem.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/14/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class CalculationGuestItem: UIView {
    init(nickname: String, product: ListedProductModel) {
        self.nickname = nickname
        self.product = product
        
        super.init(frame: .zero)
        configureUI()
        bindTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let product: ListedProductModel
    private let nickname: String
    private let disposeBag = DisposeBag()
    
    var onNicknameTapped: (() -> Void)?
    
    // MARK: - 디자인 요소
    // label과 textField가 들어갈 StackView
    private let itemStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 8
        sv.distribution = .fillEqually
        
        return sv
    }()
    
    // 닉네임 Label
    private let nicknameLabel: UILabel = {
        let lb = UILabel()
        lb.font = title16.font
        lb.textColor = .primary400
        lb.backgroundColor = .primary100
        lb.textAlignment = .center
        lb.layer.cornerRadius = 14
        lb.layer.borderWidth = 2
        lb.layer.borderColor = UIColor.primary400.cgColor
        lb.clipsToBounds = true
        
        return lb
    }()
    
    // 수량 textField
    private let countTextField: RightViewTextField = {
        let tv = RightViewTextField(rightText: String(localized: "Count"))
        tv.keyboardType = .numberPad
        
        return tv
    }()
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        self.backgroundColor = .clear
        
        self.addSubview(itemStackView)
        
        itemStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        [nicknameLabel, countTextField].forEach {
            itemStackView.addArrangedSubview($0)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        countTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        countTextField.updateRightViewText(product.unitIndex == 1 ? String(localized: "Count") : "g")
        
        let attributedText = NSAttributedString(
            string: nickname,
            attributes: title16.attributes(alignment: .center)
        )
        nicknameLabel.attributedText = attributedText
    }
    
    private func bindTapGesture() {
        nicknameLabel.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.onNicknameTapped?()
            })
            .disposed(by: disposeBag)
    }
    
    func getCount() -> String {
        return countTextField.text ?? ""
    }
}
