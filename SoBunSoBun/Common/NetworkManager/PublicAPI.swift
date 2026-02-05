//
//  PublicAPI.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/12/25.
//

import Foundation
import Alamofire
import Moya

// TODO: 파일 분할 필요
enum PublicAPI {
    // 로그인
    case authLoginKakao(accessToken: String)
    case authCompleteSignUp(loginToken: String, serviceTermsAgreed: Bool, privacyPolicyAgreed: Bool, marketingOptionalAgreed: Bool)
    case health
    case checkNickname(nickname: String) // 닉네임 중복 검사 API
    // 홈
    case getAddress(point: String) // 좌표를 통해 주소 가져오기
}

extension PublicAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .authLoginKakao, .authCompleteSignUp, .health, .checkNickname:
            return URL(string: API_URL)!
        case .getAddress:
            return URL(string: "https://api.vworld.kr")!
        }
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
        case .getAddress:
            return "/req/address"
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
        case .getAddress:
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
        case .getAddress(point: let point):
            let key = Bundle.main.object(forInfoDictionaryKey: "VWORLD_CERT_KEY") as! String
            let model = GeocoderRequestModel(point: point, key: key)
            
            return .requestParameters(parameters: model.toDictionary()!, encoding: URLEncoding(destination: .queryString, arrayEncoding: .brackets, boolEncoding: .literal))
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
