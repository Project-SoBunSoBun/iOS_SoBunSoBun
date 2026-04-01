//
//  ReportAPIs.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/23/26.
//

import Foundation
import Moya

enum ReportAPIs {
    case reportPost(postId: Int, reason: String, description: String)
    case reportPostComment(commentId: Int, reason: String, description: String)
    case reportUser(userId: Int, groupPostId: Int, reason: String, description: String)
}

extension ReportAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return RESPONSE_CODES
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .reportPost:
            return "/api/v1/posts/reports"
            
        case .reportPostComment:
            return "/api/v1/comments/reports"
            
        case .reportUser(let userId, _, _, _):
            return "/api/v1/users/\(userId)/report"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // POST
                .reportPost,
                .reportPostComment,
                .reportUser:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .reportPost(let postId, let reason, let description):
            let body = ReportPostRequestBodyModel(postId: postId, reason: reason, description: description)
            
            return .requestJSONEncodable(body)
            
        case .reportPostComment(let commentId, let reason, let description):
            let body = ReportPostCommentRequestBodyModel(commentId: commentId, reason: reason, description: description)
            
            return .requestJSONEncodable(body)
            
        case .reportUser(_, let groupPostId, let reason, let description):
            let body = ReportUserRequestBodyModel(groupPostId: groupPostId, reason: reason, description: description)
            
            return .requestJSONEncodable(body)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
