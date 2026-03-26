//
//  SettleUpNetworkManager.swift
//  SoBunHaeYo
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
    func mySettleUps(status: String, page: Int, size: Int) -> Single<SettleUpResponseModel> {
        return authProvider.rx.request(
            MultiTarget(SettleUpAPIs.mySettleUps(status: status, page: page, size: size))
        )
        .filterSuccessfulStatusCodes()
        .tryMap(SettleUpResponseModel.self)
    }
    
    // 정산 완료 등록 메서드
    func putSettlementComplete(model: SettleUp3rdStepDataModel) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(SettleUpAPIs.putSettlementComplete(model: model))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // 정산 상세 조회 메서드
    func getSettlement(settlementId: Int) -> Single<SettlementResponseModel> {
        return authProvider.rx.request(
            MultiTarget(SettleUpAPIs.getSettlement(settlementId: settlementId))
        )
        .filterSuccessfulStatusCodes()
        .tryMap(SettlementResponseModel.self)
    }
}
