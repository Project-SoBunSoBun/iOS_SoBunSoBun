//
//  SettingAPIs.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/12/26.
//

import Foundation
import Moya

enum SettingAPIs {
    // 마이페이지
    case getMeProfile
    case patchProfileImage(profileImage: Data)
    case patchNickname(nickname: String)
    // 공지사항
    case getAnnouncement(page: Int, size: Int)
    case getAnnouncementDetail(id: Int)
    // 탈퇴
    case postWithdraw(reasonCode: String, reasonDetail: String, agreedToTerms: Bool)
    // 1:1 문의
    case postInquiries(typeCode: String, content: String, replyEmail: String, selectedImages: [Data]?)
    // 버그 신고
    case postBugReport(typeCode: String, content: String, deviceInfo: String, selectedImages: [Data]?)
}

extension SettingAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .getMeProfile:
            return "api/me/profile"
            
        case .patchProfileImage:
            return "users/me/profile-image"
            
        case .patchNickname:
            return "users/me/nickname"
            
        case .getAnnouncement:
            return "api/announcements"
            
        case .postWithdraw:
            return "users/me/withdraw"
            
        case .getAnnouncementDetail(let id):
            return "api/announcements/\(id)"
            
        case .postInquiries:
            return "api/support/inquiry"
        
        case .postBugReport:
            return "/api/support/bug-report"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // GET
                .getMeProfile,
                .getAnnouncement,
                .getAnnouncementDetail:
            return .get
            
        case // POST
                .postWithdraw,
                .postInquiries,
                .postBugReport:
            return .post
            
        case // PATCH
                .patchProfileImage,
                .patchNickname:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getMeProfile:
            return .requestPlain
            
        case .patchProfileImage(let profileImage):
            let imageData = profileImage
            var formData: [MultipartFormData] = []
            
            formData.append(MultipartFormData(
                provider: .data(imageData),
                name: "profileImage",
                fileName: "profile.jpg",
                mimeType: "image/jpeg"
            ))
            
            return .uploadMultipart(formData)
            
        case .patchNickname(nickname: let nickname):
            let body: [String: String] = ["nickname": nickname]
            
            return .requestJSONEncodable(body)
            
        case .getAnnouncement(page: let page, size: let size):
            let parameters = AnnouncementRequestModel(page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
            
        case .postWithdraw(let reasonCode, let reasonDetail, let agreedToTerms):
            let model = WithdrawRequestBodyModel(reasonCode: reasonCode, reasonDetail: reasonDetail, agreedToTerms: agreedToTerms)
            
            return .requestJSONEncodable(model)
            
        case .getAnnouncementDetail:
            return .requestPlain
            
        case .postInquiries(let typeCode, let content, let replyEmail, let selectedImages):
            var formData: [MultipartFormData] = []
            
            if let images = selectedImages, !images.isEmpty {
                images.forEach {
                    formData.append(MultipartFormData(
                        provider: .data($0),
                        name: "screenshots",
                        fileName: "",
                        mimeType: "image/jpeg"
                    ))
                }
            } else {
                // 이미지가 없을 때 빈 데이터 전송
                formData.append(MultipartFormData(
                    provider: .data(Data()),
                    name: "screenshots",
                    fileName: "",
                    mimeType: "image/jpeg"
                ))
            }
            
            let urlParameters: [String: Any] = [
                "typeCode": typeCode,
                "content": content,
                "replyEmail": replyEmail
            ]
            
            return .uploadCompositeMultipart(formData, urlParameters: urlParameters)
            
        case .postBugReport(let typeCode, let content, let deviceInfo, let selectedImages):
            var formData: [MultipartFormData] = []
            
            if let images = selectedImages, !images.isEmpty {
                images.forEach {
                    formData.append(MultipartFormData(
                        provider: .data($0),
                        name: "screenshots",
                        fileName: "",
                        mimeType: "image/jpeg"
                    ))
                }
            } else {
                // 이미지가 없을 때 빈 데이터 전송
                formData.append(MultipartFormData(
                    provider: .data(Data()),
                    name: "screenshots",
                    fileName: "",
                    mimeType: "image/jpeg"
                ))
            }
            
            let urlParameters: [String: Any] = [
                "typeCode": typeCode,
                "content": content,
                "deviceInfo": deviceInfo
            ]
            
            return .uploadCompositeMultipart(formData, urlParameters: urlParameters)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .patchProfileImage,
                .postInquiries,
                .postBugReport:
            return ["Content-Type": "multipart/form-data"]
            
        default:
            return [:]
        }
    }
}
