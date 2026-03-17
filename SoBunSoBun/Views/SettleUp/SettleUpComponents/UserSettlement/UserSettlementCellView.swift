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
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
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
    
    // 공통 렌더링 메서드
    func commonRender(nickname: String, itemNames: [String], assignedAmount: Int, isCurrentUser: Bool) {
        let backgroundColor: UIColor = isCurrentUser ? .primary400 : .primary50
        let textColor: UIColor = isCurrentUser ? .backgroundWhite : .neutral600
        
        self.backgroundColor = backgroundColor
        
        // 닉네임
        let localizedMe = String(localized: "Me", table: "SettleUp")
        let displayNickname = isCurrentUser ? "\(nickname)\(localizedMe)" : nickname
        
        var nicknameAttributes = title16.attributes(alignment: .left)
        nicknameAttributes[.foregroundColor] = textColor
        
        nicknameLabel.attributedText = NSAttributedString(string: displayNickname, attributes: nicknameAttributes)
        
        // 상품명
        var productsAttributes = body14.attributes(alignment: .left)
        productsAttributes[.foregroundColor] = textColor
        
        productsLabel.attributedText = NSAttributedString(string: itemNames.joined(separator: ", "), attributes: productsAttributes)
        
        // 금액
        let formattedAmount = numberFormatter.string(from: NSNumber(value: assignedAmount)) ?? "0"
        let unit = String(localized: "KRW", table: "SettleUp")
        
        var amountAttributes = title16.attributes(alignment: .right)
        amountAttributes[.foregroundColor] = textColor
        
        amountLabel.attributedText = NSAttributedString(string: "\(formattedAmount)\(unit)", attributes: amountAttributes)
    }
    
    // 3단계 정산용
    func configureUI(model: SettleUp3rdStepParticipantModel, authorId: Int) {
        commonRender(
            nickname: model.nickname,
            itemNames: model.items.map { $0.itemName },
            assignedAmount: model.assignedAmount,
            isCurrentUser: model.userId == authorId
        )
    }
    
    // 정산 상세 조회용
    func configureUI(model: SettlementParticipantModel, currentUserId: Int) {
        commonRender(
            nickname: model.userNickname,
            itemNames: model.items.map { $0.itemName },
            assignedAmount: model.assignedAmount,
            isCurrentUser: model.userId == currentUserId
        )
    }
}
