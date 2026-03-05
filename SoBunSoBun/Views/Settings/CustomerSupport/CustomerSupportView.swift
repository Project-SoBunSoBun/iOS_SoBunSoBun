//
//  CustomerSupportView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/28/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import OSLog

class CustomerSupportView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.CustomerSupport.View"
    )
    
    typealias Reactor = CustomerSupportReactor
    private let reactor = CustomerSupportReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "CustomerSupport", table: "Settings")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 버그 신고하기
    private let bug = SettingCardCell(title: String(localized: "BugReport", table: "Settings"), type: .button)
    
    // 1:1 문의하기
    private let inquiries = SettingCardCell(title: String(localized: "Contact", table: "Settings"), type: .button)
    
    // 고객 지원 세팅 카드
    private lazy var cumtomerSupportSettingCard = SettingCard(cells: [bug, inquiries])
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, cumtomerSupportSettingCard].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        // 고객 지원 세팅 카드
        cumtomerSupportSettingCard.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(topNavigationBar.snp.bottom).offset(16)
        }
        
        [bug, inquiries].forEach {
            $0.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
            }
        }
    }
}

extension CustomerSupportView {
    private func bind(reactor: CustomerSupportReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: CustomerSupportReactor) {
        // 버그 신고하기 클릭
        bug.didTap
            .map { Reactor.Action.supportBugTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 1:1 문의하기 클릭
        inquiries.didTap
            .map { Reactor.Action.supportInquiriesTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: CustomerSupportReactor) {
        // 세팅 카드 버튼 클릭 시 화면 이동
        reactor.pulse(\.$shouldNavigate)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewType in
                guard let self = self else { return }
                
                let view: UIViewController
                
                switch viewType {
                case .bugReport:
                    view = BugReportView()
                    
                case .supportInquiries:
                    view = InquiriesView()
                }
                
                self.navigationController?.pushViewController(view, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
