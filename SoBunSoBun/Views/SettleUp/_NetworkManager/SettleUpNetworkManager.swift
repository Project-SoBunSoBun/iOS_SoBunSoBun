//
//  SettleUpNetworkManager.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/13/26.
//

import Foundation
import Moya
import RxMoya
import RxSwift
import UIKit

class SettleUpNetworkManager {
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    // MARK: - 정산
    // 서버에서 유저별 정산 목록을 받아오는 메서드
    func mySettleUps(activeOnly: Int, page: Int, size: Int) -> Single<SettleUpModel> {
        return authProvider.rx.request(
            MultiTarget(SettleUpAPIs.mySettleUps(activeOnly: activeOnly, page: page, size: size))
        )
        .filterSuccessfulStatusCodes()
        .map(SettleUpModel.self)
    }
    
    // 정산 삭제 메서드
    func deleteSettleUp(id: Int) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(SettleUpAPIs.deleteSettleUp(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
}
