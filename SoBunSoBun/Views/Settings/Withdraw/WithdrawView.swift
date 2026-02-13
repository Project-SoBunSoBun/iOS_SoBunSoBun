//
//  WithdrawView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/5/26.
//

import UIKit
import SnapKit
import OSLog
import RxSwift
import RxCocoa
import RxGesture

class WithdrawView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.Withdraw.View"
    )
    
    private let disposeBag = DisposeBag()
    
    typealias Reactor = WithdrawReactor
    private let reactor = WithdrawReactor()
    
    private let withdrawMessageKeys = [
        "WithdrawMessage1",
        "WithdrawMessage2",
        "WithdrawMessage3"
    ]
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "Withdraw", table: "Settings")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 전체 스크롤 뷰
    private let scrollView = UIScrollView()
    
    // 스크롤 뷰가 들어갈 View
    private let contentView = UIView()
    
    // 화면 상단 타이틀 라벨
    private let titleLabel: UILabel = {
        var attributes = title24.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributedText = NSAttributedString(
            string: String(localized: "WithdrawTitle", table: "Settings"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 회원 탈퇴 안내 메세지 라벨을 만드는 함수
    private func makeWithdrawMessage(string: String) -> UILabel {
        var attributes = body16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral700
        
        let attributedText = NSAttributedString(
            string: string,
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        lb.numberOfLines = 0
        
        return lb
    }
    
    // 1. 2. 3. 라벨을 만들어 주는 함수
    private func makeNumberLabel(string: String) -> UILabel {
        var attributes = body16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral700
        
        let attributedText = NSAttributedString(
            string: string,
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        lb.snp.makeConstraints { make in
            make.width.equalTo(16)
        }
        
        return lb
    }
    
    // 라벨과 안내 문구가 들어갈 스택뷰를 만드는 함수
    private func makeHorizontalStackView() -> UIStackView {
        let hs = UIStackView()
        hs.spacing = 8
        hs.axis = .horizontal
        hs.alignment = .top
        
        return hs
    }
    
    // 탈퇴 안내 문구를 만드는 함수
    private func setupWithdrawMessages() {
        withdrawMessageKeys.enumerated().forEach { index, key in
            // 1. 가로 스택뷰 생성
            let hs = makeHorizontalStackView()
            
            // 2. 숫자 라벨 생성 (1., 2., 3.)
            let numberLabel = makeNumberLabel(string: "\(index + 1).")
            
            // 3. 메시지 라벨 생성
            let messageLabel = makeWithdrawMessage(string: String(localized: String.LocalizationValue(key), table: "Settings"))
            
            // 4. 가로 스택뷰에 순서대로 추가
            [numberLabel, messageLabel].forEach {
                hs.addArrangedSubview($0)
            }
            
            // 5. 메인 세로 스택뷰에 추가
            verticalStackView.addArrangedSubview(hs)
        }
    }

    private let verticalStackView: UIStackView = {
        let vs = UIStackView()
        vs.axis = .vertical
        vs.spacing = 0
        
        return vs
    }()
    
    // 탈퇴 사유 라벨
    private let reasonLabel: UILabel = {
        var attributes = title16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributedText = NSAttributedString(
            string: String(localized: "WithdrawReason", table: "Settings"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        
        return lb
    }()
    
    // 탈퇴 사유와 아이콘이 들어갈 스택뷰
    private let reasonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 0, bottom: 16, right: 0)
        sv.isUserInteractionEnabled = true
        
        return sv
    }()
    
    // 선택된 탈퇴 사유 라벨
    private let selectedReasonLabel: UILabel = {
        var attributes = body16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral400
        
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "SelectWithdrawReason", table: "Settings"), attributes: attributes)
        
        return lb
    }()
    
    // 드롭다운 아이콘
    private let dropDownIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = .blackDown.resize(.init(width: 24, height: 24))
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    // 구분선
    private let divider: UIView = {
        let divider = UIView()
        divider.backgroundColor = .neutral200
        
        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        return divider
    }()
    
    // 탈퇴 사유 dropdown
    private let reasonDropDownView: SettingDropDownView = {
        let ddv = SettingDropDownView(tableName: "Settings", isHeightLimited: false)
        ddv.textAlignment = .center
        ddv.items = ["WithdrawReason001", "WithdrawReason002", "WithdrawReason003", "WithdrawReason004"]
        ddv.animationAnchor = .topCenter
        
        return ddv
    }()
    
    // 내용을 입력해 주세요
    private let reasonDetailTextView: AutoHeightTextView = {
        let ahtv = AutoHeightTextView(minHeight: 240, maxHeight: 240, maxLength: 100, fontStyle: body16)
        ahtv.placeholder = String(localized: "InsertContent", table: "Common")
        ahtv.textContainerInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        ahtv.showCharactersCount = true
        ahtv.layer.cornerRadius = 16
        ahtv.layer.borderWidth = 1
        ahtv.layer.borderColor = UIColor.neutral200.cgColor
        ahtv.frame = CGRectInset(ahtv.frame, -ahtv.layer.borderWidth, -ahtv.layer.borderWidth)
        
        return ahtv
    }()
    
    // 탈퇴 동의 체크박스
    private let agreeCheckBox = TermsCheckBoxView()
    
    // 탈퇴하기 버튼
    private let withDrawButton = Button(title: String(localized: "Withdraw", table: "Settings"))
    
    // 로딩 화면
    private lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.isHidden = true
        
        return view
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
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
        
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        // 스크롤 뷰 안에 들어가는 요소들
        [titleLabel, verticalStackView, reasonLabel, reasonStackView, divider, reasonDetailTextView, agreeCheckBox, reasonDropDownView, withDrawButton].forEach {
            contentView.addSubview($0)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        setupWithdrawMessages()
        
        verticalStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        reasonLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(verticalStackView.snp.bottom).offset(32)
        }
        
        [selectedReasonLabel, dropDownIcon].forEach {
            reasonStackView.addArrangedSubview($0)
        }
        
        reasonStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(reasonLabel.snp.bottom).offset(8)
        }
        
        selectedReasonLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        selectedReasonLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        dropDownIcon.setContentHuggingPriority(.required, for: .horizontal)
        dropDownIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        divider.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(reasonStackView)
            make.top.equalTo(reasonStackView.snp.bottom)
        }
        
        reasonDetailTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(divider.snp.bottom).offset(16)
        }
        
        // 탈퇴 동의 설정
        agreeCheckBox.configure(title: String(localized: "AgreeWithdraw", table: "Settings"), hasDetail: false, font: body14.font, textColor: .neutral900)
        
        agreeCheckBox.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(reasonDetailTextView.snp.bottom).offset(16)
        }
        
        reasonDropDownView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(divider.snp.bottom).offset(16)
        }
        
        withDrawButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(agreeCheckBox.snp.bottom).offset(36)
            make.bottom.equalToSuperview()
        }
    }
}

