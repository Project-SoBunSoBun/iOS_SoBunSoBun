//
//  SettingAPIModels.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/12/26.
//

import Foundation

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

// MARK: - 공지사항
struct AnnouncementRequestModel: Encodable {
    let page: Int
    let size: Int
}

struct AnnouncementModel: Decodable {
    let success: Bool
    let data: AnnouncementDataModel
    let error: ErrorModel?
}

struct AnnouncementDataModel: Decodable {
    let content: [AnnouncementContentModel]
    let page: PageModel
}

struct AnnouncementContentModel: Decodable, Equatable {
    let id: Int
    let title, category: String
    let isPinned: Bool
    let createdAt: String
}

struct PageModel: Decodable {
    let number, size, totalElements, totalPages: Int
    let first, last, hasNext, hasPrevious: Bool
}

// MARK: - 탈퇴
struct WithdrawRequestBodyModel: Encodable {
    let reasonCode: String
    let reasonDetail: String
    let agreedToTerms: Bool
}
