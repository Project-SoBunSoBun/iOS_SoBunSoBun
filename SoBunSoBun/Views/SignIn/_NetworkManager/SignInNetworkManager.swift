//
//  SignInNetworkManager.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/13/26.
//

import Foundation
import Moya
import RxMoya
import RxSwift
import UIKit

class SignInNetworkManager {
    private let provider = MoyaProvider<MultiTarget>(plugins: [MoyaLoggingPlugin()])
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    // MARK: - 로그인
    // 서버에서 카카오 토큰을 통해 임시 토큰을 가져오는 메서드
    func fetchAuthLoginKakao(accessToken: String) -> Single<AuthResponse> {
        return provider.rx.request(
            MultiTarget(SignInAPIs.authLoginKakao(accessToken: accessToken))
        )
        .filterSuccessfulStatusCodes()
        .map(AuthResponse.self)
    }
    
    // 애플 로그인
    func fethAuthLoginApple(code: String, idToken: String) -> Single<AuthResponse> {
        return provider.rx.request(
            MultiTarget(SignInAPIs.authLoginApple(code: code, idToken: idToken))
        )
        .filterSuccessfulStatusCodes()
        .map(AuthResponse.self)
    }
    
    // 애플 계정 연결 해제
    func fetchAuthRevokeApple() -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(SignInAPIs.authRevokeApple)
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // 서버에서 임시 토큰을 통해 사용자 정보를 가져오는 메서드
    func fetchAuthCompleteSignUp(loginToken: String, serviceTermsAgreed: Bool, privacyPolicyAgreed: Bool, marketingOptionalAgreed: Bool) -> Single<UserModel> {
        return provider.rx.request(
            MultiTarget(SignInAPIs.authCompleteSignUp(loginToken: loginToken, serviceTermsAgreed: serviceTermsAgreed, privacyPolicyAgreed: privacyPolicyAgreed, marketingOptionalAgreed: marketingOptionalAgreed))
        )
        .filterSuccessfulStatusCodes()
        .map(UserModel.self)
    }
    
    // 서버에서 닉네임 중복 여부를 확인하는 메서드
    func checkNickname(nickname: String) -> Single<CheckNicknameModel> {
        return provider.rx.request(
            MultiTarget(SignInAPIs.checkNickname(nickname: nickname))
        )
        .filterSuccessfulStatusCodes()
        .map(CheckNicknameModel.self)
    }
    
    // MARK: - 닉네임 설정
    // 서버에 닉네임과 프로필 이미지를 저장하는 메서드
    func saveProfile(nickname: String, profileImage: UIImage?) -> Single<Void> {
        let imageData = profileImage?.jpegData(compressionQuality: 0.7)
        
        return authProvider.rx.request(
            MultiTarget(SignInAPIs.saveProfile(nickname: nickname, profileImage: imageData))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
}
