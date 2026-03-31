//
//  WithdrawReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 2/12/26.
//

import Foundation
import ReactorKit
import OSLog

class WithdrawReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.Withdraw.Reactor"
    )
    
    private let networkManager = SettingNetworkManager()
    
    let initialState: State = State()
    
    enum Action {
        // 탈퇴 사유 스택뷰 선택시
        case reasonTapped(Bool)
        // 드롭 다운 메뉴 선택시
        case dropDownCellTapped(Int)
        // 동의 체크박스 선택시
        case agreeCheckBoxTapped(Bool)
        // 탈퇴 버튼 클릭시
        case withdrawButtonTapped
        // 탈퇴 사유 내용 변경시
        case reasonDetailChanged(String)
    }
    
    enum Mutation {
        // 탈퇴 사유 스택뷰 선택시
        case setIsMenuOpen(Bool)
        // 드롭 다운 메뉴 선택시
        case setReasonNumber(Int)
        // 동의 체크박스 선택시
        case setIsAgree(Bool)
        // 탈퇴 사유 내용 변경시
        case setReasonDetail(String)
        // 로딩 상태
        case setLoading(Bool)
        // 탈퇴 완료
        case setWithdrawCompleted
        // 에러
        case setErrorMessage(String)
    }
    
    struct State {
        var isMenuOpen: Bool = false
        var reasonNumber: Int?
        var isAgree: Bool = false
        var isEnable: Bool {
            reasonNumber != nil && isAgree
        }
        var reasonDetailString: String?
        var isLoading: Bool = false
        @Pulse var withdrawCompleted: Void?
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reasonTapped(let isMenuOpen):
            return Observable.just(.setIsMenuOpen(isMenuOpen))
            
        case .dropDownCellTapped(let reasonNumber):
            return Observable.just(.setReasonNumber(reasonNumber))
            
        case .agreeCheckBoxTapped(let isAgree):
            return Observable.just(.setIsAgree(isAgree))
        
        case .withdrawButtonTapped:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                withdraw(),
                Observable.just(.setLoading(false))
            ])
            
        case .reasonDetailChanged(let reasonDetail):
            return Observable.just(.setReasonDetail(reasonDetail))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setIsMenuOpen(let isMenuOpen):
            newState.isMenuOpen = isMenuOpen
            
        case .setReasonNumber(let reasonNumber):
            newState.reasonNumber = reasonNumber
            
        case .setIsAgree(let isAgree):
            newState.isAgree = isAgree
            
        case .setReasonDetail(let reasonDetail):
            newState.reasonDetailString = reasonDetail
            
        case .setWithdrawCompleted:
            newState.withdrawCompleted = ()
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }
        
        return newState
    }
    
    private func withdraw() -> Observable<Mutation> {
        guard let reasonNumber = currentState.reasonNumber else {
            logger.error("탈퇴 사유가 선택되지 않음")
            
            return Observable.just(.setErrorMessage(String(localized: "SelectWithdrawReason", table: "Settings")))
        }
        
        let reasonCode = String(format: "%03d", reasonNumber)
        let reasonDetail = currentState.reasonDetailString ?? ""
        let agreedToTerms = currentState.isAgree
        
        return networkManager.withdraw(
            reasonCode: reasonCode,
            reasonDetail: reasonDetail,
            agreedToTerms: agreedToTerms
        )
        .asObservable()
        .flatMap { response -> Observable<Mutation> in
            if response.success {
                self.logger.debug("탈퇴 완료")
                
                return Observable.just(.setWithdrawCompleted)
            } else {
                if let errorCode = response.errorCode {
                    self.logger.critical("탈퇴 실패(\(errorCode)) - \(response.message ?? "")")
                    
                    return Observable.just(.setErrorMessage(localizedErrorMessage(errorCode)))
                } else {
                    self.logger.critical("탈퇴 실패: \(response.message ?? "")")
                    
                    return Observable.just(.setErrorMessage(localizedErrorMessage(nil)))
                }
            }
        }
        .catch { error in
            self.logger.debug("탈퇴 에러: \(error)")
            
            return Observable.just(.setErrorMessage(String(format: String(localized: "ErrorMessageWithReason", table: "Error"), error.localizedDescription)))
        }
    }
}
