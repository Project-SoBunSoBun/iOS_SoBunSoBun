//
//  AuthInterceptor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/24/25.
//

import Foundation
import Alamofire
import RxSwift
import OSLog

final class AuthInterceptor: RequestInterceptor {
    nonisolated(unsafe) private let disposeBag = DisposeBag()
    nonisolated(unsafe) var isRefreshing: Bool = false
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "AuthInterceptor"
    )
    
    static let shared = AuthInterceptor()
    
    private init() {}
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        // 저장된 액세스 토큰 가져오기
        guard let accessToken = KeyChain.shared.get(key: "ACCESS_TOKEN") else {
            AuthManager.shared.removeTokens()
            AuthManager.shared.switchToLoginView()
            
            logger.debug("ACCESS_TOKEN이 Keychain에 존재하지 않습니다.")
            logger.fault("API 요청 중 오류가 발생했습니다. 요청을 중단하고 로그아웃 처리됩니다.")
            
            completion(.failure(NSError(domain: "SobunHaeyo", code: -1, userInfo: [NSLocalizedDescriptionKey: "액세스 토큰이 없습니다."])))
            
            return
        }
        
        // 헤더에 accessToken을 담아서 전달
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: accessToken))
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        logger.debug("retry 진입")
        
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            logger.debug("401 오류가 아님")
            completion(.doNotRetryWithError(error))
            
            return
        }
        
        guard let refreshTokenExpireAtKST = KeyChain.shared.get(key: "REFRESH_TOKEN_EXPIRE_AT_KST") else {
            AuthManager.shared.logout()
            completion(.doNotRetry)
            logger.fault("리프레시 토큰 만료 시간 정보 없음")
            
            return
        }
        
        let now = Date()
        
        guard let dateRefreshTokenExpireAtKST = ISO8601ToDate(refreshTokenExpireAtKST) else {
            AuthManager.shared.logout()
            completion(.doNotRetry)
            logger.fault("리프레시 토큰 만료 시간 ISO8601ToDate 형태 변환 실패")
            
            return
        }
        
        let isRefreshExpired = dateRefreshTokenExpireAtKST < now
        
        // 현재 시간과 refreshToken의 만료 시간을 비교
        if isRefreshExpired {
            AuthManager.shared.logout()
            completion(.doNotRetry)
            logger.debug("리프레시 토큰 만료")
            
            return
        }
        
        if isRefreshing {
            logger.debug("이미 재발급 중")
            completion(.retry)
        } else {
            isRefreshing = true
            
            refreshAccessToken() { [weak self] isSuccess in
                guard let self = self else {
                    completion(.doNotRetry)
                    return
                }
                
                isRefreshing = false
                
                if isSuccess {
                    completion(.retry)
                    logger.debug("액세스 토큰 재발급 완료")
                } else {
                    AuthManager.shared.logout()
                    completion(.doNotRetry)
                    
                    logger.debug("리프레시 토큰 만료")
                }
            }
        }
    }
    
    // 리프레시 토큰을 사용하여 액세스 토큰을 재발급 후 Keychain에 저장
    func refreshAccessToken(completion: @escaping(Bool) -> Void) {
        guard let refreshToken = KeyChain.shared.get(key: "REFRESH_TOKEN") else {
            AuthManager.shared.logout()
            logger.fault("리프레시 토큰 없음")
            completion(false)
            
            return
        }
        
        let networkManager = CommonNetworkManager()
        
        networkManager.refreshAccessToken(refreshToken: refreshToken)
            .asObservable()
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                KeyChain.shared.set(key: "ACCESS_TOKEN", value: model.accessToken)
                KeyChain.shared.set(key: "ACCESS_TOKEN_EXPIRE_AT_KST", value: model.accessTokenExpiresAtKst)
                completion(true)
                
                logger.debug("[재발급한 ACCESS_TOKEN]\n\n\(model.accessToken)")
            }, onError: { [weak self] error in
                guard let self = self else { return }
                
                AuthManager.shared.logout()
                completion(false)
                
                logger.critical("리프레시 토큰 갱신 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
