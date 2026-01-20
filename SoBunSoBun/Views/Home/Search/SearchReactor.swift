//
//  SearchReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 1/14/26.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

class SearchReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Home.Search.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    
    let initialState: State = State()
    private let pageSize: Int = 20
    
    enum Action {
        case viewWillAppear
        case viewTapped
        case backButtonTapped
        case search(String)
        case quickSearch(String)
        case clearAllTapped
        case clearOneSearchHistoryTapped(String)
        case sortButtonTapped
        case sortTapped(String)
        case postTapped(PostModel)
        case loadMorePosts
    }
    
    enum Mutation {
        case setSuggestions([String])
        case setGoBack
        case setHistory([String])
        case setKeyword(String)
        case setPosts([PostModel])
        case appendPosts([PostModel])
        case setLoading(Bool)
        case setPage(Int)
        case setHasMore(Bool)
        case setIsSortButtonOpen(Bool)
        case setSort(String)
        case setPostDetailView(PostModel)
        
        case setErrorMessage(String)
    }
    
    struct State {
        @Pulse var shouldGoBack: Void?
        
        var suggestions: [String] = []
        var history: [String] = []
        var keyword: String = ""
        var isSortButtonOpen: Bool = false
        var sortBy: String = "SortByLatest"
        var page: Int = 0
        var posts: [PostModel]? = nil
        @Pulse var shouldPushPostDetailView: PostModel?
        var isLoading: Bool = false
        var hasMore: Bool = true
        
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.concat([
                getSearchHistory(),
                getSuggestions()
            ])
            
        case .viewTapped:
            return Observable.just(.setIsSortButtonOpen(false))
            
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
                    Observable.just(.setErrorMessage(String(localized: "CheckYourInputs")))
                ])
            }
            
            let sortBy = currentState.sortBy
            return Observable.concat([
                Observable.just(.setKeyword(trimmedText)),
                Observable.just(.setIsSortButtonOpen(false)),
                addSearchHistory(text: trimmedText),
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
        case .setSuggestions(let suggestions):
            newState.suggestions = suggestions
            
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
    
    // 추천 검색어 불러오기
    private func getSuggestions() -> Observable<Mutation> {
        return NetworkManager.shared.getSuggestions()
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                return Observable.just(.setSuggestions(model.suggestions))
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.empty() }
                
                logger.critical("추천 검색어 API 호출 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(String(localized: "ErrorMessage")))
            }
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
        let api: Single<PostListResponseModel> = NetworkManager.shared.getSearchList(keyword: keyword, sortBy: sortBy, page: page, size: pageSize)
        
        return Observable.concat([
            Observable.just(.setLoading(true)),
            api.asObservable()
                .flatMap { response -> Observable<Mutation> in
                    let mutations: Observable<Mutation> = isFirst
                    ? Observable.just(.setPosts(response.posts))
                    : Observable.just(.appendPosts(response.posts))
                    
                    return Observable.concat([
                        mutations,
                        Observable.just(.setHasMore(!response.pageInfo.last)),
                        Observable.just(.setLoading(false)).delay(.seconds(1), scheduler: MainScheduler.instance)
                    ])
                }
                .catch { error in
                    self.logger.fault("게시글 목록 불러오기 실패: \(error.localizedDescription)")
                    return Observable.concat([
                        isFirst ? Observable.just(.setPosts([])) : Observable.empty(),
                        Observable.just(.setLoading(false)).delay(.seconds(1), scheduler: MainScheduler.instance),
                        Observable.just(.setHasMore(false))
                    ])
                }
        ])
    }
}
