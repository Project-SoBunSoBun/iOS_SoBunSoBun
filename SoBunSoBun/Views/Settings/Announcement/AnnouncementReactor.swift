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
    private let pageSize: Int = 20
    
    enum Action {
        case viewWillAppear
        case loadMore // 페이지네이션
        case refresh // 새로고침
        case cellTapped(AnnouncementContentModel) // 셀 클릭
    }
    
    enum Mutation {
        case setNotice([AnnouncementContentModel])
        case setError(String)
        case setLoading(Bool)
        case setRefreshing(Bool)
        case appendNotice([AnnouncementContentModel])
        case setPage(Int)
        case setHasMore(Bool)
        case setNoticeDetailView(AnnouncementContentModel)
    }
    
    struct State {
        var notices: [AnnouncementContentModel] = [] // 공지사항
        var page: Int = 0 // 페이지네이션 페이지 번호
        var isLoading: Bool = false
        var isRefreshing: Bool = false
        var hasMore: Bool = true // 페이지네이션 추가 가능 여부
        @Pulse var errorMessage: String?
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
            
        case .setNotice(let notices):
            newState.notices = notices
            
        case .setError(let message):
            newState.errorMessage = message
            
        case .setRefreshing(let isRefreshing):
            newState.isRefreshing = isRefreshing
            
        case .appendNotice(let notices):
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
        return Observable.concat([
            Observable.just(.setLoading(true)),
            networkManager.getAnnouncements(page: page, size: size)
                .asObservable()
                .flatMap { response -> Observable<Mutation> in
                    self.logger.debug("공지사항 조회 성공")
                    
                    let isFirst = response.data.page.first
                    
                    return Observable.concat([
                        isFirst ? Observable.just(.setNotice(response.data.content)) : Observable.just(.appendNotice(response.data.content)),
                        Observable.just(.setHasMore(!response.data.page.last)),
                        Observable.just(.setLoading(false)).delay(.seconds(1), scheduler: MainScheduler.instance)
                    ])
                }
                .catch { error in
                    self.logger.fault("공지사항 조회 실패: \(error.localizedDescription)")
                    return Observable.concat([
                        Observable.just(.setError(error.localizedDescription)),
                        Observable.just(.setLoading(false)).delay(.seconds(1), scheduler: MainScheduler.instance)
                    ])
                }
        ])
    }
}
