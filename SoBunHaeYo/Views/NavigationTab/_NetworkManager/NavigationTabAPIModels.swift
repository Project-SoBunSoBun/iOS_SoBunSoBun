//
//  NavigationTabAPIModels.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/10/26.
//

import Foundation

struct ChatRoomListResponseModel: Decodable, Equatable {
    let status: String
    let code: Int
    let data: [ChatRoomListResponseDataModel]
    let message, error: String?
}

struct ChatRoomListResponseDataModel: Decodable, Equatable {
    let roomId, unReadCount: Int
    let roomName: String
    let profileImageUrl: String?
    let lastMessage: ChatMessageModel?
    let roomType: ChatRoomType
}
