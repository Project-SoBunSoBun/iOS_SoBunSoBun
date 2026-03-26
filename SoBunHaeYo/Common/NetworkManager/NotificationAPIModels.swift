//
//  NotificationAPIModels.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/27/26.
//

import Foundation

struct NotificationModel: Decodable {
    let id: Int
    let type: NotificationType
    let nickname: String?
    let postId, settlementId, chatRoomId: Int?
    let isRead: Bool
    let createdAt: String
}

struct NotificationResponseModel: Decodable {
    let success: Bool
    let data: NotificationResponseDataModel
}

struct NotificationResponseDataModel: Decodable {
    let content: [NotificationModel]
    let page: PageInfoModel
}
