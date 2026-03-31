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
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettleUpAPIs.mySettleUps(status: status, page: page, size: size)))
        
        return request.tryMap(SettleUpResponseModel.self)
    }
    
    // 정산 완료 등록 메서드
    func putSettlementComplete(model: SettleUp3rdStepDataModel) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettleUpAPIs.putSettlementComplete(model: model)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // 정산 상세 조회 메서드
    func getSettlement(settlementId: Int) -> Single<SettlementResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(SettleUpAPIs.getSettlement(settlementId: settlementId)))
        
        return request.tryMap(SettlementResponseModel.self)
    }
}
