//
//  MyPostReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 3/2/26.
//

import ReactorKit
import RxSwift
import OSLog

class MyPostReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.MyPost.Reactor"
    )
    
    let initialState = State()
    
    private let networkManager = SettingNetworkManager()
    private let pageSize: Int = 20
    
    enum Action {
        case viewWillAppear
        case loadMore // 페이지네이션
        case refresh // 새로고침
        case cellTapped(PostModel) // 셀 클릭
        case menuButtonTapped(Int) // 셀의 메뉴버튼 클릭
    }
    
    enum Mutation {
        case setMyPosts([PostModel]) // 초기 내 게시글 로딩
        case setLoading(Bool)
        case setAppendMyPosts([PostModel]) // 추가 내 게시글 로딩
        case setPage(Int)
        case setHasMore(Bool)
        case setRefreshing(Bool)
        case setError(String)
        case setMyPostDetailView(PostModel)
    }
    
    struct State {
        var myPosts: [PostModel] = []
        var isLoading: Bool = false
        var page: Int = 0 // 페이지네이션 페이지 번호
        var hasMore: Bool = true //  페이지네이션 추가 가능 여부
        var isRefreshing: Bool = false // 새로고침 여부
        @Pulse var errorMessage: String?
        @Pulse var shouldPushMyPostDetailView: PostModel? // 해당 게시글로 이동
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.concat([
                Observable.just(.setPage(0)),
                loadMyPosts(page: currentState.page, size: pageSize, isFirst: true)
            ])
            
        case .loadMore:
            guard !currentState.isLoading && currentState.hasMore else {
                return Observable.empty()
            }
            
            let nextPage = currentState.page + 1
            
            return Observable.concat([
                Observable.just(.setPage(nextPage)),
                loadMyPosts(page: nextPage, size: pageSize, isFirst: false)
            ])
            
        case .refresh:
            return Observable.concat([
                Observable.just(.setRefreshing(true)),
                Observable.just(.setPage(0)),
                loadMyPosts(page: 0, size: pageSize, isFirst: true),
                Observable.just(.setRefreshing(false))
            ])
            
        case .cellTapped(let model):
            return Observable.just(.setMyPostDetailView(model))
            
        case .menuButtonTapped(let id):
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setMyPosts(let myPosts):
            newState.myPosts = myPosts
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setAppendMyPosts(let myPosts):
            newState.myPosts.append(contentsOf: myPosts)
            
        case .setPage(let page):
            newState.page = page
            
        case .setHasMore(let hasMore):
            newState.hasMore = hasMore
            
        case .setRefreshing(let isRefreshing):
            newState.isRefreshing = isRefreshing
            
        case .setError(let message):
            newState.errorMessage = message
            
        case .setMyPostDetailView(let model):
            newState.shouldPushMyPostDetailView = model
        }
        
        return newState
    }
    
    private func loadMyPosts(page: Int, size: Int, isFirst: Bool) -> Observable<Mutation> {
        return Observable.concat([
            Observable.just(.setLoading(true)),
            networkManager.getMyPosts(page: page, size: size)
                .asObservable()
                .flatMap { response -> Observable<Mutation> in
                    self.logger.debug("내 게시글 조회 성공")
                    
                    let mutations: Observable<Mutation> = isFirst
                    ? Observable.just(.setMyPosts(response.posts))
                    : Observable.just(.setAppendMyPosts(response.posts))
                    
                    return Observable.concat([
                        mutations,
                        Observable.just(.setHasMore(!response.pageInfo.last))
                    ])
                }
                .catch { error in
                    self.logger.critical("내가 게시한 글 불러오기 실패: \(error.localizedDescription)")
                    
                    return Observable.concat([
                        isFirst ? Observable.just(.setMyPosts([])) : Observable.empty(),
                        Observable.just(.setHasMore(false)),
                        Observable.just(.setPage(0))
                    ])
                },
            Observable.just(.setLoading(false)).delay(.seconds(1), scheduler: MainScheduler.instance)
        ])
    }
}
