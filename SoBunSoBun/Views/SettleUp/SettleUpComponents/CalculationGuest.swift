//
//  CalculationGuest.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/13/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import OSLog

class CalculationGuest: UIView {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "SettleUpComponents.CalculationGuest"
    )
    
    init(frame: CGRect = .zero, product: ListedProductModel
    ) {
        self.product = product
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let disposeBag = DisposeBag()
    private var labelsDisposeBag = DisposeBag()
    
    private let product: ListedProductModel
    
    private var availableParticipants: [String] = [] {
        didSet {
            updateParticipantLabels()
        }
    }
    
    // 선택된 참여자들 리스트
    private var selectedParticipants: Set<String> = []
    
    private var dividerTopAnchor: ConstraintItem {
        return participantLabelsView.superview != nil
        ? participantLabelsView.snp.bottom
        : productLabel.snp.bottom
    }
    
    // MARK: - 디자인 요소
    // 배경 View
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary50
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        
        return view
    }()
    
    // 상품명
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.lineBreakMode = .byTruncatingTail
        
        return lb
    }()
    
    // 상품 수량 및 총금액
    private let productLabel: UILabel = {
        let lb = UILabel()
        
        return lb
    }()
    
    // 닉네임들
    private let participantLabelsView = HorizontalWrappingView(horizontalSpacing: 8, verticalSpacing: 8)
    
    // 구분선
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .primary100
        
        return view
    }()
    
    // CalculationGuestItem이 들어갈 StackView
    private let selectedGuestsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        return stackView
    }()
    
    // 천단위 콤마 Formatter
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        
        return formatter
    }()
    
    // MARK: - 레이아웃 설정
    private func configure() {
        self.backgroundColor = .clear
        
        self.addSubview(backgroundView)
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        [titleLabel, productLabel, participantLabelsView, selectedGuestsStackView].forEach {
            backgroundView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16).priority(.high)
            make.top.equalToSuperview().offset(16)
        }
        
        productLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16).priority(.high)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        participantLabelsView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16).priority(.high)
            make.top.equalTo(productLabel.snp.bottom).offset(16)
        }
        
        selectedGuestsStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16).priority(.high)
            make.top.equalTo(participantLabelsView.snp.bottom)
            make.bottom.equalToSuperview().inset(16).priority(999)
        }
        
        // 텍스트 설정 (레이아웃 제약 설정 후)
        setupLabels(with: product)
    }
    
    // TextField의 개 / g 텍스트 설정
    private func setupLabels(with product: ListedProductModel) {
        // 상품명 설정
        var titleAttributes = title18.attributes(alignment: .left)
        titleAttributes[.foregroundColor] = UIColor.neutral900
        
        let titleAttributedText = NSAttributedString(
            string: product.name,
            attributes: titleAttributes
        )
        titleLabel.attributedText = titleAttributedText
        
        // 상품 수량/중량 및 총 가격 설정
        let won = String(localized: "KRW", table: "SettleUp")
        let countString = numberFormatter.string(from: NSNumber(value: product.count)) ?? "\(product.count)"
        let priceString = numberFormatter.string(from: NSNumber(value: product.price)) ?? "\(product.price)"
        let totalText: String
        
        switch product.unitIndex {
        case 1:
            let format = String(localized: "ListedProductItemTotal", table: "SettleUp")
            totalText = String(format: format, countString, priceString)
            
        case 2:
            totalText = "\(countString)g \(priceString)\(won)"
            
        default:
            let format = String(localized: "ListedProductItemTotal", table: "SettleUp")
            totalText = String(format: format, countString, priceString)
        }
        
        var productAttributes = body16.attributes(alignment: .left)
        productAttributes[.foregroundColor] = UIColor.neutral900
        
        let productAttributedText = NSAttributedString(
            string: totalText,
            attributes: productAttributes
        )
        productLabel.attributedText = productAttributedText
    }
    
    // 참여자 업데이트
    private func updateParticipantLabels() {
        // 기존 라벨 및 바인딩 초기화
        participantLabelsView.removeAllArrangedSubviews()
        labelsDisposeBag = DisposeBag()
        
        // 선택되지 않은 참여자 필터링
        let filteredParticipants = availableParticipants.filter { !selectedParticipants.contains($0) }
        
        if filteredParticipants.isEmpty {
            // 모두 선택됨 → participantLabelsView 제거
            if participantLabelsView.superview != nil {
                participantLabelsView.removeFromSuperview()
                
                // divider가 표시 중이면 기준점 변경
                if divider.superview != nil {
                    divider.snp.remakeConstraints { make in
                        make.horizontalEdges.equalToSuperview().inset(16).priority(.high)
                        make.top.equalTo(dividerTopAnchor).offset(16)
                        make.height.equalTo(2)
                    }
                }
            }
        } else {
            // 선택 가능한 참여자 있음 → participantLabelsView 복원
            if participantLabelsView.superview == nil {
                backgroundView.addSubview(participantLabelsView)
                
                participantLabelsView.snp.remakeConstraints { make in
                    make.horizontalEdges.equalToSuperview().inset(16).priority(.high)
                    make.top.equalTo(productLabel.snp.bottom).offset(16)
                }
                
                // divider가 표시 중이면 기준점 원복
                if divider.superview != nil {
                    divider.snp.remakeConstraints { make in
                        make.horizontalEdges.equalToSuperview().inset(16).priority(.high)
                        make.top.equalTo(dividerTopAnchor).offset(16)
                        make.height.equalTo(2)
                    }
                }
            }
            
            // 필터링된 참여자들로 라벨 생성 및 추가
            filteredParticipants.forEach { nickname in
                let label = CalculationGuestLabel()
                label.attributedText = NSAttributedString(string: nickname, attributes: title14.attributes(alignment: .center))
                
                label.tapped
                    .take(1)
                    .subscribe(onNext: { [weak self] tappedNickname in
                        guard let self = self else { return }
                        self.handleParticipantTapped(nickname: tappedNickname)
                    })
                    .disposed(by: labelsDisposeBag)
                
                participantLabelsView.addArrangedSubview(label)
            }
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // 닉네임 라벨을 클릭했을 때 동작할 함수
    private func handleParticipantTapped(nickname: String) {
        logger.debug("참여자 선택: \(nickname)")
        
        // 선택된 참여자 Set에 추가
        selectedParticipants.insert(nickname)
        
        // 라벨 목록 업데이트
        updateParticipantLabels()
        
        // 구분선 표시
        if divider.superview == nil {
            showDivider()
        }
        
        // 선택된 게스트 항목 추가
        let guestItem = CalculationGuestItem(nickname: nickname, product: product)
        
        // 닉네임 라벨 탭 이벤트 처리
        guestItem.nicknameTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.handleGuestItemRemoved(nickname: nickname, guestItem: guestItem)
            })
            .disposed(by: disposeBag)
        
        selectedGuestsStackView.addArrangedSubview(guestItem)
        self.layoutIfNeeded()
    }
    
    private func handleGuestItemRemoved(nickname: String, guestItem: CalculationGuestItem) {
        logger.debug("참여자 제거: \(nickname)")
        
        // 선택된 참여자 Set에서 제거
        selectedParticipants.remove(nickname)
        
        // StackView에서 해당 아이템 제거
        self.selectedGuestsStackView.removeArrangedSubview(guestItem)
        guestItem.removeFromSuperview()
        
        // 라벨 목록 업데이트 (다시 나타남)
        self.updateParticipantLabels()
        
        // 선택된 게스트가 없으면 구분선 숨기기
        if self.selectedParticipants.isEmpty {
            self.hideDivider()
        }
        
        self.layoutIfNeeded()
    }
    
    private func showDivider() {
        guard divider.superview == nil else { return }
        
        backgroundView.addSubview(divider)
        
        divider.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(dividerTopAnchor).offset(16)
            make.height.equalTo(2)
        }
        
        selectedGuestsStackView.snp.remakeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(divider.snp.bottom).offset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func hideDivider() {
        guard divider.superview != nil else {return }
        
        self.divider.removeFromSuperview()
        
        selectedGuestsStackView.snp.remakeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(dividerTopAnchor)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    // 외부에서 참여자를 추가하는 함수
    func setParticipants(_ participants: [String]) {
        self.availableParticipants = participants
        self.selectedParticipants.removeAll()
    }
    
    // 외부에서 선택을 초기화 시키는 함수
    func resetSelections() {
        selectedParticipants.removeAll()
        
        selectedGuestsStackView.arrangedSubviews.forEach { view in
            selectedGuestsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        hideDivider()
        updateParticipantLabels()
    }
    
    // 외부에서 각 항목별 정산 내용을 받는 함수
    func getSelectionData() -> SettleUpProductSelectionModel {
        let selections = selectedGuestsStackView.arrangedSubviews
            .compactMap { $0 as? CalculationGuestItem }
            .map { item in
                ParticipantSelectionModel(userNickname: item.getNickname(), value: item.getCount())
            }
        
        return SettleUpProductSelectionModel(
            productName: self.product.name,
            unitIndex: self.product.unitIndex,
            totalPrice: self.product.price,
            totalCount: self.product.count,
            selections: selections
        )
    }
}
