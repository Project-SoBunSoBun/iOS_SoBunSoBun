//
//  AuthInterceptor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 9/24/25.
//

import Foundation
import Alamofire
import RxSwift
import OSLog

final class AuthInterceptor: RequestInterceptor {
    // refreshStateQueue로 직렬화하여 data race 방지 (nonisolated(unsafe)는 Swift 6 Sendable 경고 억제용)
    nonisolated(unsafe) private let disposeBag = DisposeBag()
    nonisolated(unsafe) private(set) var isRefreshing: Bool = false
    nonisolated(unsafe) private var refreshCompletionHandlers: [(Bool) -> Void] = []
    private let refreshStateQueue = DispatchQueue(label: "SoBunHaeYo.AuthInterceptor.RefreshState")
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "AuthInterceptor"
    )
    
    static let shared = AuthInterceptor()
    
    private init() {}
    
    // MARK: - RequestInterceptor
    // 모든 요청에 액세스 토큰을 헤더에 주입
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard let accessToken = KeyChain.shared.get(key: "ACCESS_TOKEN") else {
            logger.fault("ACCESS_TOKEN 없음 - 로그아웃")
            
            AuthManager.shared.logout()
            
            completion(.failure(NSError(domain: "SobunHaeyo", code: -1, userInfo: [NSLocalizedDescriptionKey: "액세스 토큰이 없습니다."])))
            
            return
        }
        
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: accessToken))
        completion(.success(urlRequest))
    }
    
    // 401 응답 시 리프레시 토큰으로 액세스 토큰을 재발급한 후 원래 요청을 재시도
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        logger.debug("retry 진입")
        
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            logger.debug("401 오류가 아님")
            
            completion(.doNotRetryWithError(error))
            
            return
        }
        
        guard isRefreshTokenValid() else {
            AuthManager.shared.logout()
            
            logger.debug("리프레시 토큰 만료 또는 정보 없음")
            
            completion(.doNotRetry)
            
            return
        }
        
        refreshAccessToken { [weak self] isSuccess in
            guard let self = self else {
                completion(.doNotRetry)
                
                return
            }
            
            if isSuccess {
                logger.debug("액세스 토큰 재발급 완료")
                
                completion(.retry)
            } else {
                AuthManager.shared.logout()
                
                logger.debug("액세스 토큰 재발급 실패 - 로그아웃")
                
                completion(.doNotRetry)
            }
        }
    }
    
    // MARK: - 토큰 갱신
    // 액세스 토큰을 재발급하고 Keychain에 저장
    // 이미 갱신 중이면 완료 시 호출될 핸들러 큐에 추가 (네트워크 요청은 1회만 발생)
    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        refreshStateQueue.async { [weak self] in
            guard let self = self else {
                completion(false)
                
                return
            }
            
            refreshCompletionHandlers.append(completion)
            
            guard !isRefreshing else {
                logger.debug("이미 재발급 중 - 완료 후 재시도")
                
                return
            }
            
            isRefreshing = true
            
            guard let refreshToken = KeyChain.shared.get(key: "REFRESH_TOKEN") else {
                logger.fault("리프레시 토큰 없음")
                
                finishRefreshing(isSuccess: false)
                
                return
            }
            
            // networkManager를 클로저에 강한 캡처해 요청 완료 전 해제되지 않도록 유지
            let networkManager = CommonNetworkManager()
            networkManager.refreshAccessToken(refreshToken: refreshToken)
                .asObservable()
                .subscribe(
                    onNext: { [weak self] model in
                        guard let self = self else {
                            // self가 nil이면 finishRefreshing 미호출로 isRefreshing이 영구 true 고착되므로 반드시 호출
                            AuthInterceptor.shared.finishRefreshing(isSuccess: true)
                            
                            return
                        }
                        
                        KeyChain.shared.set(key: "ACCESS_TOKEN", value: model.accessToken)
                        KeyChain.shared.set(key: "ACCESS_TOKEN_EXPIRE_AT_KST", value: model.accessTokenExpiresAtKst)
                        
                        logger.debug("[재발급한 ACCESS_TOKEN]\n\n\(model.accessToken)")
                        
                        finishRefreshing(isSuccess: true)
                    },
                    onError: { [weak self] error in
                        guard let self = self else {
                            AuthInterceptor.shared.finishRefreshing(isSuccess: false)
                            
                            return
                        }
                        
                        logger.critical("리프레시 토큰 갱신 실패: \((error as? APIErrorModel)?.message ?? error.localizedDescription)")
                        
                        finishRefreshing(isSuccess: false)
                    },
                    // subscription이 종료될 때까지 networkManager를 캡처해 provider가 해제되지 않도록 유지
                    onDisposed: { _ = networkManager }
                )
                .disposed(by: disposeBag)
        }
    }
}

extension AuthInterceptor {
    // Keychain의 만료 시간을 기준으로 리프레시 토큰 유효성 검증
    private func isRefreshTokenValid() -> Bool {
        guard let expireAtKST = KeyChain.shared.get(key: "REFRESH_TOKEN_EXPIRE_AT_KST") else {
            logger.fault("리프레시 토큰 만료 시간 정보 없음")
            
            return false
        }
        
        guard let expireDate = ISO8601ToDate(expireAtKST) else {
            logger.fault("리프레시 토큰 만료 시간 ISO8601ToDate 형태 변환 실패")
            
            return false
        }
        
        return expireDate >= Date()
    }
    
    // 갱신 완료 후 isRefreshing을 초기화하고 대기 중인 핸들러를 일괄 호출
    private func finishRefreshing(isSuccess: Bool) {
        refreshStateQueue.async { [weak self] in
            guard let self = self else { return }
            
            isRefreshing = false
            
            let handlers = refreshCompletionHandlers
            refreshCompletionHandlers.removeAll()
            
            handlers.forEach { $0(isSuccess) }
        }
    }
}
