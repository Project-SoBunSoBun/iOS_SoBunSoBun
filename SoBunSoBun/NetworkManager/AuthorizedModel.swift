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
