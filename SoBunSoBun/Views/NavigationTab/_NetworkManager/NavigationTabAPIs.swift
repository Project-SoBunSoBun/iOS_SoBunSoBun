//
//  NavigationTabAPIs.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/10/26.
//

import Foundation
import Moya

enum NavigationTabAPIs {
    case getChatRoomList
}

extension NavigationTabAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .getChatRoomList:
            return "/api/v1/chat/rooms/list"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // GET
                .getChatRoomList:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
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
