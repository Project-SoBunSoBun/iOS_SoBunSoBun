//
//  SettingAPIModels.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/12/26.
//

import Foundation

// MARK: - 탈퇴
struct WithdrawRequestBodyModel: Encodable {
    let reasonCode: String
    let reasonDetail: String
    let agreedToTerms: Bool
}
