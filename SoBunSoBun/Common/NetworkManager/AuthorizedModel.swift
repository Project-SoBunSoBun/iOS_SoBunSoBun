//
//  AuthorizedModel.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/12/25.
//

import Foundation

// MARK: - 공통
struct PostListResponseModel: Decodable {
    let posts: [PostModel]
    let pageInfo: PostPageInfo
}

struct PostModel: Decodable {
    let id: Int
    let owner: PostOwnerModel
    let title, categoryCode, content, itemsText, notesText, locationName, meetAt, deadlineAt: String
    let minMembers, maxMembers, joinedMembers: Int
    let status, createdAt, updatedAt: String
}

struct PostOwnerModel: Decodable {
    let id: Int
    let nickname, profileImageUrl: String?
}

struct PostPageInfo: Decodable {
    let currentPage, pageSize, totalElements, totalPages: Int
    let last: Bool
}

// MARK: - 로그인
struct AuthKakaoTokenModel: Encodable {
    let accessToken: String
}

struct LoginTokenModel: Encodable {
    let loginToken: String
    let serviceTermsAgreed: Bool
    let privacyPolicyAgreed: Bool
    let marketingOptionalAgreed: Bool
}

struct KakaoAuthResponse: Decodable {
    let email: String
    let nickname: String?
    let profileImageUrl: String?
    let loginToken: String
    let newUser: Bool
}

struct UserModel: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: UserInfoModel
    let accessTokenExpiresAtKst: String
    let refreshTokenExpiresAtKst: String
}

struct UserInfoModel: Decodable {
    let id: Int
    let email: String
    let nickname: String?
    let profileImageUrl: String?
    let role: String
}

struct CheckNicknameModel: Decodable {
    let nickname: String
    let available: Bool
}

// MARK: - 홈
struct LocationVerificationModel: Decodable {
    let address, locationVerifiedAt: String?
    let remainingMinutes: Int?
    let verified, expired: Bool
}

struct LocationVerificationBodyModel: Encodable {
    let address: String
}

struct HomeListRequestModel: Encodable {
    let page, size: Int
}

struct HomeListCategoryRequestModel: Encodable {
    let categories: [String]
    let page, size: Int
}

// MARK: - 정산
struct SettleUpModel: Decodable {
    let content: [Content]
    let pageable: Pageable
    let totalElements, totalPages: Int
    let last: Bool
    let size, number: Int
    let sort: Sort
    let numberOfElements: Int
    let first, empty: Bool
}

struct Content: Decodable {
    let id, groupPostId: Int
    let groupPostTitle: String
    let settledById: Int
    let settledByNickname: String?
    let status: Int
    let title, locationName: String
    let meetAt, createdAt, updatedAt: String
}

struct Pageable: Decodable {
    let pageNumber, pageSize: Int
    let sort: Sort
    let offset: Int
    let paged, unpaged: Bool
}

struct Sort: Decodable {
    let sorted, empty, unsorted: Bool
}
