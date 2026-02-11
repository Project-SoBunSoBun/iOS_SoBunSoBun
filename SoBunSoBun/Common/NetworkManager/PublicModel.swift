//
//  PublicModel.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/21/25.
//

import Foundation

// TODO: 파일 분할 필요

// MARK: - 로그인
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
