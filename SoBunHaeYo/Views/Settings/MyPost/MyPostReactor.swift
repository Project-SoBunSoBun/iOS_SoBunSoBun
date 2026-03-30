//
//  MyPostReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 3/2/26.
//

import ReactorKit
import RxSwift
import OSLog

class MyPostReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.MyPost.Reactor"
    )
    
    let initialState = State()
    
    private let settingNetworkManager = SettingNetworkManager()
    private let homeNetworkManager = HomeNetworkManager()
    private let pageSize: Int = 20
    
    enum Action {
        case viewWillAppear
        case loadMore // 페이지네이션
        case refresh // 새로고침
        case cellTapped(PostModel) // 테이블 뷰 셀 클릭
        case openMenu(id: Int) // 드롭다운 메뉴 열기 + 선택된 id 저장
        case closeMenu // 드롭다운 메뉴 닫기
        case deletePostId(Int) // 게시글 삭제 id
    }
    
    enum Mutation {
        case setMyPosts([PostModel]) // 초기 내 게시글 로딩
        case setLoading(Bool)
        case setAppendMyPosts([PostModel]) // 추가 내 게시글 로딩
        case setPage(Int)
        case setHasMore(Bool)
        case setRefreshing(Bool)
        case setMyPostDetailView(PostModel)
        case setSelectedId(Int)
        case setIsMenuOpen(Bool)
        case removePostById(Int)
        case setShouldShowDeletePostDoneAlert
        case setErrorMessage(String)
    }
    
    struct State {
        var myPosts: [PostModel] = []
        var isLoading: Bool = false
        var page: Int = 0 // 페이지네이션 페이지 번호
        var hasMore: Bool = true //  페이지네이션 추가 가능 여부
        var isRefreshing: Bool = false // 새로고침 여부
        
        @Pulse var shouldPushMyPostDetailView: PostModel? // 해당 게시글로 이동
        
        var selectedId: Int? // 선택된 게시글 id
        var isMenuOpen: Bool = false // 드롭다운 개폐
        
        @Pulse var shouldShowDeletePostDoneAlert: Void? // 삭제 완료 알러트
        @Pulse var errorMessage: String? // 에러 메세지
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
            
        case .openMenu(id: let id):
            return Observable.concat([
                Observable.just(.setSelectedId(id)),
                Observable.just(.setIsMenuOpen(true))
            ])
            
        case .closeMenu:
            return Observable.just(.setIsMenuOpen(false))
            
        case .deletePostId(let id):
            return deletePost(id: id)
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
            
        case .setMyPostDetailView(let model):
            newState.shouldPushMyPostDetailView = model
            
        case .setIsMenuOpen(let isMenuOpen):
            newState.isMenuOpen = isMenuOpen
            
        case .setSelectedId(let id):
            newState.selectedId = id
            
        case .removePostById(let id):
            if let index = newState.myPosts.firstIndex(where: { $0.id == id }) {
                newState.myPosts.remove(at: index)
            }
            
        case .setShouldShowDeletePostDoneAlert:
            newState.shouldShowDeletePostDoneAlert = ()
        
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func loadMyPosts(page: Int, size: Int, isFirst: Bool) -> Observable<Mutation> {
        return Observable.deferred {
            self.settingNetworkManager.getMyPosts(page: page, size: size)
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
                }
        }
    }
    
    private func deletePost(id: Int) -> Observable<Mutation> {
        return Observable.deferred {
            Observable.concat([
                Observable.just(.setLoading(true)),
                self.homeNetworkManager.deletePost(id: id)
                    .asObservable()
                    .flatMap { response -> Observable<Mutation> in
                        if response.success {
                            self.logger.debug("게시글 삭제 성공")
                            
                            return Observable.concat([
                                Observable.just(.removePostById(id)),
                                Observable.just(.setShouldShowDeletePostDoneAlert),
                                Observable.just(.setLoading(false))
                            ])
                        } else {
                            if let errorCode = response.errorCode {
                                self.logger.critical("게시글 삭제 실패(\(errorCode)) - \(response.message ?? "")")
                                
                                return Observable.concat([
                                    Observable.just(.setErrorMessage(localizedErrorMessage(errorCode))),
                                    Observable.just(.setLoading(false))
                                ])
                            } else {
                                self.logger.critical("게시글 삭제 실패: \(response.message ?? "")")
                                
                                return Observable.concat([
                                    Observable.just(.setErrorMessage(localizedErrorMessage(nil))),
                                    Observable.just(.setLoading(false))
                                ])
                            }
                        }
                    }
                    .catch { [weak self] error in
                        guard let self = self else { return Observable.empty() }
                        
                        self.logger.error("게시글 삭제 실패: \(error.localizedDescription)")
                        
                        return Observable.concat([
                            Observable.just(.setErrorMessage(String(format: String(localized: "ErrorMessageWithReason", table: "Error"), error.localizedDescription))),
                            Observable.just(.setLoading(false))
                        ])
                    }
            ])
        }
    }
}
