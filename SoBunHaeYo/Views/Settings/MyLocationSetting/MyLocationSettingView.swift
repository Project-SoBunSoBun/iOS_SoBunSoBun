//
//  MyLocationSettingView.swift
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

class MyLocationSettingView: BaseViewController {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.MyLocationSetting.View"
    )
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "MyLocationSetting", table: "Settings")
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
