//
//  NotificationManager.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/19/26.
//

import Foundation
import FirebaseMessaging
import UserNotifications
import UIKit
import RxSwift
import OSLog

final class NotificationManager: NSObject {
    private override init() {}
    
    static let shared = NotificationManager()
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "NotificationManager"
    )
    
    private let networkManager = CommonNetworkManager()
    private let disposeBag = DisposeBag()
    
    // 알림 권한 요청
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // Firebase에 APNs를 등록하지 않으면 허용을 해도 항상 false로 return됨
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                self.logger.fault("권한 요청 에러: \(error)")
            }
            
            self.logger.debug("알림 granted: \(granted)")
            
            completion(granted)
        }
    }
    
    // 알림 권한 상태 확인
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        // Firebase에 APNs를 등록하지 않으면 허용을 해도 항상 false로 return됨
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            self.logger.debug("알림 권한 상태: \(settings.authorizationStatus.rawValue)")
            
            completion(settings.authorizationStatus)
        }
    }
    
    // 권한 확인 후 FCM 토큰 서버 전송
    func registerFCMToken() {
        checkAuthorizationStatus { status in
            guard status == .authorized || status == .provisional else {
                self.logger.error("알림 권한이 없습니다: \(status.rawValue)")
                
                return
            }
            
            self.logger.debug("알림 권한 확인 완료: \(status.rawValue)")
            
            self.sendFCMTokenToServer()
        }
    }
    
    private func sendFCMTokenToServer() {
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else { return }
        
        Messaging.messaging().token { [weak self] token, error in
            guard let self else { return }
            
            if let error = error {
                self.logger.fault("Error fetching FCM registration token: \(error)")
            }
            
            guard let token = token,
                  KeyChain.shared.get(key: "FCM_TOKEN") != token else {
                self.logger.debug("FCM 토큰을 서버에 전송하지 않음")
                
                return
            }
            
            networkManager.registerFCMToken(deviceId: uuid, token: token)
                .asObservable()
                .subscribe(onNext: { model in
                    if let errorCode = model.errorCode {
                        self.logger.critical("FCM 토큰 서버로 전송 중 오류 발생(\(errorCode)): \(model.message ?? "")")
                    } else {
                        self.logger.debug("FCM 토큰 서버 전송 완료\nDevice Id: \(uuid)\nFCM Token: \(token)")
                    }
                    KeyChain.shared.set(key: "FCM_TOKEN", value: token)
                }, onError: { error in
                    self.logger.critical("FCM 토큰 서버로 전송 중 오류 발생: \(error.localizedDescription)")
                })
                .disposed(by: self.disposeBag)
        }
    }
}
