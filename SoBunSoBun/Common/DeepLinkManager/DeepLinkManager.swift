//
//  DeepLinkManager.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/7/26.
//

import Foundation
import UIKit
import OSLog

class DeepLinkManager {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "DeepLinkManager"
    )
    
    static let shared = DeepLinkManager()
    
    private init() {}
    
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
                    let vc = PostDetailView(postId: postId)
                    nav.pushViewController(vc, animated: true)
                }
                
            case "profile": // 프로필
                if let userIdString = url.pathComponents.last,
                   let userId = Int(userIdString) {
                    let vc = ProfileView(userId: userId)
                    nav.pushViewController(vc, animated: true)
                }
                
            case "profile_managable": // 프로필 차단 및 신고 가능
                if let userIdString = url.pathComponents.last,
                   let userId = Int(userIdString) {
                    let vc = ProfileManagableView(userId: userId)
                    nav.pushViewController(vc, animated: true)
                }
                
            default:
                logger.fault("알 수 없는 딥링크 host: \(url.host ?? "nil")")
            }
        }
    }
}
