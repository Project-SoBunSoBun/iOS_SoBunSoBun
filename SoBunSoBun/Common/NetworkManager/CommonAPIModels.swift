//
//  CommonAPIModels.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/12/25.
//

import Foundation

// TODO: 파일 분할 필요

// MARK: - 공통
struct UserInfoModel: Decodable {
    let id: Int
    let email: String
    let nickname: String?
    let profileImageUrl: String?
    let role: String
}

struct PostListResponseModel: Decodable {
    let posts: [PostModel]
    let pageInfo: PostPageInfo
}

struct PostModel: Decodable {
    let id, minMembers, maxMembers, joinedMembers: Int
    let owner: PostOwnerModel
    let title, categoryCode, itemsText, notesText, locationName, meetAt, deadlineAt, status, createdAt, updatedAt: String
    let content: String?
}

struct PostOwnerModel: Decodable {
    let id: Int
    let nickname, profileImageUrl, address: String?
}

struct PostPageInfo: Decodable {
    let currentPage, pageSize, totalElements, totalPages: Int
    let last: Bool
}

struct ErrorModel: Decodable {
    let code, message: String
}

// MARK: - 리프레시
struct RefreshBodyModel: Encodable {
    let refreshToken: String
}

struct RefreshResponseModel: Decodable {
    let tokenType: String
    let accessToken: String
    let accessTokenExpiresAtKst: String
    let expiresIn: Int
}
