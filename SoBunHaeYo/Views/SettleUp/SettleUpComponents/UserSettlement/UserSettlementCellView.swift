//
//  UserSettlementCellView.swift
//  SoBunHaeYo
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
    
    private let countUnit = String(localized: "Count", table: "SettleUp")
    private let amountUnit = String(localized: "KRW", table: "SettleUp")
    private let totalText = String(localized: "Total", table: "SettleUp")
    
    // MARK: - 디자인 요소
    private let nicknameLabel = UILabel()
    private let itemStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        
        return stackView
    }()
    
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

        [nicknameLabel, itemStackView, amountLabel].forEach {
            self.addArrangedSubview($0)
        }
        
        self.setCustomSpacing(12, after: itemStackView)
    }
    
    // 공통 렌더링 메서드
    func commonRender(nickname: String, items: [(description: String, amount: Int)], assignedAmount: Int, isCurrentUser: Bool) {
        let backgroundColor: UIColor = isCurrentUser ? .primary400 : .primary50
        let textColor: UIColor = isCurrentUser ? .backgroundWhite : .neutral600
        
        self.backgroundColor = backgroundColor
        configureItemRows(items: items, textColor: textColor)
        
        // 닉네임
        let localizedMe = String(localized: "Me", table: "SettleUp")
        let displayNickname = isCurrentUser ? "\(nickname)\(localizedMe)" : nickname
        
        var nicknameAttributes = title16.attributes(alignment: .left)
        nicknameAttributes[.foregroundColor] = textColor
        
        nicknameLabel.attributedText = NSAttributedString(string: displayNickname, attributes: nicknameAttributes)
        
        // 금액
        let formattedAmount = numberFormatter.string(from: NSNumber(value: assignedAmount)) ?? "0"
        
        var amountAttributes = title16.attributes(alignment: .right)
        amountAttributes[.foregroundColor] = textColor
        
        amountLabel.attributedText = NSAttributedString(string: "\(totalText) \(formattedAmount)\(amountUnit)", attributes: amountAttributes)
    }

    private func formatItemDescription(itemName: String, quantity: Int, unit: String) -> String {
        "· \(itemName) \(quantity)\(unit)"
    }
    
    private func configureItemRows(items: [(description: String, amount: Int)], textColor: UIColor) {
        itemStackView.arrangedSubviews.forEach { subview in
            itemStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        items.forEach { item in
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .top
            rowStackView.spacing = 8
            
            let descriptionLabel = UILabel()
            descriptionLabel.numberOfLines = 0
            
            var descriptionAttributes = body14.attributes(alignment: .left)
            descriptionAttributes[.foregroundColor] = textColor
            
            descriptionLabel.attributedText = NSAttributedString(
                string: item.description,
                attributes: descriptionAttributes
            )
            
            let spacerView = UIView()
            
            let amountValueLabel = UILabel()
            
            let formattedAmount = numberFormatter.string(from: NSNumber(value: item.amount)) ?? "0"
            
            var amountAttributes = body14.attributes(alignment: .right)
            amountAttributes[.foregroundColor] = textColor
            
            amountValueLabel.attributedText = NSAttributedString(
                string: "\(formattedAmount)\(amountUnit)",
                attributes: amountAttributes
            )
            
            [descriptionLabel, spacerView, amountValueLabel].forEach {
                rowStackView.addArrangedSubview($0)
            }
            
            itemStackView.addArrangedSubview(rowStackView)
        }
    }
    
    // 3단계 정산용
    func configureUI(model: SettleUp3rdStepParticipantModel, authorId: Int) {
        commonRender(
            nickname: model.nickname,
            items: model.items.map { item in
                let unit = item.unitIndex == 1 ? countUnit : "g"
                
                return (
                    description: formatItemDescription(
                        itemName: item.itemName,
                        quantity: item.quantity,
                        unit: unit
                    ),
                    amount: item.amount
                )
            },
            assignedAmount: model.assignedAmount,
            isCurrentUser: model.userId == authorId
        )
    }
    
    // 정산 상세 조회용
    func configureUI(model: SettlementParticipantModel, currentUserId: Int) {
        commonRender(
            nickname: model.userNickname,
            items: model.items.map { item in
                (
                    description: formatItemDescription(
                        itemName: item.itemName,
                        quantity: item.quantity,
                        unit: item.unit
                    ),
                    amount: item.amount
                )
            },
            assignedAmount: model.assignedAmount,
            isCurrentUser: model.userId == currentUserId
        )
    }
}
