//
//  ProfileAPIModels.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/15/26.
//

import Foundation

struct ProfileUserInfoResponseModel: Decodable {
    let success: Bool
    let data: ProfileUserInfoResponseDataModel?
    let message: String?
}

struct ProfileUserInfoResponseDataModel: Decodable, Equatable {
    let userId: Int
    let nickname: String?
    let profileImageUrl: String?
    let activityScore: Int
    let hostCount: Int
    let participationCount: Int
    let mannerTags: [MannerTagModel]?
    var isBlocked: Bool
    let posts: PostListResponseModel
}
