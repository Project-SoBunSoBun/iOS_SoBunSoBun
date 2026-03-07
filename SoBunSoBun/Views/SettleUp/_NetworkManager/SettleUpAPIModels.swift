//
//  SettleUpAPIModels.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/13/26.
//

import Foundation

// MARK: - 정산
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
    let id, groupPostId: Int
    let groupPostTitle: String
    let status: String
    let totalAmount, participantCount: Int
    let participants: [ParticipantModel]
    let locationName: String
    let meetAt, createdAt, updatedAt: String
}

struct ParticipantModel: Decodable {
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
