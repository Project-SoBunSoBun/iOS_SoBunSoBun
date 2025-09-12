//
//  PublicAPI.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/12/25.
//

import Foundation
import Moya

enum PublicAPI {
    case authLoginKakao(accessToken: String)
    case health
}

extension PublicAPI: TargetType {
    var baseURL: URL {
        let apiUrl = Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String
        return URL(string: apiUrl)!
    }
    
    var path: String {
        switch self {
        case .authLoginKakao:
            return "/auth/login/kakao-token"
        case .health:
            return "/health"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .authLoginKakao:
            return .post
        case .health:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .authLoginKakao(accessToken: let accessToken):
            let body = AuthKakaoTokenModel(accessToken: accessToken)
            return .requestJSONEncodable(body)
        case .health:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
