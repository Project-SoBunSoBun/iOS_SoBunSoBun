//
//  SettleUpReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 11/14/25.
//

import ReactorKit
import RxSwift
import OSLog

enum SettleUpCategory: Int {
    case all = 0
    case incomplete = 1
    case complete = 2
}

class SettleUpReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "SettleUp.SettleUp.Reactor"
    )
    
    let initialState = State()
    
    private let disposeBag = DisposeBag()
    
    private let networkManager = SettleUpNetworkManager()
    private let pageSize: Int = 20
    
    enum Action {
        case viewWillAppear
        case refresh // 새로고침
        case loadMore // 페이지네이션
        case categorySelected(SettleUpCategory)
    }
    
    enum Mutation {
        case setSelectedCategory(SettleUpCategory)
        case setItems([SettleUpItemModel])
        case appendItems([SettleUpItemModel])
        case setPage(Int)
        case setHasMore(Bool)
        case setRefreshing(Bool)
        case setErrorMessage(String)
    }
    
    struct State {
        var selectedCategory: SettleUpCategory = .all
        var items: [SettleUpItemModel] = []
        var page: Int = 0 // 페이지네이션 페이지 번호
        var hasMore: Bool = true // 새로고침 여부
        var isRefreshing: Bool = false // 새로고침 여부
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {   
        case .viewWillAppear:
            return Observable.concat([
                Observable.just(.setPage(0)),
                loadItems(page: 0, size: pageSize, isFirst: true),
            ])
            
            
        case .refresh:
            return Observable.concat([
                Observable.just(.setRefreshing(true)),
                Observable.just(.setPage(0)),
                loadItems(page: 0, size: pageSize, isFirst: true),
                Observable.just(.setRefreshing(false))
            ])
            
        case .loadMore:
            guard currentState.hasMore else {
                return Observable.empty()
            }
            
            let nextPage = currentState.page + 1
            
            return Observable.concat([
                Observable.just(.setPage(nextPage)),
                loadItems(page: nextPage, size: pageSize, isFirst: false)
            ])
            
        case .categorySelected(let category):
            return Observable.concat([
                Observable.just(.setSelectedCategory(category)),
                Observable.just(.setPage(0)),
                loadItems(for: category, page: 0, size: pageSize, isFirst: true)
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            
        case .setSelectedCategory(let category):
            newState.selectedCategory = category
            
        case .setItems(let items):
            newState.items = items
            
        case .appendItems(let items):
            newState.items.append(contentsOf: items)
            
        case .setPage(let page):
            newState.page = page
            
        case .setHasMore(let hasMore):
            newState.hasMore = hasMore
            
        case .setRefreshing(let isRefreshing):
            newState.isRefreshing = isRefreshing
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        return newState
    }
    
    private func loadItems(for category: SettleUpCategory? = nil, page: Int, size: Int, isFirst: Bool) -> Observable<Mutation> {
        let selectedCategory = category ?? currentState.selectedCategory
        let status: String
        
        switch selectedCategory {
        case .all:
            status = "ALL"
            
        case .incomplete:
            status = "PENDING"
            
        case .complete:
            status = "COMPLETED"
        }
        
        return Observable.deferred {
            self.networkManager.mySettleUps(status: status, page: page, size: size)
                .asObservable()
                .flatMap { response -> Observable<Mutation> in
                    if response.success {
                        guard let userId = KeyChain.shared.get(key: "USER_ID") else { return Observable.empty() }
                        
                        let currentUserId = Int(userId)
                        
                        let items: [SettleUpItemModel] = response.data.content.map { content in
                            let isCompleted = (content.status == "COMPLETED")
                            
                            return SettleUpItemModel(
                                settlementId: content.id,
                                authorId: content.authorId,
                                isAuthor: content.authorId == currentUserId,
                                settlementStatus: isCompleted,
                                title: content.groupPostTitle,
                                location: content.locationName,
                                meetingDate: content.meetAt,
                                participants: content.chatRoomMembers
                            )
                        }
                        
                        let mutation: Observable<Mutation> = isFirst
                        ? Observable.just(.setItems(items))
                        : Observable.just(.appendItems(items))
                        
                        return Observable.concat([
                            mutation,
                            Observable.just(.setHasMore(!response.data.last))
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
                .catch { [weak self] error in
                    guard let self = self else { return Observable.empty() }
                    
                    self.logger.critical("정산 목록 로드 실패: \(error.localizedDescription)")
                    
                    let errorMessage = String(format: String(localized: "ErrorMessageWithReason", table: "Error"), error.localizedDescription)
                    return Observable.concat([
                        isFirst ? Observable.just(.setItems([])) : Observable.empty(),
                        Observable.just(.setErrorMessage(errorMessage)),
                        Observable.just(.setHasMore(false))
                    ])
                }
        }
    }
}
