//
//  MyProfileReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/18/26.
//

import Foundation
import ReactorKit
import OSLog

class MyProfileReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Home.MyProfile.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    private let networkManager = HomeNetworkManager()
    
    let initialState: State = State()
    private let PAGE_SIZE: Int = 20
    
    enum Action {
        case viewWillAppear
        case settingButtonTapped
        case editProfileButtonTapped
        case tabSelected(Int)
        case loadMorePosts
        case refresh // 새로고침
        case postTapped(PostModel) // 게시글 tap
    }
    
    enum Mutation {
        case setShouldPushToSettingView
        case setShouldPushToEditProfileView
        case setMyUserInfo(MyProfileResponseDataModel?)
        case setTab(Int)
        case setPosts([PostModel]) // 게시글 설정
        case appendPosts([PostModel]) // 페이지네이션 게시글 추가
        case setPage(Int) // 페이지네이션 페이지 번호 설정
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setHasMore(Bool) // 페이지네이션 추가 가능 여부 설정
        case setShouldPushToPostDetailView(PostModel)
        case setErrorMessage(String)
    }
    
    struct State {
        var userInfo: MyProfileResponseDataModel? // 내 정보 모델
        var tabIndex: Int = 0
        var page: Int = 0 // 페이지네이션 페이지 번호
        var posts: [PostModel] = [] // 게시글
        var isLoading: Bool = false
        var hasMore: Bool = true // 페이지네이션 추가 가능 여부
        var isRefreshing: Bool = false
        @Pulse var shouldPushToSettingView: Void?
        @Pulse var shouldPushToEditProfileView: Void?
        @Pulse var shouldPushToPostDetailView: PostModel?
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.concat([
                Observable.just(.setPage(0)),
                loadPosts(page: 0, isFirst: true)
            ])
            
        case .settingButtonTapped:
            return Observable.just(.setShouldPushToSettingView)
            
        case .editProfileButtonTapped:
            return Observable.just(.setShouldPushToEditProfileView)
            
        case .tabSelected(let index):
            return Observable.concat([
                Observable.just(.setTab(index)),
                Observable.just(.setPosts([])),
                Observable.just(.setPage(0)),
                loadPosts(page: 0, isFirst: true)
            ])
            
        case .loadMorePosts:
            guard !currentState.isLoading && currentState.hasMore else {
                return Observable.empty()
            }
            
            let nextPage = currentState.page + 1
            
            return Observable.concat([
                Observable.just(.setPage(nextPage)),
                loadPosts(page: nextPage, isFirst: false)
            ])
            
        case .refresh:
            return Observable.concat([
                Observable.just(.setRefreshing(true)),
                Observable.just(.setPage(0)),
                loadPosts(page: 0, isFirst: true),
                Observable.just(.setRefreshing(false))
            ])
            
        case .postTapped(let model):
            return Observable.just(.setShouldPushToPostDetailView(model))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setMyUserInfo(let model):
            newState.userInfo = model
            
        case .setShouldPushToSettingView:
            newState.shouldPushToSettingView = ()
            
        case .setShouldPushToEditProfileView:
            newState.shouldPushToEditProfileView = ()
            
        case .setTab(let index):
            newState.tabIndex = index
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setRefreshing(let isRefreshing):
            newState.isRefreshing = isRefreshing
            
        case .setPosts(let posts):
            newState.posts = posts
            
        case .appendPosts(let posts):
            newState.posts.append(contentsOf: posts)
            
        case .setPage(let page):
            newState.page = page
            
        case .setHasMore(let hasMore):
            newState.hasMore = hasMore
            
        case .setShouldPushToPostDetailView(let model):
            newState.shouldPushToPostDetailView = model
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    // 홈 게시글 목록 API 호출
    private func loadPosts(page: Int, isFirst: Bool) -> Observable<Mutation> {
        let tabs: [String] = ["posts", "commented", "saved"]
        
        return Observable.deferred {
            Observable.concat([
                Observable.just(.setLoading(true)),
                self.networkManager.getMyProfile(tab: tabs[self.currentState.tabIndex], page: page, size: self.PAGE_SIZE)
                    .asObservable()
                    .flatMap { response -> Observable<Mutation> in
                        if let data = response.data {
                            let mutations: Observable<Mutation> = isFirst ?
                            Observable.concat([
                                Observable.just(.setMyUserInfo(data)),
                                Observable.just(.setPosts(data.posts.posts))
                            ]) : Observable.just(.appendPosts(data.posts.posts))
                            
                            return Observable.concat([
                                mutations,
                                Observable.just(.setHasMore(!data.posts.pageInfo.last))
                            ])
                        } else {
                            if let error = response.error {
                                self.logger.critical("내 정보 조회 중 오류: \(error.message)")
                                
                                return Observable.empty()
                            } else {
                                self.logger.critical("내 정보 조회 중 오류")
                                
                                return Observable.empty()
                            }
                        }
                    }
                    .catch { error in
                        self.logger.critical("내 정보 불러오기 실패: \(error.localizedDescription)")
                        
                        return Observable.concat([
                            isFirst ? Observable.just(.setPosts([])) : Observable.empty(),
                            Observable.just(.setHasMore(false)),
                            Observable.just(.setPage(0))
                        ])
                    },
                Observable.just(.setLoading(false))
            ])
        }
    }
}
