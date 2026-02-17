//
//  AnnouncementDetailReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/14/26.
//

import ReactorKit
import RxSwift
import OSLog

class AnnouncementDetailReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
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
        case setError(String)
        case setNoticeDetail(AnnouncementDetailDataModel)
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
            
        case .setError(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func loadNoticeDetail(id: Int) -> Observable<Mutation> {
        return networkManager.getAnnouncementsDetail(id: id)
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
                self.logger.debug("공지사항 상세 조회 성공")
                
                return Observable.just(.setNoticeDetail(response.data))
            }
            .catch { error in
                self.logger.fault("공지사항 상세 조회 실패: \(error.localizedDescription)")
                
                return Observable.just(.setError(error.localizedDescription))
            }
    }
}
