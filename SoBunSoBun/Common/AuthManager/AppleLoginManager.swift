//
//  AppleLoginManager.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/26/26.
//

import Foundation
import AuthenticationServices
import RxSwift

struct AppleAuthInfo {
    let identityToken: String
    let authorizationCode: String
    let userIdentifier: String
}

final class AppleLoginManager: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let loginSubject = PublishSubject<AppleAuthInfo>()
    
    func appleLogin() -> Observable<AppleAuthInfo> {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        return loginSubject.asObservable()
    }
    
    // 성공 시 호출
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityTokenData = appleIDCredential.identityToken,
           let authorizationCodeData = appleIDCredential.authorizationCode,
           let identityToken = String(data: identityTokenData, encoding: .utf8),
           let authorizationCode = String(data: authorizationCodeData, encoding: .utf8) {
            let userIdentifier = appleIDCredential.user
            
            let authInfo = AppleAuthInfo(
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                userIdentifier: userIdentifier
            )
            
            loginSubject.onNext(authInfo)
        }
    }
    
    // 실패 시 호출
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        loginSubject.onError(error)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scene = UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
        
        return scene?.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
    
    // 애플 연결 상태 체크
    func checkAppleIDCredentialState(userID: String) -> Observable<ASAuthorizationAppleIDProvider.CredentialState> {
        return Observable.create { observer in
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            
            appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
                if let error = error {
                    observer.onError(error)
                    
                    return
                }
                observer.onNext(credentialState)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
