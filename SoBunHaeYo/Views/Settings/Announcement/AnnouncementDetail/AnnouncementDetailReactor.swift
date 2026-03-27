//
//  AnnouncementDetailReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 2/14/26.
//

import ReactorKit
import RxSwift
import OSLog

class AnnouncementDetailReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.AnnouncementDetail.Reactor"
    )
    
    init(id: Int) {
        initialState = State(id: id)
    }
    
    let initialState: State
    
    private let networkManager = SettingNetworkManager()
    
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case setNoticeDetail(AnnouncementDetailDataModel)
        case setErrorMessage(String)
    }
    
    struct State {
        let id: Int
        var noticeDetail: AnnouncementDetailDataModel?
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            loadNoticeDetail(id: currentState.id)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setNoticeDetail(let noticeDetail):
            newState.noticeDetail = noticeDetail
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func loadNoticeDetail(id: Int) -> Observable<Mutation> {
        return networkManager.getAnnouncementsDetail(id: id)
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
                if response.success {
                    self.logger.debug("공지사항 상세 조회 성공")
                    
                    return Observable.just(.setNoticeDetail(response.data))
                } else {
                    if let errorCode = response.errorCode {
                        let errorMessage = NSLocalizedString(errorCode, tableName: "Error", comment: "")
                        let fallback = String(format: String(localized: "ErrorMessageWithCode", table: "Error"), errorCode)
                        return Observable.just(.setErrorMessage(errorMessage != errorCode ? errorMessage : fallback))
                    } else {
                        return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Error")))
                    }
                }
            }
            .catch { error in
                self.logger.fault("공지사항 상세 조회 실패: \(error.localizedDescription)")
                
                let errorMessage = String(format: String(localized: "ErrorMessageWithReason", table: "Error"), error.localizedDescription)
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
}
