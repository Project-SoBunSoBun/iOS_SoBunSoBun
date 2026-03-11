//
//  SettleUp2ndStepView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/12/26.
//

import UIKit
import SnapKit
import OSLog
import RxSwift
import RxCocoa
import ReactorKit

class SettleUp2ndStepView: UIViewController {
    init(settlementId: Int, participants:[SettleUpParticipantModel] , products: [ListedProductModel], authorId: Int) {
        reactor = SettleUp2ndStepReactor(
            settlementId: settlementId,
            participants: participants,
            authorId: authorId
        )
        self.participants = participants
        self.products = products
        
        super.init(nibName: nil, bundle: nil)
    }
    
    typealias Reactor = SettleUp2ndStepReactor
    private let reactor: SettleUp2ndStepReactor
    
    private let disposeBag = DisposeBag()
    
    private let products: [ListedProductModel]
    private let participants: [SettleUpParticipantModel]
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "SettleUp2ndStep.View"
    )
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        
        return tnb
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
    
    // 2/3
    private let stepLabel: UILabel = {
        let lb = UILabel()
        let attributedText = NSAttributedString(
            string: "2/3",
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
            string: String(localized: "SettleUpStart", table: "SettleUp"),
            attributes: title24.attributes(alignment: .left)
        )
        lb.attributedText = attributedText
        lb.textColor = .neutral900
        
        return lb
    }()
    
    // 등록된 상품 수량 라벨 배경 뷰
    private let subtitleBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .primary50
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        
        return view
    }()
    
    // 등록된 상품 수량 라벨
    private let subtitleLabel: UILabel = {
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpParticipant", table: "SettleUp"),
            attributes: body14.attributes(alignment: .center)
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        lb.textColor = .neutral800
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 참여자별 정산 컴포넌트가 들어갈 스택뷰
    private let calculationStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        
        return sv
    }()
    
    // 등록하기 버튼
    private let registerButton = Button(title: String(localized: "Register", table: "Common"))
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setUpCalculationGuests()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, scrollView].forEach {
            view.addSubview($0)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        [stepLabel, titleLabel, subtitleBackground, calculationStackView, registerButton].forEach {
            contentView.addSubview($0)
        }
        
        subtitleBackground.addSubview(subtitleLabel)
        
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
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(53)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        calculationStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(subtitleBackground.snp.bottom).offset(8)
        }
        
        registerButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(calculationStackView.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setUpCalculationGuests() {
        calculationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let myUserIdString = KeyChain.shared.get(key: "USER_ID") else { return }
        let myUserId = Int(myUserIdString)
        
        let setParticipants = participants.map { participant -> String in
            if let myId = myUserId, participant.userId == myId {
                return "\(participant.nickname)(나)"
            }
            
            return participant.nickname
        }
        .sorted { $0.hasSuffix("(나)") && !$1.hasSuffix("(나)") }
        
        products.forEach { product in
            let guestView = CalculationGuest(product: product)
            
            guestView.setParticipants(setParticipants)
            
            calculationStackView.addArrangedSubview(guestView)
        }
    }
}

extension SettleUp2ndStepView {
    // reactor와 view 연결
    private func bind(reactor: SettleUp2ndStepReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: SettleUp2ndStepReactor) {
        registerButton.rx.tap
            .map { [weak self] () -> Reactor.Action in
                guard let self = self else { return .registerButtonTapped([]) }
                
                let allSelections = self.calculationStackView.arrangedSubviews
                    .compactMap { $0 as? CalculationGuest }
                    .map { $0.getSelectionData() }
                
                return .registerButtonTapped(allSelections)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: SettleUp2ndStepReactor) {
        // 3단계 화면 전환
        reactor.pulse(\.$shouldNavigateToNextStep)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                let nextVC = SettleUp3rdStepView(model: model)
                self.navigationController?.pushViewController(nextVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 수량 불일치 알림
        reactor.pulse(\.$validationError)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.validationErrorAlert(title: message)
            })
            .disposed(by: disposeBag)
    }
    
    // 수량 불일치 알러트
    private func validationErrorAlert(title: String) {
        let alert = CustomAlertView(
            title: NSLocalizedString(title, tableName: "SettleUp", comment: ""),
            subTitle: String(localized: "ValidationCheckQuantity", table: "SettleUp"),
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            self.logger.debug("확인 버튼 클릭")
        }
        
        alert.show(on: self)
    }
}
