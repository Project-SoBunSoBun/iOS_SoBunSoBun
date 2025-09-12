//
//  LoginView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/4/25.
//

import UIKit
import KakaoSDKAuth
import ReactorKit
import SnapKit
import RxSwift
import RxGesture

class LoginView: UIViewController {
    typealias Reactor = LoginReactor
    private let reactor = LoginReactor()
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 앱 로고
    private let appLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .logo
        
        return imageView
    }()
    
    // 애플로 시작하기를 담고 있는 뷰
    private let appleButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    // 애플 로고
    private let appleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .apple
        imageView.tintColor = .white
        
        return imageView
    }()
    
    // 애플 버튼 안 텍스트
    private let appleText: UILabel = {
        let label = UILabel()
        label.text = String(localized: "LoginApple")
        label.textColor = .white
        
        return label
    }()
    
    // 애플 로고와 텍스트를 담을 뷰
    private let appleButtonInnerView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .center
        
        return view
    }()
    
    // 카카오로 시작하기를 담고 있는 뷰
    private let kakaoButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    // 카카오 로고
    private let kakaoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .kakao
        
        return imageView
    }()
    
    // 카카오 버튼 안 텍스트
    private let kakaoText: UILabel = {
        let label = UILabel()
        label.text = String(localized: "LoginKakao")
        label.textColor = .black
        
        return label
    }()
    
    // 카카오 로고와 텍스트를 담을 뷰
    private let kakaoButtonInnerView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .center
        
        return view
    }()
    
    // MARK: - 생명주기
    // 네비게이션 바를 숨기기 위한 viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        
        // TODO: 배경 색상 - 디자인 시스템 나오면 변경 필요
        view.backgroundColor = .white
        
        [appLogoImage, appleButtonView, kakaoButtonView].forEach {
            view.addSubview($0)
        }
        
        appleButtonView.addSubview(appleButtonInnerView)
        kakaoButtonView.addSubview(kakaoButtonInnerView)
        
        [kakaoImage, kakaoText].forEach {
            kakaoButtonInnerView.addArrangedSubview($0)
        }
        
        [appleImage, appleText].forEach {
            appleButtonInnerView.addArrangedSubview($0)
        }
        
        appLogoImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(215)
            make.size.equalTo(120)
        }
        
        appleButtonView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
            make.top.equalTo(appLogoImage.snp.bottom).offset(150)
            make.height.equalTo(52)
        }
        
        appleImage.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        appleButtonInnerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        kakaoButtonView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
            make.top.equalTo(appleButtonView.snp.bottom).offset(8)
            make.height.equalTo(52)
        }
        
        kakaoImage.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        kakaoButtonInnerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

// Reactor 연결
extension LoginView {
    // reactor와 view 연결
    func bind(reactor: LoginReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    func bindAction(reactor: LoginReactor) {
        // Apple로 시작하기 버튼 클릭 제스처
        appleButtonView.rx.tapGesture()
            .map { _ in Reactor.Action.appleButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        
        // 카카오로 시작하기 버튼 클릭 제스처
        kakaoButtonView.rx.tapGesture()
            .map{ _ in Reactor.Action.kakaoButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(reactor: LoginReactor) {
        
    }
}

// 미리보기
#if DEBUG
import SwiftUI

struct LoginViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            LoginView()
        }
    }
}
#endif
