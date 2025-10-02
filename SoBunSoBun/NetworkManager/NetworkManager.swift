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

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // Public API 전용
    private let provider = MoyaProvider<MultiTarget>()
    // Authorized API 전용
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared))
    
    // 서버에서 카카오 토큰을 통해 사용자 정보 가져오는 메서드
    func fetchAuthLoginKakao(accessToken: String) -> Single<UserModel> {
        return provider.rx.request(
            MultiTarget(PublicAPI.authLoginKakao(accessToken: accessToken))
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
}
