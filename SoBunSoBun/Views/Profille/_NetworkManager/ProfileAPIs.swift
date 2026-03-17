//
//  ProfileAPIs.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/16/26.
//

import Foundation
import Moya

enum ProfileAPIs {
    case getPostList(userId: Int, page: Int, size: Int)
    case blockUser(userId: Int)
    case unBlockUser(userId: Int)
    case reportUser(userId: Int, reason: String, description: String)
}

extension ProfileAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .customCodes(Array(200...299) + [400] + Array(402...499))
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .getPostList(let userId, _, _):
            return "/api/v1/users/\(userId)/profile"
            
        case
                .blockUser(let userId),
                .unBlockUser(let userId):
            return "/api/v1/blocks/\(userId)"
            
            
        case .reportUser(let userId, _, _):
            return "/api/v1/users/\(userId)/report"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // GET
                .getPostList:
            return .get
            
        case // POST
                .blockUser,
                .reportUser:
            return .post
            
        case // DELETE
                .unBlockUser:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getPostList(_, let page, let size):
            let parameters: [String: Int] = ["page": page, "size": size]
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
            
        case
                .blockUser,
                .unBlockUser:
            return .requestPlain
            
        case .reportUser(_, let reason, let description):
            let body: [String: String] = ["reason": reason, "description": description]
            
            return .requestJSONEncodable(body)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
