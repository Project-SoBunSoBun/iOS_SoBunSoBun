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

// MARK: - 홈
struct GeocoderRequestModel: Encodable {
    let service: String = "address"
    let request: String = "getAddress"
    let version: String = "2.0"
    let crs: String = "epsg:4326"
    let format: String = "json"
    let errorformat: String = "json"
    let type: String = "parcel"
    let zipcode: Bool = false
    let simple: Bool = true
    let point: String
    let key: String
}

struct GeocoderResponseModel: Decodable {
    let response: GeocoderResponseInsideModel
}

struct GeocoderResponseInsideModel: Decodable {
    let result: [GeocoderResponseResultModel]
}

struct GeocoderResponseResultModel: Decodable {
    let text: String
    let structure: GeocoderResponseResultStructureModel
}

struct GeocoderResponseResultStructureModel: Decodable {
    let level1, level2, level3: String
}
