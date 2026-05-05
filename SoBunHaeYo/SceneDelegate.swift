//
//  SceneDelegate.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 8/15/25.
//

import UIKit
import KakaoSDKAuth
import RxKakaoSDKAuth
import OSLog

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "SceneDelegate"
    )
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
            
            // 딥링크 처리
            DeepLinkManager.shared.handle(url: url)
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // 텍스트 입력창 밖 tap할 시 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
        
        let nav = UINavigationController(rootViewController: SplashView())
        nav.isNavigationBarHidden = true
        
        window.rootViewController = nav
        window.makeKeyAndVisible()
        
        // 딥링크 처리
        if let urlContext = connectionOptions.urlContexts.first {
            DeepLinkManager.shared.handle(url: urlContext.url)
        }
        
        // 애플 계정 연결 상태 체크 (앱 최초 실행 시 1회)
        AuthManager.shared.checkAppleAuthentication()
        
        logger.debug("[저장된 ACCESS_TOKEN]\n\n\(KeyChain.shared.get(key: "ACCESS_TOKEN") ?? "KeyChain에 저장되지 않음")")
        // logger.debug("[저장된 LOGIN_TOKEN]\n\n\(KeyChain.shared.get(key: "LOGIN_TOKEN") ?? "KeyChain에 저장되지 않음")")
    }
    
    @objc private func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        window?.endEditing(true)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationCenter.default.post(name: .sceneWillEnterForeground, object: nil)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        NotificationCenter.default.post(name: .sceneDidEnterBackground, object: nil)
    }
}

extension SceneDelegate: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // NonDismissingButton 터치 시 키보드 내리기 제스처 비활성화
        return !(touch.view is NonDismissingButton)
    }
}

// 키보드를 내리지 않아야 하는 버튼에 사용하는 마커 서브클래스
final class NonDismissingButton: UIButton {}

extension Notification.Name {
    static let sceneDidEnterBackground = Notification.Name("sceneDidEnterBackground")
    static let sceneWillEnterForeground = Notification.Name("sceneWillEnterForeground")
}
