//
//  ProfileReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/14/26.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

class ProfileReactor: Reactor {
    private let userId: Int
    
    init(userId: Int) {
        self.userId = userId
    }
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Profile.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    private let networkManager = ProfileNetworkManager()
    
    let initialState: State = State()
    private let PAGE_SIZE: Int = 20
    
    enum Action {
        case viewWillAppear
        case loadMorePosts
        case refresh // 새로고침
        case postTapped(PostModel) // 게시글 tap
        case reportButtonTapped
        case blockButtonTapped
        case blockUser
        case unBlockUser
    }
    
    enum Mutation {
        case setUserInfo(ProfileUserInfoResponseDataModel)
        case setPosts([PostModel]) // 게시글 설정
        case appendPosts([PostModel]) // 페이지네이션 게시글 추가
        case setPage(Int) // 페이지네이션 페이지 번호 설정
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setHasMore(Bool) // 페이지네이션 추가 가능 여부 설정
        case setShouldPushPostDetailView(PostModel)
        case setShouldPushUserReportView
        case setShouldShowBlockAlert
        case setShouldShowBlockDoneAlert
        case setShouldShowUnBlockAlert
        case setShouldShowUnBlockDoneAlert
        case setErrorMessage(String)
    }
    
    struct State {
        var userInfo: ProfileUserInfoResponseDataModel? // 유저 정보 모델
        var page: Int = 0 // 페이지네이션 페이지 번호
        var posts: [PostModel] = [] // 게시글
        var isLoading: Bool = false
        var hasMore: Bool = true // 페이지네이션 추가 가능 여부
        var isRefreshing: Bool = false
        @Pulse var shouldPushPostDetailView: PostModel?
        @Pulse var shouldPushUserReportView: Void?
        @Pulse var shouldShowBlockAlert: Void?
        @Pulse var shouldShowBlockDoneAlert: Void?
        @Pulse var shouldShowUnBlockAlert: Void?
        @Pulse var shouldShowUnBlockDoneAlert: Void?
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.concat([
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
            return Observable.just(.setShouldPushPostDetailView(model))
            
        case .reportButtonTapped:
            return Observable.just(.setShouldPushUserReportView)
            
        case .blockButtonTapped:
            guard let userInfo = currentState.userInfo else {
                return Observable.empty()
            }
            
            if userInfo.isBlocked {
                return Observable.just(.setShouldShowUnBlockAlert)
            } else {
                return Observable.just(.setShouldShowBlockAlert)
            }
            
        case .blockUser:
            return blockUser()
            
        case .unBlockUser:
            return unBlockUser()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setUserInfo(let model):
            newState.userInfo = model
            
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
            
        case .setShouldPushPostDetailView(let model):
            newState.shouldPushPostDetailView = model
            
        case .setShouldPushUserReportView:
            newState.shouldPushUserReportView = ()
            
        case .setShouldShowBlockAlert:
            newState.shouldShowBlockAlert = ()
            
        case .setShouldShowBlockDoneAlert:
            newState.shouldShowBlockDoneAlert = ()
            
        case .setShouldShowUnBlockAlert:
            newState.shouldShowUnBlockAlert = ()
            
        case .setShouldShowUnBlockDoneAlert:
            newState.shouldShowUnBlockDoneAlert = ()
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    // 홈 게시글 목록 API 호출
    private func loadPosts(page: Int, isFirst: Bool) -> Observable<Mutation> {
        return Observable.deferred {
            Observable.concat([
                Observable.just(.setLoading(true)),
                self.networkManager.getProfilePostList(userId: self.userId, page: page, size: self.PAGE_SIZE)
                    .asObservable()
                    .flatMap { response -> Observable<Mutation> in
                        if let data = response.data {
                            let mutations: Observable<Mutation> = isFirst ?
                            Observable.concat([
                                Observable.just(.setUserInfo(data)),
                                Observable.just(.setPosts(data.posts.posts))
                            ]) : Observable.just(.appendPosts(data.posts.posts))
                            
                            return Observable.concat([
                                mutations,
                                Observable.just(.setHasMore(!data.posts.pageInfo.last))
                            ])
                        } else {
                            if let error = response.error {
                                self.logger.critical("게시글 목록 조회 중 오류: \(error.message)")
                                
                                return Observable.empty()
                            } else {
                                self.logger.critical("게시글 목록 조회 중 오류")
                                
                                return Observable.empty()
                            }
                        }
                    }
                    .catch { error in
                        self.logger.critical("게시글 목록 불러오기 실패: \(error.localizedDescription)")
                        
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
    
    private func blockUser() -> Observable<Mutation> {
        let userInfo = currentState.userInfo
        
        return networkManager.blockUser(userId: userId)
            .asObservable()
            .flatMap { [weak self] model -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                if model.success {
                    if var info = userInfo {
                        info.isBlocked.toggle()
                        
                        self.logger.debug("차단 완료")
                        
                        return Observable.concat([
                            Observable.just(.setUserInfo(info)),
                            Observable.just(.setShouldShowBlockDoneAlert)
                        ])
                    } else {
                        self.logger.fault("차단 중 userInfo가 없음")
                        
                        return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
                    }
                } else {
                    if let error = model.error {
                        self.logger.critical("차단 중 오류: \(error.message)")
                        
                        return Observable.just(.setErrorMessage(String(format: String(localized: "ErrorMessageWithCode", table: "Common"), error.code)))
                    } else {
                        self.logger.critical("차단 중 오류")
                        
                        return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
                    }
                }
            }
            .catch { [weak self] error -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                self.logger.critical("차단 중 오류: \(error.localizedDescription)")
                
                return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
            }
    }
    
    private func unBlockUser() -> Observable<Mutation> {
        let userInfo = currentState.userInfo
        
        return networkManager.unBlockUser(userId: userId)
            .asObservable()
            .flatMap { [weak self] model -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                if model.success {
                    if var info = userInfo {
                        info.isBlocked.toggle()
                        
                        self.logger.debug("차단 해제 완료")
                        
                        return Observable.concat([
                            Observable.just(.setUserInfo(info)),
                            Observable.just(.setShouldShowUnBlockDoneAlert)
                        ])
                    } else {
                        self.logger.fault("차단 해제 중 userInfo가 없음")
                        
                        return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
                    }
                } else {
                    if let error = model.error {
                        self.logger.critical("차단 해제 중 오류: \(error.message)")
                        
                        return Observable.just(.setErrorMessage(String(format: String(localized: "ErrorMessageWithCode", table: "Common"), error.code)))
                    } else {
                        self.logger.critical("차단 해제 중 오류")
                        
                        return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
                    }
                }
            }
            .catch { [weak self] error -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                self.logger.critical("차단 해제 중 오류: \(error.localizedDescription)")
                
                return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
            }
    }
}
