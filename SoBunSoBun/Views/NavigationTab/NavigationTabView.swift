//
//  NavigationTabView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/15/25.
//

import UIKit
import SnapKit
import SwiftUI
import RxSwift
import RxCocoa
import ReactorKit

class NavigationTabView: UIViewController {
    typealias Reactor = NavigationTabReactor
    private let reactor = NavigationTabReactor()
    private let disposeBag = DisposeBag()
    
    private let homeView = HomeView()
    private let chatListView = ChatListView()
    private let settleUpView = SettleUpView()
    private let myPageView = MypageView()
    
    private lazy var viewControllers: [UIViewController] = [homeView, chatListView, settleUpView, myPageView]
    
    private let buttons: [TabBarButton] = [
        TabBarButton(icons: [.greyFilledHome, .blueFilledHome], title: String(localized: "Home")),
        TabBarButton(icons: [.greyFilledMessage, .blueFilledMessage], title: String(localized: "Chat")),
        TabBarButton(icons: [.greyFilledReceipt, .blueFilledReceipt], title: String(localized: "SettleUp")),
        TabBarButton(icons: [.greyFilledUser, .blueFilledUser], title: String(localized: "Mypage"))
    ]
    
    private var currentVC: UIViewController? = nil
    
    // MARK: - 디자인 요소
    private lazy var navigationBar = NavigationBar(buttons: buttons)
    
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
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalToSuperview()
        }
        
        view.addSubview(navigationBar)
        
        navigationBar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(8)
        }
    }
    
    private func showViewController(index: Int) {
        let newVC = viewControllers[index]
        
        guard currentVC != newVC else { return }
        
        currentVC?.view.removeFromSuperview()
        
        containerView.addSubview(newVC.view)
        
        newVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        currentVC = newVC
    }
}

// Reactor 연결
extension NavigationTabView {
    private func bind(reactor: NavigationTabReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        
        // homeView 위치 권한 알림창
        homeView.shouldShowLocationSettingAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                showLocationSettingAlert(self)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindAction(reactor: NavigationTabReactor) {
        navigationBar.didChangeIndex
            .map { Reactor.Action.selectIndex($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: NavigationTabReactor) {
        reactor.state.map { $0.selectedIndex }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                
                showViewController(index: index)
                
                // NavigationBar 컴포넌트 상태 업데이트
                navigationBar.updateSelectedIndex(index: index)
            })
            .disposed(by: disposeBag)
    }
}

// 미리보기
#if DEBUG
import SwiftUI

struct NavigationTabViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            NavigationTabView()
        }
    }
}
#endif
