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
    case getHomeList(page: Int, size: Int)
    case getHomeListByCategories(category: [String], page: Int, size: Int)
    // 정산
    case mySettleUps(activeOnly: Int, page: Int, size: Int)
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
        case .getHomeList:
            return "/api/posts"
        case .getHomeListByCategories(category: let category, page: _, size: _):
            return "/api/posts/categories/\(category.joined(separator: ","))"
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
        case .getLocationVerification:
            return .get
        case .patchLocationVerification:
            return .patch
        case .getHomeList:
            return .get
        case .getHomeListByCategories:
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
        case .getLocationVerification:
            return .requestPlain
        case .patchLocationVerification(address: let address):
            let body = LocationVerificationBodyModel(address: address)
            
            return .requestJSONEncodable(body)
        case .getHomeList(page: let page, size: let size):
            let parameters = HomeListRequestModel(page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
        case .getHomeListByCategories(category: _, page: let page, size: let size):
            let parameters = HomeListRequestModel(page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
        case .mySettleUps(activeOnly: let activeOnly, page: let page, size: let size):
            return .requestParameters(parameters: ["activeOnly": activeOnly, "page": page, "size": size], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .saveProfile:
            return ["Content-Type": "multipart/form-data"]
        case .myProfile,
                .getLocationVerification,
                .patchLocationVerification,
                .getHomeList,
                .getHomeListByCategories:
            return [:]
        case .mySettleUps:
            return [:]
        }
    }
}
