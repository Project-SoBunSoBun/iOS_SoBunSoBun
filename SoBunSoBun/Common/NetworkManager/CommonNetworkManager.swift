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

class CommonNetworkManager {
    private let provider = MoyaProvider<MultiTarget>(plugins: [MoyaLoggingPlugin()])
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])

    // 서버에 유저 정보를 받아오는 메서드
    func myProfile() -> Single<UserInfoModel> {
        return authProvider.rx.request(
            MultiTarget(CommonAPIs.me)
        )
        .filterSuccessfulStatusCodes()
        .map(UserInfoModel.self)
    }
    
    // 액세스 토큰 재발급
    func refreshAccessToken(refreshToken: String) -> Single<RefreshResponseModel> {
        return provider.rx.request(
            MultiTarget(CommonAPIs.refreshAccessToken(refreshToken: refreshToken))
        )
        .filterSuccessfulStatusCodes()
        .map(RefreshResponseModel.self)
    }
}
