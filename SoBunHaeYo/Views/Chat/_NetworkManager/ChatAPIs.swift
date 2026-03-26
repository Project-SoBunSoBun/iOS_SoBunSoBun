//
//  ChatAPIs.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/24/26.
//

import Foundation
import Moya

enum ChatAPIs {
    case getChatRoomDetail(id: Int)
    case getChatHistory(id: Int, cursor: String?, size: Int)
    case sendText(id: Int, message: String)
    case sendChatImage(id: Int, message: String?, image: Data)
    case sendInviteCard(chatRoomId: Int, inviteeId: Int)
    case acceptInvitation(inviteId: Int)
    case sendSettlementCard(chatRoomId: Int, settlementId: Int)
    case leaveChatRoom(id: Int)
    case kickMember(chatRoomId: Int, userId: Int)
    case rateManners(groupPostId: Int, manners: [Int: [String]])
}

extension ChatAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .customCodes(Array(200...299) + [400] + Array(402...499))
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
            
        case .sendText:
            return "/api/messages"
            
        case .sendChatImage(let id, _, _):
            return "/api/v1/chat/rooms/\(id)/images"
            
        case .sendInviteCard(let chatRoomId, _):
            return "/api/chat/rooms/\(chatRoomId)/invites"
            
        case .acceptInvitation(let inviteId):
            return "/api/chat/invites/\(inviteId)/accept"
            
        case .sendSettlementCard(let chatRoomId, _):
            return "/api/v1/chat/rooms/\(chatRoomId)/settlement-card"
            
        case .leaveChatRoom(let id):
            return "/api/v1/chat/rooms/\(id)/members/me"
            
        case .kickMember(let chatRoomId, let userID):
            return "/api/chat/rooms/\(chatRoomId)/members/\(userID)"
            
        case .rateManners:
            return "/api/manner/review"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // GET
                .getChatRoomDetail,
                .getChatHistory:
            return .get
            
        case // POST
                .sendText,
                .sendChatImage,
                .rateManners,
                .sendInviteCard,
                .sendSettlementCard:
            return .post
            
        case // PATCH
                .acceptInvitation:
            return .patch
            
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
            
        case .sendText(let id, let message):
            let body = ChatSendTextBodyModel(groupChatRoomId: id, content: message)
            
            return .requestJSONEncodable(body)
            
        case .sendChatImage(_, let message, let image):
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
            
        case .sendInviteCard(_, let inviteeId):
            let body: [String: Int] = ["inviteeId": inviteeId]
            
            return .requestJSONEncodable(body)
            
        case .acceptInvitation:
            return .requestPlain
            
        case .sendSettlementCard(_, let settlementId):
            let body: [String: Int] = ["settlementId": settlementId]
            
            return .requestJSONEncodable(body)
            
        case .leaveChatRoom:
            return .requestPlain
            
        case .kickMember:
            return .requestPlain
            
        case .rateManners(let groupPostId, let manners):
            let body: ChatRateMannerRequestBodyModel = ChatRateMannerRequestBodyModel(
                groupPostId: groupPostId,
                reviews: manners.map {
                    ChatRateMannerRequestBodyReviewModel(receiverId: $0.key, tagCodes: $0.value)
                }
            )
            
            return .requestJSONEncodable(body)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .sendChatImage:
            return ["Content-Type": "multipart/form-data"]
            
        default:
            return [:]
        }
    }
}
