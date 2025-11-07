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

class LoginView: CustomViewController {
    typealias Reactor = LoginReactor
    private let reactor = LoginReactor()
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 앱 로고
    private let appLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .logo
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    // 앱 로고 Text - 소분소분
    private let appLogoText: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .sobunSobunText
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    // 애플로 시작하기를 담고 있는 뷰
    private let appleButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .appleBlack
        view.layer.cornerRadius = 12
        
        return view
    }()
    
    // 애플 로고
    private let appleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .apple
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    // 애플 버튼 안 텍스트
    private let appleText: UILabel = {
        let label = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "LoginApple"), // 다국어 지원 구문
            attributes: title16.attributes()
        )
        label.attributedText = attributedText
        label.textColor = .appleWhite
        
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
        view.backgroundColor = .kakaoYellow
        view.layer.cornerRadius = 12
        
        return view
    }()
    
    // 카카오 로고
    private let kakaoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .kakao
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    // 카카오 버튼 안 텍스트
    private let kakaoText: UILabel = {
        let label = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "LoginKakao"), // 다국어 지원 구문
            attributes: title16.attributes()
        )
        label.attributedText = attributedText
        label.textColor = .kakaoLabelBlack
        
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
    
    // 그라데이션 뷰
    private let gradientLayer: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor.primary100.withAlphaComponent(0).cgColor,
            UIColor.primary100.withAlphaComponent(1).cgColor
        ]
        gl.locations = [0,1]
        gl.startPoint = CGPoint(x: 0.5, y: 0.0)
        gl.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        return gl
    }()
    
    // MARK: - 생명주기
    // 네비게이션 바를 숨기기 위한 viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = CGRect(
            x: 0,
            y: 312,
            width: view.bounds.width,
            height: view.bounds.height - 312
        )
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        // 그라데이션 추가
        view.layer.addSublayer(gradientLayer)
        
        [appLogoImage, appLogoText, appleButtonView, kakaoButtonView].forEach {
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
        
        appLogoText.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(appLogoImage.snp.bottom).offset(24)
            make.height.equalTo(44)
            make.width.equalTo(129)
        }
        
        appleButtonView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(appLogoText.snp.bottom).offset(80)
            make.height.equalTo(52)
        }
        
        appleImage.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        appleButtonInnerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        kakaoButtonView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
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
        reactor.pulse(\.$loginCompleted)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] isNewUser in
                guard let self = self else { return }
                
                if isNewUser {
                    let vc = SignUpView()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = NavigationTabView()
                    self.navigationController?.setViewControllers([vc], animated: false)
                }
            })
            .disposed(by: disposeBag)
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
