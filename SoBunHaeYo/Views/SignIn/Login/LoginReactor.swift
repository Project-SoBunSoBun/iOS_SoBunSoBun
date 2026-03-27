//
//  LoginReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 9/4/25.
//

import ReactorKit
import Foundation
import RxSwift
import RxKakaoSDKUser
import KakaoSDKUser
import KakaoSDKAuth
import OSLog

class LoginReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "SignIn.Login.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    
    private let networkManager = SignInNetworkManager()
    private let appleLoginManager = AppleLoginManager()
    
    let initialState = State()
    
    enum Action {
        case appleButtonTapped // 애플 로그인 버튼을 클릭했을 때
        case kakaoButtonTapped // 카카오 로그인 버튼을 클릭했을 때
        case completeLoginAndNavigateToHome // 로그인 후 홈으로 이동
    }
    
    enum Mutation {
        case loginSuccess(isNewUser: Bool) // 로그인 성공했을 때
        case loginFailed(String) // 로그인에 실패했을 때
        case loginAndNavigateToHomeSuccess(isSaved: Bool) // 로그인 후 홈으로 이동 성공
        case loginAndNavigateToHomeFailed(String) // 로그인 후 홈으로 이동 실패
    }
    
    struct State {
        @Pulse var loginCompleted: Bool?
        @Pulse var errorMessage: String?
        @Pulse var shouldNavigateToHome: Bool?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .kakaoButtonTapped:
            // 카카오 로그인을 통해 OAuthToken 발급받기
            return kakaoLoginAction()
                .flatMap { oauthToken in
                    let accessToken = oauthToken.accessToken
                    // 로그인 타입 저장
                    KeyChain.shared.set(key: "LOGIN_TYPE", value: "KAKAO")
                    
                    return self.networkManager.fetchAuthLoginKakao(accessToken: accessToken)
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
            return appleLoginManager.appleLogin()
                .flatMap { authInfo in
                    // 테스트 후 삭제하기
                    self.logger.debug("애플 code: \(authInfo.authorizationCode)")
                    self.logger.debug("애플 token: \(authInfo.identityToken)")
                    self.logger.debug("애플 userID: \(authInfo.userIdentifier)")
                    // userID 저장
                    KeyChain.shared.set(key: "APPLE_USER_ID", value: authInfo.userIdentifier)
                    // 로그인 타입 저장
                    KeyChain.shared.set(key: "LOGIN_TYPE", value: "APPLE")
                    
                    return self.networkManager.fethAuthLoginApple(code: authInfo.authorizationCode, idToken: authInfo.identityToken)
                        .asObservable()
                        .map { AppleAuthResponse in
                            // 임시 토큰 저장
                            KeyChain.shared.set(key: "LOGIN_TOKEN", value: AppleAuthResponse.loginToken)
                            
                            return Mutation.loginSuccess(isNewUser: AppleAuthResponse.newUser)
                        }
                }
                .catch { error  in
                    Observable.just(.loginFailed("AppleLoginFailed"))
                }
            
        case .completeLoginAndNavigateToHome:
            return saveToken()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loginSuccess(let isNewUser):
            newState.loginCompleted = isNewUser
            
        case .loginFailed(let message):
            newState.errorMessage = message
            
        case .loginAndNavigateToHomeSuccess(let isSaved):
            newState.shouldNavigateToHome = isSaved
            
        case .loginAndNavigateToHomeFailed(let message):
            newState.errorMessage = message
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
            return Observable.just(.loginAndNavigateToHomeFailed("로그인 토큰이 없습니다"))
        }
        
        return networkManager.fetchAuthCompleteSignUp(
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
            return Mutation.loginAndNavigateToHomeSuccess(isSaved: true)
        }
        .catch { error in
            return Observable.just(.loginAndNavigateToHomeFailed("토큰 저장 실패"))
        }
    }
}
