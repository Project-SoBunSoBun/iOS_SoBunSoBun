//
//  AnnouncementReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/14/26.
//

import ReactorKit
import RxSwift
import OSLog

class AnnouncementReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.Announcement.Reactor"
    )
    
    let initialState = State()
    
    private let networkManager = SettingNetworkManager()
    
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case setNotice([AnnouncementContentModel])
        case setLoading(Bool)
        case setError(String)
    }
    
    struct State {
        var notices: [AnnouncementContentModel] = []
        var page: Int = 0
        var isLoading: Bool = false
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .viewDidLoad:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                loadNotices(page: currentState.page, size: 20),
                Observable.just(.setLoading(false))
            ])
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            
        case .setNotice(let notices):
            newState.notices = notices
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setError(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    // 공지사항 API 호출
    private func loadNotices(page: Int, size: Int) -> Observable<Mutation> {
        return networkManager.getAnnouncements(page: page, size: size)
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
                self.logger.debug("공지사항 조회 성공")
                return Observable.just(.setNotice(response.data.content))
            }
            .catch { error in
                self.logger.fault("공지사항 조회 실패: \(error.localizedDescription)")
                return Observable.just(.setError(error.localizedDescription))
            }
    }
}
