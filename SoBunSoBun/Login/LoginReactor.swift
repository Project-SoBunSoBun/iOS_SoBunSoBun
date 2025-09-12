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
    }
    
    enum Mutation {
        case loginSuccess // 로그인 성공했을 때
        case loginFailed(String) // 로그인에 실패했을 때
    }
    
    struct State {
        @Pulse var loginCompleted: Void?
        @Pulse var loginErrorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .kakaoButtonTapped:
            var status = Observable<Mutation>.empty()
            
            // 카카오 로그인을 통해 OAuthToken 발급받기
            kakaoLoginAction()
                .subscribe(onNext: { oauthToken in
                    let accessToken = oauthToken.accessToken
                    print("KakaoToken : \(accessToken)")
                    // status = Observable.just(.loginSuccess)
                }, onError: { _ in
                    status = Observable.just(.loginFailed(String(localized: "KakaoLoginFailed")))
                }).disposed(by: disposeBag)
            
            return status
        case .appleButtonTapped:
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loginSuccess:
            newState.loginCompleted = Void()
        case .loginFailed(let message):
            newState.loginErrorMessage = message
        }
        
        return newState
    }
}

extension LoginReactor {
    func kakaoLoginAction() -> Observable<OAuthToken> {
        let loginObservable: Observable<OAuthToken>
        
        // KakaoTalk 앱을 통한 로그인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            loginObservable = UserApi.shared.rx.loginWithKakaoTalk()
        } else { // KakaoTalk 앱이 없을 때 웹으로 로그인
            loginObservable = UserApi.shared.rx.loginWithKakaoAccount()
        }
        
        return loginObservable
    }
}
