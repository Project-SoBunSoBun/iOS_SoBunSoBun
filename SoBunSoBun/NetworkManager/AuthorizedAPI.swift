//
//  AuthorizedAPI.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/24/25.
//


import Foundation
import Moya

enum AuthorizedAPI {
    
}

extension AuthorizedAPI: TargetType {
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
            
        }
    }
    
    var method: Moya.Method {
        switch self {
            
        }
    }
    
    var task: Moya.Task {
        switch self {
            
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
