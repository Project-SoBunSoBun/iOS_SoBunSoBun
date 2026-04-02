//
//  DeepLinkManager.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/7/26.
//

import Foundation
import UIKit
import OSLog

final class DeepLinkManager {
    static let shared = DeepLinkManager()
    
    private init() {}
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "DeepLinkManager"
    )
    
    func handle(url: URL) {
        logger.debug("딥링크 감지됨: \(url)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let currentWindow,
                  let nav = currentWindow.rootViewController as? UINavigationController else {
                return
            }
            
            switch url.host {
            case "post": // 게시글
                if let postIdString = url.pathComponents.last,
                   let postId = Int(postIdString) {
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                    let notificationId = components?.queryItems?.first(where: { $0.name == "id" })?.value.flatMap { Int($0) }
                    
                    let vc = PostDetailView(postId: postId, notificationId: notificationId)
                    nav.pushViewController(vc, animated: true)
                }
                
            case "profile": // 프로필
                if let userIdString = url.pathComponents.last,
                   let userId = Int(userIdString) {
                    let vc = ProfileView(userId: userId)
                    nav.pushViewController(vc, animated: true)
                }
                
            case "settlement": // 정산
                if let settlementIdString = url.pathComponents.last,
                   let settlementId = Int(settlementIdString) {
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                    let notificationId = components?.queryItems?.first(where: { $0.name == "id" })?.value.flatMap { Int($0) }
                    
                    let vc = SettlementConfirmView(settlementId: settlementId, notificationId: notificationId)
                    nav.pushViewController(vc, animated: true)
                }
                
            case "chat": // 채팅
                if let chatRoomIdString = url.pathComponents.last,
                   let chatRoomId = Int(chatRoomIdString) {
                    let vc = ChatView(chatRoomId: chatRoomId)
                    nav.pushViewController(vc, animated: true)
                }
                
            case "notifications": // 알림
                let vc = NotificationsView()
                nav.pushViewController(vc, animated: true)
                
            default:
                logger.fault("알 수 없는 딥링크 host: \(url.host ?? "nil")")
            }
        }
    }
}
