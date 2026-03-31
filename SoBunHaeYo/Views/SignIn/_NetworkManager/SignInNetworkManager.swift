//
//  SignInNetworkManager.swift
//  SoBunHaeYo
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
        let request: Single<Response> = provider.rx.request(MultiTarget(SignInAPIs.authLoginKakao(accessToken: accessToken)))
        
        return request.tryMap(AuthResponse.self)
    }
    
    // 애플 로그인
    func fethAuthLoginApple(code: String, idToken: String) -> Single<AuthResponse> {
        let request: Single<Response> = provider.rx.request(MultiTarget(SignInAPIs.authLoginApple(code: code, idToken: idToken)))
        
        return request.tryMap(AuthResponse.self)
    }
    
    // 애플 계정 연결 해제
    func fetchAuthRevokeApple() -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SignInAPIs.authRevokeApple))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // 서버에서 임시 토큰을 통해 사용자 정보를 가져오는 메서드
    func fetchAuthCompleteSignUp(loginToken: String, serviceTermsAgreed: Bool, privacyPolicyAgreed: Bool, marketingOptionalAgreed: Bool) -> Single<UserModel> {
        let request: Single<Response> = provider.rx.request(MultiTarget(SignInAPIs.authCompleteSignUp(loginToken: loginToken, serviceTermsAgreed: serviceTermsAgreed, privacyPolicyAgreed: privacyPolicyAgreed, marketingOptionalAgreed: marketingOptionalAgreed)))
        
        return request.tryMap(UserModel.self)
    }
    
    // 서버에서 닉네임 중복 여부를 확인하는 메서드
    func checkNickname(nickname: String) -> Single<CheckNicknameModel> {
        let request: Single<Response> = provider.rx.request(MultiTarget(SignInAPIs.checkNickname(nickname: nickname)))
        
        return request.tryMap(CheckNicknameModel.self)
    }
    
    // MARK: - 닉네임 설정
    // 서버에 닉네임과 프로필 이미지를 저장하는 메서드
    func saveProfile(nickname: String, profileImage: UIImage?) -> Single<PlainResponseModel> {
        let imageData = profileImage?.jpegData(compressionQuality: 0.7)
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SignInAPIs.saveProfile(nickname: nickname, profileImage: imageData)))
        
        return request.tryMap(PlainResponseModel.self)
    }
}
