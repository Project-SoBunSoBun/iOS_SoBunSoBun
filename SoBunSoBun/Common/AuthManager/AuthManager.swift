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

class AuthManager {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "AuthManager"
    )
    
    static let shared = AuthManager()
    
    private init() {}
    
    func logout() {
        kakaoLogout()
        removeTokens()
        showLogOutAlert()
        
        logger.debug("로그아웃 처리")
    }
    
    func withdraw() {
        kakaoUnlink()
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
        
        logger.debug("모든 keychain 내 토큰 제거")
    }
    
    func showLogOutAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let currentVC = window?.rootViewController {
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
            if let window {
                let vc = UINavigationController(rootViewController: LoginView())
                vc.isNavigationBarHidden = true
                
                window.rootViewController = vc
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
}
