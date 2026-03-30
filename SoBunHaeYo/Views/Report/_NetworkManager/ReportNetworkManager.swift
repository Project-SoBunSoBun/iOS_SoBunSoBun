//
//  ReportNetworkManager.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/23/26.
//

import Foundation
import Moya
import RxMoya
import RxSwift

final class ReportNetworkManager {
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    // 댓글 신고
    func reportPostComment(commentId: Int, reason: String, description: String) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(ReportAPIs.reportPostComment(commentId: commentId, reason: reason, description: description)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // 게시글 신고
    func reportPost(postId: Int, reason: String, description: String) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(ReportAPIs.reportPost(postId: postId, reason: reason, description: description)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // 사용자 신고
    func reportUser(userId: Int, groupPostId: Int, reason: String, description: String) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(ReportAPIs.reportUser(userId: userId, groupPostId: groupPostId, reason: reason, description: description)))
        
        return request.tryMap(PlainResponseModel.self)
    }
}
