//
//  NotificationNetworkManager.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/27/26.
//

import Foundation
import Moya
import RxMoya
import RxSwift

final class NotificationNetworkManager {
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    func getNotifications(page: Int, size: Int) -> Single<NotificationResponseModel> {
        return authProvider.rx.request(
            MultiTarget(NotificationAPIs.getNotifications(page: page, size: size))
        )
        .tryMap(NotificationResponseModel.self)
    }
    
    func readNotification(id: Int) -> Single<PlainResponseModel> {
        return authProvider.rx.request(
            MultiTarget(NotificationAPIs.readNotification(id: id))
        )
        .tryMap(PlainResponseModel.self)
    }
    
    func readAllNotifications() -> Single<PlainResponseModel> {
        return authProvider.rx.request(
            MultiTarget(NotificationAPIs.readAllNotifications)
        )
        .tryMap(PlainResponseModel.self)
    }
}
