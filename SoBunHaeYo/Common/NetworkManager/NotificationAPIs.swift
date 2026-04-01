//
//  NotificationAPIs.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/27/26.
//

import Foundation
import Moya

enum NotificationAPIs {
    case getNotifications(page: Int, size: Int)
    case readNotification(id: Int)
    case readAllNotifications
}

extension NotificationAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return RESPONSE_CODES
    }
    
    var baseURL: URL {
        switch self {
        default:
            return URL(string: API_URL)!
        }
    }
    
    var path: String {
        switch self {
        case .getNotifications:
            return "/api/me/notifications"
            
        case .readNotification(let id):
            return "/api/me/notifications/\(id)/read"
            
        case .readAllNotifications:
            return "/api/me/notifications/read-all"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // GET
                .getNotifications:
            return .get
            
        case // PATCH
                .readNotification,
                .readAllNotifications:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getNotifications(let page, let size):
            let parameters = PagenationRequestModel(page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
            
        case .readNotification:
            return .requestPlain
            
        case .readAllNotifications:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
