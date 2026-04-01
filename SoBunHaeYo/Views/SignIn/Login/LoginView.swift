//
//  LoginView.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 9/4/25.
//

import UIKit
import KakaoSDKAuth
import ReactorKit
import SnapKit
import RxSwift
import RxGesture
import OSLog

class LoginView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "SignIn.Login.View"
    )
    
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
    
    // 앱 로고 Text - 소분해요
    private let appLogoText: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .soBunHaeYoText
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
            string: String(localized: "LoginApple", table: "SignIn"),
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
            string: String(localized: "LoginKakao", table: "SignIn"),
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = CGRect(
            x: 0,
            y: view.bounds.height * 0.38, // 높이 기준 38%
            width: view.bounds.width,
            height: view.bounds.height * (1 - 0.38)
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
            make.horizontalEdges.equalToSuperview().inset(16)
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
            make.horizontalEdges.equalToSuperview().inset(16)
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
    private func bind(reactor: LoginReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: LoginReactor) {
        // Apple로 시작하기 버튼 클릭 제스처
        appleButtonView.rx.tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.appleButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 카카오로 시작하기 버튼 클릭 제스처
        kakaoButtonView.rx.tapGesture()
            .when(.recognized)
            .map{ _ in Reactor.Action.kakaoButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: LoginReactor) {
        reactor.pulse(\.$loginCompleted)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] isNewUser in
                guard let self = self else { return }
                
                if isNewUser {
                    let vc = SignUpView()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.reactor.action.onNext(.completeLoginAndNavigateToHome)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldNavigateToHome)
            .compactMap { $0 }
            .filter { $0 == true }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let vc = NavigationTabView()
                self.navigationController?.setViewControllers([vc], animated: false)
            })
            .disposed(by: disposeBag)
        
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
            title: String(localized: "Error", table: "Error"),
            subTitle: message,
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            self.logger.debug("확인 버튼 클릭")
        }
        
        alert.show(on: self)
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
