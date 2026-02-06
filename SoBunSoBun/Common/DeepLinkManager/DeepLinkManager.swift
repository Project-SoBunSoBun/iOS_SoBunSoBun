//
//  DeepLinkManager.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/7/26.
//

import Foundation

class DeepLinkManager {
    static let shared = DeepLinkManager()
    
    private init() {}
    
    func handle(url: URL) {
        DispatchQueue.main.async {
            guard let window else { return }
            
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            let path = url.path
            // let queryItems = components?.queryItems
            
            // 게시글
            if path.hasPrefix("/post/") {
                let postIdString = path.replacingOccurrences(of: "/post/", with: "")
                if let postId = Int(postIdString) {
                    let vc = PostDetailView(postId: postId)
                    window.rootViewController?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            // 프로필
        }
    }
}
