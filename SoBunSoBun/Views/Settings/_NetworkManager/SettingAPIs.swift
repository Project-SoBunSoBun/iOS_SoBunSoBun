//
//  SettingAPIs.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/12/26.
//

import Foundation
import Moya

enum SettingAPIs {
    // 탈퇴
    case postWithdraw(reasonCode: String, reasonDetail: String, agreedToTerms: Bool)
    // 마이페이지
    case getMeProfile
    case patchProfileImage(profileImage: Data)
    case patchNickname(nickname: String)
}

extension SettingAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .postWithdraw:
            return "users/me/withdraw"
        case .getMeProfile:
            return "api/me/profile"
        case .patchProfileImage:
            return "users/me/profile-image"
        case .patchNickname:
            return "users/me/nickname"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // POST
                .postWithdraw:
            return .post
        case // GET
                .getMeProfile:
            return .get
        case // PATCH
                .patchProfileImage,
                .patchNickname:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .postWithdraw(let reasonCode, let reasonDetail, let agreedToTerms):
            let model = WithdrawRequestBodyModel(reasonCode: reasonCode, reasonDetail: reasonDetail, agreedToTerms: agreedToTerms)
            
            return .requestJSONEncodable(model)
        case .getMeProfile:
            return .requestPlain
            
        case .patchProfileImage(let profileImage):
            let imageData = profileImage
            var formData: [MultipartFormData] = []
            
            formData.append(MultipartFormData(
                provider: .data(imageData),
                name: "profileImage",
                fileName: "profile.jpg",
                mimeType: "image/jpeg"
            ))
            
            return .uploadMultipart(formData)
            
        case .patchNickname(nickname: let nickname):
            let body: [String: String] = ["nickname": nickname]
            
            return .requestJSONEncodable(body)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .patchProfileImage:
            return ["Content-Type": "multipart/form-data"]
        default :
            return [:]
        }
    }
}
