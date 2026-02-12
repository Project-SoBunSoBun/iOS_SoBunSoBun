//
//  NetworkManager.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/12/25.
//

import Foundation
import Moya
import RxMoya
import RxSwift
import UIKit
import OSLog

// TODO: 파일 분할 필요
final class NetworkManager {
    // 분리 작업 이후 더 이상 싱글톤 패턴으로 유지할 이유가 없어 보일 것 같습니다.
    static let shared = NetworkManager()
    
    private init() {}
    
    // Public API 전용
    private let provider = MoyaProvider<MultiTarget>(plugins: [MoyaLoggingPlugin()])
    // Authorized API 전용
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    // MARK: - 로그인
    // 서버에서 카카오 토큰을 통해 임시 토큰을 가져오는 메서드
    func fetchAuthLoginKakao(accessToken: String) -> Single<KakaoAuthResponse> {
        return provider.rx.request(
            MultiTarget(PublicAPI.authLoginKakao(accessToken: accessToken))
        )
        .filterSuccessfulStatusCodes()
        .map(KakaoAuthResponse.self)
    }
    
    // 서버에서 임시 토큰을 통해 사용자 정보를 가져오는 메서드
    func fetchAuthCompleteSignUp(loginToken: String, serviceTermsAgreed: Bool, privacyPolicyAgreed: Bool, marketingOptionalAgreed: Bool) -> Single<UserModel> {
        return provider.rx.request(
            MultiTarget(PublicAPI.authCompleteSignUp(loginToken: loginToken, serviceTermsAgreed: serviceTermsAgreed, privacyPolicyAgreed: privacyPolicyAgreed, marketingOptionalAgreed: marketingOptionalAgreed))
        )
        .filterSuccessfulStatusCodes()
        .map(UserModel.self)
    }
    
    // 서버에서 닉네임 중복 여부를 확인하는 메서드
    func checkNickname(nickname: String) -> Single<CheckNicknameModel> {
        return provider.rx.request(
            MultiTarget(PublicAPI.checkNickname(nickname: nickname))
        )
        .filterSuccessfulStatusCodes()
        .map(CheckNicknameModel.self)
    }
    
    // 서버에 닉네임과 프로필 이미지를 저장하는 메서드
    func saveProfile(nickname: String, profileImage: UIImage?) -> Single<Void> {
        let imageData = profileImage?.jpegData(compressionQuality: 0.7)
        
        return authProvider.rx.request(
            MultiTarget(AuthorizedAPI.saveProfile(nickname: nickname, profileImage: imageData))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // 서버에 유저 정보를 받아오는 메서드
    func myProfile() -> Single<UserInfoModel> {
        return authProvider.rx.request(
            MultiTarget(AuthorizedAPI.me)
        )
        .filterSuccessfulStatusCodes()
        .map(UserInfoModel.self)
    }
    
    // MARK: - 정산
    // 서버에서 유저별 정산 목록을 받아오는 메서드
    func mySettleUps(activeOnly: Int, page: Int, size: Int) -> Single<SettleUpModel> {
        return authProvider.rx.request(
            MultiTarget(AuthorizedAPI.mySettleUps(activeOnly: activeOnly, page: page, size: size))
        )
        .filterSuccessfulStatusCodes()
        .map(SettleUpModel.self)
    }
    
    // 정산 삭제 메서드
    func deleteSettleUp(id: Int) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(AuthorizedAPI.deleteSettleUp(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
}
