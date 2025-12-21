//
//  NetworkManager.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/12/25.
//

import Foundation
import Moya
import RxMoya
import RxSwift
import UIKit
import OSLog

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // Public API 전용
    private let provider = MoyaProvider<MultiTarget>(plugins: [MoyaLoggingPlugin()])
    // Authorized API 전용
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    // MARK: - 로그인
    // 서버에서 카카오 토큰을 통해 임시 토큰을 가져오는 메서드
    func fetchAuthLoginKakao(accessToken: String) -> Single<KakaoAuthResponse> {
        return provider.rx.request(
            MultiTarget(PublicAPI.authLoginKakao(accessToken: accessToken))
        )
        .filterSuccessfulStatusCodes()
        .map(KakaoAuthResponse.self)
    }
    
    // 서버에서 임시 토큰을 통해 사용자 정보를 가져오는 메서드
    func fetchAuthCompleteSignUp(loginToken: String, serviceTermsAgreed: Bool, privacyPolicyAgreed: Bool, marketingOptionalAgreed: Bool) -> Single<UserModel> {
        return provider.rx.request(
            MultiTarget(PublicAPI.authCompleteSignUp(loginToken: loginToken, serviceTermsAgreed: serviceTermsAgreed, privacyPolicyAgreed: privacyPolicyAgreed, marketingOptionalAgreed: marketingOptionalAgreed))
        )
        .filterSuccessfulStatusCodes()
        .map(UserModel.self)
    }
    
    // 서버에서 닉네임 중복 여부를 확인하는 메서드
    func checkNickname(nickname: String) -> Single<CheckNicknameModel> {
        return provider.rx.request(
            MultiTarget(PublicAPI.checkNickname(nickname: nickname))
        )
        .filterSuccessfulStatusCodes()
        .map(CheckNicknameModel.self)
    }
    
    // 서버에 닉네임과 프로필 이미지를 저장하는 메서드
    func saveProfile(nickname: String, profileImage: UIImage?) -> Single<Void> {
        let imageData = profileImage?.jpegData(compressionQuality: 0.7)
        
        return authProvider.rx.request(
            MultiTarget(AuthorizedAPI.saveProfile(nickname: nickname, profileImage: imageData))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // 서버에 유저 정보를 받아오는 메서드
    func myProfile() -> Single<UserInfoModel> {
        return authProvider.rx.request(
            MultiTarget(AuthorizedAPI.myProfile)
        )
        .filterSuccessfulStatusCodes()
        .map(UserInfoModel.self)
    }
    
    // MARK: - 홈
    // 현재 사용자 위치 인증 상태 조회
    func getLocationVefirication() -> Single<LocationVerificationModel> {
        return authProvider.rx.request(
            MultiTarget(AuthorizedAPI.getLocationVerification)
        )
        .filterSuccessfulStatusCodes()
        .map(LocationVerificationModel.self)
    }
    
    // 좌표를 통해 주소 변환
    func getAddresFromGeocoder(longitude: Double, latitude: Double) -> Single<GeocoderResponseModel> {
        let point: String = "\(longitude),\(latitude)"
        
        return provider.rx.request(
            MultiTarget(PublicAPI.getAddress(point: point))
        )
        .filterSuccessfulStatusCodes()
        .map(GeocoderResponseModel.self)
    }
    
    // 사용자 위치 인증
    func patchLocationVerification(address: String) -> Single<LocationVerificationModel> {
        return authProvider.rx.request(
            MultiTarget(AuthorizedAPI.patchLocationVerification(address: address))
        )
        .filterSuccessfulStatusCodes()
        .map(LocationVerificationModel.self)
    }
    
    // 홈 게시글 목록 불러오기
    func getHomeList(page: Int, size: Int) -> Single<PostListResponseModel> {
        return authProvider.rx.request(
            MultiTarget(AuthorizedAPI.getHomeList(page: page, size: size))
        )
        .filterSuccessfulStatusCodes()
        .map(PostListResponseModel.self)
    }
    
    // 카테고리 선택 후 홈 게시글 목록 불러오기
    func getHomeListByCategories(categories: [String], page: Int, size: Int) -> Single<PostListResponseModel> {
        return authProvider.rx.request(
            MultiTarget(AuthorizedAPI.getHomeListByCategories(category: categories, page: page, size: size))
        )
        .filterSuccessfulStatusCodes()
        .map(PostListResponseModel.self)
    }
    
    // 글 등록
    func registerPost(model: RegisterPostBodyModel) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(AuthorizedAPI.registerPost(model: model))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // MARK: - 정산
    // 서버에서 유저별 정산 목록을 받아오는 메서드
    func mySettleUps(activeOnly: Int, page: Int, size: Int) -> Single<SettleUpModel> {
        return authProvider.rx.request(
            MultiTarget(AuthorizedAPI.mySettleUps(activeOnly: activeOnly, page: page, size: size))
        )
        .filterSuccessfulStatusCodes()
        .map(SettleUpModel.self)
    }
}

/// Moya 로그 플러그인
final class MoyaLoggingPlugin: PluginType {
    private let requestLogger = Logger(
        subsystem: "SoBunSoBun",
        category: "NetworkManager.Request"
    )
    
    private let responseLogger = Logger(
        subsystem: "SoBunSoBun",
        category: "NetworkManager.Response"
    )
    
    // Request를 보낼 때 호출
    func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
            requestLogger.critical("[오류] 유효하지 않은 요청")
            return
        }
        
        let url = httpRequest.description
        let method = httpRequest.httpMethod ?? "unknown method"
        
        var log: String = "[요청 시작]\n"
        log.append("\n")
        log.append("URL: \(url)\n")
        log.append("METHOD: \(method)\n")
        log.append("API: \(target)\n")
        
        if let headers = httpRequest.allHTTPHeaderFields, !headers.isEmpty {
            log.append("HEADER: \(headers)\n")
        }
        
        if let body = httpRequest.httpBody, let bodyString = String(bytes: body, encoding: .utf8) {
            if let json = try? JSONSerialization.jsonObject(with: body, options: .mutableContainers),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                log.append("BODY:")
                log.append(String(decoding: jsonData, as: UTF8.self))
                log.append("\n")
            } else {
                log.append("BODY: \(bodyString)\n")
            }
        }
        
        log.append("\n")
        log.append("[요청 종료]\n")
        
        requestLogger.debug("\(log)")
    }
    
    // Response가 왔을 때
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            onSuceed(response, target: target, isFromError: false)
        case let .failure(error):
            onFail(error, target: target)
        }
    }
    
    func onSuceed(_ response: Response, target: TargetType, isFromError: Bool) {
        let request = response.request
        let url = request?.url?.absoluteString ?? "nil"
        let statusCode = response.statusCode
        
        var log = "[통신 성공]\n"
        log.append("\n")
        log.append("URL: \(url)\n")
        log.append("STATUS CODE: \(statusCode)\n")
        log.append("API: \(target)\n")
        
        // 2xx로 시작하지 않은 status code만 response 내용을 표시
        if !(200...299).contains(statusCode) {
            response.response?.allHeaderFields.forEach {
                log.append("\($0): \($1)\n")
            }
            
            log.append("RESPONSE:\n")
            if let reString = String(bytes: response.data, encoding: .utf8) {
                if let json = try? JSONSerialization.jsonObject(with: response.data, options: .mutableContainers),
                   let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    log.append(String(decoding: jsonData, as: UTF8.self))
                } else {
                    log.append(reString)
                }
            }
            log.append("\n")
        }
        
        log.append("\n")
        log.append("\(response.data.count) BYTES\n")
        log.append("\n")
        log.append("[통신 종료]\n")
        
        if (200...299).contains(statusCode) {
            responseLogger.debug("\(log)")
        } else {
            responseLogger.critical("\(log)")
        }
    }
    
    func onFail(_ error: MoyaError, target: TargetType) {
        if let response = error.response {
            onSuceed(response, target: target, isFromError: true)
            return
        }
        
        var log = "[통신 오류]\n"
        log.append("\n")
        log.append("\(error.errorCode) \(target)\n")
        log.append("\(error.failureReason ?? error.errorDescription ?? "unknown error")\n")
        log.append("\n")
        log.append("[통신 종료]\n")
        
        responseLogger.critical("\(log)")
    }
}
