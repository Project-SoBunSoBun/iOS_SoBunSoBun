//
//  SignInModels.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 2/13/26.
//

import Foundation

// MARK: - 로그인
struct AuthResponse: Decodable {
    let success: Bool
    let email: String?
    let nickname: String?
    let profileImageUrl: String?
    let loginToken: String?
    let newUser: Bool?
    let message: String?
    let errorCode: String?
}

struct UserModel: Decodable {
    let success: Bool
    let accessToken: String?
    let refreshToken: String?
    let user: UserInfoModel?
    let accessTokenExpiresAtKst: String?
    let refreshTokenExpiresAtKst: String?
    let message: String?
    let errorCode: String?
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
