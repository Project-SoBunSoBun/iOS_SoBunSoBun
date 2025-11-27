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
    case mySettleUps(activeOnly: String, page: Int, size: Int)
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
        case .mySettleUps:
            return "/api/settleups/my"
        }
    }
    
    var method: Moya.Method {
        switch self {
            
        case .saveProfile:
            return .patch
        case .myProfile:
            return .get
        case .mySettleUps:
            return .get
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
        case .mySettleUps(activeOnly: let activeOnly, page: let page, size: let size):
            return .requestParameters(parameters: ["activeOnly": activeOnly, "page": page, "size": size], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .saveProfile:
            return ["Content-Type": "multipart/form-data"]
        case .myProfile:
            return [:]
        case .mySettleUps:
            return [:]
        }
    }
}
