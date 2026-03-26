//
//  CommonAPIs.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 9/24/25.
//

import Foundation
import Moya

enum CommonAPIs {
    // myProfile
    case me
    // 액세스 토큰 재발급
    case refreshAccessToken(refreshToken: String)
    // FCM 토큰 전송
    case registerFCMToken(deviceId: String, token: String)
    // FCM 토큰 삭제
    case deleteFCMToken(deviceId: String)
}

extension CommonAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .customCodes(Array(200...299) + [400] + Array(402...499))
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .me:
            return "/api/me"
            
        case .refreshAccessToken:
            return "/auth/token/refresh"
            
        case .registerFCMToken:
            return "/api/me/devices"
            
        case .deleteFCMToken(let deviceId):
            return "/api/me/devices/\(deviceId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // GET
                .me:
            return .get
            
        case // POST
                .refreshAccessToken,
                .registerFCMToken:
            return .post
            
        case // DELETE
                .deleteFCMToken:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .me:
            return .requestPlain
            
        case .refreshAccessToken(let refreshToken):
            let body = RefreshBodyModel(refreshToken: refreshToken)
            
            return .requestJSONEncodable(body)
            
        case .registerFCMToken(let deviceId, let token):
            let body = RegisterFCMTokenRequestBodyModel(deviceId: deviceId, fcmToken: token)
            
            return .requestJSONEncodable(body)
            
        case .deleteFCMToken:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default:
            return [:]
        }
    }
}
