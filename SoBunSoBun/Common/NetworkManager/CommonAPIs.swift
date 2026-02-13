//
//  CommonAPIs.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/24/25.
//

import Foundation
import Moya

enum CommonAPIs {
    // myProfile
    case me
    // 액세스 토큰 재발급
    case refresh(refreshToken: String)
}

extension CommonAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .me:
            return "/api/me"
            
        case .refresh:
            return "/auth/token/refresh"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .me:
            return .get
            
        case .refresh:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .me:
            return .requestPlain
            
        case .refresh(let refreshToken):
            let body = RefreshBodyModel(refreshToken: refreshToken)
            
            return .requestJSONEncodable(body)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default:
            return [:]
        }
    }
}
