//
//  SettleUpAPIs.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/13/26.
//

import Foundation
import Moya

enum SettleUpAPIs {
    // 정산
    case mySettleUps(status: String, page: Int, size: Int)
    case deleteSettleUp(id: Int)
    case putSettlementComplete(model: SettleUp3rdStepDataModel)
    case getSettlement(settlementId: Int)
}

extension SettleUpAPIs: TargetType {
    // interceptor retry 활성화
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        return URL(string: API_URL)!
    }
    
    var path: String {
        switch self {
        case .mySettleUps:
            return "/api/v1/settlements/my"
            
        case .deleteSettleUp(let id):
            return "/api/v1/settlements/\(id)"
            
        case .putSettlementComplete(let model):
            return "/api/v1/settlements/\(model.settlementId)/complete"
            
        case .getSettlement(let settlementId):
            return "/api/v1/settlements/\(settlementId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case // GET
                .mySettleUps,
                .getSettlement:
            return .get
            
        case // PUT
                .putSettlementComplete:
            return .put
            
        case // DELETE
                .deleteSettleUp:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .mySettleUps(let status, let page, let size):
            let parameters = SettleUpMyRequestModel(status: status, page: page, size: size)
            
            return .requestParameters(parameters: parameters.toDictionary()!, encoding: URLEncoding.queryString)
            
        case .deleteSettleUp:
            return .requestPlain
            
        case .putSettlementComplete(let model):
            let participants = model.participants.map { participant in
                SettlementCompleteParticipantModel(
                    userId: participant.userId,
                    assignedAmount: participant.assignedAmount,
                    items: participant.items.map { item in
                            SettlementCompleteItemModel(
                                itemName: item.itemName,
                                quantity: item.quantity,
                                unit: item.unitIndex == 1 ? String(localized: "Count", table: "SettleUp") : "g",
                                amount: item.amount
                            )
                    }
                )
            }
            
            let body = SettlementCompleteRequestModel(
                totalAmount: model.totalAmount,
                participants: participants
            )
            
            return .requestJSONEncodable(body)
            
        case .getSettlement:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
