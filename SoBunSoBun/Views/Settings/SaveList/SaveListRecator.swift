//
//  SaveListRecator.swift
//  SoBunSoBun
//
//  Created by 허성필 on 3/17/26.
//

import ReactorKit
import OSLog
import RxSwift

class SaveListRecator: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.SaveList.Reactor"
    )
    
    let initialState = State()
    
    private let networkManager = SettingNetworkManager()
    private let pageSize: Int = 20
    
    enum Action {
        case viewDidLoad
        case cellTapped(PostModel) // 테이블 뷰 셀 클릭
        case refresh
        case loadMore
    }
    
    enum Mutation {
        case setSavedPosts([PostModel]) // 초기 저장 목록 로딩
        case setLoading(Bool)
        case appendSavedPosts([PostModel]) // 추가 저장 목록 로딩
        case setPage(Int)
        case setHasMore(Bool)
        case setRefreshing(Bool)
        case setSavedPostDetail(PostModel)
        case setError(String)
    }
    
    struct State {
        var savedPosts: [PostModel] = []
        var isLoading: Bool = false
        var page: Int = 0
        var hasMore: Bool = true
        var isRefreshing: Bool = false
        
        @Pulse var shouldPushSavedPostDetailView: PostModel? // 해당 게시글로 이동
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.concat([
                Observable.just(.setPage(0)),
                loadSavedPosts(page: currentState.page, size: pageSize, isFirst: true)
            ])
            
        case .cellTapped(let model):
            return Observable.just(.setSavedPostDetail(model))
            
        case .refresh:
            return Observable.concat([
                Observable.just(.setRefreshing(true)),
                Observable.just(.setPage(0)),
                loadSavedPosts(page: 0, size: pageSize, isFirst: true),
                Observable.just(.setRefreshing(false))
            ])
            
        case .loadMore:
            guard !currentState.isLoading && currentState.hasMore else {
                return Observable.empty()
            }
            
            let nextPage = currentState.page + 1
            
            return Observable.concat([
                Observable.just(.setPage(nextPage)),
                loadSavedPosts(page: nextPage, size: pageSize, isFirst: false)
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setSavedPosts(let savedPosts):
            newState.savedPosts = savedPosts
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .appendSavedPosts(let savedPosts):
            newState.savedPosts.append(contentsOf: savedPosts)
            
        case .setPage(let page):
            newState.page = page
            
        case .setHasMore(let hasMore):
            newState.hasMore = hasMore
            
        case .setRefreshing(let isRefreshing):
            newState.isRefreshing = isRefreshing
            
        case .setSavedPostDetail(let model):
            newState.shouldPushSavedPostDetailView = model
            
        case .setError(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func loadSavedPosts(page: Int, size: Int, isFirst: Bool) -> Observable<Mutation> {
        return Observable.deferred {
            self.networkManager.getSavePosts(page: page, size: size)
                .asObservable()
                .flatMap { response -> Observable<Mutation> in
                    self.logger.debug("저장 목록 조회 성공")
                    
                    let mutations: Observable<Mutation> = isFirst
                    ? Observable.just(.setSavedPosts(response.posts))
                    : Observable.just(.appendSavedPosts(response.posts))
                    
                    return Observable.concat([
                        mutations,
                        Observable.just(.setHasMore(!response.pageInfo.last))
                    ])
                }
                .catch { error in
                    self.logger.critical("저장 목록 불러오기 실패: \(error.localizedDescription)")
                    
                    return Observable.concat([
                        isFirst ? Observable.just(.setSavedPosts([])) : Observable.empty(),
                        Observable.just(.setError(String(localized: "FailToLoadSavedPosts", table: "Settings"))),
                        Observable.just(.setHasMore(false)),
                        Observable.just(.setPage(0))
                    ])
                }
        }
    }
}
