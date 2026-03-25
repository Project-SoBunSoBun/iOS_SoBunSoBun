//
//  NotificationsView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/20/26.
//

import UIKit
import SnapKit
import RxSwift
import OSLog

class NotificationsView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Home.NotificationsView.View"
    )
    
    typealias Reactor = NotificationsReactor
    private let reactor = NotificationsReactor()
    
    private let disposeBag = DisposeBag()
    
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "Notifications", table: "Notifications")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 저장 목록 글 테이블 뷰
    private let tableView: BaseTableView = {
        let tv = BaseTableView()
        tv.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.identifier)
        tv.estimatedRowHeight = 105
        tv.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        
        return tv
    }()
    
    // 새로고침
    private let refreshControl: BlueMeatballsRefreshController = {
        let rc = BlueMeatballsRefreshController()
        
        return rc
    }()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reactor.action.onNext(.viewWillAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            reactor.action.onNext(.viewWillDisappear)
            NotificationCenter.default.post(name: .didPopNotificationsView, object: nil)
        }
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, tableView, loadingView].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        tableView.refreshControl = refreshControl
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension NotificationsView {
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        // 새로고침
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 페이지네이션
        tableView.rx.willDisplayCell
            .filter { [weak self] cell, indexPath -> Bool in
                guard let self = self else { return false }
                
                let totalCount = self.tableView.numberOfRows(inSection: 0)
                let triggerCount = 3
                
                return totalCount > triggerCount && indexPath.row >= totalCount - triggerCount
            }
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { _ in Reactor.Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 셀을 눌렀을 때
        tableView.rx.modelSelected(NotificationModel.self)
            .map { Reactor.Action.cellTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: Reactor) {
        // 테이블 뷰에 데이터 바인딩
        reactor.state.map { $0.notifications }
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(
                cellIdentifier: NotificationTableViewCell.identifier,
                cellType: NotificationTableViewCell.self
            )) { _, model, cell in
                let message: String
                
                switch model.type {
                case .COMMENT:
                    message = String(format: String(localized: "COMMENT", table: "Notifications"), model.nickname ?? String(localized: "Unknown", table: "Common"))
                    
                case .COMMENT_MENTIONED:
                    message = String(format: String(localized: "COMMENT_MENTIONED", table: "Notifications"), model.nickname ?? String(localized: "Unknown", table: "Common"))
                    
                case .PARTICIPATION:
                    message = String(format: String(localized: "PARTICIPATION", table: "Notifications"), model.nickname ?? String(localized: "Unknown", table: "Common"))
                    
                case .POST_UPDATE:
                    message = String(localized: "POST_UPDATE", table: "Notifications")
                    
                case .SETTLEMENT:
                    message = String(localized: "SETTLEMENT", table: "Notifications")
                    
                case .unknown:
                    message = String(localized: "UNKNOWN", table: "Notifications")
                }
                
                cell.configureUI(message: message, createdAt: model.createdAt, isRead: model.isRead)
            }
            .disposed(by: disposeBag)
        
        // 셀을 눌렀을 때 화면 이동
        reactor.pulse(\.$shouldPushView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                switch model.type {
                case .COMMENT, .COMMENT_MENTIONED, .POST_UPDATE:
                    guard let postId = model.postId else {
                        self.logger.fault("\(model.type.rawValue)의 postId가 없음")
                        
                        return
                    }
                    
                    self.navigationController?.pushViewController(PostDetailView(postId: postId), animated: true)
                    
                case .PARTICIPATION:
                    guard let chatRoomId = model.chatRoomId else {
                        self.logger.fault("PARTICIPATION의 chatRoomId가 없음")
                        
                        return
                    }
                    
                    self.navigationController?.pushViewController(ChatView(chatRoomId: chatRoomId), animated: true)
                    
                case .SETTLEMENT:
                    guard let settlementId = model.settlementId else {
                        self.logger.fault("SETTLEMENT의 settlementId가 없음")
                        
                        return
                    }
                    
                    self.navigationController?.pushViewController(SettlementConfirmView(settlementId: settlementId), animated: true)
                    
                case .unknown:
                    self.logger.fault("UNKNOWN 타입으로, push view 불가")
                }
            })
            .disposed(by: disposeBag)
        
        // 새로고침
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        // 에러 알러트
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.errorAlert(subTitle: message)
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태
        reactor.state.map { !$0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    // 에러 알러트
    private func errorAlert(subTitle: String) {
        let alert = CustomAlertView(
            title: String(localized: "Error", table: "Common"),
            subTitle: subTitle,
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = { [weak self] in
            guard let self = self else { return }
            
            self.logger.debug("확인 버튼 클릭")
        }
        
        alert.show(on: self)
    }
}
