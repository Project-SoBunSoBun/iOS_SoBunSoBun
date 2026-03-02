//
//  MyPostView.swift
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

class MyPostView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.MyPost.View"
    )
    
    typealias Reactor = MyPostReactor
    private let reactor = MyPostReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "MyPost", table: "Settings")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 내가 게시한 글 테이블 뷰
    private let tableView: BaseTableView = {
        let tv = BaseTableView()
        tv.register(UserPagePostListDeletableTableViewCell.self,
                    forCellReuseIdentifier: UserPagePostListDeletableTableViewCell.identifier)
        tv.backgroundColor = .clear
        tv.estimatedRowHeight = 134
        
        return tv
    }()
    
    private let refreshControl: BlueMeatballsRefreshController = {
        let rc = BlueMeatballsRefreshController()
        
        return rc
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

    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
    
        [topNavigationBar, tableView].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        // 내가 게시한 글 테이블 뷰
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(topNavigationBar.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
        
        tableView.refreshControl = refreshControl
    }
}

extension MyPostView {
    private func bind(reactor: MyPostReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: MyPostReactor) {
        // 메뉴 버튼 클릭
        tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] cell, indexPath in
                guard let self = self,
                let deletableCell = cell as? UserPagePostListDeletableTableViewCell else { return }
                
                deletableCell.didTapMenu
                    .map { _ in
                        let post = reactor.currentState.myPosts[indexPath.row]
                        self.logger.debug("선택된 post id: \(post.id)")
                        
                        return Reactor.Action.menuButtonTapped(post.id)
                    }
                    .bind(to: reactor.action)
                    .disposed(by: deletableCell.disposeBag)
            })
            .disposed(by: disposeBag)
        
        // 새로고침
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 셀을 눌렀을 때
        tableView.rx.modelSelected(PostModel.self)
            .map { Reactor.Action.cellTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 페이지네이션
        tableView.rx.willDisplayCell
            .filter { [weak self] cell, IndexPath -> Bool in
                guard let self = self else { return false }
                
                let totalCount = self.tableView.numberOfRows(inSection: 0)
                let triggerCount = 3
                
                return totalCount > triggerCount && IndexPath.row >= totalCount - triggerCount
            }
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { _ in Reactor.Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: MyPostReactor) {
        // 공지사항 데이터를 테이블 뷰에 바인딩
        reactor.state.map { $0.myPosts }
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(
                cellIdentifier: UserPagePostListDeletableTableViewCell.identifier,
                cellType: UserPagePostListDeletableTableViewCell.self
            )) { index, model, cell in
                cell.configureUI(model: model)
            }
            .disposed(by: disposeBag)
        
        // 셀을 눌렀을 때 화면 이동
        reactor.pulse(\.$shouldPushMyPostDetailView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(
                    PostDetailView(postId: model.id),
                    animated: true)
            })
            .disposed(by: disposeBag)
        
        // 새로고침
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
    }
}
