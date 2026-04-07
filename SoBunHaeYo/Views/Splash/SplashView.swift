//
//  SplashView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 4/5/26.
//

import UIKit
import ReactorKit
import SnapKit
import RxSwift

class SplashView: UIViewController {
    typealias Reactor = SplashReactor
    private let reactor = SplashReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 앱 로고
    private let appLogoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .appLogo
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reactor.action.onNext(.viewDidAppear)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        view.addSubview(appLogoImageView)
        
        appLogoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(120)
        }
    }
}

extension SplashView {
    // reactor와 view 연결
    private func bind(reactor: Reactor) {
        reactor.pulse(\.$destination)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] destination in
                guard let self = self else { return }
                
                self.navigate(to: destination)
            })
            .disposed(by: disposeBag)
    }
    
    // 화면 전환
    private func navigate(to destination: SplashReactor.Destination) {
        let vc: UIViewController
        
        switch destination {
        case .main:
            vc = NavigationTabView()
        case .login:
            vc = LoginView()
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        
        guard let window = view.window else { return }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = nav
        }
    }
}
