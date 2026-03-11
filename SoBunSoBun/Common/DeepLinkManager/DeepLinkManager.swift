//
//  DeepLinkManager.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/7/26.
//

import Foundation
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
        
        DispatchQueue.main.async {
            guard let currentWindow else { return }
            
            let path = url.path
            // let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            // let queryItems = components?.queryItems
            
            // 게시글
            if path.hasPrefix("/post/") {
                let postIdString = path.replacingOccurrences(of: "/post/", with: "")
                if let postId = Int(postIdString) {
                    let vc = PostDetailView(postId: postId)
                    currentWindow.rootViewController?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            // 프로필
            if path.hasPrefix("/profile/") {
                let profileIdString = path.replacingOccurrences(of: "/profile/", with: "")
                if let profileId = Int(profileIdString) {
                    
                }
            }
        }
    }
}
