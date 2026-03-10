//
//  SettleUpAPIs.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/13/26.
//

import Foundation
import Moya

enum SettleUpAPIs {
    // 정산
    case mySettleUps(status: String, page: Int, size: Int)
    case deleteSettleUp(id: Int)
}

extension SettleUpAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .mySettleUps:
            return "/api/v1/settlements/my"
            
        case .deleteSettleUp(let id):
            return "/api/v1/settlements/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // GET
                .mySettleUps:
            return .get
            
        case // DELETE
                .deleteSettleUp:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .mySettleUps(let status, let page, let size):
            let parameters = SettleUpMyRequestModel(status: status, page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
            
        case .deleteSettleUp:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
