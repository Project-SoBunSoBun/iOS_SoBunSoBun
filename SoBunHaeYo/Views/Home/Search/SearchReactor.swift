//
//  SearchReactor.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 1/14/26.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

class SearchReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Home.Search.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    private let networkManager = HomeNetworkManager()
    
    let initialState: State = State()
    private let pageSize: Int = 20
    
    enum Action {
        case viewWillAppear // viewWillAppear 생명주기 실행
        case backButtonTapped // 뒤로가기 버튼 Tap
        case search(String) // 검색 실행
        case quickSearch(String) // 버튼을 눌렀을 때 바로 검색 실행
        case clearAllTapped // 모두 지우기 tap
        case clearOneSearchHistoryTapped(String) // 하나의 기록 지우기 tap
        case sortButtonTapped // 정렬 목록 버튼 tap
        case sortTapped(String) // 정렬 tap
        case postTapped(PostModel) // 게시글 tap
        case loadMorePosts // 페이지네이션
    }
    
    enum Mutation {
        case setGoBack // 뒤로가기
        case setHistory([String]) // 검색 기록 설정
        case setKeyword(String) // 검색창 텍스트 설정
        case setPosts([PostModel]) // 게시글 설정
        case appendPosts([PostModel]) // 페이지네이션 게시글 추가
        case setLoading(Bool)
        case setPage(Int) // 페이지네이션 페이지 번호 설정
        case setHasMore(Bool) // 페이지네이션 추가 가능 여부 설정
        case setIsSortButtonOpen(Bool) // 정렬 목록 버튼 열림 여부
        case setSort(String) // 정렬 설정
        case setPostDetailView(PostModel) // 게시글 상세 뷰로 이동
        case setErrorMessage(String) // 오류 메시지 알림 표시 설정
    }
    
    struct State {
        @Pulse var shouldGoBack: Void? // 뒤로 가기
        var history: [String] = [] // 검색 기록
        var keyword: String = "" // 검색창 텍스트
        var isSortButtonOpen: Bool = false // 정렬 목록 버튼 열림
        var sortBy: String = "SortByLatest" // 정렬
        var page: Int = 0 // 페이지네이션 페이지 번호
        var posts: [PostModel]? = nil // 게시글
        @Pulse var shouldPushPostDetailView: PostModel? // 게시글 상세 뷰로 이동
        var isLoading: Bool = false
        var hasMore: Bool = true // 페이지네이션 추가 가능 여부
        @Pulse var errorMessage: String? // 오류 메시지
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return getSearchHistory()
            
        case .backButtonTapped:
            return Observable.just(.setGoBack)
            
        case .quickSearch(let text):
            let sortBy = currentState.sortBy
            return Observable.concat([
                Observable.just(.setKeyword(text)),
                addSearchHistory(text: text),
                loadPosts(keyword: text, sortBy: sortBy, page: 0, isFirst: true)
            ])
            
        case .clearAllTapped:
            return clearAllSearchHistory()
            
        case .clearOneSearchHistoryTapped(let text):
            return clearOneSearchHistory(text: text)
            
        case .search(let text):
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !trimmedText.isEmpty else {
                return Observable.concat([
                    Observable.just(.setKeyword("")),
                    Observable.just(.setErrorMessage(String(localized: "CheckYourInputs", table: "Common")))
                ])
            }
            
            let sortBy = currentState.sortBy
            return Observable.concat([
                Observable.just(.setKeyword(trimmedText)),
                Observable.just(.setIsSortButtonOpen(false)),
                addSearchHistory(text: trimmedText),
                Observable.just(.setPage(0)),
                loadPosts(keyword: trimmedText, sortBy: sortBy, page: 0, isFirst: true)
            ])
            
        case .loadMorePosts:
            guard !currentState.isLoading && currentState.hasMore else {
                return Observable.empty()
            }
            
            let keyword = currentState.keyword
            let sortBy = currentState.sortBy
            let nextPage = currentState.page + 1
            
            return Observable.concat([
                Observable.just(.setPage(nextPage)),
                loadPosts(keyword: keyword, sortBy: sortBy, page: nextPage, isFirst: false)
            ])
            
        case .sortButtonTapped:
            return Observable.just(.setIsSortButtonOpen(!currentState.isSortButtonOpen))
            
        case .sortTapped(let sortBy):
            let keyword = currentState.keyword
            
            return Observable.concat([
                Observable.just(.setIsSortButtonOpen(false)),
                Observable.just(.setSort(sortBy)),
                loadPosts(keyword: keyword, sortBy: sortBy, page: 0, isFirst: true)
            ])
            
        case .postTapped(let model):
            return Observable.concat([
                Observable.just(.setIsSortButtonOpen(false)),
                Observable.just(.setPostDetailView(model))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setGoBack:
            newState.shouldGoBack = ()
            
        case .setHistory(let history):
            newState.history = history
            
        case .setKeyword(let text):
            newState.keyword = text
            
        case .setPosts(let posts):
            newState.posts = posts
            
        case .appendPosts(let posts):
            newState.posts?.append(contentsOf: posts)
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setPage(let page):
            newState.page = page
            
        case .setHasMore(let hasMore):
            newState.hasMore = hasMore
            
        case .setIsSortButtonOpen(let isOpen):
            newState.isSortButtonOpen = isOpen
            
        case .setSort(let sortBy):
            newState.sortBy = sortBy
            
        case .setPostDetailView(let model):
            newState.shouldPushPostDetailView = model
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private let userDefaultsKey: String = "SearchHistory"
    
    // 최근 검색어 불러오기
    private func getSearchHistory() -> Observable<Mutation> {
        let history = UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
        
        return Observable.just(.setHistory(history))
    }
    
    // 최근 검색어 추가
    private func addSearchHistory(text: String) -> Observable<Mutation> {
        var history = currentState.history
        
        if let removeIndex = history.firstIndex(of: text) {
            history.remove(at: removeIndex)
        }
        
        history.append(text)
        
        UserDefaults.standard.set(history, forKey: userDefaultsKey)
        
        return Observable.just(.setHistory(history))
    }
    
    // 최근 검색어 모두 지우기
    private func clearAllSearchHistory() -> Observable<Mutation> {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        
        return Observable.just(.setHistory([]))
    }
    
    // 최근 검색어 하나 지우기
    private func clearOneSearchHistory(text: String) -> Observable<Mutation> {
        var history = currentState.history
        
        if let removeIndex = history.firstIndex(of: text) {
            history.remove(at: removeIndex)
        }
        
        UserDefaults.standard.set(history, forKey: userDefaultsKey)
        
        return Observable.just(.setHistory(history))
    }
    
    // 검색 목록 API 호출
    private func loadPosts(keyword: String, sortBy: String, page: Int, isFirst: Bool) -> Observable<Mutation> {
        let sortBy = sortBy.replacingOccurrences(of: "SortBy", with: "").lowercased()
        
        // API 호출
        let api: Single<PostListResponseModel> = networkManager.getSearchList(keyword: keyword, sortBy: sortBy, page: page, size: pageSize)
        
        return Observable.deferred {
            Observable.concat([
                Observable.just(.setLoading(true)),
                api.asObservable()
                    .flatMap { response -> Observable<Mutation> in
                        let mutations: Observable<Mutation> = isFirst
                            ? Observable.just(.setPosts(response.posts))
                            : Observable.just(.appendPosts(response.posts))

                        return Observable.concat([
                            mutations,
                            Observable.just(.setHasMore(!response.pageInfo.last))
                        ])
                    }
                    .catch { error in
                        self.logger.fault("게시글 목록 불러오기 실패: \(error.localizedDescription)")

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
