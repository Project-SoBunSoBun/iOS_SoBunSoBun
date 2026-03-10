//
//  SettleUpDataModel.swift
//  SoBunSoBun
//
//  Created by 허성필 on 12/27/25.
//

import Foundation

struct SettleUpItemModel {
    let settlementId, authorId: Int
    let settlementStatus: Bool
    let title: String
    let location: String
    let meetingDate: String
    let participants: [ParticipantModel]
}
