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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .me:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .me:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .me:
            return [:]
        }
    }
}
