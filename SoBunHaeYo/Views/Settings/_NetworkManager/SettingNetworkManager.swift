//
//  SettingNetworkManager.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 2/12/26.
//

import Foundation
import Moya
import RxMoya
import RxSwift
import UIKit

class SettingNetworkManager {
    private let provider = MoyaProvider<MultiTarget>(plugins: [MoyaLoggingPlugin()])
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    // MARK: - 마이페이지
    // 마이페이지 프로필 조회
    func getMeProfile() -> Single<MyProfileModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettingAPIs.getMeProfile))
        
        return request.tryMap(MyProfileModel.self)
    }
    
    // 프로필 이미지 변경
    func patchProfileImage(profileImage: UIImage) -> Single<PlainResponseModel> {
        let imageData = profileImage.jpegData(compressionQuality: 0.7) ?? Data()
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettingAPIs.patchProfileImage(profileImage: imageData)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // 닉네임 변경
    func patchNickname(nickname: String) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettingAPIs.patchNickname(nickname: nickname)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // MARK: - 내 게시글 조회
    // 내 게시글 전체 조회
    func getMyPosts(page: Int, size: Int) -> Single<PostListResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettingAPIs.getMyPosts(page: page, size: size)))
        
        return request.tryMap(PostListResponseModel.self)
    }
    
    // MARK: - 저장 목록
    // 내가 저장한 게시글 조회
    func getSavePosts(page: Int, size: Int) -> Single<PostListResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettingAPIs.getSavedPosts(page: page, size: size)))
        
        return request.tryMap(PostListResponseModel.self)
    }
    
    // MARK: - 공지사항
    // 공지사항 목록 조회
    func getAnnouncements(page: Int, size: Int) -> Single<AnnouncementModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettingAPIs.getAnnouncement(page: page, size: size)))
        
        return request.tryMap(AnnouncementModel.self)
    }
    
    // 공지사항 상세 조회
    func getAnnouncementsDetail(id: Int) -> Single<AnnouncementDetailModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettingAPIs.getAnnouncementDetail(id: id)))
        
        return request.tryMap(AnnouncementDetailModel.self)
    }
    
    // MARK: - 회원 탈퇴
    // 사용자 회원 탈퇴
    func withdraw(reasonCode: String, reasonDetail: String, agreedToTerms: Bool) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettingAPIs.postWithdraw(reasonCode: reasonCode, reasonDetail: reasonDetail, agreedToTerms: agreedToTerms)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // MARK: - 1:1 문의
    // 1:1 문의 전송
    func postInquiries(typeCode: String, content: String, replyEmail: String, selectedImages: [UIImage]?) -> Single<PlainResponseModel> {
        let imageDatas: [Data]? = selectedImages?.compactMap {
            $0.jpegData(compressionQuality: 0.7)
        }
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettingAPIs.postInquiries(typeCode: typeCode, content: content, replyEmail: replyEmail, selectedImages: imageDatas)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // MARK: - 버그 신고하기
    // 버그 신고하기
    func postBugReport(typeCode: String, content: String, deviceInfo: String, selectedImages: [UIImage]?) -> Single<PlainResponseModel> {
        let imageDatas: [Data]? = selectedImages?.compactMap {
            $0.jpegData(compressionQuality: 0.7)
        }
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettingAPIs.postBugReport(typeCode: typeCode, content: content, deviceInfo: deviceInfo, selectedImages: imageDatas)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // MARK: - 약관 조회
    // 약관 조회
    func getTermsDetail(termsType: String) -> Single<TermsResponseModel> {
        let request: Single<Response> = provider.rx.request(MultiTarget(SettingAPIs.getTermsDetail(termsType: termsType)))
        
        return request.tryMap(TermsResponseModel.self)
    }
    
    // MARK: - 차단 목록 조회
    func getBlockList() -> Single<BlockListResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettingAPIs.getBlockList))
        
        return request.tryMap(BlockListResponseModel.self)
    }
}
