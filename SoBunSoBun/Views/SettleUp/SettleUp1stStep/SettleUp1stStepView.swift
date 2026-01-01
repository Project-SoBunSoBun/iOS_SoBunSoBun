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
        let tf = PaddedTextField(fontStyle: body16)
        tf.layer.cornerRadius = 16
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.primary100.cgColor
        tf.textColor = .neutral900
        tf.backgroundColor = .backgroundWhite
        tf.placeholder = String(localized: "SettleUpItemNamePlaceholder")
        
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
    private let quantityButton = UnitButton(
        titleKey: "SettleUpQuantity",
        isSelected: true
    )
    
    // 중량(g) 버튼
    private let weightButton = UnitButton(
        titleKey: "SettleUpWeight",
        isSelected: false
    )
    
    // 단위 textField
    private let itemCountTextField = RightViewTextField(
        rightText: String(localized: "Count")
    )
    
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
    private let itemAmountTextField = RightViewTextField(
        rightText: String(localized: "Won")
    )
    
    // 등록하기 버튼
    private let registerButton = Button(title: String(localized: "Register")
    )
    
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
    
    // 공백 상태 메시지를 추가 할 View
    private let emptyStateView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    // 공백 상태 메시지
    private let emptyStateLabel: UILabel = {
        let lb = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpRegisterEmpty"),
            attributes: body16.attributes(alignment: .center)
        )
        lb.attributedText = attributedText
        lb.textColor = .neutral300
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // ListedProduct가 들어갈 StackView
    private let productStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 0
        
        return sv
    }()
    
    // 총 금액 Label과 총 금액원 Label이 들어갈 StackView
    private let totalLabelStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        
        return sv
    }()
    
    // totalLabelStackView의 배경
    private let totalBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral50
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        
        return view
    }()
    
    // 총 금액 Label
    private let totalLabel: UILabel = {
        let lb = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpTotalPrice"),
            attributes: title18.attributes(alignment: .left)
        )
        lb.attributedText = attributedText
        lb.textColor = .primary400
        
        return lb
    }()
    
    // 총 금액 원 Label
    private let totalPriceLabel: UILabel = {
        let lb = UILabel()
        let won = String(localized: "Won")
        let attributedText = NSAttributedString(
            string: "0\(won)",
            attributes: title18.attributes(alignment: .right)
        )
        lb.attributedText = attributedText
        lb.textColor = .neutral900
        
        return lb
    }()
    
    // 천단위 콤마 Formatter
    private let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        
        return formatter
    }()
    
    // 정산하기 버튼
    private let settleUpButton = Button(title: String(localized: "SettleUpStart"))
    
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
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        [stepLabel, titleLabel, subtitleBackground, registerItemBackground, registeredItemLabel, itemCountLabel, emptyStateView, emptyStateLabel].forEach {
            contentView.addSubview($0)
        }
        
        subtitleBackground.addSubview(subtitleLabel)
        
        [itemNameLabel, itemNameTextField, unitLabel, unitButtonContainer, itemCountTextField, amountLabel, itemAmountTextField, registerButton].forEach {
            registerItemBackground.addSubview($0)
        }
        
        [quantityButton, weightButton].forEach {
            unitButtonContainer.addArrangedSubview($0)
        }
        
        totalBackgroundView.addSubview(totalLabelStackView)
        
        [totalLabel, totalPriceLabel].forEach {
            totalLabelStackView.addArrangedSubview($0)
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
        }
        
        subtitleBackground.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.height.equalTo(74)
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
            make.top.equalTo(registerItemBackground.snp.bottom).offset(24)
        }
        
        itemCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(registeredItemLabel)
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(registeredItemLabel.snp.bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(160)
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalTo(emptyStateView)
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
    
    private func updateSubTitleLabel(count: Int) {
        let format = String(localized: "SettleUpItemRegistered")
        
        let attributedText = NSAttributedString(
            string: String(format: format, count),
            attributes: body14.attributes(alignment: .center)
        )
        
        subtitleLabel.attributedText = attributedText
    }
    
    private func renderProducts(products: [ListedProductModel]) {
        productStackView.arrangedSubviews.forEach {
            productStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        if products.isEmpty {
            showEmptyState()
        } else {
            showProductList(products: products)
        }
        
        updateItemCountLabel(count: products.count)
        updateSubTitleLabel(count: products.count)
    }
    
    private func showEmptyState() {
        productStackView.removeFromSuperview()
        totalBackgroundView.removeFromSuperview()
        settleUpButton.removeFromSuperview()
        
        if emptyStateView.superview == nil {
            [emptyStateView, emptyStateLabel].forEach {
                contentView.addSubview($0)
            }
            
            emptyStateView.snp.remakeConstraints { make in
                make.horizontalEdges.equalToSuperview()
                make.top.equalTo(registeredItemLabel.snp.bottom)
                make.bottom.equalToSuperview()
                make.height.equalTo(160)
            }
            
            emptyStateLabel.snp.remakeConstraints { make in
                make.center.equalTo(emptyStateView)
            }
        }
    }
    
    private func showProductList(products: [ListedProductModel]) {
        [emptyStateView, emptyStateLabel].forEach {
            $0.removeFromSuperview()
        }
        
        if productStackView.superview == nil {
            [productStackView, totalBackgroundView, settleUpButton].forEach {
                contentView.addSubview($0)
            }
            
            productStackView.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(16)
                make.top.equalTo(registeredItemLabel.snp.bottom).offset(16)
            }
            
            totalBackgroundView.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(16)
                make.top.equalTo(productStackView.snp.bottom).offset(16)
            }
            
            totalLabelStackView.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(16)
                make.verticalEdges.equalToSuperview().inset(10)
            }
            
            settleUpButton.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(16)
                make.top.equalTo(totalBackgroundView.snp.bottom).offset(16)
                make.bottom.equalToSuperview().inset(16)
            }
        }
        
        products.enumerated().forEach { index, product in
            let view = ListedProduct(
                itemName: product.name,
                itemCount: product.count,
                itemPrice: product.price,
                unitIndex: product.unitIndex
            )
            
            // 수정하기 버튼 이벤트 처리
            view.onEditButtonTapped = { [weak self] in
                guard let self = self else { return }
                
                self.showEditItemAlert(index: index)
            }
            
            // 삭제 버튼 이벤트 처리
            view.onDeleteButtonTapped = { [weak self] in
                guard let self = self else { return }
                
                self.showDeleteItemAlert(index: index)
            }
            
            productStackView.addArrangedSubview(view)
            
            view.snp.makeConstraints { make in
                make.horizontalEdges.width.equalToSuperview()
            }
        }
    }
    
    // 삭제 알림창
    private func showDeleteItemAlert(index: Int) {
        let alert = CustomAlertView(
            title: String(localized: "SettleUp1stStepDeleteMessage"),
            primaryTitleKey: String(localized: "Delete"),
            cancelTitleKey: String(localized: "Cancel")
        )
        
        alert.isSubtitleEnabled = false
        
        alert.onPrimaryTapped = {
            self.reactor.action.onNext(.productDeleted(index))
        }
        
        alert.onCancelTapped = {
            self.logger.debug("취소됨")
        }
        
        alert.show(on: self)
    }
    
    // 수정 알림창
    private func showEditItemAlert(index: Int) {
        let alert = CustomAlertView(
            title: String(localized: "SettleUp1stStepEditMessage"),
            primaryTitleKey: String(localized: "ListedProductEdit"),
            cancelTitleKey: String(localized: "Cancel")
        )
        
        alert.isSubtitleEnabled = false
        
        alert.onPrimaryTapped = {
            self.reactor.action.onNext(.productEdited(index))
        }
        
        alert.onCancelTapped = {
            self.logger.debug("취소됨")
        }
        
        alert.show(on: self)
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
        
        // 수량 버튼 탭
        quantityButton.rx.tap
            .map { Reactor.Action.unitButtonTapped(1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 중량 버튼 탭
        weightButton.rx.tap
            .map { Reactor.Action.unitButtonTapped(2) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 등록하기 버튼 활성화 여부
        Observable.combineLatest(
            itemNameTextField.rx.text.orEmpty,
            itemCountTextField.rx.text.orEmpty,
            itemAmountTextField.rx.text.orEmpty
        )
        .map { !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty }
        .bind(to: registerButton.rx.isEnabled)
        .disposed(by: disposeBag)
        
        // 등록하기 버튼 탭
        registerButton.rx.tap
            .withLatestFrom(
                Observable.combineLatest(
                    itemNameTextField.rx.text.orEmpty,
                    itemCountTextField.rx.text.orEmpty,
                    itemAmountTextField.rx.text.orEmpty
                )
            )
            .map { name, count, amount in
                Reactor.Action.registerButtonTapped(name: name, count: count, amount: amount)
            }
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
        
        // 선택된 단위에 따라 UI 업데이트
        reactor.state.map { $0.selectedUnitIndex }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] selectedIndex in
                guard let self = self else { return }
                
                self.updateUnitSelection(selectedIndex: selectedIndex)
            })
            .disposed(by: disposeBag)
        
        // 스택뷰에 상품 등록하기
        reactor.state.map { $0.products }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] products in
                guard let self = self else { return }
                
                self.renderProducts(products: products)
            })
            .disposed(by: disposeBag)
        
        // 등록 후 TextField 초기화
        reactor.state.map { $0.products.count }
            .distinctUntilChanged()
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.itemNameTextField.text = ""
                self.itemCountTextField.text = ""
                self.itemAmountTextField.text = ""
                
                self.itemNameTextField.sendActions(for: .editingChanged)
                self.itemCountTextField.sendActions(for: .editingChanged)
                self.itemAmountTextField.sendActions(for: .editingChanged)
            })
            .disposed(by: disposeBag)
        
        // 총 금액 라벨 UI 업데이트
        reactor.state.map { $0.totalPrice }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] total in
                guard let self = self else { return }
                
                let won = String(localized: "Won")
                let formattedNumber = priceFormatter.string(from: NSNumber(value: total)) ?? "\(total)"
                let format = "\(formattedNumber)\(won)"
                let attributedText = NSAttributedString(
                    string: format,
                    attributes: title18.attributes(alignment: .right)
                )
                
                self.totalPriceLabel.attributedText = attributedText
            })
            .disposed(by: disposeBag)
        
        // 상품 수정하기 클릭 후 라벨 업데이트
        reactor.state.map { $0.editingProduct }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] product in
                guard let self = self else { return }
                
                self.itemNameTextField.text = product.name
                self.reactor.action.onNext(.unitButtonTapped(product.unitIndex))
                
                DispatchQueue.main.async {
                    self.itemCountTextField.text = "\(product.count)"
                    self.itemAmountTextField.text = "\(product.price)"
                    
                    self.itemNameTextField.sendActions(for: .editingChanged)
                    self.itemCountTextField.sendActions(for: .editingChanged)
                    self.itemAmountTextField.sendActions(for: .editingChanged)
                }
            })
            .disposed(by: disposeBag)
        
        // 등록하기(수정하기) 버튼 텍스트 변경
        reactor.state.map { $0.isEditing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEditing in
                guard let self = self else { return }
                
                let title = isEditing ? String(localized: "ListedProductEdit") : String(localized: "Register")
                
                self.registerButton.changeTitle(title: title)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUnitSelection(selectedIndex: Int) {
        let isQuantity = selectedIndex == 1
        
        // quantityButton 설정
        var quantityConfig = quantityButton.configuration
        quantityConfig?.baseBackgroundColor = isQuantity ? .primary100 : .primary50
        quantityConfig?.baseForegroundColor = isQuantity ? .primary400 : .primary300
        quantityButton.configuration = quantityConfig
        quantityButton.layer.borderWidth = isQuantity ? 2 : 0
        quantityButton.layer.borderColor = isQuantity ? UIColor.primary400.cgColor : nil
        
        // weightButton 설정
        var weightConfig = weightButton.configuration
        weightConfig?.baseBackgroundColor = isQuantity ? .primary50 : .primary100
        weightConfig?.baseForegroundColor = isQuantity ? .primary300 : .primary400
        weightButton.configuration = weightConfig
        weightButton.layer.borderWidth = isQuantity ? 0 : 2
        weightButton.layer.borderColor = isQuantity ? nil : UIColor.primary400.cgColor
        
        // unit text 업데이트
        itemCountTextField.updateRightViewText(isQuantity ? String(localized: "Count") : "g")
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
