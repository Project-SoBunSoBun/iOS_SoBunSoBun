//
//  HomeAPIs.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/6/26.
//

import Foundation
import Moya

enum HomeAPIs {
    // 피드
    
    // 검색
    
    // 게시글 상세
    case getPost(id: Int)
    case checkPostSaved(id: Int)
    case getPostCommentsCount(id: Int)
    case getPostComments(id: Int)
    case savePost(id: Int)
    case cancelSavePost(id: Int)
    case reportPost(id: Int)
    case deletePost(id: Int)
    case createPostComment(postId: Int, content: String)
    case patchPostComment(id: Int, content: String)
    case deletePostComment(id: Int)
    case reportPostComment(id: Int)
}

extension HomeAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .getPost(let id), .deletePost(let id):
            return "/api/posts/\(id)"
            
        case .checkPostSaved(let id):
            return "/api/v1/posts/saved/check"
            
        case .getPostCommentsCount(let id):
            return "/api/posts/\(id)/comments/count"
            
        case .getPostComments(let id):
            return "/api/posts/\(id)/comments"
            
        case .savePost, .cancelSavePost:
            return "/api/v1/posts/saved"
            
        case .reportPost:
            return "/api/v1/posts/reports"
            
        case .createPostComment(let postId, _):
            return "/api/posts/\(postId)/comments"
            
        case .patchPostComment(let id, _), .deletePostComment(let id):
            return "/api/comments/\(id)"
            
        case .reportPostComment:
            return "/api/v1/comments/reports"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // GET
                .getPost,
                .checkPostSaved,
                .getPostCommentsCount,
                .getPostComments:
            return .get
            
        case // POST
                .savePost,
                .reportPost,
                .createPostComment,
                .reportPostComment:
            return .post
            
        case // PATCH
                .patchPostComment:
            return .patch
            
        case // DELETE
                .cancelSavePost,
                .deletePost,
                .deletePostComment:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getPost:
            return .requestPlain
            
        case .checkPostSaved(let id):
            let parameter: [String: Int] = ["postId": id]
            
            return .requestParameters(parameters: parameter, encoding: URLEncoding.queryString)
            
        case .getPostCommentsCount:
            return .requestPlain
            
        case .getPostComments:
            return .requestPlain
            
        case .savePost(let id), .cancelSavePost(let id):
            let parameter: [String: Int] = ["postId": id]
            
            return .requestParameters(parameters: parameter, encoding: URLEncoding.queryString)
            
        case .reportPost(let id):
            let model: ReportPostModel = ReportPostModel(postId: id, reason: "OTHER", description: "유저가 신고한 게시글입니다.")
            
            return .requestJSONEncodable(model)
            
        case .deletePost:
            return .requestPlain
            
        case .createPostComment(_, let content):
            let model: CreateCommentModel = CreateCommentModel(content: content, parentCommentId: 0)
            
            return .requestJSONEncodable(model)
            
        case .patchPostComment(_, let content):
            let body: [String: String] = ["content": content]
            
            return .requestJSONEncodable(body)
            
        case .deletePostComment:
            return .requestPlain
            
        case .reportPostComment(let id):
            let model: ReportCommentModel = ReportCommentModel(commentId: id, reason: "OTHER", description: "유저가 신고한 댓글입니다.")
            
            return .requestJSONEncodable(model)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case // None
                .getPost,
                .checkPostSaved,
                .getPostCommentsCount,
                .getPostComments,
                .savePost,
                .cancelSavePost,
                .reportPost,
                .deletePost,
                .createPostComment,
                .patchPostComment,
                .deletePostComment,
                .reportPostComment:
            return [:]
        }
    }
}
