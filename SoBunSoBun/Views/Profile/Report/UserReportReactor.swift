//
//  UserReportReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/17/26.
//

import Foundation
import ReactorKit
import OSLog

class UserReportReactor: Reactor {
    private let userId: Int
    
    init(userId: Int) {
        self.userId = userId
    }
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Profile.UserReport.Reactor"
    )
    
    let initialState = State()
    let networkManager = ProfileNetworkManager()
    
    enum Action {
        // 신고 유형 선택시
        case menuBoxTapped(Bool)
        // 드랍 다운 메뉴 선택시
        case dropDownCellTapped(String)
        // 문의 내용 변경시
        case detailChanged(String)
        // 동의 체크박스 선택시
        case agreeCheckBoxTapped(Bool)
        // 신고하기 버튼 선택시
        case reportButtonTapped
    }
    
    enum Mutation {
        // 신고 유형 선택시
        case setIsMenuOpen(Bool)
        // 드롭 다운 메뉴 선택시
        case setReportType(String)
        // 문의 내용 변경시
        case setDetail(String)
        // 동의 체크박스 선택시
        case setIsAgree(Bool)
        // 로딩 상태
        case setLoading(Bool)
        // 신고하기 전송 성공
        case setReportCompleted
        // 에러
        case setErrorMessage(String)
    }
    
    struct State {
        var isMenuOpen: Bool = false
        var reportType: String?
        var detailString: String?
        var isAgree: Bool = false
        
        var isLoading: Bool = false
        @Pulse var reportCompleted: Void?
        @Pulse var errorMessage: String?
        
        // 버튼 활성화 여부
        var isButtonEnabled: Bool {
            let isTypeSelected = reportType != nil
            let isDetailInputted = !(detailString?.isEmpty ?? true)
            
            return isTypeSelected && isAgree && isDetailInputted && !isLoading
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .menuBoxTapped(let isMenuOpen):
            return Observable.just(.setIsMenuOpen(isMenuOpen))
            
        case .dropDownCellTapped(let type):
            return Observable.just(.setReportType(type))
            
        case .detailChanged(let detail):
            return Observable.just(.setDetail(detail))
            
        case .agreeCheckBoxTapped(let isAgree):
            return Observable.just(.setIsAgree(isAgree))
            
        case .reportButtonTapped:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                report(),
                Observable.just(.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setIsMenuOpen(let isMenuOpen):
            newState.isMenuOpen = isMenuOpen
            
        case .setReportType(let type):
            newState.reportType = type
        
        case .setDetail(let detail):
            newState.detailString = detail
            
        case .setIsAgree(let isAgree):
            newState.isAgree = isAgree
        
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setReportCompleted:
            newState.reportCompleted = ()
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func report() -> Observable<Mutation> {
        guard let reportType = currentState.reportType else {
            logger.error("신고 유형을 선택하지 않음")
            
            return Observable.just(.setErrorMessage(String(localized: "SelectBugLocation", table: "Settings")))
        }
        
        let description = currentState.detailString ?? ""
        
        return networkManager.reportUser(userId: userId, reason: reportType, description: description)
        .asObservable()
        .flatMap { model -> Observable<Mutation> in
            self.logger.debug("신고 완료")
            
            if model.success {
                return Observable.just(.setReportCompleted)
            } else {
                if let errorCode = model.errorCode {
                    return Observable.just(.setErrorMessage(String(format: String(localized: "ErrorMessageWithCode", table: "Common"), errorCode)))
                } else {
                    return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
                }
            }
        }
        .catch { error in
            self.logger.debug("신고 에러: \(error)")
            
            return Observable.just(.setErrorMessage(error.localizedDescription))
        }
    }
}
