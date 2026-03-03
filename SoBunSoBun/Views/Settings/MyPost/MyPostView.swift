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
    private var selectedPostId: Int?
    private var selectedIndexPathRow: Int?
    
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
    
    // 새로고침
    private let refreshControl: BlueMeatballsRefreshController = {
        let rc = BlueMeatballsRefreshController()
        
        return rc
    }()
    
    // 삭제하기 메뉴 dropdown
    private let dropDownView: DropDownView = {
        let ddv = DropDownView(
            selectionMode: .plain, tableName: "Common")
        ddv.textAlignment = .center
        ddv.items = ["Delete"]
        ddv.animationAnchor = .topRight
        
        return ddv
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
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, tableView, dropDownView, loadingView].forEach {
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
        
        // 드롭다운뷰
        dropDownView.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.top.equalTo(view.snp.top)
            make.trailing.equalTo(view.snp.trailing)
        }
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension MyPostView {
    private func bind(reactor: MyPostReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: MyPostReactor) {
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
        
        // 메뉴 버튼 클릭
        tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] cell, indexPath in
                guard let self = self,
                      let deletableCell = cell as? UserPagePostListDeletableTableViewCell else { return }
                
                deletableCell.disposeBag = DisposeBag()
                
                deletableCell.didTapMenu
                    .subscribe(onNext: { [weak self] _ in
                        guard let self = self else { return }
                        
                        let posts = self.reactor.currentState.myPosts
                        guard posts.indices.contains(indexPath.row) else { return }
                        
                        let post = posts[indexPath.row]
                        self.selectedPostId = post.id
                        self.selectedIndexPathRow = indexPath.row
                        
                        // 드롭다운 위치 계산 및 표시
                        let dotIconFrame = deletableCell.dotIconFrameInWindow()
                        self.showDropDown(frame: dotIconFrame)
                        
                        self.reactor.action.onNext(.menuButtonTapped(!self.reactor.currentState.isMenuOpen))
                    })
                    .disposed(by: deletableCell.disposeBag)
            })
            .disposed(by: disposeBag)
        
        // 드롭다운 삭제하기 클릭
        dropDownView.didCellTap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                reactor.action.onNext(.menuButtonTapped(false))
                
                self.deletePostAlert()
            })
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
        
        // 삭제하기 드롭다운 개폐
        reactor.state.map { $0.isMenuOpen }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext:  { [weak self] isOpen in
                guard let self = self else { return }
                
                dropDownView.setOpen(isOpen: isOpen)
            })
            .disposed(by: disposeBag)
        
        // 삭제 완료 알러트
        reactor.pulse(\.$shouldShowDeletePostDoneAlert)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.deletePostDoneAlert()
            })
            .disposed(by: disposeBag)
        
        // 에러 알러트
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.errorAlert()
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태
        reactor.state.map { !$0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func showDropDown(frame: CGRect) {
        let topOffset: CGFloat = 4
        let trailingInset: CGFloat = 24
        
        dropDownView.snp.updateConstraints { make in
            make.top.equalTo(view.snp.top).offset(frame.maxY + topOffset)
            make.trailing.equalTo(view.snp.trailing).inset(trailingInset)
        }
        
        dropDownView.setOpen(isOpen: true)
    }
    
    private func deletePostAlert() {
        let alert = CustomAlertView(
            title: String(localized: "DeleteAlertTitle", table: "Settings"),
            subTitle: String(localized: "DeleteAlertSubtitle", table: "Settings"),
            primaryTitleKey: String(localized: "Delete", table: "Common"),
            cancelTitleKey: String(localized: "Cancel", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            guard let selectedId = self.selectedPostId else { return }
            
            self.reactor.action.onNext(.deletePostId(selectedId))
        }
        
        alert.show(on: self)
    }
    
    private func deletePostDoneAlert() {
        let alert = CustomAlertView (
            title: String(localized: "DeleteCompleted", table: "Common"),
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            self.logger.debug("확인 버튼 클릭")
        }
        
        alert.show(on: self)
    }
    
    private func errorAlert() {
        let alert = CustomAlertView(
            title: String(localized: "ErrorMessage", table: "Common"),
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            self.logger.debug("확인 버튼 클릭")
        }
        
        alert.show(on: self)
    }
}
