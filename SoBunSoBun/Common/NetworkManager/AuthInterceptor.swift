//
//  AuthInterceptor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/24/25.
//

import Foundation
import Alamofire
import Moya
import OSLog

final class AuthInterceptor: RequestInterceptor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "AuthInterceptor"
    )
    
    static let shared = AuthInterceptor()
    
    private init() {}
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        // 저장된 액세스 토큰과 액세스 토큰 만료 시간을 가져오기
        guard let accessToken = KeyChain.shared.get(key: "ACCESS_TOKEN"),
              let accessTokenExpireAtKST = KeyChain.shared.get(key: "ACCESS_TOKEN_EXPIRE_AT_KST")
        else {
            // TODO: LogOut 구현하기 (ex 로그인 화면으로 이동)
            return
        }
        
        let now = Date()
        
        guard let dateAccessTokenExpireAtKST = ISO8601ToDate(accessTokenExpireAtKST) else {
            return
        }
        
        let isAccessExpired = dateAccessTokenExpireAtKST < now
        
        // 현재 시간과 accessToken의 만료 시간을 비교
        //        if isAccessExpired {
        //            completion(.failure(NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "액세스 토큰 만료"])))
        //            return
        //        }
        
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
            // TODO: LogOut 구현하기 (ex 로그인 화면으로 이동)
            completion(.doNotRetry)
            logger.fault("리프레시 토큰 만료 시간 정보 없음")
            return
        }
        
        let now = Date()
        
        guard let dateRefreshTokenExpireAtKST = ISO8601ToDate(refreshTokenExpireAtKST) else {
            return
        }
        
        let isRefreshExpired = dateRefreshTokenExpireAtKST < now
        
        // 현재 시간과 refreshToken의 만료 시간을 비교
        if isRefreshExpired {
            // TODO: LogOut 구현하기 (ex 로그인 화면으로 이동)
            completion(.doNotRetry)
            logger.debug("리프레시 토큰 만료")
            return
        }
        
        if isRefreshing {
            logger.debug("이미 재발급 중")
            completion(.retry)
        } else {
            isRefreshing = true
            
            refreshToken() { [weak self] isSuccess in
                guard let self = self else {
                    completion(.doNotRetry)
                    return
                }
                
                isRefreshing = false
                
                if isSuccess {
                    logger.debug("액세스 토큰 재발급 완료")
                    completion(.retry)
                } else {
                    logger.debug("리프레시 토큰 만료")
                    // TODO: 로그아웃 구현 (ex 로그인 화면으로 넘기기)
                    completion(.doNotRetry)
                }
            }
        }
    }
    
    // 리프레시 토큰을 사용하여 액세스 토큰을 재발급 후 Keychain에 저장
    private func refreshToken(completion: @escaping(Bool) -> Void) {
        guard let refresh = KeyChain.shared.get(key: "REFRESH_TOKEN"),
              let body = RefreshBodyModel(refreshToken: refresh).toDictionary() else {
            logger.fault("리프레시 토큰 없음")
            completion(false)
            return
        }
        
        AF.request("\(API_URL)/auth/token/refresh",
                   method: .post,
                   parameters: body,
                   encoding: JSONEncoding.default)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: RefreshResponseModel.self) { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let model):
                KeyChain.shared.set(key: "ACCESS_TOKEN", value: model.accessToken)
                KeyChain.shared.set(key: "ACCESS_TOKEN_EXPIRE_AT_KST", value: model.accessTokenExpiresAtKst)
                logger.debug("[재발급된 ACCESS TOKEN]\n\n\(model.accessToken)")
                completion(true)
            case .failure(let error):
                logger.critical("리프레시 토큰 갱신 실패: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}
