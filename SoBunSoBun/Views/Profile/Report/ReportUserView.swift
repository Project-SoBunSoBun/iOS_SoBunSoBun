//
//  ReportUserView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/17/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import OSLog

class ReportUserView: UIViewController {
    private let userId: Int
    private let groupPostId: Int
    
    init(userId: Int, groupPostId: Int, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.userId = userId
        self.groupPostId = groupPostId
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Profile.ReportUser.View"
    )
    
    typealias Reactor = ReportUserReactor
    private lazy var reactor = ReportUserReactor(userId: userId, groupPostId: groupPostId)
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "ReportUser", table: "Report")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 전체 스크롤 뷰
    private let scrollView = UIScrollView()
    
    // 스크롤 뷰가 들어갈 View
    private let contentView = UIView()
    
    // 신고 유형
    private let reportTypeBox = SelectMenuBox(placeholder: String(localized: "SelectReportType", table: "Report"))
    
    // 제목 dropdown
    private let reportTypeDropDownView: SettingDropDownView = {
        let ddv = SettingDropDownView(tableName: "Report", isHeightLimited: false)
        ddv.textAlignment = .center
        ddv.items = ["SPAM", "INAPPROPRIATE", "SCAM", "HARMFUL", "ABUSE", "FRAUD", "OTHER"]
        ddv.animationAnchor = .topCenter
        
        return ddv
    }()
    
    // 신고 설명
    private let detailTextView: AutoHeightTextView = {
        let ahtv = AutoHeightTextView(minHeight: 240, maxLength: 240, fontStyle: body16)
        ahtv.placeholder = String(localized: "InsertReportDescription", table: "Report")
        ahtv.textContainerInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        ahtv.showCharactersCount = true
        ahtv.layer.cornerRadius = 16
        ahtv.layer.borderWidth = 1
        ahtv.layer.borderColor = UIColor.neutral200.cgColor
        ahtv.frame = CGRectInset(ahtv.frame, -ahtv.layer.borderWidth, -ahtv.layer.borderWidth)
        
        return ahtv
    }()
    
    // 신고 제출 동의 체크박스
    private let agreeCheckBox = TermsCheckBoxView()
    
    // 신고하기 버튼
    private let reportButton = Button(title: String(localized: "Report", table: "Report"))
    
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
        
        [topNavigationBar, reportButton, agreeCheckBox, scrollView, reportTypeDropDownView, loadingView].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        // 신고하기 버튼
        reportButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        // 체크박스 설정
        agreeCheckBox.configure(title: String(localized: "AgreeReport", table: "Settings"), hasDetail: false, font: body16.font, textColor: .neutral900)
        
        // 신고 제출 동의 체크박스
        agreeCheckBox.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(reportButton.snp.top).offset(-16)
        }
        
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(agreeCheckBox.snp.top).inset(-16)
        }
        
        [reportTypeBox, detailTextView].forEach {
            contentView.addSubview($0)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 신고 유형
        reportTypeBox.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        // 신고 설명
        detailTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(reportTypeBox.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
        
        // 신고 유형 dropdown
        reportTypeDropDownView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(reportTypeBox.snp.bottom).offset(16)
        }
        
        // 로딩 뷰
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ReportUserView {
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        // 신고 유형 드롭다운 열기
        reportTypeBox.didTap
            .observe(on: MainScheduler.instance)
            .map { _ in Reactor.Action.menuBoxTapped(!reactor.currentState.isMenuOpen)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 신고 유형 위치 선택
        reportTypeDropDownView.didCellTap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { menu in
                reactor.action.onNext(.menuBoxTapped(false))
                reactor.action.onNext(.dropDownCellTapped(menu))
            })
            .disposed(by: disposeBag)
        
        // 신고 내용 Text 전달
        detailTextView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.detailChanged($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 신고하기 버튼 선택
        reportButton.rx.tap
            .map { Reactor.Action.reportButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: Reactor) {
        // 신고 유형 드롭다운 개폐
        reactor.state.map { $0.isMenuOpen }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isOpen in
                guard let self = self else { return }
                
                reportTypeDropDownView.setOpen(isOpen: isOpen)
            })
            .disposed(by: disposeBag)
        
        // 신고 유형 라벨에 반영
        reactor.state.map { $0.reportType }
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                
                let localizedString = NSLocalizedString(type, tableName: "Report", comment: "")
                reportTypeBox.updateSelectedText(text: localizedString)
            })
            .disposed(by: disposeBag)
        
        // 제출 동의
        agreeCheckBox.isChecked
            .map { Reactor.Action.agreeCheckBoxTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 버튼 활성화 상태
        reactor.state.map { $0.isButtonEnabled }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: reportButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 신고 전송 완료
        reactor.pulse(\.$reportCompleted)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.logger.debug("신고 완료 알림 표시")
                reportDoneAlert()
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext:  { [weak self] errorMessage in
                guard let self = self else { return }
                
                self.errorAlert(description: errorMessage)
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태
        reactor.state.map { !$0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func reportDoneAlert() {
        let alert = CustomAlertView(
            title: String(localized: "Notice", table: "Common"),
            subTitle: String(localized: "ReportUserDoneAlertSubTitle", table: "Report"),
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.show(on: self)
    }
    
    private func errorAlert(description: String) {
        let alert = CustomAlertView(
            title: String(localized: "Error", table: "Common"),
            subTitle: description,
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            self.logger.debug("확인 버튼 클릭")
        }
        
        alert.show(on: self)
    }
}
