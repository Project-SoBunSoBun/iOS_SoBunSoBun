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
    // 상품 명
    private let itemNameLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .neutral900
        
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
        config.baseBackgroundColor = .neutral50
        config.baseForegroundColor = .primary400
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        bt.configuration = config
        bt.layer.cornerRadius = 8
        bt.clipsToBounds = true
        
        return bt
    }()
    
    // 삭제 버튼
    private let deleteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .neutral50
        config.preferredSymbolConfigurationForImage = .init(pointSize: 27)
        config.image = .blueFail
        config.imagePadding = 0
        config.contentInsets = .init(top: 9, leading: 9, bottom: 9, trailing: 9)
        
        let bt = UIButton(configuration: config)
        bt.layer.cornerRadius = 13.5
        bt.clipsToBounds = true
        
        return bt
    }()
    
    // 구분선
    private let divider: UIView = {
        let dv = UIView()
        dv.backgroundColor = .primary100
        
        return dv
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
        
        // 상품 수량 or 중량,  총 가격
        let won = String(localized: "Won")
        let totalText: String
        
        switch unitIndex {
        case 1:
            let format = String(localized: "ListedProductItemTotal")
            totalText = String(format: format, itemCount, itemPrice)
        case 2:
            totalText = "\(itemCount)g \(itemPrice)\(won)"
        
        default:
            let format = String(localized: "ListedProductItemTotal")
            totalText = String(format: format, itemCount, itemPrice)
        }
        
        itemTotalLabel.attributedText = NSAttributedString(
            string: totalText,
            attributes: body16.attributes(alignment: .left))
        
        [itemNameLabel, itemTotalLabel, deleteButton, editButton, divider].forEach {
            self.addSubview($0)
        }
        
        // 상품 명
        itemNameLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        // 상품 수량 or 중량,  총 가격
        itemTotalLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(itemNameLabel.snp.bottom).offset(8)
        }
        
        // 삭제 버튼
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(itemTotalLabel)
        }
        
        // 수정하기 버튼
        editButton.snp.makeConstraints { make in
            make.trailing.equalTo(deleteButton.snp.leading).offset(-8)
            make.centerY.equalTo(deleteButton)
        }
        
        // 구분선
        divider.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
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
