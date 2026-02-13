//
//  AnnouncementView.swift
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

class AnnouncementView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.Announcement.View"
    )

    typealias Reactor = AnnouncementReactor
    private let reactor = AnnouncementReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "Announcement", table: "Settings")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 공지사항 테이블뷰
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(AnnouncementTableViewCell.self, forCellReuseIdentifier: AnnouncementTableViewCell.identifier)
        tv.backgroundColor = .clear
        tv.separatorStyle = .singleLine
        tv.separatorColor = .neutral100
        tv.estimatedRowHeight = 105
        tv.rowHeight = UITableView.automaticDimension
        tv.minimumZoomScale = 1.0
        tv.maximumZoomScale = 1.0
        tv.pinchGestureRecognizer?.isEnabled = false
        
        return tv
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
    
        [topNavigationBar, tableView].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        // 공지사항 테이블 뷰
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
    }
}

extension AnnouncementView {
    private func bind(reactor: AnnouncementReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: AnnouncementReactor) {
        reactor.action.onNext(.viewDidLoad)
    }
    
    private func bindState(reactor: AnnouncementReactor) {
        // 공지사항 데이터를 테이블뷰에 바인딩
        reactor.state.map { $0.notices }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(
                cellIdentifier: AnnouncementTableViewCell.identifier,
                cellType: AnnouncementTableViewCell.self
            )) { index, item, cell in
                cell.configure(item: item)
            }
            .disposed(by: disposeBag)
    }
}
