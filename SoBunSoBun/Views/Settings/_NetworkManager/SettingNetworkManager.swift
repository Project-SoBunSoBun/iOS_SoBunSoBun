//
//  SettingNetworkManager.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/12/26.
//

import Foundation
import Moya
import RxMoya
import RxSwift

class SettingNetworkManager {
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    // MARK: - 회원 탈퇴
    // 사용자 회원 탈퇴
    func withdraw(reasonCode: String, reasonDetail: String, agreedToTerms: Bool) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(SettingAPIs.postWithdraw(reasonCode: reasonCode, reasonDetail: reasonDetail, agreedToTerms: agreedToTerms))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
}
