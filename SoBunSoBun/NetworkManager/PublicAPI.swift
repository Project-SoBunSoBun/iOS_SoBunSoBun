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
    case authCompleteSignUp(loginToken: String, serviceTermsAgreed: Bool, privacyPolicyAgreed: Bool, marketingOptionalAgreed: Bool)
    case health
    case checkNickname(nickname: String) // 닉네임 중복 검사 API
}

extension PublicAPI: TargetType {
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .authLoginKakao:
            return "/auth/verify/kakao-token"
        case .authCompleteSignUp:
            return "/auth/complete-signup"
        case .health:
            return "/health"
        case .checkNickname:
            return "/users/check-nickname"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .authLoginKakao:
            return .post
        case .authCompleteSignUp:
            return .post
        case .health:
            return .get
        case .checkNickname:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .authLoginKakao(accessToken: let accessToken):
            let body = AuthKakaoTokenModel(accessToken: accessToken)
            return .requestJSONEncodable(body)
        case .authCompleteSignUp(loginToken: let loginToken,
                                 serviceTermsAgreed: let serviceTermsAgreed,
                                 privacyPolicyAgreed: let privacyPolicyAgreed,
                                 marketingOptionalAgreed: let marketingOptionalAgreed):
            let body = LoginTokenModel(loginToken: loginToken,
                                       serviceTermsAgreed: serviceTermsAgreed,
                                       privacyPolicyAgreed: privacyPolicyAgreed,
                                       marketingOptionalAgreed: marketingOptionalAgreed)
            return .requestJSONEncodable(body)
        case .health:
            return .requestPlain
        case .checkNickname(nickname: let nickname):
            return .requestParameters(parameters: ["nickname": nickname], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
