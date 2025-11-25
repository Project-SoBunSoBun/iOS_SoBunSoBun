//
//  AuthorizedAPI.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/24/25.
//

import Foundation
import Moya

enum AuthorizedAPI {
    // 로그인
    case saveProfile(nickname: String, profileImage: Data?)
    case myProfile
    // 홈
    case getLocationVerification
    case patchLocationVerification(address: String)
}

extension AuthorizedAPI: TargetType {
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .saveProfile:
            return "/users/me/profile"
        case .myProfile:
            return "/me"
        case .getLocationVerification:
            return "/me/location-verification"
        case .patchLocationVerification:
            return "/me/location-verification"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .saveProfile:
            return .patch
        case .myProfile:
            return .get
        case .getLocationVerification:
            return .get
        case .patchLocationVerification:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .saveProfile(nickname: let nickname, profileImage: let profileImage):
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
        case .myProfile:
            return .requestPlain
        case .getLocationVerification:
            return .requestPlain
        case .patchLocationVerification(address: let address):
            let body = LocationVerificationBodyModel(address: address)
            
            return .requestJSONEncodable(body)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .saveProfile:
            return ["Content-Type": "multipart/form-data"]
        case .myProfile,
                .getLocationVerification,
                .patchLocationVerification:
            return [:]
        }
    }
}
