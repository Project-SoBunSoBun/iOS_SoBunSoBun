//
//  SignUpReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/19/25.
//

import UIKit
import ReactorKit

class SignUpReactor: Reactor {
    
    let initialState = State()
    private let disposeBag = DisposeBag()
    
    enum Action {
        case backButtonTapped // 뒤로가기 버튼 클릭
        case allAgreeToggled // 모두 동의 체크
        case termsToggled(String) // 개별 약관
        case detailButtonTapped(String) // 약관 상세보기
        case nextButtonTapped // 다음 버튼 클릭
        case locationPermisstionGranted // 위치 권한 승인
        case locationPermisstionDenied // 위치 권한 미승인
    }
    
    enum Mutation {
        case setBackButtonTapped
        case setAllAgree(Bool)
        case setTermsCheck(String, Bool)
        case setTermsDetail(String)
        case setSignUpSuccess // 로그인 성공
        case setSignUpFailed(String) // 로그인 실패
        case setRequestLocationPermission
        case setShowLocationSettingAlert
    }
    
    struct State {
        @Pulse var shouldPopViewController: Void?
        @Pulse var shouldTermsDetail: String?
        @Pulse var signUpCompleted: Bool = false
        @Pulse var signUpErrorMessage: String?
        @Pulse var shouldRequestLocationPermission: Bool = false
        @Pulse var shouldShowLocationSettingAlert: Bool = false
        
        var allAgreed: Bool = false
        var termsChecked: [String: Bool] = [
            "all": false,
            "service": false,
            "privacy": false,
            "location": false
        ]
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .backButtonTapped:
            return Observable.just(.setBackButtonTapped)
        case .allAgreeToggled:
            let newValue = !currentState.allAgreed
            return Observable.concat([
                Observable.just(Mutation.setAllAgree(newValue)),
                Observable.just(Mutation.setTermsCheck("service", newValue)),
                Observable.just(Mutation.setTermsCheck("privacy", newValue)),
                Observable.just(Mutation.setTermsCheck("location", newValue))
            ])
        case .termsToggled(let id):
            let newValue = !(currentState.termsChecked[id] ?? false)
            return Observable.just(Mutation.setTermsCheck(id, newValue))
        case .detailButtonTapped(let id):
            return Observable.just(Mutation.setTermsDetail(id))
        case .nextButtonTapped:
            // 위치 권한 상태 확인
            let authStatus = LocationManager.shared.getCurrentAuthorizationStatus()
            
            switch authStatus {
            case .notDetermined:
                // 아직 권한을 요청하지 않음 -> 권한 요청
                return Observable.just(.setRequestLocationPermission)
            case .denied, .restricted:
                // 권한 거부됨 -> 설정 알러트
                return Observable.just(.setShowLocationSettingAlert)
            case .authorizedWhenInUse, .authorizedAlways:
                // 권한 허용됨 -> 회원 가입 진행
                return performSignUp()
            default:
                return Observable.just(.setShowLocationSettingAlert)
            }
        case .locationPermisstionGranted:
            return performSignUp()
        case .locationPermisstionDenied:
            return Observable.just(.setShowLocationSettingAlert)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setBackButtonTapped:
            newState.shouldPopViewController = ()
        case .setAllAgree(let agreed):
            newState.allAgreed = agreed
        case .setTermsCheck(let id, let checked):
            newState.termsChecked[id] = checked
            let requiredTerms = ["service", "privacy", "location"]
            let allChecked = requiredTerms.allSatisfy { newState.termsChecked[$0] == true }
            newState.allAgreed = allChecked
        case .setTermsDetail(let id):
            newState.shouldTermsDetail = id
        case .setSignUpSuccess:
            newState.signUpCompleted = true
        case .setSignUpFailed(let message):
            newState.signUpErrorMessage = message
        case .setRequestLocationPermission:
            newState.shouldRequestLocationPermission = true
        case .setShowLocationSettingAlert:
            newState.shouldShowLocationSettingAlert = true
        }
        return newState
    }
    
    private func performSignUp() -> Observable<Mutation> {
        guard let loginToken = KeyChain.shared.get(key: "LOGIN_TOKEN") else {
            return Observable.just(.setSignUpFailed("로그인 토큰이 없습니다"))
        }
        
        let serviceTermsAgreed = currentState.termsChecked["service"] ?? false
        let privacyPolicyAgreed = currentState.termsChecked["privacy"] ?? false
        
        return NetworkManager.shared.fetchAuthCompleteSignUp(
            loginToken: loginToken,
            serviceTermsAgreed: serviceTermsAgreed,
            privacyPolicyAgreed: privacyPolicyAgreed,
            marketingOptionalAgreed: false
        )
        .asObservable()
        .map { userModel in
            KeyChain.shared.set(key: "ACCESS_TOKEN", value: userModel.accessToken)
            KeyChain.shared.set(key: "REFRESH_TOKEN", value: userModel.refreshToken)
            KeyChain.shared.set(key: "ACCESS_TOKEN_EXPIRE_AT_KST", value: String(userModel.accessTokenExpiresAtKst))
            KeyChain.shared.set(key: "REFRESH_TOKEN_EXPIRE_AT_KST", value: String(userModel.refreshTokenExpiresAtKst))
            return Mutation.setSignUpSuccess
        }
        .catch { error in
            return Observable.just(.setSignUpFailed("회원가입 실패"))
        }
    }
}
