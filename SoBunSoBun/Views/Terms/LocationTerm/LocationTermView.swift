//
//  LocationTermView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 10/23/25.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import WebKit

class LocationTermView: UIViewController {
    typealias Reactor = LocationTermReactor
    private let reactor = LocationTermReactor()
    
    private let disposeBag = DisposeBag()
    
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        tnb.title = String(localized: "LocationBasedService", table: "Settings")
        
        return tnb
    }()

    // 웹 뷰
    private let webView: WKWebView = {
        let wv = WKWebView()
        wv.backgroundColor = .backgroundWhite
        wv.scrollView.showsVerticalScrollIndicator = false
        
        return wv
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
        
        [topNavigationBar, webView].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        webView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(topNavigationBar.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
    }
}

extension LocationTermView {
    // reactor와 view 연결
    private func bind(reactor: LocationTermReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: LocationTermReactor) {
        reactor.action.onNext(.viewDidLoad)
    }
    
    private func bindState(reactor: LocationTermReactor) {
        // HTML 콘텐츠 바인딩
        reactor.state.map { $0.content }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] content in
                guard let self = self else { return }
                
                self.webView.loadHTMLString(content, baseURL: nil)
            })
            .disposed(by: disposeBag)
        
        // 에러 알림
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.errorAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    private func errorAlert(message: String) {
        let alert = CustomAlertView(
            title: message,
            subTitle: String(localized: "ErrorMessage", table: "Common"),
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.show(on: self)
    }
}
