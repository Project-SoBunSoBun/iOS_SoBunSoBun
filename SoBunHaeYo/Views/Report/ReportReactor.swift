//
//  ReportReactor.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/17/26.
//

import Foundation
import ReactorKit
import OSLog

class ReportReactor: Reactor {
    private let target: ReportTarget
    
    init(target: ReportTarget) {
        self.target = target
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Report.Reactor"
    )
    
    let initialState = State()
    let networkManager = ReportNetworkManager()
    
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
        // 신고
        case report
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
        // 신고 확인 알림 표시
        case setShouldShowReportConfirmAlert
        // 로딩 상태
        case setLoading(Bool)
        // 신고하기 전송 성공
        case setShouldShowReportCompletedAlert
        // 에러
        case setErrorMessage(String)
    }
    
    struct State {
        var isMenuOpen: Bool = false
        var reportType: String?
        var detailString: String?
        var isAgree: Bool = false
        
        @Pulse var shouldShowReportConfirmAlert: Void?
        
        var isLoading: Bool = false
        @Pulse var shouldShowReportCompletedAlert: Void?
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
            return Observable.just(.setShouldShowReportConfirmAlert)
            
        case .report:
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
            
        case .setShouldShowReportConfirmAlert:
            newState.shouldShowReportConfirmAlert = ()
            
        case .setShouldShowReportCompletedAlert:
            newState.shouldShowReportCompletedAlert = ()
            
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
        
        let api: Single<PlainResponseModel>
        
        switch target {
        case .user(userId: let userId, groupPostId: let groupPostId):
            api = networkManager.reportUser(userId: userId, groupPostId: groupPostId, reason: reportType, description: description)
            
        case .post(postId: let postId):
            api = networkManager.reportPost(postId: postId, reason: reportType, description: description)
            
        case .comment(commentId: let commentId):
            api = networkManager.reportPostComment(commentId: commentId, reason: reportType, description: description)
        }
        
        return api.asObservable()
            .flatMap { response -> Observable<Mutation> in
                if response.success {
                    self.logger.debug("신고 완료")
                    
                    return Observable.just(.setShouldShowReportCompletedAlert)
                } else {
                    if let errorCode = response.errorCode {
                        self.logger.critical("신고 실패(\(errorCode)) - \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(errorCode)))
                    } else {
                        self.logger.critical("신고 실패: \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(nil)))
                    }
                }
            }
            .catch { error in
                self.logger.debug("신고 에러: \(error)")
                
                return Observable.just(.setErrorMessage(String(format: String(localized: "ErrorMessageWithReason", table: "Error"), error.localizedDescription)))
            }
    }
}
