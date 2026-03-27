//
//  AnnouncementReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 2/14/26.
//

import ReactorKit
import RxSwift
import OSLog

class AnnouncementReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.Announcement.Reactor"
    )
    
    let initialState = State()
    
    private let networkManager = SettingNetworkManager()
    private let pageSize: Int = 20
    
    enum Action {
        case viewWillAppear
        case loadMore // 페이지네이션
        case refresh // 새로고침
        case cellTapped(AnnouncementContentModel) // 셀 클릭
    }
    
    enum Mutation {
        case setNotices([AnnouncementContentModel])
        case setLoading(Bool)
        case appendNotices([AnnouncementContentModel])
        case setPage(Int)
        case setHasMore(Bool)
        case setRefreshing(Bool)
        case setErrorMessage(String)
        case setNoticeDetailView(AnnouncementContentModel)
    }
    
    struct State {
        var notices: [AnnouncementContentModel] = [] // 공지사항
        var isLoading: Bool = false
        var page: Int = 0 // 페이지네이션 페이지 번호
        var hasMore: Bool = true // 페이지네이션 추가 가능 여부
        var isRefreshing: Bool = false // 새로고침 여부
        @Pulse var errorMessage: String? // 에러 메세지
        @Pulse var shouldPushDetailView: AnnouncementContentModel? // 공지사항 디테일 뷰로 이동
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.concat([
                Observable.just(.setPage(0)),
                loadNotices(page: currentState.page, size: pageSize)
            ])
            
        case .loadMore:
            guard !currentState.isLoading &&
                    currentState.hasMore else {
                return Observable.empty()
            }
            
            let nextPage = currentState.page + 1
            
            return Observable.concat([
                Observable.just(.setPage(nextPage)),
                loadNotices(page: nextPage, size: pageSize)
            ])
            
        case .refresh:
            return Observable.concat([
                Observable.just(.setRefreshing(true)),
                Observable.just(.setPage(0)),
                loadNotices(page: 0, size: pageSize),
                Observable.just(.setRefreshing(false))
            ])
            
        case .cellTapped(let model):
            return Observable.just(.setNoticeDetailView(model))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setNotices(let notices):
            newState.notices = notices
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
            
        case .setRefreshing(let isRefreshing):
            newState.isRefreshing = isRefreshing
            
        case .appendNotices(let notices):
            newState.notices.append(contentsOf: notices)
            
        case .setPage(let page):
            newState.page = page
            
        case .setHasMore(let hasMore):
            newState.hasMore = hasMore
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setNoticeDetailView(let model):
            newState.shouldPushDetailView = model
        }
        
        return newState
    }
    
    // 공지사항 API 호출
    private func loadNotices(page: Int, size: Int) -> Observable<Mutation> {
        return Observable.deferred {
            Observable.concat([
                Observable.just(.setLoading(true)),
                self.networkManager.getAnnouncements(page: page, size: size)
                    .asObservable()
                    .flatMap { response -> Observable<Mutation> in
                        if response.success {
                            self.logger.debug("공지사항 조회 성공")
                            
                            let isFirst = response.data.page.first
                            
                            return Observable.concat([
                                isFirst ? Observable.just(.setNotices(response.data.content)) : Observable.just(.appendNotices(response.data.content)),
                                Observable.just(.setHasMore(!response.data.page.last))
                            ])
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
                        self.logger.fault("공지사항 조회 실패: \(error.localizedDescription)")
                        
                        let errorMessage = String(format: String(localized: "ErrorMessageWithReason", table: "Error"), error.localizedDescription)
                        return Observable.just(.setErrorMessage(errorMessage))
                    },
                Observable.just(.setLoading(false))
            ])
        }
    }
}
