//
//  AuthManager.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/25/25.
//

import Foundation
import UIKit
import OSLog

class AuthManager {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "AuthManager"
    )
    
    static let shared = AuthManager()
    
    private init() {}
    
    func logout() {
        removeTokens()
        showLogOutAlert()
        
        logger.debug("로그아웃 처리")
    }
    
    func removeTokens() {
        KeyChain.shared.remove(key: "ACCESS_TOKEN")
        KeyChain.shared.remove(key: "ACCESS_TOKEN_EXPIRE_AT_KST")
        KeyChain.shared.remove(key: "REFRESH_TOKEN")
        KeyChain.shared.remove(key: "REFRESH_TOKEN_EXPIRE_AT_KST")
        KeyChain.shared.remove(key: "LOGIN_TOKEN")
        
        logger.debug("모든 keychain 내 토큰 제거")
    }
    
    func showLogOutAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let currentVC = window?.rootViewController {
                showAlert(
                    title: String(localized: "Notice"),
                    message: String(localized: "YouShouldSignInAgain"),
                    confirmTitle: String(localized: "Confirm"),
                    confirmAction: { self.switchToLoginView() },
                    vc: currentVC
                )
            }
        }
        
        logger.debug("showLogOutAlert 함수 실행")
    }
    
    func switchToLoginView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let sceneDelegate = windowScene?.delegate as? SceneDelegate {
                let vc = UINavigationController(rootViewController: LoginView())
                vc.isNavigationBarHidden = true
                
                sceneDelegate.window?.rootViewController = vc
            }
        }
        
        logger.debug("LoginView로 전환")
    }
}
