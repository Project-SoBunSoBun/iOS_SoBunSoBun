//
//  AuthorizedModel.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/12/25.
//

import Foundation

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
    let id, groupPostID: Int
    let groupPostTitle: String
    let settledByID: Int
    let settledByNickname: String?
    let status: Int
    let title, locationName: String
    let meetAt, createdAt, updatedAt: Date
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
