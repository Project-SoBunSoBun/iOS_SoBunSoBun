//
//  SettleUpAPIModels.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/13/26.
//

import Foundation

// MARK: - 정산
struct SettleUpResponseModel: Decodable {
    let success: Bool
    let statusCode: Int
    let message: String?
    let data: SettleUpModel
    let errorCode: String?
    let timestamp: String
}

struct SettleUpModel: Decodable {
    let content: [SettleUpContentModel]
    let pageable: SettleUpPageableModel
    let totalElements, totalPages: Int
    let last: Bool
    let size, number: Int
    let sort: SettleUpSortModel
    let numberOfElements: Int
    let first, empty: Bool
}

struct SettleUpContentModel: Decodable {
    let id, authorId, groupPostId: Int
    let groupPostTitle: String
    let status: String
    let totalAmount: Int?
    let participantCount: Int
    let chatRoomMembers: [SettleUpParticipantModel]
    let locationName: String
    let meetAt, createdAt, updatedAt: String
}

struct SettleUpParticipantModel: Decodable {
    let userId: Int
    let nickname: String
}

struct SettleUpPageableModel: Decodable {
    let pageNumber, pageSize: Int
    let sort: SettleUpSortModel
    let offset: Int
    let paged, unpaged: Bool
}

struct SettleUpSortModel: Decodable {
    let sorted, empty, unsorted: Bool
}

struct SettleUpMyRequestModel: Encodable {
    let status: String
    let page, size: Int
}

// 정산 등록
struct SettlementCompleteRequestModel: Encodable {
    let totalAmount: Int
    let participants: [SettlementCompleteParticipantModel]
}

struct SettlementCompleteParticipantModel: Encodable {
    let userId: Int
    let assignedAmount: Int
    let items: [SettlementCompleteItemModel]
}

struct SettlementCompleteItemModel: Encodable {
    let itemName: String
    let quantity: Int
    let unit: String
    let amount: Int
}
