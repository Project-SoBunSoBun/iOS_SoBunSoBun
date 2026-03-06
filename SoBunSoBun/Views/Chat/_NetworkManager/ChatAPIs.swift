//
//  ChatAPIs.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/24/26.
//

import Foundation
import Moya

enum ChatAPIs {
    case getChatRoomDetail(id: Int)
    case getChatHistory(id: Int, cursor: String?, size: Int)
    case uploadChatImage(id: Int, message: String?, image: Data)
    case leaveChatRoom(id: Int)
    case kickMember(chatRoomId: Int, userId: Int)
}

extension ChatAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .getChatRoomDetail(let id):
            return "/api/v1/chat/rooms/\(id)/detail"
            
        case .getChatHistory(let id, _, _):
            return "/api/v1/chat/rooms/\(id)/messages/cursor"
            
        case .uploadChatImage(let id, _, _):
            return "/api/v1/chat/rooms/\(id)/images"
            
        case .leaveChatRoom(let id):
            return "/api/v1/chat/rooms/\(id)/members/me"
            
        case .kickMember(let chatRoomId, let userID):
            return "/api/chat/rooms/\(chatRoomId)/members/\(userID)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // GET
                .getChatRoomDetail,
                .getChatHistory:
            return .get
            
        case // POST
                .uploadChatImage:
            return .post
            
        case // DELETE
                .leaveChatRoom,
                .kickMember:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getChatRoomDetail:
            return .requestPlain
            
        case .getChatHistory(_, let cursor, let size):
            var parameters: [String: Any] = ["size": size]
            
            if let cursor {
                parameters["cursor"] = cursor
            }
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
        case .uploadChatImage(_, let message, let image):
            let imageData = image
            var formData: [MultipartFormData] = []
            
            formData.append(MultipartFormData(
                provider: .data(imageData),
                name: "image",
                fileName: "",
                mimeType: "image/jpeg"
            ))
            
            var parameters: [String: String] = [:]
            
            if let message {
                parameters["message"] = message
            }
            
            return .uploadCompositeMultipart(formData, urlParameters: parameters)
            
        case .leaveChatRoom:
            return .requestPlain
            
        case .kickMember:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .uploadChatImage:
            return ["Content-Type": "multipart/form-data"]
            
        default:
            return [:]
        }
    }
}
