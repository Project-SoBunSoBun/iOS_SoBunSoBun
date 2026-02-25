//
//  SettingNetworkManager.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/12/26.
//

import Foundation
import Moya
import RxMoya
import RxSwift
import UIKit

class SettingNetworkManager {
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    // MARK: - 마이페이지
    // 마이페이지 프로필 조회
    func getMeProfile() -> Single<MyProfileModel> {
        return authProvider.rx.request(
            MultiTarget(SettingAPIs.getMeProfile)
        )
        .filterSuccessfulStatusCodes()
        .map(MyProfileModel.self)
    }
    
    // 프로필 이미지 변경
    func patchProfileImage(profileImage: UIImage) -> Single<Void> {
        let imageData = profileImage.jpegData(compressionQuality: 0.7) ?? Data()
            
        return authProvider.rx.request(
            MultiTarget(SettingAPIs.patchProfileImage(profileImage: imageData))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // 닉네임 변경
    func patchNickname(nickname:String) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(SettingAPIs.patchNickname(nickname: nickname))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // MARK: - 공지사항
    // 공지사항 목록 조회
    func getAnnouncements(page: Int, size: Int) -> Single<AnnouncementModel> {
        return authProvider.rx.request(
            MultiTarget(SettingAPIs.getAnnouncement(page: page, size: size))
        )
        .filterSuccessfulStatusCodes()
        .map(AnnouncementModel.self)
    }
    
    // 공지사항 상세 조회
    func getAnnouncementsDetail(id: Int) -> Single<AnnouncementDetailModel> {
        return authProvider.rx.request(
            MultiTarget(SettingAPIs.getAnnouncementDetail(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map(AnnouncementDetailModel.self)
    }
    
    // MARK: - 회원 탈퇴
    // 사용자 회원 탈퇴
    func withdraw(reasonCode: String, reasonDetail: String, agreedToTerms: Bool) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(SettingAPIs.postWithdraw(reasonCode: reasonCode, reasonDetail: reasonDetail, agreedToTerms: agreedToTerms))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // MARK: - 1:1 문의
    // 1:1 문의 전송
    func postInquiries(typeCode: String, content: String, replyEmail: String, selectedImages: [UIImage]?) -> Single<Void> {
        let imageDatas: [Data]? = selectedImages?.compactMap {
            $0.jpegData(compressionQuality: 0.7)
        }

        return authProvider.rx.request(
            MultiTarget(SettingAPIs.postInquiries(typeCode: typeCode, content: content, replyEmail: replyEmail, selectedImages: imageDatas))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // MARK: - 버그 신고하기
    // 버그 신고하기
    func postBugReport(typeCode: String, content: String, deviceInfo: String, selectedImages: [UIImage]?) -> Single<Void> {
        let imageDatas: [Data]? = selectedImages?.compactMap {
            $0.jpegData(compressionQuality: 0.7)
        }
        
        return authProvider.rx.request(
            MultiTarget(SettingAPIs.postBugReport(typeCode: typeCode, content: content, deviceInfo: deviceInfo, selectedImages: imageDatas))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
}
