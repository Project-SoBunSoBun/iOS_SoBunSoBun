//
//  SettleUp2ndStepView.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 1/12/26.
//

import UIKit
import SnapKit
import OSLog
import RxSwift
import RxCocoa

class SettleUp2ndStepView: BaseViewController {
    typealias Reactor = SettleUp2ndStepReactor
    private let reactor: SettleUp2ndStepReactor
    
    private let products: [ListedProductModel]
    private let participants: [SettleUpParticipantModel]
    
    init(settlementId: Int, participants:[SettleUpParticipantModel] , products: [ListedProductModel], authorId: Int, nibName: String? = nil, bundle: Bundle? = nil) {
        reactor = SettleUp2ndStepReactor(
            settlementId: settlementId,
            participants: participants,
            authorId: authorId
        )
        self.participants = participants
        self.products = products
        
        super.init(nibName: nibName, bundle: bundle)
    }
    
    private let disposeBag = DisposeBag()
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
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
        var attributes = title14.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.primary400
        
        let attributedText = NSAttributedString(
            string: "2/3",
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        
        return lb
    }()
    
    // 제목 라벨
    private let titleLabel: UILabel = {
        var attributes = title24.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpStart", table: "SettleUp"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        
        return lb
    }()
    
    // 참여자별 정산 안내 라벨 배경
    private let subtitleBackground: UIView = {
        let v = UIView()
        v.backgroundColor = .primary50
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        
        return v
    }()
    
    // 참여자별 정산 안내 라벨
    private let subtitleLabel: UILabel = {
        var attributes = body14.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.neutral800
        
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpParticipant", table: "SettleUp"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
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
        [topNavigationBar, scrollView, registerButton].forEach {
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
            make.horizontalEdges.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
            make.width.equalToSuperview()
        }
        
        [stepLabel, titleLabel, subtitleBackground, calculationStackView].forEach {
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
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        calculationStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(subtitleBackground.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
        
        registerButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func setUpCalculationGuests() {
        calculationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let myUserIdString = KeyChain.shared.get(key: "USER_ID"),
              let myId = Int(myUserIdString) else { return }
        
        let localizedMe = String(localized: "Me", table: "SettleUp")
        
        let setParticipants = participants.map { participant -> String in
            if participant.userId == myId {
                return "\(participant.nickname)\(localizedMe)"
            }
            
            return participant.nickname
        }.sorted { $0.hasSuffix(localizedMe) && !$1.hasSuffix(localizedMe) }
        
        products.forEach { product in
            let guestView = CalculationGuest(product: product)
            guestView.setParticipants(setParticipants)
            
            calculationStackView.addArrangedSubview(guestView)
        }
    }
}

extension SettleUp2ndStepView {
    // reactor와 view 연결
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        registerButton.rx.tap
            .map { [weak self] () -> Reactor.Action in
                guard let self = self else { return Reactor.Action.registerButtonTapped([]) }
                
                let allSelections = self.calculationStackView.arrangedSubviews
                    .compactMap { $0 as? CalculationGuest }
                    .map { $0.getSelectionData() }
                
                return Reactor.Action.registerButtonTapped(allSelections)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: Reactor) {
        // 3단계 화면 전환
        reactor.pulse(\.$shouldNavigateToNextStep)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                let nextVC = SettleUp3rdStepView(model: model, authorId: reactor.currentState.authorId)
                self.navigationController?.pushViewController(nextVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 검증 오류 알림
        reactor.pulse(\.$validationError)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.validationErrorAlert(subtitle: message)
            })
            .disposed(by: disposeBag)
    }
    
    // 검증 오류 알러트
    private func validationErrorAlert(subtitle: String) {
        let alert = CustomAlert(
            title: String(localized: "ValidationError", table: "SettleUp"),
            subTitle: NSLocalizedString(subtitle, tableName: "SettleUp", comment: ""),
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.show(on: self)
    }
}
