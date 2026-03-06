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
    let settlementId, groupChatRoomId: Int?
    
    static var databaseTableName: String { "messages" }
}

struct ChatSendMessageModel: Encodable, Equatable {
    let roomId: Int
    let type: ChatMessageType
    let content: String?
    let cardPayload: String? = nil
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
    let roomName, createdAt: String
    let roomType: ChatRoomType
    let lastMessage, lastMessageAt, groupPostTitle: String?
    let members: [ChatRoomDetailMemberModel]
}

struct ChatRoomDetailMemberModel: Decodable, Equatable {
    let userId: Int
    let nickname, profileImage: String?
    let isOwner: Bool
}
