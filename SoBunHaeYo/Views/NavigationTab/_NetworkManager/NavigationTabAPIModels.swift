//
//  NavigationTabAPIModels.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/10/26.
//

import Foundation

struct ChatRoomListResponseModel: Decodable, Equatable {
    let data: [ChatRoomListResponseDataModel]?
}

struct ChatRoomListResponseDataModel: Decodable, Equatable {
    let roomId, unReadCount: Int
    let roomName: String
    let profileImageUrl: String?
    let lastMessage: ChatMessageModel?
    let roomType: ChatRoomType
}
