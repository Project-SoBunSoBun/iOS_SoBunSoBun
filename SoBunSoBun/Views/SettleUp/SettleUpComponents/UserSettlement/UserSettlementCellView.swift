//
//  UserSettlementCellView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 3/12/26.
//

import UIKit
import SnapKit

class UserSettlementCellView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let nicknameLabel = UILabel()
    private let productsLabel = UILabel()
    private let amountLabel = UILabel()
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        self.axis = .vertical
        self.spacing = 8
        self.isLayoutMarginsRelativeArrangement = true
        self.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        
        [nicknameLabel, productsLabel, amountLabel].forEach {
            self.addArrangedSubview($0)
        }
    }
    
    func configureUI(model: SettleUp3rdStepParticipantModel, authorId: Int) {
        let isAuthor = (model.userId == authorId)
        let backgroundColor: UIColor = isAuthor ? .primary400 : .primary50
        let textColor: UIColor = isAuthor ? .backgroundWhite : .neutral600
        
        self.backgroundColor = backgroundColor
        
        // 닉네임 설정
        let localizedMe = String(localized: "Me", table: "SettleUp")
        let displayNickname = isAuthor ? "\(model.nickname)\(localizedMe)" : model.nickname
        
        var nicknameAttributes = title16.attributes(alignment: .left)
        nicknameAttributes[.foregroundColor] = textColor
        
        nicknameLabel.attributedText = NSAttributedString(
            string: displayNickname,
            attributes: nicknameAttributes
        )
        
        // 상품명 설정
        let productNames = model.items.map { $0.itemName }.joined(separator: ", ")
        
        var productsAttributes = body14.attributes(alignment: .left)
        productsAttributes[.foregroundColor] = textColor
        
        productsLabel.attributedText = NSAttributedString(
            string: productNames,
            attributes: productsAttributes
        )
        
        // 금액 설정
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedAmount = formatter.string(from: NSNumber(value: model.assignedAmount)) ?? "0"
        let unit = String(localized: "KRW", table: "SettleUp")
        
        var amountAttributes = title16.attributes(alignment: .right)
        amountAttributes[.foregroundColor] = textColor
        
        amountLabel.attributedText = NSAttributedString(
            string: "\(formattedAmount)\(unit)",
            attributes: amountAttributes
        )
    }
}
