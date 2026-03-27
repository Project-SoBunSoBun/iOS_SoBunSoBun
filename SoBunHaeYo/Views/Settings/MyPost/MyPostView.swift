//
//  MyPostView.swift
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

class MyPostView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
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
    
    private let backgroundDimView: UIButton = {
        let bt = UIButton()
        bt.backgroundColor = .clear
        bt.isHidden = true
        
        return bt
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
        
        [topNavigationBar, tableView, backgroundDimView ,dropDownView, loadingView].forEach {
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
        
        // 투명 터치 버튼
        backgroundDimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 드롭다운뷰
        dropDownView.snp.makeConstraints { make in
            make.trailing.equalTo(view.snp.trailing)
            make.top.equalTo(view.snp.top)
            make.width.equalTo(70)
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
        
        // 드롭다운 삭제하기 클릭
        dropDownView.didCellTap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] menu in
                guard let self = self else { return }
                
                switch menu {
                case "Delete":
                    // 드롭다운 닫기
                    self.reactor.action.onNext(.closeMenu)
                    
                    // 삭제 확인 알러트
                    self.deletePostAlert()
                    
                default:
                    self.logger.fault("dropDownView의 didCellTap의 case에서 등록되지 않은 메뉴가 있음: \(menu)")
                }
            })
            .disposed(by: disposeBag)
        
        // 드롭다운이 켜져있을 때 다른 곳을 누르면 드롭다운 끄기
        backgroundDimView.rx.tap
            .map { Reactor.Action.closeMenu }
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
            )) { [weak self] index, model, cell in
                guard let self = self else { return }
                
                cell.configureUI(model: model)
                
                // 메뉴 버튼 클릭
                cell.didTap
                    .subscribe(onNext: { [weak self] button in
                        guard let self = self else { return }
                        
                        // 드롭다운 위치 계산 및 표시
                        let dotIconFrame = button.convert(button.bounds, to: view)
                        
                        self.updateDropDownPosition(frame: dotIconFrame)
                        
                        self.reactor.action.onNext(.openMenu(id: model.id))
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // 셀을 눌렀을 때 화면 이동
        reactor.pulse(\.$shouldPushMyPostDetailView)
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
        
        // 삭제하기 드롭다운 개폐
        reactor.state.map { $0.isMenuOpen }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext:  { [weak self] isOpen in
                guard let self = self else { return }
                
                self.dropDownView.setOpen(isOpen: isOpen)
                self.backgroundDimView.isHidden = !isOpen
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
    
    // 드롭다운뷰의 위치 업데이트
    private func updateDropDownPosition(frame: CGRect) {
        let topOffset: CGFloat = 4
        let trailingInset: CGFloat = 24 // 테이블 뷰의 셀에서 안쪽으로 8
        
        dropDownView.snp.remakeConstraints { make in
            make.trailing.equalTo(view.snp.trailing).inset(trailingInset)
            make.top.equalTo(view.snp.top).offset(frame.maxY + topOffset)
            make.width.equalTo(70)
        }
    }
    
    // 삭제 확인 알러트
    private func deletePostAlert() {
        let alert = CustomAlertView(
            title: String(localized: "DeleteAlertTitle", table: "Settings"),
            subTitle: String(localized: "DeleteAlertSubtitle", table: "Settings"),
            primaryTitleKey: String(localized: "Delete", table: "Common"),
            cancelTitleKey: String(localized: "Cancel", table: "Common")
        )
        
        alert.onPrimaryTapped = { [weak self] in
            guard let self = self,
                    let selectedId = self.reactor.currentState.selectedId else { return }
            
            self.reactor.action.onNext(.deletePostId(selectedId))
        }
        
        alert.show(on: self)
    }
    
    // 삭제 완료 알러트
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
    
    // 에러 알러트
    private func errorAlert() {
        let alert = CustomAlertView(
            title: String(localized: "Error", table: "Error"),
            subTitle: String(localized: "ErrorMessage", table: "Error"),
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            self.logger.debug("확인 버튼 클릭")
        }
        
        alert.show(on: self)
    }
}
