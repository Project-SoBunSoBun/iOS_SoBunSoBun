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
    case me
    // 홈
    case getLocationVerification
    case patchLocationVerification(address: String)
    case getHomeList(page: Int, size: Int)
    case getHomeListByCategories(category: [String], page: Int, size: Int)
    case registerPost(model: RegisterPostBodyModel)
    // 검색
    case getSuggestions
    case getSearchList(keyword: String, sortBy: String, page: Int, size: Int)
    // 정산
    case mySettleUps(activeOnly: Int, page: Int, size: Int)
    case deleteSettleUp(id: Int)
    // 마이페이지
    case getMeProfile
    case patchProfileImage(profileImage: Data)
    case patchNickname(nickname: String)
}

extension AuthorizedAPI: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .saveProfile:
            return "/users/me/profile"
        case .me:
            return "/api/me"
        case .getLocationVerification:
            return "/api/me/location-verification"
        case .patchLocationVerification:
            return "/api/me/location-verification"
        case .getHomeList:
            return "/api/posts"
        case .getHomeListByCategories(let category, page: _, size: _):
            return "/api/posts/categories/\(category.joined(separator: ","))"
        case .registerPost:
            return "/api/posts"
        case .getSuggestions:
            return "/api/search/suggestions/default"
        case .getSearchList:
            return "/api/search"
        case .mySettleUps:
            return "/api/settleups/my"
        case .deleteSettleUp(let id):
            return "/api/settleups/\(id)"
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
        case .saveProfile:
            return .patch
        case .me:
            return .get
        case .getLocationVerification:
            return .get
        case .patchLocationVerification:
            return .patch
        case .getHomeList:
            return .get
        case .getHomeListByCategories:
            return .get
        case .registerPost:
            return .post
        case .getSuggestions:
            return .get
        case .getSearchList:
            return .get
        case .mySettleUps:
            return .get
        case .deleteSettleUp:
            return .delete
        case .getMeProfile:
            return .get
        case .patchProfileImage:
            return .patch
        case .patchNickname:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
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
            
        case .me:
            return .requestPlain
            
        case .getLocationVerification:
            return .requestPlain
            
        case .patchLocationVerification(let address):
            let body = LocationVerificationBodyModel(address: address)
            
            return .requestJSONEncodable(body)
            
        case .getHomeList(let page, let size):
            let parameters = HomeListRequestModel(page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
            
        case .getHomeListByCategories(category: _, let page, let size):
            let parameters = HomeListRequestModel(page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
            
        case .registerPost(let model):
            return .requestJSONEncodable(model)
            
        case .getSuggestions:
            return .requestPlain
            
        case .getSearchList(let keyword, let sortBy, let page, let size):
            let parameters = SearchListRequestModel(keyword: keyword, sortBy: sortBy, page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
        
        case .mySettleUps(let activeOnly, let page, let size):
            let parameters = SettleUpMyRequestModel(activeOnly: activeOnly, page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
            
        case .deleteSettleUp:
            return .requestPlain
            
        case .getMeProfile:
            return .requestPlain
            
        case .patchProfileImage(profileImage: let profileImage):
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
        case .saveProfile,
            .patchProfileImage:
            return ["Content-Type": "multipart/form-data"]
        case .me,
                .getLocationVerification,
                .patchLocationVerification,
                .getHomeList,
                .getHomeListByCategories,
                .registerPost,
                .getSuggestions,
                .getSearchList,
                .mySettleUps,
                .deleteSettleUp,
                .getMeProfile,
                .patchNickname:
            return [:]
        }
    }
}
