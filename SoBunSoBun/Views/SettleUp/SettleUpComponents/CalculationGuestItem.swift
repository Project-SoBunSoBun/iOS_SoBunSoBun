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
    
    let nicknameTapped = PublishRelay<Void>()
    
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
        lb.backgroundColor = .primary100
        lb.layer.cornerRadius = 14
        lb.layer.borderWidth = 2
        lb.layer.borderColor = UIColor.primary400.cgColor
        lb.clipsToBounds = true
        
        return lb
    }()
    
    // 수량 textField
    private let countTextField: RightViewTextField = {
        let tv = RightViewTextField(rightText: String(localized: "Count", table: "SettleUp"))
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
        
        countTextField.updateRightViewText(product.unitIndex == 1 ? String(localized: "Count", table: "SettleUp") : "g")
        
        var attributes = title16.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.primary400
        
        let attributedText = NSAttributedString(
            string: nickname,
            attributes: attributes
        )
        nicknameLabel.attributedText = attributedText
    }
    
    private func bindTapGesture() {
        nicknameLabel.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in () }
            .bind(to: nicknameTapped)
            .disposed(by: disposeBag)
    }
    
    func getCount() -> Int {
        guard let count = Int(countTextField.text ?? "0") else { return 0 }
        
        return count
    }
    
    func getNickname() -> String {
        return self.nickname
    }
}
