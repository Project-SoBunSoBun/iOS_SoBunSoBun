//
//  NotificationSettingView.swift
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

class NotificationSettingView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.NotificationSetting.View"
    )
    
    typealias Reactor = NotificationSettingReactor
    private let reactor = NotificationSettingReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "NotificationReceiveSetting", table: "Settings")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 소분소분에서 보내는 소식
    private lazy var notificationSetting = SettingCardCell(title: String(localized: "NewsFromSobunSobun", table: "Settings"), type: .button)
    
    // 업데이트, 댓글, 채팅 알림 라벨
    private let subTitleLabel: UILabel = {
        var attributes = body14.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral400
        
        let attributedText = NSAttributedString(
            string: String(localized: "News", table: "Settings"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        
        return lb
    }()
    
    // 알림 수신 설정 세팅 카드
    private lazy var notificationSettingCard = SettingCard(cells: [notificationSetting, subTitleLabel])
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, notificationSettingCard].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        notificationSettingCard.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(topNavigationBar.snp.bottom).offset(16)
        }
        
        [notificationSetting, subTitleLabel].forEach {
            $0.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
            }
        }
        
        notificationSettingCard.setSpacing(spacing: 8)
    }
}

extension NotificationSettingView {
    private func bind(reactor: NotificationSettingReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: NotificationSettingReactor) {
        // 세팅 카드 버튼 클릭
        notificationSetting.didTap
            .map { Reactor.Action.notificationSettingTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: NotificationSettingReactor) {
        // 알림 설정창 이동
        reactor.pulse(\.$shouldOpenSettings)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.showNotificationSettingAlert()
            })
            .disposed(by: disposeBag)
    }
    
    // 알림 권한 설정 알림창
    private func showNotificationSettingAlert() {
        let alert = CustomAlertView(
            title: String(localized: "MoveToSetting", table: "Settings"),
            subTitle: String(localized: "MoveToSettingDesc", table: "Settings"),
            primaryTitleKey: String(localized: "Move", table: "Common"),
            cancelTitleKey: String(localized: "Cancel", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            // 설정 앱으로 이동
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        alert.onCancelTapped = {
            self.logger.debug("취소됨")
        }
        
        alert.show(on: self)
    }
}
