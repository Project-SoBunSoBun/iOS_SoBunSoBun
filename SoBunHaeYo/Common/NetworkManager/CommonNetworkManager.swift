//
//  NetworkManager.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 9/12/25.
//

import Foundation
import Moya
import RxMoya
import RxSwift
import UIKit
import OSLog

class CommonNetworkManager {
    private let provider = MoyaProvider<MultiTarget>(plugins: [MoyaLoggingPlugin()])
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])

    // 서버에 유저 정보를 받아오는 메서드
    func myProfile() -> Single<UserInfoModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(CommonAPIs.me))
        
        return request.tryMap(UserInfoModel.self)
    }
    
    // 액세스 토큰 재발급
    func refreshAccessToken(refreshToken: String) -> Single<RefreshResponseModel> {
        let request: Single<Response> = provider.rx.request(MultiTarget(CommonAPIs.refreshAccessToken(refreshToken: refreshToken)))
        
        return request.tryMap(RefreshResponseModel.self)
    }
    
    // FCM 토큰 전송
    func registerFCMToken(deviceId: String, token: String) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(CommonAPIs.registerFCMToken(deviceId: deviceId, token: token)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // FCM 토큰 삭제
    func deleteFCMToken(deviceId: String) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(CommonAPIs.deleteFCMToken(deviceId: deviceId)))
        
        return request.tryMap(PlainResponseModel.self)
    }
}
