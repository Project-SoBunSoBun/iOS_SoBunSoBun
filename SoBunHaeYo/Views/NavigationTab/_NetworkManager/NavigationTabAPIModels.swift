//
//  NavigationTabAPIModels.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/10/26.
//

import Foundation

struct ChatRoomListResponseModel: Decodable, Equatable {
    let success: Bool
    let data: [ChatRoomListResponseDataModel]?
    let message, errorCode: String?
}

struct ChatRoomListResponseDataModel: Decodable, Equatable {
    let roomId, unReadCount: Int
    let roomName: String
    let profileImageUrl: String?
    let lastMessage: ChatMessageModel?
    let roomType: ChatRoomType
}
