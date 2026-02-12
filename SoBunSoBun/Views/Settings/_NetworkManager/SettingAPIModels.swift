//
//  SettingAPIModels.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/12/26.
//

import Foundation

// MARK: - 탈퇴
struct WithdrawRequestBodyModel: Encodable {
    let reasonCode: String
    let reasonDetail: String
    let agreedToTerms: Bool
}

// MARK: - 마이페이지
struct MyProfileModel: Decodable {
    let success: Bool
    let data: MyProfileDataModel
    let error: ErrorModel?
}

struct MyProfileDataModel: Decodable, Equatable {
    let userId: Int
    let nickname, profileImageUrl: String?
    let mannerScore: Float16
    let participationCount, hostCount: Int
    let mannerTags: [MannerTagModel]?
}

struct MannerTagModel: Decodable, Equatable {
    let tagId: Int
    let count: Int
}
