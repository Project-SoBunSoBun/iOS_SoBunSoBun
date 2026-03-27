//
//  NavigationTabAPIs.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/10/26.
//

import Foundation
import Moya

enum NavigationTabAPIs {
    case getUnreadNotificationCount
    case getChatRoomList
}

extension NavigationTabAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .customCodes(Array(200...299) + [400] + Array(402...499))
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .getUnreadNotificationCount:
            return "/api/me/notifications/unread-count"
            
        case .getChatRoomList:
            return "/api/v1/chat/rooms/list"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // GET
                .getUnreadNotificationCount,
                .getChatRoomList:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getUnreadNotificationCount:
            return .requestPlain
            
        case .getChatRoomList:
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
