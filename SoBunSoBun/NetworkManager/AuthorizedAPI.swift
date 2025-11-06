//
//  AuthorizedAPI.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/24/25.
//


import Foundation
import Moya

enum AuthorizedAPI {
    case saveProfile(nickname: String, profileImage: Data?)
    case myProfile
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
        }
    }
    
    var method: Moya.Method {
        switch self {
            
        case .saveProfile:
            return .patch
        case .myProfile:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
            
        case .saveProfile(nickname: let nickname, profileImage: let profileImage):
            var formData: [MultipartFormData] = []
            
            // 프로필 이미지가 있을 경우에만 추가
            if let imageData = profileImage {
                formData.append(MultipartFormData(provider: .data(imageData),
                                                  name: "profileImage",
                                                  fileName: "profile.jpg",
                                                  mimeType: "image/jpeg"))
            }
            
            // nickname은 URL query parameter로 전달
            let urlParameters = ["nickname": nickname]
            
            return .uploadCompositeMultipart(formData, urlParameters: urlParameters)
        case .myProfile:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .saveProfile:
            return ["Content-Type": "multipart/form-data"]
        case .myProfile:
            return [:]
        }
    }
}
