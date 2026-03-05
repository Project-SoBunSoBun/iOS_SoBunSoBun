//
//  ServiceTermView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/7/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import OSLog

class ServiceTermView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "ServiceTerm.View"
    )
    
    typealias Reactor = ServiceTermReactor
    private let reactor = ServiceTermReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "ServiceTerm", table: "Settings")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
}
