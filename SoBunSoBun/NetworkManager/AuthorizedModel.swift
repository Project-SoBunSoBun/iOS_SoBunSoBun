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
    let accessTokenExpiresAt: Int
    let refreshTokenExpiresAt: Int
}

struct UserInfoModel: Decodable {
    let id: Int
    let email: String
    let nickname: String?
    let profileImageUrl: String?
    let role: String
}
