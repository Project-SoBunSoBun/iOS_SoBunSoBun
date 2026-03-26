//
//  NavigationTabNetworkManager.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/10/26.
//

import Foundation
import Moya
import RxMoya
import RxSwift

class NavigationTabNetworkManager {
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    func getUnreadNotificationCount() -> Single<UnreadNotificationCountResponseModel> {
        return authProvider.rx.request(
            MultiTarget(NavigationTabAPIs.getUnreadNotificationCount)
        )
        .tryMap(UnreadNotificationCountResponseModel.self)
    }
    
    func getChatRoomList() -> Single<ChatRoomListResponseModel> {
        return authProvider.rx.request(
            MultiTarget(NavigationTabAPIs.getChatRoomList)
        )
        .filterSuccessfulStatusCodes()
        .tryMap(ChatRoomListResponseModel.self)
    }
}
