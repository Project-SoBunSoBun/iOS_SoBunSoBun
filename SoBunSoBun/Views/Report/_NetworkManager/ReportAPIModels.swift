//
//  ReportAPIModels.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/23/26.
//

import Foundation

struct ReportPostRequestBodyModel: Encodable {
    let postId: Int
    let reason, description: String
}

struct ReportPostCommentRequestBodyModel: Encodable {
    let commentId: Int
    let reason, description: String
}

struct ReportUserRequestBodyModel: Encodable {
    let groupPostId: Int
    let reason: String
    let description: String
}
