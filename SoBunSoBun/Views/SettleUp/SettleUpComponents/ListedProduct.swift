//
//  ListedProduct.swift
//  SoBunSoBun
//
//  Created by 허성필 on 12/16/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import OSLog

class ListedProduct: UIView {
    init(frame: CGRect = .zero,
         itemName: String,
         itemCount: Int,
         itemPrice: Int,
         unitIndex: Int
    ) {
        super.init(frame: frame)
        
        configure(itemName: itemName,
                  itemCount: itemCount,
                  itemPrice: itemPrice,
                  unitIndex: unitIndex)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "SettleUpComponents.ListedProduct"
    )
    
    private let disposeBag = DisposeBag()
    
    var onEditButtonTapped: (() -> Void)? // 수정하기 버튼 클릭
    var onDeleteButtonTapped: (() -> Void)? // 삭제 버튼 클릭
    
    // MARK: - 디자인 요소
    // 상품명
    private let itemNameLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .neutral900
        lb.numberOfLines = 1
        lb.lineBreakMode = .byTruncatingTail
        
        return lb
    }()
    
    // 상품 수량 or 중량, 총 가격
    private let itemTotalLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .neutral900
        
        return lb
    }()
    
    // 수정하기 버튼
    private let editButton: UIButton = {
        let bt = UIButton()
        var config = UIButton.Configuration.filled()
        
        var attributedString = NSAttributedString(string: String(localized: "ListedProductEdit"), attributes: title14.attributes())
        
        config.attributedTitle = .init(attributedString)
        config.baseBackgroundColor = .backgroundWhite
        config.baseForegroundColor = .primary300
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        bt.configuration = config
        bt.layer.cornerRadius = 8
        bt.clipsToBounds = true
        bt.layer.borderWidth = 1
        bt.layer.borderColor = UIColor.primary100.cgColor
        
        return bt
    }()
    
    // 삭제 버튼
    private let deleteButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        config.preferredSymbolConfigurationForImage = .init(pointSize: 24)
        config.image = .greyClose
        config.imagePadding = 0
        config.contentInsets = .init(top: 6, leading: 6, bottom: 6, trailing: 6)
        
        let bt = UIButton(configuration: config)
        
        return bt
    }()
    
    // 구분선
    private let divider: UIView = {
        let dv = UIView()
        dv.backgroundColor = .primary100
        
        return dv
    }()
    
    // 천단위 콤마 Formatter
    private let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        
        return formatter
    }()
    
    // MARK: - 레이아웃 설정
    private func configure(itemName: String,
                           itemCount: Int,
                           itemPrice: Int,
                           unitIndex: Int
    ) {
        self.backgroundColor = .clear
        
        // 상품 명
        itemNameLabel.attributedText = NSAttributedString(
            string: itemName,
            attributes: title16.attributes(alignment: .left)
        )
        
        itemNameLabel.lineBreakMode = .byTruncatingTail
        
        // 상품 수량 or 중량,  총 가격
        let won = String(localized: "Won")
        let priceString = priceFormatter.string(from: NSNumber(value: itemPrice)) ?? "\(itemPrice)"
        let totalText: String
        
        switch unitIndex {
        case 1:
            let format = String(localized: "ListedProductItemTotal")
            totalText = String(format: format, itemCount, priceString)
        case 2:
            totalText = "\(itemCount)g \(priceString)\(won)"
        
        default:
            let format = String(localized: "ListedProductItemTotal")
            totalText = String(format: format, itemCount, priceString)
        }
        
        itemTotalLabel.attributedText = NSAttributedString(
            string: totalText,
            attributes: body16.attributes(alignment: .left))
        
        [itemNameLabel, deleteButton, itemTotalLabel, editButton, divider].forEach {
            self.addSubview($0)
        }
        
        // 상품명
        itemNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(deleteButton.snp.leading).offset(-8)
            make.top.equalToSuperview().offset(16)
        }
        
        // 삭제 버튼
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(itemNameLabel)
            make.size.equalTo(24)
        }

        // 상품 수량 or 중량,  총 가격
        itemTotalLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(itemNameLabel.snp.bottom).offset(16)
        }
        
        // 수정하기 버튼
        editButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(itemTotalLabel)
        }
        
        // 구분선
        divider.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(itemTotalLabel.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        // 버튼 클릭 이벤트
        editButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.logger.debug("수정하기 버튼 터치")
                self.onEditButtonTapped?()
            })
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.logger.debug("삭제 버튼 터치")
                self.onDeleteButtonTapped?()
            })
            .disposed(by: disposeBag)
    }
}
