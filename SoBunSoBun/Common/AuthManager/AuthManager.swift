//
//  AuthManager.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/25/25.
//

import Foundation
import UIKit
import OSLog
import KakaoSDKUser
import RxSwift

class AuthManager {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "AuthManager"
    )
    
    static let shared = AuthManager()
    private let appleLoginManager = AppleLoginManager()
    private let networkManager = SignInNetworkManager()
    
    private let disposeBag = DisposeBag()
    
    private var isShowingLogOutAlert = false
    
    private let loginType = KeyChain.shared.get(key: "LOGIN_TYPE")
    
    private init() {}
    
    func checkAppleAuthentication() {
        guard let userID = KeyChain.shared.get(key: "APPLE_USER_ID"),
              let loginType = KeyChain.shared.get(key: "LOGIN_TYPE"), loginType == "APPLE" else { return }
        
        appleLoginManager.checkAppleIDCredentialState(userID: userID)
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .authorized:
                    self.logger.debug("애플 로그인 인증 상태: 연결됨")
                    
                case .revoked, .notFound:
                    self.logger.error("애플 로그인 인증 상태: 연결 끊김 또는 찾을 수 없음. 로그아웃 진행")
                    self.withdraw()
                    
                default:
                    break
                }
            }, onError: { error in
                self.logger.error("애플 인증 상태 확인 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    func logout() {
        if loginType == "KAKAO" {
            kakaoLogout()
        }
        
        removeTokens()
        showLogOutAlert()
        
        logger.debug("로그아웃 처리")
    }
    
    func withdraw() {
        if loginType == "KAKAO" {
            kakaoUnlink()
        } else if loginType == "APPLE" {
            appleRevoke()
        }
        
        removeTokens()
        switchToLoginView()
    }
    
    func removeTokens() {
        KeyChain.shared.remove(key: "ACCESS_TOKEN")
        KeyChain.shared.remove(key: "ACCESS_TOKEN_EXPIRE_AT_KST")
        KeyChain.shared.remove(key: "REFRESH_TOKEN")
        KeyChain.shared.remove(key: "REFRESH_TOKEN_EXPIRE_AT_KST")
        KeyChain.shared.remove(key: "LOGIN_TOKEN")
        KeyChain.shared.remove(key: "USER_ID")
        KeyChain.shared.remove(key: "FCM_TOKEN")
        KeyChain.shared.remove(key: "EMAIL")
        KeyChain.shared.remove(key: "LOGIN_TYPE")
        KeyChain.shared.remove(key: "APPLE_USER_ID")
        
        logger.debug("모든 keychain 내 토큰 제거")
    }
    
    func showLogOutAlert() {
        guard !isShowingLogOutAlert else { return }
        isShowingLogOutAlert = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let currentVC = currentWindow?.rootViewController {
                let alert = CustomAlertView(
                    title: String(localized: "Notice", table: "Common"),
                    subTitle: String(localized: "YouShouldSignInAgain", table: "Common"),
                    primaryTitleKey: String(localized: "Confirm", table: "Common")
                )
                
                alert.onPrimaryTapped = {
                    self.switchToLoginView()
                }
                
                alert.show(on: currentVC)
            }
        }
        
        logger.debug("showLogOutAlert 함수 실행")
    }
    
    func switchToLoginView() {
        DispatchQueue.main.async {
            if let currentWindow {
                let vc = UINavigationController(rootViewController: LoginView())
                vc.isNavigationBarHidden = true
                
                currentWindow.rootViewController = vc
            }
        }
        
        logger.debug("LoginView로 전환")
    }
    
    private func kakaoLogout() {
        UserApi.shared.logout() { error in
            if let error = error {
                self.logger.error("카카오 로그아웃 실패: \(error)")
            }
        }
    }
    
    private func kakaoUnlink() {
        UserApi.shared.unlink() { error in
            if let error = error {
                self.logger.error("카카오 연결 끊기 실패: \(error)")
            }
        }
    }
    
    private func appleRevoke() {
        // 서버에 authorizationCode를 보내 애플 Revoke API 진행
        networkManager.fetchAuthRevokeApple()
            .subscribe(onSuccess: { [weak self] in
                guard let self = self else { return }
                
                self.logger.debug("애플 Revoke 성공")
            }, onFailure: { [weak self] error in
                guard let self = self else { return }
                
                self.logger.error("애플 Revoke 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
