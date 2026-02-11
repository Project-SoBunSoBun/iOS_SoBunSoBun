//
//  HomeAPIModels.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/6/26.
//

import Foundation

// MARK: - 피드
struct LocationVerificationModel: Decodable {
    let address, locationVerifiedAt: String?
    let remainingMinutes: Int?
    let verified, expired: Bool
}

struct LocationVerificationBodyModel: Encodable {
    let address: String
}

struct HomeListRequestModel: Encodable {
    let page, size: Int
}

struct HomeListCategoryRequestModel: Encodable {
    let categories: [String]
    let page, size: Int
}

struct RegisterPostBodyModel: Encodable {
    let title, categories, locationName, meetAt, deadlineAt, itemsText, notesText: String
    let minMembers, maxMembers: Int
}

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

// MARK: - 검색
struct SuggestionSearchKeywordsModel: Decodable {
    let suggestions: [String]
    let count: Int
}

struct SearchListRequestModel: Encodable {
    let keyword, sortBy: String
    let page, size: Int
}

// MARK: - 게시글 상세
struct CommentCountModel: Decodable, Equatable {
    let postId, commentCount: Int
}

struct CommentModel: Decodable, Equatable {
    let id, postId, userId: Int
    let userNickname, userProfileImageUrl, userAddress, content: String?
    let createdAt, updatedAt: String
    let deleted, edited: Bool
}

struct ReportPostModel: Encodable {
    let postId: Int
    let reason, description: String
}

struct CreateCommentModel: Encodable {
    let content: String
    let parentCommentId: Int
}

struct ReportCommentModel: Encodable {
    let commentId: Int
    let reason, description: String
}
