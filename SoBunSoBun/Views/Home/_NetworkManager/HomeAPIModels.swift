//
//  HomeAPIModels.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/6/26.
//

import Foundation

// MARK: - 피드

// MARK: - 검색

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
