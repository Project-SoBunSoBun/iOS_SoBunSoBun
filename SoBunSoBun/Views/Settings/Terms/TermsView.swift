//
//  TermsView.swift
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

class TermsView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Mypage.Terms.View"
    )
    
    typealias Reactor = TermsReactor
    private let reactor = TermsReactor()
    
    private let disposeBag = DisposeBag()

    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "Terms", table: "Settings")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 서비스 이용 약관
    private let serviceTerm = SettingCardCell(title: String(localized: "ServiceTerm", table: "Settings"), type: .button)
    
    // 개인정보처리방침
    private let privacyPolicy = SettingCardCell(title: String(localized: "PrivacyPolicy", table: "Settings"), type: .button)
    
    // 약관 및 정책 세팅 카드
    private lazy var termsSettingCard = SettingCard(cells: [serviceTerm, privacyPolicy])
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }

    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
    
        [topNavigationBar, termsSettingCard].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        // 약관 및 정책 세팅 카드
        termsSettingCard.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(topNavigationBar.snp.bottom).offset(16)
        }
        
        [serviceTerm, privacyPolicy].forEach {
            $0.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
            }
        }
    }
}

extension TermsView {
    private func bind(reactor: TermsReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: TermsReactor) {
        // 서비스 이용 약관 클릭
        serviceTerm.didTap
            .map { Reactor.Action.serviceTermTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 개인정보처리방침 클릭
        privacyPolicy.didTap
            .map { Reactor.Action.privacyPolicyTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: TermsReactor) {
        // 세팅 카드 버튼 클릭 시 화면 이동
        reactor.pulse(\.$shouldNavigate)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewType in
                guard let self = self else { return }
                
                let view: UIViewController
                
                switch viewType {
                    
                case .serviceTerm:
                    view = ServiceTermView()
                    
                case .privacyPolicy:
                    view = PrivacyTermView()
                }
                
                self.navigationController?.pushViewController(view, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
