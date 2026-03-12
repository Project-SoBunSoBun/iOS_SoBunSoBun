//
//  CalculationGuestDataModel.swift
//  SoBunSoBun
//
//  Created by 허성필 on 3/6/26.
//

import Foundation

// MARK: - 2단계 정산 DataModel
struct SettleUpProductSelectionModel {
    let productName: String
    let unitIndex: Int
    let totalPrice: Int
    let totalCount: Int
    let selections: [ParticipantSelectionModel]
}

struct ParticipantSelectionModel {
    let userNickname: String
    let value: Int
}

// MARK: - 3단계 정산 DataModel
struct SettleUp3rdStepDataModel {
    let settlementId: Int
    let totalAmount: Int
    let participants: [SettleUp3rdStepParticipantModel]
}

struct SettleUp3rdStepParticipantModel {
    let userId: Int
    let nickname: String
    let assignedAmount: Int
    let items: [SettleUpItemDetailModel]
}

struct SettleUpItemDetailModel {
    let itemName: String
    let quantity: Int
    let unitIndex: Int
    let amount: Int
}
