//
//  SignInAPIs.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/13/26.
//

import Foundation
import Moya

enum SignInAPIs {
    // 로그인
    case authLoginKakao(accessToken: String)
    case authCompleteSignUp(loginToken: String, serviceTermsAgreed: Bool, privacyPolicyAgreed: Bool, marketingOptionalAgreed: Bool)
    case health
    case checkNickname(nickname: String)
    case saveProfile(nickname: String, profileImage: Data?)
}

extension SignInAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .successCodes
    }
    
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
            
        case .saveProfile:
            return "/users/me/profile"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // GET
                .health,
                .checkNickname:
            return .get
            
        case // POST
                .authLoginKakao,
                .authCompleteSignUp:
            return .post
            
        case // PATCH
                .saveProfile:
            return .patch
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
            
        case .saveProfile(let nickname, let profileImage):
            var formData: [MultipartFormData] = []
            
            // 사용자가 선택한 이미지가 있을 때 이미지 추가
            if let imageData = profileImage {
                formData.append(MultipartFormData(
                    provider: .data(imageData),
                    name: "profileImage",
                    fileName: "profile.jpg",
                    mimeType: "image/jpeg"
                ))
            } else {
                // 이미지가 없을 때 빈 데이터 전송
                formData.append(MultipartFormData(
                    provider: .data(Data()),
                    name: "profileImage",
                    fileName: "",
                    mimeType: "image/jpeg"
                ))
            }
            
            // nickname은 URL query parameter로 전달
            let urlParameters = ["nickname": nickname]
            
            return .uploadCompositeMultipart(formData, urlParameters: urlParameters)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .saveProfile:
            return ["Content-Type": "multipart/form-data"]
        default:
            return [:]
        }
    }
}