extension WithdrawView {
    private func bind(reactor: WithdrawReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: WithdrawReactor) {
        // 탈퇴 사유 드롭다운 열기
        reasonStackView.rx
            .tapGesture()
            .when(.recognized)
            .observe(on: MainScheduler.instance)
            .map { _ in Reactor.Action.reasonTapped(!reactor.currentState.isMenuOpen)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 탈퇴 사유 선택
        reasonDropDownView.didCellTap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { menu in
                reactor.action.onNext(.reasonTapped(false))
                
                guard let menuNum = Int(menu.suffix(3)) else { return }
                
                reactor.action.onNext(.dropDownCellTapped(menuNum))
            })
            .disposed(by: disposeBag)
        
        // 탈퇴 동의
        agreeCheckBox.isChecked
            .map { Reactor.Action.agreeCheckBoxTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 탈퇴하기 버튼 클릭
        withDrawButton.rx.tap
            .map { Reactor.Action.withdrawButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 탈퇴 사유 내용
        reasonDetailTextView.rx.text
            .distinctUntilChanged()
            .map { Reactor.Action.reasonDetailChanged($0 ?? "") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: WithdrawReactor) {
        // 탈퇴 사유 드롭다운 개폐
        reactor.state.map { $0.isMenuOpen }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isOpen in
                guard let self = self else { return }
                
                reasonDropDownView.setOpen(isOpen: isOpen)
            })
            .disposed(by: disposeBag)
        
        // 탈퇴 사유 라벨에 반영
        reactor.state.map { $0.reasonNumber }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] reasonNumber in
                guard let self = self else { return }
                
                let paddedNumber = String(format: "%03d", reasonNumber)
                let key = "WithdrawReason\(paddedNumber)"
                let localizedString = String(localized: String.LocalizationValue(key), table: "Settings")
                
                var attributes: [NSAttributedString.Key: Any] = body16.attributes(alignment: .left)
                attributes[.foregroundColor] = UIColor.neutral900
                
                selectedReasonLabel.attributedText = NSAttributedString(string: localizedString, attributes: attributes)
            })
            .disposed(by: disposeBag)
        
        // 버튼 활성화 반영
        reactor.state.map { $0.isEnable }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: withDrawButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 탈퇴 완료
        reactor.pulse(\.$withdrawCompleted)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.logger.debug("탈퇴 완료 알림 표시")
                withdrawAlert()
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                guard let self = self else { return }
                
                self.logger.error("에러: \(errorMessage)")
                self.errorAlert()
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading {
                    self.showLoadingView()
                } else {
                    loadingView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func withdrawAlert() {
        let alert = CustomAlertView(
            title: String(localized: "WithdrawCompleted", table: "Settings"),
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            AuthManager.shared.removeTokens()
            AuthManager.shared.switchToLoginView()
        }
        
        alert.show(on: self)
    }
    
    private func errorAlert() {
        let alert = CustomAlertView(
            title: String(localized: "ErrorMessage", table: "Common"),
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            AuthManager.shared.removeTokens()
            AuthManager.shared.switchToLoginView()
        }
        
        alert.show(on: self)
    }
    
    private func showLoadingView() {
        if loadingView.superview == nil {
            view.addSubview(loadingView)
            loadingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        loadingView.isHidden = false
    }
}
