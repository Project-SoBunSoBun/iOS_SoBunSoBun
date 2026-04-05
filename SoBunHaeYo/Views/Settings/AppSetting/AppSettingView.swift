//
//  AppSettingView.swift
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

class AppSettingView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.AppSetting.View"
    )
    
    typealias Reactor = AppSettingReactor
    private let reactor = AppSettingReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "AppSetting", table: "Settings")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 라벨 만드는 함수
    private func makeLabel(string: String) -> UILabel {
        var attributes = title16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributedText = NSAttributedString(
            string: string,
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        
        return lb
    }
    
    // 알림 설정 라벨
    private lazy var notificationSettingLabel = makeLabel(string: String(localized: "NotificationSetting", table: "Settings"))
    
    // 알림 수신 설정
    private let notificationSetting = SettingCardCell(title: String(localized: "NotificationReceiveSetting", table: "Settings"), type: .button)
    
    // 알림 수신 설정 세팅 카드
    private lazy var notificationSettingCard = SettingCard(cells: [notificationSetting])
    
    // 사용자 설정 라벨
    private lazy var personalSettingLabel = makeLabel(string: String(localized: "PersonalSetting", table: "Settings"))
    
    // 계정 정보 관리
    private let managingAccountInfo = SettingCardCell(title: String(localized: "ManagingAccountInfo", table: "Settings"), type: .button)
    
    // 차단 관리
    private let blockManagement = SettingCardCell(title: String(localized: "BlockManagement", table: "Settings"), type: .button)
    
    // 사용자 설정 세팅 카드
    private lazy var managingAccountInfoSettingCard = SettingCard(cells: [managingAccountInfo, blockManagement])
    
    // 기타 라벨
    private lazy var etcLabel = makeLabel(string: String(localized: "Etc", table: "Settings"))
    
    // 공지 사항
    private let announcement = SettingCardCell(title: String(localized: "Announcement", table: "Settings"), type: .button)
    
    // 고객 지원
    private let customerSupport = SettingCardCell(title: String(localized: "CustomerSupport", table: "Settings"), type: .button)
    
    // 약관 및 정책
    private let terms = SettingCardCell(title: String(localized: "Terms", table: "Settings"), type: .button)
    
    // 현재 버전
    private let currentVersion = SettingCardCell(title: String(localized: "CurrentVersion", table: "Settings"), subTitle: AppVersion.current, type: .text)
    
    // 기타 세팅 카드
    private lazy var etcSettingCard = SettingCard(cells: [announcement, customerSupport, terms, currentVersion])
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, notificationSettingLabel, notificationSettingCard, personalSettingLabel, managingAccountInfoSettingCard, etcLabel, etcSettingCard].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        // 알림 설정 라벨
        notificationSettingLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(topNavigationBar.snp.bottom).offset(16)
        }
        
        // 알림 설정 세팅 카드
        notificationSettingCard.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(notificationSettingLabel.snp.bottom).offset(16)
        }
        
        notificationSetting.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
        }
        
        // 사용자 설정
        personalSettingLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(notificationSettingCard.snp.bottom).offset(24)
        }
        
        // 계정 정보 관리
        managingAccountInfoSettingCard.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(personalSettingLabel.snp.bottom).offset(16)
        }
        
        [managingAccountInfo, blockManagement].forEach {
            $0.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
            }
        }
        
        // 기타 라벨
        etcLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(managingAccountInfoSettingCard.snp.bottom).offset(24)
        }
        
        // 기타 세팅 카드
        etcSettingCard.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(etcLabel.snp.bottom).offset(16)
        }
        
        [announcement, customerSupport, terms, currentVersion].forEach {
            $0.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
            }
        }
    }
}

extension AppSettingView {
    // reactor와 view 연결
    private func bind(reactor:AppSettingReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        // 알림 수신 설정 클릭
        notificationSetting.didTap
            .map { Reactor.Action.notificationSettingTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 계정 정보 관리 클릭
        managingAccountInfo.didTap
            .map { Reactor.Action.managingAccountInfoTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 차단 관리 클릭
        blockManagement.didTap
            .map { Reactor.Action.blockManagementTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 공지 사항 클릭
        announcement.didTap
            .map { Reactor.Action.announcementTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 고객 지원 클릭
        customerSupport.didTap
            .map { Reactor.Action.customerSupportTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 약관 및 정책 클릭
        terms.didTap
            .map { Reactor.Action.termsTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: Reactor) {
        // 세팅 카드 클릭 시 화면 이동
        reactor.pulse(\.$shouldNavigate)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewType in
                guard let self = self else { return }
                
                let view: UIViewController
                
                switch viewType {
                    
                case .notificationSetting:
                    view = NotificationSettingView()
                    
                case .managingAccountInfo:
                    view = ManagingAccountInfoView()
                    
                case .blockManagement:
                    view = BlockManagementView()
                    
                case .announcement:
                    view = AnnouncementView()
                    
                case .customerSupport:
                    view = CustomerSupportView()
                    
                case .terms:
                    view = TermsView()
                }
                
                self.navigationController?.pushViewController(view, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
