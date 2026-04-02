//
//  AppDelegate.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 8/15/25.
//

import UIKit
import RxKakaoSDKCommon
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 카카오 로그인
        let appKeyKakao = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as! String
        RxKakaoSDK.initSDK(appKey: appKeyKakao)
        
        // Firebase
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // 푸시 알림 클릭
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        let type = userInfo["type"] as? String
        
        print("[AppDelegate] userNotificationCenter\n", userInfo)
        
        DispatchQueue.main.async {
            var urlString: String?
            
            switch type {
            case "COMMENT", "COMMENT_MENTIONED", "POST_UPDATE":
                if let postIdString = userInfo["postId"] as? String {
                    if let notificationIdString = userInfo["id"] as? String {
                        urlString = "sobunhaeyo://post/\(postIdString)?id=\(notificationIdString)"
                    } else {
                        urlString = "sobunhaeyo://post/\(postIdString)"
                    }
                }
                
            case "SETTLEMENT":
                if let settlementIdString = userInfo["settlementId"] as? String {
                    if let notificationIdString = userInfo["id"] as? String {
                        urlString = "sobunhaeyo://settlement/\(settlementIdString)?id=\(notificationIdString)"
                    } else {
                        urlString = "sobunhaeyo://settlement/\(settlementIdString)"
                    }
                }
                
            case "CHAT":
                if let chatRoomIdString = userInfo["chatRoomId"] as? String {
                    urlString = "sobunhaeyo://chat/\(chatRoomIdString)"
                }
                
            default:
                urlString = "sobunhaeyo://notifications"
            }
            
            if let urlString, let url = URL(string: urlString) {
                DeepLinkManager.shared.handle(url: url)
            }
        }
    }
    
    // 앱 화면 보고있는 중 푸시 알림 받음
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        
        return [.badge]
    }
    
    // Error
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError: \(error)")
    }
}

extension AppDelegate: MessagingDelegate {
    // 앱 시작마다 토큰 갱신 여부 확인
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let now = Date()
        
        guard KeyChain.shared.get(key: "REFRESH_TOKEN") != nil,
              let refreshTokenExpireAtKST = KeyChain.shared.get(key: "REFRESH_TOKEN_EXPIRE_AT_KST"),
              let dateRefreshTokenExpireAtKST = ISO8601ToDate(refreshTokenExpireAtKST),
              dateRefreshTokenExpireAtKST > now else {
            return
        }
        
        NotificationManager.shared.registerFCMToken()
    }
}
