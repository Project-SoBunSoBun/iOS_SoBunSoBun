//
//  SignInAPIModels.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 2/13/26.
//

import Foundation

// MARK: - 로그인
struct AuthResponse: Decodable {
    let success: Bool
    let email, nickname, profileImageUrl, loginToken: String?
    let newUser: Bool?
    let message, errorCode: String?
}

struct UserModel: Decodable {
    let success: Bool
    let accessToken, refreshToken, accessTokenExpiresAtKst, refreshTokenExpiresAtKst: String?
    let user: UserInfoModel?
    let message, errorCode: String?
}

struct CheckNicknameModel: Decodable {
    let nickname: String
    let available: Bool
}

struct AuthKakaoTokenModel: Encodable {
    let accessToken: String
}

struct LoginTokenModel: Encodable {
    let loginToken: String
    let serviceTermsAgreed: Bool
    let privacyPolicyAgreed: Bool
    let marketingOptionalAgreed: Bool
}

struct AuthAppleTokenModel: Encodable {
    let code: String
    let idToken: String
}
