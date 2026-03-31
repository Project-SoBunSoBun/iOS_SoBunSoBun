//
//  ProfileNetworkManager.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/16/26.
//

import Foundation
import Moya
import RxMoya
import RxSwift

class ProfileNetworkManager {
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    func getProfilePostList(userId: Int, page: Int, size: Int) -> Single<ProfileUserInfoResponseModel> {
        return authProvider.rx.request(MultiTarget(ProfileAPIs.getPostList(userId: userId, page: page, size: size)))
            .tryMap(ProfileUserInfoResponseModel.self)
    }
    
    func blockUser(userId: Int) -> Single<PlainResponseModel> {
        return authProvider.rx.request(MultiTarget(ProfileAPIs.blockUser(userId: userId)))
            .tryMap(PlainResponseModel.self)
    }
    
    func unBlockUser(userId: Int) -> Single<PlainResponseModel> {
        return authProvider.rx.request(MultiTarget(ProfileAPIs.unBlockUser(userId: userId)))
            .tryMap(PlainResponseModel.self)
    }
}
