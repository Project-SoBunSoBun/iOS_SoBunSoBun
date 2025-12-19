//
//  SceneDelegate.swift
//  SoBunSoBun
//
//  Created by 허성필 on 8/15/25.
//

import UIKit
import KakaoSDKAuth
import RxKakaoSDKAuth
import OSLog

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "SceneDelegate"
    )
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        window.backgroundColor = .backgroundWhite
        
        // 텍스트 입력창 밖 tap할 시 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        window.addGestureRecognizer(tapGesture)
        
        var nav: UINavigationController
        
        let now = Date()
        
        if KeyChain.shared.get(key: "REFRESH_TOKEN") != nil,
           let refreshTokenExpireAtKST = KeyChain.shared.get(key: "REFRESH_TOKEN_EXPIRE_AT_KST"),
           let dateRefreshTokenExpireAtKST = ISO8601ToDate(refreshTokenExpireAtKST),
           dateRefreshTokenExpireAtKST > now {
            nav = UINavigationController(rootViewController: NavigationTabView())
        } else {
            nav = UINavigationController(rootViewController: LoginView())
        }
        
        nav.isNavigationBarHidden = true
        
        window.rootViewController = nav
        window.makeKeyAndVisible()
        
        logger.debug("[저장된 ACCESS_TOKEN]\n\n\(KeyChain.shared.get(key: "ACCESS_TOKEN") ?? "KeyChain에 저장되지 않음")")
        // logger.debug("[저장된 LOGIN_TOKEN]\n\n\(KeyChain.shared.get(key: "LOGIN_TOKEN") ?? "KeyChain에 저장되지 않음")")
    }
    
    @objc private func dismissKeyboard() {
        window?.endEditing(true)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

