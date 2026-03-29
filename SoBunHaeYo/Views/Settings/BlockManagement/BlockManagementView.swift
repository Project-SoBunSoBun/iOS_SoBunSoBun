//
//  BlockManagementView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/28/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import OSLog

class BlockManagementView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.BlockManagement.View"
    )
    
    typealias Reactor = BlockManagementReactor
    private let reactor = BlockManagementReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "BlockManagement", table: "Settings")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        
        return sv
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        view.addSubview(topNavigationBar)
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.verticalEdges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    private func updateBlockListCells(blockList: [BlockListResponseDataModel]) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        blockList.forEach { model in
            let cellView = UserActionCellView(
                userId: model.userId,
                nickname: model.nickname,
                profileImageUrl: model.profileImageUrl,
                actionTitle: String(localized: "Unblock", table: "Settings")
            )
            
            cellView.actionButton.rx.tap
                .map { Reactor.Action.unblockButtonTapped(userId: model.userId) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            stackView.addArrangedSubview(cellView)
        }
    }
}

extension BlockManagementView {
    private func bind(reactor: BlockManagementReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: BlockManagementReactor) {
        reactor.action.onNext(.viewDidLoad)
    }
    
    private func bindState(reactor: BlockManagementReactor) {
        // 차단 목록
        reactor.state.map { $0.blockList }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] blockList in
                guard let self else { return }
                
                updateBlockListCells(blockList: blockList)
            })
            .disposed(by: disposeBag)
        
        // 차단 해제 확인 알림
        reactor.pulse(\.$shouldShowUnblockAlert)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "UnblockAlertTitle", table: "Settings"),
                    subTitle: String(localized: "UnblockAlertSubTitle", table: "Settings"),
                    primaryTitleKey: String(localized: "UnblockAlertConfirm", table: "Settings"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alert.onPrimaryTapped = {
                    reactor.action.onNext(.unblockConfirmed)
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        // 오류 메시지
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "Error", table: "Error"),
                    subTitle: message,
                    primaryTitleKey: String(localized: "Confirm", table: "Common")
                )
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
    }
}
