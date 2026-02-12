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
    
    // MARK: - 회원 탈퇴
    // 사용자 회원 탈퇴
    func withdraw(reasonCode: String, reasonDetail: String, agreedToTerms: Bool) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(SettingAPIs.postWithdraw(reasonCode: reasonCode, reasonDetail: reasonDetail, agreedToTerms: agreedToTerms))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
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
}
