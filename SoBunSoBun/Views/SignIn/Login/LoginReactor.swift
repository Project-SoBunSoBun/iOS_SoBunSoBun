//
//  LoginReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/4/25.
//

import ReactorKit
import Foundation
import RxSwift
import RxKakaoSDKUser
import KakaoSDKUser
import KakaoSDKAuth

class LoginReactor: Reactor {
    private let disposeBag = DisposeBag()
    
    let initialState = State()
    
    enum Action {
        case appleButtonTapped // 애플 로그인 버튼을 클릭했을 때
        case kakaoButtonTapped // 카카오 로그인 버튼을 클릭했을 때
        case saveToken // 카카오 로그인 성공 시 토큰 저장하기
    }
    
    enum Mutation {
        case loginSuccess(isNewUser: Bool) // 로그인 성공했을 때
        case loginFailed(String) // 로그인에 실패했을 때
        case saveSuccess(isSaved: Bool) // 키체인에 저장 성공했을 때
        case saveFailed(String)
    }
    
    struct State {
        @Pulse var loginCompleted: Bool?
        @Pulse var loginErrorMessage: String?
        @Pulse var saveSuccess: Bool?
        @Pulse var saveFailedMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .kakaoButtonTapped:
            // 카카오 로그인을 통해 OAuthToken 발급받기
            return kakaoLoginAction()
                .flatMap { oauthToken in
                    let accessToken = oauthToken.accessToken
                    return NetworkManager.shared.fetchAuthLoginKakao(accessToken: accessToken)
                        .asObservable()
                        .map { kakaoAuthResponse in
                            // 임시 토큰 저장
                            KeyChain.shared.set(key: "LOGIN_TOKEN", value: kakaoAuthResponse.loginToken)
                            return Mutation.loginSuccess(isNewUser: kakaoAuthResponse.newUser)
                        }
                        .catch { error in
                            Observable.just(Mutation.loginFailed("ServerConnectFailed"))
                        }
                }
                .catch { error in
                    Observable.just(Mutation.loginFailed("KakaoLoginFailed"))
                }
        case .appleButtonTapped:
            return Observable.empty()
        case .saveToken:
            return saveToken()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loginSuccess(let isNewUser):
            newState.loginCompleted = isNewUser
        case .loginFailed(let message):
            newState.loginErrorMessage = message
        case .saveSuccess(let isSaved):
            newState.saveSuccess = isSaved
        case .saveFailed(let message):
            newState.saveFailedMessage = message
        }
        
        return newState
    }
}

extension LoginReactor {
    private func kakaoLoginAction() -> Observable<OAuthToken> {
        let loginObservable: Observable<OAuthToken>
        
        // KakaoTalk 앱을 통한 로그인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            loginObservable = UserApi.shared.rx.loginWithKakaoTalk()
        } else { // KakaoTalk 앱이 없을 때 웹으로 로그인
            loginObservable = UserApi.shared.rx.loginWithKakaoAccount()
        }
        
        return loginObservable
    }
    
    private func saveToken() -> Observable<Mutation> {
        guard let loginToken = KeyChain.shared.get(key: "LOGIN_TOKEN") else {
            return Observable.just(.saveFailed("로그인 토큰이 없습니다"))
        }
        
        return NetworkManager.shared.fetchAuthCompleteSignUp(
            loginToken: loginToken,
            serviceTermsAgreed: true,
            privacyPolicyAgreed: true,
            marketingOptionalAgreed: false
        )
        .asObservable()
        .map { userModel in
            KeyChain.shared.set(key: "ACCESS_TOKEN", value: userModel.accessToken)
            KeyChain.shared.set(key: "REFRESH_TOKEN", value: userModel.refreshToken)
            KeyChain.shared.set(key: "ACCESS_TOKEN_EXPIRE_AT_KST", value: String(userModel.accessTokenExpiresAtKst))
            KeyChain.shared.set(key: "REFRESH_TOKEN_EXPIRE_AT_KST", value: String(userModel.refreshTokenExpiresAtKst))
            return Mutation.saveSuccess(isSaved: true)
        }
        .catch { error in
            return Observable.just(.saveFailed("토큰 저장 실패"))
        }
    }
}
