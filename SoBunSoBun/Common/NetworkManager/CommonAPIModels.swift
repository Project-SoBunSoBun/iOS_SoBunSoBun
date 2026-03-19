//
//  CommonAPIModels.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/12/25.
//

import Foundation

// MARK: - 공통
struct UserInfoModel: Decodable {
    let id: Int
    let email: String
    let nickname: String?
    let profileImageUrl: String?
    let role: String
}

struct PostListResponseModel: Decodable, Equatable {
    let posts: [PostModel]
    let pageInfo: PostPageInfo
}

struct PostModel: Decodable, Equatable {
    let id, minMembers, maxMembers, joinedMembers: Int
    let owner: PostOwnerModel
    let title, categoryCode, itemsText, notesText, locationName, meetAt, deadlineAt, status, createdAt, updatedAt: String
    let content: String?
    let latestComment: SimpleCommentModel?
}

struct PostOwnerModel: Decodable, Equatable {
    let id: Int
    let nickname, profileImageUrl, address: String?
}

struct PostPageInfo: Decodable, Equatable {
    let currentPage, pageSize, totalElements, totalPages: Int
    let last: Bool
}

struct SimpleCommentModel: Decodable, Equatable {
    let id: Int
    let content, createdAt: String
}

struct PlainResponseModel: Decodable {
    let success: Bool
    let error: ErrorModel?
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

// MARK: - FCM 토큰
struct RegisterFCMTokenRequestBodyModel: Encodable {
    let deviceId: String
    let fcmToken: String
    let platform: String = "IOS"
}
