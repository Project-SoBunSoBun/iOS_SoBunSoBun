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
    let id, minMembers, maxMembers, joinedMembers: Int
    let owner: PostOwnerModel
    let title, categoryCode, itemsText, notesText, locationName, meetAt, deadlineAt, status, createdAt, updatedAt: String
    let content: String?
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

struct RegisterPostBodyModel: Encodable {
    let title, categories, locationName, meetAt, deadlineAt, itemsText, notesText: String
    let minMembers, maxMembers: Int
}

// MARK: - 검색
struct SuggestionSearchKeywordsModel: Decodable {
    let suggestions: [String]
    let count: Int
}

struct SearchListRequestModel: Encodable {
    let keyword, sortBy: String
    let page, size: Int
}

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
    let settledById: Int
    let settledByNickname: String?
    let status: Int
    let title, locationName: String
    let meetAt, createdAt, updatedAt: String
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
    let activeOnly, page, size: Int
}

// MARK: - 마이페이지
struct MyProfileModel: Decodable {
    let success: Bool
    let data: DataClass
    let error: Error
}

struct DataClass: Decodable {
    let userID: Int
    let nickname, profileImageUrl: String
    let mannerScore, participationCount, hostCount: Int
    let mannerTags: [MannerTag]
}

struct MannerTag: Decodable {
    let tagID: Int
    let tagName, tagEmoji: String
    let count: Int
}

struct Error: Decodable {
    let code, message: String
}
