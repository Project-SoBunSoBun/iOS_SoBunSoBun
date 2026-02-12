//
//  AuthorizedAPI.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/24/25.
//

import Foundation
import Moya

// TODO: 파일 분할 필요
enum AuthorizedAPI {
    // 로그인
    case saveProfile(nickname: String, profileImage: Data?)
    case me
    
    // 정산
    case mySettleUps(activeOnly: Int, page: Int, size: Int)
    case deleteSettleUp(id: Int)
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
        case .mySettleUps:
            return "/api/settleups/my"
        case .deleteSettleUp(let id):
            return "/api/settleups/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .saveProfile:
            return .patch
        case .me:
            return .get
        case .mySettleUps:
            return .get
        case .deleteSettleUp:
            return .delete
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
        
        case .mySettleUps(let activeOnly, let page, let size):
            let parameters = SettleUpMyRequestModel(activeOnly: activeOnly, page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
            
        case .deleteSettleUp:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .saveProfile:
            return ["Content-Type": "multipart/form-data"]
        case .me,
                .mySettleUps,
                .deleteSettleUp:
            return [:]
        }
    }
}
