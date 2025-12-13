//
//  SettleUp1stStepView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 12/11/25.
//

import UIKit
import SnapKit
import OSLog
import RxSwift
import RxCocoa
import ReactorKit

class SettleUp1stStepView: UIViewController {
    init(id: Int) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    typealias Reactor = SettleUp1stStepReactor
    private let reactor = SettleUp1stStepReactor()
    
    private let disposeBag = DisposeBag()
    private let id: Int
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "SettleUp1stStep.View"
    )
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    // 뒤로 가기 버튼
    private let backButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0)
        config.image = .blackLeft
        config.preferredSymbolConfigurationForImage = .init(pointSize: 24)
        
        button.configuration = config
        
        return button
    }()
    
    // 전체 스크롤 뷰
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        
        return sv
    }()
    
    // 스크롤 뷰가 들어갈 View
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    // 1/3
    private let stepLabel: UILabel = {
        let lb = UILabel()
        let attributedText = NSAttributedString(
            string: "1/3",
            attributes: title14.attributes(alignment: .left)
        )
        lb.attributedText = attributedText
        lb.textColor = .primary400
        
        return lb
    }()
    
    // 제목 라벨
    private let titleLabel: UILabel = {
        let lb = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpRegisterItem"),
            attributes: title24.attributes(alignment: .left)
        )
        lb.attributedText = attributedText
        lb.textColor = .neutral900
        
        return lb
    }()
    
    // 등록된 상품 수량 라벨 배경 뷰
    private let subtitleBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral50
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        
        return view
    }()
    
    // 등록된 상품 수량 라벨
    private let subtitleLabel: UILabel = {
        let lb = UILabel()
        let format = String(localized: "SettleUpItemRegistered")
        let attributedText = NSAttributedString(
            string: String(format: format, 0),
            attributes: body14.attributes(alignment: .center)
        )
        
        lb.attributedText = attributedText
        lb.textColor = .neutral500
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 상품 등록 배경 뷰
    private let registerItemBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral50
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        
        return view
    }()
    
    // 상품명 라벨
    private let itemNameLabel: UILabel = {
        let lb = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpItemName"),
            attributes: title14.attributes(alignment: .left)
        )
        
        lb.attributedText = attributedText
        lb.textColor = .neutral900
        
        return lb
    }()
    
    private let itemNameTextField: UITextField = {
        let tf = PaddedTextField()
        tf.layer.cornerRadius = 16
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.primary100.cgColor
        tf.font = body16.font
        tf.textColor = .neutral900
        tf.backgroundColor = .backgroundWhite
        tf.attributedPlaceholder = NSAttributedString(
            string: String(localized: "SettleUpItemNamePlaceholder"),
            attributes: [
                .foregroundColor: UIColor.neutral300
            ]
        )
        
        return tf
    }()
    
    // 단위 라벨
    private let unitLabel: UILabel = {
        let lb = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpUnit"),
            attributes: title14.attributes(alignment: .left)
        )
        
        lb.attributedText = attributedText
        lb.textColor = .neutral900
        
        return lb
    }()
    
    // 단위 선택 버튼 컨테이너
    private let unitButtonContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fillEqually
        
        return sv
    }()
    
    // 수량(개) 버튼
    private let quantityButton: UIButton = {
        let bt = UIButton()
        var config = UIButton.Configuration.filled()
        
        var attributedString = AttributedString(
            String(localized: "SettleUpQuantity")
        )
        attributedString.font = title16.font
        
        config.attributedTitle = attributedString
        config.baseBackgroundColor = .primary100
        config.baseForegroundColor = .primary400
        config.contentInsets = .init(top: 16, leading: 12, bottom: 16, trailing: 12)
        
        bt.configuration = config
        bt.layer.cornerRadius = 14
        bt.clipsToBounds = true
        bt.layer.borderColor = UIColor.primary400.cgColor
        bt.layer.borderWidth = 2
        
        return bt
    }()
    
    // 중량(g) 버튼
    private let weightButton: UIButton = {
        let bt = UIButton()
        var config = UIButton.Configuration.filled()
        
        var attributedString = AttributedString(
            String(localized: "SettleUpWeight")
        )
        attributedString.font = title16.font
        
        config.attributedTitle = attributedString
        config.baseBackgroundColor = .primary50
        config.baseForegroundColor = .primary300
        config.contentInsets = .init(top: 16, leading: 12, bottom: 16, trailing: 12)
        
        bt.configuration = config
        bt.layer.cornerRadius = 14
        bt.clipsToBounds = true
        
        return bt
    }()
    
    // 단위 textField
    private let itemCountTextField: UITextField = {
        let tf = PaddedTextField()
        tf.layer.cornerRadius = 16
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.primary100.cgColor
        tf.font = body16.font
        tf.textColor = .neutral900
        tf.backgroundColor = .backgroundWhite
        tf.attributedPlaceholder = NSAttributedString(
            string: "0",
            attributes: [
                .foregroundColor: UIColor.neutral300
            ]
        )
        tf.textAlignment = .right
        
        let label = UILabel(frame: .init())
        label.text = String(localized: "Count")
        label.font = body16.font
        label.textColor = .neutral900
        
        let container = UIView()
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16))
        }
        label.sizeToFit()
        
        tf.configurePadding(width: Int(label.bounds.width))
        tf.rightView = container
        tf.rightViewMode = .always
        
        return tf
    }()
    
    // 금액 라벨
    private let amountLabel: UILabel = {
        let lb = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpAmount"),
            attributes: title14.attributes(alignment: .left)
        )
        lb.attributedText = attributedText
        lb.textColor = .neutral900
        
        return lb
    }()
    
    // 금액 textField
    private let itemAmountTextField: UITextField = {
        let tf = PaddedTextField()
        tf.layer.cornerRadius = 16
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.primary100.cgColor
        tf.font = body16.font
        tf.textColor = .neutral900
        tf.backgroundColor = .backgroundWhite
        tf.attributedPlaceholder = NSAttributedString(
            string: "0",
            attributes: [
                .foregroundColor: UIColor.neutral300
            ]
        )
        tf.textAlignment = .right
        
        let label = UILabel(frame: .init())
        label.text = String(localized: "Won")
        label.font = body16.font
        label.textColor = .neutral900
        
        let container = UIView()
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16))
        }
        label.sizeToFit()
        
        tf.configurePadding(width: Int(label.bounds.width))
        tf.rightView = container
        tf.rightViewMode = .always
        
        return tf
    }()
    
    // 등록하기 버튼
    private let registerButton = Button(title: String(localized: "Register"))
    
    // 등록된 상품 Label
    private let registeredItemLabel: UILabel = {
        let lb = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpRegisteredItem"),
            attributes: title18.attributes(alignment: .left)
        )
        lb.attributedText = attributedText
        lb.textColor = .neutral900
        
        return lb
    }()
    
    // 0개의 상품 Label
    private let itemCountLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .neutral900
        
        return lb
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
        
        updateItemCountLabel(count: 0)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [backButton, scrollView].forEach {
            view.addSubview($0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        [stepLabel, titleLabel, subtitleBackground, registerItemBackground, registeredItemLabel, itemCountLabel].forEach {
            contentView.addSubview($0)
        }
        
        subtitleBackground.addSubview(subtitleLabel)
        
        [itemNameLabel, itemNameTextField, unitLabel, unitButtonContainer, itemCountTextField, amountLabel, itemAmountTextField, registerButton].forEach {
            registerItemBackground.addSubview($0)
        }
        
        [quantityButton, weightButton].forEach {
            unitButtonContainer.addArrangedSubview($0)
        }
        
        backButton.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.leading.equalToSuperview().offset(4)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        stepLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(stepLabel.snp.bottom).offset(8)
            make.height.equalTo(32)
        }
        
        subtitleBackground.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.height.equalTo(64)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        registerItemBackground.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(subtitleBackground.snp.bottom).offset(8)
        }
        
        itemNameLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        itemNameTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(itemNameLabel.snp.bottom).offset(8)
            make.height.equalTo(52)
        }
        
        unitLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(itemNameTextField.snp.bottom).offset(16)
        }
        
        unitButtonContainer.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(unitLabel.snp.bottom).offset(8)
        }
        
        itemCountTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(unitButtonContainer.snp.bottom).offset(8)
            make.height.equalTo(52)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(itemCountTextField.snp.bottom).offset(16)
        }
        
        itemAmountTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.height.equalTo(52)
        }
        
        registerButton.snp.remakeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(itemAmountTextField.snp.bottom).offset(16)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
        
        registeredItemLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(registerItemBackground.snp.bottom).offset(32)
        }
        
        itemCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(registeredItemLabel)
        }
    }
    
    private func updateItemCountLabel(count: Int) {
        let format = String(localized: "SettleUpRegisteredItemCount")
        let fullText = String(format: format, count)
        let countString = "\(count)"
        
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: body16.attributes(alignment: .right)
        )
        
        if let range = fullText.range(of: countString) {
            let nsRange = NSRange(range, in: fullText)
            
            attributedString.addAttribute(.foregroundColor, value: UIColor.primary400, range: nsRange)
        }
        
        itemCountLabel.attributedText = attributedString
    }
}

extension SettleUp1stStepView {
    // reactor와 view 연결
    private func bind(reactor: SettleUp1stStepReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: SettleUp1stStepReactor) {
        // Back 버튼 탭
        backButton.rx.tap
            .map { Reactor.Action.backButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: SettleUp1stStepReactor) {
        // Back  버튼 탭
        reactor.pulse(\.$shouldPopViewController)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// 미리보기
#if DEBUG
import SwiftUI

struct SettleUp1stStepViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            SettleUp1stStepView(id: 1)
        }
    }
}
#endif
