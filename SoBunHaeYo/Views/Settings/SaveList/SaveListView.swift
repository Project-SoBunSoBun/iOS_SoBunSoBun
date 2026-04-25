//
//  SaveListView.swift
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

class SaveListView: BaseViewController {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.SaveList.View"
    )
    
    typealias Reactor = SaveListRecator
    private let reactor = SaveListRecator()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "SaveList", table: "Settings")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 저장 목록 글 테이블 뷰
    private let tableView: BaseTableView = {
        let tv = BaseTableView()
        tv.register(UserPagePostListTableViewCell.self,
                    forCellReuseIdentifier: UserPagePostListTableViewCell.identifier)
        tv.backgroundColor = .clear
        tv.estimatedRowHeight = 134
        
        return tv
    }()
    
    private let emptyStateLabel: UILabel = {
        var attributes = body16.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.neutral500
        
        let label = UILabel()
        label.attributedText = NSAttributedString(
            string: String(localized: "SaveListEmpty", table: "Settings"),
            attributes: attributes
        )
        label.numberOfLines = 0
        label.isHidden = true
        
        return label
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

    // MARK: - 레이아웃 설정
    private func configureUI() {
        [topNavigationBar, tableView, emptyStateLabel, loadingView].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(topNavigationBar.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.horizontalEdges.equalToSuperview().inset(32)
        }
        
        tableView.refreshControl = refreshControl
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SaveListView {
    // reactor와 view 연결
    private func bind(reactor: SaveListRecator) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: SaveListRecator) {
        reactor.action.onNext(.viewDidLoad)
        
        // 새로고침
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 페이지 네이션
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
        tableView.rx.modelSelected(PostModel.self)
            .map { Reactor.Action.cellTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: SaveListRecator) {
        // 테이블 뷰에 데이터 바인딩
        reactor.state.map { $0.savedPosts }
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(
                cellIdentifier: UserPagePostListTableViewCell.identifier,
                cellType: UserPagePostListTableViewCell.self
            )) { _, model, cell in
                cell.configureUI(model: model, bottomEdgeInset: 24)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.savedPosts.isEmpty }
            .distinctUntilChanged()
            .map { !$0 }
            .observe(on: MainScheduler.instance)
            .bind(to: emptyStateLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 셀을 눌렀을 때 화면 이동
        reactor.pulse(\.$shouldPushSavedPostDetailView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(PostDetailView(postId: model.id), animated: true)
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
                
                self.showErrorAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태
        reactor.state.map { !$0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
