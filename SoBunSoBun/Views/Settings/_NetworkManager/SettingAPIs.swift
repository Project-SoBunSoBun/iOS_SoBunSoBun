//
//  SettingAPIs.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/12/26.
//

import Foundation
import Moya

enum SettingAPIs {
    // 탈퇴
    case postWithdraw(reasonCode: String, reasonDetail: String, agreedToTerms: Bool)
}

extension SettingAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
            
        case .postWithdraw(let reasonCode, let reasonDetail, let agreedToTerms):
            return "users/me/withdraw"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case // POST
                .postWithdraw:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .postWithdraw(let reasonCode, let reasonDetail, let agreedToTerms):
            let model = WithdrawRequestBodyModel(reasonCode: reasonCode, reasonDetail: reasonDetail, agreedToTerms: agreedToTerms)
            
            return .requestJSONEncodable(model)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
