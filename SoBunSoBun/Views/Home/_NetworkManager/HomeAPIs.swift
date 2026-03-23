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
    case getLocationVerification
    case patchLocationVerification(address: String)
    case getHomeList(sortBy: String, page: Int, size: Int)
    case getHomeListByCategories(category: [String], sortBy: String, page: Int, size: Int)
    case getAddress(point: String) // 좌표를 통해 주소 가져오기
    case registerPost(model: RegisterPostBodyModel)
    
    // 검색
    case getSuggestions
    case getSearchList(keyword: String, sortBy: String, page: Int, size: Int)
    
    // 게시글 상세
    case getPost(id: Int)
    case checkPostSaved(id: Int)
    case getPostCommentsCount(id: Int)
    case getPostComments(id: Int)
    case savePost(id: Int)
    case cancelSavePost(id: Int)
    case deletePost(id: Int)
    case createPostComment(postId: Int, content: String)
    case patchPostComment(id: Int, content: String)
    case deletePostComment(id: Int)
    case createChatRoomId(userId: Int, groupPostId: Int)
    
    // 마이페이지
    case getMyProfile(tab: String, page: Int, size: Int)
    
    // 알림
    case getUnreadNotificationCount
    case getNotifications(page: Int, size: Int)
    case readNotification(id: Int)
}

extension HomeAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .customCodes(Array(200...299) + [400] + Array(402...499))
    }
    
    var baseURL: URL {
        switch self {
        case .getAddress:
            return URL(string: "https://api.vworld.kr")!
            
        default:
            return URL(string: API_URL)!
        }
    }
    
    var path: String {
        switch self {
        case .getLocationVerification:
            return "/api/me/location-verification"
            
        case .patchLocationVerification:
            return "/api/me/location-verification"
            
        case .getHomeList:
            return "/api/posts"
            
        case .getHomeListByCategories(let category, _, _, _):
            return "/api/posts/categories/\(category.joined(separator: ","))"
            
        case .getAddress:
            return "/req/address"
            
        case .registerPost:
            return "/api/posts"
            
        case .getSuggestions:
            return "/api/search/suggestions/default"
            
        case .getSearchList:
            return "/api/search"
            
        case .getPost(let id), .deletePost(let id):
            return "/api/posts/\(id)"
            
        case .checkPostSaved:
            return "/api/v1/posts/saved/check"
            
        case .getPostCommentsCount(let id):
            return "/api/posts/\(id)/comments/count"
            
        case .getPostComments(let id):
            return "/api/posts/\(id)/comments"
            
        case .savePost, .cancelSavePost:
            return "/api/v1/posts/saved"
            
        case .createPostComment(let postId, _):
            return "/api/posts/\(postId)/comments"
            
        case .patchPostComment(let id, _), .deletePostComment(let id):
            return "/api/comments/\(id)"
            
        case .createChatRoomId:
            return "/api/v1/chat/rooms/private"
            
        case .getMyProfile:
            return "/api/v1/users/me/profile"
            
        case .getUnreadNotificationCount:
            return "/api/me/notifications/unread-count"
            
        case .getNotifications:
            return "/api/me/notifications"
            
        case .readNotification(let id):
            return "/api/me/notifications/\(id)/read"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // GET
                .getLocationVerification,
                .getHomeList,
                .getHomeListByCategories,
                .getAddress,
                .getSuggestions,
                .getSearchList,
                .getPost,
                .checkPostSaved,
                .getPostCommentsCount,
                .getPostComments,
                .getMyProfile,
                .getUnreadNotificationCount,
                .getNotifications:
            return .get
            
        case // POST
                .registerPost,
                .savePost,
                .createPostComment,
                .createChatRoomId:
            return .post
            
        case // PATCH
                .patchLocationVerification,
                .patchPostComment,
                .readNotification:
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
        case .getLocationVerification:
            return .requestPlain
            
        case .patchLocationVerification(let address):
            let body = LocationVerificationBodyModel(address: address)
            
            return .requestJSONEncodable(body)
            
        case .getHomeList(let sortBy, let page, let size):
            let parameters: [String: Any] = ["sortBy": sortBy, "page": page, "size": size]
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
            
        case .getHomeListByCategories(_, let sortBy, let page, let size):
            let parameters: [String: Any] = ["sortBy": sortBy, "page": page, "size": size]
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
            
        case .getAddress(point: let point):
            let key = Bundle.main.object(forInfoDictionaryKey: "VWORLD_CERT_KEY") as! String
            let model = GeocoderRequestModel(point: point, key: key)
            
            return .requestParameters(parameters: model.toDictionary()!, encoding: URLEncoding(destination: .queryString, arrayEncoding: .brackets, boolEncoding: .literal))
            
        case .registerPost(let model):
            return .requestJSONEncodable(model)
            
        case .getSuggestions:
            return .requestPlain
            
        case .getSearchList(let keyword, let sortBy, let page, let size):
            let parameters = SearchListRequestModel(keyword: keyword, sortBy: sortBy, page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
            
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
            
        case .createChatRoomId(let userId, let groupPostId):
            let body: [String: Int] = ["otherUserId": userId, "groupPostId": groupPostId]
            
            return .requestJSONEncodable(body)
            
        case .getMyProfile(let tab, let page, let size):
            let parameters = MyProfileRequestModel(tab: tab, page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
            
        case .getUnreadNotificationCount:
            return .requestPlain
            
        case .getNotifications(let page, let size):
            let parameters = PagenationRequestModel(page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
            
        case .readNotification:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
