//
//  NavigationTabView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 10/15/25.
//

import UIKit
import SnapKit
import SwiftUI
import RxSwift
import RxCocoa
import ReactorKit

class NavigationTabView: BaseViewController {
    typealias Reactor = NavigationTabReactor
    private let reactor = NavigationTabReactor()
    private let disposeBag = DisposeBag()
    
    private let homeView = HomeView()
    private let chatRoomListView = ChatRoomListView()
    private let settleUpView = SettleUpView()
    private let myPageView = MypageView()
    
    private lazy var viewControllers: [UIViewController] = [homeView, chatRoomListView, settleUpView, myPageView]
    
    private let buttons: [TabBarButton] = [
        TabBarButton(icons: [.greyFilledHome, .blueFilledHome], title: String(localized: "Home", table: "Common")),
        TabBarButton(icons: [.greyFilledMessage, .blueFilledMessage], title: String(localized: "Chat", table: "Common")),
        TabBarButton(icons: [.greyFilledReceipt, .blueFilledReceipt], title: String(localized: "SettleUp", table: "Common")),
        TabBarButton(icons: [.greyFilledUser, .blueFilledUser], title: String(localized: "Mypage", table: "Common"))
    ]
    
    private var currentVC: UIViewController? = nil
    
    // MARK: - 디자인 요소
    private lazy var bottomNavigationBar = BottomNavigationBar(buttons: buttons)
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers.forEach { vc in
            addChild(vc)
            vc.didMove(toParent: self)
        }
        
        configureUI()
        bind(reactor: reactor)
        
        showViewController(index: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reactor.action.onNext(.getUnreadNotificationCount)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalToSuperview()
        }
        
        view.addSubview(bottomNavigationBar)
        
        bottomNavigationBar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(8)
        }
    }
    
    func showViewController(index: Int) {
        let newVC = viewControllers[index]
        
        guard currentVC != newVC else { return }
        
        currentVC?.view.removeFromSuperview()
        currentVC?.beginAppearanceTransition(false, animated: false)
        currentVC?.endAppearanceTransition()
        
        containerView.addSubview(newVC.view)
        
        newVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        newVC.beginAppearanceTransition(true, animated: false)
        newVC.endAppearanceTransition()
        
        currentVC = newVC
    }
}

extension NavigationTabView {
    // reactor와 view 연결
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        
        // homeView 위치 권한 알림창
        homeView.shouldShowLocationSettingAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.showLocationSettingAlert()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindAction(reactor: Reactor) {
        reactor.action.onNext(.viewDidLoad)
        
        bottomNavigationBar.didChangeIndex
            .map { Reactor.Action.selectIndex($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.didPopNotificationsView)
            .map { _ in Reactor.Action.getUnreadNotificationCount }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: Reactor) {
        reactor.state.map { $0.selectedIndex }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                
                showViewController(index: index)
                
                // BottomNavigationBar 컴포넌트 상태 업데이트
                bottomNavigationBar.updateSelectedIndex(index: index)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.unreadNotificationCount }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: homeView.unreadNotificationCount)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.chatRoomList }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] models in
                guard let self = self else { return }
                
                let totalUnreadCount = models.reduce(0) { $0 + $1.unReadCount }
                
                let chatButton = bottomNavigationBar.buttons[1]
                chatButton.updateIcons(
                    totalUnreadCount > 0 ?
                    [.newGreyFilledMessage, .newBlueFilledMessage] :
                    [.greyFilledMessage, .blueFilledMessage]
                )
                
                chatRoomListView.receivedChatRoomList(models)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.showErrorAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    private func showLocationSettingAlert() {
        let alert = CustomAlert(
            title: String(localized: "Error", table: "Error"),
            subTitle: String(localized: "LocationSettingTitle", table: "Common"),
            primaryTitleKey: String(localized: "GoToSetting", table: "Common")
        )
        
        alert.primaryTap.emit(onNext: {
            // 설정 앱으로 이동
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        .disposed(by: alert.disposeBag)
        
        alert.show(on: self)
    }
    
    func changeTabViewIndex(index: Int) {
        reactor.action.onNext(.selectIndex(index))
    }
}

extension Notification.Name {
    static let didPopNotificationsView = Notification.Name("didPopNotificationsView")
    static let didReadAllNotifications = Notification.Name("didReadAllNotifications")
}
