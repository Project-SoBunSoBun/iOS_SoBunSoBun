//
//  ChatAPIModels.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/21/26.
//

import Foundation
import GRDB

enum ChatMessageType: String, Codable {
    case TEXT
    case IMAGE
    case INVITE_CARD
    case SETTLEMENT_CARD
    case SYSTEM
    case ENTER
    case LEAVE
}

enum ChatRoomType: String, Codable {
    case ONE_TO_ONE
    case GROUP
}

struct ChatMessageModel: Codable, Equatable, FetchableRecord, PersistableRecord {
    let id: String
    let roomId, userId: Int
    var nickname, profileImage: String?
    let type: ChatMessageType
    let content, imageUrl: String?
    let createdAt: String
    let settlementId, inviteId: Int?
    
    static var databaseTableName: String { "messages" }
}

struct ChatSendMessageModel: Encodable, Equatable {
    let roomId: Int
    let type: ChatMessageType
    let content: String?
    let cardPayload: String? = nil
}

struct ChatReadMessageModel: Encodable {
    let roomId: Int
    let lastReadMessageId: String
}

// 과거 메시지 불러오기 모델
struct ChatMessageHistoryModel: Decodable, Equatable {
    let status: String
    let code: Int
    let data: [ChatMessageModel]
    let message: String?
}

struct ChatRoomDetailModel: Decodable, Equatable {
    let status: String
    let code: Int
    let data: ChatRoomDetailDataModel
    let message, error: String?
}

struct ChatRoomDetailDataModel: Decodable, Equatable {
    let roomId, ownerId, groupPostId: Int
    let roomName, groupPostTitle, createdAt : String
    let roomType: ChatRoomType
    let members: [ChatRoomDetailMemberModel]
    let isSettled: Bool
    let isReviewed: Bool?
    let settlementId: Int?
}

struct ChatRoomDetailMemberModel: Decodable, Equatable {
    let userId: Int
    let nickname, profileImage: String?
    let isOwner: Bool
}

struct GroupChatAcceptResponseModel: Decodable {
    let success: Bool
    let statusCode: Int
    let message: String?
    let data: GroupChatAcceptResponseDataModel
}

struct GroupChatAcceptResponseDataModel: Decodable {
    let chatRoomId, inviterId, inviteeId: Int
}

struct ChatRateMannerRequestBodyModel: Encodable {
    let groupPostId: Int
    let reviews: [ChatRateMannerRequestBodyReviewModel]
}

struct ChatRateMannerRequestBodyReviewModel: Encodable {
    let receiverId: Int
    let tagCodes: [String]
}
