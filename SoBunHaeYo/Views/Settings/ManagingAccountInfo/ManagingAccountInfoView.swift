//
//  ManagingAccountInfoView.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 1/28/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import OSLog

class ManagingAccountInfoView: BaseViewController {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.ManagingAccountInfo.View"
    )
    
    typealias Reactor = ManagingAccountInfoReactor
    private let reactor = ManagingAccountInfoReactor()
    
    private let disposeBag = DisposeBag()
    private var userEmail: String = ""

    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "ManagingAccountInfo", table: "Settings")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 이메일
    private lazy var email = SettingCardCell(title: String(localized: "Email", table: "Settings"), subTitle: userEmail, type: .text)
    
    // 로그아웃
    private let logOut = SettingCardCell(title: String(localized: "LogOut", table: "Settings"), type: .button)
    
    // 회원탈퇴
    private let deleteAccount = SettingCardCell(title: String(localized: "DeleteAccount", table: "Settings"), type: .button)
    
    // 계정 정보 관리 세팅 카드
    private lazy var ManagingAccountInfoSettingCard = SettingCard(cells: [email, logOut, deleteAccount])
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }

    // MARK: - 레이아웃 설정
    private func configureUI() {
        let getUserEmail = KeyChain.shared.get(key: "EMAIL") ?? String(localized: "FailToGetEmail", table: "Settings")
        
        self.userEmail = getUserEmail
    
        [topNavigationBar, ManagingAccountInfoSettingCard].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        // 계정 정보 관리 세팅 카드
        ManagingAccountInfoSettingCard.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(topNavigationBar.snp.bottom).offset(16)
        }
        
        [email, logOut, deleteAccount].forEach {
            $0.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
            }
        }
    }
}

extension ManagingAccountInfoView {
    // reactor와 view 연결
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        // 로그아웃 클릭
        logOut.didTap
            .map { Reactor.Action.logOutTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 회원 탈퇴 클릭
        deleteAccount.didTap
            .map { Reactor.Action.deleteAccountTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: Reactor) {
        // 세팅 카드 버튼 클릭 시 화면 이동
        reactor.pulse(\.$shouldNavigate)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewType in
                guard let self = self else { return }

                switch viewType {
                case .logOut:
                    self.showLogOutAlert()
                    
                case .deleteAccount:
                    let view = WithdrawView()
                    
                    self.navigationController?.pushViewController(view, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func showLogOutAlert() {
        let alert = CustomAlertView(
            title: String(localized: "LogOutMessage", table: "Settings"),
            subTitle: String(localized: "LogOutSubMessage", table: "Settings"),
            primaryTitleKey: String(localized: "LogOut", table: "Settings"),
            cancelTitleKey: String(localized: "Cancel", table: "Common")
        )
        
        alert.primaryTap.emit(onNext: {
            AuthManager.shared.logout()
        })
        .disposed(by: alert.disposeBag)
        
        alert.show(on: self)
    }
}
